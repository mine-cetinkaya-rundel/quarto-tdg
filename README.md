# quarto-tdg

Quarto: The Definitive Guide

## Building Locally

### To Reproduce Python Environment

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

VS Code + Python extension should pick up this environment automatically. 
