# Review Log: Global install support (--global)
Date: 2026-07-06
Plan: .claude-hve-tracking/plans/2026-07-06/global-install-support-plan.md
Changes: .claude-hve-tracking/changes/2026-07-06/global-install-support-changes.md
Research: none (plan authored inline; noted in plan header)
Overall Status: Complete

## Phase Reviews

| Phase | Validator verdict | Findings |
|---|---|---|
| 1: install.sh --global mode | Pass | none; all 8 plan steps verified, citations accurate (phase-001-validation.md) |
| 2: Test coverage | Pass (functional) | RV-001/RV-002 Minor: changes-log line ranges spanned Phase 4's assertion; assertion count ambiguity (phase-002-validation.md) |
| 3: Documentation | Pass | IV-001 Minor: conservative line-range citation (phase-003-validation.md) |
| 4: Windows compatibility | Pass | one Minor citation offset; paste prompt verified behaviorally equivalent to install.sh --global (phase-004-validation.md) |

## Quality Findings

Quality validation (global-install-support-quality.md): 0 Critical, 1 Major, 5 Minor.

- IV-001 [MAJOR] test5 never exercised --global against a pre-existing ~/.claude/CLAUDE.md, leaving the marker-replace and prepend branches untested in global mode (behavior manually verified correct).
- IV-002 [MINOR] CONTRIBUTING.md still said "Covers 5 install.sh scenarios".
- IV-003 [MINOR] CLAUDE.md new paragraph line-wrap width inconsistent (cosmetic).
- IV-004 [MINOR] Unrecognized --flags fall through to target-dir parsing (pre-existing pattern).
- IV-005 [MINOR] Prompts-migration guard lacks its own explanatory comment.
- Shell-correctness edge cases (set -u/shift, SOURCE=TARGET with TARGET=$HOME, unset HOME) all verified correct.

## Security Findings

None. No secrets in changed files; .gitignore hygiene intact (enforced by drift suite); --global never writes to $HOME/.gitignore.

## Record Consistency

Changes log re-read end-to-end. The superseded install-suite tally (41 → 42 → 48) carries in-place annotations and dated Correction entries per the CLAUDE.md convention. Line-range citation imprecisions found by validators were corrected in place with dated notes. No un-annotated contradictions.

## Remediation (2026-07-06, same session)

- IV-001 (Major) fixed: tests/run-install-tests.sh Test 5b covers global upgrade over a marker-bearing and an unmarked pre-existing ~/.claude/CLAUDE.md (7 new assertions). Suite: 48 passed, 0 failed.
- IV-002 (Minor) fixed: CONTRIBUTING.md updated to 7 scenarios.
- RV-001/RV-002 (Minor) fixed: changes-log citations corrected with dated notes.
- IV-003/IV-004/IV-005 (Minor) deferred as follow-ons: cosmetic rewrap, stricter flag validation, guard comment.

## Summary
Status: ✅ Complete
Critical: 0 | Major: 1 (fixed in remediation) | Minor: 9 (6 fixed, 3 deferred)
Record consistency: ✅ Consistent (corrections properly annotated)
