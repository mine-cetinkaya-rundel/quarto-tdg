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
DENSITY=${DENSITY:-200}
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
  # Trim to content by default. Examples that need the page margins visible
  # (e.g. page-geometry demos) opt out with a "screenshot: full-page" marker
  # in the .qmd, which keeps the whole page. "screenshot: framed" goes further:
  # keeps the whole page AND adds a solid page outline + pale grey outer
  # padding to match the anatomy-diagram treatment.
  trim="-trim +repage"
  framed=0
  if grep -q "screenshot: framed" "$qmd"; then
    trim=""
    framed=1
  elif grep -q "screenshot: full-page" "$qmd"; then
    trim=""
  fi
  magick -density "$DENSITY" "$out_pdf"[0] -background white -flatten \
    $trim "$out"
  if [ "$framed" -eq 1 ]; then
    # Side padding is wider than top/bottom to match the anatomy diagram's
    # canvas proportions (viewBox shape).
    magick "$out" -bordercolor "#444" -border 6 \
      -bordercolor "#ececec" -border 350x100 "$out"
  else
    # Sample top-right pixel so the border matches the document's edge color
    # (colored body bgs fake their own padding; white-bg docs still get a white border).
    pad_color=$(magick "$out" -format "%[pixel:p{%[fx:w-1],0}]" info:)
    magick "$out" -bordercolor "$pad_color" -border 40 "$out"
  fi

  echo "Saved $out"

  rel_source="${qmd#$ROOT_DIR/}"

  # Remove existing entry for this image from manifest, then append updated one.
  # Skip the matching `- image:` line plus its indented fields until the next
  # `- image:` line (which is kept). Manifest entries are contiguous (no blank
  # separators), so terminating on the next entry is the only safe boundary.
  if [ -f "$MANIFEST" ]; then
    awk "/^- image: ${image//./\\.}$/{found=1; next} found && /^- image:/{found=0} !found" \
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
