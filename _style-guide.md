# Quarto: The Practical Guide - Style Guide

This style guide summarizes the writing conventions and Quarto syntax patterns used throughout "Quarto: The Practical Guide" by Mine Çetinkaya-Rundel and Charlotte Wickham.

---

## Writing Style

### Voice and Tone

- **Direct and instructional**: Use clear, straightforward language focused on teaching
- **Second person ("you")**: Address the reader directly throughout
- **Present tense**: Use present tense for instructions and explanations
- **Friendly but conversational**: Maintain an approachable tone that respects the reader's time
- **Concise**: Favor brevity while maintaining clarity
- **First person plural ("we")**: Use "we" to refer to the instructors (Mine and Charlotte)
- **Put the student first, not the tool**: Focus on what the reader can do, not what the tool can do

**Examples:**
- ✅ "You can create a link using the usual markdown syntax..."
- ✅ "In this chapter, you'll start with the minimal building blocks..."
- ✅ "We've organized this chapter to build progressively..."
- ✅ "You can write math using TeX syntax" (student-focused)
- ❌ "Quarto supports math equations using TeX syntax" (tool-focused)
- ❌ Avoid passive voice: "Links can be created..." (instead use "You can create links...")

### Structure and Organization

#### Chapter Organization
1. **Chapter title with identifier**: Start with a level-1 heading and cross-reference ID
2. **Overview section**: Begin chapters with an "Overview" section that:
   - Explains what the chapter covers
   - Provides context and motivation
   - Outlines the structure with forward references to sections
3. **Progressive complexity**: Move from simple to complex concepts
4. **Practical examples**: Include concrete, working examples throughout

