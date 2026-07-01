#!/bin/bash
# Build the marginalia-geometry diagram for the Typst chapter.
#
# Renders _marginalia.qmd (margin-geometry with symmetric inner/outer far +
# separation) — same .column-page, body, and margin blocks as _anatomy.qmd —
# and overlays faint dashed lines + labels for the Marginalia parameters:
# inner.far, inner.width, inner.sep, outer.sep, outer.width, outer.far, top,
# bottom, plus the implicit body region.
#
# Run from any directory:
#   ./_examples/typst/page-layout/build-marginalia.sh

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$DIR/../../.." && pwd)"
DENSITY=200
OUT="$ROOT/images/typst-page-layout-marginalia.svg"

cd "$DIR"
quarto render _marginalia.qmd
magick -density "$DENSITY" "_marginalia.pdf[0]" -background white -flatten _marginalia.png
B64=$(base64 -i _marginalia.png)

cat > "$OUT" <<SVG
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg"
     viewBox="-50 0 2450 1360"
     role="img"
     aria-labelledby="svg-title svg-desc">
  <title id="svg-title">Marginalia geometry parameters in a Quarto Typst page</title>
  <desc id="svg-desc">A schematic of the top portion of a Typst page rendered through Quarto. Faint dashed lines drop from a measurement bracket at the top of the figure, marking the horizontal Marginalia geometry sections from left to right: inner.far, inner.width, inner.separation, body, outer.separation, outer.width, outer.far. The page continues beyond the bottom edge of the figure.</desc>

  <defs>
    <marker id="arrow" viewBox="0 0 20 20" refX="18" refY="10"
            markerWidth="20" markerHeight="20" markerUnits="userSpaceOnUse" orient="auto">
      <path d="M 0 0 L 20 10 L 0 20 z" fill="#444"/>
    </marker>
  </defs>

  <rect x="-50" y="0" width="2450" height="1360" fill="#ececec"/>

  <image x="300" y="340" width="1700" height="2200" href="data:image/png;base64,$B64"/>

  <rect x="300" y="340" width="1700" height="2200" fill="none" stroke="#333" stroke-width="6"/>

  <g stroke="#8a8a8a" stroke-width="2" stroke-dasharray="10 6" fill="none">
    <line x1="420"  y1="340" x2="420"  y2="1360"/>
    <line x1="582"  y1="340" x2="582"  y2="1360"/>
    <line x1="642"  y1="340" x2="642"  y2="1360"/>
    <line x1="1520" y1="340" x2="1520" y2="1360"/>
    <line x1="1580" y1="340" x2="1580" y2="1360"/>
    <line x1="1880" y1="340" x2="1880" y2="1360"/>
  </g>

  <g font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, 'DejaVu Sans Mono', monospace"
     font-size="44" fill="#222" stroke="none">

    <text x="40" y="560">papersize</text>
    <line x1="150" y1="585" x2="300" y2="670"
          stroke="#444" stroke-width="4" marker-end="url(#arrow)"/>

    <path d="M 300,330 L 300,300 L 642,300 L 642,330 M 420,330 L 420,300 M 582,330 L 582,300 M 1520,330 L 1520,300 L 2000,300 L 2000,330 M 1580,330 L 1580,300 M 1880,330 L 1880,300"
          fill="none" stroke="#444" stroke-width="4"/>

    <text x="300"  y="160" text-anchor="start" font-weight="bold">inner:</text>
    <text x="1520" y="160" text-anchor="start" font-weight="bold">outer:</text>

    <g font-size="36">
      <text x="360"  y="265" text-anchor="middle">far</text>
      <text x="501"  y="265" text-anchor="middle">width</text>
      <text x="582"  y="265" text-anchor="start">separation</text>

      <text x="1940" y="265" text-anchor="middle">far</text>
      <text x="1730" y="265" text-anchor="middle">width</text>
      <text x="1580" y="265" text-anchor="end">separation</text>
    </g>

    <text x="1150" y="565"  text-anchor="middle" fill="#234">.column-page</text>
    <text x="1081" y="825"  text-anchor="middle" fill="#234">.column-body</text>
    <text x="1730" y="800"  text-anchor="middle" font-size="32" fill="#234">.column-margin</text>

  </g>
</svg>
SVG

rm _marginalia.png
echo "Wrote $OUT"
