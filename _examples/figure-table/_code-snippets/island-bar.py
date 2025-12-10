(
    ggplot(penguins, aes(x="island", fill="species"))
    + geom_bar()
    + scale_fill_manual(values=penguin_colors)
    + labs(x="Island", y="Count")
)
