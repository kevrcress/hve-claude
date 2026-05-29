# C# Coding Standards

> Apply these standards when writing or reviewing C# code.

## Project Structure

- Solutions use `.sln` at root, `src/` for projects, test projects suffixed `*.Tests`
- Target framework: `net10.0` for cross-platform, `net10.0-windows` for Windows-specific
- Enable `ImplicitUsings` and `Nullable` in project files
- Omit explicit `LangVersion` — .NET 10 defaults to C# 14

## Naming Conventions

| Element | Convention |
|---|---|
| Classes | `PascalCase` |
| Interfaces | `IPascalCase` |
| Methods / Properties | `PascalCase` |
| Fields | `camelCase` |
| Base classes | `PascalCaseBase` |
| Type parameters | `TName` |

## Class Member Ordering

Within each access level (public → protected → private → internal):

1. Constants, static readonly, readonly, instance fields
2. Constructors
3. Properties
4. Methods

## Variable Declarations

- Use `var` when type is obvious from context
- Target-typed `new()` when type appears on the left
- Collection expressions: `[1, 2, 3]`
- Prefer early returns over nested conditions

## Documentation

- Public and protected members require XML documentation
- Use `<see cref="..."/>` for type/member references
- Use `<inheritdoc/>` for interface implementations
- Use `<exception cref="...">` for thrown exceptions

## Namespaces

- Prefer file-scoped namespaces aligned with folder structure

## Nullable Reference Types

- Enable at project level
- Use `?` for nullable types
- Use `required` modifier for non-nullable properties that must be set
- Avoid the null-forgiving operator `!` except when provably necessary
