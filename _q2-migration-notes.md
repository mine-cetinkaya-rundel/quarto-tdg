# Rendering the book with q2

Two goals:

1. The book renders with q2.
2. The book doesn't teach syntax that fails in q2. Errors in the book's
   own examples are findings to review, not noise to fix automatically.

Notes from a first attempt to render the book with q2 v0.45.0 (2026-11-16), on
branch `q2-render`: latest `main` with open PRs #39, #37, #28, #22 and #17 merged.

## First render

`q2 render --to html` rendered 0 of 39 files, with 192 errors.

- **Syntax errors (about 165).** Mostly generic parse errors. Also:
  - 53 × Q-2-3: a class after a `key=value` pair in `{...}`
  - 5 × Q-2-41: bare `{...}` in prose
  - 2 × Q-2-32: `***bold italics***`
  - indented code blocks inside lists

  By chapter: authoring (64), html (30), figure-table (26), typst (16),
  figure-table-computational (16), projects (10), yaml (6), presentations (4),
  writing (2), websites (2).
- **Filter failure (11 chapters).** `filters: - list-table` fails: q2 looks for
  `./list-table`, not the `pandoc-ext` extension. Every chapter that parses
  then fails on this error, so it may hide other problems.
- q2 also scanned the `.qmd` files in `renv/library/`.
- The summary said output went to `_book`, although I passed
  `--output-dir _book_q2`. Check whether that flag works.

## Migration guidance found

- **Docs built into the binary.** `q2 docs llms <page>`, or `q2 docs serve`.
  - `guides/authoring/migrating-markdown.md`: the main guide. One rule: a
    backslash makes any syntax character literal. Tables of what stops the
    render, what warns, and what changes silently. Shortcodes are expanded
    inside code too; keep them literal with `shortcodes="false"` or
    `{{{< >}}}`.
  - One page per error code, e.g. `errors/markdown/Q-2-3.md`.
  - `errors/extension/Q-16-13.md`: extensions that are now built in.
- **`qmd-syntax-helper`** (`crates/qmd-syntax-helper` in quarto-dev/q2). An
  automatic fixer; not in the releases. Build with
  `cargo build --release --bin qmd-syntax-helper`. Its workflow:
  1. `check -r parse "**/*.qmd"` to see why files fail to parse
  2. `convert -r all --in-place "**/*.qmd"` to fix what it can
  3. `check -r literal-brackets -r reference-links "**/*.qmd"` once files
     parse (`literal-brackets` is opt-in: it rewrites prose)
- **`q2 render --json-errors`** prints one JSON record per error, for counting.
- **quarto-dev/q2#801** proposes making the fixer use Quarto 1's parser and the
  q2 writer. The tooling is still being designed.

## Progress (2026-11-16)

- Steps 1–3 done. Merged `main` (list tables, no `list-table` extension).
  Added `project.render: ["**/*.qmd", "!renv/"]`. Quarto 1 sees the same 26
  inputs as before.
- `qmd-syntax-helper` built from a worktree at `../q2-v0.45.0` (tag
  `v0.45.0`, to match the binary). Reports are in `_q2/`, which is not
  committed: `render.jsonl`, `check-chapters.jsonl`, `check-examples.jsonl`.
- **Second render:** 88 errors in 10 files. Fixing the filter showed new problems:
  - 53 generic parse errors, 29 × Q-2-3, 4 × Q-2-41, 1 × Q-2-32,
    1 × Q-2-55 (class before id: `{.callout-note #nte-render-targets}`).
  - By chapter: authoring (32), html (15), figure-table (13),
    figure-table-computational (8), typst (8), projects (5), yaml (3),
    presentations (2), websites (1), writing (1).
  - The `custom-callout` filter fails: `Callout` is nil in q2 (line 617).
  - `python.qmd`: q2's Jupyter has no `seaborn`. Possibly q2 doesn't
    use the uv environment.
  - Warnings: 19 × Q-2-50 (doubled braces), 20 × Q-2-9 (raw HTML).
