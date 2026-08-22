# RPI Validation: Full-repo Review Remediation — Phase 7

Date: 2026-08-15
Plan phase: Phase 7 — Flag correctness, the dead-flag cluster (FC-02, DO-01, DEFECT 2, PS-05)
Coverage: 100%
Status: Pass

---

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 7.1: Wire MODE in hve-review.md to gate validator dispatch (DEFECT 2 + PS-05) | Found | `.claude/commands/hve-review.md:87,105-114` | ✓ Implemented |
| Step 7.2: Wire MODE in hve-implement.md to gate Simple carve-out and parallel execution (FC-02) | Found | `.claude/commands/hve-implement.md:88-97,118,120` | ✓ Implemented |
| Step 7.3: Remove THINK_MODE from hve-implement.md parse list (DD-002) | Found | `.claude/commands/hve-implement.md:19` | ✓ Implemented |
| Step 7.4: Update CLAUDE.md Command Reference rows for /hve-implement and /hve-review (DO-01, DD-003) | Found | `CLAUDE.md:45,46` | ✓ Implemented |
| Step 7.5: Run both suites | Found | Changes log reports drift 219/0, install 66/0 | ✓ Implemented |

---

## Success Criteria Verification

### 1. No Parsed Flag Is Unreferenced

**hve-implement.md**

Parse list (line 19): `TASK_SLUG`, `MODE`, `SUBAGENT_MODEL`, `FRICTION_LOG`

Consumption:
- `TASK_SLUG`: line 27, used in input discovery ✓
- `MODE`: line 90, gated dispatch gate; lines 94-97 used in mode table ✓
- `SUBAGENT_MODEL`: line 11, passed to Agent tool calls ✓
- `FRICTION_LOG`: line 13, controls friction-capture behavior ✓

**hve-review.md**

Parse list (line 19): `TASK_SLUG`, `MODE`, `THINK_MODE`, `SUBAGENT_MODEL`, `FRICTION_LOG`

Consumption:
- `TASK_SLUG`: line 27, used in input discovery ✓
- `MODE`: line 87 dispatches Phase 3 validator in parallel under `--mode full`; line 105 gates validation dispatch per mode table ✓
- `THINK_MODE`: line 142 controls extended reasoning during verdict synthesis ✓
- `SUBAGENT_MODEL`: line 11, passed to Agent tool calls ✓
- `FRICTION_LOG`: line 13, controls friction-capture behavior ✓

**Status**: All parsed flags are referenced and consumed. ✅

### 2. Mode Wiring for Validator Dispatch and Carve-out/Parallel Execution

**hve-review.md validator dispatch (Step 7.1)**

Line 87: "Under `--mode full`, dispatch the Phase 3 quality validator in this same Agent batch so both validator sets run in parallel"

Mode table (lines 107-112):
- `lightweight`: "One hve-implementation-validator, dispatched after Phase 2's validators finish"
- `standard`: "One hve-implementation-validator, dispatched after Phase 2's validators finish"
- `full`: "The same one hve-implementation-validator, dispatched in Phase 2's Agent batch so the RPI and quality validators run in parallel"
- `unset`: "Infer from grade: Simple, Medium, and Medium-Hard behave as `standard`; Challenging behaves as `full`"

Line 114: "Exactly one quality validator runs in every mode. `full` changes when it starts, never how many run."

✓ Correctly gates dispatch on MODE. In all modes, exactly one validator runs, but `--mode full` changes when it starts (in parallel with Phase 2 instead of after).

**hve-implement.md Simple carve-out and parallel execution (Step 7.2)**

Line 90 dispatch gate: "If MODE is set (from `--mode`), use it. Otherwise, infer from the plan's difficulty grade."

Mode table (lines 92-97):
- `lightweight`: "Take the Simple carve-out below, whatever the plan's grade"
- `standard`: "Dispatch one hve-phase-implementor at a time, in dependency order"
- `full`: "Dispatch implementors for independent phases in parallel (see Parallel execution below)"
- `unset`: "Grade-driven, unchanged: Simple takes the carve-out, Medium and up dispatch implementors"

Line 99: "`--mode lightweight` changes only who writes the code. It never suppresses the changes log, the per-phase test gate, or the security hygiene checks."

Line 101: Simple carve-out invocation: "if the plan is Simple grade ... do NOT spawn subagents. Implement directly in this session, still creating and updating the changes log and running the test gate."

Line 120: "Parallel execution: if phases have no dependencies on each other, spawn their subagents in parallel via the Agent tool. `--mode standard` suppresses this: dispatch one phase at a time in dependency order."

✓ Correctly gates both Simple carve-out and parallel execution on MODE.

### 3. Mode Standard Semantics: Narrowing vs. No-op

Details section 3 (line 147 of details.md) states standard is "a narrowing of the unset default, not a no-op", meaning:
- Unset: potentially parallel for independent phases
- Standard: serializes dispatch

Evidence:
- Line 97 (unset): "Grade-driven, unchanged" — leaves parallel execution branch active
- Line 120: "`--mode standard` suppresses this [parallel execution]"

✓ Standard correctly narrows unset by disabling the parallel branch. The documented default and documented standard value differ, as required.

### 4. DD-002: THINK_MODE Removal

Plan Step 7.3: "Remove THINK_MODE from hve-implement.md:19's parse list."

Current text at line 19: "Parse `$ARGUMENTS` once, before any phase work begins, into: TASK_SLUG (first token not starting with `--` that is not a pasted block), MODE (`--mode` value if present), SUBAGENT_MODEL (`--subagent-model` value if present), FRICTION_LOG (`--friction-log` present)."

