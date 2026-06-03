# RPI Validation: Installer test suite — Phases 4–5
Date: 2026-06-02
Plan phase: Phase 4 (Create prompt test — new install) and Phase 5 (Create prompt test — upgrade)
Coverage: 100%
Status: Pass

## Plan Item Comparison

### Phase 4: Create prompt test — new install

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 4.1: Create tests/run-prompt-new-install.sh with REPO_ROOT, temp dir, bordered blocks, prompts, assertions, and finish | Found | `tests/run-prompt-new-install.sh:1-174` | ✅ Implemented |

**Detail breakdown — Phase 4:**

| Requirement | File:Line | Verified |
|---|---|---|
| Shebang and REPO_ROOT resolved | `tests/run-prompt-new-install.sh:1,16` | ✅ |
| Fresh temp dir created (no CLAUDE.md, no HVE files) | `tests/run-prompt-new-install.sh:47` | ✅ |
| NOT auto-deleted — temp dir left for inspection | `tests/run-prompt-new-install.sh:9` (comment) | ✅ |
| Bordered block (╔══╗) for STEP 1 showing directory path prominently | `tests/run-prompt-new-install.sh:63-69` | ✅ |
| Bordered block for STEP 2 with prompt text easy to copy | `tests/run-prompt-new-install.sh:76-95` | ✅ |
| Option A prompt verbatim, dev branch clone URL | `tests/run-prompt-new-install.sh:80-95` | ✅ (URL: `https://github.com/kevrcress/hve-claude -b dev`) |
| read -r _ pause with message | `tests/run-prompt-new-install.sh:105-106` | ✅ |
| Assert .claude/commands contains hve*.md | `tests/run-prompt-new-install.sh:116-118` | ✅ |
| Assert .claude/agents contains hve*.md | `tests/run-prompt-new-install.sh:120-122` | ✅ |
| Assert .claude/instructions contains ≥1 .md | `tests/run-prompt-new-install.sh:124-126` | ✅ |
| Assert prompts/ contains ≥1 .md | `tests/run-prompt-new-install.sh:128-130` | ✅ |
| Assert CLAUDE.md exists | `tests/run-prompt-new-install.sh:132-134` | ✅ |
| Assert CLAUDE.md contains HVE:START | `tests/run-prompt-new-install.sh:136-139` | ✅ |
| Assert CLAUDE.md contains HVE:END | `tests/run-prompt-new-install.sh:141-144` | ✅ |
| Assert .gitignore contains subagents exclusion rule | `tests/run-prompt-new-install.sh:146-149` | ✅ |
| Temp dir path printed after finish | `tests/run-prompt-new-install.sh:157-158` | ✅ |
| "Wrong directory?" note if assertions fail | `tests/run-prompt-new-install.sh:167-171` | ✅ |

### Phase 5: Create prompt test — upgrade

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 5.1: Create tests/run-prompt-upgrade.sh with seeding, bordered blocks, prompts, assertions, and finish | Found | `tests/run-prompt-upgrade.sh:1-180` | ✅ Implemented |

**Detail breakdown — Phase 5:**

