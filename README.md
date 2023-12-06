# quarto-tdg

Quarto: The Definitive Guide

## Workflow

The book is rendered and deployed to Netlify via a [GitHub action](.github/workflows/build-book.yaml). Changes to the `main` branch trigger a deployment to the published site. Pull requests trigger a deployment preview.

Substantive changes are proposed using pull requests. 

The book project sets [`freeze` to `auto`](https://github.com/mine-cetinkaya-rundel/quarto-tdg/blob/c7f98329338d86c86580ccc81dd424283850cb7c/_quarto.yml#L69-L70), so when you propose changes you should:

1. Locally render the book
2. Examine the git diff for changes to `_freeze/`, and commit changes to relevant files.

Since the GitHub action that renders the book does not execute any code, forgetting to commit to `_freeze` will result in a failed check on the PR.

### Reproducing the R environment locally

The R environment is managed with [renv](https://rstudio.github.io/renv/articles/renv.html). This should work automatically when opening the book project, and you'll be prompted by renv to get the required packages with `renv::restore()`.

If your contribution adds a dependency on an R package, make sure you run `renv::snapshot()`, and commit changes to `renv.lock`.

### Reproducing the python environment locally

#### Creating or recreating the environment

Use Python 3.12.

Create a virtual environment in the `env/` folder, in Terminal:

```{.bash}
python3 -m venv env
```

Activate the environment:

```bash
source env/bin/activate
```

Install packages from `requirements.txt`:

```bash
python3 -m pip install -r requirements.txt
```

#### Using the environment

VS Code + Python extension should pick up this environment automatically. 

Or on Terminal, activate the environment:

```bash
source env/bin/activate
```

#### Adding python packages

1. Activate the environment
2. Install the additional packages using `pip`
3. Update `requirements.txt`
    ```
    python3 -m pip freeze > requirements.txt
    ```
4. Commit `requirements.txt`
