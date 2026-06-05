#!/bin/bash
# Build the page-layout anatomy diagram for the Typst chapter.
#
# Renders _anatomy.qmd to a PDF, rasterises page 1 to PNG at 200 dpi, then
# composes an SVG that embeds the PNG as a base64 data URI and overlays
# vector annotations labelling papersize, margin, body-width, columns,
# gutter-width, margin-width, and page-numbering.
#
# Run from any directory:
#   ./_examples/typst/page-layout/build-anatomy.sh

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$DIR/../../.." && pwd)"
DENSITY=200
OUT="$ROOT/images/typst-page-layout-anatomy.svg"

cd "$DIR"
quarto render _anatomy.qmd
magick -density "$DENSITY" "_anatomy.pdf[0]" -background white -flatten _anatomy.png
B64=$(base64 -i _anatomy.png)

cat > "$OUT" <<SVG
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg"
     viewBox="-50 0 2450 2550"
     role="img"
     aria-labelledby="svg-title svg-desc">
  <title id="svg-title">Anatomy of a Typst page in Quarto</title>
  <desc id="svg-desc">A schematic of a Typst page rendered through Quarto. The outer rectangle is the page itself, labelled papersize. The whitespace around the body content is the page margin, with separate labels for the top, bottom, left, and right margins. The wider grey area at left containing two columns of stacked grey blocks is the body, labelled body-width, with the gap between its two columns marked columns: 2. A narrow gutter-width gap separates the body from a margin column on the right, labelled margin-width. A page number at the bottom of the page is labelled page-numbering.</desc>

  <defs>
    <marker id="arrow" viewBox="0 0 20 20" refX="18" refY="10"
            markerWidth="20" markerHeight="20" markerUnits="userSpaceOnUse" orient="auto">
      <path d="M 0 0 L 20 10 L 0 20 z" fill="#444"/>
    </marker>
  </defs>

  <rect x="-50" y="0" width="2450" height="2550" fill="#ececec"/>

  <image x="300" y="100" width="1700" height="2200" href="data:image/png;base64,$B64"/>

  <rect x="300" y="100" width="1700" height="2200" fill="none" stroke="#333" stroke-width="6"/>

  <g font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, 'DejaVu Sans Mono', monospace"
     font-size="44" fill="#222" stroke="none">

    <text x="40" y="90">papersize</text>
    <line x1="240" y1="100" x2="305" y2="115"
          stroke="#444" stroke-width="4" marker-end="url(#arrow)"/>

    <path d="M 400,100 L 400,250 M 385,100 L 415,100 M 385,250 L 415,250"
          fill="none" stroke="#444" stroke-width="4"/>
    <text x="445" y="185">margin: top</text>

    <path d="M 400,2150 L 400,2300 M 385,2150 L 415,2150 M 385,2300 L 415,2300"
          fill="none" stroke="#444" stroke-width="4"/>
    <text x="445" y="2235">margin: bottom</text>

    <path d="M 300,1500 L 420,1500 M 300,1485 L 300,1515 M 420,1485 L 420,1515"
          fill="none" stroke="#444" stroke-width="4"/>
    <text x="285" y="1565" text-anchor="end">margin: left</text>

    <path d="M 1880,1200 L 2000,1200 M 1880,1185 L 1880,1215 M 2000,1185 L 2000,1215"
          fill="none" stroke="#444" stroke-width="4"/>
    <text x="2040" y="1265">margin: right</text>

    <path d="M 712,240 L 712,220 L 1100,220 L 1100,240 M 1132,240 L 1132,220 L 1520,220 L 1520,240"
          fill="none" stroke="#444" stroke-width="4"/>
    <text x="1116" y="180" text-anchor="middle">columns: 2</text>

    <text x="2030" y="2210">page-numbering</text>
    <line x1="2020" y1="2195" x2="1145" y2="2195"
          stroke="#444" stroke-width="4" marker-end="url(#arrow)"/>

    <path d="M 712,2340 L 712,2370 L 1880,2370 L 1880,2340 M 1520,2340 L 1520,2370 M 1580,2340 L 1580,2370"
          fill="none" stroke="#444" stroke-width="4"/>
    <text x="1116" y="2435" text-anchor="middle">body-width</text>
    <text x="1730" y="2435" text-anchor="middle">margin-width</text>

    <line x1="1550" y1="2380" x2="1550" y2="2460"
          stroke="#444" stroke-width="4"/>
    <text x="1550" y="2510" text-anchor="middle">gutter-width</text>

  </g>
</svg>
SVG

rm _anatomy.png
echo "Wrote $OUT"
