## Title

Book sidebar shows file names for chapters titled by a heading

## Body

In a book, q2 0.45.0 labels a chapter in the sidebar only if it has a front matter `title:`. A chapter titled by its first heading shows its file name (`intro.html`). Quarto 1 uses the heading.

This hits most books: only a heading can carry a chapter's cross-reference id (`# Introduction {#sec-intro}`), so most chapters are titled that way.

### Reproduce

```yaml
# _quarto.yml
project:
  type: book
book:
  title: Test
  chapters:
    - index.qmd      # "# Preface {.unnumbered}"
    - intro.qmd      # "# Introduction {#sec-intro}"
    - yamltitle.qmd  # front matter "title: Has YAML title"
```

`q2 render --to html`, then look at the sidebar in `_book/intro.html`:

| Chapter | Quarto 1.11.9 | q2 0.45.0 |
|---|---|---|
| `index.qmd` | Preface | index.html |
| `intro.qmd` | 1 Introduction | intro.html |
| `yamltitle.qmd` | 2 Has YAML title | 2 Has YAML title |

The chapter pages themselves are correct, and so is the numbering. `chapter_is_numbered` already reads the first heading ([render_item.rs#L393-L415](https://github.com/quarto-dev/q2/blob/8e2ff6c652c5b2da2ae03acd29bc4eb71e6593de/crates/quarto-core/src/project/book/render_item.rs#L393-L415)), but the sidebar labels don't.

macOS 27.2.1. AI-assisted, grounded in a local clone at `v0.45.0`.
