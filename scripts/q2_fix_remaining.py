"""q2 fixes for presentations.qmd, websites.qmd and writing.qmd."""
import re
from pathlib import Path


def reorder(m):
    # {.lang filename="x" .cls} -> {.lang .cls filename="x"}
    return "{" + m.group(1) + " " + m.group(3) + " " + m.group(2) + "}"


ATTR = re.compile(r'\{(\.[\w-]+) ((?:[\w-]+="[^"]*" ?)+?) ?(\.[\w-]+)\}')


def add_engine(text):
    if text.startswith("---\n"):
        return text.replace("---\n", "---\nengine: markdown\n", 1)
    return "---\nengine: markdown\n---\n\n" + text


for name in ["presentations.qmd", "writing.qmd"]:
    p = Path(name)
    t = p.read_text()
    t = ATTR.sub(reorder, t)
    t = re.sub(r"\{\{(r|python)\}\}", r"{\1}", t)
    t = add_engine(t)
    p.write_text(t)

p = Path("websites.qmd")
t = p.read_text()
t = re.sub(r"(?<!`)\\index\{([^}]*)\}", r"`\\index{\1}`{=latex}", t)
p.write_text(t)
