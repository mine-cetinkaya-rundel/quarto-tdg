# Book Restructure Progress

Tracking progress on restructuring the book to match the plan in `_reboot.md`.

## Status: Structure Created

### Completed
- [x] `_quarto.yml` updated with new chapter structure
- [x] New chapter stub files created
- [x] New part intro files created
- [x] Split authoring.qmd → writing.qmd (essentials copied, original kept intact)
- [x] Created options.qmd (new intro chapter, not a split from yaml.qmd)
- [x] Split publishing.qmd → sharing.qmd (basics copied, original kept intact)

## Source Files Overview

| File | Lines | Current Branch |
|------|-------|----------------|
| authoring.qmd | ~1104 | restructure (current) |
| yaml.qmd | ~873 | restructure (current) |
| look-under-hood.qmd | ~817 | restructure (current) |
| projects.qmd | ~521 | restructure (current) |
| publishing.qmd | ~318 | restructure (current) |
| tools.qmd | ~166 | restructure (current) |
| websites.qmd | ~1752 | restructure (current) |
| presentations.qmd | ~58 | restructure (current) |
| quarto.qmd | ~50 | restructure (current) |

---

## Proposed Section Mapping

### Part I: Getting Started

#### Ch 1: Welcome to Quarto
**Target:** What is Quarto, installation, first document (~100-150 lines)
**Source:** `quarto.qmd` (expand)

Current headings in `quarto.qmd`:
- `# Quarto`
- `## What is Quarto?`
- `## Installation`
- `## Tools for authoring`

**Action:** Expand with first document walkthrough

---

#### Ch 2: Your Quarto Workflow
**Target:** Tools (CLI, IDE basics), preview, render (~150-200 lines)
**Source:** `tools.qmd` (condense)

Current headings in `tools.qmd`:
- `# Tools`
- `## Whole game`
  - `### Rendering`
- `## RStudio`
  - `### New file...`
  - `### Editors`
  - `### Running code`
  - `### Rendering`
- `## JupyterLab`
- `## VSCode`
- `## Choosing a tool`

**Action:** Condense, focus on workflow not tool comparison

---

#### Ch 3: Writing Content
**Target:** Markdown essentials - headings, text, lists, links, images
**Source:** `authoring.qmd` (split - essentials portion)

Sections to INCLUDE (essentials):
- `## Markdown text`
- `## Sections` / `## Section` / `### Subsection`
- `## Paragraphs`
- `## Text` (basic formatting)
- `## Lists`
- `## Images and figures` (basics only)

Sections to DEFER to Ch 7 (depth):
- `## Code blocks`
- `## Tables` (all subsections)
- `## Mathematical equations`
- `## Cross-references`
- `## Citations`
- `## Footnotes`
- `## Fenced divs`
- `## Callouts`
- `## Layout`
- `## Raw blocks`
- `## Shortcodes`
- `## Includes`

**Note:** Links are covered within basic text formatting, no separate section needed

---

#### Ch 4: Adding Code
**Target:** Code cells, basic execution options (echo, eval, output) (~200-250 lines)
**Source:** NEW chapter

Possible content from existing:
- `yaml.qmd` → `## Execution options` (basic subset)
- `look-under-hood.qmd` → execution concepts (simplified)

**Note:** Briefly mention difference between executable code cells and code blocks (code blocks covered in Ch 7)

---

#### Ch 5: Setting Options
**Target:** YAML basics - document options, where to put them
**Source:** NEW chapter (not a split from yaml.qmd)

**Status: COMPLETE**

New introductory chapter covering:
- Three places to set options (document header, format key, code cells)
- YAML syntax essentials (key-value, indentation, arrays, quotes)
- IDE help (completion, validation)
- Reference to @sec-yaml for troubleshooting

All detailed YAML content remains in yaml.qmd (Ch 9).

---

#### Ch 6: Sharing Your Work
**Target:** Publishing basics - `quarto publish`, providers overview
**Source:** `publishing.qmd` (split - basics portion)

Sections to INCLUDE (basics):
- `## Publishing to the web`
- `## The publishing process`
- `## Updating published documents`
- `## Providers` (overview only)

Sections to DEFER (to Ch 10/15):
- Detailed provider setup (GitHub Pages, Netlify, etc.)
- `## Sharing documents in other ways`
- `## Sharing document source`
- CI/CD details

---

### Part II: Going Deeper

#### Ch 7: Authoring in Depth
**Target:** Full authoring reference - code blocks, tables, equations, citations, callouts, layout
**Source:** `authoring.qmd` (depth portion)

Sections to INCLUDE:
- `## What are attributes?`
- `## Code blocks` (non-executable, syntax highlighting)
- `## Tables` (all: Markdown pipe, List, HTML, From code cell)
- `## Mathematical equations`
- `## Cross-references`
- `## Citations`
- `## Footnotes`
- `## Fenced divs` / `## What's a div?`
- `## Callouts` (all types)
- `## Layout` (Panel layouts, Column classes)
- `## Raw blocks`
- `## Shortcodes`
- `## Includes`

---

