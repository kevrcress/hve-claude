# Prompt Analysis: .claude/commands/hve-plan.md
Date: 2026-06-12
Type: command
Context: Pre-analysis before applying Change #1 from .claude-hve-tracking/challenges/2026-06-12-hve-workflow-tightening-writeup.md
Status: Documented — fixes deferred

## Summary

All findings are gaps relative to Change #1. The file is clean on standard quality criteria (no Copilot-isms, correct frontmatter, sequential phases). No pre-existing defects unrelated to the writeup.

---

## Findings

### PA-001 [COMPLETENESS] [MAJOR]
Issue: No rule forbidding unearned "confirmed"/"verified" language in plan steps.
Evidence: Steps block (line 67) shows only `file:line reference if applicable` — no evidence-discipline constraint anywhere in the file.
Fix: Add a "Plan-Step Evidence Rules" block stating that "confirmed"/"verified" are forbidden unless immediately accompanied by the falsifying check that produced them (exact command or `file:line` citations whose predicate targets the claim itself).
Source: Change #1, bullet 1

### PA-002 [COMPLETENESS] [MAJOR]
Issue: Confidence markers are not enforced in plan steps despite CLAUDE.md mandating them. The writeup explicitly calls this out ("the plan command does not enforce it").
Evidence: `[HIGH]/[MEDIUM]/[LOW]` markers appear nowhere in the file. Step example (line 67) carries no marker. The DD-001 `Assumption:`/`Risk:` fields (lines 103-106) live in a separate artifact and do not force per-step markers in the plan itself.
Fix: Require every key assumption in a plan step to carry `[HIGH]/[MEDIUM]/[LOW]`; update the step example on line 67 to model it (e.g. `Assumption: [target state assumed stable] [MEDIUM]`).
Source: Change #1, bullet 2

### PA-003 [COMPLETENESS] [MAJOR]
Issue: No guard-step mechanism for when plan-time verification is impossible.
Evidence: Phase 2 (lines 39-106) and the plan template have no concept of a deferred implementation-phase guard step; assumptions can only be asserted or logged, never deferred-with-a-check.
Fix: Add rule: when verification is impossible (no build env, etc.), mark the assumption `[MEDIUM]/[LOW]` AND emit an explicit guard step into the implementation phase ("toggle, compile, revert if broken") rather than asserting the outcome.
Source: Change #1, bullet 3

### PA-004 [ACTIONABILITY] [MINOR]
Issue: Existing `file:line reference if applicable` half-covers evidence but conflates location citation with falsifying-check evidence, and "if applicable" makes it optional.
Evidence: Line 67 — `- [ ] Step 1.1: [Specific action] — `file:line` reference if applicable`
Fix: Keep the citation guidance but clarify in the new rules block that citing a location is not the same as confirming an outcome — "Compiles without X" can only be confirmed by compiling without X.
Source: Change #1 (implied — "a grep whose predicate targets the claim itself")

### PA-005 [COMPLETENESS] [MINOR]
Issue: Phase 3 validator instruction scoped too narrowly; the writeup's acceptance check won't fire from this command's instructions.
Evidence: Line 118 — `Instruction to update the Discrepancy Log section only (DR-/DD- items)`
Fix: Extend the validator instruction to also flag (a) any "confirmed/verified" not adjacent to a command/citation and (b) any plan-step assumption lacking a confidence marker.
Source: Change #1, Acceptance criterion

---

## Where Evidence Rules Live Today

One weak line: `file:line reference if applicable` (line 67) plus out-of-band `DD-` Assumption/Risk fields in the Planning Log artifact (lines 103-106). No evidence discipline inside plan steps themselves.

## Conflicts vs. Half-Coverage

No text contradicts Change #1. Gaps are absence and half-coverage:
- Line 67 (`file:line ... if applicable`) **half-covers** and slightly muddies the new rule
- `DD-` Assumption/Risk (lines 103-106) **half-covers** the confidence-marker requirement but in the wrong artifact and without per-step enforcement
- No prohibition, no marker enforcement, no guard-step concept exist at all

## Recommended Insertion Point

New `### Plan-Step Evidence Rules` subsection in Phase 2, inserted **after the Implementation Plan template closes (after line 81) and before `### Artifact 2` (line 83)**.

Rationale: rules govern what may be written into plan steps, so they belong adjacent to the plan template that produces those steps — not in Phase 3 (validation reads them) and not in the Planning Log (discrepancies, not per-step discipline).

Companion edits needed:
1. Update step example on line 67 to show a confidence marker
2. Extend Phase 3 validator instruction on line 118 (PA-005)

---

## Quality Summary
Clarity: PASS
Completeness: FAIL (Change #1 rules absent; CLAUDE.md marker requirement unenforced)
Actionability: PARTIAL (line 67 conflates citation with confirmation)
Format compliance: PASS
No Copilot-isms: PASS

Overall: 5 findings — 0 critical, 3 major, 2 minor
