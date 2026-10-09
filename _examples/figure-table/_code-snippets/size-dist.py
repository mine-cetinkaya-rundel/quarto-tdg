(
    ggplot(penguins, aes(x="body_mass_g", fill="species"))
    + geom_histogram(bins=30)
    + facet_grid("species ~ .")
    + scale_fill_manual(values=penguin_colors)
    + labs(x="Body Mass (g)")
)
