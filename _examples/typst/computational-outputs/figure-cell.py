#| label: fig-punctuality
#| fig-cap: On-time rate by route
#| fig-alt: A bar chart of on-time rates by route, showing values between roughly 85% and 95% across the Northern, Central, Circle, District, and Jubilee routes.
#| echo: false

from plotnine import ggplot, aes, geom_col, labs, theme_minimal, element_blank, theme

(
    ggplot(trains, aes(x="route", y="rate"))
    + geom_col(fill="#4e79a7")
    + labs(x=None, y="On-time rate (%)")
    + theme_minimal()
    + theme(axis_title_x=element_blank())
)
