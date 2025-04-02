(
  pl.DataFrame(penguins)
 .group_by('species')
 .count()
 .pipe(GT)
)
