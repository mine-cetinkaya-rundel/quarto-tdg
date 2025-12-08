library(here)
library(fs)
library(dplyr)

source(here("R", "qmdshot.R"))

source_dir <- here("_examples", "authoring")
image_dir <- here("images")


# Input list of file, ID pairs
# fmt: skip
screenshots <- tribble(
  ~file,                      ~id,
  "tables/markdown-table.qmd"          , "tbl-perf",
)

screenshots <- screenshots |>
  mutate(
    document = fs::path(source_dir, file),
    filename = fs::path(image_dir, paste0("authoring-", id), ext = "png"),
    selector = paste0("#", id)
  )

# Do all of them
screenshots <- screenshots |>
  rowwise() |>
  mutate(
    image = qmdshot(document, filename, selector)
  )
