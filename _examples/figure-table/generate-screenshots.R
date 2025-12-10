library(here)
library(fs)
library(dplyr)

source(here("R", "qmdshot.R"))

source_dir <- here("_examples", "figure-table")
image_dir <- here("images")


# Input list of file, ID pairs
# fmt: skip
screenshots <- tribble(
  ~file,                      ~id,
  "quick-start/r.qmd"      , "quick-start-figure",
  "quick-start/r.qmd"      , "basic-cell-options-table",
  "multiple/r.qmd"         ,  "multiple-figures",
  "multiple/r.qmd"         ,  "multiple-tables",
  "position/r.qmd"         ,  "column-screen",
  "position/r.qmd"         ,  "column-margin",
  "basic-cell-options/r.qmd", "basic-cell-options-table",
  "basic-cell-options/r.qmd", "basic-cell-options-figure",
  "cross-references/r.qmd"  , "cross-references-link",
  "cross-references/simple.qmd", "simple",
  "fig-align/r.qmd",         "align-left",
  "fig-align/r.qmd",         "align-center",
  "fig-align/r.qmd",         "align-right",
)

screenshots <- screenshots |>
  mutate(
    document = fs::path(source_dir, file),
    filename = fs::path(image_dir, paste0("figure-table-", id), ext = "png"),
    selector = paste0("#", id)
  )

# Do one
screenshots |>
  slice(10) |>
  rowwise() |>
  mutate(
    image = qmdshot(document, filename, selector)
  )

# Do all of them
screenshots <- screenshots |>
  rowwise() |>
  mutate(
    image = qmdshot(document, filename, selector)
  )
