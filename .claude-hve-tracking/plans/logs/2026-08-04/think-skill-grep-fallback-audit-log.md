# Planning Log: think-skill-grep-fallback-audit

## Discrepancies

### DD-001: Exact replacement wording sourced from live install, not re-authored
Source: Research's open question — "Should the exact fallback wording be re-authored, or is the phrasing surfaced by this session's live (patched) skill render trustworthy enough to reuse verbatim?"
Assumption: The wording already live in `~/.claude/commands/{hve.md,hve-plan.md,hve-research.md}` and `~/.claude/agents/hve-researcher.md` is fit to copy verbatim into the repo — it has been running in this exact session (this plan phase itself executed under the patched `hve-plan.md` text) with no observed defect.
Risk: The live wording was authored by Claude in an unreviewed prior session, not sourced from official Claude Code docs. Low risk here since it is a plain English clarification, not a technical/API claim, and it is already validated by having executed correctly in two live sessions (this one, plus whatever session patched it).
Status: Resolved — plan adopts the live wording verbatim (Phase 1 Steps 1.1/1.2, Phase 2 Steps 2.1/2.2).

### DD-002: `hve.md` orchestrator does not get its own fallback note
Source: Research's open question — "Should the Grep-fallback note also be added to `.claude/commands/hve.md`'s own orientation usage, even though it has Bash available as a lower-severity backstop?"
Assumption: `hve.md` has no inline "Use Glob and Grep" orientation instruction of its own to attach a note to — it delegates orientation entirely to the spawned `hve-researcher` subagent (confirmed by reading `hve.md` lines 61-68 during planning, see details doc).
Risk: If a future edit to `hve.md` re-inlines an orientation step (rather than delegating), that new text would need its own fallback note and this plan would not have added it. Low likelihood; flagged here for the next session that touches `hve.md`'s Phase 1.
Status: Resolved — no action in this plan (Phase 2, Step 2.3 records the decision).

### DR-001: Stray `/think` references outside `.claude/commands/` and `.claude/agents/`
Source: Research's open question — "Are there other stray `/think`-as-command references anywhere outside `.claude/commands/` and `.claude/agents/` (e.g. `.claude/instructions/`, `CLAUDE.md` itself)? Not checked in this pass."
Resolution: Checked during planning — `grep -rn '/think' .claude/instructions/*.md CLAUDE.md` returned zero matches in both the project `CLAUDE.md` and the user's global `CLAUDE.md`. No further action needed; scope is confirmed to be exactly the four lines in this plan's two phases.
Status: Resolved.
