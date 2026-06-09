# Plan Validation: Move `prompts/` → `.claude/prompts/`

Date: 2026-06-08
Validator: HVE Plan Validator
Task: Validate implementation plan against research document for completeness and coverage

---

## Validation Summary

**Status**: PASS with 1 MINOR discrepancy

**Severity Breakdown**:
- Critical: 0
- Major: 0
- Minor: 1 (documentation/clarity)

---

## Coverage Analysis

### Research Requirements vs Plan Phases

All research-identified requirements are addressed by the plan:

| Requirement | Plan Phase | Coverage |
|---|---|---|
| Move source `prompts/` via `git mv` | P1 | ✓ Explicit |
| Update installer paths (4 lines) | P2 | ✓ Explicit |
| Add migration logic mirroring instructions | P2 | ✓ Explicit with full code block |
| Create shared prompt-files list | P3 | ✓ Explicit (new file) |
| Update test runner assertions | P3 | ✓ Explicit with line references |
| Add `seed_old_prompts()` helper | P3 | ✓ Explicit |
| Update interactive test prompts | P3 | ✓ Lines 83, 95, 127-129, 140-142 |
| Update markdown references (11 files) | P4 | ✓ Complete list with line numbers |
| Verify with automated test suite | P5 | ✓ Explicit |

All 15 `prompts/` references found via grep across `.sh` and `.md` files are mapped to plan phases.

### Installer Ordering Safety

**P2 migration block ordering is correct** [HIGH]:
- Copy at `:43` (mkdir) and `:52` (cp from source) runs BEFORE the new migration block (inserted after `:91`).
- When migration block runs, `.claude/prompts/` already exists at the target, so identical old files can be safely deleted.
- Matches the instructions migration pattern exactly.

### Test Coverage Validation

**New automated coverage** (run-install-tests.sh):
- `test1`: new assertion that `.claude/prompts/` has 6 `.md` files + root `prompts/` does not exist ✓
- `test3_clean_upgrade`: seeded with old `prompts/`, asserts both directories cleaned correctly ✓
- Assertions check byte-compare behavior (no diverged-file warnings when all identical) ✓

**Interactive test updates** (run-prompt-new-install.sh, run-prompt-upgrade.sh):
- Both prompt texts updated to reference `.claude/prompts/` ✓
- Seed paths updated to new location ✓
- Assertions updated for new paths ✓

---

## Discrepancy Detected

### DD-005: Plan references `HVE_PROMPT_FILES` list synchronization but expects manual maintenance

**Source**: Plan P3, P2; Details P2 (lines 27-29, 66)

**Finding**: The plan correctly notes that `HVE_PROMPT_FILES` must stay in sync between `install.sh` and `tests/lib/prompt-files.sh` (comment in both locations). However, there is no automated check or assertion to verify this synchronization at test time. The existing `instructions/` migration also has this limitation, so it is not a regression — it is an existing design pattern.

**Risk Level**: MINOR

**Recommendation**: Document the sync requirement clearly (already done via comments), and ensure the planning log reflects this as an ongoing maintenance concern. No plan change needed; this is consistent with established patterns.

**Status**: Expected; documented in planning log as "Open Risks"

---

## Completeness Checks

### Phase Success Criteria

| Phase | Success Criteria | Explicit in Plan | Testable |
|---|---|---|---|
| P1 | Source folder moved, 6 files present, root `prompts/` absent | ✓ Line 9 | ✓ Git status, `ls` |
| P2 | Installer paths updated, migration block added, ordering safe | ✓ Lines 12-22 | ✓ Test3 assertions |
| P3 | Test list created, assertions updated, old location migrated | ✓ Lines 26-41 | ✓ Test1, Test3 |
| P4 | All 11 markdown files updated from `prompts/` to `.claude/prompts/` | ✓ Lines 43-54 | ✓ Manual grep |
| P5 | Automated test suite passes, no residual root `prompts/` references | ✓ Lines 56-59 | ✓ `run-install-tests.sh` + grep |

All phases have explicit success criteria and testable outputs.

### Underspecified Steps