- **Check report:** `check -r parse` gives counts only. Use `render.jsonl`
  for line numbers. `tools.qmd` has 23 × `[MCR]` that q2 deletes silently.
  `_examples/`: `list-table-complicated.qmd` fails to parse, `math-sampler`
  has definition lists, and the website examples warn Q-5-37.

## Callouts in q2 (2026-11-16)

From the `v0.45.0` source:

- **Pipeline.** User pre filters see callouts as plain Divs. Then
  `CalloutTransform` (`crates/quarto-core/src/transforms/callout.rs`) turns
  each one into a Rust `CustomNode` of type `Callout`, with `title` and
  `content` slots. Its `plain_data` holds `type`, `appearance`, `collapse` and
  `icon`. `CalloutResolveTransform` (crossref phase) turns it back into
  structured Divs before post filters run.
- **No Lua API.** There is no `quarto.Callout` constructor, and custom nodes
  are not passed to Lua (`crates/pampa/src/lua/types.rs:414`).
- **Fixed types.** Only `note`, `warning`, `tip`, `caution` and `important`
  (`CALLOUT_TYPES`, `callout.rs:55`). `.callout-mytype` stays a plain Div.
- **Braid.** `bd-o90yz5mg` (open, P3) covers walking custom nodes from Lua,
  not building them. No strand for user-defined callout types or a Lua
  callout constructor.
- **Workaround.** A pre filter can emit a built-in callout Div with `title=`,
  `icon=` and `appearance=`, but it can't make a new type. Custom colours
  and icons need a wrapper class and CSS.
- **Done:** removed the `custom-callout` extension and its `_quarto.yml`
  config. It only styled `::: todo`, which now renders as a plain Div. For
  tool callouts later, use a built-in type with `title=`, or file a q2 issue
  for user-defined callout types.

## `_q2.md`

`_q2.md` is for readers and will be committed. It lists only the syntax
that the book teaches and that has no form that works in both Quarto 1 and
q2. It shows the q2 syntax for each case. Author notes stay in this file.
Entries: footnotes with more than one paragraph, and math macros.

## Audit: authoring.qmd (2026-11-16)

Third render, after removing `custom-callout`: still 88 errors. The callout
error is gone. **Side effect:** `q2 render` rewrote Quarto 1's
`_freeze/html/execute-results/html.json` and dropped its `supporting` files.
I reverted it. Check `git status _freeze` after every q2 render.

The 32 errors have three causes. The other errors are cascades.

