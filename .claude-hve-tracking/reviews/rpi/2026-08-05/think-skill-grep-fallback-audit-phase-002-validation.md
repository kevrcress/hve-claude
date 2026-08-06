# RPI Validation: Fix `/think`-as-command wording and add Grep-fallback note to the two read-only research carriers — Phase 2
Date: 2026-08-05
Plan phase: Phase 2 — Add Grep-fallback note to the two read-only research carriers
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 2.1: Add Grep-unavailable fallback to hve-research.md:47 | Found | `.claude/commands/hve-research.md:47` | ✅ Implemented |
| Step 2.2: Add Grep-unavailable fallback to hve-researcher.md:30 | Found | `.claude/agents/hve-researcher.md:30` | ✅ Implemented |
| Step 2.3: Confirm no change needed in hve.md (no inline orientation line) | Confirmed | `.claude/commands/hve.md:63-77` | ✅ Verified |

## Findings

None. All plan steps for Phase 2 correctly implemented and verified.

### Verification Detail

**Step 2.1 — `.claude/commands/hve-research.md:47`**
- Expected replacement text: `2. Use Glob and Grep to do a quick orientation of the codebase (entry points, relevant modules, config files). If no standalone Grep tool is available in this session, fall back to Glob plus targeted Read calls — never add Bash to route around this; the research phase stays read-only by design regardless of what the harness happens to expose.`
- Actual line 47: Matches exactly [HIGH]
- Bash constraint satisfied: YES — text explicitly forbids Bash ("never add Bash to route around this") [HIGH]

**Step 2.2 — `.claude/agents/hve-researcher.md:30`**
- Expected replacement text: `2. Use Grep to search for key symbols, function names, or patterns relevant to the question. If no standalone Grep tool is available in this session, fall back to Glob (broad filename/pattern matching) plus targeted Read calls for content search — do not reach for Bash to work around this; this agent stays read-only by design regardless of what the harness happens to expose.`
- Actual line 30: Matches exactly [HIGH]
- Bash constraint satisfied: YES — text explicitly forbids Bash ("do not reach for Bash to work around this") [HIGH]

**Step 2.3 — `.claude/commands/hve.md` (lines 63-77, Phase 1 — Research section)**
- Plan requirement: Confirm no inline "Use Glob and Grep" orientation line exists; hve.md should delegate orientation to hve-researcher subagent
- Actual behavior: Line 68 delegates orientation: "Spawn `hve-researcher` subagents in parallel (one per research theme)..." [HIGH]
- Inline orientation present: NO [HIGH]
- No-edit decision validated: CORRECT

## Research Coverage

Plan Phase 2 directly addresses Research Bug 2 findings:

1. **Research finding**: ".claude/commands/hve-research.md:47 (repo, on disk) reads only: 'Use Glob and Grep...' — no fallback clause for Grep being unavailable."
   - Status: ✅ RESOLVED — fallback clause now present at exact line cited

2. **Research finding**: ".claude/agents/hve-researcher.md:29-30 (repo, on disk) — Step 1 'Orient' instructs 'Use Glob...' / 'Use Grep...' with no fallback or unavailability handling anywhere in the file."
   - Status: ✅ RESOLVED — fallback clause now present at hve-researcher.md:30

3. **Research constraint**: "Neither carrier suggests Bash as a workaround"
   - Status: ✅ SATISFIED — Both files explicitly forbid Bash as a fallback route

## Unlisted Changes

No unlisted changes. Changed-file list supplied by parent:
- `.claude/agents/hve-researcher.md` — In scope (Step 2.2); found in changes log
- `.claude/commands/hve-research.md` — In scope (Step 2.1); found in changes log
- `.claude/commands/hve-plan.md` — Out of Phase 2 scope (Phase 1); not checked
- `.claude/commands/hve.md` — Out of Phase 2 scope (Phase 1 Step 1.1); Step 2.3 verified no Phase 2 changes needed

All Phase 2 in-scope files are represented in the changes log.

## Summary

Phase 2 achieves 100% coverage (3/3 plan steps implemented or verified). Both Grep-fallback additions match the plan's replacement strings verbatim and satisfy the explicit constraint against suggesting Bash as a workaround. The decision not to edit hve.md is verified as correct — it delegates orientation to subagents rather than inlining an orientation step. All research requirements for Bug 2 are met.
