penguins |>
  count(species, year) |>
  pivot_wider(names_from = year, values_from = n) |>
  gt() |>
  cols_label(
    species = "Species"
  )