**Prose (the book's own markup):**

1. **Unquoted attribute values with commas** (5 list-table openers):
   `aligns=l,l,l`. Fix: `aligns="l,l,l"`. Single quotes (`widths='1,2'`)
   are fine.
2. **List items whose first line is empty** (about 30 list-table cells): `- `
   on its own line, then a blank line, then the content. In q2 such an item
   ends at the blank line, so the content that follows fails to parse. A
   nested list right under an empty `- ` fails too. Fix: start the content on
   the marker line (`  - ``` markdown`). The migration guide doesn't mention
   this. CommonMark allows an item to start with one blank line, so q2 is
   stricter than the spec. **Possible q2 issue.**

**Taught syntax:**

3. `***bold italics***` (table at line 109). Use `_**bold italics**_`,
   which works in both.
4. `_examples/authoring/tables/list-table-complicated.qmd` teaches cause 2
   (empty first line in a cell). Fix the example the same way.
5. `_examples/authoring/footnotes/long.md`: a footnote with indented
   continuation paragraphs. q2 rejects it (Q-2-59) and wants a fenced div,
   `::: ^longnote`. Quarto 1 has no syntax for this. Note the difference in
   the text. The example also uses a lazy (unindented) continuation line.
6. `_examples/authoring/math/macros.md`: `\newcommand` lines in the body
   (Pandoc `latex_macros`) don't parse in q2. In q2, `\newcommand` works
   only inside the math expression that uses it (Q-22-1). No syntax shares
   macros across expressions in both. Note the difference in the text.

**Quoting:**

7. ```` ```{{LANGUAGE}} ```` inside a `markdown` block (lines 422, 478): q2
   shows the doubled braces (Q-2-50). Quarto 1 shows `{LANGUAGE}`. Fix:
   single braces. That is safe here because authoring.qmd has no engine.
   **Elsewhere:** 85 more `{{lang}}` cells in 13 chapters, many of them knitr
   or Jupyter chapters. Check that single braces inside an outer fence
   don't execute in Quarto 1 before changing them.

**Status (commit `78ad316`):** fixed 1, 2, 3, 4 and 7. 5 and 6 are in
`_q2.md`. Also changed the taught italics to `_italics_` (authoring.qmd
table, writing.qmd first example and its syntax list), so the pattern
matches `_**bold italics**_`. The book's own prose emphasis stays `*word*`.
authoring.qmd now fails in q2 only on the footnote example (`long.md`),
which is expected. Quarto 1 renders it with no warnings.

**Tested in Quarto 1 for cause 2** (code block on the marker line): loose
rows, code as first/middle/last cell, a blank line in the code, a fence with
attributes, and a four-backtick fence all work. An executable cell in a list
item is broken in both versions with either layout, and the book has none.

**Doubled braces, other chapters:** knitr ran a ```` ```{r} ```` nested
inside a four-backtick fence in Quarto 1. So `{{r}}` cannot become `{r}` in
chapters that run code. Needs a different approach.

**Definition lists:** `::: {.definition-list}` works in Quarto 1.11 and q2.
Use it for `_examples/typst/math-sampler/sampler.qmd`.

## Audit: html.qmd (2026-11-16)

**Committed** to PR #37 (`html`, `af613ea`, pushed) and to `q2-render`
(`674ef24`). html.qmd runs code, so a change needs a new freeze. Charlotte
ran `renv::restore()` in the `html` worktree, rendered, and committed
`ea3ad5a` (freeze and renv.lock) on `html`. Cherry-picked to `q2-render` as
`183d12b`. A full merge of `html` into `q2-render` conflicts in
`_quarto.yml`.

`quarto render html.qmd` re-runs the code even with freeze on, so it always
rewrites the freeze. If only the leaflet widget ID changes, revert it.

The 15 errors are all prose (the book's own markup). None are taught syntax.

- 11 × Q-2-3: `{.markdown filename="x" .code-overflow-wrap}`. Fix: put the
  class first, `{.markdown .code-overflow-wrap filename="x"}`. 17 openers
  changed (some had not been reported because of cascades).
- 1 unquoted `aligns=l,l,l`, and 11 list-table cells with an empty first
  line (authoring causes 1 and 2).
- Fixed with `scripts/q2_fix_html.py`. html.qmd now renders in q2 with no
  errors. Warnings left: 5 × Q-2-50 (doubled braces), 2 × Q-2-9. Quarto 1
  renders it, and the tables keep all their cells.
- **Freeze side effects:** q2 runs knitr, rewrites
  `_freeze/html/execute-results/html.json` (reverted), and writes leaflet
  and htmlwidgets library folders into `_freeze/html/` (untracked).
- **Method correction:** `--json-errors` writes to stderr, not stdout. Use
  `2> _q2/render.jsonl`.

## Audit: figure-table.qmd (2026-11-16)

**Committed** to PR #28 (`figtab-mastering`, `5f161dd`, pushed, from the
worktree `../quarto-tdg-figtab`) and to `q2-render` (`27c90d4`). Preview:
https://mine-cetinkaya-rundel.github.io/quarto-tdg/pr-preview/pr-28/figure-table.html

- **Prose:** one unquoted `aligns=l,l,l` (line 621). The 9 div-closer parse
  errors after it were cascades and went away with this fix.
- **Taught syntax:** `{ IMAGE }`, `{ TABLE }` and `{ CONTENT n }`
  placeholders (27). q2 rejects bare braces (Q-2-41). The text also says an
  unreplaced `{ IMAGE }` is valid markdown, and shows it live. Changed to
  bare words (`IMAGE`), which are valid in both versions, so the claim stays
  true.
- **Quoting:** 11 × `{{LANGUAGE}}` and 11 × `{{r}}`/`{{python}}`. Single
  braces made Quarto 1 pick the Jupyter engine (cells with `#|` options
  inside an outer fence still count). Fix: added `engine: markdown` front
  matter. Then single braces display the same in both, inline and fenced.
  **Use this for other chapters that run no code.** Chapters that run code
  still need another approach.
- Result: q2 reports nothing for this chapter. Quarto 1 renders it, with
  only a cross-chapter crossref warning.
- **Quarto 1 after q2:** a Quarto 1 render right after a q2 render can fail
  with a missing `site_libs/...js`. Rendering again works.
- Taught examples checked with `scripts/q2_extract_examples.py`. The
  included `_examples` tables pass.

## Where changes go

**Commit every fix twice:** on its PR branch, and the same change on
`q2-render`. The final check is a q2 render of the whole book on
`q2-render`, so that branch needs every fix. Identical edits merge without
conflict later. Copy a change with `git diff > patch` and `git apply --3way`.

Which PR branch:

1. **Only one open PR changes the chapter:** that PR's branch.
   - PR #28 `figtab-mastering` (worktree `../quarto-tdg-figtab`): has the
     figure-table and figure-table-computational fixes.
   - PR #37 `html` (worktree `../quarto-tdg-html-wt`, renv restored): has
     the html.qmd fixes and freeze.
   - PR #17 `tools`: quarto, tools.
2. **Otherwise:** `q2-syntax` (worktree `../quarto-tdg-q2-syntax`, based on
   `main`, **not pushed**). It collects the chapters with no open PR, and
   the chapters with small PR edits that merge cleanly with ours (check with
   `git merge-tree`). It becomes one PR **only when Charlotte asks**.

`q2-syntax` has: typst (`d9b1764`), authoring + `_q2.md` + writing
(`5529f89`), projects (`7cfa52e`), yaml (`9828e76`), websites + writing
(`bc72337`).

PR #22 `presentations` (Mine is still working on it): **don't push**. Post
fixes as review suggestions instead.

Open PR files (`gh pr view --json files` lists only 100; use
`gh pr diff N --name-only`): #28 authoring, figure-table,
figure-table-computational, look-under-hood, typst, websites, yaml. #37
authoring, code, html, projects, typst, websites.

**Freezes.** A chapter that runs code needs a new freeze when it changes.
The `q2-syntax` worktree has no renv library. **At the end:** Charlotte runs
`renv::restore()` there and re-renders the chapters that run code
(projects so far), then commits the freezes.

## Audit: figure-table-computational.qmd (2026-11-16)

**Committed** to PR #28 (`00bf80c`, pushed) and to `q2-render` (`6b05d03`).
Preview:
https://mine-cetinkaya-rundel.github.io/quarto-tdg/pr-preview/pr-28/figure-table-computational.html

- **Prose:** 9 × Q-2-3 (`filename=` before `.code-overflow-wrap`). The two
  `:::` parse errors were cascades.
- **Quoting:** 23 × `{{r}}`/`{{python}}`. The only real cells were two
  hidden helpers (`screenshots`, `code-setup`; `eval: false`,
  `include: false`). `engine: markdown` shows such cells in both versions,
  so they are now an HTML comment with the same pointers. Added
  `engine: markdown` and used single braces. Removed the tracked
  `_freeze/figure-table-computational/`, which nothing uses now.
- Line 877, `{{#fig-plot1 ...}}`, is a Python f-string escape. It is
  correct and stays.
- Result: q2 shows no syntax warnings. The warnings left come from
  rendering one file (crossrefs, sidebar Q-13-1/Q-13-7). Quarto 1 renders
  with no warnings.

## Audit: typst.qmd (2026-11-16)

On `q2-syntax` (`d9b1764`) and `q2-render` (`4a1ddcb`). (PR #41 was opened
by mistake and closed.)

- 15 × Q-2-3 openers reordered (8 reported).
- `engine: markdown`, and single braces for `{r}`, `{python}` and the quoted
  raw block `{=typst}`.
- The fenced examples and the 17 included `_examples` files pass in q2.
- On `main`, q2 stops at the custom-callout Lua error before it reports
  warnings. Check warnings on `q2-render`.
- **Todo tags:** `[CVW]`/`[MCR]` (29 in tools, html, websites, typst) give
  Q-2-49, and q2 drops the brackets. Decision: leave them for now.

## Audit: projects.qmd (2026-11-16)

On `q2-render` (`8507102`, with the new freeze) and `q2-syntax` (`7cfa52e`,
**freeze not updated yet**: the worktree has no renv library, and
projects.qmd differs from `q2-render` by one line, so the freeze can't be
copied).

- Q-2-55: `{.callout-note #nte-render-targets}` became
  `{#nte-render-targets .callout-note}`. Line 188 was a cascade.
- 2 × Q-2-3: `{layout-ncol="2" .column-page-right}`, class now first.
- `kbd` shortcode: `linux=win=Shift-Control-B` was a typo, wrong in
  Quarto 1 too. Now `linux=Shift-Control-B`.
- q2 is clean apart from single-file sidebar warnings. Quarto 1 renders
  with no warnings, and the R output in the freeze is unchanged. The 5
  fenced examples pass.

## Audit: yaml.qmd (2026-11-16)

On `q2-syntax` (`9828e76`) and `q2-render` (`63a9439`). PR #28 also changes
yaml.qmd, but the test merge is clean.

- Line 151: `\index{block scalar}` in prose (Q-2-41, plus two cascade
  errors). Now `` `\index{block scalar}`{=latex} ``. Quarto 1 gives the
  same HTML and LaTeX. q2 drops it (q2 has no `latex` format).
  **websites.qmd has 6 more `\index{}`**: same fix.
- 3 × `{{r}}`: `engine: markdown` and single braces.
- Quarto 1 renders with no warnings. No fenced markdown examples.
- **Shell care:** `git stash` in a worktree shares the stash list with
  every worktree. Don't stash to test things; use `git merge-tree`.

## Audit: presentations, websites, writing (2026-11-16)

Fourth render: errors only in these three, plus the expected `long.md`.
Fixed with `scripts/q2_fix_remaining.py`. On `q2-render` (`ff5e75f`).

- presentations: 3 × Q-2-3. No real cells, so `engine: markdown` and single
  braces (8 cells). Removed the stale tracked `_freeze/presentations/`.
- writing: 1 × Q-2-3, 1 × `{{r}}` with `engine: markdown`.
- websites: 6 × `\index{}` with the yaml.qmd fix.
- q2 is clean apart from Q-2-49 (todo tags), Q-2-9 and single-file
  warnings. Quarto 1 renders all three with no warnings.
- websites + writing on `q2-syntax` (`bc72337`). Merges cleanly with #28
  and #37.
- **presentations is only in PR #22** (`presentations`, Mine is still
  working on it). **Don't push to #22.** Instead, posted the fixes as a
  review with 12 suggestions:
  https://github.com/mine-cetinkaya-rundel/quarto-tdg/pull/22#pullrequestreview-5926783662
  (`scripts/q2_pr22_review.py`). The review says to delete the freeze too.
  The worktree `../quarto-tdg-presentations` still has the fix staged and
  uncommitted (the dcg hook blocked discarding it). Remove that worktree.
