# Implementation Validation: Global install support (--global)
Date: 2026-07-06
Scope: full-quality (all 11 dimensions)
Files Reviewed: 5 implementation files (install.sh, tests/run-install-tests.sh,
docs/installation.md, README.md, CLAUDE.md) plus 2 tracking artifacts (plan, changes log)

## Summary
Critical: 0 | Major: 1 | Minor: 5

## Findings

### IV-001 [TEST-COVERAGE] [MAJOR]
Description: `test5_global_install` covers the fresh-file and no-marker-yet paths for
`~/.claude/CLAUDE.md`, but does not cover the two other branches of the merge logic that
`--global` mode newly makes reachable: (a) a pre-existing `~/.claude/CLAUDE.md` that
already contains an HVE:START/END block (the "replace existing block" branch), and (b) a
pre-existing `~/.claude/CLAUDE.md` with no markers (the "prepend, preserve user content"
branch). Both branches are exercised for project mode (Test 2, Test 3b) but not for global
mode. I manually verified both branches work correctly under `--global` (ran install.sh
against a synthetic `~/.claude/CLAUDE.md` with pre-existing marker content and with
pre-existing unmarked content; both produced exactly one HVE:START block and preserved
user content), so this is a coverage gap rather than a functional bug.
Evidence: `tests/run-install-tests.sh:364-441` (test5_global_install; no case constructs a
pre-existing `${fake_home}/.claude/CLAUDE.md` before invoking `--global`, contrast with
`tests/run-install-tests.sh:194-241` test2 and `tests/run-install-tests.sh:293-326` test3b
which do this for project mode)
Impact: A future regression in the marker-replace or prepend branches when the target is
`~/.claude/CLAUDE.md` specifically (e.g. a path-construction bug that only shows up for
`$CLAUDE_DIR/CLAUDE.md` vs `$TARGET/CLAUDE.md`) would not be caught by the test suite.
Recommendation: Add two assertions to test5: seed `${fake_home}/.claude/CLAUDE.md` with an
existing HVE:START block plus a sentinel outside it before the first `--global` run, and
assert the sentinel survives and the block count stays at 1; separately (or via a second
temp HOME) seed a marker-less `~/.claude/CLAUDE.md` with sentinel content and assert the
prepend path preserves it.

### IV-002 [DOCUMENTATION] [MINOR]
Description: CONTRIBUTING.md's description of the install test suite was not updated
after this change added a sixth scenario (global install). It still says "Covers 5
install.sh scenarios" and lists only the five project-mode cases, while
`tests/run-install-tests.sh`'s own header comment was correctly generalized away from "all
5 test cases" per the changes log (Phase 2).
Evidence: `CONTRIBUTING.md:24` — "Covers 5 `install.sh` scenarios: new install, prepend
case, clean upgrade, old em-dash marker upgrade, and diverged upgrade." No mention of Test
5 (global install). Contrast `tests/run-install-tests.sh:6` which was updated to drop the
stale "5" count.
Impact: Contributors reading CONTRIBUTING.md before running the suite will not know a
global-install scenario exists, and the count will visibly mismatch the 6 `run_test` calls
in `tests/run-install-tests.sh:main()` if they check.
Recommendation: Update CONTRIBUTING.md:24-25 to mention 6 scenarios and add "global
install" to the list.

