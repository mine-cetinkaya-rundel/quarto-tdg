import seaborn as sns
import matplotlib.pyplot as plt
from palmerpenguins import load_penguins

# Load the data
penguins = load_penguins()

# Define the same color palette
penguin_colors = {
    'Adelie': '#FF8C00',    # darkorange
    'Chinstrap': '#800080', # purple
    'Gentoo': '#008B8B'     # cyan4
}

g = sns.scatterplot(
    data=penguins,
    x='bill_length_mm',
    y='bill_depth_mm',
    hue='species',
    palette=penguin_colors
)
g.set(xlabel='Bill Length (mm)', ylabel='Bill Depth (mm)')


# Example 1: Scatter plot of body mass vs flipper length
sns.scatterplot(
    data=penguins,
    x='body_mass_g',
    y='flipper_length_mm',
    hue='species',
    palette=penguin_colors
)
plt.xlabel('Body Mass (g)')
plt.ylabel('Flipper Length (mm)')
plt.show()

# Example 2: Histograms by species


# Example 3: Bar plot of species counts by island
plt.figure(figsize=(10, 6))
sns.histplot(
    data=penguins,
    x='island',
    hue='species',
    palette=penguin_colors,
    multiple="stack",
    stat="count",
    shrink=0.8  # This adds space between bars (0.8 = 80% of original width)
)
plt.xlabel('Island')
plt.ylabel('Count')
plt.show()