# Implementation Plan: Apply 5 Workflow-Tightening Prompt Changes
Date: 2026-06-12
Task slug: hve-workflow-tightening
Research: .claude-hve-tracking/research/2026-06-12/hve-workflow-tightening.md
Status: Draft

## Overview

Apply Changes #1–#5 from `2026-06-12-hve-workflow-tightening-writeup.md` across 8 files, using
the insertion points pinpointed by the five 2026-06-12 prompt-analyze reports. Every author-side
rule lands with its checker-side acceptance check in the same pass. Edits integrate into existing
blocks and templates — no parallel appended sections.

## Phases

### Phase 1: CLAUDE.md conventions (Changes #4 + #5)
Dependencies: none
Estimated scope: 1 file (CLAUDE.md), ~25 lines
Success criteria: Citation Format distinguishes dated snapshots (`file:line`) from living docs
(symbol anchors, dated hints, prefer tests); a dated-corrections convention exists stating stale
claims are annotated in place ("superseded — see Correction YYYY-MM-DD") with a dated Correction
entry owned by the phase that learned it.

Steps:
- [ ] Step 1.1: Extend `## Citation Format` (CLAUDE.md:142-152) with snapshots-vs-living-docs rule — living doc = tracked `.md` outside `.claude-hve-tracking/` [HIGH, per impl-validator report PA-003/PA-004]
- [ ] Step 1.2: Add `## Corrections in Tracking Artifacts` convention section after `## Confidence Markers` (CLAUDE.md:138) — never silently rewrite; annotate + dated Correction entry; owning phase writes it [HIGH, writeup #4 text]

### Phase 2: Change #1 pair — plan command + plan validator
Dependencies: Phase 1 (cites the conventions)
Estimated scope: 2 files, ~30 lines
Success criteria: hve-plan.md forbids unearned "confirmed"/"verified", mandates per-step
confidence markers, defines impossible-verification guard steps; hve-plan-validator.md Step 2
contains both checks (unearned claims; missing markers) emitting DD- items.

Steps:
- [ ] Step 2.1: Insert `### Plan-Step Evidence Rules` in hve-plan.md after the Implementation Plan template (after line 81, before `### Artifact 2` at line 83) with the three writeup-#1 bullets [HIGH, plan report insertion point]
- [ ] Step 2.2: Update step example at hve-plan.md:67 to model a confidence marker [HIGH]
- [ ] Step 2.3: Extend Phase 3 validator instruction at hve-plan.md:118 to pass the two new checks to the validator [HIGH, plan report PA-005]
- [ ] Step 2.4: Add two bullets to hve-plan-validator.md Step 2 (lines 36-41): **Missing confidence markers** and **Unearned verification claims**, both emitting DD- [HIGH, validator report PA-001/PA-002]
- [ ] Step 2.5: Widen DD- template wording at hve-plan-validator.md:69 from "unverified assumption" to "unverified assumption or unearned verification claim" [HIGH, validator report PA-003]

### Phase 3: Changes #2/#3/#4 implementor-side — agent + command
Dependencies: Phase 1 (cites the corrections convention)
Estimated scope: 2 files, ~45 lines
Success criteria: implementor has the STOP-and-log-DR rule (with local DR- gloss), the two-prong
won't-fix rule in Constraints, the pre-Complete self-correction substep, and structured DR-/DD- +
Corrections homes in the changes-log template; hve-implement.md mirrors the template and tells the
parent to surface DR-/STOP returns to the user instead of auto-advancing.

Steps:
- [ ] Step 3.1: Insert Change #2 STOP rule in hve-phase-implementor.md Step 2 after the blocker block (after line 50), with one-line DR- gloss ("DR- = discrepancy discovered during implementation") [HIGH, implementor report PA-001/PA-005]
- [ ] Step 3.2: Add Change #3 two-prong won't-fix rule to hve-phase-implementor.md Constraints (lines 100-106) [HIGH, implementor report PA-002]
- [ ] Step 3.3: Add Change #4 self-correction substep to hve-phase-implementor.md Step 3 (after line 57), referencing the CLAUDE.md correction convention [HIGH, implementor report PA-003]
- [ ] Step 3.4: Add `#### Discrepancies & Decisions (DR-/DD-)` and `#### Corrections` subsections to the Step 4 changes-log template (hve-phase-implementor.md:64-81) [HIGH, implementor report PA-004]
- [ ] Step 3.5: Mirror the two template subsections in hve-implement.md changes-log structure (lines 36-61) [HIGH]
- [ ] Step 3.6: Add parent-side receiver to hve-implement.md Phase 2 (after step 5, line 78): on returned DR- or STOP (functional or Major+ deviation), surface to user before continuing [HIGH, implementor report coordination note]

### Phase 4: Change #4 reviewer-side — review command + rpi validator
Dependencies: Phase 1 (gate references the convention)
Estimated scope: 2 files, ~25 lines
Success criteria: hve-review.md has a whole-log record-consistency scan step, a Record Consistency
template section + summary line, and a ✅ Complete gate conjunct requiring an internally consistent
changes log; hve-rpi-validator.md Step 2 flags intra-phase contradictions as Minor RV- findings.

Steps:
- [ ] Step 4.1: Add record-consistency scan to hve-review.md Phase 1 (after reading artifacts, line 30-32 area): re-read changes log end-to-end, flag un-annotated contradictions as Minor [HIGH, review report PA-002 — load-bearing producing step]
- [ ] Step 4.2: Add `## Record Consistency` section + summary line to the review-log template (hve-review.md:45-56) [HIGH, review report PA-003]
- [ ] Step 4.3: Add consistency conjunct to the ✅ Complete gate (hve-review.md:109); contradictions without corrections → ⚠️ Needs Rework [HIGH, review report PA-001]
- [ ] Step 4.4: Fix `/think` wording at hve-review.md:105 to match the --think flag mechanism [HIGH, review report PA-005, opportunistic]
- [ ] Step 4.5: Add intra-phase contradiction bullet to hve-rpi-validator.md Step 2 (lines 42-48): Minor RV- "record consistency" finding; cross-phase synthesis stays with the parent [HIGH, review report PA-004]

### Phase 5: Change #5 — implementation validator + review dimension sync
Dependencies: Phase 1 (convention), Phase 4 (both edit hve-review.md — sequenced to avoid conflicts)
Estimated scope: 2 files, ~25 lines
Success criteria: hve-implementation-validator.md has Dimension 11 Documentation Integrity with a
runnable Grep procedure and a living-doc definition; scope enum includes `documentation` and
`overall-quality`; counts read "eleven"; Coverage Notes always mentions the citation-check result;
hve-review.md Phase 3 dimension list shows 11 dimensions.

Steps:
- [ ] Step 5.1: Add `### 11. Documentation Integrity` to hve-implementation-validator.md with living-doc definition + Grep procedure (basename sweep → symbol existence check) and Minor severity for dead refs [HIGH, impl-validator report PA-001/PA-004]
- [ ] Step 5.2: Add `documentation` and `overall-quality` tokens to the scope enum (hve-implementation-validator.md:20) [HIGH, PA-002]
- [ ] Step 5.3: Update "ten"/"Ten" → "eleven"/"Eleven" (lines 9, 25) [HIGH, PA-005]
- [ ] Step 5.4: Add Coverage Notes instruction: note citation-check result even when clean (lines 121-122) [HIGH, PA-006]
- [ ] Step 5.5: Update hve-review.md Phase 3 list (lines 87-97) to 11 dimensions including Documentation integrity [HIGH, sync requirement from research]

## Risk Log
| Risk | Likelihood | Mitigation |
|---|---|---|
| Bloat — added rules read as bolted-on sections | Medium | Integrate into existing blocks/templates; review phase checks line-count delta and placement |
| DR- prefix confusion (plan-log vs impl-time) | Medium | One-line gloss in implementor (Step 3.1); CLAUDE.md untouched on this point |
| Dimension-count drift between hve-review.md and validator | Low | Steps 5.3 + 5.5 in same phase; review validates both |
| Edit conflicts on hve-review.md (Phases 4 and 5 both touch it) | Low | Phase 5 depends on Phase 4 — sequential |

## Testing Approach
No executable tests — these are prompt files. Verification happens in the review phase by running
these checks and recording their actual output in the changes log (per-pair rule-presence greps;
each could fail by returning no match):

1. Change #1 pair: `grep -c "confirmed.*verified\|Unearned verification" .claude/commands/hve-plan.md .claude/agents/hve-plan-validator.md` — both files must match
2. Change #2: `grep -n "MUST NOT" .claude/agents/hve-phase-implementor.md` and `grep -n "DR-" .claude/commands/hve-implement.md` — both must match
3. Change #3: `grep -n "both prongs\|ORIGINAL criterion" .claude/agents/hve-phase-implementor.md` — must match
4. Change #4: `grep -n "superseded — see Correction" CLAUDE.md .claude/agents/hve-phase-implementor.md .claude/commands/hve-review.md .claude/agents/hve-rpi-validator.md` — all four must match
5. Change #5: `grep -n "Documentation Integrity" .claude/agents/hve-implementation-validator.md` and `grep -n "11 dimensions\|Documentation integrity" .claude/commands/hve-review.md` — both must match

Plus a bloat check (`git diff --stat` on the 8 files; expect roughly +25 lines per phase estimate)
and a placement check that no rule landed as a disconnected appended section. Rule-pairing is a
post-implementation claim: it is asserted only in the review log, next to this recorded output.
