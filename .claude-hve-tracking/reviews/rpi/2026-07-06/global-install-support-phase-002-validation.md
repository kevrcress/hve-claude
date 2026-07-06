# RPI Validation: Global install support — Phase 2
Date: 2026-07-06
Plan phase: Test coverage
Coverage: 100%
Status: Fail: 1 minor (citation precision issue, no functional impact)

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Add test5_global_install to suite | Found | tests/run-install-tests.sh:367-438 | ✅ Implemented |
| Assert isolated HOME | Found | tests/run-install-tests.sh:368-369 | ✅ Implemented |
| Assert files land under ~/.claude/ | Found | tests/run-install-tests.sh:376-388 | ✅ Implemented |
| Assert CLAUDE.md at ~/.claude/CLAUDE.md | Found | tests/run-install-tests.sh:391-392 | ✅ Implemented |
| Assert HVE markers present | Found | tests/run-install-tests.sh:393-394 | ✅ Implemented |
| Assert global placeholder section | Found | tests/run-install-tests.sh:395-396 | ✅ Implemented |
| Assert no ~/CLAUDE.md created | Found | tests/run-install-tests.sh:399-400 | ✅ Implemented |
| Assert no ~/.gitignore created | Found | tests/run-install-tests.sh:401-402 | ✅ Implemented |
| Assert skipped-gitignore message | Found | tests/run-install-tests.sh:404-405 | ✅ Implemented |
| Assert idempotent re-run (one marker) | Found | tests/run-install-tests.sh:408-416 | ✅ Implemented |
| Assert --global rejects trailing dir | Found | tests/run-install-tests.sh:420-427 | ✅ Implemented |
| Wire test5 into main() | Found | tests/run-install-tests.sh:454 | ✅ Implemented |

## Findings

### RV-001 [MINOR]
**Citation precision: Phase 2 line range overlaps Phase 4 scope**

Plan item: Phase 2 test coverage (lines 23-28 of plan); Phase 4 addendum (lines 38-45).

Evidence:
- Changes log Phase 2, line 30: `tests/run-install-tests.sh:364-431` (claims range ends at line 431)
- Changes log Phase 4, line 55: `tests/run-install-tests.sh:432-441` (claims range starts at line 432)
- Actual test file: test5_global_install spans lines 367-438
- HOME unset check (Phase 4 per plan): lines 429-437 (within Phase 2's claimed range)

The Phase 2 citation range `364-431` correctly includes the HOME unset check setup (line 431: `env -u HOME`), but this assertion logically belongs to Phase 4 per the plan addendum. The Phase 4 citation `432-441` is imprecise: the HOME unset block is actually 429-437, and line 441 is a section separator comment.

Impact: No functional impact—the assertion is present and functional. The issue is documentation precision only: the changes log creates ambiguity about which phase owns the HOME unset check.

Recommendation: Consider adding a note in the changes log clarifying that test5 was initially implemented in Phase 2 with 10 assertions covering the core --global behavior, and Phase 4 added the 11th assertion (HOME unset). Alternatively, regenerate Phase 2's line range as `364-427` (excluding the HOME unset block) and Phase 4's range as `429-437` (the HOME unset block only).

### RV-002 [MINOR]
**Assertion count annotation mismatch with actual test assertions**

Plan item: Phase 2 test coverage (line 28 of plan says "10 assertions")

Evidence:
- Changes log Phase 2, line 30: "10 assertions (layout, merge target, placeholder, no home pollution, skipped-gitignore message, idempotent re-run, arg rejection)" — this list omits the HOME unset check
- Actual test5_global_install assertions (lines 378-437):
  1. cmd_count >= 1 (line 378-384)
  2. instructions count = 12 (line 386-388)
  3. CLAUDE.md exists (line 391-392)
  4. HVE:START marker (line 393-394)
  5. Global placeholder (line 395-396)
  6. No ~/CLAUDE.md (line 399-400)
  7. No ~/.gitignore (line 401-402)
  8. skipped-gitignore message (line 404-405)
  9. idempotent re-run (line 411-416)
  10. --global rejects trailing dir (line 422-427)
  11. env -u HOME rejects (line 432-437) — Phase 4 scope, but implemented in Phase 2

Impact: The test file is correct and complete. The changes log annotation is imprecise: it lists only 9-10 items when the test function contains 11 assertions. This creates confusion about whether Phase 2 was truly complete per the plan.

Recommendation: Update the changes log Phase 2 annotation to list all 10 Phase 2-owned assertions, and separately note that Phase 4 adds the 11th (HOME unset).

## Unlisted Changes

No files modified for Phase 2 beyond `tests/run-install-tests.sh`.

## Research Coverage

No research document provided (noted in plan header as "Research: none"). Plan Phase 2 is self-contained: it adds test coverage for Phase 1's --global installation mode. All plan-specified assertions are present in the test file.

## Test Verification

All assertions in test5_global_install are statically verified as present:
- Layout and path assertions (lines 376-388): verify ~/.claude/ directory structure ✓
- File content assertions (lines 393-396, 404-405): verify merge markers, placeholder section, message output ✓
- Negation assertions (lines 399-402): verify no pollution of HOME root ✓
- Idempotence assertion (lines 410-416): verify single marker after re-run ✓
- Rejection assertions (lines 420-427, 431-437): verify exit nonzero on invalid args ✓

Test is properly wired into main() at line 454.

## Summary

Phase 2 implementation is **functionally complete and correct**. All 10 core assertions specified in the Phase 2 plan are present and properly verified in test5_global_install. The 11th assertion (HOME unset check) is attributed to Phase 4 in the plan addendum but physically located in the Phase 2 test scope; this is a **documentation clarity issue only**, not a functional defect. The test suite passes (42 tests: 41 baseline + test5's contribution; per changes log line 62-63 and correction line 67).

**Rating: Pass with minor citation precision notes** — recommend clarifying the test assertion attribution in the changes log for future reference, but no code changes needed.
