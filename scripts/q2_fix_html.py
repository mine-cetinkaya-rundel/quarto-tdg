"""One-off q2 fixes for html.qmd (see _q2-migration-notes.md)."""
import re
import sys

path = sys.argv[1]
text = open(path).read()

# Q-2-3: class after key=value in code-block attributes
text, n1 = re.subn(r'(\{\.\w+) (filename="[^"]*") (\.code-overflow-wrap)\}',
                   r'\1 \3 \2}', text)
# Unquoted comma values
text, n2 = re.subn(r'aligns=([lcr](?:,[lcr])+)', r'aligns="\1"', text)
# Empty first line in a list item, followed by a blank line and a fence
text, n3 = re.subn(r'(?m)^(  - ) *\n\n {4}(```)', r'\1\2', text)

open(path, 'w').write(text)
print(n1, n2, n3)
