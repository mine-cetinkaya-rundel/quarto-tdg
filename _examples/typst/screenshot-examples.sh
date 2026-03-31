#!/bin/bash
# Render .qmd examples and screenshot the first page to ../../images/
# Run from _examples/typst/ or from the project root.
# Usage: ./_examples/typst/screenshot-examples.sh [path/to/example.qmd ...]
#   With no arguments, processes all .qmd files in subdirectories of _examples/typst/

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)
CHAPTER=$(basename "$SCRIPT_DIR")
DENSITY=200
OUT_DIR="$ROOT_DIR/images"
mkdir -p "$OUT_DIR"

MANIFEST="$SCRIPT_DIR/screenshots.yml"

files=("$@")
if [ ${#files[@]} -eq 0 ]; then
  while IFS= read -r f; do
    files+=("$f")
  done < <(find "$SCRIPT_DIR" -mindepth 2 -maxdepth 2 -name "*.qmd" ! -name "_*" | sort)
fi

for qmd in "${files[@]}"; do
  qmd=$(cd "$(dirname "$qmd")" && pwd)/$(basename "$qmd")
  name=$(basename "$qmd" .qmd)
  dir=$(dirname "$qmd")
  section=$(basename "$dir")
  pdf="$dir/$name.pdf"
  image="$CHAPTER-$section-$name.png"
  out="$OUT_DIR/$image"
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  echo "Rendering $qmd..."
  (cd "$dir" && quarto render "$(basename "$qmd")")

  echo "Screenshotting $pdf..."
  magick -density "$DENSITY" "$pdf"[0] -background white -flatten \
    -trim +repage -bordercolor white -border 40 "$out"

  echo "Saved $out"

  rel_source="${qmd#$ROOT_DIR/}"

  # Remove existing entry for this image from manifest, then append updated one
  if [ -f "$MANIFEST" ]; then
    awk "/^- image: ${image//./\\.}$/{found=1} found && /^$/{found=0; next} !found" \
      "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"
  fi

  cat >> "$MANIFEST" <<EOF
- image: $image
  source: $rel_source
  density: $DENSITY
  generated: $timestamp
EOF

done
