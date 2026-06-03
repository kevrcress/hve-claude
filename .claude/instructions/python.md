# Python Coding Standards

> Apply these standards when writing or reviewing Python code.

## Project Setup

- Use `uv` for dependency management and virtual environments
- `pyproject.toml` is the single source of project metadata
- Target Python 3.12+ unless the project requires otherwise

## Style

- Follow PEP 8
- Use `ruff` for linting and formatting (replaces flake8 + black + isort)
- Line length: 120 characters
- Use f-strings for string interpolation; avoid `%` formatting or `.format()`

## Type Annotations

- Required on all public functions and methods
- Use `from __future__ import annotations` for forward references
- Use `X | Y` union syntax (Python 3.10+), not `Optional[X]` or `Union[X, Y]`
- Use `list[str]` not `List[str]`; built-in generics are preferred

## Naming

- Functions and variables: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Private: leading underscore `_private`

## Error Handling

- Raise specific exceptions; never `raise Exception("message")`
- Use custom exception classes for domain errors
- Catch specific exception types; never bare `except:`
- Context managers (`with`) for all resource management

## Async

- Use `asyncio` for I/O-bound concurrency
- Prefer `async/await` over callbacks or `threading`
- Use `anyio` for library code that should be framework-agnostic

## Documentation

- Docstrings: Google style for public modules, classes, functions
- Single-line docstrings for obvious functions
- No docstring needed for `__init__` when the class docstring covers it
