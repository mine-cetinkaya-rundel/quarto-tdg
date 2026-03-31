#!/bin/bash
# Render .qmd examples and screenshot the first page to ../../images/
# Run from _examples/typst/ or from the project root.
# Usage: ./_examples/typst/screenshot-examples.sh [path/to/example.qmd[:profile] ...]
#   With no arguments, processes all .qmd files in subdirectories of _examples/typst/
#   Append :profile to use a Quarto profile, e.g. path/to/theorem.qmd:fancy

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

for entry in "${files[@]}"; do
  # Split on : to extract optional profile
  qmd_rel="${entry%%:*}"
  profile="${entry#*:}"
  [ "$profile" = "$entry" ] && profile=""

  qmd=$(cd "$(dirname "$qmd_rel")" && pwd)/$(basename "$qmd_rel")
  name=$(basename "$qmd" .qmd)
  dir=$(dirname "$qmd")
  section=$(basename "$dir")
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Image name includes profile suffix if present
  if [ -n "$profile" ]; then
    image="$CHAPTER-$section-$name-$profile.png"
    out_pdf="$dir/$name-$profile.pdf"
    render_args="--profile $profile --output $name-$profile.pdf"
  else
    image="$CHAPTER-$section-$name.png"
    out_pdf="$dir/$name.pdf"
    render_args=""
  fi

  out="$OUT_DIR/$image"

  echo "Rendering $qmd${profile:+ (profile: $profile)}..."
  (cd "$dir" && quarto render "$(basename "$qmd")" $render_args)

  echo "Screenshotting $out_pdf..."
  magick -density "$DENSITY" "$out_pdf"[0] -background white -flatten \
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
  source: $rel_source${profile:+
  profile: $profile}
  density: $DENSITY
  generated: $timestamp
EOF

done
