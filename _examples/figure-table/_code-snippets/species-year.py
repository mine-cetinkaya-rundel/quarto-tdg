(
  pl.DataFrame(penguins)
 .group_by(['species', 'year'])
 .count()
 .pivot(index='species', columns='year', values='count')
 .pipe(GT)
 .cols_label(
     species="Species"
 )
)
