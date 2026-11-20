# quarto-tdg

Quarto: The Definitive Guide

## Workflow

The book is rendered and deployed to GitHub Pages via a [GitHub action](.github/workflows/build-book.yaml). Changes to the `main` branch trigger a deployment to the published site. Pull requests trigger a deployment preview.

Substantive changes are proposed using pull requests. 

The book project sets [`freeze` to `auto`](https://github.com/mine-cetinkaya-rundel/quarto-tdg/blob/c7f98329338d86c86580ccc81dd424283850cb7c/_quarto.yml#L69-L70), so when you propose changes you should:

1. Locally render the book
2. Examine the git diff for changes to `_freeze/`, and commit changes to relevant files.

The GitHub actions that render the book for a push or a pull request do not execute any code. Before they render, they run `scripts/check-freeze.ts`. If you change a chapter with executable code and do not commit its `_freeze/` files, this check fails and names the chapter to render. To run the same check locally:

```bash
quarto run scripts/check-freeze.ts
```

### Re-executing all code

The [Execute Code workflow](.github/workflows/execute-build-book.yaml) executes all the code in the book. It does not start automatically. To start it, use the **Run workflow** button on the Actions tab, or run:

```bash
gh workflow run execute-build-book.yaml
```

The workflow installs the R packages from `renv.lock` and the Python packages from `uv.lock`. Then it deletes `_freeze/` and renders the book, so every code cell runs. If the workflow fails, a lockfile or a chapter does not work in a clean environment.

The last step of the workflow deploys the rendered book to Netlify. The workflow does not commit the new `_freeze/` files.

### Reproducing the R environment locally

The R environment is managed with [renv](https://rstudio.github.io/renv/articles/renv.html). This should work automatically when opening the book project, and you'll be prompted by renv to get the required packages with `renv::restore()`.

If your contribution adds a dependency on an R package, make sure you run `renv::snapshot()`, and commit changes to `renv.lock`.

### Reproducing the Python environment locally

The Python environment is managed with [uv](https://docs.astral.sh/uv/). To create or recreate the environment:

```bash
uv sync
```

This creates a `.venv/` and installs all dependencies from `uv.lock`.

#### Using the environment

Quarto will use the `.venv/` automatically. To activate it in the terminal:

```bash
source .venv/bin/activate
```

#### Adding Python packages

```bash
uv add <package>
```

Then commit the updated `pyproject.toml` and `uv.lock`.

## Style Guide

See `_style-guide.md` for details on writing and formatting style for the book.