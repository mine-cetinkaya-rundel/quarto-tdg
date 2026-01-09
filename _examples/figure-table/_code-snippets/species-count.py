(
  pl.DataFrame(penguins)
 .group_by('species')
 .len()
 .pipe(GT)
)
