# PR Review — Functional Correctness: fix/think-skill-grep-fallback-research
Date: 2026-08-05
Branch: fix/think-skill-grep-fallback-research
Dimension(s): Functional Correctness

## Functional Correctness

### FC-001 [Minor]
Location: `.claude/agents/hve-rpi-validator.md:6`, `.claude/agents/hve-plan-validator.md:6`, `.claude/agents/hve-pr-reviewer.md:6`, `.claude/agents/hve-prompt-evaluator.md:6`
Finding: The PR fixes the Grep-unavailability single point of failure only for the two "research carrier" surfaces (`hve-researcher.md`, `hve-research.md`). Four other agents declare the identical read-only tool profile — `Read, Write, Glob, Grep` with no `Bash` — and would hit the same silent content-search failure if Grep is unavailable in a session, but received no fallback clause and no "stays read-only by design" guard against reaching for Bash. If the underlying harness condition motivating this fix (Grep sometimes absent despite frontmatter grant) is real, these four agents remain exposed to it.
Recommendation: Confirm with the parent whether this fix's scope was deliberately limited to the two research-phase files named in the task description (in which case this is a legitimate scope boundary, not a defect) or whether the same fallback clause should be propagated to `hve-rpi-validator.md`, `hve-plan-validator.md`, `hve-pr-reviewer.md`, and `hve-prompt-evaluator.md` in a follow-up.

## Verification Notes (no findings, recorded for parent's context)

- Confirmed via repo-wide grep that no other `.claude/*.md` file still invokes `/think` as a slash command after this fix — `grep -r "/think" .claude/` only matches the two corrected lines themselves (`hve-plan.md:49`, `hve.md:85`), which now describe it as nonexistent rather than invoke it. Fix for bug (1) is complete and consistent.
- `THINK_MODE` propagation logic in `hve.md:19,48,85` and `hve-plan.md:13,36,49` is internally consistent before and after the edit; no argument-parsing or propagation regression introduced.
- The new Grep-fallback wording in `hve-researcher.md:30` and `hve-research.md:47` correctly characterizes Glob as filename/path matching only ("broad filename/pattern matching"), pairing it with targeted `Read` calls for content search rather than mischaracterizing Glob as a content-search tool.
- Both fallback clauses correctly forbid adding Bash as a workaround, consistent with each file's own `allowed-tools`/`tools` frontmatter (`hve-research.md:4` has no Bash; `hve-researcher.md:6` has no Bash), so the instruction does not contradict the tool grants elsewhere in the same file.
- All four diff hunks apply cleanly against the current file contents (verified by reading each file at the cited pre-image line numbers); no stale-hunk or context-mismatch risk.
