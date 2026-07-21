# RPI Validation: Unowned-File Remediation — Phase 9
Date: 2026-07-21
Plan file: .claude-hve-tracking/plans/2026-07-20/unowned-file-remediation-plan.md
Phase: Phase 9 — Residual documentation drift (2 Minor)
Coverage: 100% (2/2 steps)
Status: Pass

## Validation Summary

Phase 9 addresses two Minor findings (stale wording residue and incomplete living-doc description). Both plan steps have been verified in the implementation against the live file tree. The phase depends on Phase 2.1's sequential dispatch being complete and Phase 2.3's Template Integrity criterion being defined.

---

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 9.1: Remove "After both subagents complete" from hve-prompt-builder.md:61; reword to sequential | Found | `.claude/commands/hve-prompt-builder.md:42,52,61` | ✅ Implemented |
| Step 9.2: Add Template Integrity criterion to docs/internals.md:25; anchor per living-doc rule | Found | `docs/internals.md:25` + `.claude/agents/hve-prompt-evaluator.md:56-59` | ✅ Implemented |

---

## Step-by-Step Verification

### Step 9.1: Sequential Wording in hve-prompt-builder.md

**Plan requirement:** Replace "After both subagents complete" (residue of parallel design) with wording matching Step 2.1's sequential tester→evaluator dispatch.

**Evidence found:**

1. `.claude/commands/hve-prompt-builder.md:42` — "wait for it to complete before evaluating — the evaluator reads the test execution log the tester writes" — enforces sequential dependency
2. `.claude/commands/hve-prompt-builder.md:52` — "After the tester completes, spawn the `hve-prompt-evaluator` subagent" — explicit sequencing
3. `.claude/commands/hve-prompt-builder.md:61` — "Once the evaluator returns, read both logs — the tester's execution log from Step A and the evaluator's findings from Step B" — names both subagent outputs in sequential order

**Verification:** The phrase "After both subagents complete" does not appear anywhere in the Phase 2 loop (lines 40–65). The wording throughout uses sequential language ("wait... before", "After the tester completes", "Once the evaluator returns") that matches the tester→evaluator→updater pipeline established by Step 2.1.

**Status:** ✅ Implemented

---

### Step 9.2: Template Integrity Criterion in Living Doc

**Plan requirement:** Add Template Integrity criterion to `docs/internals.md:25` (the hve-prompt-evaluator row); anchor to symbol/section name per CLAUDE.md living-doc rule, not file:line.

**Evidence found:**

1. `docs/internals.md:25` — hve-prompt-evaluator row now reads: "Rates draft prompts against clarity / completeness / actionability / format / no-Copilot / Template Integrity criteria (the last checks every template blank is fillable in-session or carries an N/A branch)"

2. Criterion definition verification — `.claude/agents/hve-prompt-evaluator.md:56-59` defines:
   ```
   ### Template Integrity
   - Is every template blank fillable from information available in-session?
   - Does every blank that might be unfillable carry an explicit N/A branch (example: `Tests: N/A - no test runner in repo`)?
   - Flag as Major any blank that would force a fabricated value or stall the phase.
   ```

3. Citation form check — grep of `docs/internals.md` for `file:\d+` pattern returned **no matches**, confirming no line-number citations were introduced. The anchor is the criterion name "Template Integrity" and the agent name "hve-prompt-evaluator", per the living-doc rule.

4. Bonus repair — the same row also now includes "actionability" (previously omitted from the criteria list), documented in the changes log as a pre-existing gap in the same sentence. This aligns the living doc with the five criteria listed in `.claude/commands/hve-prompt-builder.md:58`.

**Status:** ✅ Implemented

---

## Cross-File Consistency Check

- **Phase 2.1 dispatch sequencing** (`.claude/commands/hve-prompt-builder.md:40–65`) — tester runs, evaluator runs after log is written, updater runs after evaluation. Step 9.1's wording is consistent with this flow.
- **Criteria consistency** — `.claude/commands/hve-prompt-builder.md:58` lists "clarity, completeness, actionability, Claude Code format compliance, absence of Copilot-isms" (5 criteria); `.claude/agents/hve-prompt-evaluator.md:56–84` defines all 5 plus Template Integrity (6 total); `docs/internals.md:25` now names all 6.
- **Template Integrity definition scope** — `.claude/agents/hve-prompt-evaluator.md:75` output template tags include `|TEMPLATE`; line 83 Quality Score line includes "Template integrity: Pass/Fail". Both are present and match the criterion.

---

## Findings

None. Both steps verify cleanly against the implementation. The phase meets its success criteria:
1. No stale parallel-dispatch wording remains in the builder's Phase 2 loop.
2. The internals doc now lists Template Integrity and Actionability criteria with proper symbol-based anchoring (no file:line citations).

---

## Unlisted Changes

The parent-supplied changed-file list includes:
- `.claude/commands/hve-prompt-builder.md` ✓ (Phase 9.1 claims edit at line 61; verified)
- `docs/internals.md` ✓ (Phase 9.2 claims edit at line 25; verified)

No files on the changed list are absent from the changes log.

---

## Research Coverage

Phase 9 targets residual documentation drift after the implementation and review phases. The research document (section "Minor findings", m-03) identifies the Template Blanks convention as unforced in the tooling. Phase 2 Step 2.3 added the criterion to the evaluator agent; Phase 9 Step 9.2 surfaces it in the living documentation, closing the visibility gap. The plan requires the changes to be anchored by symbol, not line number, per CLAUDE.md's living-doc citation rule — verified in step 9.2.

---

## Summary

- **Steps completed:** 2/2 (100%)
- **Critical findings:** 0
- **Major findings:** 0
- **Minor findings:** 0
- **Confidence:** All evidence read directly from the live file tree.

Phase 9 is **complete and ready for merge**.
