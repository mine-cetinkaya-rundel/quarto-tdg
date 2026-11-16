"""Extract fenced markdown/qmd blocks from a chapter into separate files.

Usage: python3 scripts/q2_extract_examples.py CHAPTER.qmd OUTDIR

Writes OUTDIR/<line>.qmd for each block (line = opening fence line) and
lists include shortcodes found in the chapter.
"""
import os
import re
import sys

chapter, outdir = sys.argv[1], sys.argv[2]
os.makedirs(outdir, exist_ok=True)
lines = open(chapter).read().split('\n')

opener = re.compile(r'^(\s*)(`{3,}|~{3,})\s*\{?\.?(markdown|qmd)\b')
i = 0
while i < len(lines):
    m = opener.match(lines[i])
    if not m:
        i += 1
        continue
    indent, fence = m.group(1), m.group(2)
    start = i
    body = []
    i += 1
    while i < len(lines):
        s = lines[i]
        if s.strip().startswith(fence) and s.strip().strip(fence[0]) == '':
            break
        body.append(s[len(indent):] if s.startswith(indent) else s)
        i += 1
    text = '\n'.join(body)
    if not re.fullmatch(r'\s*\{\{< include [^>]+>\}\}\s*', text):
        open(os.path.join(outdir, f'{start + 1}.qmd'), 'w').write(text + '\n')
    i += 1

for n, s in enumerate(lines, 1):
    for inc in re.findall(r'\{\{< include ([^ >]+) >\}\}', s):
        print(f'include {n}: {inc}')
