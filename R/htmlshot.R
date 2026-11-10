library(chromote)

# Screenshot a rendered HTML file with headless Chrome.
#
# `width` sets the CSS viewport, which controls layout (breakpoints, sidebars,
# margin column) and so the apparent text size once the image is scaled to the
# book's column. `scale` only adds pixel density; it does not change layout.
# `selector` trims to the bounding box of the matching element(s), grown by
# `expand` CSS px (length 1 or top/right/bottom/left); NULL captures the
# viewport, or the whole page if `full_page = TRUE`.
# `color_scheme` ("light" or "dark") sets Quarto's light/dark toggle; "dark"
# requires a document with both a light and a dark theme.
# `click` and `hover` are CSS selectors for an element to click (e.g. to open a
# menu) or to put the mouse over (e.g. to show a copy button) before capture.
htmlshot <- function(
  html,
  filename,
  selector = NULL,
  width = 1200,
  height = 800,
  scale = 2,
  full_page = FALSE,
  expand = 0,
  color_scheme = "light",
  click = NULL,
  hover = NULL
) {
  color_scheme <- match.arg(color_scheme, c("light", "dark"))
  b <- ChromoteSession$new(width = width, height = height)
  on.exit(b$close(), add = TRUE)
  # Hide scrollbars before loading so the layout width is exactly `width`
  # (chromote's screenshot() hides them, but only by resizing after load)
  b$Emulation$setScrollbarsHidden(hidden = TRUE)

  # Serve over HTTP: Quarto loads quarto.js as an ES module, which Chrome
  # blocks on file://, so page behaviour (e.g. TOC collapse) would be missing.
  url <- serve_dir(dirname(normalizePath(html)))
  on.exit(attr(url, "server")$kill(), add = TRUE)

  loaded <- b$Page$loadEventFired(wait_ = FALSE)
  b$Page$navigate(paste0(url, "/", utils::URLencode(basename(html))), wait_ = FALSE)
  b$wait_for(loaded)
  # Let Quarto's scroll/layout scripts (and their CSS transitions) settle
  Sys.sleep(0.5)
  set_color_scheme(b, color_scheme)
  # Avoid capturing before web fonts are applied
  b$Runtime$evaluate("document.fonts.ready.then(() => true)", awaitPromise = TRUE)
  if (!is.null(click)) click_element(b, click)
  if (!is.null(hover)) hover_element(b, hover)

  # Quarto sets `html { height: 100% }`, and chromote clips selector bounds to
  # the <html> box, so anything below the first screen is cut off. Measure the
  # clip rectangle in page coordinates here and pass it as `cliprect` instead.
  measure <- function() {
    if (is.null(selector)) {
      page_height <- js_value(b, "document.documentElement.scrollHeight")
      c(0, 0, width, if (full_page) page_height else height)
    } else {
      selector_rect(b, selector, expand)
    }
  }
  cliprect <- measure()

  # If the clip fits in the viewport, capture it directly. chromote's
  # screenshot() and captureBeyondViewport both resize the page, and Quarto
  # reacts to resize events (e.g. it mispositions the collapsed-TOC toggle).
  scroll <- js_value(b, "[window.scrollX, window.scrollY]")
  # Don't let `expand` push the clip past the page's right edge (or scrollbar)
  client_width <- js_value(b, "document.documentElement.clientWidth")
  cliprect[3] <- min(cliprect[3], scroll[[1]] + client_width - cliprect[1])
  in_view <- cliprect[1] >= scroll[[1]] && cliprect[2] >= scroll[[2]] &&
    cliprect[1] + cliprect[3] <= scroll[[1]] + width &&
    cliprect[2] + cliprect[4] <= scroll[[2]] + height
  if (in_view) {
    shot <- b$Page$captureScreenshot(
      format = "png",
      clip = list(
        x = cliprect[1], y = cliprect[2],
        width = cliprect[3], height = cliprect[4],
        scale = scale
      )
    )
    writeBin(jsonlite::base64_dec(shot$data), filename)
    return(invisible(filename))
  }

  # The first capture (captureBeyondViewport) shifts the layout by a few px, so
  # take a throwaway one and measure again
  b$screenshot(filename = tempfile(fileext = ".png"), show = FALSE)
  cliprect <- measure()

  b$screenshot(
    filename = filename,
    cliprect = cliprect,
    scale = scale,
    show = FALSE,
    options = list(captureBeyondViewport = TRUE)
  )
  invisible(filename)
}

