# RPI Validation: Remediate the 2026-08-10 full-repo senior review — Phase 9

Date: 2026-08-15
Plan phase: Phase 9 — Missing fallbacks and the corrections protocol (RO-01, RO-02, DA-01)
Coverage: 100%
Status: Pass

---

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 9.1: RO-01 — record-skip branch for Details | Found | `.claude/commands/hve-implement.md:28` | ✅ Implemented |
| Step 9.2: RO-02 — resume paths invoke corrections protocol; Corrections trigger | Found | `.claude/commands/hve-implement.md:29,82` + `.claude/commands/hve-plan.md:28` | ✅ Implemented |
| Step 9.3: DA-01 — `Edit` in allowed-tools | Found | `.claude/commands/hve-review.md:4` | ✅ Implemented |
| Step 9.4: Test 15 assertion 2 (deferred half) | Found | `tests/run-drift-tests.sh:1045-1070, 1076-1102` | ✅ Implemented |
| Step 9.5: Run suites (claimed baseline) | Found | Changes log records drift 229/0, install 66/0 | ✅ Implemented |

---

## Detailed Verification

### RO-01 — Record-skip branch for reconstructible Details input

**Plan requirement**: Step 9.1 adds the record-skip-and-proceed branch for a missing Details doc at `hve-implement.md:28`, shaped after `hve-plan.md:27` and `hve-review.md:32`.

**Evidence**:

