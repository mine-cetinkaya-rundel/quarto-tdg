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

Screenshots render at 200 DPI by default. Override with the `DENSITY` env var for sharper output (e.g. text-heavy examples where 200 looks grainy):

```bash
DENSITY=300 bash _examples/typst/screenshot-examples.sh _examples/typst/fonts-colors/system-font.qmd
```

The density used is recorded per image in `screenshots.yml`, so mixed densities across the set are fine.

### Full-page and framed screenshots

By default the screenshot is trimmed to the content. Two markers in the example's frontmatter change that:

- `# screenshot: full-page` — keep the whole page so margins / geometry stay visible.
- `# screenshot: framed` — full-page **and** add a thin dark page outline plus a pale grey outer matte, so the result reads as a framed "page on a backdrop" rather than a floating screenshot. Used for layout illustrations that sit alongside the annotated diagrams.

Example:

```yaml
---
# screenshot: framed
format:
  typst: ...
---
```

`screenshot-examples.sh` greps for these markers and adjusts the magick post-processing accordingly.

### Multi-page screenshots

The script captures page 1 only. For multi-page captures, render the example manually and pull out each page:

```bash
magick -density 200 "example.pdf[0]" -background white -flatten images/typst-section-example-p1.png
magick -density 200 "example.pdf[1]" -background white -flatten images/typst-section-example-p2.png
```

Then add manifest entries with a `page:` field for each.

### Files excluded from auto-discovery

Files with an underscore prefix (`_anatomy.qmd`, `_marginalia.qmd`, …) are skipped by `screenshot-examples.sh`'s sweep. Use this for sources that have a custom build pipeline (see Diagrams below) — they still render via `quarto render` when their build script runs, they just don't get auto-screenshotted.

## Diagrams (`build-*.sh`)

A few `images/` entries are annotated SVG diagrams rather than plain screenshots: they render an example to a page, rasterise it, then overlay vector labels. These are built by dedicated scripts, not the screenshot sweep:

- `page-layout/build-anatomy.sh` → `typst-page-layout-anatomy.svg` — the `margin`/`grid` page anatomy.
- `page-layout/build-marginalia.sh` → `typst-page-layout-marginalia.svg` — the marginalia `inner`/`outer` `far`/`width`/`separation` geometry.

Run the script to regenerate, e.g.:

```bash
bash _examples/typst/page-layout/build-marginalia.sh
```

Their `screenshots.yml` entries carry a `builder:` field naming the script.

Build scripts follow a common shape:

1. `quarto render` the source `.qmd` to PDF (sources are underscore-prefixed so the sweep ignores them).
2. `magick -density 200` rasterise page 1 to PNG.
3. `base64 -i` encode the PNG.
4. Write an SVG that embeds the PNG as a `data:image/png;base64,…` URI and overlays vector annotations (text, lines, brackets, arrow markers).
5. Delete the temp PNG.

When iterating on diagram SVGs, preview with **librsvg** rather than ImageMagick — `magick` drops thin strokes and arrow markers when rasterising SVG:

```bash
rsvg-convert -w 1200 images/typst-page-layout-anatomy.svg -o /tmp/preview.png
```

## screenshots.yml

`screenshots.yml` records how each image in `images/` was generated:

```yaml
- image: typst-navigation-train-punctuality.png
  source: _examples/typst/navigation/train-punctuality.qmd
  density: 200
  generated: 2026-03-31T18:58:51Z
```

It is updated automatically by `screenshot-examples.sh` each time a screenshot is (re)generated.
