#| label: rate-plot
#| renderings: [light, dark]
#| fig-alt: A bar chart of on-time rates for five routes, all between 85% and 95%.
from plotnine import *

p = (
    ggplot(trains, aes(x="route", y="rate"))
    + geom_col()
    + labs(x="", y="On-time rate (%)")
    + theme_minimal()
)
dark = theme(
    plot_background=element_rect(fill="#222222"),
    text=element_text(color="white"),
    panel_grid=element_line(color="#444444"),
)

p.show()
(p + dark).show()
