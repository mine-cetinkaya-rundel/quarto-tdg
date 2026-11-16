library(tidyverse)
library(gt)
library(palmerpenguins)

theme_set(theme_classic())

penguin_colors <- c(
  Adelie = "#FF8C00",
  Chinstrap = "#A020F0",
  Gentoo = "#008B8B"
)

penguins <- penguins |>
  drop_na(bill_depth_mm)
