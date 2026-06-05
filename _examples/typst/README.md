# Typst examples

Each subdirectory is a self-contained example used in the Typst chapter. Subdirectory names correspond to chapter sections (e.g., `navigation/`).

## Generating screenshots

`screenshot-examples.sh` requires [ImageMagick](https://imagemagick.org) v7+ (`magick` must be on your PATH). Install with Homebrew if needed:

```bash
brew install imagemagick
```

Run `screenshot-examples.sh` to render all examples and save a PNG of the first page to `images/` in the project root:

```bash
# All examples
bash _examples/typst/screenshot-examples.sh

# A specific example
bash _examples/typst/screenshot-examples.sh _examples/typst/navigation/train-punctuality.qmd
```

Screenshots are named `typst-{section}-{example}.png` (e.g., `typst-navigation-train-punctuality.png`).

### Full-page screenshots

By default the screenshot is trimmed to the content. To keep the whole page — e.g. to show page margins or geometry — add a marker comment to the example's frontmatter:

```yaml
---
# screenshot: full-page
format:
  typst: ...
---
```

`screenshot-examples.sh` greps for `screenshot: full-page` and skips the trim for that example (see `page-layout/margin-geometry.qmd`).

## Diagrams (`build-*.sh`)

A few `images/` entries are annotated SVG diagrams rather than plain screenshots: they render an example to a page, rasterise it, then overlay vector labels. These are built by dedicated scripts, not the screenshot sweep:

- `page-layout/build-anatomy.sh` → `typst-page-layout-anatomy.svg` — the `margin`/`grid` page anatomy.
- `page-layout/build-marginalia.sh` → `typst-page-layout-marginalia.svg` — the marginalia `inner`/`outer` `far`/`width`/`separation` geometry.

Run the script to regenerate, e.g.:

```bash
bash _examples/typst/page-layout/build-marginalia.sh
```

Their `screenshots.yml` entries carry a `builder:` field naming the script.

## screenshots.yml

`screenshots.yml` records how each image in `images/` was generated:

```yaml
- image: typst-navigation-train-punctuality.png
  source: _examples/typst/navigation/train-punctuality.qmd
  density: 200
  generated: 2026-03-31T18:58:51Z
```

It is updated automatically by `screenshot-examples.sh` each time a screenshot is (re)generated.
