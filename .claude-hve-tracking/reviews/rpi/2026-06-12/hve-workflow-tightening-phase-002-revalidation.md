# RPI Validation: HVE Workflow Tightening — Phase 2 (Re-validation)
Date: 2026-06-12
Plan phase: Phase 2 — Change #1 pair (hve-plan.md + hve-plan-validator.md)
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 2.1: Insert Plan-Step Evidence Rules block | Found | `.claude/commands/hve-plan.md:84-90` | ✅ Implemented |
| Step 2.2: Update step example to model confidence marker | Found | `.claude/commands/hve-plan.md:67-68` | ✅ Implemented |
| Step 2.3: Extend Phase 3 validator instruction | Found | `.claude/commands/hve-plan.md:127` | ✅ Implemented |
| Step 2.4: Add two bullets to validator Step 2 | Found | `.claude/agents/hve-plan-validator.md:41-42` | ✅ Implemented |
| Step 2.5: Widen DD- template Source line | Found | `.claude/agents/hve-plan-validator.md:71` | ✅ Implemented |

## Findings

### RV-001 [MINOR]
**Category:** Line number citation aging (expected post-review correction)

The changes log cites `.claude/commands/hve-plan.md:83-89` and `:126` for Steps 2.1 and 2.3. Due to the post-review IV-005 rework of the step example at hve-plan.md:67-68 (shifted from 1 line to 2 lines), these insertions were shifted down by 1 line: Evidence Rules block is now at **:84-90** and Phase 3 instruction is now at **:127**. The changes log carries a dated Correction entry (2026-06-12, post-review) annotating this drift and explaining the cause per the CLAUDE.md corrections convention. No new findings — this is correct application of the convention.

## Verification Details

### Step 2.1 — Plan-Step Evidence Rules block
**Claimed location:** `.claude/commands/hve-plan.md:83-89` (per changes log phase 2 entry)
**Actual location:** `.claude/commands/hve-plan.md:84-90` (post-IV-005 shift)
**Content verified:** ✅ All three rules present:
- "confirmed" / "verified" forbidden without evidence (line 88)
- Every key assumption MUST carry `[HIGH]`/`[MEDIUM]`/`[LOW]` (line 89)
- Impossible-verification → mark `[MEDIUM]`/`[LOW]` + emit guard step (line 90)

**Wording integrity:** ✅ Exact match to details doc; no weakening of MUST language or rule logic.

### Step 2.2 — Step example confidence marker
**Claimed location:** `.claude/commands/hve-plan.md:67`
**Actual location:** `.claude/commands/hve-plan.md:67-68`
**Content verified:** ✅ Two-line form as specified by details doc Step 2.2:
- Line 67: `- [ ] Step 1.1: [Specific action] — \`file:line\` reference if applicable`
- Line 68: `  - Assumption: [what is assumed about the environment or existing state] [MEDIUM]`

**Wording integrity:** ✅ Exact match to details spec; confidence marker `[MEDIUM]` present in standalone Assumption sub-line per the form reworked in IV-005.

### Step 2.3 — Phase 3 validator instruction extended
**Claimed location:** `.claude/commands/hve-plan.md:126` (per changes log)
**Actual location:** `.claude/commands/hve-plan.md:127` (post-IV-005 shift)
**Content verified:** ✅ Bullet extends to include both checks:
- "flagging any "confirmed"/"verified" claim not adjacent to the command or citation that produced it"
- "and any plan-step assumption missing a confidence marker"

**Wording integrity:** ✅ Exact match to details doc; both conjuncts present as independent clauses.

### Step 2.4 — Two validator Step 2 bullets
**Claimed location:** `.claude/agents/hve-plan-validator.md:41-42`
**Actual location:** `.claude/agents/hve-plan-validator.md:41-42` ✅ (no shift; hve-plan-validator.md was not edited before)
**Content verified:** ✅ Both bullets present in correct order:
- **Unearned verification claims** (line 41): forbids unverified "confirmed"/"verified" not adjacent to command/citation; emits DD- scaled to gate severity
- **Missing confidence markers** (line 42): flags assumptions lacking `[HIGH]`/`[MEDIUM]`/`[LOW]`; emits DD- per item

**Wording integrity:** ✅ Exact match to details doc; MUST-carry language and DD- emission preserved; severity scaling rule intact.

