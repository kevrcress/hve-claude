# Doc-Ops Reference

> Invoke documentation QA with `/hve-doc-ops [path]`.

## What it checks

- **Pattern compliance**: heading hierarchy, list formatting, code block language tags, frontmatter
- **Accuracy**: file paths exist, function names match codebase, version numbers are current
- **Gaps**: undocumented public APIs, missing configuration docs, absent onboarding guide

## Options

- `--scope all` — all documentation (default)
- `--scope compliance` — pattern checks only
- `--scope accuracy` — cross-reference with code only
- `--scope gaps` — gap detection only

## Excludes

Prompt engineering artifacts (`.claude/commands/`, `.claude/agents/`, `.claude/instructions/`, `.claude/prompts/`) — use `/hve-prompt-analyze` for those.

## Output

`.claude-hve-tracking/doc-ops/YYYY-MM-DD-session.md` with severity-graded findings.

## When to use

- After major feature work — check that docs reflect what was built
- Before a release — comprehensive documentation audit
- When a new contributor reports confusion — gap detection mode
