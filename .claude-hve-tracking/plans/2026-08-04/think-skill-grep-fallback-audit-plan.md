# Implementation Plan: Fix `/think`-as-command wording and add Grep-fallback note to the two read-only research carriers
Date: 2026-08-04
Task slug: think-skill-grep-fallback-audit
Research: .claude-hve-tracking/research/2026-08-04/think-skill-grep-fallback-audit.md
Status: Draft

## Overview
Two bugs, already fixed and live-validated in the user's globally-installed `~/.claude` copy but never landed back into this repo. Both fixes are known verbatim from diffing `~/.claude/commands/{hve.md,hve-plan.md,hve-research.md}` and `~/.claude/agents/hve-researcher.md` against this repo's copies — this plan applies the exact same text, not a re-authored equivalent. No design decisions remain open.

## Phases

### Phase 1: Fix `/think` invoked as a nonexistent slash command
Dependencies: none
Estimated scope: 2 files, 1 line each
Success criteria: `.claude/commands/hve.md` and `.claude/commands/hve-plan.md` no longer contain the literal string `` `/think` `` as an invocation target; wording matches the already-fixed precedent in `.claude/commands/hve-review.md:129` and the live `~/.claude` copies.

Steps:
- [ ] Step 1.1: In `.claude/commands/hve.md:85`, replace:
  `2. If THINK_MODE is true, invoke \`/think\` before drafting the plan to reason through task complexity, risk surface, and phase ordering.`
  with:
  `2. If THINK_MODE is true, perform an extended reasoning pass (interleaved/extended thinking) on task complexity, risk surface, and phase ordering before drafting the plan. No \`/think\` command exists in Claude Code — describe the behavior, don't invoke it as a slash command.`
  - Assumption: this exact replacement text is the one already live and running in `~/.claude/commands/hve.md:85`, diffed byte-for-byte against the repo copy during planning. [HIGH] — confirmed by `diff ~/.claude/commands/hve.md .claude/commands/hve.md` output showing only this line differs (command run during planning, verbatim single-line diff observed).
- [ ] Step 1.2: In `.claude/commands/hve-plan.md:49`, replace:
  `If THINK_MODE is true, begin this phase by invoking \`/think\` to reason through task complexity, risk surface, and phase ordering before drafting any artifacts.`
  with:
  `If THINK_MODE is true, begin this phase with an extended reasoning pass (interleaved/extended thinking) on task complexity, risk surface, and phase ordering before drafting any artifacts. No \`/think\` command exists in Claude Code — describe the behavior, don't invoke it as a slash command.`
  - Assumption: same as Step 1.1 — this is the live `~/.claude/commands/hve-plan.md:49` text, confirmed via diff during planning (this very plan phase is executing under that already-patched skill render). [HIGH]
- [ ] Step 1.3: Grep the two edited files afterward for the literal substring `` `/think` `` to confirm zero remaining invocation-style references (a mention of `--think` the flag is fine and expected; only the backtick-wrapped slash form is the defect).

### Phase 2: Add Grep-fallback note to the two read-only research carriers
Dependencies: none (independent of Phase 1; both phases may be implemented in either order or concurrently)
Estimated scope: 2 files, 1 line each
Success criteria: `.claude/commands/hve-research.md` and `.claude/agents/hve-researcher.md` instruct a Glob+Read fallback when Grep is unavailable, without ever suggesting Bash as a workaround; wording matches the live `~/.claude` copies exactly.

Steps:
- [ ] Step 2.1: In `.claude/commands/hve-research.md:47`, replace:
  `2. Use Glob and Grep to do a quick orientation of the codebase (entry points, relevant modules, config files)`
  with:
  `2. Use Glob and Grep to do a quick orientation of the codebase (entry points, relevant modules, config files). If no standalone Grep tool is available in this session, fall back to Glob plus targeted Read calls — never add Bash to route around this; the research phase stays read-only by design regardless of what the harness happens to expose.`
  - Assumption: confirmed live text via `diff ~/.claude/commands/hve-research.md .claude/commands/hve-research.md` during planning, single-line diff observed at this position. [HIGH]
- [ ] Step 2.2: In `.claude/agents/hve-researcher.md:30`, replace:
  `2. Use Grep to search for key symbols, function names, or patterns relevant to the question`
  with:
  `2. Use Grep to search for key symbols, function names, or patterns relevant to the question. If no standalone Grep tool is available in this session, fall back to Glob (broad filename/pattern matching) plus targeted Read calls for content search — do not reach for Bash to work around this; this agent stays read-only by design regardless of what the harness happens to expose.`
  - Assumption: confirmed live text via `diff ~/.claude/agents/hve-researcher.md .claude/agents/hve-researcher.md` during planning, single-line diff observed at this position. [HIGH]
- [ ] Step 2.3: Do NOT add the same fallback note to `.claude/commands/hve.md`'s orchestrator. Research confirmed `hve.md` never inlines the "Use Glob and Grep" orientation line itself — it delegates orientation entirely to the `hve-researcher` subagent (Phase 1, Step 1.3 of `hve.md`'s own text: "Spawn `hve-researcher` subagents in parallel"). Once Step 2.2 lands, `hve.md`'s research phase inherits the fix transitively; a duplicate note in `hve.md` would have no orientation line to attach to. [HIGH] — confirmed by reading `.claude/commands/hve.md` lines 61-68 during planning: no "Use Glob and Grep" text present there.

## Out of Scope (recorded, not actioned)

- **Global install resync**: this plan only edits repo files. After Phase 1 and 2 land and are committed, the user should run `./install.sh --global` to resync `~/.claude` — but since `~/.claude` already carries this exact fixed text (it's the source these fixes were copied from), the resync is idempotent and low-urgency, not a blocking follow-up. Not an implementation step because it mutates state outside this repo.
- **`.claude/instructions/*.md` and both `CLAUDE.md` files**: grepped during planning for stray `` /think `` invocation language — zero matches (`grep -rn '/think' .claude/instructions/*.md CLAUDE.md` returned nothing). No fix needed here; research's open question is resolved. [HIGH]
- **Other 13 files referencing "Grep"** (`hve-doc-ops.md`, `hve-challenge.md`, etc.): research flagged these as out of scope since the user's report named only the two research carriers. Not actioned; no evidence any of them share the read-only-with-no-Bash-backstop constraint that makes the fallback load-bearing for the research phase specifically.

## Risk Log
| Risk | Likelihood | Mitigation |
|---|---|---|
| Repo copy drifts from `~/.claude` again after this fix (same root cause recurring) | Medium | Out of scope for this plan (process fix, not a code fix); noted here so a future session can consider a lint/CI check diffing installed vs. repo prompt files. |
| Line-number citations in this plan shift if either file changes before implementation runs | Low | Steps quote the exact old-text string to replace, not just a line number, so Edit will fail loudly (no match) rather than silently editing the wrong line if drift occurs. |

## Testing Approach
No test runner or compiler applies to markdown prompt files. Verification is:
1. Re-run `grep -rn '/think' .claude/commands/*.md .claude/agents/*.md` after Phase 1 — expect zero results for the invocation form (only `--think` flag mentions, which are correct and expected).
2. Re-run `diff` between each of the four edited repo files and their `~/.claude` counterparts — expect the specific line to now match exactly (other lines may still legitimately differ if unrelated drift exists, which is out of scope).
3. Confirm `tests/run-drift-tests.sh` still passes (no test pins the old wording per research; the parent should still run the full suite as a regression guard per this repo's baseline convention).
