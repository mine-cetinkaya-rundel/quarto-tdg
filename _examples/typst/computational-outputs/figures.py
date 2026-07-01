from plotnine import ggplot, aes, geom_col, labs, theme_minimal, element_blank, theme

(
    ggplot(trains, aes(x="route", y="rate"))
    + geom_col(fill="#4e79a7")
    + labs(x=None, y="On-time rate (%)")
    + theme_minimal()
    + theme(axis_title_x=element_blank())
)
