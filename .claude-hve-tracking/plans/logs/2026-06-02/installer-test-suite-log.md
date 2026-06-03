# Planning Log: Installer test suite
Date: 2026-06-02
Task slug: installer-test-suite

## Discrepancies

### DD-001: Assertion counter sharing across subshells
Source: Initial design used subshells for test isolation (`eval "$body"` in subshell) but subshells cannot write to parent-scope PASS/FAIL variables.
Assumption: Using a temp file (`ASSERT_LOG`) as shared state across the whole run solves the isolation vs. counter-sharing problem cleanly.
Risk: If the runner exits before `finish` is called (e.g. due to an unhandled error), the temp file may not be cleaned up. Mitigated by including `ASSERT_LOG` in the EXIT trap.

### DD-002: No research document — plan derived from conversation
Source: Task was designed entirely in conversation; no `.claude-hve-tracking/research/` doc exists.
Assumption: The conversation is sufficiently detailed (6 named test cases, file structure, exact fixture content, install.sh source read directly) to plan without a separate research phase.
Risk: Low — all key behaviors were derived by reading install.sh:1-151 and README.md:216-337 directly, not inferred.

### DD-003: assert-prompt-install.sh does not test CLAUDE.md sentinel survival
Source: The prompt-install assertions are intentionally simpler than the automated suite — they only check structure, not content preservation.
Assumption: Sentinel survival (verifying `## Your Project` is intact after a Claude session) is impractical to automate for the prompt tests since the user's CLAUDE.md content is unknown at script-write time.
Risk: Low — the human tester can visually verify this; the script handles the structural assertions.

