"""Compare the content of a Quarto 1 book render with a q2 book render.

Usage: python3 scripts/q2_compare_books.py Q1_DIR Q2_DIR [chapter.html ...]

For each chapter, counts structural elements in <main> and diffs the words of
the main text, so content that q2 dropped (or added) shows up.
"""
import difflib
import re
import sys
from pathlib import Path

from bs4 import BeautifulSoup

q1_dir, q2_dir = Path(sys.argv[1]), Path(sys.argv[2])
pages = sys.argv[3:] or sorted(p.name for p in q1_dir.glob("*.html"))


def main_of(path):
    soup = BeautifulSoup(path.read_text(), "html.parser")
    main = soup.find("main") or soup.body
    for el in main.select("script, style, nav, .quarto-title-meta, #quarto-appendix"):
        el.decompose()
    return main


def counts(main):
    return {
        "h2-h4": len(main.select("h2, h3, h4")),
        "pre": len(main.select("pre")),
        "table": len(main.select("table")),
        "tr": len(main.select("tr")),
        "callout": len(main.select(".callout")),
        "img": len(main.select("img, svg")),
        "a": len([a for a in main.select("a[href]") if not re.match(r"#cb\d+-\d+$", a["href"])]),
        "li": len(main.select("li")),
        "fn": len(main.select("[role=doc-noteref], .footnote-ref")),
        "math": len(main.select(".math")),
        "?@ unresolved": len(re.findall(r"\?@[\w-]+", main.get_text())),
    }


def words(main):
    # Code: join spans with no separator, so highlighting doesn't split tokens.
    for pre in main.select("pre"):
        pre.replace_with(" " + pre.get_text("") + " ")
    text = main.get_text(" ")
    return re.findall(r"\S+", text)


for page in pages:
    p1, p2 = q1_dir / page, q2_dir / page
    if not p2.exists():
        print(f"## {page}: MISSING in q2\n")
        continue
    m1, m2 = main_of(p1), main_of(p2)
    c1, c2 = counts(m1), counts(m2)
    w1, w2 = words(m1), words(m2)
    diffs = {k: (c1[k], c2[k]) for k in c1 if c1[k] != c2[k]}
    print(f"## {page}: words {len(w1)} -> {len(w2)}")
    for k, (a, b) in diffs.items():
        print(f"  {k}: {a} -> {b}")
    sm = difflib.SequenceMatcher(None, w1, w2, autojunk=False)
    missing = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag in ("delete", "replace") and i2 - i1 >= 4:
            missing.append(" ".join(w1[i1:i2])[:200])
    for m in missing[:15]:
        print(f"  - q1 only: {m}")
    if len(missing) > 15:
        print(f"  ... {len(missing) - 15} more runs")
    print()
