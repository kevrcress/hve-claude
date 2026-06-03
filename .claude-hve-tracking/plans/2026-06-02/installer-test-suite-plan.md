# Implementation Plan: Installer test suite
Date: 2026-06-02
Task slug: installer-test-suite
Research: (no prior research document — plan derived from conversation and direct source audit of install.sh and README.md)
Status: Draft

## Overview

Create a `tests/` directory containing fixture files, a shared assertion library, an automated test runner covering 5 install.sh scenarios, and two separate semi-manual scripts for the natural-language-prompt scenarios. All scripts are POSIX-compatible bash. The automated runner creates isolated temp directories, seeds them, runs install.sh, asserts outcomes, and cleans up — reporting pass/fail per test. The two prompt scripts each seed their own temp directory, print the exact prompt to paste into Claude Code, pause for user input, then assert outcomes against the seeded directory.

## Phases

### Phase 1: Create fixture files

Dependencies: none
Estimated scope: 3 new files under `tests/fixtures/`
Success criteria: Each fixture file is a valid minimal CLAUDE.md representing one of the three pre-install states the installer must handle

Steps:
- [ ] 1.1: Create `tests/fixtures/claude-md-no-hve.md` — a blank/minimal CLAUDE.md with no HVE content and no markers (represents a project that has a CLAUDE.md but has never had HVE installed)
- [ ] 1.2: Create `tests/fixtures/claude-md-old-marker.md` — a CLAUDE.md with the old em-dash marker format (`<!-- HVE:START — managed by install.sh...`) wrapping a stub HVE block, plus a `## Your Project` section with unique sentinel content that must survive the upgrade
- [ ] 1.3: Create `tests/fixtures/claude-md-current-marker.md` — a CLAUDE.md with the current hyphen marker format (`<!-- HVE:START - managed by install.sh...`) wrapping a stub HVE block (older version content), plus the same-style `## Your Project` sentinel

### Phase 2: Create shared assertion library

Dependencies: none (parallel with Phase 1)
Estimated scope: 1 new file `tests/lib/assert.sh`, ~60 lines
Success criteria: All assertion helpers used by run-install-tests.sh and assert-prompt-install.sh are defined here; sourcing the file sets `PASS` and `FAIL` counters; a `finish` function prints the summary and exits non-zero on any failure

Steps:
- [ ] 2.1: Create `tests/lib/assert.sh` with:
  - `PASS=0`, `FAIL=0` counters
  - `assert_exists <path>` — passes if file/dir exists
  - `assert_not_exists <path>` — passes if file/dir does not exist
  - `assert_contains <path> <string>` — passes if file contains the string
  - `assert_not_contains <path> <string>` — passes if file does not contain the string
  - `assert_output_contains <output_var> <string>` — passes if captured output contains string
  - `finish` — prints `N passed, M failed` and exits 1 if FAIL > 0

### Phase 3: Create automated test runner

Dependencies: Phase 1, Phase 2
Estimated scope: 1 new file `tests/run-install-tests.sh`, ~230 lines
Success criteria: Running `./tests/run-install-tests.sh` from the repo root executes all 5 install.sh test cases in isolated temp dirs, prints per-test pass/fail, exits 0 only if all pass; temp dirs cleaned up on exit (even on failure via trap)

Steps:
- [ ] 3.1: Create `tests/run-install-tests.sh` with:
  - Shebang `#!/usr/bin/env bash` and `set -euo pipefail`
  - `REPO_ROOT` resolved to the repo root (dirname of script)
  - `trap 'rm -rf "$TMPDIR"' EXIT` for cleanup
  - Source `tests/lib/assert.sh`
  - `run_test <name> <body_fn>` helper that prints `[ TEST ] name`, calls body, prints `[  OK  ]` or `[ FAIL ]`

- [ ] 3.2: Implement **Test 1 — New install (no CLAUDE.md at all)**:
  - Create fresh temp dir with no files
  - Run `install.sh "$tmpdir"`, capture stdout
  - Assert: `.claude/commands/` contains at least one `hve*.md`
  - Assert: `.claude/agents/` contains at least one `hve*.md`
  - Assert: `.claude/instructions/` contains at least one `.md`
  - Assert: `prompts/` contains at least one `.md`
  - Assert: `CLAUDE.md` exists and contains `<!-- HVE:START`
  - Assert: `CLAUDE.md` contains `<!-- HVE:END`
  - Assert: `.gitignore` contains `.claude-hve-tracking/**/subagents/`
  - Assert: no `instructions/` directory at root