| Requirement | File:Line | Verified |
|---|---|---|
| Shebang and REPO_ROOT resolved | `tests/run-prompt-upgrade.sh:1,19` | ✅ |
| Note at top about dev branch cloning | `tests/run-prompt-upgrade.sh:4-5` | ✅ |
| assert.sh sourced | `tests/run-prompt-upgrade.sh:21` | ✅ |
| CLAUDE.md seeded from claude-md-current-marker.md fixture | `tests/run-prompt-upgrade.sh:40` | ✅ |
| instructions/ seeded with all 12 HVE files | `tests/run-prompt-upgrade.sh:43-49` | ✅ (bash, csharp, csharp-tests, python, python-tests, python-uv, rust, rust-tests, terraform, markdown, git-commit-messages, writing-style) |
| .claude/commands/, .claude/agents/, prompts/ seeded with current HVE files | `tests/run-prompt-upgrade.sh:52-62` | ✅ |
| Bordered block for STEP 1 showing directory path | `tests/run-prompt-upgrade.sh:74-79` | ✅ |
| Bordered block for STEP 2 with update prompt | `tests/run-prompt-upgrade.sh:85-111` | ✅ |
| Update prompt verbatim, dev branch clone URL | `tests/run-prompt-upgrade.sh:92-111` | ✅ (URL: `https://github.com/kevrcress/hve-claude -b dev`) |
| read -r _ pause with message | `tests/run-prompt-upgrade.sh:118-119` | ✅ |
| Assert .claude/commands contains hve*.md | `tests/run-prompt-upgrade.sh:129-131` | ✅ |
| Assert .claude/agents contains hve*.md | `tests/run-prompt-upgrade.sh:133-135` | ✅ |
| Assert .claude/instructions contains ≥1 .md | `tests/run-prompt-upgrade.sh:137-139` | ✅ |
| Assert prompts/ contains ≥1 .md | `tests/run-prompt-upgrade.sh:141-143` | ✅ |
| Assert CLAUDE.md contains HVE:START | `tests/run-prompt-upgrade.sh:145-148` | ✅ |
| Assert CLAUDE.md contains HVE:END | `tests/run-prompt-upgrade.sh:150-153` | ✅ |
| Assert CLAUDE.md still contains sentinel (Your Project content preserved) | `tests/run-prompt-upgrade.sh:155-158` | ✅ (sentinel: `SENTINEL_YOUR_PROJECT_CONTENT`) |
| Assert instructions/ directory no longer exists | `tests/run-prompt-upgrade.sh:160-162` | ✅ |
| Temp dir path printed after finish for inspection | `tests/run-prompt-upgrade.sh:171-175` | ✅ |

## Findings

**Status: PASS** — All plan requirements for Phases 4 and 5 are implemented, verified in code, and match the changes log claims.

### Coverage Analysis

**Phase 4:** 1/1 plan items implemented (100%)
**Phase 5:** 1/1 plan items implemented (100%)
**Combined coverage:** 2/2 items (100%)

### Code Quality Notes

1. **Phase 4 error handling (line 162–173):** Uses `set +e` / `set -e` pattern to ensure the "Wrong directory?" note and cleanup command print even when `finish()` exits non-zero. This is correct given `set -euo pipefail` at the top; the pattern prevents the note from being skipped.

2. **Phase 5 assertion pattern (lines 129–143):** Uses `find ... -print -quit` to check for at least one file, then passes the result to `assert_exists`. This correctly handles the case where `find` returns empty string — the assertion correctly fails. This is more elegant than the helper function used in Phase 4, and both patterns work.

3. **Phase 5 assertion without helper (line 160–162):** Uses `assert_not_exists` directly rather than a custom helper, which is simpler and correct.

4. **Fixture integrity:** `tests/fixtures/claude-md-current-marker.md` (line 8) contains the sentinel `SENTINEL_YOUR_PROJECT_CONTENT` that Phase 5 assertions verify (line 157 of run-prompt-upgrade.sh), confirming the test will verify user content preservation.

5. **Prompt verbatim integrity:** Both Phase 4 (lines 80–95) and Phase 5 (lines 92–111) prompts are copied exactly from the plan specification, with dev branch URLs correctly amended from the base repo URL.

## Unlisted Changes

None detected. All files referenced in the plan and changes log are present and match their described purpose.

## Research Coverage

No research document was provided for this task. The plan was derived from direct source audit of `install.sh` and `README.md` per the plan header (line 4). Plan requirements are internally consistent and comprehensive.

## Recommendations for Follow-On

1. After merging `feature/installer-tests` to `dev` and pushing to GitHub, manually run both prompt scripts in isolated temp projects to confirm they work end-to-end.
2. Verify that the fixture files (`.claude-md-current-marker.md` and others) remain in the repo — they are test fixtures, not build artifacts, and should be committed.
3. Document the 12-file list for `instructions/` in a comment in Phase 5 setup or in a helper function if the list changes in future HVE updates.

---

**Written:** `/Users/kevin/GitHub/hve-claude/.claude-hve-tracking/reviews/rpi/2026-06-02/installer-test-suite-phase-4-5-validation.md`
