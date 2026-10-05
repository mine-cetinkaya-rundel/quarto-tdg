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
{{< include _examples/html/first-document/report.qmd >}}
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
  ```

- Do not commit rendered output (`*.html`, `*_files/`).
  Commit only the source files and any data or assets that the source files need.

## Screenshots

Put screenshots in `images/` in the project root with the name `html-{section-slug}-{example}.png` (for example `html-first-document-report.png`).
Give every figure an ID that matches (`#fig-html-first-document-report`), the `.border` class, and `fig-alt` text.

TODO: decide how to capture HTML screenshots (headless browser, viewport width, light/dark mode) and record each image in `screenshots.yml`, as the Typst examples do.
