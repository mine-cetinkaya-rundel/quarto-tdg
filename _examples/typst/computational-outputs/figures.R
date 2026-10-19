library(ggplot2)

ggplot(trains, aes(x = route, y = rate)) +
  geom_col(fill = "#4e79a7") +
  labs(x = NULL, y = "On-time rate (%)") +
  theme_minimal()
