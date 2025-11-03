---
title: "Untitled"
format: html
fig-width: 2
fig-height: 5
keep-md: true
---

::: {#c7f32567 .cell execution_count=1}
``` {.python .cell-code}
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
```
:::


Use defaults

::: {#8073a3ed .cell execution_count=2}
``` {.python .cell-code}
import seaborn as sns

penguins = sns.load_dataset("penguins")

sns.countplot(data=penguins, x="island", hue="species", dodge=False)
```

::: {.cell-output .cell-output-stderr}
```
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/_base.py:948: FutureWarning: When grouping with a length-1 list-like, you will need to pass a length-1 tuple to get_group in a future version of pandas. Pass `(name,)` instead of `name` to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/categorical.py:1273: FutureWarning: DataFrameGroupBy.apply operated on the grouping columns. This behavior is deprecated, and in a future version of pandas the grouping columns will be excluded from the operation. Either pass `include_groups=False` to exclude the groupings or explicitly select the grouping columns after groupby to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/_base.py:948: FutureWarning: When grouping with a length-1 list-like, you will need to pass a length-1 tuple to get_group in a future version of pandas. Pass `(name,)` instead of `name` to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/categorical.py:1273: FutureWarning: DataFrameGroupBy.apply operated on the grouping columns. This behavior is deprecated, and in a future version of pandas the grouping columns will be excluded from the operation. Either pass `include_groups=False` to exclude the groupings or explicitly select the grouping columns after groupby to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/_base.py:948: FutureWarning: When grouping with a length-1 list-like, you will need to pass a length-1 tuple to get_group in a future version of pandas. Pass `(name,)` instead of `name` to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/categorical.py:1273: FutureWarning: DataFrameGroupBy.apply operated on the grouping columns. This behavior is deprecated, and in a future version of pandas the grouping columns will be excluded from the operation. Either pass `include_groups=False` to exclude the groupings or explicitly select the grouping columns after groupby to silence this warning.
```
:::

::: {.cell-output .cell-output-display}
![](python_files/figure-html/cell-3-output-2.png){width=221 height=429}
:::
:::


::: {#847950bd .cell execution_count=3}
``` {.python .cell-code}
import matplotlib as mpl
mpl.rcParams['figure.figsize'] = (12, 3)

sns.countplot(data=penguins, x="island", hue="species", dodge=False)
```

::: {.cell-output .cell-output-stderr}
```
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/_base.py:948: FutureWarning: When grouping with a length-1 list-like, you will need to pass a length-1 tuple to get_group in a future version of pandas. Pass `(name,)` instead of `name` to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/categorical.py:1273: FutureWarning: DataFrameGroupBy.apply operated on the grouping columns. This behavior is deprecated, and in a future version of pandas the grouping columns will be excluded from the operation. Either pass `include_groups=False` to exclude the groupings or explicitly select the grouping columns after groupby to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/_base.py:948: FutureWarning: When grouping with a length-1 list-like, you will need to pass a length-1 tuple to get_group in a future version of pandas. Pass `(name,)` instead of `name` to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/categorical.py:1273: FutureWarning: DataFrameGroupBy.apply operated on the grouping columns. This behavior is deprecated, and in a future version of pandas the grouping columns will be excluded from the operation. Either pass `include_groups=False` to exclude the groupings or explicitly select the grouping columns after groupby to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/_base.py:948: FutureWarning: When grouping with a length-1 list-like, you will need to pass a length-1 tuple to get_group in a future version of pandas. Pass `(name,)` instead of `name` to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/categorical.py:1273: FutureWarning: DataFrameGroupBy.apply operated on the grouping columns. This behavior is deprecated, and in a future version of pandas the grouping columns will be excluded from the operation. Either pass `include_groups=False` to exclude the groupings or explicitly select the grouping columns after groupby to silence this warning.
```
:::

::: {.cell-output .cell-output-display}
![](python_files/figure-html/cell-4-output-2.png){width=965 height=282}
:::
:::


Reset defaults

::: {#84d8a951 .cell execution_count=4}
``` {.python .cell-code}
with mpl.rc_context({'figure.figsize': (12, 3)}):
    sns.countplot(data=penguins, x="island", hue="species", dodge=False)
```

::: {.cell-output .cell-output-stderr}
```
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/_base.py:948: FutureWarning: When grouping with a length-1 list-like, you will need to pass a length-1 tuple to get_group in a future version of pandas. Pass `(name,)` instead of `name` to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/categorical.py:1273: FutureWarning: DataFrameGroupBy.apply operated on the grouping columns. This behavior is deprecated, and in a future version of pandas the grouping columns will be excluded from the operation. Either pass `include_groups=False` to exclude the groupings or explicitly select the grouping columns after groupby to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/_base.py:948: FutureWarning: When grouping with a length-1 list-like, you will need to pass a length-1 tuple to get_group in a future version of pandas. Pass `(name,)` instead of `name` to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/categorical.py:1273: FutureWarning: DataFrameGroupBy.apply operated on the grouping columns. This behavior is deprecated, and in a future version of pandas the grouping columns will be excluded from the operation. Either pass `include_groups=False` to exclude the groupings or explicitly select the grouping columns after groupby to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/_base.py:948: FutureWarning: When grouping with a length-1 list-like, you will need to pass a length-1 tuple to get_group in a future version of pandas. Pass `(name,)` instead of `name` to silence this warning.
/Users/charlottewickham/Documents/posit/quarto-tdg/.venv/lib/python3.12/site-packages/seaborn/categorical.py:1273: FutureWarning: DataFrameGroupBy.apply operated on the grouping columns. This behavior is deprecated, and in a future version of pandas the grouping columns will be excluded from the operation. Either pass `include_groups=False` to exclude the groupings or explicitly select the grouping columns after groupby to silence this warning.
```
:::

::: {.cell-output .cell-output-display}
![](python_files/figure-html/cell-5-output-2.png){width=965 height=282}
:::
:::


`

::: {#2706b32d .cell execution_count=5}
``` {.python .cell-code}
(
    ggplot(penguins, aes(x="island", fill="species"))
    + geom_bar()
    + scale_fill_manual(values=penguin_colors)
    + labs(x="Island", y="Count")
    + theme(figure_size=(4, 6))
)
```

::: {.cell-output .cell-output-display}
![](python_files/figure-html/cell-6-output-1.png){width=384 height=576}
:::
:::


