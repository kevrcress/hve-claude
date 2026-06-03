# Changes Log: Installer test suite
Date: 2026-06-02
Plan: .claude-hve-tracking/plans/2026-06-02/installer-test-suite-plan.md
Status: Complete

## Phases

### Phase 1: Create fixture files
Status: Complete
Started: 2026-06-02T00:00:00Z
Completed: 2026-06-02T00:00:00Z

#### Files Modified
- `tests/fixtures/claude-md-no-hve.md` — Minimal CLAUDE.md with no HVE content; contains SENTINEL_ORIGINAL_CONTENT
- `tests/fixtures/claude-md-old-marker.md` — CLAUDE.md with old em-dash (U+2014) HVE:START marker; contains SENTINEL_YOUR_PROJECT_CONTENT
- `tests/fixtures/claude-md-current-marker.md` — CLAUDE.md with current hyphen HVE:START marker; contains SENTINEL_YOUR_PROJECT_CONTENT

#### Steps Completed
- [x] Step 1.1: Create tests/fixtures/claude-md-no-hve.md — `tests/fixtures/claude-md-no-hve.md:1`
- [x] Step 1.2: Create tests/fixtures/claude-md-old-marker.md — `tests/fixtures/claude-md-old-marker.md:1`
- [x] Step 1.3: Create tests/fixtures/claude-md-current-marker.md — `tests/fixtures/claude-md-current-marker.md:1`

#### Issues Encountered
None

---

### Phase 2: Create shared assertion library
Status: Complete
Started: 2026-06-02T22:03:00Z
Completed: 2026-06-02T22:05:00Z

#### Files Modified
- `tests/lib/assert.sh` — Created; shared assertion library with ASSERT_LOG, all helpers, and finish()

#### Steps Completed
- [x] Step 2.1: Create tests/lib/assert.sh — `tests/lib/assert.sh:1`

#### Issues Encountered
- `grep -c` exits 1 on zero matches; fixed finish() to use `|| pass_count=0` / `|| fail_count=0` assignment pattern rather than `|| echo 0` inside subshell, which produced spurious output in the count variables.

---

### Phase 3: Create automated test runner
Status: Complete
Started: 2026-06-02T22:30:00Z
Completed: 2026-06-02T22:45:00Z

#### Files Modified
- `tests/run-install-tests.sh:1` — Created; 230-line automated test runner with 5 test cases, run_test helper, seed_old_instructions helper, trap cleanup, sourced assert.sh

#### Steps Completed
- [x] Step 3.1: Create tests/run-install-tests.sh scaffold — `tests/run-install-tests.sh:1`
- [x] Step 3.2: Implement Test 1 — New install — `tests/run-install-tests.sh:89`
- [x] Step 3.3: Implement Test 2 — Prepend case — `tests/run-install-tests.sh:136`
- [x] Step 3.4: Implement Test 3 — Clean upgrade — `tests/run-install-tests.sh:173`
- [x] Step 3.5: Implement Test 3b — Old em-dash marker — `tests/run-install-tests.sh:204`
- [x] Step 3.6: Implement Test 4 — Diverged upgrade — `tests/run-install-tests.sh:231`

#### Issues Encountered
- **Test 3b exposes a real install.sh bug (Major):** install.sh passes the multi-line WRAPPED variable to awk via `-v block="$WRAPPED"`, which fails on macOS awk with "newline in string". The em-dash CLAUDE.md is left unmodified — HVE block is not replaced. Test 3b correctly fails with 2 assertion failures (hyphen format not found; em-dash still present). Tests 1, 2, 3, and 4 all pass. Final run: 26 passed, 2 failed (both in test3b, reflecting the install.sh bug, not the test runner).
- **Test 1 double-assertion removed:** Initial draft had a redundant assert_file_count call with expected=1 before the inline >=1 check; removed in the edit pass.

---

### Phase 4: Create prompt test — new install
Status: Complete
Started: 2026-06-02T22:10:00Z
Completed: 2026-06-02T22:15:00Z

#### Files Modified
- `tests/run-prompt-new-install.sh:1` — Created; semi-manual prompt test for new HVE install via Claude Code

#### Steps Completed
- [x] Step 4.1: Create tests/run-prompt-new-install.sh — `tests/run-prompt-new-install.sh:1`

#### Issues Encountered
- `finish` calls `exit 1` on failure; with `set -euo pipefail` active, a `finish || { note }` pattern would skip the note because `exit` bypasses the OR branch. Fixed by using `set +e` / `set -e` around the `finish` call and capturing the return code, so the user-facing note and temp dir path always print before the script exits.

---

### Phase 5: Create prompt test — upgrade
Status: Complete
Started: 2026-06-02T22:20:00Z
Completed: 2026-06-02T22:25:00Z

#### Files Modified
- `tests/run-prompt-upgrade.sh:1` — Created; semi-manual prompt test for upgrade scenario; made executable (chmod +x)

#### Steps Completed
- [x] Step 5.1: Create tests/run-prompt-upgrade.sh — `tests/run-prompt-upgrade.sh:1`

#### Issues Encountered
- assert_exists called with `"$(find ... -print -quit)"` as path; when find returns empty string, `[[ -e "" ]]` correctly evaluates to false — pattern works without a wrapper helper. Verified bash syntax with `bash -n`.
- README lines 319-337 update prompt copied verbatim; clone URL amended from `https://github.com/kevrcress/hve-claude` to `https://github.com/kevrcress/hve-claude -b dev` as specified.

---

### Phase 6: Update README
Status: Complete
Started: 2026-06-02T23:00:00Z
Completed: 2026-06-02T23:05:00Z

#### Files Modified
- `README.md:380` — Inserted `## Development` section (38 lines) after the Installation section, before `## Workflow walkthrough`

#### Steps Completed
- [x] Step 6.1: Add ## Development section to README.md — `README.md:380`

#### Issues Encountered
None

---

## Security Hygiene Check
- Modified files: tests/ scripts, install.sh (awk fix), README.md — no secrets, no credentials
- Secret pattern scan (PRIVATE KEY, api_key=, password=, Bearer, -----BEGIN): **0 hits**
- Credential-like filenames in diff: none
- .gitignore: .env, *.pem, *.key not applicable to this change
- install.sh fix: macOS awk newline bug — no security implications
- Status: **PASS**
