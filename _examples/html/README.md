# HTML examples

Each subdirectory holds the examples for one section of the HTML chapter (`html.qmd`).

## One source per example

An example shown in the book has exactly one source file.
That file lives in `_examples/html/{section-slug}/`.
The slug is the section ID without the `sec-html-` prefix.
For example, `{#sec-html-first-document}` maps to `_examples/html/first-document/`.

Do not copy example code into `html.qmd`.
Include the source with the `include` shortcode, inside a four-backtick block so that the example can contain its own code fences:

`````markdown
````{.markdown filename="report.qmd" .code-overflow-wrap}
{{< include _examples/html/first-document/train-punctuality.qmd >}}
````
`````

The screenshot of the rendered output comes from the same file.
So the code the reader sees is always the code that made the screenshot.

## Keep examples minimal

- Show only the YAML that the example needs.
  Put shared or incidental options (for example `format: html`, `theme`, or options that make the screenshot tidy) in a `_quarto.yml` in the section directory.
  Quarto uses `_quarto.yml` when it renders the example, but the reader does not see it.
- Omit the YAML header completely when the example is only about body content.
- Keep content short.
  Use enough text to show the feature, not a full document.
- Give the `filename` attribute a realistic name for the reader (`report.qmd`, `_quarto.yml`, `styles.css`), not the name of the source file.
  The source file name describes the example (`margin.qmd`, `callout-collapse.qmd`).

## Fragments

Sometimes the book shows only part of a file, for example a YAML snippet, a CSS rule, or a body excerpt.
Start the names of these files with an underscore (`_toc-options.yml`, `_dark-mode.scss`).
The underscore tells the screenshot tooling to skip the file.
If a fragment also needs a rendered screenshot, keep a separate complete file and make a note of it in `screenshots.yml`.

### Header-only fragments

When the book shows only the YAML header of an example, put the header (with its `---` delimiters) in `_{example}.yml`.
The complete file `{example}.qmd` starts with `{{< include _{example}.yml >}}`, followed by the body.
Then the header has one source, and the screenshot always matches the code in the book.
Examples: `themes/_flatly.yml` and `css/_report.yml`.

This does not work for `brand`.
Quarto reads `brand` before it expands shortcodes, so a `brand` option from an included header (or from `metadata-files`) has no effect.
For `brand/colors.qmd` and `brand/fonts.qmd`, the complete file has the header inline, and `_colors.yml` and `_fonts.yml` are copies of it.
If you change one of these headers, make the same change in both files.
Do not put comments in the `_*.yml` copies, because the book shows them.

## Subject matter

Use the same subject as the Typst chapter where possible: transit punctuality data (routes such as Harbour–Airport, West Loop, University Line).
Readers then recognize the content and can focus on the feature.

## Section directories

- Each directory is a self-contained Quarto project.
  It renders with `quarto render` from inside that directory.
- Each directory has a `.gitignore` that contains:

  ```
  /.quarto/
  **/*.quarto_ipynb
  *.html
  *_files/
  ```

- Do not commit rendered output (`*.html`, `*_files/`).
  Commit only the source files and any data or assets that the source files need.

## Screenshots

Put screenshots in `images/` in the project root with the name `html-{section-slug}-{example}.png` (for example `html-first-document-train-punctuality.png`).
Give every figure an ID that matches (`#fig-html-first-document-train-punctuality`), the `.border` class, and `fig-alt` text.

### Taking screenshots

`screenshot-examples.R` renders an example and captures it with headless Chrome (chromote).
The page loads from a temporary local HTTP server (`python3 -m http.server`), not from `file://`.
Chrome does not run Quarto's `quarto.js` (an ES module) from `file://`, so page behaviour such as the collapsed table of contents is missing there.
It records every image in `screenshots.yml`, as the Typst examples do.
Run it from the project root:

```r
source("_examples/html/screenshot-examples.R")

# Render one example, take the screenshot, and update screenshots.yml
shoot("_examples/html/first-document/train-punctuality.qmd", selector = "main", expand = 16)

# Regenerate every image in screenshots.yml
rebuild()
```

From the shell: `Rscript _examples/html/screenshot-examples.R --manifest`.

`shoot()` options (the manifest records only the values that are not the default):

| Option      | Default | Effect                                                                 |
|-------------|---------|------------------------------------------------------------------------|
| `selector`  | none    | Trim to the bounding box of a CSS selector (`main`, `#fig-x`, `.callout`). With no selector, capture the viewport. |
| `expand`    | 0       | Padding in CSS px around the selected element.                         |
| `width`     | 1200    | Viewport width in CSS px. This controls the layout and the text size in the book. |
| `height`    | 800     | Viewport height in CSS px.                                             |
| `full-page` | false   | Capture the full page height, not only the viewport.                   |
| `scale`     | 2       | Pixel density. This does not change the layout.                        |
| `profile`   | none    | Quarto profile. The image name gets a `-{profile}` suffix.             |
| `name`      | file name | Changes the `{example}` part of the image name.                      |
| `click`     | none    | CSS selector of an element to click before the capture, for example to open a menu (`#quarto-code-tools-menu`). |
| `hover`     | none    | CSS selector of an element to move the mouse over before the capture, for example to show a copy button (`.code-copy-outer-scaffold`). |
| `color-scheme` | `light` | Set to `dark` to switch Quarto's light/dark toggle before the capture. The image name gets a `-dark` suffix. The example needs both a light and a dark theme. |

Selectors match only visible elements, so a selector such as `.cell-output-display` picks the rendering that is shown in the current color scheme.

Use `name` to take more than one screenshot of the same source.

### Text size

The book shrinks each image to the width of its column.
A wide viewport therefore gives small text.
Quarto limits the width of the body text, so extra viewport width only adds empty margin.
Trim to an element where you can.
To compare widths, use `compare_widths(source, widths = c(800, 1000, 1200))`.
It writes to a temporary directory and does not change the manifest.

TODO: choose a default `width` after comparing widths in the rendered book.
