# Implementation Validation: Installer test suite
Date: 2026-06-02
Scope: All 10 dimensions (architecture, design-principles, dry-analysis, api-usage, version-consistency, refactoring, error-handling, test-coverage, security, overall-quality)
Files Reviewed: 9 files

## Summary
Critical: 0 | Major: 1 | Minor: 4

---

## Findings

### IV-001 [ARCHITECTURE] [MAJOR]
**Description:** Instruction file list duplicated across three locations instead of single source-of-truth. Changes to the 12-file roster require updating three separate arrays, creating risk of drift and test-data inconsistency.

**Evidence:**
- `install.sh:57-60` — `HVE_INSTRUCTION_FILES` array
- `tests/run-install-tests.sh:98-100` — seed_old_instructions loop
- `tests/run-prompt-upgrade.sh:44-46` — second seed loop (identical copy)

**Impact:** If a new instruction file is added (e.g., `go.md`), the list must be updated in all three places. Missed update causes test failures that are hard to diagnose.

**Recommendation:** Extract the 12-file list to a shared `.sh` library file (e.g., `tests/lib/instruction-files.sh`), then `source` it in `install.sh`, `tests/run-install-tests.sh`, and `tests/run-prompt-upgrade.sh`. This follows DRY and establishes a single definition.

---

### IV-002 [DRY] [MINOR]
**Description:** The `seed_old_instructions()` function in `tests/run-install-tests.sh` is nearly identical to the inline loop in `tests/run-prompt-upgrade.sh:43-49`, duplicating 7 lines of code.

**Evidence:**
- `tests/run-install-tests.sh:89-103` — function definition
- `tests/run-prompt-upgrade.sh:43-49` — inline copy of the same logic

**Impact:** Low risk currently, but if the instruction file list changes, both locations must be updated. Increases maintenance burden.

**Recommendation:** Move `seed_old_instructions()` to `tests/lib/assert.sh` (or extract to a shared library file per IV-001) and source it from `run-prompt-upgrade.sh`. Note: this aligns with IV-001's recommendation to centralize file lists.

---

### IV-003 [ERROR-HANDLING] [MAJOR]
**Description:** The `block_file` temporary file created in `install.sh:115` may not be cleaned up if the awk command fails or if the script receives a signal before reaching line 126.

**Evidence:**
- `install.sh:114-127` — temp file creation and cleanup:
  ```
  block_file="$(mktemp)"
  printf '%s\n' "$WRAPPED" > "$block_file"
  awk -v bf="$block_file" '...' "$TARGET_CLAUDE" > "$tmp"
  rm -f "$block_file"   # ← only reached if awk succeeds
  ```

**Impact:** If awk fails, `block_file` is orphaned in `/tmp`. With repeated script invocations, temp directory can accumulate garbage files. On systems with temp cleanup policies, this is low risk; on others, temp directory pollution can occur.