#### Section Headings
- Use descriptive, action-oriented headings
- Include cross-reference identifiers for major sections
- Maintain consistent heading hierarchy (don't skip levels)

**Example structure:**
```markdown
# Chapter Title {#sec-chapter-name}

## Overview

Brief introduction explaining what this chapter covers...

In this chapter, you'll learn:

* First topic in @sec-first-topic
* Second topic in @sec-second-topic

## First Topic {#sec-first-topic}

Content...

### Subtopic

More specific content...
```

### Explanatory Patterns

#### Introducing New Concepts
1. **Define clearly**: Provide a clear definition when introducing new terms
2. **Show before tell**: Often present an example before explaining it
3. **Build incrementally**: Start with minimal examples, then add complexity
4. **Explain the "why"**: Don't just show syntax; explain when and why to use it

**Example pattern:**
```markdown
The simplest Quarto project that results in a website consists of 
a directory with two files:

- `index.qmd` that renders to `index.html`—the homepage.
  For illustration, we'll use a simple file with a `title` and 
  some placeholder text:
  
  [code example]

- A `_quarto.yml` file that contains:
  
  [code example]

The specification of `type: website` in `_quarto.yml` means when 
you render the project, Quarto identifies it as a website...
```

#### Presenting Examples

- **Annotate code blocks**: Use `filename` attribute to show which file code belongs to
- **Explain after showing**: Present code first, then explain what it does
- **Use realistic examples**: Prefer practical, real-world scenarios
- **Show output when relevant**: Include rendered results or describe expected output

### Lists and Enumerations

- Use bulleted lists for unordered items
- Use numbered lists for sequential steps or ordered items
- Use consistent punctuation (typically no periods for short items)
- Introduce lists with a colon when the introduction is a complete sentence
- Keep list items parallel in structure

**Examples:**
```markdown
In this chapter, you'll dive into the three big components of a website:

* Content: In @sec-website-structure you'll learn...
* Navigation: In @sec-websites-navigation you'll learn...
* Appearance: In @sec-websites-theme you'll learn...
```

### Cross-References and Links

- **Forward references**: Point readers to where topics will be covered in detail
- **Backward references**: Remind readers of previously covered material
- **Use descriptive link text**: Make clear what the link points to
- **Consistent reference style**: Use `@sec-`, `@fig-`, `@tbl-` prefixes consistently

**Examples:**
- "You'll learn more about [external links in the Quarto documentation](https://quarto.org/docs/...)"
- "Later in @sec-websites-navigation you'll learn about adding site navigation..."
- "Recall from @sec-authoring that..."

### Terminology

- **Bold** for emphasis on first use of important terms and for tool/language names (e.g., "...known as **hybrid navigation**")
- **Code formatting** (`backticks`) for:
  - File names: `_quarto.yml`, `index.qmd`
  - Code elements: `type: website`, `navbar`
  - Commands: `quarto render`, `quarto preview`
  - Extensions: `.qmd`, `.html`
  - URLs and paths: `_site/`, `{ base }/about.html`
- **Italics** for occasional emphasis (e.g., "...things you *do* want") - use sparingly
- **Tool/language capitalization**: Capitalize names such as Julia, Jupyter, Markdown, Pandoc, Knitr (use lower case only when talking about particular commands, e.g., "running the pandoc command")

#### Metadata Terminology

- The chunk at the top of a `.qmd` that starts and ends with `---` is called the **document header**.
- Refer to the keys that are set in YAML as **options**, not keys.
- In general, options that apply to a document (either set in the header, `_quarto.yml`, `_metadata.yml`, or on command line) are known as **metadata**.

**Examples:**
- "You set options for the whole document using YAML in the document header."
- "You set code cell options using YAML with hashpipe (or other language appropriate) comments at the top of a code cell."
- "You set project level options using YAML in `_quarto.yml`."

### Callouts

Use callouts to highlight important information:

- **Tip callouts** (`.callout-tip`): For helpful suggestions and best practices
- **Note callouts** (`.callout-note`): For important information to remember
- **Warning callouts** (`.callout-warning`): For potential pitfalls

**Format:**
```markdown
::: callout-tip

## Descriptive Title

Content of the callout...

:::
```

### Tables

- Use tables for reference information and comparisons
- Include descriptive captions with cross-reference IDs
- Use `tbl-colwidths` when needed to control column proportions
- Keep table content concise

**Example:**
```markdown
| Option | Description |
|:-------|:------------|
| `href` | Link to file... |
| `text` | Text to display... |

: Properties of navigation items {#tbl-nav-item}
```

---

## Quarto Syntax Style

### Document Headers (YAML)

```yaml
---
bibliography: references.bib
tbl-colwidths: [20, 80]
---
```

**Conventions:**
- Use quotes for titles with special characters
- Include only necessary metadata
- Keep YAML clean and minimal
- When giving an example of YAML that would be included in a document header, always include the opening and closing `---` delimiters

### Headings and Cross-References

```markdown
# Chapter Title {#sec-chapter-name}

## Section Title {#sec-section-name}

### Subsection Title
```

**Conventions:**
- Level-1 headings: `#sec-chapter-name` (chapter level)
- Level-2 headings: `#sec-section-name` (major sections)
- Level-3+ headings: Usually no ID unless specifically needed for cross-referencing
- Use descriptive, kebab-case identifiers
- Prefix section IDs with `sec-`
- Prefix figure IDs with `fig-`
- Prefix table IDs with `tbl-`

### Code Blocks

#### Non-executable code (for display only):

````markdown
```{.yaml filename="_quarto.yml"}
project:
  type: website
```
````

````markdown
```{.markdown filename="index.qmd"}
---
title: Home
---

Content here...
```
````

**Conventions:**
- Use language class: `.yaml`, `.markdown`, `.python`, `.r`, `.bash`
- Include `filename` attribute to show context
- Use `shortcodes="false"` when showing shortcode syntax literally

#### Executable code cells:

````markdown
```{python}
import pandas as pd
df = pd.read_csv("data.csv")
```
````

````markdown
```{r}
library(ggplot2)
ggplot(data, aes(x, y)) + geom_point()
```
````

### Figures

```markdown
![Caption text](images/filename.png){#fig-identifier fig-alt="Detailed description"}
```

**For complex figures with multiple panels:**

```markdown
::: {#fig-identifier layout-ncol=2}

![Panel A caption](image-a.png)

![Panel B caption](image-b.png)

Overall figure caption

:::
```

**Conventions:**
- Always include `fig-alt` for accessibility
- Use descriptive alt text that explains what's shown
- Store images in `images/` directory
- Use PNG format for screenshots
- Include figure captions that can stand alone

### Callouts

```markdown
::: callout-tip

## Optional Title

Content of the callout...

:::
```

```markdown
::: {.callout-note}

Content without a custom title...

:::
```

**Conventions:**
- Use level-2 heading (`##`) for callout titles
- Leave blank lines around callout content
- Choose appropriate callout type: `tip`, `note`, `warning`, `important`, `caution`

### Fenced Divs

```markdown
::: {#identifier .class-name}

Content inside the div...

:::
```

**For complex layouts:**

```markdown
::: {#fig-identifier layout-ncol=2}

::::: {}
Content for first column
:::::

::::: {}
Content for second column
:::::

Caption for the overall figure

:::
```

**Conventions:**
- Use more colons for nested divs (3, 4, 5 colons)
- Include identifiers when needed for cross-referencing
- Use classes for styling (`.rendered`, `.external`, etc.)

### Links

```markdown
[Link text](relative/path/to/file.qmd)
[Link text](/absolute/path/from/root.qmd)
[Link text](https://external-url.com)
[Link text](file.qmd#section-id)
[External link](https://url.com){.external target="_blank"}
```

**Conventions:**
- Use `.qmd` extension for internal links (Quarto handles conversion)
- Use absolute paths (starting with `/`) for content that might be included elsewhere
- Add `.external` class for external links
- Use `target="_blank"` to open in new tab when appropriate

### Cross-References

```markdown
See @sec-section-name for more details.
As shown in @fig-figure-name...
The options are listed in @tbl-table-name.
```

**Conventions:**
- Use `@` prefix for cross-references
- References automatically include appropriate text ("Section", "Figure", "Table")
- Works within a single document or within a book project
- Does NOT work across pages in a website project

### Lists

```markdown
Unordered list:

- First item
- Second item
  - Nested item
  - Another nested item
- Third item

Ordered list:

1. First step
2. Second step
3. Third step
```

**Conventions:**
- Use `-` for unordered lists (consistent throughout)
- Blank line before first list item
- Indent nested items with 2 spaces
- Can use `1.` for all numbered items (auto-renumbered)

### Directory Trees

Use the `.dir-str` class for showing directory structures:

````markdown
```{.dir-str}
project/
├── _quarto.yml
├── index.qmd
└── about.qmd
```
````

**Conventions:**
- Use tree characters: `├──`, `└──`, `│`
- Include trailing `/` for directories
- Align items consistently
- Add comments or annotations after items when helpful

### Includes

```markdown
{{< include _examples/path/to/file.yml >}}
```

**Conventions:**
- Store reusable examples in `_examples/` directory
- Use descriptive paths that mirror content structure
- Prefix with underscore to exclude from rendering

### Shortcodes

```markdown
{{< lipsum 1 >}}
```

**Conventions:**
- Use `shortcodes="false"` in code blocks when showing shortcode syntax literally
- Common shortcodes: `lipsum` for placeholder text

---

## Best Practices Summary

### Writing
1. Start with overview, build progressively
2. Show examples before or alongside explanations
3. Use forward and backward references liberally
4. Include practical, realistic examples
5. Explain both "how" and "why"
6. Use callouts for tips and important notes
7. Keep paragraphs focused and concise

### Syntax
1. Always include cross-reference IDs for major sections, figures, and tables
2. Use descriptive, consistent naming for IDs
3. Include `filename` attribute for code blocks
4. Provide `fig-alt` text for all images
5. Use appropriate code block classes (`.yaml`, `.markdown`, etc.)
6. Maintain consistent indentation and spacing
7. Use fenced divs for complex layouts
8. Store reusable content in `_examples/` directory

### Accessibility
1. Include descriptive alt text for all figures
2. Use semantic heading hierarchy
3. Provide descriptive link text
4. Use proper table headers
5. Include captions that can stand alone

---
