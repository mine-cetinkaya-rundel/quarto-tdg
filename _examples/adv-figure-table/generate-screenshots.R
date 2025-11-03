library(here)
library(fs)
library(dplyr)

source(here("R", "qmdshot.R"))

source_dir <- here("_examples", "adv-figure-table")
image_dir <- here("images")


# Input list of file, ID pairs
# fmt: skip
screenshots <- tribble(
  ~file,                      ~id,
  "captions/r.qmd"          , "captions-subcaptions",
  "captions/r.qmd"          , "captions-subcaptions-reference",
  "captions/location-bottom.qmd"          , "captions-location-bottom",
  "captions/location-margin.qmd"          , "captions-location-margin",
  "captions/location-top.qmd"          , "captions-location-top",
)

screenshots <- screenshots |>
  mutate(
    document = fs::path(source_dir, file),
    filename = fs::path(image_dir, paste0("adv-figure-table-", id), ext = "png"),
    selector = paste0("#", id)
  )

# Do one
screenshots |>
  slice(10:12) |>
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