**Recommendation:** Use a trap to clean up temp files on all exit paths (as done in test runners). Add near line 114:
```bash
trap 'rm -f "$tmp" "$block_file"' EXIT
```
This ensures cleanup even if awk fails or the script is interrupted. The trap can be scoped to the CLAUDE.md merge section or at the script level (install.sh doesn't create temp files elsewhere, so script-level trap is safe).

---

### IV-004 [API-USAGE] [MINOR]
**Description:** `assert_contains()` in `tests/lib/assert.sh:58` uses `grep -qF`, which is correct for fixed-string matching. However, the label parameter order differs from `assert_file_count()` and some callsites pass 3 positional args in different order (label last vs first). Inconsistent parameter order creates risk of mislabeled assertions.

**Evidence:**
- `tests/lib/assert.sh:54-62` — `assert_contains(path, string, label)` — label is 3rd
- `tests/lib/assert.sh:76-88` — `assert_file_count(dir, pattern, expected, label)` — label is 4th
- `tests/run-install-tests.sh:159-162` — callsite: `assert_contains ... "label-as-third-arg"`
- `tests/lib/assert.sh:95` — `assert_output_contains(output, string, label)` — label is 3rd

**Impact:** Inconsistency is mostly cosmetic, but makes the API harder to remember. Low risk of actual bugs if all call sites are correct.

**Recommendation:** Standardize: move `label` to the final parameter position in all assertion functions for consistency. Update all callsites. This makes the API predictable: `assert_X <data-args...> <label>`.

---

### IV-005 [VERSION-CONSISTENCY] [MINOR]
**Description:** README.md line 414 mentions "If those prompts change in a future release, update the corresponding script to match" but there is no version or change-tracking mechanism to signal when prompts change. No comments in the prompt scripts reference a version or hash of the source prompts.

**Evidence:**
- `README.md:413-414` — maintenance guidance
- `tests/run-prompt-new-install.sh:80-95` — prompt embedded; no version or hash comment
- `tests/run-prompt-upgrade.sh:92-111` — prompt embedded; no version or hash comment

**Impact:** When prompts are updated in the future, maintainers may not realize the scripts need updating if they only look at script timestamps. This is a documentation/process issue, not a code correctness issue.

**Recommendation:** Add a comment at the top of each prompt script with a hash of the original prompt (or a date), e.g. `# Prompt sync: match README.md lines 220-233 (updated 2026-06-02)`. This serves as a visual reminder to check the README when maintenance is needed.

---

### IV-006 [OVERALL-QUALITY] [MINOR]
**Description:** `run-prompt-new-install.sh` and `run-prompt-upgrade.sh` define an inline `assert_has_files()` helper (lines 28-41 in run-prompt-new-install.sh) that duplicates logic similar to `assert_file_count()` from the shared library, but with a different signature and behavior.

**Evidence:**
- `tests/run-prompt-new-install.sh:28-41` — inline helper for "at least 1 file" checks
- `tests/lib/assert.sh:76-88` — `assert_file_count()` supports exact count assertion
- Signature difference: `assert_has_files(dir, pattern, label)` vs `assert_file_count(dir, pattern, expected, label)`

**Impact:** Low impact, but adds a second way to do file counting, reducing clarity. The prompt tests could use the shared library's `assert_file_count()` with `expected=1` for "at least one file" checks, or a wrapper in assert.sh like `assert_has_file_count()` for ">=1" counts.

**Recommendation:** Either (a) extend `assert.sh` with an `assert_has_files_count(dir, pattern, label)` helper that asserts `>= 1` files, and use it in both prompt scripts, or (b) replace `assert_has_files()` calls in prompt scripts with calls to the shared library. This consolidates file-counting logic.

---

### IV-007 [TEST-COVERAGE] [PASS]
**Description:** The 5 automated tests in `run-install-tests.sh` cover the meaningful paths through `install.sh` according to the plan requirements. All major scenarios are exercised:
1. Fresh install (no CLAUDE.md) — creates both files and directories
2. Prepend case (CLAUDE.md exists, no markers) — inserts HVE block at top, preserves user content
3. Clean upgrade (markers present, all instruction files identical) — replaces block, cleans up old location
4. Old marker format (em-dash marker) — converts to hyphen marker format correctly
5. Diverged upgrade (one instruction file customized locally) — keeps customized file, removes unmodified ones

**Evidence:**
- `tests/run-install-tests.sh:108-172` through `tests/run-install-tests.sh:299-331` — all 5 test functions
- Plan requirements match implementation: 5/5 test cases from plan are present

**Impact:** Good coverage of both success paths and edge cases (old marker format, diverged files). Prompt tests are semi-manual (require user to run Claude Code), which appropriately delegates integration testing to a human-in-the-loop phase.

**Recommendation:** No changes. Coverage is appropriate for the scope. The tests would benefit from more edge cases (e.g., CLAUDE.md with markers but empty block, corrupted marker syntax), but those are lower-priority given the plan requirements.

---

### IV-008 [DESIGN-PRINCIPLES] [PASS]
**Description:** Test suite follows single-responsibility principle well: `assert.sh` handles assertions only; `run-install-tests.sh` is the automated test orchestrator; `run-prompt-*.sh` are semi-manual prompt testers. Each script has one job and does it clearly.

**Evidence:**
- `tests/lib/assert.sh` — purely assertion library, 117 lines, no test logic
- `tests/run-install-tests.sh` — orchestrates 5 tests against install.sh; no assertion definition
- `tests/run-prompt-new-install.sh` and `tests/run-prompt-upgrade.sh` — prompt seeding and user-guided testing

**Impact:** Clean separation makes the test suite maintainable and testable itself.

**Recommendation:** No changes. Good design.

---

### IV-009 [SECURITY] [PASS]
**Description:** No secrets, credential patterns, or unsafe input handling detected in test scripts, fixtures, or install.sh. Shell scripts use `set -euo pipefail` to prevent unset variable expansion and command failure silencing. Temp files are created via `mktemp`, not predictable paths.

**Evidence:**
- All shell scripts have `set -euo pipefail` (lines 9, 14, 17 in respective files)
- No grep hits for `PRIVATE KEY`, `api_key`, `password`, `Bearer`, `-----BEGIN`, AWS/GCP patterns
- Fixtures contain only demo content (SENTINEL markers, stub HVE blocks)
- Temp files created via `mktemp -d` (secure, unpredictable)
- `tests/lib/assert.sh:10` — mktemp error-guarded: `mktemp || { echo ... exit 1; }`

**Impact:** Good security posture for test infrastructure.

**Recommendation:** No changes.

---

### IV-010 [REFACTORING] [PASS]
**Description:** Code complexity is appropriate to the problem scope. Test runners are straightforward state machines; assertion functions are simple predicates. No obvious simplifications or patterns that could replace verbose code.

**Evidence:**
- Test functions are 50–70 lines each, readable, and do one thing
- Assertion functions are 5–10 lines each, clear intent
- `run_test()` helper eliminates boilerplate for each test invocation

**Impact:** Maintainable, understandable code.

**Recommendation:** No changes needed. (Note: IV-001 and IV-002 address code duplication, which is a refactoring opportunity, but they're covered separately.)

---

## Coverage Notes

**Dimensions fully checked:**
- Architecture Conformance: Reviewed file placement, module boundaries, directory structure. Found one major issue (IV-001).
- Design Principles: Single responsibility and separation of concerns evaluated. Good overall; SRP followed well.
- DRY Compliance: Grepped for duplicate logic; found two instances of code duplication (IV-001, IV-002).
- API Usage: Checked bash idioms (`[[ ]]` vs `[ ]`, quoting, `set -euo pipefail`, readonly constants). Found minor inconsistency in assertion function signatures (IV-004).
- Version Consistency: Verified the 12 instruction filenames are listed in all three locations (install.sh, run-install-tests.sh, run-prompt-upgrade.sh). Consistency verified; noted as duplication (IV-001).
- Refactoring Opportunities: No over-engineered or verbose patterns found. Code appropriate to scope.
- Error Handling: Reviewed trap cleanup, temp file handling, exit codes. Found one major issue with install.sh block_file cleanup (IV-003).
- Test Coverage: Verified 5 automated tests match plan requirements. All major paths through install.sh are tested.
- Security Posture: Verified no secrets, credential patterns, unsafe input handling. Temp file creation secure. `set -euo pipefail` present. Passed.
- Overall Quality: Readability, naming, complexity all appropriate. Naming is clear; complexity is justified.

---

## Quality Assessment

**Pass** — No critical issues; one major issue (install.sh temp file cleanup) requires fixing; four minor issues (code duplication, version tracking, API consistency) are improvement opportunities but not blockers.

The installer test suite is well-structured, covers the plan requirements, and demonstrates good testing discipline. The major issue (IV-003) is a reliability/robustness fix for production use; the minor issues (IV-001, IV-002) are maintainability improvements for future updates.
