# Review Log: Installer test suite
Date: 2026-06-02
Plan: .claude-hve-tracking/plans/2026-06-02/installer-test-suite-plan.md
Changes: .claude-hve-tracking/changes/2026-06-02/installer-test-suite-changes.md
Research: (none — plan derived from direct source audit)
Overall Status: Complete

## Phase Reviews

### Phase 1: Fixture files — Pass
All 3 fixtures present with correct marker formats and sentinel content verified.

### Phase 2: Assertion library — Pass
All 6 helpers implemented. ASSERT_LOG with mktemp error guard. finish() correct. No short-circuit on failure.

### Phase 3: Automated test runner — Pass
All 5 test cases implemented (28 assertions). run_test helper, seed_old_instructions, trap cleanup all present and correct.

### Phase 4: Prompt test — new install — Pass
All 15 requirements met. Bordered blocks, dev branch URL, 7 assertions, temp dir preserved, wrong-directory note present.

### Phase 5: Prompt test — upgrade — Pass
All 12 requirements met. Correct seeding of old instructions/ and current HVE files. 8 assertions including sentinel and instructions/ removal.

### Phase 6: README Development section — Pass
All required content present. Section placed correctly (after Installation, before Workflow walkthrough). 36 lines, self-contained.

## Quality Findings

### IV-001 [Major] — DRY: 12-instruction-file list duplicated in 3 places
The list of 12 HVE instruction filenames is hardcoded separately in `install.sh` (HVE_INSTRUCTION_FILES array), `tests/run-install-tests.sh` (seed_old_instructions), and `tests/run-prompt-upgrade.sh` (seeding loop). If a file is added or renamed in a future release, all three must be updated manually.
Recommendation: extract to `tests/lib/instruction-files.sh` and source in the test scripts; install.sh keeps its own array but a comment should reference the test lib.

### IV-002 [Minor] — seed_old_instructions() not shared between runners
The function exists in run-install-tests.sh but is re-implemented inline in run-prompt-upgrade.sh. Could be moved to assert.sh or a shared helper.

### IV-003 [Minor] — install.sh block_file not cleaned up on awk failure
If awk fails, `set -e` exits before `rm -f "$block_file"` runs, leaving a temp file. Low risk (temp files, not sensitive), but a `trap 'rm -f "${block_file}"' EXIT` around the awk block would be cleaner.

### IV-004 [Minor] — assert_has_files() in run-prompt-new-install.sh duplicates assert_file_count()
A local helper was added for "count >= 1" checks; assert_file_count in assert.sh could be extended to support a minimum rather than exact count.

### IV-005 [Minor] — Prompt scripts lack sync marker comments
No comment indicates which README lines the embedded prompts were copied from, making future sync harder.

### IV-006 [Minor] — Assertion label parameter position varies across helpers
Some helpers take label as second arg, others as third. Standardizing label as the final argument would improve consistency.

## Security Findings
None. No secrets, no credentials, no untrusted input execution. Scripts operate on temp directories with known content. PASS.

## Summary
Status: ✅ Complete
Critical: 0 | Major: 1 | Minor: 5