- **Taught-syntax bug (Quarto 1 too):** presentations.qmd shows
  `#| code-line-numbers="2,4"`. Cell options are YAML:
  `#| code-line-numbers: "2,4"`. Included in the review suggestions.

## Full render and content check (2026-11-16)

Full q2 render on `q2-render` (`ff5e75f`). Errors: `long.md` (expected,
so authoring.qmd has no q2 output) and python.qmd (`seaborn`). No tracked
freeze changes. q2 writes to `_book` (from `_quarto.yml`), so a stale
Quarto 1 page stays there for each chapter that fails, and for the
`part-*` pages, which q2 does not make.

**Content check:** `scripts/q2_compare_books.py Q1_DIR Q2_DIR` compares a
Quarto 1 render with the q2 render: element counts and a word diff of
`<main>`. Copy `_book` before the Quarto 1 render, and render Quarto 1
with `--output-dir` elsewhere. Tables, callouts, code blocks, footnotes and math
match, and so does the text, apart from the items below. Some chapters have
more `<li>` in q2 (look-under-hood 26 → 38); not checked yet. Content that q2 loses:

1. **Cross-chapter crossrefs** (about 45, in 9 chapters) show as
   `?sec-x?`. q2 warns "unresolved crossref" for each. Crossrefs in the
   same chapter work. Probably a q2 gap: check source, possible issue.
