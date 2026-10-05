library(quarto)
library(chromote)

qmdshot <- function(
  document,
  filename = "screenshot.png",
  selector = "html"
) {
  port <- quarto:::find_port()
  quarto_preview(
    document,
    port = port,
    render = "html",
    browse = FALSE,
    watch = FALSE
  )
  on.exit(quarto_preview_stop(), add = TRUE)

  b <- ChromoteSession$new()
  on.exit(b$close(), add = TRUE)

  b$go_to(paste0("http://localhost:", port))
  b$screenshot(filename = tempfile(fileext = ".png"))
  b$screenshot(
    filename = filename,
    selector = selector,
    region = "margin",
    options = list(captureBeyondViewport = TRUE)
  )
}
