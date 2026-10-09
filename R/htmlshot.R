library(chromote)

# Screenshot a rendered HTML file with headless Chrome.
#
# `width` sets the CSS viewport, which controls layout (breakpoints, sidebars,
# margin column) and so the apparent text size once the image is scaled to the
# book's column. `scale` only adds pixel density; it does not change layout.
# `selector` trims to the bounding box of the matching element(s); NULL captures
# the viewport, or the whole page if `full_page = TRUE`.
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

  # Quarto sets `html { height: 100% }`, and chromote clips selector bounds to
  # the <html> box, so elements below the first screen would be cut off or fall
  # back to the viewport. Make the viewport as tall as the page.
  if (!is.null(selector) || full_page) {
    page_height <- b$Runtime$evaluate(
      "document.documentElement.scrollHeight"
    )$result$value
    b$set_viewport_size(width, max(height, page_height))
  }

  if (is.null(selector)) {
    selector <- "html"
    cliprect <- if (full_page) NULL else c(0, 0, width, height)
  } else {
    cliprect <- NULL
  }

  b$screenshot(
    filename = filename,
    selector = selector,
    cliprect = cliprect,
    expand = expand,
    scale = scale,
    show = FALSE,
    options = list(captureBeyondViewport = TRUE)
  )
  invisible(filename)
}
