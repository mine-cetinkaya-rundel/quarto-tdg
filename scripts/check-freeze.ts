// Check that the committed _freeze/ files match their source files.
//
// CI renders the book from _freeze/ only, with no R or Python. If a freeze
// file is stale or missing, Quarto tries to execute the chapter and fails with
// an unclear error. This script fails first, with a clear message.
//
// Run with: quarto run scripts/check-freeze.ts
//
// The hash rule follows freezeInputHash() in quarto-cli
// src/command/render/freeze.ts: MD5 of the source text with CRLF -> LF.

import { createHash } from "node:crypto";
import { existsSync, walkSync } from "stdlib/fs";
import { dirname, fromFileUrl, join, relative, resolve } from "stdlib/path";

const projectDir = resolve(dirname(fromFileUrl(import.meta.url)), "..");
const freezeDir = join(projectDir, "_freeze");
const inGitHub = !!Deno.env.get("GITHUB_ACTIONS");

const problems: { file: string; message: string }[] = [];

const toPosix = (p: string) => p.split("\\").join("/");

function sourceHash(path: string): string {
  const text = Deno.readTextFileSync(path).replaceAll("\r\n", "\n");
  return createHash("md5").update(text).digest("hex");
}

// Check A: stale freeze files ------------------------------------------------
let freezeCount = 0;
if (existsSync(freezeDir)) {
  for (
    const entry of walkSync(freezeDir, { exts: [".json"], includeDirs: false })
  ) {
    const rel = toPosix(relative(freezeDir, entry.path));
    const m = rel.match(/^(.*)\/execute-results\/[^/]+\.json$/);
    if (!m) continue;
    freezeCount++;
    const source = `${m[1]}.qmd`;
    const sourcePath = join(projectDir, source);
    if (!existsSync(sourcePath)) {
      console.warn(`Warning: _freeze/${rel} has no source file ${source}.`);
      continue;
    }
    const frozen = JSON.parse(Deno.readTextFileSync(entry.path));
    if (frozen.hash !== sourceHash(sourcePath)) {
      problems.push({
        file: source,
        message: `${source} changed after its freeze was made. ` +
          `Render it locally, then commit _freeze/${m[1]}/.`,
      });
    }
  }
}

// Check B: missing freeze files ----------------------------------------------
const binPath = Deno.env.get("QUARTO_BIN_PATH");
const quarto = binPath ? join(binPath, "quarto") : "quarto";
const out = new Deno.Command(quarto, {
  args: ["inspect", projectDir],
  cwd: projectDir,
  stdout: "piped",
  stderr: "inherit",
}).outputSync();
if (!out.success) {
  console.error("Error: `quarto inspect` failed.");
  Deno.exit(1);
}
const inspect = JSON.parse(new TextDecoder().decode(out.stdout));

for (const input of inspect.files?.input ?? []) {
  // files.input paths are absolute; fileInformation keys are relative.
  const source = toPosix(relative(projectDir, input));
  const info = inspect.fileInformation?.[source] ??
    inspect.fileInformation?.[input];
  if (!info) continue;
  const hasCode = (info.codeCells ?? []).length > 0;
  if (!hasCode || info.metadata?.engine === "markdown") continue;

  const stem = source.replace(/\.qmd$/, "");
  const resultsDir = join(freezeDir, stem, "execute-results");
  const hasFreeze = existsSync(resultsDir) &&
    [...Deno.readDirSync(resultsDir)].some((e) =>
      e.isFile && e.name.endsWith(".json")
    );
  if (!hasFreeze) {
    problems.push({
      file: source,
      message: `${source} has executable code but no freeze file. ` +
        `Render it locally, then commit _freeze/${stem}/.`,
    });
  }
}

// Report ---------------------------------------------------------------------
if (problems.length === 0) {
  console.log(`All ${freezeCount} freeze files are up to date.`);
  Deno.exit(0);
}

for (const p of problems) {
  console.error(p.message);
  if (inGitHub) {
    console.log(
      `::error file=${p.file},title=Freeze out of date::${p.message}`,
    );
  }
}
Deno.exit(1);