2. **Citations and bibliography:** no citeproc. Citations stay as
   `data-cites` spans with the raw key text, and `references.html` is empty.
   **Fixed (uncommitted):** in a q2 book, `bibliography:` alone doesn't
   turn on citeproc (by design, Q-23-1). q2 needs `filters: [citeproc]`
   and `book.references: references.qmd`. Quarto 1 reads `citeproc` in
   `filters:` as a file path (`./citeproc`) and fails, so both settings
   are in `_quarto-q2.yml`. Render with `q2 render --profile q2`; the
   docs-links filter still runs. Side effects: about 700 × Q-23-2 warnings,
   because citeproc sees every `@sec-…` crossref as a citation key.
   Crossrefs don't change. **Still a gap:** a citation inside a footnote
   (r.qmd line 590) stays as `@xie2020`. Possible q2 issue, and a possible
   strand: "in a book, `bibliography:` should turn on citeproc".
3. **Linked figure:** `[![cap](img){#fig-x}](link)` (look-under-hood
   line 482) becomes a plain image. No caption, no Figure 18.9, and
   `@fig-render-process-pdf` is unresolved.
   **Fixed:** the link target (`render-process.pdf`) never existed, so the
   link was broken in Quarto 1 too. Now a plain figure, on `q2-render`
   (`fcd9a3f`) and `q2-syntax` (`f06b93a`). Both versions show the caption
   and resolve the crossref.
   **New gap found:** q2 numbers subfigures (`#fig-plot-html` inside
   `#fig-plot-md`) as top-level figures ("Figure 18.8: Targeting HTML"), not
   (a)/(b). So q2's figure numbers after the first subfigure group differ from
   Quarto 1's (this figure: 18.9 in Quarto 1, 18.11 in q2). Possible q2 issue.
