# Render the book with Quarto 2

This issue records the status of a q2 render of the book (q2 v0.45.0, Quarto 1.11.9, 2026-11-16). It is for two readers: us, when we render the book with q2 for real, and the q2 developers, as a list of what blocks a real book.

## Status

The book's markdown is valid in q2 (#43, #37, #28, and the review on #22). The `q2-render` branch merges all those fixes.

A full q2 render of that branch writes every chapter. It has one error, and the page is correct in spite of it (see gap 9). For this render:

- The `long.md` example is left out. `_examples/authoring/footnotes/long.md` teaches a multi-paragraph footnote with indented paragraphs. q2 rejects it (Q-2-59). This is intended. `_q2.md` gives the q2 syntax.
- The uv environment is active. Without it, q2's Jupyter doesn't find `seaborn`, and python.qmd fails.

## How to render with q2

```bash
zsh scripts/q2_render_full.sh
```

The script:

1. Comments out the `long.md` includes in authoring.qmd.
2. Activates `.venv`.
3. Runs `q2 render --profile q2 --to html --json-errors 2> _q2/render.jsonl`.
4. Restores authoring.qmd and shows changed files.

Notes:

- `_quarto-q2.yml` (the `q2` profile) holds the settings that only q2 needs. See gap 2.
- `--json-errors` writes to stderr. A file that fails to parse gives a record with no `kind`, and its `error` field holds all the errors as text.
- **q2 writes to Quarto 1's freeze.** It rewrote `_freeze/html/execute-results/html.json` and added untracked library folders to `_freeze/html/`. Revert the freeze after each q2 render.
- q2 writes to `_book`. It ignores `--output-dir` when `_quarto.yml` sets one.
- q2 doesn't make the `part-*.html` pages. Old Quarto 1 pages stay in `_book`.

## Content that q2 loses

A render with no errors can still lose content. `scripts/q2_compare_books.py` compares a Quarto 1 render with a q2 render, chapter by chapter: element counts, and the words of `<main>`. Tables, callouts, code blocks, footnotes and math match. The differences are below.

### q2 gaps (possible q2 issues)

1. **Cross-chapter crossrefs don't resolve.** 33 different targets show as `?sec-x?`, or as `(sec-x?)` when citeproc runs. Crossrefs within a chapter work. The q2 book guide says that crossrefs resolve across chapters.
2. **Citations need extra configuration, and some still fail.** In a book, `bibliography:` alone doesn't turn on citeproc (Q-23-1). q2 also needs `filters: [citeproc]` and `book.references: references.qmd`. Quarto 1 reads `citeproc` in `filters:` as a file path and stops, so both settings are in `_quarto-q2.yml`. With them:
   - Citations in body text resolve, and `references.html` has the full bibliography.
   - A citation inside a footnote (`r.qmd`, footnote `[^r-1]`) stays as `@xie2020`.
   - Quarto 1 adds a reference list at the end of each chapter that cites something (authoring, r). q2 doesn't.
   - citeproc gives 393 × Q-23-2 warnings. It sees each `@sec-…` crossref as a citation key. The resolved crossrefs are correct.
3. **Subfigures get top-level numbers.** In look-under-hood, `#fig-plot-html` and `#fig-plot-pdf` inside `#fig-plot-md` become Figures 18.8 and 18.9, not 18.8 (a) and (b). All later figure numbers in the chapter differ from Quarto 1.
4. **`#|` lines disappear in knitr chapters.**
   - tools.qmd: a ```` ```{{r}} ```` block loses its fence line and its `#| fig-cap` line. A plain ```` ``` ```` block that holds only `#| fig-cap: !expr ...` disappears.
   - r.qmd: a cell with `echo: fenced` shows ```` ```{{r}} ```` and loses `label` and `fig-cap`.
   - Chapters with `engine: markdown` show all their `#|` lines.
5. **Custom crossref titles are ignored.** `crossref: lst-title: Snippet` gives "Listing".
6. **The home page has no book title** `<h1>`.
7. **Jupyter shows the value of the last expression.** In python.qmd, q2 shows `<seaborn.axisgrid.FacetGrid at 0x…>` under the plot. Quarto 1 doesn't.
8. **A linked figure loses its caption.** `[![cap](img){#fig-x}](link)` becomes a plain image, with no caption or number. The book no longer uses this syntax.
9. **references.qmd gives an error but renders.** "Project-scoped artifact merge failed … artifact key 'search-page/references.html' has conflicting content". The error occurs when `references.qmd` is `book.references` and is also in `book.appendices`, with citeproc on. q2 seems to render the page twice, once with the bibliography and once without. The page and `search.json` are correct, but the render exits with an error. Related: quarto-dev/q2#1227.
   - Quarto 1 needs `references.qmd` in `book.appendices`, so the file stays there.
   - `appendices: !prefer [jupyter.qmd]` in `_quarto-q2.yml` removes the error, but it breaks projects.qmd. q2 sets `QUARTO_PROFILE=q2` for code cells. The cell that runs `quarto create` then starts Quarto 1, which reads `_quarto-q2.yml` and stops on the unknown `!prefer` tag. So we accept the error for now.
10. **A list item with an empty first line ends at the next blank line.** CommonMark lets an item start with one blank line. The book now avoids this, but q2 is stricter than the spec.

### Not checked yet

- Some chapters have more `<li>` elements in q2 than in Quarto 1 (look-under-hood 26 → 38), but the same text.

## Book-side open items

- **Doubled braces in chapters that run code.** q2 shows ```` ```{{r}} ```` with the doubled braces (Q-2-50, 25 warnings). In chapters that run no code, `engine: markdown` and single braces work in both versions. In chapters that run code, Quarto 1 runs a ```` ```{r} ```` cell even inside an outer fence, so this needs another fix.
- **Bracketed text with no attributes.** `[CVW]`, `[MCR]` and four presentations headings such as `[Slide backgrounds]` give Q-2-49, and q2 drops the brackets. Left for now.
- **Raw HTML.** 44 × Q-2-9 (an HTML element converted to raw HTML). Not reviewed.
- **Custom callouts.** q2 has no Lua API to make a callout, and supports only the five built-in types. The `custom-callout` extension (from #37) fails in q2.
- **`math-sampler` definition lists.** `_examples/typst/math-sampler/sampler.qmd` uses definition lists. `::: {.definition-list}` works in Quarto 1.11 and q2.

## Tools

- **q2 docs:** `q2 docs llms guides/authoring/migrating-markdown` is the migration guide. Each error code has a page, for example `q2 docs llms errors/markdown/Q-2-3`.
- **`qmd-syntax-helper`:** an automatic fixer in quarto-dev/q2 (`crates/qmd-syntax-helper`). It isn't in the releases. Build it from the tag that matches your q2 binary. `check` gives counts per file, not line numbers.
