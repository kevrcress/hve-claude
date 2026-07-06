# RPI Validation: HVE Workflow Tightening — Phase 1
Date: 2026-06-12
Plan phase: CLAUDE.md conventions (Changes #4 + #5)
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 1.1: Extend `## Citation Format` with snapshots-vs-living-docs rule | Found | `CLAUDE.md:165` | ✅ Implemented |
| Step 1.2: Add `## Corrections in Tracking Artifacts` convention section after `## Confidence Markers` | Found | `CLAUDE.md:142-151` | ✅ Implemented |

## Findings

### FV-001 [RULE-PAIRING CONFORMANCE]
Both author-side rules in Phase 1 land with their paired checker-side acceptance checks in downstream phases:
- Step 1.1 (Citation Format distinction) is cited in Phase 5, Step 5.1 (`hve-implementation-validator.md:80` Dimension 11 Living-doc definition) and in Phase 3, Step 3.3 (`hve-phase-implementor.md:66` self-correction substep referencing CLAUDE.md corrections convention)
- Step 1.2 (Corrections convention) is cited in Phase 3 (`hve-phase-implementor.md:66`, Step 3.3) and Phase 4 (`hve-review.md:114` gate conjunct; `hve-rpi-validator.md:49` Step 2 bullet)

All four downstream checker references verified in file evidence [HIGH].

## Verification Details

### Step 1.1: Citation Format Extension
**Expected:** Append snapshots-vs-living-docs paragraph after "No markdown hyperlinks in findings." (after line 163 per CLAUDE.md structure)

**File evidence:** `CLAUDE.md:165`
```
**Snapshots vs. living docs:** `file:line` citations are for dated tracking artifacts 
(`.claude-hve-tracking/` — snapshots that age with their date). Living docs (any tracked 
markdown outside `.claude-hve-tracking/`, e.g. contributor guides, READMEs, architecture 
notes) anchor to symbols instead (`Class.Method`, function names), optionally with a dated 
line hint ("as of YYYY-MM-DD"), and prefer pointing at tests as compile-checked living 
examples. Line numbers in living docs rot silently after the first edit to the cited file.
```

**Fidelity check:** Compares against details-doc text (lines 17-22). Exact match; hard-wrapped lines in details doc joined into single paragraph per CLAUDE.md house style. No wording changes. [HIGH]

### Step 1.2: Corrections in Tracking Artifacts Convention
**Expected:** New section between `## Confidence Markers` and `## Citation Format`, with convention rules (1. annotation in place; 2. dated Correction entry) and pre-announcement of Phase 4 gate.

**File evidence:** `CLAUDE.md:142-151`
```
## Corrections in Tracking Artifacts

Falsified statements in tracking artifacts are never silently rewritten. When later work 
proves an earlier claim wrong:

1. Annotate the stale claim in place: `(superseded — see Correction YYYY-MM-DD)`
2. Append a dated `Correction (YYYY-MM-DD):` entry in the owning phase's section explaining 
   what was learned and what the claim should have said

The phase that learns the corrected information owns writing the correction. A changes log 
that contradicts itself without correction annotations cannot be graded ✅ Complete in review.
```

**Fidelity check:** Compares against details-doc text (lines 28-39). Exact match; hard-wrapped lines joined per house style. Last sentence ("A changes log...") serves as pre-announcement per details-doc note line 42. No wording weakening. [HIGH]

**Location check:** Confirmed positioned between `## Confidence Markers` (line 130) and `## Citation Format` (line 153). [HIGH]

## Corrections in Changes Log
Per changes log line 26, a dated correction was already recorded:
- `Correction (2026-06-12): Phase 1's entry cites the review gate at `.claude/commands/hve-review.md:55,109`; Phase 4's insertions shifted those lines to 60/114. The Phase 1 claim was accurate when written (superseded — see this correction).`

This correction is properly formatted and annotated in the changes log. The Phase 1 validation output (this document) does not contradict this; the line-number shift is a downstream artifact of Phase 4's insertions, not a Phase 1 implementation error. [HIGH]

## Research Coverage

### Change #4: Dated Corrections Convention [CRITICAL]
**Requirement** (writeup #4): Falsified tracking-artifact statements are never silently rewritten — annotate in place ("superseded — see Correction YYYY-MM-DD") + append dated Correction in the owning phase's section; the phase that learns the corrected info owns the correction.

**Verification:** 
- Step 1.2 implements the convention with exact annotation rule (line 146) and dated Correction entry ownership rule (lines 147-148). [HIGH]
- Last sentence pre-announces the Phase 4 gate: "cannot be graded ✅ Complete in review" (line 149), which ties to downstream enforcement (Phase 4 Step 4.3, Phase 3 Step 3.3 substep 4). [HIGH]
- Annotation phrase `(superseded — see Correction YYYY-MM-DD)` matches downstream search grep target in plan Testing Approach line 103. [HIGH]

**Coverage:** ✅ Fully met

### Change #5: Living-Doc Citation Rot Check [CRITICAL]
**Requirement** (writeup #5): `file:line` for dated tracking artifacts (snapshots); living docs anchor to SYMBOLS, optional dated line hints ("as of YYYY-MM-DD"), prefer tests.

**Verification:**
- Step 1.1 implements the distinction with explicit definitions: `file:line` = snapshots in `.claude-hve-tracking/`; living docs = symbols + optional dated hints + prefer tests (lines 165). [HIGH]
- Definition of living docs ("any tracked markdown outside `.claude-hve-tracking/`") matches research specification exactly. [HIGH]
- Examples given ("`Class.Method`, function names") match writeup intent. [HIGH]

**Coverage:** ✅ Fully met

## Unlisted Changes
No changes to CLAUDE.md outside the two planned insertions for Phase 1. Verification:
- Grep for other lines edited in CLAUDE.md between Phase 1 (2026-06-12T00:00) and Phase 1 completion: none reported in changes log. [HIGH]

## Summary

**Status: ✅ Pass**

Phase 1 is **100% complete**. Both plan steps land exactly as specified:

1. **Step 1.1 (Citation Format)** — snapshots-vs-living-docs distinction appended; exact wording from details doc with house-style line-wrapping adjustment
2. **Step 1.2 (Corrections convention)** — new section inserted between Confidence Markers and Citation Format; all three rule elements present (annotation phrase, dated Correction ownership, gate pre-announcement); no wording weakened

Both changes carry **[HIGH]** confidence (exact file evidence, specification match). The conventions are immediately cited by downstream phases (Phase 3 Step 3.3, Phase 4 Steps 4.2–4.3, Phase 5 Step 5.1), confirming pairing integrity.

No contradictions. No missing enforcement checkpoints. Dated correction in changes log (line 26) properly annotated per the new convention itself.

**RPI validation gate:** ✅ Critical findings: 0. Major findings: 0. Minor findings: 0. Phase 1 validated as Complete.
