penguins |>
  ggplot(aes(x = bill_length_mm, y = bill_depth_mm)) +
  geom_point(aes(color = species)) +
  scale_color_manual(values = penguin_colors) +
  labs(x = "Bill Length (mm)", y = "Bill Depth (mm)")