- [ ] 3.3: Implement **Test 2 — Existing CLAUDE.md, no markers (prepend case)** ← DR-004:
  - Create temp dir; seed with `tests/fixtures/claude-md-no-hve.md` as `CLAUDE.md`
  - Run `install.sh "$tmpdir"`, capture stdout
  - Assert: `CLAUDE.md` contains `<!-- HVE:START` before the original content
  - Assert: `CLAUDE.md` contains original sentinel text from fixture (user content preserved)
  - Assert: `CLAUDE.md` contains exactly one `<!-- HVE:START` (not duplicated)
  - Assert: `.gitignore` contains `.claude-hve-tracking/**/subagents/`

- [ ] 3.4: Implement **Test 3 — Clean upgrade (existing instructions/ with identical files)**:
  - Create temp dir; seed with `tests/fixtures/claude-md-current-marker.md` as `CLAUDE.md`
  - Seed `instructions/` with a copy of each of the 12 HVE instruction files (identical to source)
  - Run `install.sh "$tmpdir"`, capture stdout
  - Assert: `.claude/instructions/` contains exactly 12 `.md` files
  - Assert: `instructions/` directory no longer exists
  - Assert: stdout does NOT contain `! kept` (no diverged-file warnings)
  - Assert: `CLAUDE.md` still contains sentinel `## Your Project` content
  - Assert: `CLAUDE.md` contains updated `<!-- HVE:START` (block was refreshed)

- [ ] 3.5: Implement **Test 3b — Old em-dash marker upgrade**:
  - Create temp dir; seed with `tests/fixtures/claude-md-old-marker.md` as `CLAUDE.md`
  - Run `install.sh "$tmpdir"`, capture stdout
  - Assert: `CLAUDE.md` contains exactly one occurrence of `<!-- HVE:START` (not duplicated)
  - Assert: `CLAUDE.md` contains `<!-- HVE:START -` (hyphen, new format)
  - Assert: `CLAUDE.md` does NOT contain `<!-- HVE:START —` (em-dash, old format)
  - Assert: `CLAUDE.md` still contains sentinel `## Your Project` content

- [ ] 3.6: Implement **Test 4 — Diverged upgrade (one instruction file locally modified)**:
  - Create temp dir; seed with `tests/fixtures/claude-md-current-marker.md` as `CLAUDE.md`
  - Seed `instructions/` with copies of all 12 files
  - Append `# local customization` to `instructions/bash.md` to make it diverge
  - Run `install.sh "$tmpdir"`, capture stdout
  - Assert: stdout contains `! kept instructions/bash.md`
  - Assert: `instructions/bash.md` still exists (NOT removed)
  - Assert: `instructions/` directory still exists (NOT removed, has diverged file)
  - Assert: non-diverged files were removed from `instructions/` (pick one, e.g. `python.md`)
  - Assert: `.claude/instructions/` contains exactly 12 `.md` files

### Phase 4: Create prompt test — new install

Dependencies: Phase 1, Phase 2
Estimated scope: 1 new file `tests/run-prompt-new-install.sh`, ~50 lines
Success criteria: Running `./tests/run-prompt-new-install.sh` seeds a fresh temp project, prints the exact Option A prompt and the target directory path, pauses for the user to run Claude Code, then asserts outcomes and reports pass/fail

Steps:
- [ ] 4.1: Create `tests/run-prompt-new-install.sh` with:
  - `REPO_ROOT` resolved from script location
  - Create a fresh temp dir (no CLAUDE.md, no HVE files)
  - Print the target directory path clearly (`Open Claude Code in: $TMPDIR`)
  - Print the Option A prompt from README verbatim but with the clone URL amended to clone the `dev` branch: `git clone -b dev https://github.com/kevrcress/hve-claude`
  - `read -r _` pause with message: `Press Enter once Claude has finished...`
  - Source `tests/lib/assert.sh`
  - Assert: `.claude/commands/` contains at least one `hve*.md`
  - Assert: `.claude/agents/` contains at least one `hve*.md`
  - Assert: `.claude/instructions/` contains at least one `.md`
  - Assert: `prompts/` contains at least one `.md`
  - Assert: `CLAUDE.md` exists and contains `<!-- HVE:START`
  - Assert: `CLAUDE.md` contains `<!-- HVE:END`
  - Assert: `.gitignore` contains `.claude-hve-tracking/**/subagents/`
  - Call `finish`
  - Print temp dir path again after finish so user can inspect if needed; do NOT auto-delete (user may want to inspect)

