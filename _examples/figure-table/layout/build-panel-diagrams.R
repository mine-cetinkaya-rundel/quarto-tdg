# Build the panel layout diagrams for the Figures and tables chapter
# (@sec-panel-layout in figure-table.qmd).
#
# Writes four SVGs to images/figure-table-panel-*.svg, one for each way of
# combining a panel layout with cross-reference identifiers. Content is drawn
# as placeholders: an image on the left and a table on the right. Dashed
# outlines mark cross-referenceable elements. Main captions are left-aligned
# and sub-captions centered, matching Quarto defaults.
#
# Run from the project root (so renv and here find the project):
#   Rscript _examples/figure-table/layout/build-panel-diagrams.R

library(here)

mono <- "ui-monospace, SFMono-Regular, Menlo, Consolas, 'DejaVu Sans Mono', monospace"
sans <- "-apple-system, system-ui, 'Segoe UI', Roboto, sans-serif"
W <- 1200
H <- 640
L <- 150
R <- 650
Y <- 110

placeholder_image <- function(x, y, w = 400, h = 280) {
  sprintf(
    paste0(
      '<rect x="%d" y="%d" width="%d" height="%d" fill="#fff" stroke="#999" stroke-width="3"/>',
      '<circle cx="%d" cy="%d" r="28" fill="#ccc"/>',
      '<path d="M %d %d L %d %d L %d %d L %d %d L %d %d z" fill="#ccc"/>'
    ),
    x, y, w, h, x + w - 90, y + 80,
    x + 40, y + h - 30, x + 150, y + 110, x + 230, y + 200,
    x + 280, y + 150, x + w - 40, y + h - 30
  )
}

placeholder_table <- function(x, y, w = 400, h = 280, nrow = 5, ncol = 3) {
  rh <- h / nrow
  cw <- w / ncol
  rows <- sprintf(
    '<line x1="%d" y1="%.0f" x2="%d" y2="%.0f" stroke="#ccc" stroke-width="3"/>',
    x, y + rh * seq_len(nrow - 1), x + w, y + rh * seq_len(nrow - 1)
  )
  cols <- sprintf(
    '<line x1="%.0f" y1="%d" x2="%.0f" y2="%d" stroke="#ccc" stroke-width="3"/>',
    x + cw * seq_len(ncol - 1), y, x + cw * seq_len(ncol - 1), y + h
  )
  c(
    sprintf('<rect x="%d" y="%d" width="%d" height="%d" fill="#fff"/>', x, y, w, h),
    sprintf('<rect x="%d" y="%d" width="%d" height="%.0f" fill="#ddd"/>', x, y, w, rh),
    rows, cols,
    sprintf('<rect x="%d" y="%d" width="%d" height="%d" fill="none" stroke="#999" stroke-width="3"/>', x, y, w, h)
  )
}

caption <- function(x, y, label, num = NULL, anchor = "middle") {
  sprintf(
    '<text x="%d" y="%d" font-family="%s" font-size="34" fill="#222" text-anchor="%s">%s%s</text>',
    x, y, sans, anchor,
    if (is.null(num)) "" else sprintf('<tspan font-weight="bold">%s</tspan> ', num),
    label
  )
}

xref_box <- function(x, y, w, h, id, col = "#2e5090") {
  sprintf(
    paste0(
      '<rect x="%d" y="%d" width="%d" height="%d" rx="8" fill="none" stroke="%s" stroke-width="4" stroke-dasharray="16 10"/>',
      '<text x="%d" y="%d" font-family="%s" font-size="28" fill="%s">#%s</text>'
    ),
    x, y, w, h, col, x + 10, y - 12, mono, col, id
  )
}

write_svg <- function(file, title, desc, body, height = H) {
  writeLines(
    c(
      '<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
      sprintf('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" role="img" aria-labelledby="svg-title svg-desc">', W, height),
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

contents <- c(placeholder_image(L, Y), placeholder_table(R, Y))

write_svg(
  "figure-table-panel-images.svg",
  "Two pieces of content side by side",
  "An image placeholder and a table placeholder side by side, with no captions and no numbers.",
  contents
)

write_svg(
  "figure-table-panel-figures.svg",
  "A figure and a table side by side",
  "A figure and a table side by side. Each is outlined as its own cross-referenceable element, with its own numbered caption: Figure 1: Caption 1 and Table 1: Caption 2.",
  c(
    contents,
    caption(L, Y + 340, "Caption 1", "Figure 1:", anchor = "start"),
    caption(R, Y + 340, "Caption 2", "Table 1:", anchor = "start"),
    xref_box(L - 30, Y - 30, 460, 400, "fig-1"),
    xref_box(R - 30, Y - 30, 460, 400, "tbl-1")
  )
)

write_svg(
  "figure-table-panel-figure-of-images.svg",
  "One figure containing two pieces of content",
  "One figure outlined around an image placeholder and a table placeholder that sit side by side. Neither has a caption. A single caption below reads Figure 1: Main caption.",
  c(
    contents,
    caption(L, Y + 390, "Main caption", "Figure 1:", anchor = "start"),
    xref_box(L - 60, Y - 50, 1020, 480, "fig-main")
  )
)

write_svg(
  "figure-table-panel-subfigures.svg",
  "One figure with two sub-figures",
  "One outer figure containing two inner sub-figures side by side, one an image placeholder and one a table placeholder. Each sub-figure has a lettered sub-caption, (a) Sub-caption 1 and (b) Sub-caption 2. A single caption below both reads Figure 1: Main caption.",
  c(
    contents,
    caption(L + 200, Y + 340, "Sub-caption 1", "(a)"),
    caption(R + 200, Y + 340, "Sub-caption 2", "(b)"),
    xref_box(L - 30, Y - 20, 460, 390, "fig-sub1"),
    xref_box(R - 30, Y - 20, 460, 390, "fig-sub2"),
    caption(L, Y + 440, "Main caption", "Figure 1:", anchor = "start"),
    xref_box(L - 70, Y - 70, 1040, 550, "fig-main")
  )
)

write_svg(
  "figure-table-panel-custom-grid.svg",
  "Three pieces of content in a custom grid",
  "Two placeholders of equal width side by side in the first row, an image and a table, and one full-width image placeholder in the second row. No captions and no numbers.",
  c(
    contents,
    placeholder_image(L, Y + 320, w = 900, h = 280)
  ),
  height = Y + 320 + 280 + 110
)

write_svg(
  "figure-table-panel-valign.svg",
  "Two pieces of content of different heights aligned at the bottom",
  "A tall image placeholder on the left and a short table placeholder on the right. The bottom edges of the two placeholders line up. No captions and no numbers.",
  c(
    placeholder_image(L, Y, h = 420),
    placeholder_table(R, Y + 420 - 200, h = 200, nrow = 4)
  )
)