### DR-001: Missing test for instructions/ directory with non-HVE files
Source: install.sh:87-88 — silent-pass branch when directory exists but contains no HVE files (not touched).
Gap: Plan has no test for the case where `instructions/` exists but contains only unrecognized files (e.g., `mylocal.md`). The script leaves such directories untouched and prints no output. This is valid behavior but untested.
Severity: Minor
Recommendation: Add Test 5 — "Non-HVE instructions/ directory silently preserved" — or document in plan that this edge case is intentionally not automated (acceptable since the user's custom files are not touched and the script warns on divergence).
Status: Open

### DR-002: No test for .gitignore creation when file does not exist
Source: install.sh:131-145 — handles both `.gitignore` creation and append cases.
Gap: Test 1 (new install) asserts `.gitignore` *contains* a rule but does not verify it was *created* from scratch vs. appended to an existing file. This is a minor gap since the assertion passes for both cases, but the "file creation" path (line 140) is not explicitly covered.
Severity: Minor
Recommendation: Test 1 could add `assert_not_exists $tmpdir/.gitignore` before running install.sh to force the creation path. Currently accidental but acceptable since append also works.
Status: Open

### DD-004: Test 3b (old em-dash marker) assumes exact UTF-8 em-dash in fixture [LOW]
Source: install.sh:112-113 uses grep pattern `<!-- HVE:START` which matches both marker styles; details.md:36 notes the em-dash is U+2014 (3-byte UTF-8).
Assumption: The fixture file `claude-md-old-marker.md` will correctly contain the em-dash character, and `grep` will match it correctly on macOS and Linux.
Risk: [LOW] — em-dash is standard UTF-8 and grep is locale-agnostic for this pattern. However, if the fixture is hand-created with the wrong character (e.g., encoded as two-dash `--`), the test will fail. Recommend verifying the fixture with `od -c` or `xxd` to confirm the 3-byte sequence.
Severity: Minor
Status: Open

### DD-005: Temp file cleanup in assert.sh assumes mktemp succeeds [LOW]
Source: details.md:78 — `ASSERT_LOG="$(mktemp)"` is called at script load time.
Assumption: mktemp succeeds (no full disk, permissions errors). If mktemp fails, `$ASSERT_LOG` is empty and assertions write to the filesystem root (e.g., `/PASS: exists: ...`).
Risk: [LOW] — mktemp failure is extremely rare, but the script should check `[ -n "$ASSERT_LOG" ]` and exit with an error if it fails.
Severity: Minor
Recommendation: Add error check: `ASSERT_LOG="$(mktemp)" || { echo "ERROR: mktemp failed"; exit 1; }`
Status: Open

### DR-003: Plan does not specify which .claude/instructions/ files to assert
Source: Plan steps 3.2 and 3.4 assert `.claude/instructions/` *contains* at least one `.md` but do not specify the count (should be exactly 12).
Gap: For clarity, tests should assert that exactly 12 files exist in `.claude/instructions/` (not "at least one"). Plan is vague on whether partial copies (e.g., 6 files) would pass. This is a minor spec gap.
Severity: Minor
Recommendation: Tighten test assertions to count files: `assert_file_count $tmpdir/.claude/instructions 12`
Status: Open

### DR-004: Missing Test 2 — "Prepend case (existing CLAUDE.md, no markers)"
Source: install.sh:122-129 — the prepend branch handles CLAUDE.md that exists but has no HVE markers. This is a distinct code path from "create" (103-109) and "replace" (110-121).
Gap: Plan covers Tests 1, 3, 3b, 4 but not Test 2. The prepend case is a critical path that is currently untested.
Severity: Major
Recommendation: Add Test 2 (step 3.3.5 or renumber as appropriate): "Existing CLAUDE.md with no markers (prepend case)" — Create temp dir with `tests/fixtures/claude-md-no-hve.md` as CLAUDE.md, run install.sh, assert that the wrapped HVE block appears *before* the original content and `## Your Project` is prepended correctly, and original content is preserved below.
Status: Open

### DD-006: .gitignore merge logic has edge cases not tested [LOW]
Source: install.sh:139-144 — checks for "`.claude-hve-tracking`" substring in existing .gitignore before appending the header comment; then calls `add_ignore()` for each rule with exact matching (`-qxF`).
Assumption: Plan Test 1 asserts the rules are *present* but does not test the header comment path or idempotency of re-running when rules are partially present.
Risk: [LOW] — Edge case: if .gitignore exists with `# HVE tracking` comment but the rules are missing, the script will not re-add the comment (line 139 grep would pass). This is acceptable behavior (comment already there) but technically the comment could be stale. Not a blocker since the rules are added correctly by `add_ignore()`.
Severity: Minor
Recommendation: Test 1 could add an optional idempotency check: run install.sh twice and verify no duplicate rules or comments. Document that this is known-safe but untested.
Status: Open

### DD-007: Assertions continue on failure (no early exit in test body) [MEDIUM]
Source: details.md:80-86 — assertion functions write to a log file but do not exit on failure. Combined with `set -euo pipefail` in the runner, a failing assertion does not halt the test.
Assumption: This is intentional — all assertions in a test run to completion, and `finish()` tallies passes/fails at the end. The runner subshell isolates each test so that one test's failure does not abort the runner.
Risk: [MEDIUM] — If a *critical* assertion fails early (e.g., `assert_not_exists instructions/` in Test 4), subsequent assertions in that test may pass when they should not (e.g., if `instructions/` still exists due to a bug, the assertion that "python.md was removed" could be false-positive). This is acceptable for a test suite since you see all failures, but can be confusing. Recommend documenting the assertion design: "all assertions run; if any fail, the test fails at the end."
Severity: Minor
Recommendation: Document in plan Phase 2 or details: "Assertion functions write to a log file and do not short-circuit. All assertions in a test run even if one fails, allowing you to see all issues at once."
Status: Open

### DD-008: Plan does not test install.sh pre-flight error checks [LOW]
Source: install.sh:25-34 — checks for SOURCE == TARGET and missing source directories; exits with error if either condition is true.
Assumption: These are pre-flight validation errors and not part of the "normal" test scope. Testing them would require mocking directory conditions or modifying install.sh, which is out of scope.
Risk: [LOW] — The error paths are defensive and unlikely to be triggered in normal usage. Not testing them is acceptable.
Severity: Minor
Recommendation: Document that error paths (SOURCE == TARGET, missing .claude/commands/) are assumed to be well-tested by manual use and are not part of the automated test suite scope.
Status: Open

### DR-005: Phase 2 success criteria mention PASS/FAIL counters but design uses temp file log
Source: Plan Phase 2, line 28 — "sourcing the file sets PASS and FAIL counters"; details.md:78-96 shows the actual design uses `ASSERT_LOG` temp file with grep tally at the end.
Gap: The plan's success criteria describe a different implementation than the details. This is not a blocker (DD-001 explains the design choice) but creates spec confusion.
Severity: Minor
Recommendation: Update plan Phase 2 success criteria to read: "All assertion helpers used by run-install-tests.sh and assert-prompt-install.sh are defined here; sourcing the file initializes a temp log file (`ASSERT_LOG`); a `finish` function tallies passes/fails from the log and exits non-zero on failure."
Status: Open
