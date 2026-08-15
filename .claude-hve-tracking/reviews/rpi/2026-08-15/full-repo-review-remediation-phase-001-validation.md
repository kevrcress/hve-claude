# RPI Validation: full-repo-review-remediation — Phase 1
Date: 2026-08-15
Plan phase: Phase 1 — Installer ships the credential rules its own CLAUDE.md asserts (SC-01)
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 1.1: Add `add_ignore` calls for credential patterns | Found | `install.sh:241-250` | ✅ Implemented |
| Step 1.2: Add install-suite test (fresh/idempotent/seeded) | Found | `tests/run-install-tests.sh:496-512,514-561` | ✅ Implemented |
| Step 1.3: Verify against scratch targets | Found | Changes log lines 55-98 | ✅ Implemented |
| Step 1.4: Run both suites | Found | Changes log lines 38-39 | ✅ Implemented |

## File Evidence Verification

### install.sh (Step 1.1)

**Plan requirement:** Add `add_ignore` calls for `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` after the two existing tracking rules at `install.sh:239-240`, under a `# HVE security hygiene: never commit credentials` header guarded by a `grep -qF` existence check, inside the `if [ "$GLOBAL" -eq 0 ]` branch.

**Actual file content (install.sh:241-250):**
- Line 241-242: Comment explaining why header needs its own guard
- Line 243: `if ! grep -qF "# HVE security hygiene" "$GITIGNORE" 2>/dev/null; then`
- Line 244: `printf '\n# HVE security hygiene: never commit credentials\n' >> "$GITIGNORE"`
- Line 245: `fi`
- Lines 246-250: Five `add_ignore` calls for `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`

**Verification:** ✅ The guarded header is present (line 243 guard + line 244 printf). The five credential `add_ignore` calls follow immediately after. All code is inside the `if [ "$GLOBAL" -eq 0 ]` branch (confirmed by context at line 252 which checks else branch). Content matches the details doc section 1 target exactly.

### tests/run-install-tests.sh (Step 1.2)

**Plan requirement:** Add install-suite test asserting a fresh install writes all five patterns, that a second run produces exactly one of each, and that a target with a pre-existing `.env` line does not get a duplicate.

**Actual file content:**

- Lines 496-512: `_assert_line_count` helper function
  - Takes file, line, expected count, and label
  - Uses `grep -cxF` for whole-line matching (correctly distinguishes `.env` from `.env.*`)
  - Returns pass/fail status inline

- Lines 514-561: `test6_gitignore_credentials` test function
  - Line 515: Array of five credential rules: `('.env' '.env.*' '*.pem' '*.key' '*.p12')`
  - Lines 518-529: Case 1 — fresh install writes all five patterns as whole lines plus header
  - Lines 531-546: Case 2 — second install adds no duplicates (asserts each pattern x1 and header x1)
  - Lines 548-561: Case 3 — target seeded with `.env` and `*.key` ends with one of each and gains the three missing patterns; keeps pre-existing `node_modules/` untouched

- Line 580: Test 6 registered in `main()` via `run_test "Test 6: .gitignore credential rules" test6_gitignore_credentials`

**Verification:** ✅ All three cases are present and follow the plan's specification. The `_assert_line_count` helper correctly uses `grep -cxF` for exact line matching. Test is registered in main().

### Assumption Verification: Step 1.2

**Plan states:** "drift test 4 (`test4_gitignore_hygiene`) checks *this repo's* `.gitignore`, not the installer's output, so it is not the right home for this and must not be edited. [HIGH]"

**Actual evidence:**
- tests/run-drift-tests.sh:56: `readonly GITIGNORE="${REPO_ROOT}/.gitignore"`
- tests/run-drift-tests.sh:289-294: `test4_gitignore_hygiene()` asserts against `${GITIGNORE}`, which is the repo root's `.gitignore`
- The five credential patterns (`.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`) are present in the actual repo `.gitignore` at lines 21-25

**Verification:** ✅ Test 4 was not edited. It checks the repo's own `.gitignore` file, not installer output. The assumption holds.

## Test Results (Step 1.4)

Changes log reports:
- Drift tests: 211 passed, 0 failed (unchanged from baseline, as required)
- Install tests: 66 passed, 0 failed (baseline was 48; the +18 is from new test 6, the expected delta)

**Verification:** ✅ The test delta is fully accounted for and matches the plan's expectation. Both suites gate clean.

## Changed-File List Cross-Reference

Parent supplied changed-file list includes both files modified in Phase 1:
- `install.sh` — listed ✅
- `tests/run-install-tests.sh` — listed ✅

No unlisted changes from Phase 1 in the diff.

## Findings

No findings. All four steps implemented as planned; all file evidence matches changes log claims; both success criteria (five patterns written idempotently, install suite green) verified.

## Research Coverage

No research document supplied. Plan header records "Research: none — remediation driven by review artifact". Validation proceeds against the plan alone. [HIGH confidence in all assertions, backed by direct file evidence]

## Summary

Phase 1 closes SC-01 (installer ships credential rules). All changes are present, file evidence is consistent, success criteria met, and test deltas are expected and accounted for. Ready for Phase 2.
