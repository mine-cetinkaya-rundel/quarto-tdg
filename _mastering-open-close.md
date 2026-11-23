# Mastering Quarto: chapter openings and closings

Extracted 2026-11-23 to review how chapters fit after the reorg.
Chapters follow `_quarto.yml` order, with the two figure/table chapters placed where PR #28 puts them (after `authoring.qmd`).
Opening = everything before the first top-level `##` section (including an `## Overview` section if the chapter has one).
Closing = the last top-level `##` section.

# authoring

[authoring.qmd](authoring.qmd) — opening: lines 6–16; closing: lines 1118–1126.

## Opening

````markdown

# Markdown {#sec-authoring}

When we say "authoring" we mean the process of adding content to a Quarto document---literally, the things you write in a `.qmd` file.
More specifically, this chapter focuses on what you put in the parts of your document that are interpreted as markdown---that is, everything that isn't the document header, or an executable code cell.

Our goal is to give you a good overview of breadth of Quarto's authoring features, while delaying many of the details to later chapters of the book.
We also focus on syntax that is broadly supported across multiple output formats and cover specific format features where relevant in @sec-html, @sec-typst and @sec-presentations.

We suggest reading through the chapter in its entirety on your first reading, and then referring back to specific sections as needed when authoring your own documents.

````

## Closing

````markdown
## Wrapping up

This chapter has focused on how to write a rich document using Quarto markdown.
You've learned to use markdown headings to structure your document into sections, create paragraphs and lists, and format text with emphasis, links, and other inline elements. 
You've covered how to add the most important components of technical and scientific writing: code, tables, images, and equations.

You've also learned how to use key Quarto features like cross-references, citations, footnotes, and callouts.
Fenced divs let you create special regions like callouts or multi-column layouts, while shortcodes and includes help you reuse content efficiently. 
We've focused on syntax that works across multiple output formats, leaving format-specific details for later chapters—you'll likely want to return to specific sections as reference when authoring your own documents.
````

# figure-table

