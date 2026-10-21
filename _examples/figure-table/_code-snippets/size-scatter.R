penguins |>
  ggplot(aes(x = body_mass_g, y = flipper_length_mm)) +
  geom_point(aes(color = species)) +
  scale_color_manual(values = penguin_colors) +
  labs(x = "Body Mass (g)", y = "Flipper Length (mm)")
