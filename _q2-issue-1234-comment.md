A related point. The book guide says a chapter is unnumbered if its "front-matter `title:` or its first heading carries the `.unnumbered` class". That suggests attributes work in a front matter title, so I'd expect this to give the chapter an id too:

```yaml
---
title: Introduction {#sec-intro}
---
```

That would be a nice preferred syntax, since then the sidebar fix here isn't needed. But in q2 0.45.0 (HTML book) neither attribute works:

| Front matter | q2 0.45.0 | Quarto 1.11.9 |
|---|---|---|
| `title: Preface {.unnumbered}` | numbered "1 Preface" | numbered "1 Preface {.unnumbered}" |
| `title: Introduction {#sec-intro}` | `@sec-intro` unresolved | `@sec-intro` unresolved |

Tagging the title as markdown doesn't help either. `!md "Preface {.unnumbered}"`, `!md "Introduction {#sec-intro}"`, and the span forms `!md "[Preface]{.unnumbered}"` and `!md "[Introduction]{#sec-intro}"` all give the same q2 result as the table.

q2 removes the `{...}` from the displayed title but then ignores it. So today the only way to make a chapter unnumbered or give it an id is a first heading: `# Introduction {#sec-intro}`.