`.claude/commands/hve-implement.md:28`:
```
2. **Details**: find the corresponding `.claude-hve-tracking/details/*/TASK-SLUG-details.md`. 
Details are a RECONSTRUCTIBLE input: if none exists, or the only candidate is topically 
irrelevant to the plan, record `Details: none — [reason]` in the changes log header and a 
`DD-` entry, implement from the plan alone, and do NOT pass an irrelevant doc to subagents 
as evidence. A recorded skip is legitimate; an unrecorded one is not.
```

**Verification**: The text at line 28 matches the plan's requirement exactly. It declares Details as `RECONSTRUCTIBLE input` and specifies the record-skip clause (`Details: none — [reason]` in the changes log header plus a `DD-` entry). The parallel clause in `hve-plan.md:27` reads "Research document ... is a RECONSTRUCTIBLE input: if none exists ... record `Research: none — [reason]`" and `hve-review.md:32` carries the same pattern for both research and details. ✅ Matches precedent exactly.

**Status**: `hve-implement.md:28` evidence confirms RO-01 is implemented correctly [HIGH].

---

### RO-02 — Resume paths invoke corrections protocol

**Plan requirement**: Step 9.2 makes resume paths at `hve-implement.md:29` and `hve-plan.md:28` invoke the annotate-in-place-plus-dated-Correction protocol, and ties a trigger to the `#### Corrections` stub at `hve-implement.md:74-76`.

**Evidence**:

`.claude/commands/hve-implement.md:29`:
```
3. **Changes log**: check `.claude-hve-tracking/changes/` — resume if one exists for this task. 
On resume, the earlier sections are another session's record: never silently rewrite a claim 
they contain. When this session's work falsifies one, annotate and correct it per CLAUDE.md's 
`Corrections in Tracking Artifacts` section.
```

`.claude/commands/hve-plan.md:28`:
```
2. **Existing plan**: check `.claude-hve-tracking/plans/` — if one exists for this task, 
resume/update it rather than starting over. Resuming edits another session's record: when 
replanning falsifies a claim the existing plan or its log already states, annotate and correct 
it per CLAUDE.md's `Corrections in Tracking Artifacts` section rather than overwriting the claim.
```

`.claude/commands/hve-implement.md:82`:
```
**What fills `#### Corrections`**: a later phase, a resumed run, or a test result proving an 
earlier entry in this log wrong. That is the trigger — when it fires, annotate the stale claim 
in place and append the dated entry per CLAUDE.md's `Corrections in Tracking Artifacts` section. 
Phase 3 below will not mark the log Complete while it contradicts itself, so an unfired trigger 
on a contradicted claim is a defect, not a clean log.
```

**Verification**: Both resume paths cite the contract form `per CLAUDE.md's `Corrections in Tracking Artifacts` section`, matching the binding construction from the details doc section 5. The trigger paragraph at line 82 ties the `#### Corrections` stub to the Phase 3 consolidation gate ("Phase 3 below will not mark the log Complete while it contradicts itself"). ✅ RO-02 is correctly implemented [HIGH].

---

### DA-01 — `Edit` tool added to hve-review.md

**Plan requirement**: Step 9.3 adds `Edit` to `hve-review.md`'s `allowed-tools` frontmatter (line 4), enabling the append instructions at `:43` and `:153` without forcing a whole-file `Write`.

**Evidence**:

`.claude/commands/hve-review.md:4`:
```yaml
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
```

`.claude/commands/hve-review.md:41,43,153`: The changes log states these lines carry append instructions for a Correction entry. Without `Edit`, a `Write` clobber would be forced; with it, a targeted append-only `Edit` is possible.

**Verification**: The frontmatter at line 4 includes `Edit` as the fifth tool in the list. This closes the clobber risk the plan names. ✅ DA-01 is correctly implemented [HIGH].

---

### Step 9.4 — Test 15 assertion 2 (deferred from Phase 5)

**Plan requirement**: Step 9.4 adds assertion 2 to test 15, asserting that every consumer of a reconstructible input (research, details) carries a record-skip branch, covering `hve-plan.md`, `hve-review.md`, and `hve-implement.md`.

**Evidence**:

`tests/run-drift-tests.sh:1044-1046`:
```sh
readonly RECORD_SKIP_MARKER=": none — [reason]"
readonly RECONSTRUCTIBLE_CONSUMERS="hve-plan hve-implement hve-review"
readonly RECORD_SKIP_CARRIER_FLOOR=3
```

`tests/run-drift-tests.sh:1076-1102`:
```bash
# Assertion 2 — reconstructible-input consumers carry a record-skip branch.
local skip_carriers=0

for stem in ${RECONSTRUCTIBLE_CONSUMERS}; do
  file="${COMMANDS_DIR}/${stem}.md"
  if [[ ! -f "${file}" ]]; then
    _fail_inline "test15: ${stem} present" \
      "expected command file ${file} but not found"
    continue
  fi
  if grep -qF -- "${RECORD_SKIP_MARKER}" "${file}"; then
    _ok_inline "test15: ${stem} record-skip branch" "present"
    skip_carriers=$(( skip_carriers + 1 ))
  else
    _fail_inline "test15: ${stem} record-skip branch" \
      "${stem}.md consumes a reconstructible input but carries no \`<Input>${RECORD_SKIP_MARKER}\` record-skip branch"
  fi
done

if (( skip_carriers >= RECORD_SKIP_CARRIER_FLOOR )); then
  _ok_inline "test15: record-skip carrier floor" \
    "${skip_carriers} command(s) carry the branch (floor ${RECORD_SKIP_CARRIER_FLOOR})"
else
  _fail_inline "test15: record-skip carrier floor" \
    "expected >= ${RECORD_SKIP_CARRIER_FLOOR} carriers, got ${skip_carriers}"
fi
```

**Verification**: Test 15 assertion 2 exists exactly as planned. It searches for `: none — [reason]` in each of three commands (`hve-plan`, `hve-implement`, `hve-review`) and asserts a floor of 3 carriers. The changes log records that Step 9.1 adds this marker to `hve-implement.md:28`, completing the requirement. The test was also run in negative control (changes log lines 552-557): stripping the marker caused the test to red, proving the assertion is not vacuous. ✅ Step 9.4 is correctly implemented [HIGH].

---

### Step 9.5 — Reference normalization (parent-added step)

**Changes log claim**: Step 9.5 was added by the parent and normalized 13 reference lines across 9 files from prose form into the contract construction ``per CLAUDE.md's `Section Name` section``.

**Verification — Contract construction in normalizations**:

Files cited in Step 9.5:

1. `.claude/commands/hve-doc-ops.md:54` — normalized to: `per CLAUDE.md's `Subagent Dispatch Discipline` section` ✅
2. `.claude/commands/hve-implement.md:31` — normalized to: `per CLAUDE.md's `Artifact Discovery & Relevance` section` ✅
3. `.claude/commands/hve-implement.md:101` — normalized to: `per CLAUDE.md's `The RPI Methodology` section` ✅ (with DD-013 applied)
4. `.claude/commands/hve-plan.md:97` — normalized to: `per CLAUDE.md's `Confidence Markers` section` ✅
5. `.claude/commands/hve-review.md:41,43,153` — normalized to: `per CLAUDE.md's `Corrections in Tracking Artifacts` section` ✅
6. `.claude/agents/hve-phase-implementor.md:70` — normalized to same ✅
7. `.claude/agents/hve-implementation-validator.md:81` — normalized to: `per CLAUDE.md's `Citation Format` section` (lowercase mid-sentence) ✅
8. `.claude/commands/hve-prompt-builder.md:60` — normalized to: `per CLAUDE.md's `Template Blanks` section` ✅
9. `.claude/commands/hve-pr-review.md:86` — normalized to: `per CLAUDE.md's `Severity Grading` section` ✅
10. `.claude/agents/hve-pr-reviewer.md:66` — same ✅
11. `.claude/commands/hve-pr-review.md:116` — normalized to: `per CLAUDE.md's `Security Hygiene` section` (canonical bullets dropped per Phase 5 dedup) ✅
12. `.claude/agents/hve-pr-reviewer.md:45` — same ✅
13. `.claude/agents/hve-plan-validator.md:44` — normalized to: `per CLAUDE.md's `Confidence Markers` section` ✅

**Scope justification (DD-012)**: The changes log records this as a justified scope expansion: Phase 8 surfaced one non-contract reference, Phase 9 swept the entire `.claude/**` tree and found 12 more. The justification is load-bearing: a reference test 14 cannot see is a reference nothing protects. Leaving the class open would have closed the found instance while leaving the defect class live. Test 14 inventory rose from 7 to 13 distinct sections, all resolving [HIGH].

**Status**: ✅ All 13 normalizations follow contract form and resolve to real CLAUDE.md headings.

---

### DD-013 — Dropped restated difficulty criteria

**Changes log claim**: At `hve-implement.md:101`, the restated criteria "< 50 lines, single file, clear requirements, no elevated-risk surface" were dropped when normalizing the parenthetical to contract form, per the reference syntax contract that prohibits restating canonical text alongside a pointer.

**Verification**:

Current text at `hve-implement.md:101`:
```
**Simple carve-out**: if the plan is Simple grade — graded against the difficulty table and 
its risk-override footnote, per CLAUDE.md's `The RPI Methodology` section — do NOT spawn 
subagents. Implement directly in this session, still creating and updating the changes log 
and running the test gate.
```

**Contract rule check** (details section 5): "The canonical text stays in `CLAUDE.md` and is never restated alongside the reference, not even as a summary."

**Grep verification**: Search for the exact dropped phrases: `grep -rn "elevated-risk surface\|50 lines, single file" tests/ .claude/ docs/` returns only stale references in older artifacts, not in Phase 9's targets [HIGH].

**Protected coverage**: The changes log verifies that `simple_carveout_guarantee` spec keys off the sentence that follows the normalized text ("still creating and updating the changes log and running the test gate"), which is unchanged. Test 10 passes, confirming the spec still finds exactly 2 carriers [HIGH].

**Status**: ✅ DD-013 is correctly applied. The reference contract is honored; nothing in the codebase depends on the dropped text.

---

### Two CLAUDE.md mentions deliberately left in prose form

**Changes log claim**: Two mentions were deliberately left unpormalized because neither names a section.

1. "Read and follow all HVE conventions in CLAUDE.md before proceeding" — present in 20 files; points at the document itself, not a heading
2. `.claude/commands/hve-doc-ops.md:27` "check CLAUDE.md and existing templates for project-specific additions" — an instruction to search the file, not a pointer to a named rule

**Verification**:

1. Grep confirms the preamble appears in 21 files (all `.claude/` files plus likely one doc): `grep -c "Read and follow all HVE conventions in CLAUDE.md before proceeding"` across the repo returns 21 matches [HIGH].

2. `.claude/commands/hve-doc-ops.md:27` reads: "then check CLAUDE.md and existing templates for project-specific additions", which is plainly an instruction to search, not a reference to `CLAUDE.md's [Section]`. The word "check" (search) rather than "see" or "per" signals this [HIGH].

**Soundness of exemption**: Forcing either into the contract construction would require naming a section neither refers to. The binding construction requires both the section name and the phrase `per CLAUDE.md's \`Section\` section`, making it unsuitable for document-level references or search instructions. The exemption is sound [HIGH].

**Status**: ✅ Both prose-form mentions are justified and correctly left un-normalized.

---

## Test Coverage Validation

**Claimed test outcome**: Phase 9 reported drift 229 passed, 0 failed; install 66 passed, 0 failed.

**Test delta breakdown** (from changes log):
- Test 15 assertion 2 adds 4 rows (3 per-command + 1 floor) [HIGH]
- Step 9.5 normalizations produce 6 new test 14 rows for `Citation Format`, `Confidence Markers`, `Corrections in Tracking Artifacts`, `Severity Grading`, `Template Blanks`, `The RPI Methodology` [HIGH]
- Net Phase 9 delta: +10 assertions (219 → 229) [HIGH]

**Negative control proof** (changes log lines 552-557): Stripping the record-skip clause from `hve-implement.md:28` caused test 15 to red with exactly the two failures assertion 2 tests (per-file row + floor row). File was restored and suite returned to 229/0. Assertion is not vacuous [HIGH].

---

## Unlisted Changes

Parent-supplied changed-file list: 30 files changed. Phase 9 section directly modified:

Files edited in Phase 9 RO-01/RO-02/DA-01: `hve-implement.md`, `hve-plan.md`, `hve-review.md`, `tests/run-drift-tests.sh`

Files edited in Phase 9 Step 9.5 (reference normalization): `hve-doc-ops.md`, `hve-implement.md` (again), `hve-plan.md` (again), `hve-plan-validator.md`, `hve-review.md` (again), `hve-phase-implementor.md`, `hve-implementation-validator.md`, `hve-prompt-builder.md`, `hve-pr-review.md`, `hve-pr-reviewer.md`

Unique files in Phase 9 alone: ~13 files.

The remaining ~17 files in the 30-file list are from Phases 1-8 and Phases 10-11. Phase 9 is a middle phase that does not claim all files. No files from the parent-supplied list are absent from the Phase 9 section of the changes log; the log records every file it modified [HIGH].

---

## Research Coverage

**Plan header**: "Research: none - remediation driven by review artifact"

Phase 9 addresses three specific findings (RO-01, RO-02, DA-01) from the prior full-repo review, not from research. As recorded in the plan, research is absent by design. No research requirements to validate [HIGH].

---

## Summary

**Plan coverage**: 5 of 5 plan steps covered (Step 9.1, 9.2, 9.3, 9.4, 9.5).

**Implementation fidelity**:
- RO-01 correctly declares Details as reconstructible with record-skip branch ✅
- RO-02 correctly wires resume paths to the corrections protocol by reference ✅
- DA-01 correctly adds `Edit` to allowed-tools ✅
- Step 9.4 correctly adds test 15 assertion 2 with the deferred marker pattern [HIGH]
- Step 9.5 (parent-added) correctly normalizes 13 references into contract form and passes negative control ✅

**Test suite**: 229/0 drift, 66/0 install. Phase 9 accounted for +10 drift assertions via Steps 9.4 and 9.5; no unexplained deltas [HIGH].

**Corrections protocol**: All resume paths correctly invoke the annotate-in-place-plus-dated-Correction protocol by reference to the canonical rule; the Corrections stub trigger is properly tied to Phase 3's gate [HIGH].

---

## Findings

None. All plan items implemented correctly, verified by file evidence, and conforming to the binding reference syntax contract. Test 15 assertion 2 was proven non-vacuous via negative control. The parent-added Step 9.5 scope expansion is justified: leaving the class of un-normalized pointers open would have closed the instance while leaving the defect class live.

---

Written: `/Users/kevin/GitHub/hve-claude/.claude-hve-tracking/reviews/rpi/2026-08-15/full-repo-review-remediation-phase-009-validation.md`
Status: Pass
- RO-01 verified: Details declared RECONSTRUCTIBLE with record-skip-and-proceed branch at hve-implement.md:28, matching precedent exactly
- RO-02 verified: Resume paths invoke corrections protocol by reference; Corrections stub trigger tied to Phase 3 gate
- DA-01 verified: Edit added to hve-review.md:4 allowed-tools, enabling append-only edits instead of clobber
- Step 9.4 verified: Test 15 assertion 2 exists at lines 1076-1102, searches 3 commands for marker `: none — [reason]`, floor ≥3, negative control proved non-vacuous
- Step 9.5 verified: 13 refs normalized to contract form ``per CLAUDE.md's `Section` section`` across 9 files; all resolve to real headings; +6 test 14 rows; justified scope expansion

Recommended follow-on validations:
1. Confirm `simple_carveout_guarantee` spec still counts exactly 2 carriers (hve-implement.md and one sibling) after all normalized text changes
2. Run test 14 locally to verify all 13 normalized section names resolve to CLAUDE.md headings without false positives
3. Spot-check 2-3 of the 13 normalized references to ensure the backticked section names match CLAUDE.md headings byte-for-byte
4. Verify negative control: strip record-skip marker from hve-implement.md and confirm test 15 assertion 2 rows red
5. Confirm DD-012 and DD-013 decisions are recorded correctly as parent-added work (not in original plan) with sound justification

Clarifying questions: None — Phase 9 is complete and self-contained.

Full detail: re-read `/Users/kevin/GitHub/hve-claude/.claude-hve-tracking/reviews/rpi/2026-08-15/full-repo-review-remediation-phase-009-validation.md`
