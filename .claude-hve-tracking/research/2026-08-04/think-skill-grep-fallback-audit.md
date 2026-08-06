# Research: Audit repo source files for two harness bugs patched directly in another machine's ~/.claude install
Date: 2026-08-04
Task slug: think-skill-grep-fallback-audit
Confidence: HIGH overall

## Summary

Both reported bugs are confirmed live in this repo's committed source files, and both are **incomplete fixes from prior HVE work**, not new discoveries. Bug 1 (`/think` treated as an invokable command) still exists at `.claude/commands/hve.md:85` and `.claude/commands/hve-plan.md:49` — a 2026-06-12 plan (`hve-workflow-tightening`) already fixed the identical wording in `hve-review.md` but never extended that fix to the other two carriers. Bug 2 (no Grep-fallback note for the read-only research phase) does not exist anywhere in this repo's committed `.claude/commands/hve-research.md` or `.claude/agents/hve-researcher.md`; the fallback sentence the user's other session added exists only in the live-installed `~/.claude` copy, confirmed by comparing this session's own live `hve-research` skill render (which already carries the patch) against the on-disk repo file (which does not). This is exactly the global-install-drift scenario in `[[project-global-install-state]]` memory — a direct edit to `~/.claude` that never flowed back into the repo (the source of truth per CLAUDE.md's "Installing HVE in Your Project" section).

## Key Findings

### Bug 1 — `/think` invoked as a nonexistent slash command

- `.claude/commands/hve-plan.md:49` — "If THINK_MODE is true, begin this phase by invoking `/think` to reason through task complexity..." — still present, unfixed. [HIGH]
- `.claude/commands/hve.md:85` — "2. If THINK_MODE is true, invoke `/think` before drafting the plan to reason through task complexity..." — still present, unfixed. [HIGH]
- `.claude/commands/hve-review.md:129` — already correctly phrased: "use extended reasoning to think through severity weights and cross-dimension conflicts before writing the final verdict block." No `/think` invocation language remains here. [HIGH]
- No other command or agent file references `/think` as an invocation target (full grep across `.claude/commands/*.md` and `.claude/agents/*.md`); `hve-implement.md:19` only parses the `THINK_MODE` flag, it never invokes anything. [HIGH]
- Root cause traced through tracking history: the bug originated in the 2026-06-06 plan (`.claude-hve-tracking/plans/2026-06-06/claude-code-slash-commands-hve-plan.md:34,37-39`), which directed implementation to literally "prepend `/think`" in three files (hve-plan.md, hve.md, hve-review.md) — even though the originating research (`.claude-hve-tracking/research/2026-06-06/claude-code-slash-commands-hve.md:16`) only described `/think` as a Claude Code capability ("extended thinking (chain-of-thought reasoning)") at `[MEDIUM]` confidence, never asserting it was a callable slash command. [HIGH]
- The 2026-06-12 `hve-workflow-tightening` plan caught this as opportunistic Step 4.4 ("Fix `/think` wording ... to match the `--think` flag mechanism", `plans/2026-06-12/hve-workflow-tightening-plan.md:69`) but scoped the fix to `hve-review.md` only; the changes log confirms only `hve-review.md:110` was touched (`changes/2026-06-12/hve-workflow-tightening-changes.md:119`). `hve.md` and `hve-plan.md` were never revisited. [HIGH]
- Fix precedent already exists in-repo: `hve-review.md:129`'s current phrasing ("use extended reasoning to think through ... before writing...") is the established replacement pattern — the Plan phase should mirror it into `hve.md:85` and `hve-plan.md:49` rather than inventing new wording. [HIGH]

### Bug 2 — No Grep-tool fallback for the read-only research phase

- `.claude/commands/hve-research.md:47` (repo, on disk) reads only: "Use Glob and Grep to do a quick orientation of the codebase..." — no fallback clause for Grep being unavailable. [HIGH]
- `.claude/agents/hve-researcher.md:29-30` (repo, on disk) — Step 1 "Orient" instructs "Use Glob to find files..." / "Use Grep to search for key symbols..." with no fallback or unavailability handling anywhere in the file. [HIGH]
- This session's own live `hve-research` skill invocation (sourced from the installed `~/.claude`, not this repo) rendered a materially different Phase 1 step 2: "...If no standalone Grep tool is available in this session, fall back to Glob plus targeted Read calls — never add Bash to route around this; the research phase stays read-only by design regardless of what the harness happens to expose." This confirms the other session's patch is live in the installed copy but absent from the repo. [HIGH]
- Both carrier files explicitly forbid adding Bash as a workaround (`hve-research.md:73`: "Do not add Bash to this command to work around this — the research phase stays read-only by design."), so a Grep-outage without a Glob+Read fallback genuinely blocks the phase rather than degrading gracefully — the bug is load-bearing, not cosmetic. [HIGH]
- `.claude/commands/hve.md` (the orchestrator) also lists `Grep` in `allowed-tools` (line 4) but has no dedicated orientation-with-fallback instruction block of its own; unlike the two research carriers it also has `Bash`, so a Grep outage there is lower-severity and out of the two files the user named, but the Plan phase should decide whether the same fallback note belongs there for consistency. [MEDIUM]
- No other command/agent file was flagged by the user's report; a full-repo grep for "Grep" confirms 13 other files reference the tool (`hve-doc-ops.md`, `hve-challenge.md`, `hve-plan.md`, `hve-pr-review.md`, `hve-implement.md`, `hve-pr-reviewer.md`, `hve-phase-implementor.md`, `hve-review.md`, `hve-implementation-validator.md`, `hve-plan-validator.md`, `hve-prompt-evaluator.md`, `hve-rpi-validator.md`) but none were named in the report and none were audited beyond a presence check — treat as out of scope unless the Plan phase decides otherwise. [MEDIUM]

### Process finding — global install drift

- `~/.claude/commands/hve.md`, `~/.claude/commands/hve-plan.md`, `~/.claude/commands/hve-research.md`, `~/.claude/agents/hve-researcher.md` were edited directly in another project's session rather than in this repo followed by `./install.sh --global`. Per `[[project-global-install-state]]`, the global install is marker-managed specifically to prevent hand-edits like this; the divergence found here is the predicted failure mode. This repo's copies are the ones that should carry the fix; a subsequent `./install.sh --global` run resyncs the machine-wide copy once the repo is corrected — no manual copy needed. [HIGH]

## Codebase References

- `.claude/commands/hve.md` — orchestrator; Bug 1 site at line 85, also declares `Grep` in allowed-tools at line 4
- `.claude/commands/hve-plan.md` — Bug 1 site at line 49
- `.claude/commands/hve-review.md` — already-fixed precedent wording at line 129
- `.claude/commands/hve-research.md` — Bug 2 site at line 47; Bash-forbidden rule at line 73
- `.claude/agents/hve-researcher.md` — Bug 2 site at lines 29-30 (no fallback anywhere in file)
- `.claude-hve-tracking/research/2026-06-06/claude-code-slash-commands-hve.md:16` — origin of the correct, non-literal `/think` framing
- `.claude-hve-tracking/plans/2026-06-06/claude-code-slash-commands-hve-plan.md:34,37-39` — where the literal-invocation wording was introduced
- `.claude-hve-tracking/plans/2026-06-12/hve-workflow-tightening-plan.md:69` and `.claude-hve-tracking/changes/2026-06-12/hve-workflow-tightening-changes.md:119` — the prior partial fix, scoped only to `hve-review.md`

## External References

None consulted — this is a self-contained repo audit; no external docs needed.

## Open Questions

- Should the Grep-fallback note also be added to `.claude/commands/hve.md`'s own orientation usage, even though it has Bash available as a lower-severity backstop? [MEDIUM confidence lean: not required, but flag for Plan phase]
- Should the exact fallback wording be re-authored, or is the phrasing surfaced by this session's live (patched) skill render trustworthy enough to reuse verbatim? It was written by Claude in a prior session, not sourced from official docs — treat as a strong draft, not gospel.
- Are there other stray `/think`-as-command references anywhere outside `.claude/commands/` and `.claude/agents/` (e.g. `.claude/instructions/`, `CLAUDE.md` itself)? Not checked in this pass — full grep was scoped to commands/agents only.
- Does `.claude/instructions/` or any onboarding doc describe `--think` behavior in a way that also needs the same wording fix for consistency?

## Recommended Research Follow-On

- [ ] Grep `.claude/instructions/*.md` and both `CLAUDE.md` files for stray `/think` invocation language before the Plan phase finalizes scope
- [ ] Decide in Plan phase whether `hve.md`'s Grep-based orientation also needs the fallback note for consistency, even though it has Bash as a backstop
- [x] Confirm no other repo consumer (tests, drift suite in `tests/run-drift-tests.sh`) asserts the current (buggy) `/think`-invocation wording as a pinned canonical block — checked: `tests/run-drift-tests.sh` has zero matches for "think", so no drift test pins the buggy wording and a rewording is safe. [HIGH]
