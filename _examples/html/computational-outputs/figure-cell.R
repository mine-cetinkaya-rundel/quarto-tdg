#| label: fig-punctuality
#| fig-cap: On-time rate by route
#| fig-alt: A bar chart of on-time rates by route, showing values between roughly 85% and 95% across the Northern, Central, Circle, District, and Jubilee routes.
#| echo: false

library(ggplot2)

ggplot(trains, aes(x = route, y = rate)) +
  geom_col(fill = "#4e79a7") +
  labs(x = NULL, y = "On-time rate (%)") +
  theme_minimal()
