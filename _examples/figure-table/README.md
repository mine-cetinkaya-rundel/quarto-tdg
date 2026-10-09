# Figure and table examples

The examples in this directory are used in two chapters: `figure-table.qmd` and `figure-table-computational.qmd`.
Subdirectory names correspond to chapter topics (for example `captions/`, `position/`).
`_code-snippets/` holds the R and Python code that the chapters and the examples include with `{{< include >}}`.

## Screenshots

`generate-screenshots.R` renders the examples to `html` and captures parts of them with headless Chrome (`htmlshot()` in `R/htmlshot.R`).
Run it from the project root in an R session, so that the project's renv library is used:

```r
source("_examples/figure-table/generate-screenshots.R")
```

The script regenerates every image in its list and overwrites the files in `images/`.
Review the changes with `git diff` before you commit them.

Do not render the examples with `quarto render` from the shell inside this directory.
That uses your global R library, not renv, and fails if packages such as `palmerpenguins` are missing.
The script uses `quarto::quarto_render()` for this reason.

### Add a screenshot

1. In the example document, wrap the part to capture in a fenced div with an ID, for example `::: {#sub-references}`.
   Do not use a `fig-` or `tbl-` prefix for this ID, because Quarto would make it a cross-reference.
2. Add a row to the `screenshots` table in `generate-screenshots.R`: the `file` (relative to this directory) and the `id`.
3. Run the script.
   The image is `images/figure-table-{id}.png`.
4. In the chapter, give the figure the `.border` class (usually with `.p-3`) and `fig-alt` text.

By default the selector is `#id`, with no padding.
To capture a different element or to add padding, add a row to the `overrides` table.
`expand` is in CSS pixels, in the order top, right, bottom, left.
For example, `column-screen` captures only the figure cell and 70 px of text above and below it.

All screenshots use `width = 992` and `scale = 1`, to match the existing images.
If you change these values, regenerate all of the images, so that the text size is the same in all of them.

The script deletes the `*.html.md` files that the render makes (several examples set `keep-md: true`).
`*.html`, `*_files/`, and `*.html.md` are in `.gitignore`.

### Images from other sources

Not every `images/figure-table-*` file comes from `generate-screenshots.R`:

- `figure-table-panel-*.svg`: diagrams made by `layout/build-panel-diagrams.R`.
  Run `Rscript _examples/figure-table/layout/build-panel-diagrams.R` from the project root.
- `figure-table-caption-format.jpeg`, `figure-table-cross-reference-form.jpeg`, `figure-table-caption-format-edit.png`: made by hand.
  They have no source document.

## Files that are not used for screenshots

- The `python.qmd` files are Python versions of the R examples.
  They are kept for reference; the screenshots use the R versions.
- `code-examples/` shows the R and Python versions of each figure side by side (`side-by-side.qmd`, with `{{< embed >}}`).
  It is for reference only.
