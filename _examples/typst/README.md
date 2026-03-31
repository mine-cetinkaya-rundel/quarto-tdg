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

## screenshots.yml

`screenshots.yml` records how each image in `images/` was generated:

```yaml
- image: typst-navigation-train-punctuality.png
  source: _examples/typst/navigation/train-punctuality.qmd
  density: 200
  generated: 2026-03-31T18:58:51Z
```

It is updated automatically by `screenshot-examples.sh` each time a screenshot is (re)generated.
