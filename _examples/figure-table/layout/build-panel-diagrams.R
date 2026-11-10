# Build the panel layout diagrams for the Figures and tables chapter
# (@sec-panel-layout in figure-table.qmd).
#
# Writes SVGs to images/figure-table-panel-*.svg, one for each way of
# combining a panel layout with cross-reference identifiers. Content is drawn
# as plain boxes labelled CONTENT 1, CONTENT 2, ..., matching the placeholders
# in the code examples. Dashed outlines mark cross-referenceable elements.
# Main captions are left-aligned and sub-captions centered, matching Quarto
# defaults.
#
# Run from the project root (so renv and here find the project):
#   Rscript _examples/figure-table/layout/build-panel-diagrams.R

library(here)

mono <- "ui-monospace, SFMono-Regular, Menlo, Consolas, 'DejaVu Sans Mono', monospace"
sans <- "-apple-system, system-ui, 'Segoe UI', Roboto, sans-serif"
W <- 1200
L <- 150
R <- 650
CW <- 400 # content width
CH <- 280 # content height

# Font size for all text; the spacing below scales with it
FS <- 40
# Space between a dashed box and the content inside it
PAD <- 30
# Gap between the bottom of a dashed box and the baseline of its #id label
LABEL_GAP <- 14
# Vertical room taken by a #id label above a dashed box
LABEL_ROOM <- FS + LABEL_GAP + 16
# Distance from the content above a caption to the caption baseline
CAP_GAP <- FS + 24
# Background margin around the outermost element
MARGIN <- 40

placeholder <- function(x, y, label, w = CW, h = CH) {
  sprintf(
    paste0(
      '<rect x="%d" y="%d" width="%d" height="%d" fill="#fff" stroke="#999" stroke-width="3"/>',
      '<text x="%d" y="%d" font-family="%s" font-size="%d" fill="#666" text-anchor="middle" dominant-baseline="central">%s</text>'
    ),
    x, y, w, h, x + w %/% 2, y + h %/% 2, mono, FS, label
  )
}

caption <- function(x, y, label, num = NULL, anchor = "middle") {
  sprintf(
    '<text x="%d" y="%d" font-family="%s" font-size="%d" fill="#222" text-anchor="%s">%s%s</text>',
    x, y, sans, FS, anchor,
    if (is.null(num)) "" else sprintf('<tspan font-weight="bold">%s</tspan> ', num),
    label
  )
}

xref_box <- function(x, y, w, h, id, col = "#2e5090") {
  sprintf(
    paste0(
      '<rect x="%d" y="%d" width="%d" height="%d" rx="8" fill="none" stroke="%s" stroke-width="4" stroke-dasharray="16 10"/>',
      '<text x="%d" y="%d" font-family="%s" font-size="%d" fill="%s">#%s</text>'
    ),
    x, y, w, h, col, x + 12, y - LABEL_GAP, mono, FS, col, id
  )
}

write_svg <- function(file, title, desc, body, height) {
  writeLines(
    c(
      '<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
      # Explicit width/height give an intrinsic size, so the image doesn't
      # collapse to zero width when Quarto stacks panel cells on narrow screens
      sprintf('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" role="img" aria-labelledby="svg-title svg-desc">', W, height, W, height),
      sprintf('  <title id="svg-title">%s</title>', title),
      sprintf('  <desc id="svg-desc">%s</desc>', desc),
      sprintf('  <rect x="0" y="0" width="%d" height="%d" fill="#ececec"/>', W, height),
      paste0("  ", body),
      "</svg>"
    ),
    here("images", file)
  )
  message("Wrote images/", file)
}

contents <- function(y) {
  c(placeholder(L, y, "CONTENT 1"), placeholder(R, y, "CONTENT 2"))
}

# No labels or captions
local({
  y <- MARGIN + 40
  write_svg(
    "figure-table-panel-images.svg",
    "Two pieces of content side by side",
    "Two placeholders, CONTENT 1 and CONTENT 2, side by side, with no captions and no numbers.",
    contents(y),
    height = y + CH + MARGIN + 40
  )
})