# Start a static file server for `dir` on a free local port. Returns the base
# URL with the processx handle in attr "server"; the caller kills it.
serve_dir <- function(dir) {
  for (i in 1:10) {
    port <- sample(20000:40000, 1)
    p <- processx::process$new(
      "python3",
      c("-m", "http.server", port, "--bind", "127.0.0.1", "--directory", dir),
      stdout = NULL, stderr = NULL
    )
    url <- paste0("http://127.0.0.1:", port)
    for (j in 1:50) {
      ok <- tryCatch({
        con <- url(url, open = "rb")
        close(con)
        TRUE
      }, error = function(e) FALSE, warning = function(w) FALSE)
      if (ok) return(structure(url, server = p))
      if (!p$is_alive()) break
      Sys.sleep(0.1)
    }
    p$kill()
  }
  stop("Could not start a local HTTP server for ", dir)
}

click_element <- function(b, selector) {
  ok <- js_value(b, sprintf(
    "(() => { const e = document.querySelector(%s); if (!e) return false; e.click(); return true; })()",
    jsonlite::toJSON(selector, auto_unbox = TRUE)
  ))
  if (!isTRUE(ok)) stop("No element matches click selector: ", selector)
  Sys.sleep(0.5) # let menus and transitions finish
}

# CSS :hover needs a real mouse event, so move the mouse to the element centre
# (in viewport coordinates).
hover_element <- function(b, selector) {
  r <- js_value(b, sprintf(
    "(() => {
      const e = document.querySelector(%s);
      if (!e) return null;
      e.scrollIntoView({block: 'center'});
      const r = e.getBoundingClientRect();
      return {x: r.left + r.width / 2, y: r.top + r.height / 2};
    })()",
    jsonlite::toJSON(selector, auto_unbox = TRUE)
  ))
  if (is.null(r)) stop("No element matches hover selector: ", selector)
  b$Input$dispatchMouseEvent(type = "mouseMoved", x = r$x, y = r$y)
  Sys.sleep(0.5)
}

js_value <- function(b, expr) {
  b$Runtime$evaluate(expr, returnByValue = TRUE)$result$value
}

# Quarto keeps the toggle state in localStorage, which can persist between
# sessions in the same browser, so set the scheme explicitly instead of
# assuming the page loads in light mode.
set_color_scheme <- function(b, color_scheme) {
  ok <- js_value(b, sprintf(
    "(() => {
      const dark = document.body.classList.contains('quarto-dark');
      if (dark === %s) return true;
      if (typeof window.quartoToggleColorScheme !== 'function') return false;
      window.quartoToggleColorScheme();
      return true;
    })()",
    tolower(color_scheme == "dark")
  ))
  if (!isTRUE(ok)) stop("Page has no light/dark toggle; cannot use color_scheme = '", color_scheme, "'")
}

# Union of the bounding boxes of all visible elements matching `selector`, in
# page coordinates, grown by `expand`. Hidden elements (e.g. the inactive
# `.light-content`/`.dark-content` rendering) have empty boxes and are skipped.
selector_rect <- function(b, selector, expand = 0) {
  expand <- rep_len(expand, 4)
  r <- js_value(b, sprintf(
    "(() => {
      const rs = [...document.querySelectorAll(%s)]
        .map(e => e.getBoundingClientRect())
        .filter(r => r.width > 0 && r.height > 0);
      if (!rs.length) return null;
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
  if (is.null(r)) stop("No visible element matches selector: ", selector)
  left <- max(r$left - expand[4], 0)
  top <- max(r$top - expand[1], 0)
  c(left, top, r$right + expand[2] - left, r$bottom + expand[3] - top)
}