`figure-table.qmd` on the `figtab-mastering` branch (PR #28) — opening: lines 4–36; closing: lines 1308–1312.

## Opening

````markdown

# Figures and tables {#sec-figure-table}

Figures and tables are how most scientific and technical documents communicate data and results. 
You often need precise control over their placement within documents, their captions, and the ability to group them into panels and cross-reference them throughout the text. 
Given their importance, we've devoted two chapters to figures and tables: this one and @sec-figure-table-computational.

This chapter applies however you produce your figures and tables---whether you write them in markdown or generate them from code cells. 
We've done this on purpose, because most aspects of working with figures and tables are independent of their source. 
For example, document-level options that control figures and tables often apply universally, as do many layout features that involve surrounding figures or tables in additional markdown.
There are a few exceptions where you'll need to use specific attributes for markdown-based content or code cell options for computational output, and we'll point these out clearly when they arise.

You should review @sec-syntax-variations, which explains how to translate between markdown and computational syntax for figures and tables.
It also introduces what we call the fenced div syntax, which will help you understand and apply the examples used throughout the rest of both chapters.

We expect you'll turn to these chapters to solve particular tasks with your own tables and figures.
@tbl-figtab-tasks points you to the relevant section.

| How do I... | See |
|:--|:--|
| Cross-reference a figure or table | @sec-figtab-crossref |
| Change the caption text, location, or title | @sec-figtab-captions |
| Arrange multiple figures or tables in a panel | @sec-figtab-layout |
| Put a figure or table in the margin, or make it wider than the text | @sec-page-columns |
| Make a figure smaller or larger on the page | @sec-figure-width |
| Align a figure left, center, or right | @sec-figure-alignment |
| Align or size the columns of a table | @sec-table-column-alignment, @sec-table-column-widths |
| Control the size or aspect ratio of a computational figure | @sec-figure-size |
| Control the format and styling of a computational table | @sec-figtab-tables |
| Troubleshoot figure or table output from a package | @sec-figtab-troubleshooting |

: Common figure and table tasks. {#tbl-figtab-tasks}

````

## Closing

````markdown
## Wrapping Up

You now know how to cross-reference, caption, lay out, and position any figure or table, whether it comes from markdown or code.
But when code produces the output, some things are decided before Quarto ever sees it, like the size of a plot, the format of a table, or the styling a package adds.
@sec-figure-table-computational covers the code cell options that control these, and how to troubleshoot output that isn't what you expect.
````

# figure-table-computational

`figure-table-computational.qmd` on the `figtab-mastering` branch (PR #28) — opening: lines 4–107; closing: lines 775–894.

## Opening

`````markdown

# Computational figures and tables {#sec-figure-table-computational}

<!--
This chapter runs no code (engine: markdown), so quoted cells can use
single braces.

Regenerate the screenshots for this chapter and figure-table.qmd
(see _examples/figure-table/README.md):
source("_examples/figure-table/generate-screenshots.R")

Setup for running the code snippets interactively:
_examples/figure-table/_code-snippets/setup.R
-->

This chapter covers topics specific to figures and tables that are the output of executable code cells.
Producing figures and tables with code has many advantages:

- Your figures and tables are always up to date.
- You can change labeling, styling, colors, etc., right in the document source.
- Quarto handles file formats and paths, so you don't have to.

You'll start by reviewing the most common code cell options for figures and tables---those that add captions, identifiers, and alternative text.

We've split the rest of the chapter into two sections: one for figures (covering size, format, resolution, and multiple figures) and one for tables (covering table formats and multiple tables).

Much of the control of computational figures and tables comes from code cell options.
To help you navigate this, and other chapters, we list the most common code cell options in @tbl-figtab-ref.
With one exception, we only list options common to both the `knitr` and `jupyter` engines.
Use the [Quarto Code Cell Reference](https://quarto.org/docs/reference/cells/) for the full list of available options.


| Option | Document option | Description | Reference |
|:-------|-----------------|:------------|:----------|
|`label` | | ID for output, also used for cross-references | @sec-figtab-basic. Prefix with `fig-` or `tbl-` to number and cross-reference; see @sec-figtab-crossref |
| `fig-cap` | | Caption for figure                          | @sec-figtab-basic. For control over appearance see @sec-figtab-captions |
| `tbl-cap` | | Caption for table                           | @sec-figtab-basic. For control over appearance see @sec-figtab-captions |
| `fig-alt` | | Alternative text description of the figure  | @sec-figtab-basic |
| `fig-subcap` | | Sub-captions for multiple figures produced in a single code cell | @sec-multiple-figures |
| `tbl-subcap` | | Sub-captions for multiple tables produced in a single code cell |@sec-multiple-tables  |
| `layout-ncol` / `layout-nrow` | | Number of columns when arranging multiple figures or tables in a single panel | For figures see @sec-multiple-figures, for tables see @sec-multiple-tables. For more complicated layouts see @sec-figtab-layout |
| `column` / `fig-column` / `tbl-column` | | Place figure or table in a specific column relative to page | @sec-page-columns |
| `output-location` | | Place figure or table in a specific location relative to slide | @sec-output-location |
| `fig-width` / `fig-height` **knitr engine only** | ☑ | Size of figure in inches | @sec-figure-size, also includes options for `jupyter` engine |
| `out-width` **knitr engine only** | | Display width of figure on the page | @sec-figure-width |
| `fig-align`| ☑ | Alignment of figures in their surrounding container | @sec-figure-alignment |
| `tbl-colwidths` | ☑ | Column widths for markdown tables | @sec-table-column-widths |
| `layout` | | Layout specification when arranging multiple figures or tables in a single panel | @sec-figtab-layout |
| `layout-align` / `layout-valign` | | Alignment when arranging multiple figures or tables in a single panel | @sec-figtab-layout |
| `cap-location` / `fig-cap-location` / `tbl-cap-location` | ☑ | Location of caption relative to figure or table | @sec-caption-location |

: Common code cell options for figures and tables {#tbl-figtab-ref tbl-colwidths="[25,5,40,30]"}

A ☑ in the Document option column marks options you can also set at the document level.

:::: {.callout-note}
## The examples in this chapter

We wanted authentic examples of figures and tables generated by code in this chapter.
However, the focus of this chapter isn't on the code, and we don't want it to distract you.
To balance those objectives we've selected a small number of examples that we'll repeat throughout the chapter.
These examples are designed to be almost identical between R and Python, 
so we've limited ourselves to a few packages (ggplot2 and gt in R, and plotnine and great_tables in Python).

We've provided examples in both R and Python so you can reproduce them in your favorite language.
The concepts you are learning are independent of language and package, 
so while the executable code is different,
the code cell options and markdown syntax are identical.

The code to generate the example figures and tables is shown without any other context.
If you want to recreate them, you'll need the setup code as shown in @fig-setup.
We also show the rendered examples without the code; that is, we set `echo: false` in our document header:

```{.yaml .code-overflow-wrap filename="document.qmd"}
---
echo: false
---
```

::: {#fig-setup}

::: {.panel-tabset group="language"}

## R

````{.r .code-overflow-wrap filename="setup.R"}
{{< include _examples/figure-table/_code-snippets/setup.R >}}
````

## Python

```{.python .code-overflow-wrap filename="setup.py"}
{{< include _examples/figure-table/_code-snippets/setup.py >}}
```

:::

Code required before executing the examples in this chapter.

:::

::::


`````

## Closing

> **No wrap-up section.** Shown instead: the last top-level section, `## Troubleshooting {#sec-figtab-troubleshooting}`.

`````markdown
## Troubleshooting {#sec-figtab-troubleshooting}

It's useful to think about the process of getting your figures or tables into the rendered document in three steps:

1. Execution of the code in your code cell that produces your figure or table.

2. Translation of the code cell output into markdown, including saving the image file in the case of figures.

3. Rendering of the markdown to include the figure or table in the final output format.

To troubleshoot a computational figure or table that doesn't come out looking right, we suggest checking each step in turn.
The following sections provide some tips for doing this.

### Execute your code interactively

Execute the code cell interactively in your computational environment.
Be careful to ensure your local computational environment (interpreter versions and package versions) matches those used by Quarto.
Check that the figure or table looks as you expect.
If it doesn't, you need to fix your code based on the documentation for the packages you are using.

### Examine intermediate markdown

The execution engine translates the output of your code cell into markdown.
A good way to see what it has done is to examine the intermediate markdown after the engine has finished.
Set `keep-md: true` in your document header:

```{.yaml .code-overflow-wrap filename="document.qmd"}
---
title: My Document
keep-md: true
---
```

Render your document, and then open the generated markdown file, `{filename}.{format}.md`.
Find the relevant figure or table (e.g., by searching for its `label`) and examine it carefully.
When examining the intermediate markdown, ask yourself:

* Is the format of the figure or table what you expect? 

* Is the content of the figure or table what you expect?
    Compare to the result of evaluating your code cells locally.
    For figures, use the image path in the markdown to find the image file in the `{filename}_files/figure-{format}/` folder, and open it directly.
    For tables, you'll need to rely on examining the HTML or markdown syntax.

* Is the surrounding markdown what you expect?
    For example, are the attributes present on the figure or table markdown?
    Are the correct classes on the surrounding fenced divs?

Tracking down problems here is tricky because they could be coming from the packages you are using, the engine, or the interaction between the two. 
Here are some strategies to help you isolate the source of the problem.

#### Explore package options

Some packages are Quarto-aware (or `knitr`- or `jupyter`-aware), and will adjust their output based on the context of your document.
Other packages aren't Quarto-aware but provide options that force a format or omit extraneous markup.
Check the documentation for your chosen package to see if/how it supports Quarto, and what options are available.

#### Separate code from markdown

Some code cell options, like `column` and the `layout*` options,
don't affect how your code produces your figures and tables;
instead, they affect the markdown that surrounds them in the document.

If you are using these options,
a good first step is to pull apart the layout from the code that produces the figure or table.

Remove the layout options entirely, and check the tables and figures themselves look right.
Then, introduce the layout back in, but use the fenced div approach (as outlined in @sec-figtab-layout), rather than the code cell options.

#### Do the translation yourself

If you can't figure out why you aren't getting the right markdown, you can consider doing the translation yourself.
Instead of your code cell producing a figure or table, have it produce the markdown to include the figure or table.

You'll need to set the code cell option `output: asis` to tell Quarto not to further process the output of your code cell.
Then write code to output text that is the markdown to include your figure or table.
For figures, you need to save the image file in your code, and you are responsible for its format, size, and path.

For example, if your code saves an image to a path defined in `image_path`, @fig-translate-yourself shows how to produce the markdown to include it.

::: {#fig-translate-yourself}

::: {.panel-tabset group="language"}

## R
 
````{.markdown .code-overflow-wrap}
```{r}
#| echo: false
#| output: asis

cat(paste0("![Caption](", image_path, "){#fig-plot1 fig-alt='Alt text'}\n"))
```
````
 
## Python
 
````{.markdown .code-overflow-wrap}
```{python}
#| echo: false
#| output: asis

print(f"![Caption]({image_path}){{#fig-plot1 fig-alt='Alt text'}}\n")
```
````
 
:::

Code cells that produce markdown to include a figure saved in the path defined in `image_path`.
:::

### Check rendering with a non-computational output

If you see no problems with your intermediate markdown, you should be able to reproduce your problem with a non-computational example.
Replace your executable code cells with markdown equivalents.
For example, save your figure as an image file, and include it with standard markdown image syntax.

You can use your intermediate markdown as a guide, but simplify as much as you can, while still reproducing your problem.
You have now eliminated the computational environment as a source of the problem, so it's possibly a Quarto problem.
It's time to ask for help (@sec-ask-for-help).
`````

# projects

[projects.qmd](projects.qmd) — opening: lines 5–25; closing: lines 564–586.

## Opening

````markdown

# Projects {#sec-projects}

```{r}
library(fs)
library(quarto)
library(yaml)
dir_create("temp-dirs")
```

So far, we've concentrated on single Quarto documents: a single `.qmd` which defines all of its Quarto options in its header.
In this chapter, you'll learn about Quarto projects: a way to organize collections of Quarto documents.
You'll learn:

-   What a Quarto project is
-   How to create one, or turn an existing folder into one
-   How working with a project differs to working with single files
-   How to render all or part of a Quarto project
-   How to set project level Quarto settings
-   How to specify common metadata for documents in the project

````

## Closing

````markdown
## Wrapping Up

You've seen how a Quarto project allows you to organize, configure and render a folder of documents.
Project are particularly useful when you have a set of documents that share some metadata. 
But, even without shared metadata, the ability to easily render a directory of documents is a good reason to use a project. 
And as you'll see later websites, books and manuscripts are special types of projects.

There's plenty more you can do with projects that we didn't cover. A few worth knowing about:

* **Computational environments.** A project is a natural place to record the packages your code depends on, for example with `renv` for R, or a virtual environment for Python. This makes it easier for collaborators, and CI services, to reproduce your results. You can learn more in [Virtual Environments](https://quarto.org/docs/projects/virtual-environments.html).

* **Freeze.** The `freeze` execution option stops Quarto from re-running a document's code during a full project render. Quarto stores the results in `_freeze/`, which you commit, so collaborators and CI services can render your project without your computational environment. Be aware that with `freeze: auto` any edit to a document, even to its prose, re-runs its code. With `freeze: true` a project render ignores edits to a frozen document completely, until you render that document directly. You can learn more in [Managing Execution](https://quarto.org/docs/projects/code-execution.html).

* **Pre- and post-render scripts.** The `pre-render` and `post-render` project options run your own scripts before and after a render, for example to prepare data or check the links in your output. You can learn more in [Project Scripts](https://quarto.org/docs/projects/scripts.html).

* **Project profiles.** A profile, like `_quarto-production.yml`, holds options that Quarto merges over `_quarto.yml` when you activate it. Profiles let one project render differently in different situations, for example a public and an internal version, or freeze locally but run all code in production. You can learn more in [Project Profiles](https://quarto.org/docs/projects/profiles.html).

* **Custom project types.** If you often create projects with the same structure or settings, you can package them as a custom project type in an extension, which others can then use as a starting point. You can learn more in [Project Types](https://quarto.org/docs/extensions/project-types.html).


```{r}
dir_delete("temp-dirs")
```
````

# websites

[websites.qmd](websites.qmd) — opening: lines 4–25; closing: lines 1889–1908.

## Opening

````markdown

# Websites {#sec-websites}

## Overview

Quarto websites are a special type of Quarto project for building...well, websites.
By adding a single configuration file, you can turn any collection of Quarto documents into a website.
Quarto websites are a great way to showcase your work, build documentation, or share your learning progress.

In this chapter, you'll start with the minimal building blocks for a functional website --- it takes just two files!

Then, you'll dive into the three big components of a website:

* Content: In @sec-website-structure you'll learn how pages in a website are built from Quarto documents in a project, how to cross-link pages, and to control what does and doesn't end up on your site. Later, you'll also learn about two special kinds of pages **About pages** in @sec-websites-about-pages and **Listings** in @sec-websites-listings.

* Navigation: In @sec-websites-navigation you'll learn about adding site navigation, so your viewers can easily locate content on your site. 

* Appearance: In @sec-websites-theme you'll learn how to customize the appearance of your site by controlling colors, fonts and more.

Finally, in @sec-website-publish you'll learn how to get your website out in the world, and in @sec-ci tools for automating the publishing process.


````

## Closing

````markdown
## Wrapping Up

In this chapter, you learned about the key components of a Quarto website: content, navigation, and appearance. 
You also learned about a few techniques for publishing your site.

But, there are many other features we haven't talked about.
Some notable ones include:

* Drafts: Set `draft: true` to be able to preview pages, but not have them included in a site render, <https://quarto.org/docs/websites/website-drafts.html>.

* Comments: Integrate third-party tools to allow your readers to leave comments on your pages, <https://quarto.org/docs/output-formats/html-basics.html#commenting>.

* Announcements: Add a bar to the top of the site for crucial info, <https://quarto.org/docs/websites/website-tools.html#announcement-bar>.

You can find comprehensive lists of all your options are in the Reference in the Quarto documentation:

* You find website-level options in [Projects > Websites](https://quarto.org/docs/reference/projects/websites.html).

* You find page-level options (that could be set site-wide in `_quarto.yml`) in [Formats > HTML](https://quarto.org/docs/reference/formats/html.html).

````

# yaml

[yaml.qmd](yaml.qmd) — opening: lines 4–21; closing: lines 770–883.

## Opening

````markdown

# Options {#sec-yaml}

## Overview 

There's a lot going on when you set a Quarto option.
You need to:

-   know the name of the option and the values it can take,
-   figure out where to set the option, and
-   get the YAML syntax right for setting the option to its value.

In this chapter, you'll learn more about setting options in Quarto so you can nail each of those steps.

You'll start by learning more about YAML syntax.
Then, you'll see some ways things can go wrong.
Finally, you'll learn more about how to find out what options are available, and where to put them.

````

## Closing

> **No wrap-up section.** Shown instead: the last top-level section, `## Execution options {#sec-execution-options}`.

`````markdown
## Execution options {#sec-execution-options}

We use the term **execution options** to describe options you can set in code cells. 
The set of options available depends on your execution engine:
[`knitr`](https://quarto.org/docs/reference/cells/cells-knitr.html), [`jupyter`](https://quarto.org/docs/reference/cells/cells-jupyter.html) or [`ojs`](https://quarto.org/docs/reference/cells/cells-ojs.html).

You can generally split execution options into two types:

-  information that is unique to a code cell like identifiers (`label`, `lst-label`), captions (`fig-cap`, `tbl-cap`, `lst-cap`, `fig-subcap`, `tbl-subcap`, `fig-scap`) or other annotation (`fig-alt`, `fig-link`).

-  settings that could conceivably apply to many code cells that control things like: if the code is executed (`eval`), or how code and results appear in the output(`echo`, `output`, `warning`, `error`), where output appears (`column`, `panel`, `output-location`), or how code is presented (`code-fold`, `code-overflow`, `code-line-numbers`).

For options in the later category, just like document options, you can increase their scope by moving them: to the document header to apply to all code cells in the document; or to `_quarto.yml` to apply to all code cells in the project.

### Execution options set in code cells

Execution options are set in code cells using YAML syntax after a special comment:

````
```{r}
#| echo: false

```
````

Execution options need to be specified before any code, 
and are prefaced by the native comment character for the 
code cell language (`#` for `r`, `python` and `julia`),
followed by a pipe (`|`), and a space.

You can use the same YAML syntax as in the document header, 
but for multiline statements, remember to preface each line with the cell option comment.
For example, to use a literal block string:

````
```{r}
#| fig-cap: |
#|   Here's a long caption
#|   spread over two lines

plot(1:10)
```
````

### Execution options set in the document header

As reasonable working model, assume you can move an execution option from a code cell to the document header and it will apply to all code cells in the document.
For example, you could move `echo: false` out of a code cell and into the document header:
```{.yaml filename="document.qmd"}
---
title: My document
echo: false
---
```

You can override the document level setting by setting the option in a code cell:

````
```{r}
#| echo: true

```
````

When you move an option in this way it behaves just like a document option:

1. To figure out if an option is supported at the document level look in the reference guide for your target formats.

2. If you nest an execution option under a format, it will only apply to that format.

So, while assuming you can move an execution option to the document header is a good working model, the definitive way to check is to see if it is a document option for your target formats.

There are a couple of special cases it is worth pointing out.

### `fig-width` and `fig-height`

For the `jupyter` engine, `fig-width` and `fig-height` are document options only---you cannot set them at the cell level. 
If you need cell level control of the size of a figure, you'll need to set it in the code that creates the figure.

### Knitr specific options 

There are a number of execution options that are specific to the `knitr` engine, that don't have document option equivalents.
Some common ones include `message`, `collapse` and `prompt`.

You can set these for all code cells using the `knitr: chunk_opts` option.
For example, to suppress all messages:

```{.yaml}
---
title: "Untitled"
format: html
knitr:
  opts_chunk:
    message: false
---
```

### Execution options set in `_quarto.yml`

When an execution option is also a document option, 
you can move it to `_quarto.yml` to apply to all code cells in a project.

For example, to omit the code "echo" all code cells, and all formats, in a project you could set `echo` at the top-level of `_quarto.yml`:

```{.yaml filename="_quarto.yml"}
echo: false
```

You can then override this at the document or cell level as usual.





`````

# look-under-hood

[look-under-hood.qmd](look-under-hood.qmd) — opening: lines 5–11; closing: lines 818–818.

## Opening

````markdown

# Troubleshooting {#sec-troubleshooting}

So far, we haven't talked much about what happens behind the scenes when you run `quarto render`.

In this chapter, you'll learn more about what Quarto does under the hood, so you can troubleshoot problems when they occur.

````

## Closing

````markdown
## Wrapping Up
````

# more

[more.qmd](more.qmd) — opening: lines 4–12; closing: lines 204–217.

## Opening

````markdown

This book is a curated collection of what we think are the most useful parts of Quarto for most people. 
However, there is much more to Quarto!
In this chapter, we briefly cover some of the things we omitted from the book and why or when they might be useful to you.

We start with Quarto extensions, an ecosystem of additional features you can pull into your Quarto documents and projects. 
We then cover formats and project types beyond those we covered in the book.
Finally, we will briefly cover other ways you can add interactivity to Quarto documents.

````

## Closing

````markdown
## Wrapping up {#sec-wrapping-up}

You've reached the end of the book.
We hope you now have both the practical skills to write, compute and publish with Quarto, and enough understanding of how Quarto works to tackle the features we didn't cover.
Most of them build on ideas you already know: Markdown for content, code cells for computation, options to control output, and projects to tie documents together.

To keep learning and get help:

- The [Quarto documentation](https://quarto.org) is the definitive reference. Use the Guide to learn about a feature, and the Reference to look up every option for a format.
- The [Quarto blog](https://opensource.posit.co/blog/q/quarto/) announces new releases and features.
- [GitHub Discussions](https://github.com/quarto-dev/quarto-cli/discussions) is the place to ask questions. You'll get better answers if you include a small, complete example, and @sec-troubleshooting can help you narrow a problem down to one.

Happy writing, coding, and publishing!

````

