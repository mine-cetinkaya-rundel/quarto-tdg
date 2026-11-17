# Make the book's markdown valid in Quarto 2

Quarto 2 (q2) has a stricter markdown parser than Quarto 1. This PR changes the book so that its chapters parse in q2 and still render the same in Quarto 1. It also changes the syntax that the book teaches when that syntax fails in q2.

Tested with q2 v0.45.0 and Quarto 1.11.9. The q2 render status of the whole book, and the q2 problems that are not in the book, are in #ISSUE.

## Two goals

1. The book renders with q2.
2. The book doesn't teach syntax that fails in q2. If an example fails in q2, the lesson changes to syntax that works in both versions. If no such syntax exists, it is recorded in `_q2.md`.

## Fix patterns

Each pattern works in Quarto 1 and q2. For each one, I rendered a small file with both versions and compared the HTML.

| q2 problem | Fix |
|---|---|
| A class after `key=value` (Q-2-3), or a class before an id (Q-2-55) | Order the attributes as id, classes, then `key=value`. |
| An unquoted value with commas, `aligns=l,l,l` | Quote it: `aligns="l,l,l"`. |
| A list item with an empty first line, then a code block (list-table cells) | Start the fence on the `- ` line. |
| `***bold italics***` (Q-2-32) | `_**bold italics**_`. The taught italics are now `_italics_` to match. |
| ```` ```{{r}} ```` in a chapter that runs no code: q2 shows the doubled braces (Q-2-50) | Add `engine: markdown`, then use single braces. Without the engine, Quarto 1 runs the quoted cells. |
| Bare `{ IMAGE }` placeholders (Q-2-41) | Bare words: `IMAGE`. |
| `\index{x}` in prose (Q-2-41) | `` `\index{x}`{=latex} ``. |
| A shortcode in inline code: q2 expands it | `` `{{{< shortcode-name >}}}` `` |

## Changes by chapter

- **authoring:** attribute order, quoted `aligns`, list-table cells, bold italics, single braces in quoted cells, the escaped shortcode example. `_examples/authoring/tables/list-table-complicated.qmd` had the empty-first-line cells too.
- **writing:** `_italics_` in the first example and the syntax list. One attribute order. `engine: markdown`.
- **typst:** 15 attribute orders. `engine: markdown` and single braces, including the quoted raw block `{=typst}`.
- **projects:** id before class on a callout, two attribute orders. Also a `kbd` typo that was wrong in Quarto 1 too: `linux=win=Shift-Control-B` is now `linux=Shift-Control-B`.
- **yaml:** `\index{}` as raw LaTeX. `engine: markdown` and single braces.
- **websites:** 6 × `\index{}` as raw LaTeX.
- **look-under-hood:** the PDF screenshot was a figure inside a link to `_examples/look-under-hood/render-process.pdf`. That file doesn't exist, so the link was broken. It is now a plain figure. q2 also drops the caption from a linked figure.

## `_q2.md`

A new page, we might expose to, readers. It lists the taught syntax that has no form that works in both versions, and shows the q2 syntax:

- Footnotes with more than one paragraph. q2 needs a fenced div, `::: ^longnote`. The example in `_examples/authoring/footnotes/long.md` still fails in q2, on purpose.
- Math macros. In q2, `\newcommand` works only inside the math expression that uses it.

## Not in this PR

Fixes for chapters that other open PRs change are on those branches:

- html: #37
- figure-table, figure-table-computational: #28
- presentations: suggestions in a review on #22

## Before merge

- [ ] projects.qmd runs code, so it needs a new freeze. Run `renv::restore()` in this branch, render projects.qmd, and commit `_freeze/projects/`.
- [ ] Render the book with Quarto 1.