### Step 2.5 — DD- template Source line widening
**Claimed location:** `.claude/agents/hve-plan-validator.md:69`
**Actual location:** `.claude/agents/hve-plan-validator.md:71` (shift due to Step 2.4 multi-line expansion)
**Content verified:** ✅ Source line reads:
`Source: [Plan step with an unverified assumption or unearned verification claim]`

**Original text:** `[Plan step that makes an unverified assumption]`
**Change:** "or unearned verification claim" appended ✅
**Wording integrity:** ✅ Exact match to details doc; both paths covered in single clause.

## Rule-Pairing Verification

Phase 2 specifies that author-side rules in hve-plan.md must pair with checker-side acceptance checks in hve-plan-validator.md for the rule to be effective (per research cross-cutting principle).

| Author-side Rule | Checker-side Acceptance |
|---|---|
| Plan-Step Evidence Rules: forbid unearned "confirmed"/"verified" (hve-plan.md:88) | Unearned verification claims bullet (hve-plan-validator.md:41) — ✅ paired |
| Plan-Step Evidence Rules: MUST-carry confidence markers (hve-plan.md:89) | Missing confidence markers bullet (hve-plan-validator.md:42) — ✅ paired |
| Phase 3 instruction: pass both checks to validator (hve-plan.md:127) | Both bullets exist and are called out as Step 2 discrepancy checks (hve-plan-validator.md:36-42) — ✅ paired |
| DD- template widening (hve-plan-validator.md:71) | Template Source field now covers both unverified assumptions AND unearned claims — ✅ integrated |

**Pairing status:** ✅ All author-side rules carry corresponding checker-side enforcement bullets. No orphaned rules.

## Research Coverage

Phase 2 success criterion per plan: "hve-plan.md forbids unearned 'confirmed'/'verified', mandates per-step confidence markers, defines impossible-verification guard steps; hve-plan-validator.md Step 2 contains both checks (unearned claims; missing markers) emitting DD- items."

**Research requirement:** Each of 5 changes is an author-side rule paired with a checker-side enforcer (cross-cutting principle, research doc line 21-32).

| Requirement | Evidence | Status |
|---|---|---|
| Author-side rule forbids unearned "confirmed"/"verified" | hve-plan.md:88 | ✅ Present |
| Evidence must accompany claim (command or file:line) | hve-plan.md:88 | ✅ Specified |
| Per-step confidence markers MUST | hve-plan.md:89 | ✅ Present |
| Impossible-verification → guard step | hve-plan.md:90 | ✅ Present |
| Checker-side: Unearned verification claims detection | hve-plan-validator.md:41 | ✅ Present; emits DD- |
| Checker-side: Missing confidence marker detection | hve-plan-validator.md:42 | ✅ Present; emits DD- |
| DD- template reflects both failure modes | hve-plan-validator.md:71 | ✅ "unverified assumption or unearned verification claim" |
| Validator Phase 3 instruction includes both checks | hve-plan.md:127 | ✅ Both clauses present |

## Unlisted Changes

Grep for files modified but not explicitly cited in Phase 2 changes log:

- `.claude/commands/hve-plan.md` — only lines cited in changes log (67-68, 84-90, 127)
- `.claude/agents/hve-plan-validator.md` — only lines cited in changes log (41-42, 71)
- No other files modified in Phase 2 ✅

## Post-Review Edit Annotation

The changes log carries the following correction for this phase (line 27):
> "Correction (2026-06-12, post-review): Phase 2's entries cite `.claude/commands/hve-plan.md:83-89` and `:126`; the post-review IV-005 rework of the step example (1 line → 2 lines) shifted these to 84-90 and 127. Claims were accurate when written."

This is correct per CLAUDE.md corrections convention: the stale line numbers are annotated in place, and a dated Correction entry owned by the phase that discovered the drift explains the shift. No re-validation finding needed — the convention is working as intended.

## Confidence Assessment

- **Step 2.1 evidence:** HIGH — all three rule bullets present and word-for-word match
- **Step 2.2 evidence:** HIGH — two-line Assumption format matches details doc Step 2.2 spec exactly
- **Step 2.3 evidence:** HIGH — both conjuncts present in single instruction clause
- **Step 2.4 evidence:** HIGH — two bullets present with exact wording, DD- emission specified
- **Step 2.5 evidence:** HIGH — template Source field widened correctly
- **Rule pairing:** HIGH — every author rule has corresponding checker-side acceptance check
- **Research coverage:** HIGH — all Phase 2 success criteria met