#### Ch 8: Computation in Depth
**Target:** Engines, execution model, all execution options (~300-400 lines)
**Source:** NEW chapter

Possible content from existing:
- `look-under-hood.qmd` → `### Computational engine` sections
- `yaml.qmd` → `## Execution options` (full details)

---

#### Ch 9: YAML in Depth
**Target:** Full YAML syntax, option scopes, troubleshooting
**Source:** `yaml.qmd` (depth portion)

Sections to INCLUDE:
- `### Long strings`
- `### Using \`default\``
- `## What happens when you get it wrong?`
  - `### Using the wrong YAML syntax`
  - `### Specifying the wrong key`
  - `### Specifying the wrong type of value`
- `## Obtuse messages`
  - `### Ways Quarto tries to help`
- `## What are the possible options?`
- `## Project options`
- Full `## Document options`
- `### Everything is a format option`
- `## OK, not quite everything...`
- `### Top-level options are applied to all formats`
- `### Options in \`_quarto.yml\` apply to all documents`
- `## \`engine\` is the exception again`
- `### \`_metadata.yml\``
- `### Command line metadata`

---

#### Ch 10: Projects
**Target:** Project structure, shared configuration
**Source:** `projects.qmd` (use mostly as-is)

Current headings:
- `## What is a Quarto Project?`
- `## RStudio Projects`
- `## Create a Project`
- `## Don't nest \`_quarto.yml\` files`
- `## Render and Preview a Project`
- `## What gets rendered?`
- `## Project Configuration`
  - `### Project Level Options`
- `### Common Metadata`
- `## Directory level metadata`
- `## Tools` (RStudio, VS Code)

**Action:** Use as-is, possibly add publishing details from Ch 6

---

#### Ch 11: Understanding Quarto
**Target:** Rendering pipeline, troubleshooting, getting help
**Source:** `look-under-hood.qmd` (condense)

Current headings:
- `## What does Quarto do?`
- `## An HTML document with R code cells` (all subsections)
- `## An HTML document with Python code cells` (all subsections)
- `## A PDF document with R code cells`
- `## A multi-format document`
- `## Other variations`
- `## Troubleshooting`
  - `### Run \`quarto check\``
  - `### Errors from the computational engine`
- `### Things that aren't errors`
- `### Asking for help`

**Action:** Condense examples (maybe 1-2 instead of 3+), keep troubleshooting

---

### Part III: Formats

#### Ch 12: HTML Documents
**Target:** Basic HTML options, themes, TOC, code display (~200-250 lines)
**Source:** NEW chapter + `websites.qmd` theming content

Content from `websites.qmd` to move here:
- `## Website theming` → generalize to HTML theming
- `### Built-in themes`
- `### **brand.yml**`
- `### Combine **brand.yml** with a built-in theme`
- `### Adding CSS or SCSS`
- `### The role of Bootstrap`

Plus new content on HTML-specific options (TOC, code display, etc.)

---

#### Ch 13: Typst Documents
**Target:** Why Typst, basic setup, PDF output (~150-200 lines)
**Source:** NEW chapter (no existing content)

---

#### Ch 14: Presentations
**Target:** revealjs basics - slides, sections, speaker notes (~150-200 lines new)
**Source:** `presentations.qmd` (expand from ~58 lines)

Current headings in `presentations.qmd`:
- `## Sections and slides` (only real section)

**Action:** Significant expansion needed - current file is minimal stub

---

#### Ch 15: Websites
**Target:** Minimal website, pages, navigation basics, publishing (~300-400 lines)
**Source:** `websites.qmd` (heavily condense from ~1752 lines)

Current headings to KEEP (condensed):
- `## Overview`
- `## Minimal website`
- `## Workflow`
- `## Website Structure`
  - `### File structure translates to URL structure`
  - `### Links`
- `## Navigation` (simplified)
  - `### Top Navigation`
  - `### Side Navigation`
- `## Publishing a website`

Current headings to CUT or heavily reduce:
- `## Website theming` → **MOVE to Ch 12 (HTML Documents)**
- `## About Pages`
- `## Listings`
- `## Continuous integration` (maybe brief mention)
- Detailed navigation variations

---

## Decisions Made

1. **Links in Ch 3?** No - links are covered in basic text formatting section
2. **Code blocks:** Ch 7 (Authoring in Depth) - Ch 4 will just mention the difference between executable code cells and code blocks
3. **Theming:** Move website theming content to Ch 12 (HTML Documents) as much as possible

---

## Next Steps

- [x] Split authoring.qmd → writing.qmd (essentials) + authoring.qmd (depth)
- [x] Create options.qmd (new intro chapter covering three option locations + YAML essentials)
- [x] Split publishing.qmd → sharing.qmd (single document basics only, projects/providers deferred to Ch 15)
- [ ] Migrate tools.qmd → workflow.qmd
- [ ] Condense look-under-hood.qmd → understanding.qmd
- [ ] Condense websites.qmd, move theming to html.qmd
- [ ] Write new content for code.qmd, computation-depth.qmd, html.qmd, typst.qmd
- [ ] Expand presentations.qmd

---

*Last updated: 2026-01-09*
