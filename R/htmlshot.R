library(chromote)

# Screenshot a rendered HTML file with headless Chrome.
#
# `width` sets the CSS viewport, which controls layout (breakpoints, sidebars,
# margin column) and so the apparent text size once the image is scaled to the
# book's column. `scale` only adds pixel density; it does not change layout.
# `selector` trims to the bounding box of the matching element(s), grown by
# `expand` CSS px (length 1 or top/right/bottom/left); NULL captures the
# viewport, or the whole page if `full_page = TRUE`.
htmlshot <- function(
  html,
  filename,
  selector = NULL,
  width = 1200,
  height = 800,
  scale = 2,
  full_page = FALSE,
  expand = 0
) {
  b <- ChromoteSession$new(width = width, height = height)
  on.exit(b$close(), add = TRUE)

  loaded <- b$Page$loadEventFired(wait_ = FALSE)
  b$Page$navigate(paste0("file://", normalizePath(html)), wait_ = FALSE)
  b$wait_for(loaded)
  # Avoid capturing before web fonts are applied
  b$Runtime$evaluate("document.fonts.ready.then(() => true)", awaitPromise = TRUE)
  # The first capture (captureBeyondViewport) shifts the layout by a few px, so
  # take a throwaway one before measuring
  b$screenshot(filename = tempfile(fileext = ".png"), show = FALSE)

  # Quarto sets `html { height: 100% }`, and chromote clips selector bounds to
  # the <html> box, so anything below the first screen is cut off. Measure the
  # clip rectangle in page coordinates here and pass it as `cliprect` instead.
  if (is.null(selector)) {
    page_height <- js_value(b, "document.documentElement.scrollHeight")
    cliprect <- c(0, 0, width, if (full_page) page_height else height)
  } else {
    cliprect <- selector_rect(b, selector, expand)
  }

  b$screenshot(
    filename = filename,
    cliprect = cliprect,
    scale = scale,
    show = FALSE,
    options = list(captureBeyondViewport = TRUE)
  )
  invisible(filename)
}

js_value <- function(b, expr) {
  b$Runtime$evaluate(expr, returnByValue = TRUE)$result$value
}

# Union of the bounding boxes of all elements matching `selector`, in page
# coordinates, grown by `expand`.
selector_rect <- function(b, selector, expand = 0) {
  expand <- rep_len(expand, 4)
  r <- js_value(b, sprintf(
    "(() => {
      const els = [...document.querySelectorAll(%s)];
      if (!els.length) return null;
      const rs = els.map(e => e.getBoundingClientRect());
      const x = window.scrollX, y = window.scrollY;
      return {
        left: Math.min(...rs.map(r => r.left)) + x,
        top: Math.min(...rs.map(r => r.top)) + y,
        right: Math.max(...rs.map(r => r.right)) + x,
        bottom: Math.max(...rs.map(r => r.bottom)) + y
      };
    })()",
    jsonlite::toJSON(selector, auto_unbox = TRUE)
  ))
  if (is.null(r)) stop("No element matches selector: ", selector)
  left <- max(r$left - expand[4], 0)
  top <- max(r$top - expand[1], 0)
  c(left, top, r$right + expand[2] - left, r$bottom + expand[3] - top)
}
