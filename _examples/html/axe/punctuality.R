# Creates punctuality.png, the image used in report.qmd.
# Run from this directory: Rscript punctuality.R

library(ggplot2)

routes <- c("Northern", "Central", "Circle", "District", "Jubilee")
on_time <- c(142, 98, 201, 87, 165)
total   <- c(154, 110, 215, 95,  178)

trains <- data.frame(
  route   = factor(routes, levels = routes),
  on_time = on_time,
  total   = total,
  rate    = on_time / total * 100
)

p <- ggplot(trains, aes(x = route, y = rate)) +
  geom_col(fill = "#4e79a7") +
  labs(x = NULL, y = "On-time rate (%)") +
  theme_minimal()

ggsave("punctuality.png", p, width = 8, height = 2.4, dpi = 150, bg = "white")
