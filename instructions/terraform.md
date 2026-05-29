# Terraform Coding Standards

> Apply these standards when writing or reviewing Terraform code.

## Project Structure

```
module-name/
├── main.tf        # Primary resource definitions
├── variables.tf   # Input variable declarations
├── outputs.tf     # Output declarations
├── versions.tf    # Provider and Terraform version constraints
└── backend.tf     # Backend configuration (root modules only)
```

Organize by resource type: networking, storage, compute in subdirectories.

## Naming Standards

- Files and folders: `kebab-case`
- Resource logical names, variables, outputs: `snake_case`
- Single resource instances: label `"main"`
- Boolean variables: prefix with `should_` or `is_`

## Variables

- All variables require `description` (no trailing period)
- Required variables: omit `default`
- Optional variables: use sensible defaults; prefer `null` over empty strings
- Sensitive variables: include `sensitive = true`

## Outputs

- All outputs require `description`
- Use conditional expressions for optional resources: `try(resource.main.id, null)`

## Code Style

- Single-line comments: `//` syntax (not `#`)
- Section headers: visual separators (`# ----`)

## Useful Functions

- `coalesce()` — default value selection
- `try()` — optional attribute access
- Ternary operators for boolean conditions and conditional counts

## Provider Configuration

Root modules must include:
- `versions.tf` with explicit provider blocks
- `azurerm` ≥ 4.0, `azapi` ≥ 2.0, `random` ≥ 3.6 (for Azure projects)
- Backend in `backend.tf`

## Quality Gates

Run before committing:
```bash
terraform fmt -recursive
terraform validate
terraform plan
tflint
checkov -d .
```

## Lifecycle Rules

- Critical resources: `prevent_destroy = true`
- Document in comments why lifecycle rules are applied

## Documentation

Every module requires `README.md` covering: purpose, inputs, outputs, examples, prerequisites.