All steps in the plan are sufficiently specific for implementation:
- File paths are exact (line numbers provided)
- Code blocks are provided where needed (P2 migration, P3 test helpers)
- Assertion text is explicit
- No vague actions (e.g., "update the tests" — each test file has specific line/action pairs)

### Missing Dependencies or Ordering Issues

Dependencies are correctly stated:
- P1 → P2: source path depends on folder move ✓
- P2 → P3: tests must assert the installer's new behavior ✓
- P4 independent of P1-3: documentation updates are parallel ✓
- P5 last: verification runs after all changes ✓

---

## Cross-Check Against Actual Repo

### Reference Verification

All 15 `prompts/` references from research scan are accounted for:

**install.sh (3 refs)**:
- `:14` comment → P2 line 12 ✓
- `:43` mkdir → P2 line 13 ✓
- `:52` cp → P2 line 14 ✓
- `:53` echo → P2 line 15 ✓

**Test scripts (6 refs)**:
- run-install-tests.sh `:144-152` → P3 lines 28-31 ✓
- run-prompt-upgrade.sh `:11, 66, 95, 142` → P3 lines 40, 37, 40, 41 ✓
- run-prompt-new-install.sh `:83, 129` → P3 lines 37, 38 ✓

**Markdown (6 refs)**:
- CLAUDE.md:251 → P4 ✓
- README.md:35 → P4 ✓
- CONTRIBUTING.md:100 → P4 ✓
- docs/installation.md:17, 61-62, 131 → P4 ✓
- docs/workflow.md:221 → P4 ✓
- docs/reference.md:69 → P4 ✓
- blog-porting-hve-to-claude-code.md:131 → P4 ✓
- .claude/commands/hve-prompt-builder.md:27, 81 → P4 ✓
- .claude/commands/hve-prompt-analyze.md:28 → P4 ✓
- prompts/prompt-build.md:10 → P4 ✓
- prompts/doc-ops.md:20 → P4 ✓

### No Scope Creep

No plan steps reference paths or files beyond the research findings. All action items trace back to concrete research evidence.

---

## Critical Assumptions Validated

| Assumption | Source | Verification | Risk |
|---|---|---|---|
| 6 prompt files: checkpoint.md, doc-ops.md, prompt-build.md, pull-request.md, rpi.md, task-challenge.md | Research | `git ls-files prompts/` confirms all 6 present | None [HIGH] |
| Instructions migration pattern exists at install.sh:55-91 | Research | Verified; code block present and correct | None [HIGH] |
| HVE_INSTRUCTION_FILES list in tests/lib/instruction-files.sh | Research | Verified; 12 items present | None [HIGH] |
| Source layout uses `.claude/instructions/` | Research | Verified; mkdir -p and cp confirm | None [HIGH] |
| No `.gitignore` entry references `prompts/` | Research | Verified; no matching grep | None [HIGH] |
| `seed_old_instructions()` exists at tests/run-install-tests.sh:95-103 | Research | Verified; exact function present | None [HIGH] |

All critical assumptions from research are verified as HIGH confidence.

---

## Testing Strategy Coverage

The plan's testing approach covers:

1. **New-install scenario**: test1 in run-install-tests.sh asserts `.claude/prompts/` populated ✓
2. **Upgrade scenario**: test3_clean_upgrade seeds old `prompts/`, asserts migration completed ✓
3. **Interactive tests**: both run-prompt-new-install.sh and run-prompt-upgrade.sh updated to exercise new paths ✓
4. **Diverged files**: migration logic (byte-compare) exercised in test3 (expects no "! kept" warnings) ✓
5. **Residual cleanup**: assertions check that old root `prompts/` removed when empty ✓
6. **Markdown updates**: manual grep in P5 to verify no stray references ✓

All key requirements have explicit test coverage.

---

## No Blocks Identified

No blocking assumptions, scope ambiguities, or missing clarifications. The plan is actionable and complete.

---

## Summary

**Validation Result**: PASS

The implementation plan fully covers all research requirements with explicit, testable success criteria. All 15 `prompts/` references are mapped to plan phases. Installer ordering is safe, test coverage is comprehensive, and no scope creep detected. One MINOR note about synchronization coupling (already documented in planning log as an expected pattern), but this does not block implementation.

Recommendation: Proceed to implementation phase.
