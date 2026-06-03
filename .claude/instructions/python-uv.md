# Python uv Project Standards

> Apply these standards when working with uv-managed Python projects.

## Setup

```bash
# Create a new project
uv init my-project

# Add a dependency
uv add requests

# Add a dev dependency
uv add --dev pytest

# Run a script
uv run python script.py

# Run tests
uv run pytest
```

## pyproject.toml Structure

```toml
[project]
name = "my-project"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = [
    "requests>=2.32",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "ruff>=0.6",
]

[tool.ruff]
line-length = 120

[tool.pytest.ini_options]
asyncio_mode = "auto"
```

## Lock File

- Always commit `uv.lock` to version control
- Never manually edit `uv.lock`
- Run `uv sync` after pulling changes that update `pyproject.toml`

## Virtual Environments

- `uv` manages the `.venv` automatically — do not activate it manually
- Add `.venv/` to `.gitignore`
- Use `uv run` prefix for all commands that need the project environment
