# Implementation Plan: Claude Code Slash Commands and Features for HVE Integration
Date: 2026-06-06
Task slug: claude-code-slash-commands-hve
Research: .claude-hve-tracking/research/2026-06-06/claude-code-slash-commands-hve.md
Details: .claude-hve-tracking/details/2026-06-06/claude-code-slash-commands-hve-details.md
Status: Draft

## Overview

Integrate high-value Claude Code native capabilities into HVE by fixing a confirmed bug, updating documentation, adding an opt-in `--think` flag for extended reasoning, adding a `--compact` grouping mode to `hve-pr-review`, and parallelizing the prompt-builder test/eval cycle. All changes are isolated to `.claude/` files and CLAUDE.md — no runtime code, no install-script changes.

## Phases

### Phase 1: Bug Fixes and Tool-Restriction Tidying
Dependencies: none
Estimated scope: 2 files, < 5 lines each
Success criteria: `hve-challenge` can write its artifact without a tool-permission error; `hve-research` no longer lists `Bash` in `allowed-tools`

Steps:
- [ ] Step 1.1: Add `Write` to the `allowed-tools` frontmatter line in `.claude/commands/hve-challenge.md:4`
- [ ] Step 1.2: Remove `Bash` from the `allowed-tools` frontmatter line in `.claude/commands/hve-research.md:4` — keep `Read, Write, Glob, Grep, Agent`

### Phase 2: Documentation Updates
Dependencies: none
Estimated scope: CLAUDE.md — 2 additions
Success criteria: CLAUDE.md difficulty-adaptive table mentions `--effort` / `effortLevel`; command reference table includes `/batch`

Steps:
- [ ] Step 2.1: In CLAUDE.md, extend the difficulty-adaptive table or add a paragraph under "Difficulty classifications" noting that Challenging tasks benefit from `--effort xhigh` (CLI) or `effortLevel: xhigh` in `.claude/settings.json`

### Phase 3: `--think` Flag Integration
Dependencies: none (each file is independent)
Estimated scope: 3 files — `hve-plan.md`, `hve.md`, `hve-review.md`; ~10–20 lines added per file
Success criteria: Passing `--think` to `hve-plan` or `hve` causes the command to prepend `/think` before the designated reasoning-heavy step; `hve-review` Phase 4 verdict section includes a `/think` instruction when the flag is set

Steps:
- [ ] Step 3.1: In `.claude/commands/hve-plan.md` — add `--think` to `argument-hint`; add a parsing block in Phase 1 that sets `THINK_MODE=true` when `--think` is present; prepend `/think` to the Phase 2 "Planning" prose instruction block when `THINK_MODE=true`
- [ ] Step 3.2: In `.claude/commands/hve.md` — add `--think` to `argument-hint`; propagate flag through Phase 0 difficulty assessment; pass `--think` when invoking the plan phase for Challenging-difficulty tasks (or when explicitly set)
- [ ] Step 3.3: In `.claude/commands/hve-review.md` — add a note in Phase 4 verdict synthesis: if `--think` was passed (or if severity tally is non-trivial), begin the verdict section with `/think` before rendering the final severity table and overall pass/fail verdict

### Phase 4: `hve-pr-review` Compact Mode
Dependencies: none
Estimated scope: `.claude/commands/hve-pr-review.md` — ~20–30 lines
Success criteria: `hve-pr-review --compact` groups the 8 review dimensions into 4 paired subagents; default (no flag) behavior unchanged

Steps:
- [ ] Step 4.1: Add `--compact` to `argument-hint` in `.claude/commands/hve-pr-review.md:3`
- [ ] Step 4.2: Add a flag-parsing block that, when `--compact` is present, defines 4 dimension groups: (1) functional + design, (2) idiomatic + reuse, (3) performance + reliability, (4) security + docs
- [ ] Step 4.3: Add a conditional dispatch block: if compact mode, spawn 4 subagents (one per group) each instructed to cover both dimensions; if not compact, spawn 8 subagents as today

### Phase 5: `hve-prompt-builder` Parallelization
Dependencies: none
Estimated scope: `.claude/commands/hve-prompt-builder.md` — restructure one section
Success criteria: The tester subagent and evaluator subagent are spawned in parallel (two `Agent` calls in one response) rather than sequentially

Steps:
- [ ] Step 5.1: Locate the test-evaluate loop in `.claude/commands/hve-prompt-builder.md`
- [ ] Step 5.2: Restructure the loop body so that the Tester agent and Evaluator agent are described as parallel spawns (spawn both simultaneously, then wait for both before running the Updater)

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| `/think` instruction not recognized if user has no extended-thinking entitlement | Low | Flag is opt-in; document that it requires a plan or Sonnet model that supports extended thinking |
| `--compact` dimension pairing loses nuance (two-dimension subagent misses findings the single-dimension version catches) | Medium | Keep default 8-subagent path unchanged; compact is explicitly opt-in for large PRs |
| Parallel tester + evaluator in prompt-builder read the same draft draft file simultaneously — no write conflict | Low | Both are read-only at that step; updater runs after both complete |
| `argument-hint` is display-only; `--think` parsing must be done in the command body prose, not frontmatter | Low | Plan steps explicitly note this; no frontmatter behavior expected |

## Deferred Work

The following lower-value research items are explicitly deferred and not included in this plan:

- **Shared subagent response format extraction** (research item 7) — Requires touching 8+ agent files with no functional change. Risk of introducing drift or subtle wording differences outweighs the maintenance benefit at this time. Revisit after the higher-value changes stabilize.
- **`alwaysThinkingEnabled` for `hve-plan-validator`** (research item 9) — Exploratory; effect on discrepancy detection quality is unknown. Defer until user feedback from the `--think` flag (Phase 3) is collected and patterns are understood.

## Testing Approach

- Phase 1: Run `hve-challenge` on any existing artifact; confirm the challenge file is created without tool permission error. Verify `hve-research` frontmatter shows no Bash.
- Phase 2: Read CLAUDE.md and confirm both additions are present and accurate.
- Phase 3: Run `/hve-plan --think <any-task-slug>`; confirm the command emits a `/think` call before Phase 2 reasoning. Run `/hve` on a Challenging task; confirm `--think` propagates.
- Phase 4: Run `hve-pr-review --compact` on a branch with >10 changed files; confirm 4 subagents are spawned instead of 8.
- Phase 5: Run `hve-prompt-builder` on a simple prompt; confirm tester and evaluator subagent calls appear in the same turn (parallel).
