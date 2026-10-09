from tabulate import tabulate
from IPython.display import Markdown

summary_table = (
  pl.DataFrame(penguins)
 .group_by('species')
 .len()
)
Markdown(tabulate(summary_table.to_pandas(), 
  tablefmt='pipe', headers='keys', showindex=False))