### IV-003 [OVERALL-QUALITY] [MINOR]
Description: One paragraph added to CLAUDE.md's install section has visibly inconsistent
line-wrapping compared to its neighbors — most lines in the surrounding prose wrap at
roughly the same width, but one line runs much longer before the next line break, and a
short sentence ("Windows users without bash: use the global paste-to-install prompt in
docs/installation.md instead.") is packed into the middle of the line rather than on its
own line or wrapped consistently.
Evidence: `CLAUDE.md:279-281` — the "With `--global`..." paragraph; specifically line 279's
length is inconsistent with the ~95-char wrap width used on lines 271-278.
Impact: Minor readability/diff-noise issue; not a functional problem (no 80-char hard rule
in `.claude/instructions/markdown.md:36`, which allows up to ~500 chars/line).
Recommendation: Rewrap the paragraph at a consistent width matching the surrounding prose,
or give the Windows-without-bash sentence its own line.

### IV-004 [ERROR-HANDLING] [MINOR]
Description: The `--global` argument-rejection check only rejects a second positional
argument that is non-empty; it does not reject other unrecognized flags in project mode
(e.g. `./install.sh --foo` silently treats `--foo` as a target-dir path and fails later
with `cd: --foo: No such file or directory` from a different code path, an unrelated
pre-existing behavior). Not a regression from this change, but the new `--global` branch
does not add any generalized flag validation, so `./install.sh --global --verbose` is
correctly rejected while `./install.sh --globall` (typo) silently falls into project mode
and tries to `cd` into a literal `--globall` directory, producing a confusing error.
Evidence: `install.sh:32-39` — only exact-match `"${1:-}" = "--global"` is special-cased;
no rejection of flag-shaped unrecognized arguments before falling through to `TARGET="$(cd
"${1:-$PWD}" && pwd)"` at `install.sh:50`.
Impact: Low — a mistyped `--global` produces a slightly confusing but still nonzero-exit
error (via the existing `cd` failure), so this does not block functionality; flagged for
completeness since the task asked about edge cases in the new branches.
Recommendation: Optional: add a general check that rejects any leading argument starting
with `--` other than `--global`, with a clearer error message.

### IV-005 [DESIGN-PRINCIPLES] [MINOR]
Description: Migration-skip comments duplicate the same rationale ("Migrations only apply
to project installs...") only once (above the instructions-dir migration) but the
prompts-dir migration's `[ "$GLOBAL" -eq 0 ] && ...]` guard has no comment explaining why,
relying on the reader to find the earlier comment 40 lines up.
Evidence: `install.sh:99-101` (comment present) vs `install.sh:140` (guard added with no
adjacent comment)
Impact: Low; a future editor modifying just the prompts-migration block in isolation may
not immediately see why the guard exists.
Recommendation: Add a one-line comment at `install.sh:140` (or a shared comment above both
migration blocks) noting both are project-only.

### IV-006 [SECURITY] [MINOR]
Description: Security dimension checks ran clean. No secret patterns, no credential-like
filenames, no new dependencies. .gitignore already carries `.env`, `.env.*`, `*.pem`,
`*.key`, `*.p12`, `*.pfx` (added in an earlier session today) and the drift suite's Test 4
independently verifies these five entries. Flagging only as a confirmation checkpoint, not
a defect: the `--global` mode's explicit intent to skip writing `.gitignore` in the
target's home directory is a correct security/scope boundary (it never writes secrets or
tracking-ignore rules into `$HOME` itself), and the printed reminder is the right
compensating control since there is no single project `.gitignore` to modify globally.
Evidence: `install.sh:224-243` (skip branch prints exact rules instead of writing them);
`.gitignore:1-25` (repo's own gitignore, confirmed via Read); `tests/run-drift-tests.sh`
Test 4 output ("Results: 33 passed, 0 failed" including all 5 .gitignore assertions)
Impact: None (informational).
Recommendation: None required.

### IV-007 [API-USAGE/SHELL-CORRECTNESS] [MINOR]
Description: Verified core shell-correctness concerns raised in the assignment and found
them handled correctly, listed here for the record (not defects):
- `${1:-}` used consistently for the `--global` check and the post-shift target-dir check,
  so `set -u` never trips on a missing `$1` (`install.sh:32,35,42,50`).
- `shift` after consuming `--global` is safe even when it is the last/only argument,
  because bash's `shift` with no remaining positional params and no count argument is a
  no-op success, not an error, and no code path relies on `$1` existing afterward
  unconditionally.
- The `SOURCE = TARGET` guard (`install.sh:55`) correctly still fires when `--global`
  resolves `TARGET="$HOME"` and `$HOME` happens to equal the HVE source repo path (e.g.
  running install.sh from a checkout at `~/`), since the comparison runs after both
  variables are resolved regardless of mode. Manually confirmed via `bash -n` syntax check
  and full test-suite run (42/42 pass) that no ordering regression exists.
- `$HOME` unset case: `install.sh:42-45` explicitly checks `-z "${HOME:-}"` before any use
  of `$HOME`, and the new test5 assertion (`env -u HOME "${INSTALL_SH}" --global`) confirms
  nonzero exit.
Evidence: `install.sh:26-59`; full run of `bash tests/run-install-tests.sh` = "Results: 42
passed, 0 failed"; full run of `bash tests/run-drift-tests.sh` = "Results: 33 passed, 0
failed"
Impact: None (informational; confirms the specific risk areas flagged in the assignment
were implemented correctly).
Recommendation: None required.

## Coverage Notes

- **Architecture / Design Principles**: install.sh remains a single procedural script;
  the `--global` branch reuses the existing merge/copy logic via shared `$CLAUDE_DIR`,
  `$TARGET_CLAUDE` indirection rather than duplicating it, which is the right call for a
  ~250-line bash script. No structural concerns.
- **DRY**: Grepped for duplicate gitignore-rule strings and migration-skip logic; the two
  gitignore rule strings (`.claude-hve-tracking/**/subagents/`,
  `.claude-hve-tracking/sandbox/`) are duplicated once more in the printed global-mode
  guidance (`install.sh:250-252`) and again in `docs/installation.md`'s manual/paste
  sections — this is unavoidable duplication across a script's stdout and its docs, not a
  code-level DRY violation, so not flagged as a finding.
- **Version Consistency**: no new dependencies introduced; N/A for this change.
- **Refactoring**: no obvious simplification opportunities beyond IV-005's comment
  duplication note.
- **Documentation Integrity (citation check)**: Ran a full pass. Grepped living docs
  (README.md, CLAUDE.md, docs/installation.md, CONTRIBUTING.md, docs/workflow.md,
  tests/fixtures/claude-md-old-marker.md, blog-*.md) for "install.sh" references and
  checked each citing doc's claims against current script behavior and against
  `tests/run-install-tests.sh`. Result: one stale claim found and reported as IV-002
  (CONTRIBUTING.md's "5 scenarios" count). No bare `file:line` citations were added to any
  living doc in this changeset (grepped for `\.sh:[0-9]` and `\.md:[0-9]` patterns in
  README.md/docs/installation.md/CLAUDE.md — zero matches). The anchor link added to
  README.md (`docs/installation.md#global-install-all-projects-on-this-machine`) was
  verified to match GitHub's heading-slugification of the new `## Global install (all
  projects on this machine)` heading exactly.
- **Style (em-dash check)**: Grepped all `+`-prefixed (added) lines in install.sh,
  docs/installation.md, README.md, CLAUDE.md for em-dash (U+2014) and en-dash (U+2013).
  Found one en-dash in docs/installation.md:246 ("steps 2–5"), which is a numeric-range
  en-dash, not a prose em-dash, and is an acceptable typographic convention distinct from
  the repo-owner's em-dash prohibition. No true em-dashes found in new prose or comments.
  The em-dashes detected elsewhere in the diff are confined to the two tracking artifacts
  (plan.md, changes.md), which are dated snapshots, not living docs, and are not subject
  to the same prose-style enforcement as contributor-facing docs (though the changes log
  itself claims an em-dash check was run and one instance was caught and fixed in a test
  comment header, consistent with what I observed).
- **Overall Quality**: naming (`CLAUDE_DIR`, `CLAUDE_DIR_LABEL`, `TARGET_CLAUDE_LABEL`) is
  clear and consistent with the existing script's style. Function is readable by a new
  contributor without additional context beyond the header comment.
