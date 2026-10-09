library(here)
library(fs)
library(dplyr)

source(here("R", "htmlshot.R"))

source_dir <- here("_examples", "figure-table")
image_dir <- here("images")

# Input list of file, ID pairs
# fmt: skip
screenshots <- tribble(
  ~file,                          ~id,
  "quick-start/r.qmd",            "quick-start-figure",
  "multiple/r.qmd",               "multiple-figures",
  "multiple/r.qmd",               "multiple-tables",
  "position/r.qmd",               "column-screen",
  "position/r.qmd",               "column-margin",
  "basic-cell-options/r.qmd",     "basic-cell-options-table",
  "basic-cell-options/r.qmd",     "basic-cell-options-figure",
  "cross-references/simple.qmd",  "simple",
  "cross-references/sub-references.qmd", "sub-references",
  "fig-align/r.qmd",              "align-left",
  "fig-align/r.qmd",              "align-center",
  "fig-align/r.qmd",              "align-right",
  "captions/location-top.qmd",    "captions-location-top",
  "captions/location-bottom.qmd", "captions-location-bottom",
  "captions/location-margin.qmd", "captions-location-margin",
)

# Override the default selector (`#id`) and add padding (CSS px, top/right/bottom/left)
# fmt: skip
overrides <- tribble(
  ~id,             ~selector,                ~expand,
  "column-screen", "#column-screen > .cell", c(70, 0, 70, 0),
)

screenshots <- screenshots |>
  left_join(overrides, by = "id") |>
  mutate(
    document = path(source_dir, file),
    html = path_ext_set(document, "html"),
    filename = path(image_dir, paste0("figure-table-", id), ext = "png"),
    selector = coalesce(selector, paste0("#", id)),
    expand = purrr::map(expand, \(e) e %||% 0)
  )

# quarto_render() rather than the quarto CLI, so the project's renv library is used
for (doc in unique(screenshots$document)) {
  quarto::quarto_render(doc, output_format = "html", quiet = TRUE)
}
file_delete(dir_ls(source_dir, recurse = TRUE, glob = "*.html.md"))

# width and scale match the existing images
for (i in seq_len(nrow(screenshots))) {
  with(
    screenshots[i, ],
    htmlshot(
      html,
      filename,
      selector = selector,
      expand = expand[[1]],
      width = 992,
      scale = 1
    )
  )
}
