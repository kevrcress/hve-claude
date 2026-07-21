# RPI Validation: Unowned-File Convention Remediation — Phase 8
Date: 2026-07-21
Plan phase: Phase 8 (rpi-validator instruction repair — Q-202 + DRY minor)
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 8.1: Disambiguate unlisted-changes check to whole-document scope | Found | `.claude/agents/hve-rpi-validator.md:50` | ✅ Implemented |
| Step 8.2: Collapse duplicated research-absent rule to single statement | Found | `.claude/agents/hve-rpi-validator.md:34-35` | ✅ Implemented |

## Findings

### RV-008 [MINOR]
Plan item: Step 8.2 — research-absent rule stated exactly once with canonical wording  
Evidence: Changes log claims wording is "byte-identical to the details doc and to `.claude/agents/hve-plan-validator.md:34`". Verified:
- hve-rpi-validator.md:35 sub-bullet carries exact canonical wording from details.md:66-68 ✅
- hve-plan-validator.md:34 includes same core phrase plus plan-validator-specific tail (`"Note the absence in the DR-/DD- log...Steps 2–3, skipping the research-based checks"`)

Changes log claims cross-file byte-identity that does not hold; the full hve-plan-validator.md:34 includes plan-specific context appropriately absent from the rpi-validator version. The implementation is correct (canonical core wording is present and unduped); only the log's description slightly overstates byte-identity.
Impact: Changes log record-consistency — misleading but not affecting the implementation
Recommendation: Treat as cleared; the two agents correctly carry different tails appropriate to their roles

## Unlisted Changes
All 17 files on the parent-supplied changed-file list are accounted for across all phases of the changes log: Phases 1–9 own the modifications; Phase 0, 6, 10 own no repo files. No unlisted changes detected.

## Research Coverage
Phase 8 addresses a plan-licensed QA item (Q-202: clarify unlisted-changes scope ambiguity) and a DRY deduplication (minor). These are not research-backed requirements; the plan authorized the repairs directly. Research document confirms these are execution-quality issues (not correctness issues): M-01 is a false-assurance bug, the research established it as real. Phase 8 fixes the agent instruction per plan Step 8.1 and deduplicates per Step 8.2.

## Detailed Verification

### Step 8.1 — Unlisted-changes scope clarification (line 50)
Requirement: "Disambiguate 'the changes log' to state explicitly that the comparison is against the ENTIRE changes log, not only this phase's `### Phase N:` section; retain the 'If the parent supplied no list, do not infer one.' clause"

Evidence: `.claude/agents/hve-rpi-validator.md:50` reads:
```
4. Compare the parent-supplied changed-file list against the entire changes log — every 
`### Phase N:` section in the document, not only this phase's section. Any file on the 
list but absent from the log is an unlisted change; grade per severity. If the parent 
supplied no list, do not infer one.
```

Verification: 
- ✅ "entire changes log" explicitly names the whole scope
- ✅ "every `### Phase N:` section in the document, not only this phase's section" removes the ambiguity by naming both the scope boundary (entire document) and the exclusion (not phase-scoped)
- ✅ "If the parent supplied no list, do not infer one." clause retained verbatim
- ✅ Trailing clause preserved with exact wording

**Status: Implemented as specified**

### Step 8.2 — Research-absent rule deduplication (lines 34-35)
Requirement: "Collapse the duplicated research-absent rule; preserve the details-doc canonical wording as the surviving copy; result in a single statement stated exactly once"

Evidence: `.claude/agents/hve-rpi-validator.md:34-35` Pre-requisite item 4:
```
4. Read the research document if the parent supplied one
   - If the parent reports research as absent (plan header reads `Research: none — [reason]`), 
     skip requirement extraction. Record in the output: "Validated against the plan alone; 
     research was recorded absent at planning time." Do not manufacture requirements the 
     research never stated.
```

Grep verification: `grep -n "research as absent" .claude/agents/hve-rpi-validator.md` returns only line 35 (single match) ✅

Canonical wording check: The sub-bullet (line 35) matches exactly the canonical wording from `.claude-hve-tracking/details/2026-07-20/unowned-file-remediation-details.md:66-68`:
```
If the parent reports research as absent (plan header reads `Research: none — [reason]`), 
skip requirement extraction. Record in the output: "Validated against the plan alone; 
research was recorded absent at planning time." Do not manufacture requirements the 
research never stated.
```
✅ Byte-identical to details doc canonical wording

Comparison with hve-plan-validator.md:34: The plan-validator carries the same core phrase plus plan-specific context ("Note the absence in the DR-/DD- log and validate the plan for internal consistency only"). The rpi-validator correctly omits this tail (not applicable to review validation). The agent is appropriately role-scoped. ✅

**Status: Implemented as specified; single statement confirmed**

### Correction block verification (details doc)
The details doc (`.claude-hve-tracking/details/2026-07-20/unowned-file-remediation-details.md`) carries a Correction appended by Phase 10 at lines 42–50, annotating that the unlisted-changes canonical block (lines 36–40) is now superseded by the live carrier in `.claude/agents/hve-rpi-validator.md:50`. The Correction documents the change and directs readers to the live source. ✅ Present and correctly annotated.

## Test Results
Phase 8 changes log reports: `207 passed, 0 failed` (no new tests added in this phase; test baseline held). Changes did not break drift-test coverage. ✅

## Coverage Summary
- Step 8.1: ✅ Implemented — line 50 disambiguates scope
- Step 8.2: ✅ Implemented — rule stated exactly once, canonical wording preserved
- Total plan steps for phase: 2
- Implemented: 2
- **Coverage: 100%**

## Record-Consistency Note
The changes log (line 380) claims the wording is "byte-identical to the details doc and to `.claude/agents/hve-plan-validator.md:34`". This is accurate for the details doc (verified ✅) but slightly overstated for the hve-plan-validator.md comparison: the plan-validator's statement includes plan-specific context appropriately omitted from the review-validator's version. Both agents correctly carry the canonical core phrase; the tail divergence is role-appropriate, not an inconsistency. Flagged as Minor record-description issue only; implementation correctness is unaffected.
