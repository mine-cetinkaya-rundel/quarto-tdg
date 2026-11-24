#!/bin/bash
# Render .qmd revealjs presentations and screenshot each slide to ../../images/.
#
# Two modes:
#   1. Authoring (default): pass .qmd paths (optionally :profile), or no args to
#      process every example. Derives the image name and records the result in
#      screenshots.yml.
#        ./screenshot-examples.sh [path/to/example.qmd[:profile] ...]
#
#   2. Manifest rebuild: regenerate every image recorded in screenshots.yml,
#      honoring each entry's profile, page, density, and builder. This is the
#      reproducible "rebuild all" used to verify the chapter images.
#        ./screenshot-examples.sh --manifest
#
# Run from _examples/presentations/ or from the project root.
#
# Requirements: Node.js and Playwright (npm install playwright)

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)
CHAPTER=$(basename "$SCRIPT_DIR")
WIDTH=${WIDTH:-1920}
HEIGHT=${HEIGHT:-1080}
OUT_DIR="$ROOT_DIR/images"
MANIFEST="$SCRIPT_DIR/screenshots.yml"
SCREENSHOT_SCRIPT="$SCRIPT_DIR/screenshot-slides.mjs"
mkdir -p "$OUT_DIR"

# Check for Playwright
check_playwright() {
  if ! node -e "require('playwright')" 2>/dev/null; then
    echo "Error: Playwright not found. Install with: npm install playwright"
    echo "Then run: npx playwright install chromium"
    exit 1
  fi
}

# Render one qmd to revealjs HTML and screenshot all slides.
# Args: <qmd-abs> <image-prefix> <profile> <width> <height>
# Outputs: <image-prefix>-slide-1.png, <image-prefix>-slide-2.png, etc.
render_and_shoot_html() {
  local qmd="$1" image_prefix="$2" profile="$3" width="${4:-$WIDTH}" height="${5:-$HEIGHT}"
  local name dir out_html
  local -a render_args

  name=$(basename "$qmd" .qmd)
  dir=$(dirname "$qmd")

  if [ -n "$profile" ]; then
    out_html="$dir/$name-$profile.html"
    render_args=(--profile "$profile" --output "$name-$profile.html")
  else
    out_html="$dir/$name.html"
    render_args=(--output "$name.html")
  fi

  echo "Rendering $(basename "$qmd")${profile:+ [profile: $profile]} -> HTML presentation"
  (cd "$dir" && quarto render "$(basename "$qmd")" --to revealjs "${render_args[@]}") || return 1

  echo "Screenshotting slides (${width}x${height})"
  node "$SCREENSHOT_SCRIPT" "$out_html" "$OUT_DIR/$image_prefix" "$width" "$height" || return 1

  # Add border/padding to each slide image
  for img in "$OUT_DIR/$image_prefix"-slide-*.png; do
    [ -f "$img" ] || continue
    local pad_color
    pad_color=$(magick "$img" -format "%[pixel:p{%[fx:w-1],0}]" info:)
    magick "$img" -bordercolor "$pad_color" -border 40 "$img"
  done

  echo "Saved slides to $OUT_DIR/$image_prefix-slide-*.png"
}

