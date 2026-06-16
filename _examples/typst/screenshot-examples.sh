#!/bin/bash
# Render .qmd examples and screenshot pages to ../../images/.
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
# Run from _examples/typst/ or from the project root.

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)
CHAPTER=$(basename "$SCRIPT_DIR")
DENSITY=${DENSITY:-200}
OUT_DIR="$ROOT_DIR/images"
MANIFEST="$SCRIPT_DIR/screenshots.yml"
mkdir -p "$OUT_DIR"

# Render one qmd and screenshot a single page to OUT_DIR/<image>.
# Args: <qmd-abs> <image> <profile> <page> <density>
render_and_shoot() {
  local qmd="$1" image="$2" profile="$3" page="${4:-1}" density="${5:-$DENSITY}" mode="${6:-}"
  local name dir out_pdf out idx trim pad_color
  local -a render_args
  name=$(basename "$qmd" .qmd)
  dir=$(dirname "$qmd")
  if [ -n "$profile" ]; then
    out_pdf="$dir/$name-$profile.pdf"
    render_args=(--profile "$profile" --output "$name-$profile.pdf")
  else
    out_pdf="$dir/$name.pdf"
    render_args=()
  fi
  out="$OUT_DIR/$image"
  idx=$((page - 1))

  echo "Rendering $(basename "$qmd")${profile:+ [profile: $profile]} -> $image (page $page, ${density}dpi)"
  (cd "$dir" && quarto render "$(basename "$qmd")" "${render_args[@]}") || return 1

  # Screenshot mode (default: trim to content). May be passed in (arg 6, used by
  # manifest mode) or, if not, read from a marker in the .qmd:
  #   screenshot: full-page   keep the whole page (skip the -trim)
  #   screenshot: framed      keep the whole page + page outline + grey padding
  #   screenshot: full-width  keep the full body width but trim top/bottom
  #                           (so white-background code blocks stay body-width)
  if [ -z "$mode" ]; then
    mode="trim"
    if grep -q "screenshot: framed" "$qmd"; then mode="framed"
    elif grep -q "screenshot: full-page" "$qmd"; then mode="full-page"
    elif grep -q "screenshot: full-width" "$qmd"; then mode="full-width"
    fi
  fi

  if [ "$mode" = "full-width" ]; then
    # Content is left-aligned at the inner margin, so the content's left offset
    # equals the (symmetric) page margin. Body width = page width - 2*offset.
    local page bbox ch cx cy pw bodyw
    page=$(mktemp).png
    magick -density "$density" "$out_pdf[$idx]" -background white -flatten "$page" || return 1
    pw=$(magick "$page" -format "%w" info:)
    bbox=$(magick "$page" -fuzz 1% -format "%@" info:)   # WxH+X+Y of content
    ch=${bbox#*x}; ch=${ch%%+*}
    cx=${bbox#*+}; cx=${cx%%+*}
    cy=${bbox##*+}
    bodyw=$(( pw - 2 * cx ))
    magick "$page" -crop "${bodyw}x${ch}+${cx}+${cy}" +repage "$out" || return 1
    rm -f "$page"
  else
    trim="-trim +repage"
    { [ "$mode" = "framed" ] || [ "$mode" = "full-page" ]; } && trim=""
    magick -density "$density" "$out_pdf[$idx]" -background white -flatten \
      $trim "$out" || return 1
  fi

  if [ "$mode" = "framed" ]; then
    # Side padding is wider than top/bottom to match the anatomy diagram's
    # canvas proportions (viewBox shape).
    magick "$out" -bordercolor "#444" -border 6 \
      -bordercolor "#ececec" -border 350x100 "$out" || return 1
  else
    # Sample top-right pixel so the border matches the document's edge color
    # (colored body bgs fake their own padding; white-bg docs still get a white border).
    pad_color=$(magick "$out" -format "%[pixel:p{%[fx:w-1],0}]" info:)
    magick "$out" -bordercolor "$pad_color" -border 40 "$out" || return 1
  fi
  echo "Saved $out"
}

# Remove an image's existing manifest entry, then append a fresh one.
# Args: <image> <source-rel> <profile> <density>
update_manifest() {
  local image="$1" source="$2" profile="$3" density="$4" timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  # Skip the matching `- image:` line plus its indented fields until the next
  # `- image:` line (which is kept). Manifest entries are contiguous (no blank
  # separators), so terminating on the next entry is the only safe boundary.
  if [ -f "$MANIFEST" ]; then
    awk "/^- image: ${image//./\\.}\$/{found=1; next} found && /^- image:/{found=0} !found" \
      "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"
  fi
  cat >> "$MANIFEST" <<EOF
- image: $image
  source: $source${profile:+
  profile: $profile}
  density: $density
  generated: $timestamp
EOF
}

# ---- Manifest rebuild mode -------------------------------------------------
# Regenerate everything recorded in the manifest. Continues past failures and
# prints a summary so a single run reveals exactly what is (not) reproducible.
if [ "${1:-}" = "--manifest" ]; then
  echo "Rebuilding all images from $MANIFEST"
  ok=(); failed=(); skipped=()
  set +e
  # Fields are joined with \x1f (unit separator) rather than tab: tab is
  # IFS-whitespace, so `read` would collapse consecutive tabs and drop the
  # empty fields, shifting values into the wrong columns.
  while IFS=$'\x1f' read -r image source profile page density builder asset shot; do
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
    if render_and_shoot "$ROOT_DIR/$source" "$image" "$profile" "${page:-1}" "${density:-$DENSITY}" "$shot"; then
      ok+=("$image")
    else
      failed+=("$image")
    fi
  done < <(awk 'BEGIN{S=sprintf("%c",31)}
    /^- image:/        { if (h) print i S s S p S pg S d S b S a S sh; i=$0; sub(/^- image: */,"",i); s="";p="";pg="";d="";b="";a="";sh="";h=1; next }
    /^  source:/       { v=$0; sub(/^  source: */,"",v); s=v; next }
    /^  profile:/      { v=$0; sub(/^  profile: */,"",v); p=v; next }
    /^  page:/         { v=$0; sub(/^  page: */,"",v); pg=v; next }
    /^  density:/      { v=$0; sub(/^  density: */,"",v); d=v; next }
    /^  builder:/      { v=$0; sub(/^  builder: */,"",v); b=v; next }
    /^  source-asset:/ { v=$0; sub(/^  source-asset: */,"",v); a=v; next }
    /^  screenshot:/   { v=$0; sub(/^  screenshot: */,"",v); sh=v; next }
    END                { if (h) print i S s S p S pg S d S b S a S sh }
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

  if [ -n "$profile" ]; then
    image="$CHAPTER-$section-$name-$profile.png"
  else
    image="$CHAPTER-$section-$name.png"
  fi

  render_and_shoot "$qmd" "$image" "$profile" 1 "$DENSITY"
  update_manifest "$image" "${qmd#$ROOT_DIR/}" "$profile" "$DENSITY"
done
