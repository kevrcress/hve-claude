# RPI Validation: Friction Log Remediation — Phase 8
Date: 2026-07-17
Plan phase: Phase 8 — Drift tests for duplicated boilerplate
Coverage: 100% (6/6 steps implemented)
Status: Pass

## Overview

Phase 8 adds five new drift tests (Tests 5–9) to `tests/run-drift-tests.sh` to protect the deliberately-duplicated boilerplate blocks introduced in Phases 1–7. All tests are implemented, registered in `main()`, pass independently, and the full suite reports 125 passed / 0 failed. The critical DR-801 recovery (Phase 3 edits lost to an accidental `git checkout`) is complete, canonical-based, and validated by Phase 9.

---

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 8.1: Add subagent_model_boilerplate check (Test 5) | Found | `tests/run-drift-tests.sh:280-321` | ✅ Implemented |
| Step 8.2: Add response_protocol_structure check (Test 7) | Found | `tests/run-drift-tests.sh:368-413` | ✅ Implemented |
| Step 8.3: Add friction_flag_boilerplate check (Test 6) | Found | `tests/run-drift-tests.sh:323-366` | ✅ Implemented |
| Step 8.4: Add instructions_table_sync check (Test 8) | Found | `tests/run-drift-tests.sh:415-466` | ✅ Implemented |
| Step 8.5: Add agent_roster_references check (Test 9) | Found | `tests/run-drift-tests.sh:468-505` | ✅ Implemented |
| Step 8.6: Run tests green | Found | Changes log Phase 8, lines 264 | ✅ Implemented |

---

## Detailed Verification

### Test 5: subagent_model_boilerplate (Plan Step 8.1)

**Implementation** (`tests/run-drift-tests.sh:280-321`):
- Extracts the first line starting with `If \`--subagent-model` from every carrier command
- Asserts all occurrences are byte-identical to the first (canonical)
- Carrier count validation (>= 2)

**Evidence**:
- Function `test5_subagent_model_boilerplate` exists and is correctly structured
- Uses `extract_line` helper to fetch the invariant prefix
- Assertions recorded via `_ok_inline` and `_fail_inline`
- Registered in main() at line 530-531

**Status**: ✅ Implemented correctly

---

### Test 6: friction_flag_boilerplate (Plan Step 8.3)

**Implementation** (`tests/run-drift-tests.sh:323-366`):
- Extracts the first line starting with `If \`--friction-log\`` from every carrier command
- Asserts carrier count == exactly 6 (research, plan, implement, review, pr-review, challenge)
- Asserts all occurrences are byte-identical to the first

**Evidence**:
- Function `test6_friction_flag_boilerplate` exists; constant `FRICTION_EXPECTED_COUNT=6` at line 330
- Checks both count and byte-identity
- Registered in main() at line 532-533
- Changes log confirms all six carriers present (line 259: "carrier count asserted == 6")

**Status**: ✅ Implemented correctly

---

### Test 7: response_protocol_structure (Plan Step 8.2)

**Implementation** (`tests/run-drift-tests.sh:368-413`):
- Validates six invariant lines of the Subagent Response Protocol in full-protocol agents
- Structural greps (not byte-diff) because agents vary status vocabulary
- Explicitly scopes to `FULL_PROTOCOL_AGENTS` constant (6 agents): hve-researcher, hve-phase-implementor, hve-plan-validator, hve-rpi-validator, hve-implementation-validator, hve-pr-reviewer
- Documents 3 prompt-builder sandbox agents (hve-prompt-evaluator, hve-prompt-tester, hve-prompt-updater) as out-of-scope per DD-801

**Evidence**:
- Constant `FULL_PROTOCOL_AGENTS` at line 38-40 lists exactly 6 agents
- Six invariant checks via `_grep_invariant` helper (lines 385-396):
  - artifact-path line: `Written|Updated:`
  - status line: `Status:|Quality:|Verdict:`
  - 7-bullet cap: `\**7\** bullet`
  - 5-item checklist: `\**5\**`
  - 3-question cap: `\**3\**`
  - Full detail line: `Full detail`
