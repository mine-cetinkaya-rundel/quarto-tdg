library(gt)

set.seed(1)
routes <- c("Northern", "Central", "Circle", "District", "Jubilee",
            "Victoria", "Piccadilly", "Bakerloo", "Hammersmith", "Metropolitan",
            "Waterloo", "Elizabeth", "Overground", "DLR", "Trams",
            "Chiltern", "Thameslink", "Southern", "Southeastern", "Southwestern",
            "Greater Anglia", "East Midlands", "Avanti", "LNER", "CrossCountry",
            "GWR", "TransPennine", "Northern Rail", "ScotRail", "TfW")

long_trains <- data.frame(
  route   = routes,
  on_time = sample(80:200, length(routes)),
  total   = sample(100:230, length(routes))
)
long_trains$rate <- round(long_trains$on_time / long_trains$total * 100, 1)

gt(long_trains) |>
  cols_label(route = "Route", on_time = "On time", total = "Total", rate = "On-time rate (%)") |>
  fmt_number(columns = rate, decimals = 1) |>
  data_color(columns = rate, palette = "magma", reverse = TRUE)
