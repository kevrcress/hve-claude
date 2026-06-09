# Reference

Tracking folder layout, the bundled language instruction files, and the reusable
prompts copied into your project.

## Tracking folder structure

```
.claude-hve-tracking/
├── research/
│   ├── YYYY-MM-DD/topic.md                     # Consolidated findings
│   └── subagents/YYYY-MM-DD/topic.md            # Per-subagent raw findings (gitignored)
├── plans/
│   ├── YYYY-MM-DD/task-slug-plan.md             # Implementation plan (phases + deps)
│   └── logs/YYYY-MM-DD/task-slug-log.md         # Planning discrepancy log
├── details/
│   └── YYYY-MM-DD/task-slug-details.md
├── changes/
│   └── YYYY-MM-DD/task-slug-changes.md          # Updated per implemented phase
├── reviews/
│   ├── rpi/YYYY-MM-DD/                          # RPI validation output
│   └── pr/branch-name/                          # PR review output
├── challenges/
│   └── YYYY-MM-DD-topic-challenge.md
├── memory/
│   └── YYYY-MM-DD/kebab-slug.md
├── doc-ops/
│   └── YYYY-MM-DD-session.md
└── sandbox/                                     # Prompt builder runs (gitignored)
    └── YYYY-MM-DD-topic-run-N/
```

**Artifact naming:**
- Date format: `YYYY-MM-DD`
- Slug: `kebab-case-description` (3–6 words), e.g. `add-oauth2-api`
- Suffixes: `-plan.md`, `-details.md`, `-changes.md`, `-log.md`

See [Tracking folder and version control](../README.md#tracking-folder-and-version-control)
in the README for what gets committed versus gitignored.

## Language instruction files

HVE works with any language or tech stack, these instruction files are optional
style guides, not a requirement. The `hve-phase-implementor` reads the relevant
file in `.claude/instructions/` before writing code if one exists for that
language. If your language isn't listed, HVE still implements, it just won't have
a pre-loaded convention guide. You can add your own instruction files for any
language and reference them in `CLAUDE.md`.

The files below are included out of the box (ported from the MS repo):

| File | Covers |
|---|---|
| `bash.md` | `set -euo pipefail`, 2-space indent, portable POSIX patterns |
| `python.md` | PEP 8, ruff, type annotations, import order |
| `python-uv.md` | uv tooling, lockfiles, virtual environments |
| `python-tests.md` | pytest conventions, fixtures, parametrize |
| `csharp.md` | .NET naming, async/await, nullable reference types |
| `csharp-tests.md` | xUnit, Arrange/Act/Assert, test isolation |
| `rust.md` | Rust idioms, error handling, ownership patterns |
| `rust-tests.md` | `#[cfg(test)]`, integration test layout, cargo test |
| `terraform.md` | HCL style, module conventions, variable naming |
| `markdown.md` | Document structure, heading hierarchy, table formatting |
| `git-commit-messages.md` | Conventional commits, scope, subject line rules |
| `writing-style.md` | Prose clarity, active voice, technical writing conventions |

## Reusable prompts

The `.claude/prompts/` directory contains task-specific prompts copied into your project by
the installer. They're used internally by phase commands and can also be referenced
directly.

| File | Used by |
|---|---|
| `rpi.md` | Core Research → Plan → Implement → Review loop template |
| `checkpoint.md` | User checkpoint format used between phases |
| `doc-ops.md` | Documentation QA workflow template |
| `pull-request.md` | PR review prompt template |
| `task-challenge.md` | Adversarial challenge workflow template |
| `prompt-build.md` | Prompt engineering sandbox workflow template |
