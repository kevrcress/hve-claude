# Bash Scripting Standards

> Apply these standards when writing or reviewing Bash scripts.

## Core Structure Requirements

Scripts must begin with `#!/usr/bin/env bash`. Enable strict error handling at the top of every script:

```bash
set -euo pipefail
```

This handles command failures (`-e`), unset variables (`-u`), and pipeline errors (`-o pipefail`).

## Style Standards

- **Indentation**: Two spaces (never tabs)
- **Line length**: Target 80 characters; use backslash continuation for longer commands
- **Conditionals**: Use `[[ ... ]]` syntax instead of `[ ... ]` or `test`
- **Arithmetic**: Use `(( ... ))` for numeric operations

## Naming Conventions

- Environment variables and constants: `UPPER_SNAKE_CASE` with `readonly` keyword for constants
- Local variables and functions: `lower_snake_case`

## Key Practices

- Encapsulate logic within a `main()` function called at the script's end
- All variables require braces and quoting: `"${var}"`
- Arrays: use `declare -a` with iteration via `"${array[@]}"`
- Include a `usage()` function for scripts that accept arguments

## Error Handling

- Implement an `err()` function directing output to stderr
- Quote all variables to prevent word splitting and injection attacks

## Security

- Verify file checksums before execution
- Set appropriate permissions (e.g., `chmod 0600` for sensitive files)
- Validate that required commands exist before use

## Quality

- Pass ShellCheck validation with documented suppressions when necessary
- Use `--output tsv` with Azure CLI; avoid JSON parsing where tsv is sufficient