# One dashed box per item, each with a caption
local({
  box_top <- MARGIN + LABEL_ROOM
  y <- box_top + PAD
  cap_y <- y + CH + CAP_GAP
  box_h <- cap_y + PAD - box_top
  write_svg(
    "figure-table-panel-figures.svg",
    "A figure and a table side by side",
    "Two placeholders, CONTENT 1 and CONTENT 2, side by side. Each is outlined as its own cross-referenceable element, with its own numbered caption: Figure 1: Caption 1 and Table 1: Caption 2.",
    c(
      contents(y),
      caption(L, cap_y, "Caption 1", "Figure 1:", anchor = "start"),
      caption(R, cap_y, "Caption 2", "Table 1:", anchor = "start"),
      xref_box(L - PAD, box_top, CW + 2 * PAD, box_h, "fig-1"),
      xref_box(R - PAD, box_top, CW + 2 * PAD, box_h, "tbl-1")
    ),
    height = box_top + box_h + MARGIN
  )
})

# One dashed box around both items, with one caption
local({
  box_top <- MARGIN + LABEL_ROOM
  y <- box_top + 2 * PAD
  cap_y <- y + CH + CAP_GAP
  box_h <- cap_y + 2 * PAD - box_top
  write_svg(
    "figure-table-panel-figure-of-images.svg",
    "One figure containing two pieces of content",
    "One figure outlined around two placeholders, CONTENT 1 and CONTENT 2, that sit side by side. Neither has a caption. A single caption below reads Figure 1: Main caption.",
    c(
      contents(y),
      caption(L, cap_y, "Main caption", "Figure 1:", anchor = "start"),
      xref_box(L - 2 * PAD, box_top, R + CW - L + 4 * PAD, box_h, "fig-main")
    ),
    height = box_top + box_h + MARGIN
  )
})

# Inner dashed boxes with sub-captions, inside an outer dashed box
local({
  outer_top <- MARGIN + LABEL_ROOM
  inner_top <- outer_top + PAD + LABEL_ROOM
  y <- inner_top + PAD
  sub_y <- y + CH + CAP_GAP
  inner_h <- sub_y + PAD - inner_top
  cap_y <- inner_top + inner_h + CAP_GAP
  outer_h <- cap_y + PAD - outer_top
  write_svg(
    "figure-table-panel-subfigures.svg",
    "One figure with two sub-figures",
    "One outer figure containing two inner sub-figures side by side, containing CONTENT 1 and CONTENT 2. Each sub-figure has a lettered sub-caption, (a) Sub-caption 1 and (b) Sub-caption 2. A single caption below both reads Figure 1: Main caption.",
    c(
      contents(y),
      caption(L + CW %/% 2, sub_y, "Sub-caption 1", "(a)"),
      caption(R + CW %/% 2, sub_y, "Sub-caption 2", "(b)"),
      xref_box(L - PAD, inner_top, CW + 2 * PAD, inner_h, "fig-sub1"),
      xref_box(R - PAD, inner_top, CW + 2 * PAD, inner_h, "fig-sub2"),
      caption(L, cap_y, "Main caption", "Figure 1:", anchor = "start"),
      xref_box(L - 2 * PAD, outer_top, R + CW - L + 4 * PAD, outer_h, "fig-main")
    ),
    height = outer_top + outer_h + MARGIN
  )
})

local({
  y <- MARGIN + 40
  y2 <- y + CH + 40
  write_svg(
    "figure-table-panel-custom-grid.svg",
    "Three pieces of content in a custom grid",
    "Two placeholders of equal width side by side in the first row, CONTENT 1 and CONTENT 2, and one full-width placeholder, CONTENT 3, in the second row. No captions and no numbers.",
    c(
      contents(y),
      placeholder(L, y2, "CONTENT 3", w = R + CW - L)
    ),
    height = y2 + CH + MARGIN + 40
  )
})

local({
  y <- MARGIN + 40
  tall <- 420
  short <- 200
  write_svg(
    "figure-table-panel-valign.svg",
    "Two pieces of content of different heights aligned at the bottom",
    "A tall placeholder, CONTENT 1, on the left and a short placeholder, CONTENT 2, on the right. The bottom edges of the two placeholders line up. No captions and no numbers.",
    c(
      placeholder(L, y, "CONTENT 1", h = tall),
      placeholder(R, y + tall - short, "CONTENT 2", h = short)
    ),
    height = y + tall + MARGIN + 40
  )
})
