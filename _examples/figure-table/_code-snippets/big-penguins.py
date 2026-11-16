(pl.DataFrame(penguins)
 .sort("body_mass_g", descending=True)
 .head(5)
 .select(["species", "sex", "island", "body_mass_g", "flipper_length_mm"])
 .pipe(GT)
 .cols_label(
     body_mass_g="Body Mass (g)",
     flipper_length_mm="Flipper Length (mm)"
 )
)