- Registered in main() at line 534-535
- Changes log correctly notes DD-801 out-of-scope designation (line 258)

**Status**: ✅ Implemented correctly

---

### Test 8: instructions_table_sync (Plan Step 8.4)

**Implementation** (`tests/run-drift-tests.sh:415-466`):
- Bidirectional validation: every `.claude/instructions/*.md` path cited in CLAUDE.md table exists on disk
- Every file on disk appears as a table row in CLAUDE.md

**Evidence**:
- Extracts all `.claude/instructions/NAME.md` paths from CLAUDE.md (lines 427-430)
- Direction 1 (lines 438-446): each cited path is verified to exist on disk
- Direction 2 (lines 448-465): each file on disk is checked for presence in the table
- CLAUDE.md Instructions Reference table at CLAUDE.md:261-280 includes JavaScript and TypeScript rows (lines 277-278)
- Verified files exist: `.claude/instructions/javascript.md` and `.claude/instructions/typescript.md` (created Phase 7)
- Registered in main() at line 536-537

**Status**: ✅ Implemented correctly

---

### Test 9: agent_roster_references (Plan Step 8.5)

**Implementation** (`tests/run-drift-tests.sh:468-505`):
- Every backticked `hve-*` agent name in command files must resolve to `.claude/agents/<name>.md`
- Skips command-name references (those are commands, not agents)
- Catches missing-agent regressions

**Evidence**:
- Extracts bare backticked tokens from command files using grep (lines 480-483)
- Filters command names from the token list (line 494: skips if file exists in COMMANDS_DIR)
- Verifies remaining tokens resolve to agent files (line 498)
- Registered in main() at line 538-539

**Status**: ✅ Implemented correctly

---

### Test Execution (Plan Step 8.6)

**Evidence** (Changes log, line 264):
- `tests/run-drift-tests.sh`: **125 passed, 0 failed**
- `tests/run-install-tests.sh`: **48 passed, 0 failed**

**Status**: ✅ Tests pass green

---

## Critical Finding: DR-801 Recovery Assessment

### Incident Summary
During Test 6 sanity-check (perturbing the friction-log line to verify the test catches drift), Phase 8 ran `git checkout -- .claude/commands/hve-challenge.md` to restore the file. Because all edits are **uncommitted working-tree changes**, the checkout reverted the file to HEAD, discarding all three of Phase 3's edits to hve-challenge.md, not just the perturbation.

### Detected and Recovered
Phase 8 immediately detected the loss (friction-block grep count dropped to 0) and reconstructed all three edits from:
1. Phase 3 changes-log descriptions
2. Canonical blocks in the details doc (details.md:Block 2 and Block 1)

### Verification of Recovery

**1. Friction block (hve-challenge.md:11-13):**
```markdown
If `--friction-log` is present in the arguments, strip it before other parsing...
```
Byte-compared against hve-plan.md:19: **identical** ✅

**2. Argument-hint (hve-challenge.md:3):**
```yaml
argument-hint: [topic-slug | --focus research|plan|implementation] [--friction-log]
```
Matches canonical wording; `[--friction-log]` present ✅

**3. Artifact Discovery & Relevance stub (hve-challenge.md:25):**
```markdown
Discover inputs per the Artifact Discovery & Relevance convention in CLAUDE.md: slug argument first, else recent distinct slugs (ask on ambiguity, never silently pick between same-day slugs), and always relevance-check the chosen artifact before treating it as evidence.
```
Matches Block 1 canonical stub exactly ✅

### Trustworthiness Assessment

**HIGH**: All three recovered elements are canonical (deterministic blocks from details.md and CLAUDE.md). The drift test (Test 6) validates the friction block byte-identity. Recovery is complete and faithful to canonical form.

### Phase 9 Validation

Phase 9 (lines 287, 292) confirmed:
- Friction block byte-identical to hve-plan.md via `diff`
- Discovery stub is canonical command stub (Block 1)
- Argument-hint carries `[--friction-log]`
- No other files collaterally reverted (`git status` clean)
- Resolution: Resolved ✅

