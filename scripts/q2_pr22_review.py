"""Build a GitHub review with q2 suggestions for PR #22 (presentations.qmd)."""
import json
import sys

src = open(sys.argv[1]).read().split("\n")
line = lambda n: src[n - 1]

BODY = """Suggestions to make presentations.qmd valid in Quarto 2 (q2). Each one also works in Quarto 1: I rendered the chapter with both and compared the output.

- **Attribute order** (3): q2 rejects a class after a `key=value` pair (Q-2-3), which stops the render. Order is id, classes, then key=value.
- **`engine: markdown` and single braces** (8 cells): q2 displays `{{python}}` with both braces (Q-2-50). The chapter runs no code, so with `engine: markdown` Quarto 1 leaves `{python}` cells alone and both versions display them the same. Apply these together: single braces without the engine would make Quarto 1 run the cells.
- **`code-line-numbers`** (2): not a q2 issue. Cell options are YAML, so `#| code-line-numbers="2,4"` should be `#| code-line-numbers: "2,4"` (in Quarto 1 too).

Not suggestible: once the engine is `markdown`, `_freeze/presentations/` is unused and can be deleted. It is also stale (made from an older version of the chapter)."""

comments = []


def suggest(start, end, new, note=""):
    c = {"path": "presentations.qmd", "line": end, "side": "RIGHT",
         "body": (note + "\n\n" if note else "") + "`````suggestion\n" + new + "\n`````"}
    if start != end:
        c["start_line"] = start
        c["start_side"] = "RIGHT"
    comments.append(c)


suggest(1, 1, "---\nengine: markdown\n---\n\n" + line(1),
        "The chapter runs no code. Needed for the single-brace cells below.")

for n in (29, 54, 66):
    old = line(n)
    a = old.index(" filename=")
    b = old.index(" .code-overflow-wrap")
    new = old[:a] + " .code-overflow-wrap" + old[a:b] + "}"
    suggest(n, n, new, "q2 (Q-2-3): class before key=value.")

opts = {442: '#| code-line-numbers: "2,4"', 454: '#| code-line-numbers: "|1|2|3"'}
for n in (441, 453, 511, 543, 553, 564, 575, 610):
    new = line(n).replace("{{", "{").replace("}}", "}")
    if n + 1 in opts:
        suggest(n, n + 1, new + "\n" + opts[n + 1],
                "Single braces (needs `engine: markdown`), and YAML syntax for the cell option.")
    else:
        suggest(n, n, new, "Single braces (needs `engine: markdown`).")

json.dump({"commit_id": sys.argv[2], "event": "COMMENT", "body": BODY,
           "comments": comments}, open(sys.argv[3], "w"), indent=1)
print(len(comments), "comments")
