# Git Commit Message Standards

> Apply these standards when writing or reviewing git commit messages.

## Format

```
type(scope): short description under 100 characters

- Body bullet 1 (optional)
- Body bullet 2 (optional, 0–5 items max, under 300 bytes total)

🎯 Footer emoji and summary
```

## Types

| Type | When to use |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring without behavior change |
| `perf` | Performance improvement |
| `style` | Formatting, no logic change |
| `test` | Adding or updating tests |
| `docs` | Documentation only |
| `build` | Build system or dependency changes |
| `ops` | CI/CD, deployment, infrastructure |
| `chore` | Maintenance, cleanup |

## Scope

Lowercase, derived from the affected directory or module:

- `(docs)`, `(agents)`, `(prompts)`, `(instructions)`, `(workflows)`, `(build)`, `(settings)`
- Add new scopes matching the repository's directory structure

## Description

- Imperative mood: "add feature" not "added feature" or "adds feature"
- Under 100 characters including `type(scope): `
- No trailing period
- Lowercase first letter after the colon

## Body (optional)

- Present tense, imperative mood
- 0–5 bullet items
- Under 300 bytes total
- Explain the "why" not the "what"

## Footer

- Begins with a blank line after the body
- Emoji representing the change type
- Brief summary line

## Examples

```
feat(agents): add hve-challenge command for adversarial questioning

- Interrogates plans and implementations as an uninformed skeptic
- Produces challenge document in .claude-hve-tracking/challenges/

🎯 Adds adversarial validation to the HVE review workflow
```

```
fix(instructions): remove applyTo frontmatter from all instruction files

🔧 Strips Copilot-specific metadata incompatible with Claude Code
```
