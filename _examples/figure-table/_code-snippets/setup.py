import polars as pl
from plotnine import *
from great_tables import GT
from palmerpenguins import load_penguins

theme_set(theme_classic())

penguin_colors = {
    'Adelie': '#FF8C00',
    'Chinstrap': '#A020F0',
    'Gentoo': '#008B8B'
}

penguins = load_penguins()
penguins = (pl.DataFrame(penguins)
    .drop_nulls("bill_depth_mm"))