### Recommendation for Parent Reviewer

This recovery does not require rework. The reconstructed elements are canonical and have been independently verified (drift tests, Phase 9 validation). However, note for the audit trail:
- **Process lesson**: never `git checkout` a file in uncommitted state; save a backup copy first
- **Recovery quality**: complete and canonical-based; residual risk is minimal

---

## Cross-Phase Drift Test Coverage

Phase 8 completes the drift-test infrastructure that protects the deliberately-duplicated boilerplate blocks introduced by Phases 1–7:

- **Test 5** (subagent_model_boilerplate): guards the 7-carrier `--subagent-model` block copied into multiple commands
- **Test 6** (friction_flag_boilerplate): guards the 6-carrier `--friction-log` block (research, plan, implement, review, pr-review, challenge)
- **Test 7** (response_protocol_structure): guards the Subagent Response Protocol invariants across 6 full-protocol agents
- **Test 8** (instructions_table_sync): guards bidirectional CLAUDE.md table ↔ instruction files
- **Test 9** (agent_roster_references): guards agent name resolution from command references

All five work together to catch the pattern of failures this remediation was designed to prevent: silent divergence of canonical text across multiple files.

---

## Findings

### RV-001 [MINOR] — DR-801: Reconstructed hve-challenge.md edits lack byte-verification against original Phase 3

**Observation**: Phase 3's three edits to hve-challenge.md (frontmatter `[--friction-log]`, friction-block section, discovery stub) were reconstructed after accidental `git checkout` reverted them from the working tree. The friction block is byte-verified against hve-plan.md (canonical), and all three are canonical-wording elements, but they were never byte-verified against Phase 3's exact original.

**Evidence**:
- Changes log Phase 8 "Issues Encountered" (lines 266-272): documents the accidental revert and recovery
- Changes log Phase 8 "DR-801" (lines 270-271): explicitly notes "NOT byte-verified against Phase 3's exact original"
- Phase 9 validation (line 292): confirmed all three are canonical and resolved

**Impact**: Residual uncertainty about whether the recovered edits match Phase 3's exact intent. Drift tests will catch divergence in the friction block (Test 6), but the discovery stub and argument-hint cannot be drift-tested.

**Trustworthiness**: HIGH — all three elements are deterministically reproducible from canonical blocks. No functional risk.

**Recommendation**: No action required. The recovery is complete and canonical. Phase 9 has validated. This finding is for audit trail purposes.

---

## Unlisted Changes

No files modified in Phase 8 beyond those documented:
- `tests/run-drift-tests.sh`: five new test functions + main registration
- `.claude/commands/hve-challenge.md`: RECOVERY (documented as DR-801)

---

## Research Coverage

Phase 8's research requirement: "drift tests must protect the deliberately-duplicated boilerplate and verify structural invariants across multi-file locations."

**Covered**:
- ✅ `--subagent-model` boilerplate drift check (Test 5)
- ✅ `--friction-log` boilerplate drift check (Test 6)
- ✅ Response Protocol invariants across agents (Test 7)
- ✅ Instructions table ↔ files bidirectional sync (Test 8)
- ✅ Agent name resolution from command references (Test 9)

All research requirements met. Tests are executable, deterministic, and catch the specific failure modes identified in the friction logs (silent divergence, missing files, broken references).

---

## Summary

**Coverage**: 100% — 6/6 plan steps implemented and verified
**Status**: **PASS** — all five tests implemented, registered, and passing; DR-801 recovery complete and canonical-based; no blocking issues

**Key strengths**:
- Five focused tests cleanly partition the drift-detection surface
- Explicit scope management (full-protocol agent list, expected-carrier counts)
- Helper functions (`extract_line`, `_grep_invariant`) support maintainability
- Full suite (125 tests) and install tests both pass

**Process note**:
- DR-801 (accidental `git checkout`) was detected immediately, recovered faithfully, and validated by Phase 9
- This sets a precedent: uncommitted state + shell operations = risky; recovery possible but audit-intensive

---

