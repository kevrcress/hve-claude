# Changes Log: Global install support (--global)
Date: 2026-07-06
Plan: .claude-hve-tracking/plans/2026-07-06/global-install-support-plan.md
Status: Complete

## Phases

### Phase 1: install.sh --global mode
Status: Complete

#### Files Modified
- `install.sh:6-30` — usage header documents --global and its differences
- `install.sh:33-56` — flag parsing, CLAUDE_DIR/label resolution for both modes; --global rejects a trailing target-dir
- `install.sh:66-84` — copies target $CLAUDE_DIR instead of hardcoded $TARGET/.claude
- `install.sh:96-99` — old-folder migrations gated to project mode (`~/instructions` may be the user's own)
- `install.sh:171-181` — CLAUDE.md merge targets ~/.claude/CLAUDE.md in global mode; fresh global file gets a `## Your Global Context` placeholder
- `install.sh:224-259` — .gitignore step skipped in global mode with printed per-project rules; mode-specific "Done. Next:" guidance

#### Steps Completed
- [x] Flag parsing with error on `--global <dir>`
- [x] Smoke test against temp HOME: correct layout, markers in ~/.claude/CLAUDE.md, no ~/CLAUDE.md, no ~/.gitignore, idempotent re-run (one HVE:START)

#### Issues Encountered
- First draft used a broken display expansion (`${CLAUDE_DIR#$HOME/~}`) and a stray `${GLOBAL:+}`; both replaced with explicit label variables before commit.

### Phase 2: Test coverage
Status: Complete

#### Files Modified
- `tests/run-install-tests.sh:367-427` — test5_global_install with the 10 Phase 2 assertions (layout, merge target, placeholder, no home pollution, skipped-gitignore message, idempotent re-run, arg rejection); wired into main(); stale "all 5 test cases" header comment generalized. (Line ranges corrected 2026-07-06 post-review: the original `364-431` also spanned the Phase 4 unset-HOME assertion; assertion ownership clarified as 10 Phase 2 + 1 Phase 4.)

#### Steps Completed
- [x] Suite passes: Tests: 41 passed, 0 failed (was 31 before this task)
- [x] Drift suite unaffected: Tests: 33 passed, 0 failed

### Phase 3: Documentation
Status: Complete

#### Files Modified
- `docs/installation.md:118-158` — new "Global install (all projects on this machine)" section
- `README.md:197` — pointer paragraph in Installation
- `CLAUDE.md:271-283` — --global usage line and summary paragraph in the install section

#### Steps Completed
- [x] Em-dash check on all additions (one caught in a test comment header and replaced with colon style)

### Phase 4: Windows compatibility (plan addendum)
Status: Complete

#### Files Modified
- `install.sh:38-41` — explicit error when $HOME is unset in global mode
- `docs/installation.md:118-193` — Windows path equivalence note (%USERPROFILE%\.claude); new any-OS global paste-to-install prompt; Git Bash vs WSL $HOME semantics; manual alternative gains Windows path
- `README.md:197` — pointer rewritten to lead with the user-level folder on both OSes and offer both install paths
- `CLAUDE.md:278-281` — Windows parenthetical and pointer to the global paste prompt
- `tests/run-install-tests.sh:429-437` — assertion: `env -u HOME install.sh --global` exits nonzero (range corrected 2026-07-06 post-review; was cited as 432-441)

#### Steps Completed
- [x] Suite passes: Tests: 42 passed, 0 failed
- [x] Em-dash check on additions: clean

## Final Test Pass (2026-07-06)

- `tests/run-install-tests.sh`: 42 passed, 0 failed (superseded — see Correction 2026-07-06)
- `tests/run-drift-tests.sh`: 33 passed, 0 failed

#### Corrections
- Correction (2026-07-06): an earlier revision of this log recorded the final install-suite tally as 41; Phase 4 added one assertion, making the final tally 42. The drift-suite tally of 33 is unchanged. (That 42 was itself superseded by Phase 5 below; final tally 48.)

### Phase 5: Review remediation
Status: Complete

#### Files Modified
- `tests/run-install-tests.sh:444-495,503-505` — test5b_global_existing_claude_md: global upgrade over a pre-existing ~/.claude/CLAUDE.md, covering the marker-replace branch (old block replaced, single marker pair, outside content preserved) and the prepend branch (block prepended as first line, existing content preserved); wired into main(). Closes quality finding IV-001 (Major).
- `CONTRIBUTING.md:24-27` — test-scenario list updated from 5 to 7 scenarios. Closes quality finding IV-002 (Minor).
- This file — Phase 2/4 line-range citations corrected per RPI validation findings RV-001/RV-002.

#### Steps Completed
- [x] Install suite: Tests: 48 passed, 0 failed
- [x] Deferred as follow-ons (Minor, cosmetic or behavior-adjacent): CLAUDE.md paragraph rewrap (IV-003), unrecognized --flag rejection (IV-004), prompts-migration guard comment (IV-005)

## Security Hygiene Check

- No credential-like filenames in the diff; no secret patterns in changed files
- .gitignore credential entries present (added earlier on 2026-07-06, enforced by drift suite)
