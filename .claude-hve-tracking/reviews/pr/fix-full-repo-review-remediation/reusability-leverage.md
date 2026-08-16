# PR Review — Reusability and Leverage: fix/full-repo-review-remediation
Date: 2026-08-15
Branch: fix/full-repo-review-remediation
Dimension(s): Reusability and Leverage

## Reusability and Leverage

### Context

This PR's Phase 5 and Phase 6 (see `.claude-hve-tracking/changes/2026-08-15/full-repo-review-remediation-changes.md:265-421`)
did substantial, well-executed dedup work: the `--friction-log` paragraph (previously verbatim
in 6 command files), the "Shell stays in the parent" paragraph, the "Concurrent writes" paragraph,
the security-hygiene checklist, and the discovery-algorithm restatement were all consolidated to a
single canonical location in `CLAUDE.md` with a fixed pointer construction (`` per CLAUDE.md's
`Section` section ``), enforced going forward by new drift test 14 (reference resolution) and the
inverted `CANONICAL_BLOCK_SPECS` rows. I verified this by grep against the files on disk (not just
the changes log's claims):

- `grep -r "If \`--friction-log\` is present in the arguments, strip it before other parsing and enable friction capture"` under `.claude/` → 0 matches (was 6 before this PR).
- `grep -r "\*\*Concurrent writes\*\*: when phase implementors run in parallel"` repo-wide → 1 living match (`CLAUDE.md:313`); the two prior `.claude/` copies are now pointers.
- `grep -r "Shell stays in the parent"` → 1 living paragraph in `CLAUDE.md:202`, 1 pointer in `hve-review.md:81`.
- `grep -r "Secret exposure.*grep changed files for"` → 1 match, `CLAUDE.md:294`.
- `grep -r "Discover inputs per the Artifact Discovery"` → 0 matches; all four sites now read `` per CLAUDE.md's `Artifact Discovery & Relevance` section ``.

That work is real and does not need re-flagging. The findings below are the residual and
newly-introduced reusability gaps this diff still ships.

---

### RL-001 [Minor]
Location: `tests/run-install-tests.sh:538-546`
Finding: `_assert_line_count` is defined at `tests/run-install-tests.sh:499-512` specifically to do
a whole-line count-and-compare-to-expected assertion with pass/fail reporting via
`_ok_inline`/`_fail_inline`. Nine lines later, in the same test function
(`test6_gitignore_credentials`), the exact same shape (grep-count a fixed string in a file,
compare to an expected integer, branch to `_ok_inline`/`_fail_inline`) is reimplemented inline for
the `# HVE security hygiene` header count instead of calling the helper just defined above it:
```
header_count="$(grep -cF "# HVE security hygiene" "${fresh_dir}/.gitignore" 2>/dev/null)" || header_count=0
if (( header_count == 1 )); then
  _ok_inline "test6: re-run keeps exactly one hygiene header" "count=1"
else
  _fail_inline ...
fi
```
Recommendation: Replace with `_assert_line_count "${fresh_dir}/.gitignore" "# HVE security hygiene: never commit credentials" 1 "test6: re-run keeps exactly one hygiene header"` (the full line, so `-cxF` still matches correctly).

### RL-002 [Major]
Location: `install.sh:235-238` (pre-existing) and `install.sh:241-245` (new in this diff)
Finding: The new code adds a second copy of the same guard-then-print-header shape that already
existed in the file for the tracking-rules header:
```sh
if [ ! -f "$GITIGNORE" ] || ! grep -qF ".claude-hve-tracking" "$GITIGNORE"; then
  [ -f "$GITIGNORE" ] && printf '\n' >> "$GITIGNORE"
  printf '# HVE tracking: commit durable artifacts, ignore regenerable noise\n' >> "$GITIGNORE"
fi
...
# The header is written outside add_ignore, so it needs its own guard or it
# duplicates on every re-run.
if ! grep -qF "# HVE security hygiene" "$GITIGNORE" 2>/dev/null; then
  printf '\n# HVE security hygiene: never commit credentials\n' >> "$GITIGNORE"
fi
```
The comment at `install.sh:241-242` even names the mechanism it is duplicating ("it needs its own
guard") instead of factoring it into a helper alongside `add_ignore` (`install.sh:229-234`). This
is a second instance of the exact class the assignment calls out — the installer reinvented a
guarded-header helper it had just written the pattern for, three lines above. A third gitignore
section (there is precedent for adding more — this PR itself added one) will very likely reinvent
the pattern a third time.
Recommendation: extract `add_ignore_header() { local text="$1" marker="$2"; if [ ! -f "$GITIGNORE" ] || ! grep -qF "$marker" "$GITIGNORE"; then [ -s "$GITIGNORE" ] && printf '\n' >> "$GITIGNORE"; printf '%s\n' "$text" >> "$GITIGNORE"; fi; }` and call it twice.

### RL-003 [Major]
Location: `install.sh:246-251` and `install.sh:268-274`
Finding: The six credential patterns (`.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`) are
hardcoded twice in the same file: once as six sequential `add_ignore` calls in the project-mode
branch, and again as six `echo` statements in the global-mode "Done. Next:" guidance. Nothing in
`install.sh` ties these two lists together — a future edit to one (add/remove a pattern) can
silently desync from the other, which is precisely the failure mode the PR's own `DD-008`/`DD-016`
discussion (`.claude-hve-tracking/changes/2026-08-15/full-repo-review-remediation-changes.md:816-829,943-961`)
spent two rounds reconciling by hand across files. Within `install.sh` itself, nothing prevents a
repeat of that exact problem.
Recommendation: `readonly CREDENTIAL_PATTERNS=('.env' '.env.*' '*.pem' '*.key' '*.p12' '*.pfx')` near the top of the gitignore section; `for p in "${CREDENTIAL_PATTERNS[@]}"; do add_ignore "$p"; done` for the project-mode branch, and `for p in "${CREDENTIAL_PATTERNS[@]}"; do echo "       $p"; done` for the global-mode guidance block.

### RL-004 [Major]
Location: `install.sh:246-251,268-274`; `README.md:44,238`; `docs/installation.md:26,89-94,158,191-196`; `CLAUDE.md:295`; `tests/run-drift-tests.sh:291`; `tests/run-install-tests.sh:515`
Finding: Quantifying the duplication the assignment asks for — the same six-pattern credential
list is now written out as literal text in at least **11 places** across the repo (verified by
grep for `*.pfx` and the neighboring patterns): `install.sh` ×2 (RL-003 above), `README.md` ×2
(paste-install prompt line 44, gitignore note line 238), `docs/installation.md` ×4 (paste prompt
line 26, Option B block lines 89-94, global paste prompt line 158, global "what differs" block
lines 191-196), `CLAUDE.md` ×1 (line 295, the nominal canonical source), and the two test files
×2 (`tests/run-drift-tests.sh:291`, `tests/run-install-tests.sh:515`). Only `CLAUDE.md`'s copy is
"canonical" in the sense the rest of this PR establishes (prose files point at it); the other 10
cannot use that pointer construction because they are either executable code, paste-to-an-agent
prompts, or test assertions, so each is a genuine independent literal copy. The PR's own "Open
Items Carried to Review" section concedes this directly: `docs/` is outside
`canonical_block_corpus` and "nothing stops `docs/internals.md` from re-drifting," and no drift
test compares any of these surfaces against `install.sh`'s actual written output except test4/test6
(which assert against the *installed* `.gitignore`, not against the source-of-truth list itself).
This PR both grew the list (5→6 patterns, in the post-review remediation) and grew the number of
literal-copy surfaces (Phase 11 explicitly added four more per `DD-015`), increasing the surface
area of a defect class the PR was created to fix in the first place.
Recommendation: at minimum, add a drift-test row that greps all 11 surfaces for the same 6-item
set and fails if any surface's set differs, so future edits get a mechanical check instead of
relying on hand-verification (as Phase 11's "Installer verification" and "DD-008 leftover" table
did this session).

### RL-005 [Major]
Location: `CLAUDE.md:43-47,50` and `README.md:123-126,134,136`
Finding: Phase 11's `DD-017` (`.claude-hve-tracking/changes/2026-08-15/full-repo-review-remediation-changes.md:872-880`)
reconciled the README Command Reference table against CLAUDE.md's, and did so by copying several
clauses byte-for-byte between the two files rather than having README summarize and point at
CLAUDE.md the way `.claude/` agent/command files now point at CLAUDE.md for shared conventions.
Verified by grep — these clauses are identical in both files:
- `--mode` overrides the difficulty assessment and caps subagent dispatch: `lightweight` 1 researcher, `standard` 3, `full` 5.` (research row, `CLAUDE.md:43` / `README.md:123`)
- `--dimension all` (default) runs all 8 reviewers; `--dimension security` runs the security reviewer alone; any other single `--dimension <x>` runs that reviewer plus the security reviewer, which never gets filtered out.` (pr-review row, `CLAUDE.md:47` / `README.md:134`)
- `--scope all` (default) runs every check; `--scope compliance`, `accuracy`, or `gaps` runs that check alone.` (doc-ops row, `CLAUDE.md:50` / `README.md:136`)

and two more (plan-row `--mode`, review-row `--mode`) follow the same pattern. This is the same
shape of duplication Phase 5/6 spent effort removing from `.claude/` (RL-03 through RL-08), just
now reproduced between `CLAUDE.md` and `README.md`. The PR's own changes log names this exact gap
as unresolved: "No drift test compares `README.md`'s Command Reference to `CLAUDE.md`'s: Phase 11
reconciled five divergent rows, but future divergence stays invisible"
(`.claude-hve-tracking/changes/2026-08-15/full-repo-review-remediation-changes.md:1016-1017`).
Recommendation: either add a drift-test row diffing the flag-mechanics clauses between the two
tables (cheapest fix, mirrors test 14's approach), or make README's cells shorter human-facing
summaries with a "see CLAUDE.md's Command Reference for exact `--mode`/`--dimension`/`--scope`
semantics" pointer instead of restating the mechanics verbatim.

---

## Summary

The PR's headline dedup work (Phase 5/6) is genuine and verified clean on disk — no residual
copies of the six previously-flagged canonical blocks remain in `.claude/`. The gaps above are
concentrated in two places the dedup sweep didn't reach: `install.sh` (which can't use the
prose-pointer construction, so its own two internal lists were never factored into a shared bash
array) and the `README.md` ↔ `CLAUDE.md` Command Reference tables (reconciled once by hand in
Phase 11 with no mechanical guard against re-drift, an omission the implementers themselves
recorded but did not close).