4. **`#|` lines dropped in knitr chapters:** tools.qmd line 111, a
   ```` ```{{r}} ```` block, loses its fence line and `fig-cap`; the plain
   ```` ``` ```` block at line 123 (only `#| fig-cap: !expr ...`) is gone.
   r.qmd line 186, `echo: fenced`, shows ```` ```{{r}} ```` and drops
   `label` and `fig-cap`. Other chapters show all their `#|` lines.
5. **Custom crossref titles:** `crossref: lst-title: Snippet` is ignored;
   q2 says "Listing".
6. index.html has no book title `<h1>`.
8. **Sidebar shows file names** for chapters titled by a `#` heading
   (all but `more.qmd`). Filed quarto-dev/q2#1234 (2026-11-16).
7. **Shortcode in inline code** (authoring.qmd line 1105):
   `` `{{< shortcode-name >}}` `` becomes `?shortcode-name` (Q-16-3).
   Fix, tested in both: `` `{{{< shortcode-name >}}}` ``. Fixed on `q2-render` (`c87a73a`) and `q2-syntax` (`f8c575a`).
   No other chapter has this.

authoring.qmd content: rendered alone with the `long.md` includes commented
out (then restored). It loses only the `long.md` example and items 1, 2
and 7.

## Opened (2026-11-16)

- Issue #42 "Render the book with Quarto 2": status, q2 gaps, open items.
  Draft in `_q2-issue.md`.
- PR #43 from `q2-syntax`. Draft in `_q2-pr-description.md`.
  **Still needs the projects.qmd freeze** (checklist in the PR).
- `q2-render` pushed (`83823b3`): `_quarto-q2.yml`,
  `scripts/q2_render_full.sh`, `scripts/q2_compare_books.py`.
- quarto-dev/q2#1227: draft comment about the appendices + references
  error is in the conversation, not posted.

## Next session

Every chapter has had its audit. `q2-render` has all the fixes.

