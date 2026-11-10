#| label: rate-plot
#| renderings: [light, dark]
#| fig-alt: A bar chart of on-time rates for five routes, all between 85% and 95%.
library(ggplot2)

p <- ggplot(trains, aes(x = route, y = rate)) +
  geom_col() +
  labs(x = NULL, y = "On-time rate (%)")

p + theme_minimal()
p + theme_minimal(ink = "white", paper = "#222222")
