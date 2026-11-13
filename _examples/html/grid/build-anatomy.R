# Build the page-layout grid diagram for the HTML chapter.
#
# Renders _anatomy.qmd (default grid options), opens it in headless Chrome at
# three viewport widths (one per layout: wide, medium, narrow), and captures
# each one as a PNG. It also measures the body, margin, and .column-page
# blocks. Then it composes an SVG that stacks the three captures at the same
# scale, embeds them as base64 data URIs, and overlays vector brackets for the
# `grid` options. The bracket positions come from the measured blocks, so they
# stay correct if Quarto's defaults change.
#
# Run from the project root:
#   source("_examples/html/grid/build-anatomy.R")

library(chromote)
source("R/htmlshot.R") # serve_dir(), js_value()

local({
  dir <- "_examples/html/grid"
  out <- "images/html-grid-anatomy.svg"
  panels <- data.frame(
    width = c(1400, 900, 600),
    label = c(
      "992px and wider",
      "768px to 991px",
      "Narrower than 768px"
    )
  )

  owd <- setwd(dir)
  system2("quarto", c("render", "_anatomy.qmd", "--quiet"))
  setwd(owd)

  url <- serve_dir(normalizePath(dir))
  on.exit(attr(url, "server")$kill(), add = TRUE)

  measure_js <- "(() => {
    const r = s => {
      const e = document.querySelector(s).getBoundingClientRect();
      return {l: e.left + scrollX, t: e.top + scrollY,
              r: e.right + scrollX, b: e.bottom + scrollY};
    };
    return {main: r('main'), body: r('.blk-body'), margin: r('.blk-margin'),
            page: r('.blk-page')};
  })()"

  capture <- function(width) {
    b <- ChromoteSession$new(width = width, height = 900)
    on.exit(b$close(), add = TRUE)
    b$Emulation$setScrollbarsHidden(hidden = TRUE)
    loaded <- b$Page$loadEventFired(wait_ = FALSE)
    b$Page$navigate(paste0(url, "/_anatomy.html"), wait_ = FALSE)
    b$wait_for(loaded)
    # The load event can fire before Bootstrap's CSS applies; measuring then
    # captures an unstyled page. Wait until <main> is laid out as a grid.
    for (j in 1:50) {
      styled <- js_value(b, "getComputedStyle(document.querySelector('main')).display === 'grid'")
      if (isTRUE(styled)) break
      Sys.sleep(0.1)
    }
    if (!isTRUE(styled)) stop("Page styles did not load at width ", width)
    b$Runtime$evaluate("document.fonts.ready.then(() => true)", awaitPromise = TRUE)
    Sys.sleep(0.5)
    m <- js_value(b, measure_js)
    top <- m$main$t - 24
    height <- m$main$b + 24 - top
    shot <- b$Page$captureScreenshot(
      format = "png",
      clip = list(x = 0, y = top, width = width, height = height, scale = 1)
    )
    # Express block positions relative to the top of the capture
    m <- lapply(m, function(r) {
      r$t <- r$t - top
      r$b <- r$b - top
      r
    })
    list(width = width, height = height, data = shot$data, m = m)
  }
  shots <- lapply(panels$width, capture)

  # Layout (SVG units are CSS px of the captures)
  pad <- 40
  total_w <- max(panels$width) + 2 * pad
  annot_h <- 120 # room for the brackets between the first title and panel
  title_h <- 56
  gap <- 50

  f <- function(...) sprintf(...)
  bracket <- function(x1, x2, y, dashed = FALSE) {
    f(
      '<path d="M %.1f,%.1f L %.1f,%.1f M %.1f,%.1f L %.1f,%.1f M %.1f,%.1f L %.1f,%.1f" fill="none" stroke="#444" stroke-width="3"%s/>',
      x1, y, x2, y, x1, y - 12, x1, y + 12, x2, y - 12, x2, y + 12,
      if (dashed) ' stroke-dasharray="8 6"' else ""
    )
  }
  guide <- function(x, y1, y2) {
    f(
      '<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#888" stroke-width="2" stroke-dasharray="6 6"/>',
      x, y1, x, y2
    )
  }
  label <- function(x, y, text, anchor = "middle") {
    f('<text x="%.1f" y="%.1f" text-anchor="%s">%s</text>', x, y, anchor, text)
  }

  body <- character()
  y <- pad / 2
  for (i in seq_along(shots)) {
    s <- shots[[i]]
    x0 <- (total_w - s$width) / 2
    body <- c(
      body,
      f('<text class="title" x="%.1f" y="%.1f">%s</text>', x0, y + 38, panels$label[i])
    )
    y_img <- y + title_h + if (i == 1) annot_h else 0
    body <- c(
      body,
      f(
        '<image x="%.1f" y="%.1f" width="%d" height="%.1f" href="data:image/png;base64,%s"/>',
        x0, y_img, s$width, s$height, s$data
      ),
      f(
        '<rect x="%.1f" y="%.1f" width="%d" height="%.1f" fill="none" stroke="#333" stroke-width="4"/>',
        x0, y_img, s$width, s$height
      )
    )

    # Name the column class of each block, centered in the block
    for (blk in c("body", "margin", "page")) {
      r <- s$m[[blk]]
      body <- c(
        body,
        f(
          '<text class="cls" x="%.1f" y="%.1f">.column-%s</text>',
          x0 + (r$l + r$r) / 2, y_img + (r$t + r$b) / 2, blk
        )
      )
    }

    if (i == 1) {
      m <- s$m
      gutter <- m$margin$l - m$body$r
      xs <- list(
        page_l = m$page$l, body_start = m$body$l - gutter,
        body_l = m$body$l, body_r = m$body$r,
        margin_l = m$margin$l, margin_r = m$margin$r
      )
      xs <- lapply(xs, function(v) v + x0)
      yb <- y_img - 24 # bracket row, between the panel title and the panel
      body <- c(
        body,
        vapply(xs, guide, "", y1 = yb, y2 = y_img + s$height),
        bracket(xs$page_l, xs$body_start, yb, dashed = TRUE),
        label(xs$body_start, yb - 70, "sidebar-width", "end"),
        f(
          '<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#444" stroke-width="2"/>',
          xs$body_start - 4, yb - 62, (xs$page_l + xs$body_start) / 2, yb - 14
        ),
        bracket(xs$body_l, xs$body_r, yb),
        label((xs$body_l + xs$body_r) / 2, yb - 24, "body-width"),
        bracket(xs$body_r, xs$margin_l, yb),
        label(xs$body_r, yb - 70, "gutter-width", "middle"),
        f(
          '<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#444" stroke-width="2"/>',
          xs$body_r, yb - 62, (xs$body_r + xs$margin_l) / 2, yb - 14
        ),
        bracket(xs$margin_l, xs$margin_r, yb),
        label((xs$margin_l + xs$margin_r) / 2, yb - 24, "margin-width")
      )
    }
    y <- y_img + s$height + gap
  }
  total_h <- y - gap + pad

  svg <- c(
    '<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
    f(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %.0f %.0f" role="img" aria-labelledby="svg-title svg-desc">',
      total_w, total_h
    ),
    '  <title id="svg-title">The HTML page grid at three screen widths</title>',
    '  <desc id="svg-desc">Three browser windows of decreasing width, stacked vertically at the same scale. Each shows a grey block labelled .column-body, a pink block labelled .column-margin, and a blue block labelled .column-page. In the widest window, labelled 992px and wider, brackets above the page mark body-width over the body column, gutter-width over the gap between body and margin, margin-width over the margin column, and a dashed sidebar-width bracket over the short distance the blue block extends left of the body. In the middle window, labelled 768px to 991px, the margin column remains but the blue block no longer extends left of the body. In the narrowest window, labelled narrower than 768px, there is a single column: the pink margin note sits above the body block and the blue block is the same width as the body.</desc>',
    f('  <rect width="%.0f" height="%.0f" fill="#ececec"/>', total_w, total_h),
    '  <g font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, \'DejaVu Sans Mono\', monospace" font-size="30" fill="#222" stroke="none">',
    '  <style>.title { font-family: system-ui, -apple-system, \'Segoe UI\', sans-serif; font-size: 32px; font-weight: 600; } .cls { font-size: 22px; fill: #333; text-anchor: middle; dominant-baseline: central; }</style>',
    paste0("    ", body),
    "  </g>",
    "</svg>"
  )
  writeLines(svg, out)
  unlink(file.path(dir, c("_anatomy.html", "_anatomy_files")), recursive = TRUE)
  message("Wrote ", out)
})
