# PR Review — Design and Architecture: fix/think-skill-grep-fallback-research
Date: 2026-08-05
Branch: fix/think-skill-grep-fallback-research
Dimension(s): Design and Architecture

## Design and Architecture

No findings. This is a narrowly-scoped, four-line prompt-wording fix across two independent bug classes, and both edits respect existing module boundaries.

### Verification notes (no defect, recorded for traceability)

- **`/think` fix mirrors precedent correctly.** `.claude/commands/hve-plan.md:49` and `.claude/commands/hve.md:85` now use "extended reasoning pass (interleaved/extended thinking)" phrasing that matches the already-fixed precedent at `.claude/commands/hve-review.md:129` ("use extended reasoning to think through severity weights"). Terminology is consistent across all three THINK_MODE call sites. `grep`-checked: no remaining `/think` slash-command references exist anywhere under `.claude/` after this diff.
- **Grep-fallback fix is correctly scoped to read-only, no-Bash carriers.** `.claude/agents/hve-researcher.md:6` frontmatter (`tools: Read, Write, Glob, Grep, WebFetch`) confirms this agent has no Bash tool, so the added fallback clause at line 30 ("do not reach for Bash to work around this") is enforceable, not aspirational. `.claude/commands/hve-research.md` Phase 1 (line 47) carries the parallel clause for the command-level orientation step.
- **Fallback fix was not over-applied to files where it doesn't belong.** Other files with a bare "Use Grep" instruction — `.claude/agents/hve-phase-implementor.md:32` (no tool restriction in frontmatter, inherits Bash) and `.claude/agents/hve-implementation-validator.md:42,152` (frontmatter `tools: Read, Write, Glob, Grep, Bash` at line 6) — both have Bash available as a legitimate fallback, so they correctly fall outside this PR's stated scope ("read-only, no-Bash-allowed research carriers"). No inconsistency introduced.
- **hve.md/hve-plan.md duplication is pre-existing, not introduced by this diff.** `hve.md` inlines the planning protocol from `hve-plan.md` rather than referencing it, so the same THINK_MODE sentence had to be edited in two places. Both copies were updated in lockstep (`hve-plan.md:49`, `hve.md:85`); this diff does not increase or decrease the pre-existing duplication pattern.
- **No new abstractions, files, or module boundaries introduced.** All four edits are single-sentence wording changes within existing sections (`### Step 1 — Orient`, `## Phase 2 — Planning`, `## Phase 1 — Define Research Questions`); a new contributor reading either file would find the fallback/rewording inline with no structural surprise.
