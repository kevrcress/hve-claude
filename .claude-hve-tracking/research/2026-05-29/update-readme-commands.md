# Research Findings: HVE Claude Project Structure and Commands
Date: 2026-05-29
Question: Comprehensive project overview for README documentation purposes—commands, subagents, installation, configuration, tracking structure, and language conventions
Investigator: hve-researcher (subagent)

## Findings

1. **Project Purpose & Architecture** — HVE Claude is a convention-driven agentic development workflow adapted from microsoft/hve-core for Claude Code. It enforces Research → Plan → Implement → Review discipline with 15 slash commands (10 primary + 5 git/prompt utilities), 8 subagents (specialized parallel agents), and durable file-based handoff artifacts stored in `.claude-hve-tracking/` [HIGH]

2. **Command Structure — Phase Commands (5 primary)** — `/hve` (full RPI orchestrator), `/hve-research` (investigate, spawn researcher subagents), `/hve-plan` (convert findings to implementation plan with validator), `/hve-implement` (execute phases with phase-implementor subagents), `/hve-review` (validate against plan, spawn validators) [HIGH]

3. **Command Structure — Review/Auxiliary (5 additional primary)** — `/hve-pr-review` (8-dimension code review across functional/design/idiomatic/reuse/performance/reliability/security/docs), `/hve-memory` (save session decisions/open questions), `/hve-challenge` (adversarial questioning of plans/implementations), `/hve-doc-ops` (documentation QA: compliance/accuracy/gaps), plus 5 more for prompt engineering and git operations [HIGH]

4. **Subagent Model & Tool Scoping** — 8 total subagents use `model: haiku` (cost optimization) except `hve-phase-implementor` which uses `model: inherit`. Tool access is scoped: researchers use Read/Write/Glob/Grep/WebFetch (read-only); implementors use Read/Write/Edit/Glob/Grep/Bash (code changes); validators use Glob/Grep (analysis only) [HIGH]

5. **install.sh — Idempotent Installation Script** — Copies `.claude/commands/hve*.md` and `.claude/agents/hve*.md` to target project; merges HVE block into target's CLAUDE.md between markers (safe for re-runs; preserves user's `## Your Project` section); adds `.gitignore` rules for `.claude-hve-tracking/**/subagents/` and `.claude-hve-tracking/sandbox/` (commits durable artifacts, ignores regenerable noise) [HIGH]

6. **Tracking Folder Structure & Artifacts** — `.claude-hve-tracking/` holds research/, plans/+logs/, details/, changes/, reviews/rpi/, reviews/pr/, challenges/, memory/, doc-ops/, sandbox/. Artifacts named with `YYYY-MM-DD/task-slug-suffix.md`. Consolidated findings in research/, per-subagent findings in research/subagents/. Plan phases tracked separately from research. Changes log updated iteratively per phase. Reviews split into RPI validation and PR review [HIGH]

7. **Coding Instructions — 12 Language/Tool Files** — Instructions for bash.md, python.md, python-uv.md, python-tests.md, csharp.md, csharp-tests.md, rust.md, rust-tests.md, terraform.md, markdown.md, git-commit-messages.md, writing-style.md. Each defines style, naming, error handling, tooling (e.g., bash: `set -euo pipefail`, 2-space indent; python: PEP 8 + ruff + type annotations required; rust/c#/terraform follow language conventions) [HIGH]

## Codebase References

`.claude/commands/hve.md` — orchestrator (full RPI loop with checkpoints)
`.claude/commands/hve-research.md` — phase 1 (research questions, parallel subagents, consolidation)
`.claude/commands/hve-plan.md` — phase 2 (plan + details + log artifacts, validation)
`.claude/commands/hve-implement.md` — phase 3 (phase-by-phase execution, testing, security checks)
`.claude/commands/hve-review.md` — phase 4 (RPI validation + quality checks, severity grading)
`.claude/commands/hve-pr-review.md` — standalone PR review (8 dimensions, parallel subagents)
`.claude/commands/hve-memory.md` — session persistence
`.claude/commands/hve-challenge.md` — adversarial questioning
`.claude/commands/hve-doc-ops.md` — documentation QA
`.claude/commands/hve-prompt-builder.md` — iterative prompt engineering (test-evaluate-update loop)
`.claude/commands/hve-prompt-analyze.md` — static evaluation of existing prompts
`.claude/commands/hve-prompt-refactor.md` — cleanup and convention compliance
`.claude/commands/hve-git-commit.md` — safe staging, conventional message generation
`.claude/commands/hve-git-merge.md` — merge/rebase/rebase-onto with conflict handling
`.claude/commands/hve-git-setup.md` — git config audit and setup
`.claude/agents/hve-researcher.md` — subagent: targeted investigation (7-finding response format)
`.claude/agents/hve-phase-implementor.md` — subagent: execute one plan phase (code writing + log update)
`.claude/agents/hve-plan-validator.md` — subagent: validate plan against research
`.claude/agents/hve-rpi-validator.md` — subagent: validate phase implementation against plan
`.claude/agents/hve-implementation-validator.md` — subagent: 10-dimension quality check
`.claude/agents/hve-prompt-tester.md` — subagent: test prompt/agent behavior
`.claude/agents/hve-prompt-evaluator.md` — subagent: evaluate against quality criteria
`.claude/agents/hve-prompt-updater.md` — subagent: refactor findings
`install.sh` — idempotent installer (copies, merges, adds gitignore rules)
`.claude/settings.local.json` — permissions/hooks configuration
`README.md` — project overview and quick-start
`CLAUDE.md` — comprehensive HVE methodology, command reference, tracking structure, artifact naming, confidence markers, citation format, subagent protocol, severity grading, security hygiene
`instructions/bash.md` through `instructions/writing-style.md` — language-specific conventions

## External References

None — all information is self-contained in the HVE Claude repository.

## Checklist

- [x] Identified all 15 slash commands and their purpose
- [x] Documented 8 subagents, their models, and tool scoping
- [x] Verified install.sh script behavior and idempotency
- [x] Mapped tracking folder structure and artifact naming
- [x] Enumerated all 12 instruction files and their coverage
- [ ] Detailed command workflow diagrams (visual reference for README)
- [ ] Extracted example invocations for each command (for quick-start guide)

## Clarifying Questions

None — all information verified directly from source files.
