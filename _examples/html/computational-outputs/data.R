routes <- c("Northern", "Central", "Circle", "District", "Jubilee")
on_time <- c(142, 98, 201, 87, 165)
total   <- c(154, 110, 215, 95,  178)

trains <- data.frame(
  route   = factor(routes, levels = routes),
  on_time = on_time,
  total   = total,
  rate    = on_time / total * 100
)
