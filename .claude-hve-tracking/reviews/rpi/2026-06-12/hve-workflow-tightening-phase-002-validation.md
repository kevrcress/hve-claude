# RPI Validation: Apply 5 Workflow-Tightening Prompt Changes — Phase 2
Date: 2026-06-12
Plan phase: Change #1 pair — plan command + plan validator
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 2.1: Insert Plan-Step Evidence Rules after plan template | Found | `.claude/commands/hve-plan.md:83-89` | ✅ Implemented |
| Step 2.2: Step example models confidence marker | Found | `.claude/commands/hve-plan.md:67` | ✅ Implemented |
| Step 2.3: Extend Phase 3 validator instruction with both checks | Found | `.claude/commands/hve-plan.md:126` | ✅ Implemented |
| Step 2.4: Add two Step 2 bullets to validator | Found | `.claude/agents/hve-plan-validator.md:41-42` | ✅ Implemented |
| Step 2.5: Widen DD- template Source line | Found | `.claude/agents/hve-plan-validator.md:71` | ✅ Implemented |

## Findings

### Cross-Check: Rule-Pairing Verification

Phase 2 introduced Change #1 as a paired rule system: author-side in `hve-plan.md` and checker-side in `hve-plan-validator.md`.

**Author-side rule enforcement:**
- `hve-plan.md:83-89` contains the complete `### Plan-Step Evidence Rules` block with three bullets forbidding unearned "confirmed"/"verified", mandating confidence markers, and requiring guard steps for impossible verifications [HIGH]
- `hve-plan.md:67` models a confidence marker in the step example: `(e.g. "target state assumed stable [MEDIUM]")` [HIGH]
- `hve-plan.md:126` extends the Phase 3 validator instruction: "including flagging any \"confirmed\"/\"verified\" claim not adjacent to the command or citation that produced it, and any plan-step assumption missing a confidence marker" [HIGH]

**Checker-side acceptance:**
- `hve-plan-validator.md:41-42` adds two bullets:
  - Line 41: `**Unearned verification claims**: any "confirmed"/"verified" not immediately adjacent to the evidence that produced it...`
  - Line 42: `**Missing confidence markers**: every key assumption in a plan step MUST carry [HIGH]/[MEDIUM]/[LOW]...`
  Both emit as `DD-` items [HIGH]
- `hve-plan-validator.md:71` widened the DD- template Source line from "unverified assumption" to "unverified assumption or unearned verification claim" — exact match to change requirement [HIGH]

**Rule-pairing status:** Both author and checker rules present. No gaps in the pairing. Wording preserved without weakening: MUST stays MUST, forbidden remains forbidden, DD- emissions intact. Step example shows a live confidence marker in position. Details doc text ("forbidden", "MUST", "AND") all preserved verbatim through line joins to match house style.

## Verification Evidence

All five plan steps claimed in the changes log map to exact file locations:

1. **Step 2.1:** `.claude/commands/hve-plan.md:83-89` — block opens with `### Plan-Step Evidence Rules` (line 83), contains all three rules (lines 85-89), closes before `### Artifact 2`. Positioned after the Implementation Plan template (line 81, the closing triple-backtick fence) and before the next section. No insertion gaps. [HIGH]

2. **Step 2.2:** `.claude/commands/hve-plan.md:67` — the step example template line now reads:
   ```
   - [ ] Step 1.1: [Specific action] — `file:line` reference; key assumptions carry a confidence marker (e.g. "target state assumed stable [MEDIUM]")
   ```
   The phrase `(e.g. "target state assumed stable [MEDIUM]")` models the confidence marker per details doc Step 2.2. [HIGH]

3. **Step 2.3:** `.claude/commands/hve-plan.md:126` — extends the Phase 3 validation instruction bullet to include both "confirmed"/"verified" flag and "missing markers" flag. The exact phrase "including flagging any \"confirmed\"/\"verified\" claim not adjacent to the command or citation that produced it, and any plan-step assumption missing a confidence marker" matches details doc Step 2.3. [HIGH]

4. **Step 2.4:** `.claude/agents/hve-plan-validator.md:41-42` — two bullets added to the Step 2 checklist after "Dependency errors" (line 40):
   - Unearned verification claims (line 41) — phrasing matches details doc: "any \"confirmed\"/\"verified\" not immediately adjacent", "must be one that could have failed", "Emit as `DD-`". [HIGH]
   - Missing confidence markers (line 42) — phrasing matches: "every key assumption...MUST carry [HIGH]/[MEDIUM]/[LOW]", "Flag each...as `DD-`". [HIGH]

5. **Step 2.5:** `.claude/agents/hve-plan-validator.md:71` — in the DD- template output format, the Source field reads:
   ```
   Source: [Plan step with an unverified assumption or unearned verification claim]
   ```
   This widened from the original pattern to include "or unearned verification claim" — exact match to details Step 2.5 requirement. [HIGH]

## Research Coverage

The research document (`.claude-hve-tracking/research/2026-06-12/hve-workflow-tightening.md`) specifies Phase 2 requirements at lines 46-61:

1. **Earned "confirmed" + markers rule in hve-plan.md** — Verified present at `.claude/commands/hve-plan.md:83-89` with all three bullets intact, including the "confirmed"/"verified" forbidden rule. [HIGH]

2. **Checker-side acceptance in hve-plan-validator.md Step 2 bullets** — Verified present at `.claude/agents/hve-plan-validator.md:41-42` with both bullets (Unearned claims + Missing markers) emitting DD- items. [HIGH]

3. **No bloat / integration into existing blocks** — Both changes integrated into existing command/agent flows: the Evidence Rules block sits between the plan template and Artifact 2 (not appended), the validator bullets sit in the existing Step 2 checklist, the DD- template wording replaces existing text in place. [HIGH]

4. **Wording strength preserved** — All mandatory language (MUST, forbidden, both prongs for AND conditions) retained verbatim. No rule weakening detected. [HIGH]

## Unlisted Changes

No files modified outside of the two target files (hve-plan.md and hve-plan-validator.md) for Phase 2. The changes log comprehensively lists all changes for this phase.

## Cross-Phase Dependencies

Phase 2 depends on Phase 1 (CLAUDE.md conventions). The validator instruction at `hve-plan.md:126` cites CLAUDE.md indirectly ("per CLAUDE.md" at line 88 in the Evidence Rules block). The confidence-marker requirement references "per CLAUDE.md" at line 88, tying the rule to the upstream convention. Phase 1 implementation status: verified at `.claude-hve-tracking/changes/2026-06-12/hve-workflow-tightening-changes.md:37-41` (CLAUDE.md conventions added). No blocking dependency issues. [HIGH]

## Summary

Phase 2 implementation is **complete and correct**. All five plan steps have corresponding, verified file changes. Rule-pairing is intact: author-side rules in hve-plan.md (Evidence Rules block, step example, validator instruction) are paired with checker-side acceptance in hve-plan-validator.md (Step 2 bullets, DD- template wording). No wording was weakened. Integration is clean — no appended sections, all changes sit within existing blocks or replace existing text. Confidence markers on all key findings ([HIGH]). Coverage: 5/5 steps = 100%.
