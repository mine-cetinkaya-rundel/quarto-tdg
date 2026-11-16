# Render HTML examples and screenshot them to images/.
#
# Interactive use (from the project root):
#   source("_examples/html/screenshot-examples.R")
#   shoot("_examples/html/first-document/train-punctuality.qmd", selector = "main")
#   rebuild()                       # regenerate every image in screenshots.yml
#   compare_widths("_examples/html/first-document/train-punctuality.qmd")
#
# Command line:
#   Rscript _examples/html/screenshot-examples.R --manifest
#   Rscript _examples/html/screenshot-examples.R path/to/example.qmd ...

library(here)
library(fs)
library(yaml)

source(here("R", "htmlshot.R"))

html_dir <- here("_examples", "html")
image_dir <- here("images")
manifest_path <- path(html_dir, "screenshots.yml")

defaults <- list(
  width = 1200, height = 800, scale = 2, `full-page` = FALSE, expand = 0,
  `color-scheme` = "light", click = NULL, hover = NULL
)

# Render `source` (path relative to project root) and return the HTML path.
render_example <- function(source, profile = NULL) {
  qmd <- here(source)
  name <- path_ext_remove(path_file(qmd))
  out <- if (is.null(profile)) paste0(name, ".html") else paste0(name, "-", profile, ".html")
  args <- c("render", path_file(qmd), "--to", "html")
  if (!is.null(profile)) args <- c(args, "--profile", profile, "--output", out)
  withr::with_dir(path_dir(qmd), {
    status <- system2("quarto", args)
  })
  if (status != 0) stop("quarto render failed for ", source)
  path(path_dir(qmd), out)
}

# html-{section}-{name}[-{profile}][-dark].png
image_name <- function(source, name = NULL, profile = NULL, color_scheme = "light") {
  section <- path_file(path_dir(source))
  name <- name %||% path_ext_remove(path_file(source))
  dark <- if (identical(color_scheme, "dark")) "dark"
  paste0(paste(c("html", section, name, profile, dark), collapse = "-"), ".png")
}

shoot_entry <- function(entry, html) {
  e <- modifyList(defaults, entry)
  htmlshot(
    html,
    filename = path(image_dir, e$image),
    selector = e$selector,
    width = e$width,
    height = e$height,
    scale = e$scale,
    full_page = isTRUE(e$`full-page`),
    expand = e$expand,
    color_scheme = e$`color-scheme`,
    click = e$click,
    hover = e$hover
  )
}

read_manifest <- function() {
  if (file_exists(manifest_path)) read_yaml(manifest_path) %||% list() else list()
}

write_manifest <- function(entries) {
  entries <- entries[order(vapply(entries, `[[`, "", "image"))]
  # Write 16 rather than 16.0
  entries <- lapply(entries, lapply, function(v) {
    if (is.double(v) && all(v == round(v))) as.integer(v) else v
  })
  write_yaml(entries, manifest_path)
}

timestamp <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

# Authoring mode: render one example, screenshot it, record it in the manifest.
# Only non-default settings are written, so the manifest shows what is special.
shoot <- function(
  source,
  name = NULL,
  selector = NULL,
  profile = NULL,
  ...
) {
  source <- path_rel(here(source), here())
  if (startsWith(path_file(source), "_")) stop("Fragments (_*.qmd) are not screenshotted")
  opts <- list(...)
  bad <- setdiff(names(opts), names(defaults))
  if (length(bad)) stop("Unknown option(s): ", paste(bad, collapse = ", "))

  entry <- c(
    list(
      image = image_name(source, name, profile, opts$`color-scheme` %||% "light"),
      source = as.character(source)
    ),
    if (!is.null(selector)) list(selector = selector),
    if (!is.null(profile)) list(profile = profile),
    opts[!mapply(identical, opts, defaults[names(opts)])]
  )

  shoot_entry(entry, render_example(source, profile))
  entry$generated <- timestamp()

  entries <- read_manifest()
  entries <- Filter(function(x) x$image != entry$image, entries)
  write_manifest(c(entries, list(entry)))
  message("Wrote ", entry$image)
  invisible(entry)
}

# Manifest mode: render each source/profile once, then take all its shots.
rebuild <- function() {
  entries <- read_manifest()
  key <- vapply(entries, function(e) paste(e$source, e$profile %||% ""), "")
  for (k in unique(key)) {
    idx <- which(key == k)
    html <- render_example(entries[[idx[1]]]$source, entries[[idx[1]]]$profile)
    for (i in idx) {
      message("Shooting ", entries[[i]]$image)
      shoot_entry(entries[[i]], html)
      entries[[i]]$generated <- timestamp()
    }
  }
  write_manifest(entries)
  invisible(entries)
}

# Try several viewport widths for one example; writes to `out_dir`, not images/
# or the manifest. Use to judge text size against the book's column width.
compare_widths <- function(
  source,
  widths = c(800, 1000, 1200),
  selector = NULL,
  out_dir = path_temp("html-widths"),
  ...
) {
  dir_create(out_dir)
  html <- render_example(path_rel(here(source), here()))
  files <- vapply(widths, function(w) {
    f <- path(out_dir, paste0(path_ext_remove(path_file(source)), "-", w, ".png"))
    htmlshot(html, f, selector = selector, width = w, ...)
    as.character(f)
  }, "")
  message("Wrote:\n", paste(files, collapse = "\n"))
  invisible(files)
}

if (!interactive() && sys.nframe() == 0) {
  args <- commandArgs(trailingOnly = TRUE)
  if (identical(args, "--manifest")) {
    rebuild()
  } else {
    for (a in args) shoot(a)
  }
}