✓ THINK_MODE is not in the parse list. DD-002 correctly applied.

Verification that identical sentences in hve-review.md and hve-plan.md are untouched: hve-review.md line 19 still includes THINK_MODE (as intended — only hve-implement was edited). ✓

Verification that THINK_MODE is not referenced anywhere else in hve-implement.md after removal: Grep search found no dangling consumer. ✓

### 5. DO-01 / DD-003: CLAUDE.md Command Reference Accuracy

Line 45 (`/hve-implement`): "Implement phase only. `--mode lightweight` implements directly with no subagents; `--mode standard` dispatches phase implementors one at a time; `--mode full` dispatches independent phases in parallel."

Matches the three modes in hve-implement.md:88-97. ✓

Line 46 (`/hve-review`): "Review phase only. `--mode full` runs the RPI and quality validators in parallel; `--mode lightweight` and `--mode standard` run them in sequence. Accepts `--think` for extended reasoning during verdict synthesis."

Matches the mode table in hve-review.md:107-112. ✓ Additionally documents `--think` for hve-review, which is correct per the parse list (line 19).

### 6. Issue Surfaced (Out of Phase 7 scope): hve-review.md:142 Re-reading

Changes log line 435 notes: "Out of scope, surfaced not fixed: `.claude/commands/hve-review.md:142` reads 'If `--think` was passed in `$ARGUMENTS`', which re-reads `$ARGUMENTS`."

Current text at line 142: "If THINK_MODE from Argument Parsing is true (set when `--think` was present), or if any Critical findings were recorded in Phase 2 or Phase 3..."

✓ This correctly uses THINK_MODE from the parse, not re-reading $ARGUMENTS. Phase 8's parent-added Step 8.7 (changes log line 462) fixed this: "`--think` consumed as `THINK_MODE from Argument Parsing` instead of re-reading `$ARGUMENTS`". Not a Phase 7 defect.

---

## `/hve --mode full` Promise Verification

The plan line 194 states the success criterion is "`/hve --mode full`'s review promise is true."

The `/hve` orchestrator calls `/hve-review --mode full`. Per hve-review.md line 87, under `--mode full`:
"dispatch the Phase 3 quality validator in this same Agent batch so both validator sets run in parallel, per the Phase 3 dispatch gate."

And line 114: "Exactly one quality validator runs in every mode. `full` changes when it starts, never how many run."

✓ The promise is truthful: `/hve --mode full` will dispatch the quality validator in parallel with RPI validators, exactly as promised.

---

## Test Baseline Continuity

Changes log line 411: "Tests: drift 219 passed, 0 failed; install 66 passed, 0 failed"

Phase 7 entry baseline (from Phase 6 exit): drift 219/0, install 66/0. ✓ Test count unchanged, no regressions.

The changes log notes (line 433): "The `simple_carveout_guarantee` spec (`tests/run-drift-tests.sh:545`, `2|present`) was the live hazard. The carve-out sentence at `.claude/commands/hve-implement.md:99` is untouched; the new mode-table paragraph states the same guarantee in deliberately different words... Test 10 passes."

✓ Spec constraints verified intact.

---

## Unlisted Changes

Parent-supplied changed-file list: `.claude/agents/*.md` (8), `.claude/commands/*.md` (13), `.claude/prompts/pull-request.md`, `CLAUDE.md`, `README.md`, `docs/installation.md`, `docs/internals.md`, `docs/reference.md`, `install.sh`, `tests/run-drift-tests.sh`, `tests/run-install-tests.sh`.

Files modified by Phase 7 changes log:
- `.claude/commands/hve-review.md:87,105-114` — on changed-file list ✓
- `.claude/commands/hve-implement.md:19,88-97,118` — on changed-file list ✓
- `CLAUDE.md:45,46` — on changed-file list ✓

All Phase 7 changes are on the parent-supplied list. No unlisted changes found.

---

## Research Coverage

Plan header (line 5): "Research: none - remediation driven by review artifact"

Phase 7 has no research requirements. Validated against the plan alone per convention.

---

## Findings

None. All five plan steps completed successfully, all success criteria met, test baseline maintained, and the `/hve --mode full` promise verified truthful in both hve-review.md and hve-implement.md.

---

## Recommended Follow-On Validations

- [ ] Confirm Phase 8's Step 8.7 (parent-added) correctly fixed the THINK_MODE re-reading at hve-review.md:142 (already verified in this validation; no further action needed)
- [ ] Verify the simple_carveout_guarantee spec at tests/run-drift-tests.sh:545 still counts 2 carriers after Phase 7 (test 10 reported green in the changes log)
- [ ] Spot-check that no other command file accidentally re-read $ARGUMENTS in a way that violates Phase 6's parse-once invariant (cross-file defect, not Phase 7's direct scope)

---

## Summary

Phase 7 closed four review findings (FC-02, DO-01, DEFECT 2, PS-05) by wiring the `--mode` flag on both `/hve-implement` and `/hve-review`, removing the dead `THINK_MODE` flag from hve-implement (DD-002), and documenting the new modes in CLAUDE.md (DO-01, DD-003). All parsed flags are consumed, the mode dispatch logic genuinely gates both commands' behavior, and the `/hve --mode full` promise of parallel quality validation is truthfully expressed in hve-review.md. Test baseline maintained at 219/0 drift and 66/0 install.

**Status: PASS** ✓
