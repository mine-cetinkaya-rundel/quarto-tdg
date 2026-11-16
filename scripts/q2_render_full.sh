#!/bin/zsh
# Full q2 render of the book, for the content check against Quarto 1.
# - Comments out the long.md includes (q2 rejects that example on purpose).
# - Activates the uv environment, so q2's Jupyter finds the Python packages.
# - Restores authoring.qmd afterwards.
# Output: _book (q2), errors in _q2/render.jsonl.
set -u
cd "${0:A:h}/.."
sed -i '' 's|^{{< include _examples/authoring/footnotes/long.md >}}|<!-- long.md skipped for q2 -->|' authoring.qmd
source .venv/bin/activate
q2 render --profile q2 --to html --json-errors 2> _q2/render.jsonl
rc=$?
git checkout -q authoring.qmd
echo "q2 exit: $rc"
git status --short | grep -v '^??'
