from great_tables import GT

(
    GT(trains)
    .cols_label(route="Route", on_time="On time", total="Total", rate="On-time rate (%)")
    .fmt_number(columns="rate", decimals=1)
    .data_color(columns="rate", palette="magma", reverse=True)
)
