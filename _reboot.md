# Reboot

A restructured book with progressive depth, plus basic format coverage.

## Working titles

* "Quarto Essentials"
* "Quarto: the Practical Guide" 

## Timeline

* Mid-Jan: Existing content restructured
* Late-Jan: Tools chapter merged in
* Feb: Opt-in to new quarto markdown syntax
* Late-March/early-April: First draft complete
* Summer: reviews, revisions, final production

## Target Audience

New Quarto users who want to learn Quarto systematically. The book takes readers from zero to competent, with enough depth to work independently. Not a quick-start guide, but not an exhaustive reference either.

## Chapter Listing

| Part | Chapter | Content Notes |
|------|---------|---------------|
| **Getting started** | Welcome | What is Quarto, installation, first document |
| | Quarto | What is Quarto, key features |
| | Your Quarto workflow | Tools (CLI, IDE basics), preview, render |
| | Writing content | Markdown essentials - headings, text, lists, links, images |
| | Adding code | Code cells, basic execution options (echo, eval, output) |
| | Setting options | YAML basics - document options, where to put them |
| | Sharing your work | Publishing basics - `quarto publish`, providers overview |
| **Computation** | Quarto and R | R-specific computation with knitr |
| | Quarto and Python | Python-specific computation with Jupyter |
| | Freezing and caching | Managing computation for reproducibility |
| **Mastering Quarto** | Markdown | Full authoring reference - tables, equations, citations, callouts, layout |
| | Projects | Project structure, shared configuration |
| | Options | Full YAML syntax, option scopes, troubleshooting |
| | Troubleshooting | Rendering pipeline, troubleshooting, getting help |
| **Formats** | HTML documents | Basic HTML options, themes, TOC, code display |
| | Typst documents | Why Typst, basic setup, PDF output |
| | Presentations | revealjs basics - slides, sections, speaker notes |
| | Websites | Minimal website, pages, navigation basics, publishing |
| **Doing more with Quarto** | | Books, dashboards, and next steps |
| **Appendix** | Jupyter | Using Quarto with .ipynb files |

## Existing Work to Use

| Content | Source | Usage |
|---------|--------|-------|
| authoring.qmd | authoring branch | Split: essentials → Writing content, depth → Markdown |
| yaml.qmd | main | Split: basics → Setting options, depth → Options |
| look-under-hood.qmd | main | Condense for Troubleshooting |
| projects.qmd | main | Use as Projects |
| publishing.qmd | main | Split: basics → Sharing your work, details in Websites |
| tools.qmd | tools branch | Condense for Your Quarto workflow |
| websites.qmd | main | Heavily condense for Websites |
| quarto.qmd | main | Expand for Quarto chapter |

## Work to Complete

| Chapter | Work Needed |
|---------|-------------|
| Welcome | Expand intro |
| Quarto | Expand existing |
| Your Quarto workflow | Condense tools, focus on workflow |
| Adding code | New chapter - code cell basics |
| Quarto and R | New chapter - R-specific computation |
| Quarto and Python | New chapter - Python-specific computation |
| Freezing and caching | New chapter - freeze and cache options |
| HTML documents | New chapter - HTML basics |
| Typst documents | New chapter - Typst intro |
| Presentations | Expand existing |
| Websites | Condense existing |
| Doing more with Quarto | New chapter - books, dashboards, next steps |

## Brand New Content

| Chapter | Notes |
|---------|-------|
| Adding code | Code cell basics |
| Quarto and R | R-specific computation with knitr |
| Quarto and Python | Python-specific computation with Jupyter |
| Freezing and caching | Managing computation |
| HTML documents | HTML format options |
| Typst documents | Typst intro |
| Doing more with Quarto | Books, dashboards, next steps |
