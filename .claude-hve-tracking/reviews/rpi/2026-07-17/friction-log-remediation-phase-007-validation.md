# RPI Validation: Friction Log Remediation — Phase 7
Date: 2026-07-17
Plan phase: JavaScript and TypeScript instructions files
Coverage: 100%
Status: Fail: 0 critical, 0 major, 1 minor

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 7.1: Read existing instruction files for shared structure | Found | `.claude/instructions/javascript.md:1-3, typescript.md:1-5` | ✅ Implemented |
| Step 7.2: Author `.claude/instructions/javascript.md` | Found | `.claude/instructions/javascript.md` (56 lines) | ✅ Implemented |
| Step 7.3: Author `.claude/instructions/typescript.md` | Found | `.claude/instructions/typescript.md` (54 lines); references javascript.md:5 | ✅ Implemented |
| Assumption: Test enumeration sites check and update (if any) | Found | `tests/lib/instruction-files.sh:15-16, install.sh:93-94, tests/run-install-tests.sh:159,260,361,387` | ✅ Implemented |

## Findings

### RV-001 [MINOR]
**Record consistency — claim without file evidence**

Plan item: Phase 7 changes log claims `tests/run-drift-tests.sh:94` was updated to change "12 HVE instruction files" comment to "14".

Evidence: Grep across `tests/run-drift-tests.sh` yields no line containing "12 HVE instruction files" or "14 HVE instruction files". Line 94 of the actual file is the closing brace of the `frontmatter_value()` function definition, not a comment. The file contains no comment about instruction file counts.

Impact: The changes log claim is unsubstantiated by file evidence. This is a record-consistency defect: either the line number is wrong, or the modification was never made. Does not block Phase 7 completion (the critical enumeration sites were updated correctly), but indicates either a documentation error or a missed edit.

Recommendation: (1) Verify whether Phase 7 implementor intended to update a comment in run-drift-tests.sh and if so, which line was intended; (2) if no such comment exists and should not, mark this changes-log entry as `superseded — see Correction YYYY-MM-DD` with a note that the run-drift-tests.sh file was not modified in Phase 7.

---

## Unlisted Changes

None detected. All file modifications claimed in the changes log that are verifiable (javascript.md, typescript.md, three enumeration sites) are present in the codebase and align with plan requirements.

---

## Research Coverage

**Phase 7 research requirement (per research.md):**
- Missing instructions files for JavaScript and TypeScript, and no fallback rule for unlisted languages — a literal follower blocks at a numbered step (F-08 + O-13, 2 repos) [HIGH]

**Verification:**
1. ✅ `.claude/instructions/javascript.md` exists (56 lines, covers ES modules, const/let, async/await, error handling, equality, package scripts, formatting)
2. ✅ `.claude/instructions/typescript.md` exists (54 lines, references javascript.md and adds strict mode, public-API types, no-`any` rules, type-only imports, narrowing, nullability)
3. ✅ Both files follow shared structure pattern observed in rust.md and python.md (headings, bulleted guidance, rationale)
4. ✅ TypeScript file correctly references javascript.md on line 5 rather than duplicating JS rules (success criterion met)
5. ✅ Three enumeration sites updated consistently: `tests/lib/instruction-files.sh` (lines 15-16), `install.sh` (lines 93-94), `tests/run-install-tests.sh` (4 count assertions at lines 159, 260, 361, 387)
6. ✅ **Phase 1 Step 1.9 verification**: JavaScript and TypeScript rows DO appear in CLAUDE.md Instructions Reference table at lines 277-278, confirming the deferred table-row edit was completed by Phase 1 (not duplicated by Phase 7)
7. ✅ Block 17 fallback rule is present in CLAUDE.md (lines 187-190): "If no instructions file exists for the language at hand, do not block: follow the dominant conventions of the existing code in the repo, and note the missing instructions file in the changes log."

**Phase 8 validation (per changes log):**
- `tests/run-drift-tests.sh` and `tests/run-install-tests.sh` both passed (125/0 and 48/0 respectively)

**Research gap resolution:** F-08 + O-13 (missing JS/TS instructions causing literal block at numbered step) is RESOLVED.

---

## Coverage Calculation

**Total plan steps for Phase 7:** 3 (Step 7.1, 7.2, 7.3)
**Steps implemented:** 3 (all plan steps completed)
**Coverage:** 3/3 × 100% = **100%**

**Enumeration sites verified:** 3/3 (instruction-files.sh, install.sh, run-install-tests.sh all updated)
**Success criteria met:** 4/4
- Both files exist ✅
- Both follow shared structure ✅
- TypeScript references JavaScript ✅
- Enumeration tests pass ✅

---

## Status Assessment

**Plan alignment:** Phase 7 completed all three core steps (7.1, 7.2, 7.3) with high-quality implementation.

**Test gate:** Install tests pass 48/0; drift tests pass 125/0 (parent-confirmed in Phase 8). The single minor record-consistency issue does not affect functional correctness.

**Deviations (recorded, not blocking):**
- JS/TS table rows deferred to Phase 1 to avoid cross-phase conflict; Phase 1 successfully added them (CLAUDE.md:277-278). ✅

**Severity triage:**
- **Critical:** None. All required functionality present.
- **Major:** None. No specification deviations.
- **Minor:** One record-consistency finding (RV-001: unverified claim about run-drift-tests.sh:94 comment).

---

## Verdict: **FAIL** (1 minor record-consistency issue)

Phase 7 is functionally complete and meets the plan. The minor record-consistency issue (RV-001) is a documentation defect in the changes log, not a code defect. It does not block completion but should be resolved by annotation before marking the changes log as ✅ Complete per CLAUDE.md corrections convention.

**Recommended next action:** Annotate the run-drift-tests.sh claim in the changes log as `(superseded — see Correction YYYY-MM-DD)` and append a `Correction (2026-07-17):` entry explaining that the file was not modified in Phase 7, or that the line number was incorrect.
