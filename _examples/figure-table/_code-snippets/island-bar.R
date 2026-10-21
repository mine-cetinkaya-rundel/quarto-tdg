penguins |>
  ggplot(aes(x = island, fill = species)) +
  geom_bar(position = "stack") +
  scale_fill_manual(values = penguin_colors) +
  labs(x = "Species", y = "Count")