# Remove image's existing manifest entries (all slides), then append fresh ones.
# Args: <image-prefix> <source-rel> <profile> <width> <height>
update_manifest_html() {
  local image_prefix="$1" source="$2" profile="$3" width="$4" height="$5" timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Remove existing entries for this prefix
  if [ -f "$MANIFEST" ]; then
    awk "/^- image: ${image_prefix//./\\.}-slide-[0-9]+\\.png\$/{found=1; next} found && /^- image:/{found=0} !found" \
      "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"
  fi

  # Add entries for each slide image that was created
  for img in "$OUT_DIR/$image_prefix"-slide-*.png; do
    [ -f "$img" ] || continue
    local img_name slide_num
    img_name=$(basename "$img")
    slide_num=${img_name##*-slide-}
    slide_num=${slide_num%.png}
    cat >> "$MANIFEST" <<EOF
- image: $img_name
  source: $source${profile:+
  profile: $profile}
  slide: $slide_num
  width: $width
  height: $height
  generated: $timestamp
EOF
  done
}

# ---- Manifest rebuild mode -------------------------------------------------
# Regenerate everything recorded in the manifest. Continues past failures and
# prints a summary so a single run reveals exactly what is (not) reproducible.
if [ "${1:-}" = "--manifest" ]; then
  check_playwright
  echo "Rebuilding all images from $MANIFEST"
  ok=(); failed=(); skipped=()
  processed_prefixes=()
  set +e

  while IFS=$'\x1f' read -r image source profile slide width height builder asset; do
    [ -z "$image" ] && continue

    if [ -n "$builder" ]; then
      echo "Building $image via $builder"
      if bash "$ROOT_DIR/$builder"; then ok+=("$image"); else failed+=("$image"); fi
      continue
    fi

    if [ "$asset" = "true" ]; then
      echo "Skipping $image (hand-authored source asset)"
      skipped+=("$image")
      continue
    fi

    # Extract prefix from image name (remove -slide-N.png)
    local prefix="${image%-slide-*.png}"

    # Skip if we've already processed this presentation
    local already_done=false
    for p in "${processed_prefixes[@]}"; do
      [ "$p" = "$prefix" ] && already_done=true && break
    done
    if $already_done; then
      continue
    fi
    processed_prefixes+=("$prefix")

    if render_and_shoot_html "$ROOT_DIR/$source" "$prefix" "$profile" "${width:-$WIDTH}" "${height:-$HEIGHT}"; then
      ok+=("$prefix")
    else
      failed+=("$prefix")
    fi
  done < <(awk 'BEGIN{S=sprintf("%c",31)}
    /^- image:/        { if (h) print i S s S p S sl S w S ht S b S a; i=$0; sub(/^- image: */,"",i); s="";p="";sl="";w="";ht="";b="";a="";h=1; next }
    /^  source:/       { v=$0; sub(/^  source: */,"",v); s=v; next }
    /^  profile:/      { v=$0; sub(/^  profile: */,"",v); p=v; next }
    /^  slide:/        { v=$0; sub(/^  slide: */,"",v); sl=v; next }
    /^  width:/        { v=$0; sub(/^  width: */,"",v); w=v; next }
    /^  height:/       { v=$0; sub(/^  height: */,"",v); ht=v; next }
    /^  builder:/      { v=$0; sub(/^  builder: */,"",v); b=v; next }
    /^  source-asset:/ { v=$0; sub(/^  source-asset: */,"",v); a=v; next }
    END                { if (h) print i S s S p S sl S w S ht S b S a }
  ' "$MANIFEST")

  set -e
  echo
  echo "==== rebuild summary ===="
  echo "ok:      ${#ok[@]}"
  echo "skipped: ${#skipped[@]}  ${skipped[*]}"
  echo "failed:  ${#failed[@]}  ${failed[*]}"
  [ ${#failed[@]} -eq 0 ] || exit 1
  exit 0
fi

# ---- Authoring mode --------------------------------------------------------
check_playwright

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
  section=$(basename "$(dirname "$qmd")")

  # Build image prefix, avoiding duplication if section == name
  if [ "$section" = "$name" ]; then
    image_prefix="$CHAPTER-$name"
  else
    image_prefix="$CHAPTER-$section-$name"
  fi
  [ -n "$profile" ] && image_prefix="$image_prefix-$profile"

  render_and_shoot_html "$qmd" "$image_prefix" "$profile" "$WIDTH" "$HEIGHT"
  update_manifest_html "$image_prefix" "${qmd#$ROOT_DIR/}" "$profile" "$WIDTH" "$HEIGHT"
done