### Phase 5: Create prompt test — upgrade

Dependencies: Phase 1, Phase 2
Estimated scope: 1 new file `tests/run-prompt-upgrade.sh`, ~60 lines
Success criteria: Running `./tests/run-prompt-upgrade.sh` seeds a temp project that looks like an old-style HVE install (with `instructions/` at root and a CLAUDE.md with current markers), prints the exact update prompt, pauses, then asserts migration and update outcomes

Steps:
- [ ] 5.1: Create `tests/run-prompt-upgrade.sh` with:
  - `REPO_ROOT` resolved from script location
  - Note at top of file: prompt scripts clone the `dev` branch — run only after merging `feature/installer-tests` into `dev` and pushing
  - Create a temp dir; seed with `tests/fixtures/claude-md-current-marker.md` as `CLAUDE.md`
  - Seed `instructions/` with a copy of all 12 HVE instruction files (identical to source — simulates a clean prior install)
  - Also seed `.claude/commands/`, `.claude/agents/`, `prompts/` with current HVE files (simulates a project that already has a working install)
  - Print the target directory path clearly
  - Print the update prompt from README "Updating an existing install" section verbatim but with the clone URL amended to clone the `dev` branch: `git clone -b dev https://github.com/kevrcress/hve-claude`
  - `read -r _` pause with message: `Press Enter once Claude has finished...`
  - Source `tests/lib/assert.sh`
  - Assert: `.claude/commands/` contains at least one `hve*.md`
  - Assert: `.claude/agents/` contains at least one `hve*.md`
  - Assert: `.claude/instructions/` contains at least one `.md`
  - Assert: `prompts/` contains at least one `.md`
  - Assert: `CLAUDE.md` contains `<!-- HVE:START`
  - Assert: `CLAUDE.md` contains `<!-- HVE:END`
  - Assert: `CLAUDE.md` still contains sentinel `## Your Project` content
  - Assert: `instructions/` directory no longer exists (migration completed)
  - Call `finish`
  - Print temp dir path after finish for inspection

### Phase 6: Update README with development and testing section

Dependencies: Phase 3, Phase 4, Phase 5 (need final script names and commands)
Estimated scope: README.md ~30 lines added
Success criteria: README has a `## Development` section that explains the branch strategy and how to run all 7 tests; a reader can follow it cold without this conversation

Steps:
- [ ] 6.1: Add `## Development` section to README.md (before or after the existing `## Installing HVE in Your Project` section) containing:
  - **Branch strategy** — one short paragraph: `feature/` branches → `dev` → `main`; nothing merges to `main` untested
  - **Running automated tests** — `./tests/run-install-tests.sh`; note: no network needed, runs against local repo
  - **Running prompt tests** — merge to `dev` and push first; then run `./tests/run-prompt-new-install.sh` and `./tests/run-prompt-upgrade.sh` one at a time; each seeds a temp project, prints the prompt to paste, and waits

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| `set -euo pipefail` in run-install-tests.sh causes runner to exit on first assertion failure rather than continuing | High | Wrap each `run_test` body in a subshell so failures don't propagate; use temp file log for counters |
| Temp dir cleanup skipped if script exits mid-test | Medium | Use `trap 'rm -rf "$TMPDIR"' EXIT` unconditionally in run-install-tests.sh; prompt scripts leave temp dirs for inspection |
| Old em-dash marker test (3b) may fail if awk on macOS handles the em-dash differently than GNU awk | Medium | Test on macOS (primary platform); em-dash is a multi-byte UTF-8 char — verify fixture encoding with `od -c` |
| Prompt tests require the repo to be pushed to GitHub before Claude can clone it | High | Run all install.sh tests first; only run prompt tests after pushing |
| run-prompt-upgrade.sh assertions don't verify file count exactly 12 in .claude/instructions/ | Low | Claude may install a subset; acceptable for prompt tests since exact count is hard to predict — document this as known |

## Testing Approach

Run automated tests first (no network needed, works on feature branch):
```bash
./tests/run-install-tests.sh   # all 5 install.sh tests — should all print [ OK ]
```

Then merge `feature/installer-tests` → `dev`, push `dev` to GitHub, and run the prompt tests:
```bash
./tests/run-prompt-new-install.sh   # clones dev branch; follow the printed instructions
./tests/run-prompt-upgrade.sh       # clones dev branch; follow the printed instructions
```

Once all 7 tests pass, merge `dev` → `main`.