1. Done: full render and content check (above).
2. Decide what to do with content losses 1–6: fix in the book, or file q2
   issues (check the q2 source first).
3. Check whether Mine accepted the PR #22 suggestions.
4. Remove the leftover worktree:
   `git worktree remove --force ../quarto-tdg-presentations`.
5. The freezes on `q2-syntax` (see "Where changes go"). Ask Charlotte
   before opening its PR.
6. Open items: the doubled-brace cells in chapters that run code (chapters
   that run no code, or only hidden helper cells, use `engine: markdown`);
   todo tags `[CVW]`/`[MCR]` (Q-2-49, left for now); `seaborn` in q2's
   Jupyter; `math-sampler` definition lists; the untracked library folders
   q2 wrote into `_freeze/html/`.
7. Possible q2 issue: list items whose first line is empty (cause 2).

**Fix patterns that work in both versions:**

- Class after `key=value` (Q-2-3) or before an id (Q-2-55): order the
  attributes as id, classes, then key=value.
- Unquoted values with commas: quote them (`aligns="l,l,l"`).
- An empty list item before a code block: start the fence on the `- ` line.
- `{{r}}` and similar in a chapter that runs no code: add
  `engine: markdown`, then use single braces. Without the engine, Quarto 1
  runs the quoted cells.
- Bare `{ X }` placeholders: use bare words.
- `\index{x}` in prose: `` `\index{x}`{=latex} ``.

## Method

- **Render:** `q2 render --profile q2 --to html --json-errors 2> _q2/render.jsonl`. Parse
  failures are records without `kind`; their `error` field holds all the
  errors for a file as text. In plain-text output, a file's first error
  follows `warning: profile-pass skipped`, so `grep '^Error'` misses it.
  Then `git status _freeze` and revert any
  changes. q2 writes to Quarto 1's freeze.
- **Fixer:** `../q2-v0.45.0/target/release/qmd-syntax-helper check -r all
  --json *.qmd`. `check` gives counts only, not lines.
- **Taught examples:** extract the fenced `markdown`/`qmd` blocks and render
  each one with q2 outside the project. Skip the blocks that only hold an
  `include` shortcode, and parse the included `_examples` files on their own.
  A test file inside the project is excluded by the render list, so test in
  the scratchpad.
- **Both versions:** for each proposed fix, render a small file with both
  `quarto` and `q2` and compare the HTML, not only the exit code.
- **Shell hook (dcg):** it blocks `rm -r`, redirects to `$VAR` paths,
  heredocs that start a shell, and `cp` from a variable. Write scripts to
  files with the Write tool and use literal paths.

## Plan

1. **Separate PR (Charlotte):** remove the `pandoc-ext/list-table` extension
   (list tables are built in to Quarto 1.11 and q2) and convert all grid tables
   to list tables.
2. Exclude `renv/` from the render.
3. Build `qmd-syntax-helper`. Run `check` only, and save the report. Don't run
   `convert` yet, because it would hide the findings for goal 2.
4. **Audit the syntax the book teaches.** Sort each error into one of these:
   - **Prose:** an error in the book's own text (e.g. an unescaped `_` or
     `{}`). Fix it, with the fixer or by hand.
   - **Taught syntax:** an example shows syntax that q2 rejects (e.g.
     `***bold italics***`, a class after `key=value`, an indented code
     block). Change the lesson to syntax that works in both Quarto 1 and q2.
     If no such syntax exists, note the difference in the text.
   - **Quoting:** the example is valid, but quoting it in the book breaks it
     (e.g. a shortcode inside a code block, which q2 expands). Fix how it is
     quoted.

   Also check examples that q2 never sees as markdown: the `_examples/`
   files, and the code in fenced `markdown`/`qmd` blocks. Render or parse
   them with q2 separately, because an error-free chapter doesn't prove its
   examples are valid.

   Keep a list of the taught-syntax findings. It is useful content for the
   book, and possibly input for issues on quarto-dev/q2.
5. Run `convert -r all` on the prose findings only. Re-render with q2 and fix
   the rest by hand.
6. Confirm the book still renders with Quarto 1 after each step.
