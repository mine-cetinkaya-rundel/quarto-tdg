penguins |>
  arrange(desc(body_mass_g)) |>
  slice_head(n = 5) |>
  select(species, sex, island, body_mass_g, flipper_length_mm) |>
  gt() |>
  cols_label(
    body_mass_g = "Body Mass (g)",
    flipper_length_mm = "Flipper Length (mm)"
  )
