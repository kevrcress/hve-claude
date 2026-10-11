# Planning Log: Platform-Drift and Friction Quick Fixes

Date: 2026-10-10
Task slug: platform-drift-quick-fixes
Plan: .claude-hve-tracking/plans/2026-10-10/platform-drift-quick-fixes-plan.md

## Discrepancies

### DD-001: Research doc has a different slug from the plan
Source: one research doc (`cross-repo-process-review`) feeds several plans; this plan is its step 1 only.
Assumption: passing the slug explicitly and naming the research path in the plan's `Research:` header is enough for `/hve-implement`. `/hve-review` will not find the research by slug until Step 1.6 lands; until then the reviewer must be pointed at the header path.
Risk: a review run before Step 1.6 is merged treats research as absent (it is an optional input, so review still runs).

### DD-002: Research shell policy is prose only; frontmatter unchanged
Source: Decision D4. Platform check: `allowed-tools` is a pre-approval list and does not restrict the tool set.
Assumption: leaving `allowed-tools: Read, Write, Glob, Grep, Agent` on hve-research.md means Bash calls prompt under the user's permission mode instead of being pre-approved, which is the safer default for a phase meant to be read-only. Adding `Bash` would pre-approve every shell command.
Risk: a prompt on each shell call in research; acceptable, and the user can add narrower allow rules. Scoped forms such as `Bash(git log:*)` in frontmatter were not adopted because their behaviour in command frontmatter was not confirmed.

### DD-003: Index-free working-tree diff instead of `git add -N`
Source: the friction-log researcher suggested `git add -N .`, diff, `git reset`.
Assumption: `git reset` after `git add -N` would also unstage anything the user had staged, which is a destructive side effect on the user's working state. The chosen recipe (`git diff HEAD` plus `git diff --no-index /dev/null <file>` per untracked file) never touches the index.
Risk: the recipe is unproven until Step 3.1 runs it; the step is a hard gate.

### DD-004: `--working-tree` documented in the prompt and README, not the CLAUDE.md Command Reference row
Source: lean-restructure plan, locked decision 2 (Command Reference rows carry purpose and when-to-use, no flags), cited in the 2026-09-14 research item 7.
Assumption: that decision still stands (D5 answer pending on path, not on the decision itself). The existing `/hve-pr-review` row already lists `--dimension` and `--compact`, so the row will be briefly inconsistent until lean restructure lands.
Risk: `/hve-doc-ops` may flag the undocumented flag in CLAUDE.md. Accepted.

### DD-005: CLAUDE.md grows by about 9 lines while a plan to shrink it is pending
Source: Steps 2.1, 4.1, 4.4, 5.1, 5.3.
Assumption: correctness fixes should not wait for the restructure. The lean-restructure plan must re-derive its Phase 7.3 line bound after this lands (it already must, per the 2026-09-14 research).
Risk: none beyond the re-derivation.

### DD-006: Background-dispatch and check-disk rules are canonical in CLAUDE.md, with pointers in two commands
Source: research Theme 3 (background dispatch), friction F04.
Assumption: every dispatching command already reads CLAUDE.md's `Subagent Dispatch Discipline`, so one canonical paragraph guarded by a Test 10 row is safer than nine duplicated sentences. Pointers are added only where a bare "Wait for all subagents to complete." sentence exists today (hve-research.md:77, hve-pr-review.md:147).
Risk: commands without a pointer (hve.md, hve-plan.md, hve-implement.md, hve-review.md, hve-doc-ops.md, hve-challenge.md, hve-prompt-builder.md) rely on the CLAUDE.md read. hve-review.md:97 has its own "Wait for all validators to complete." and is left as is.

### DD-007: Reserved-names note instead of tree entries for `consults/` and `gh-sync/`
Source: Decision D1 (hve-claude takes no dependency on hve-orchestrator or HiVE).
Assumption: declaring the names as reserved for companion tooling prevents a future HVE folder from colliding with them, without HVE documenting another tool's formats. The `<slug>-review.md` filename collision with orch-grader-lite is not addressed here.
Risk: the collision stays open until the external-consumer contract (research sequence step 6).

### DD-008: Items deliberately left out
Source: research Themes 3 and 5.
- F05 (date folder split at midnight): Minor, traceability only.
- F12 (`/hve-review` may not remediate on request): needs a ruling, not a fix.
- Seed-research convention (2026-09-14 friction entry 2).
- Whether `hve-implementation-validator` receives Glob and Grep while it lists Bash (research Open Question 1): needs a live dispatch test.
- F03 (enforce the no-Bash rule): superseded by Decision D4, which goes the other way.
Assumption: none of these blocks the bundle.
Risk: they stay in the backlog; the research doc is their record.

### DD-009: Plan artifacts written on `feature/validators-inherit-model`, not a dedicated branch
Source: an attempt to create `fix/platform-drift-quick-fixes` during planning was refused by the session's permission layer while PR #4 was still open.
Assumption: the plan, details, and log are left uncommitted in the working tree so they do not join PR #4. Implementation should start from a branch cut after PR #4 merges.
Risk: if PR #4 changes before merge, line numbers in the details file may shift; anchors are quoted text for that reason.

Plan Validator entries (2026-10-10, hve-plan-validator, static reading only, no shell). Evidence and reasoning for each: .claude-hve-tracking/reviews/rpi/2026-10-10/platform-drift-quick-fixes-plan-validation.md. Numbering continues from DD-009 above and from DR-002, which sits after the planning-time checks further down this file.

### DR-003: F10 fix misses the three prose copies of the tracking rules (paste-to-install prompts)
Source: research Theme 4 (F10) and the friction-log checklist at .claude-hve-tracking/research/subagents/2026-10-10/cross-repo-process-review-friction-logs.md:147, which scopes the fix to the paste-to-install test prompts as well as install.sh and the docs.
Gap: Step 4.4 and guard Step 4.6 cover the 11 literal copies (list confirmed complete by Grep for `\*\*/subagents/` outside .claude-hve-tracking: same 11 hits). Three prose copies name the rules in words, so that pattern cannot find them: README.md:42-44 (Quick start paste prompt), docs/installation.md:24-26 (Option A, labelled recommended), tests/run-prompt-new-install.sh:91-93 (heredoc prompt). After the plan a paste install still writes two rules, so the claim at .claude/commands/hve-pr-review.md:36 stays false on the recommended install path. Step 4.5 also adds a diff.patch assertion beside tests/run-prompt-new-install.sh:147 while the prompt that test pastes still asks for two paths, so the new assertion passes only if the model guesses a third rule.
Severity: Major
Recommendation: add the three prose copies to Step 4.4, add a second guard pattern to Step 4.6 (for example `subagents and sandbox`), and update the heredoc in the same step as the assertion.
Status: Open

### DR-004: Decision D1 consequence (annotate the HiVE brief) has no step and no recorded exclusion
Source: research "Decisions recorded" D1 (.claude-hve-tracking/research/2026-10-10/cross-repo-process-review.md:120) and W5 (:22): the brief is kept and still needs Corrections-rule annotations where it is false at HEAD (brief:190-213).
Gap: plan:12 says D1 to D5 are plan content, but no step annotates the brief, and neither the Out of scope line (plan:14) nor DD-008 lists it. It is also absent from research step 0.
Severity: Minor
Recommendation: add one step under Phase 5, or add a line to DD-008 naming where it will be done.
Status: Open

### DR-005: D4 permits one read-only shell pass; the replacement text sets no bound
Source: research D4 (.claude-hve-tracking/research/2026-10-10/cross-repo-process-review.md:115, :123): "one read-only parent shell pass for orientation and git history".
Gap: details 1.2 lets the parent run read-only shell commands for orientation and git-history evidence with no count or phase limit, and details 1.4 adds a further read-only listing at consolidation. The Method line is the only control.
Severity: Minor
Recommendation: either carry the bound into details 1.1 and 1.2 (one pass in Phase 1, plus the existence re-checks in Phase 3), or record a DD entry that the bound was dropped on purpose.
Status: Open

### DR-006: Three DD-008 exclusions have no carrier in any later sequence step
Source: research Recommended sequence steps 2 to 7; DD-008.
Gap: all five DD-008 exclusions are defensible (none is named in research step 1; see the validation report, section 2). F05, the seed-research convention, and Open Question 1 (implementation-validator Glob and Grep) are not named in steps 2 to 7 either, so "the research doc is their record" leaves them with no owner.
Severity: Minor
Recommendation: add a pointer for each (backlog memory file or a named later plan) in DD-008's Risk line by a new entry, not by editing DD-008.
Status: Open

### DD-010: Phase dependencies leave four same-file pairs free to run in parallel
Source: Dependencies lines at plan:21, :38, :52, :70, :85 and the Risk Log row at plan:116 ("Dependencies lines forbid parallel dispatch of those phases").
Assumption: that the Dependencies lines serialize every pair of phases that share a file.
Risk: they do not. Phases 1 and 2 both edit .claude/commands/hve-research.md (Steps 1.1 to 1.4, Step 2.3). Phases 1 and 3 both edit .claude/commands/hve-review.md (Steps 1.5, 1.6, 3.7). Phases 2 and 4 both edit CLAUDE.md (Steps 2.1, 4.1, 4.4). Phases 3 and 4 both edit README.md (Steps 3.8, 4.4). All four read "Dependencies: none". With mode unset, .claude/commands/hve-implement.md:97 and :120 dispatch no-dependency phases in parallel for Medium and up, and every phase's suite run would read a tree another phase is editing. The "run in standard or lightweight" instruction lives only in the Risk Log. Phases 3 and 5 say "none" followed by a prose caveat, which a dependency-graph reader (hve-implement.md:40-41) can take either way.
Severity: Major
Recommendation: make the chain explicit (Phase 2 depends on 1, 3 on 2, 4 on 3, 5 on 4), or add a plan-header line requiring `--mode standard`, and correct the Risk Log row.
Status: Open

### DD-011: Phase 3 success criterion on `--working-tree` cannot pass from the details text; argument-hint is not updated
Source: plan:54 (`grep -c -- "--working-tree" .claude/commands/hve-pr-review.md` prints at least 2); details 3.2, 3.4, 3.5; .claude/commands/hve-pr-review.md:3.
Assumption: that the replacement text puts the flag literal on two lines of the command file.
Risk: only details 3.2 contains the literal, on one line. Details 3.4 and 3.5 use `WORKING_TREE`. The file has no occurrence today, so the criterion yields 1 and fails. The only edit that would make it 2 is the frontmatter `argument-hint` at hve-pr-review.md:3, which lists every other flag and which no step touches. An implementor must improvise an unplanned frontmatter edit or pad the file to satisfy grep.
Severity: Major
Recommendation: add `[--working-tree]` to the argument-hint in Step 3.2 and say so in details 3.2.
Status: Open

### DD-012: Working-tree mode is routed only through the empty-diff guard; an empty working-tree review is not stopped
Source: details 3.2 (mode replaces the branch diff), details 3.4 (WORKING_TREE consulted only when the base diff has zero files), details 3.5 (alternative attached to step 5); .claude/commands/hve-pr-review.md:30-36, :51, :53.
Assumption: that the flag is only ever passed on a branch with no commits ahead of main.
Risk: with the flag set and a non-empty branch diff, step 2 at :30 still takes the branch file list, the guard does not fire, steps 3 and 4 produce a branch stat and commit list, and only step 5 switches form, so the review header (Base: main, Commits: N) describes a different diff from the patch. With the flag set and a clean working tree, nothing stops an empty patch from being dispatched, which is the outcome the guard exists to prevent. Details 3.4 also refers to "the working-tree form of steps 2 to 5" while forms exist only for steps 2 and 5.
Severity: Major
Recommendation: branch on WORKING_TREE before step 2 (skip the branch diff, use working-tree forms for steps 2, 3, 5, mark step 4 and the Base and Commits header lines as HEAD and N/A), and stop when the working-tree file list is empty.
Status: Open

### DD-013: Security-floor step for the excluded folder has three holes
Source: Step 3.6 and its [HIGH] assumption (plan:63-64); details 3.6; CLAUDE.md:294-299.
Assumption: that `git diff <base> -- .claude-hve-tracking` plus the secret-exposure grep keeps the floor for everything the exclusion removes.
Risk: (1) in working-tree mode `git diff HEAD` omits untracked files, which is the F09 fact details 3.5 states, so newly written tracking artifacts get no scan in the mode built for uncommitted work. (2) only the first of the four Security Hygiene checks runs; a credential-like file dropped under the folder is not caught by a content grep and is no longer on the changed-file list the name check uses (CLAUDE.md:296). (3) the step sits after step 5, but a branch whose only changes are tracking artifacts now has zero files at step 2, so the empty-diff guard stops it first: no review, no scan, and a message that the work is not on the diff. Tracking-only branches exist in this repo (HEAD commit ba369fd).
Severity: Major
Recommendation: scan `git diff <base> --name-only -- .claude-hve-tracking` plus, in working-tree mode, `git ls-files --others --exclude-standard -- .claude-hve-tracking`; run the name check on that list; run the scan before the guard, and have the guard say "only tracking artifacts changed" when that is the case.
Status: Open

### DD-014: Step 6.1 expected drift count is wrong
Source: plan:101 ("baseline 250 passed, expected 251 with the Step 2.2 row"); Step 2.2 assumption at plan:45.
Assumption: that a count-1 `identical` row adds one pass and nothing else in the plan changes the count.
Risk: tests/run-drift-tests.sh:620 and :638 each record a pass for a count-1 identical row (carrier count, then "is canonical"), so the row adds 2. The new `--working-tree` bullet in .claude/prompts/pull-request.md adds one token to Test 13 (tests/run-drift-tests.sh:931-934), which adds 1. Static expectation is 253, not 251. No existing assertion in either suite fails after the planned edits (report, section 5). An implementor who sees 253 against a stated 251 has to stop and explain a non-problem.
Severity: Minor
Recommendation: change the expectation to 253 and mark it [MEDIUM: derived from the test source, not run].
Status: Open

### DD-015: Step 3.7 appends every untracked file to the `/hve-review` changed-file list, including the task's own tracking artifacts
Source: Step 3.7; details 3.7; .claude/agents/hve-rpi-validator.md:23, :50.
Assumption: that every untracked file is part of the change under review.
Risk: for uncommitted work the plan, details, planning log, changes log, and review files are usually untracked, and stray drafts may be too (this repo has five at the root). The validator rule at hve-rpi-validator.md:50 reports any listed file missing from the changes log as an unlisted change, so each phase validator will report the same false set. The plan applies the tracking-folder exclusion in `/hve-pr-review` but not here. The description at hve-rpi-validator.md:23 also goes stale.
Severity: Minor
Recommendation: add `-- . ':(exclude).claude-hve-tracking'` to the ls-files call in details 3.7 and one clause telling the parent to drop untracked files that predate the task.
Status: Open

### DD-016: Details 2.4 conflicts with the untouched Coverage rule; "complete" is undefined
Source: details 2.4 ("treat the reviewer as having run"); .claude/commands/hve-pr-review.md:164 (Coverage is filled from reviewers that returned Complete); details 2.1.
Assumption: that a parent can tell a complete output file from a partial one, and that :164 will be read as including a silent reviewer with a complete file.
Risk: a reviewer that returned nothing did not return Complete, so :164 read literally lists its dimension as not covered while 2.4 counts it as run. The reviewer template (.claude/agents/hve-pr-reviewer.md:86-98) has no terminal marker, so "complete" has no test. For the Security and Compliance reviewer this decides whether Approve is allowed (:166, :169). Separately, the canonical rule in details 2.1 fits read-only agents; for `hve-phase-implementor` an incomplete changes-log section means a half-edited tree, where a blind re-dispatch repeats applied steps.
Severity: Minor
Recommendation: add a clause to :164 covering the file-verified case, define complete as "every section of the agent's Output File template is present", and add "for an implementor, resume from the changes log instead of re-dispatching" to the CLAUDE.md paragraph.
Status: Open

### DD-017: F14 re-check rules name no outcome and no place to record the check
Source: details 1.4 ("record the check"); details 1.5; .claude/commands/hve-review.md:97, :146-149.
Assumption: that a parent knows what to do when its re-check falsifies a validator finding.
Risk: hve-review.md:97 and :149 require every tally number to trace to a validation output file. Details 1.5 adds a re-check but does not say whether a falsified finding is dropped, kept, or excluded from the tally, so a parent must break one rule or the other. Research Theme 6 records parents overriding validator verdicts with no rule; this adds a trigger without the rule. Details 1.4 does not say where the check is recorded.
Severity: Minor
Recommendation: in 1.5, route a falsified finding through the existing Contested severity rule (hve-review.md:148): keep it in the log, tag it, exclude it from the tally, record the evidence. In 1.4, name the Method line or the finding itself as the place to record.
Status: Open

### DD-018: README flag row targets the wrong table; flag decision and punctuation instruction are inconsistent
Source: Step 3.8; details 3.8; README.md:134, :141-147, :183-185; details:7; plan:12.
Assumption: that the table near README.md:146 is a general flags table.
Risk: it is the Cross-cutting flags table, introduced at README.md:141 with "Two flags are not listed per-command above because each works the same way wherever it is accepted". A single-command third row makes that sentence false. Per-command flags live in the command's own row (README.md:134 lists `--dimension` and `--compact`) and in the examples at :183-185. Details 3.8 says to match the neighbouring bullet punctuation in pull-request.md, which is an em-dash, while details:7 forbids em-dashes in new prose. The Overview says no new command, agent, or directory ships but does not record that a new public flag ships, or how it will sit beside the `--yes` flag planned for Bundle B.
Severity: Minor
Recommendation: move the README edit to :134 and add one example line; pick a colon for the new bullet and say so; add a DD entry for the flag.
Status: Open

### DD-019: Phase 3 insertion points are underspecified
Source: details 3.3, 3.5, 3.6; .claude/commands/hve-pr-review.md:36, :47-65.
Assumption: that a separate agent can place the three new blocks and the report line without asking.
Risk: details 3.3 says to state the exclusion in "the review report's scope line", but the review template at hve-pr-review.md:47-65 has no such line (it has Base, Files changed, Commits, Coverage). Details 3.3 and 3.5 both say "after step 5" and 3.6 says "after the exclusion sentence", with no order between the working-tree block and the security step. At :36 the pathspec must go before the `>` redirect, which "append" does not say. `-- .` limits the diff to the current directory, so the commands assume the repo root as cwd, unmarked.
Severity: Minor
Recommendation: add a `Scope:` line to the template in details 3.3, give the three blocks a fixed order, show the full :36 command, and use `':(top)'` forms or state the cwd assumption with a marker.
Status: Open

### DD-020: Step 3.1 fixture makes the gate fail for a reason unrelated to the index; the criterion tests the prototype, not the shipped text
Source: Step 3.1 (plan:57); details 3.1; planning-time check at log line "Working-tree recipe"; plan:54.
Assumption: that `git status --porcelain` is identical before and after in the fixture Step 3.1 describes.
Risk: the recipe writes `$OUT` under `.claude-hve-tracking/`. The planning-time fixture already had an untracked `.claude-hve-tracking/` folder, so porcelain did not change. Step 3.1's fixture list omits it, so creating the folder adds a `??` line, the comparison differs, and the hard gate says stop. The fixture also needs the folder for prototype check 4 to mean anything, and needs `mkdir -p` for the redirect to succeed. Separately, Step 3.1 runs before the text ships, so a transcription error in Step 3.5 passes every Phase 3 criterion, unlike Step 5.2, which extracts the command from the edited file.
Severity: Minor
Recommendation: add the pre-existing untracked tracking file and `mkdir -p` to the fixture, compare `git ls-files --stage` output for the index claim, and add a post-edit guard that extracts the block from hve-pr-review.md and re-runs it.
Status: Open

### DD-021: Several success criteria can pass without the change being made
Source: plan:23, :40, :54, :72, :120.
Assumption: that each phase's criteria cover its steps.
Risk: Phase 1's `grep -c "Method:"` at least 2 is met by the Step 1.1 and 1.2 text alone, so it does not show the template line of Step 1.3 was added. No criterion tests Steps 1.4, 1.5 (F14), 2.3, 2.4 (pointer sentences, Blocked reviewers), or 4.2 (the two instruction-path carriers). Testing Approach says each phase re-runs the drift suite, but Phases 4 and 5 have no drift run in their steps or criteria although Phase 4 edits text read by Tests 8, 11, and 16.
Severity: Minor
Recommendation: use `grep -c "^Method: \["` equals 1; add one grep per untested step (for example `Exception:` in both files, `Dispatch is asynchronous` in the two commands, `~/.claude/instructions/` in the two carriers); add the drift run to Phases 4 and 5.
Status: Open

### DD-022: Verification claims without the command that produced them
Source: plan:120 ("Baselines measured 2026-10-10 on this tree: drift 250 passed, 0 failed; install 69 passed, 0 failed, rc=0"); log "Planning-time checks" section.
Assumption: that the reader can reproduce the measurements.
Risk: the baseline line gives no command or log path and one rc for two suites; it gates the Step 6.1 expected counts. The planning-time checks name tools (`jq`, `cmp`, `grep -c`) and results but not the command lines. They are declared non-gating, so the exposure is small.
Severity: Minor
Recommendation: put the two commands and both rc values beside the baseline; add the command lines to the planning-time checks by a new dated entry.
Status: Open

### DD-023: Plan-step assumptions with no confidence marker
Source: Steps 1.1, 1.8, 2.1, 3.3, 3.7, 4.2, 4.5, 5.3.
Assumption: each of the following is stated as fact with no [HIGH], [MEDIUM], or [LOW].
Risk: (a) details 1.1 text asserts that current Claude Code omits Glob and Grep from the parent by default; the research limits this to macOS and Linux as of v2.1.296. (b) Step 1.8 expected survivors: correct today (Grep shows exactly CLAUDE.md:202, hve-researcher.md:30, hve-research.md:49, :75), but no command output is adjacent. (c) DD-006: every dispatching command reads the CLAUDE.md section. (d) Step 3.3: cwd is the repo root. (e) Step 3.7: every untracked file belongs to the change. (f) Step 4.2: eleven carriers inherit the rule; seven of them carry no pointer to the Instructions Reference section (hve-git-commit.md:9, :36; hve-git-merge.md:9; hve-prompt-builder.md:30; hve-prompt-refactor.md:59; hve-doc-ops.md:27; hve-prompt-updater.md:32). (g) Step 4.5 leaves two conditionals open that were answerable at planning: the global-printout test does not assert the printed rules (tests/run-install-tests.sh:404-405), and tests/run-prompt-upgrade.sh carries no rules list. (h) details 5.3: artifact discovery ignores unlisted folders; CLAUDE.md:243-248 states no such restriction.
Severity: Minor
Recommendation: add a marker to each; resolve (g) to a definite instruction.
Status: Open

### DD-024: Details 4.1 wording doubles the `.claude/` segment on a literal read; details 4.3 hedges a known edit
Source: details 4.1; details "4.3 to 4.5"; CLAUDE.md:267-282, :382.
Assumption: that "relative to the HVE install root: the project's `.claude/`" reads correctly beside table paths that already begin with `.claude/`.
Risk: install root plus table path gives `.claude/.claude/instructions/bash.md`, and `~/.claude/.claude/...` for global, a confusion the install suite already guards against (tests/run-install-tests.sh:374). The second sentence rescues it. Separately, "these two rules" is present at CLAUDE.md:382 (details say near :379-381, "if present"); with three rules it must change.
Severity: Minor
Recommendation: say "relative to the project root for a project install; under a global install the same files are in `~/.claude/instructions/`"; make the :382 edit definite.
Status: Open

### DD-025: Hook rewrite changes the date from local to UTC; Step 5.2 fixture is incomplete
Source: details 5.1 (`now | strftime("%Y-%m-%d")`); CLAUDE.md:117, :330; Step 5.2.
Assumption: that the jq form is equivalent to `date +%Y-%m-%d`.
Risk: `strftime` on `now` formats UTC, so entries written in the evening in US time zones carry tomorrow's date, against the "always today's date" convention. Step 5.2 does not say how to extract the command string from the fenced block or that `$TMPDIR/hooktest/.claude-hve-tracking/changes/` must exist for the append. The escaping itself decodes to the stated command, and install.sh:171, :183, :202-206 copy the block with `%s` and `getline`, which preserve the backslashes.
Severity: Minor
Recommendation: use `now | strflocaltime("%Y-%m-%d")` (or `localtime | strftime`), and add the `jq -r` extraction path and `mkdir -p` to Step 5.2.
Status: Open

### DD-026: Ignore-rule upgrade path and global printout are not fully covered
Source: Steps 4.3, 4.5, 6.4; install.sh:229-240, :262-266; tests/run-drift-tests.sh:1169-1181; docs/installation.md:222-243.
Assumption: that a re-install is enough for existing projects and that a test guards the printed rule.
Risk: on re-install `add_ignore` appends the new rule at end of file, under the credential header, because the tracking header guard at install.sh:235 is not re-entered (cosmetic). A `diff.patch` already committed stays tracked; Step 6.4 does not mention `git rm --cached`. The global printout line is unguarded: Test 16 filters out `claude-hve-tracking` lines and install test5 asserts only "skipped .gitignore", so the write list and the echo list can drift. The paste-to-update prompt has no .gitignore step, so paste upgraders never get the rule.
Severity: Minor
Recommendation: add an `assert_output_contains` for the new echo line in test5; extend the Step 6.4 note with the `git rm --cached` case and the paste-update gap.
Status: Open

### DD-027: Pointer sentence sits outside the guarded construction; no branch when Bash is denied
Source: details 2.3, 2.4; details:7; tests/run-drift-tests.sh:961 (Test 14 pattern), Step 2.2 row; details 1.1; DD-002.
Assumption: that the pointer stays punctuation-stable and that a Bash prompt can always be answered.
Risk: the pointer reads "per the **Dispatch is asynchronous** rule in CLAUDE.md's `Subagent Dispatch Discipline` section", which does not match Test 14's fixed `per CLAUDE.md's ... section` construction, so nothing checks that it resolves. The new Test 10 row passes only while the pointers omit the period inside the bold; details:7 lets the implementor adjust punctuation. Details 1.1 gives two branches (Glob and Grep, or shell); for a non-interactive caller (Decision D2) a Bash call that is not pre-approved may be denied, and the old Glob plus Read fallback is removed.
Severity: Minor
Recommendation: reword to "per CLAUDE.md's `Subagent Dispatch Discipline` section (the Dispatch is asynchronous rule)"; add a third branch to 1.1: when neither is available, use targeted Read and write "no parent shell" on the Method line.
Status: Open

### DD-028: Sibling carriers left as they are (none named by research)
Source: .claude/agents/hve-implementation-validator.md:120, :123; .claude/agents/hve-phase-implementor.md:6, :32; .claude/commands/hve-doc-ops.md:70-71.
Assumption: that the defects fixed here have no siblings worth a line in this plan.
Risk: hve-implementation-validator.md:120 and :123 hardcode `[MAJOR]` and `[CRITICAL]` in the findings template, the same class as hve-rpi-validator.md:83. hve-phase-implementor.md has no `tools:` line, so it inherits Bash, and :32 tells it to use Glob and Grep; by the research's platform reading it may have neither. hve-doc-ops.md:70-71 gives the parent the same instruction. These are outside research step 1, so they are not coverage gaps.
Severity: Minor
Recommendation: record them in the backlog, or fold the validator template into Step 2.5 since the edit is identical.
Status: Open

## Planning-time checks (ran 2026-10-10 in a scratch directory, parent shell, zsh)

These lower the risk of Steps 3.1 and 5.2 but do not replace them: the implementor re-runs both against the text as actually written into the files.

- Hook command (details 5.1): the JSON block parsed with `jq`; the decoded command, fed `{"tool_input":{"file_path":"/tmp/example.md"}}` on stdin with `CLAUDE_PROJECT_DIR` set, exited 0 and appended `2026-10-10 - Modified: /tmp/example.md`.
- Working-tree recipe (details 3.1): in a scratch repo with one modified tracked file, one staged file, one untracked file, and an untracked `.claude-hve-tracking/` folder, `cmp` of `git status --porcelain` before and after reported no difference; `grep -c` on the patch returned 1 for the untracked file's content, 1 for the staged change, 1 for the unstaged change, and 0 for `claude-hve-tracking`.
- Not checked at planning time: the same loop under bash (the commands will run in whatever shell the Bash tool provides), filenames containing newlines, and binary untracked files.

### DR-001: Research says hook variable is "probably non-functional"; platform check says undocumented
Source: research Theme 3 row 4; 2026-09-14 research Open Question 8.
Resolution: the plan replaces the example with the documented stdin form and executes the command against sample input (Step 5.2). It does not claim a live hook run.
Status: Resolved in plan; live verification remains [MEDIUM].

### DR-002: Research step 1 lists "F04" under one bullet and "background-dispatch wait sentence" under another
Source: research Recommended sequence, step 1.
Resolution: both are served by the single CLAUDE.md paragraph in Step 2.1 (DD-006).
Status: Resolved.

## Resolutions (2026-10-10, parent, plan v2)

The validator's entries above are left as written. Each Major was checked against the files before acting (DR-003: README.md:42-44, docs/installation.md:24-26, tests/run-prompt-new-install.sh:91-93 read and confirmed; DD-010: hve-implement.md:120 read and confirmed; DD-011: hve-pr-review.md:3 read and confirmed; DD-012 and DD-013: confirmed by reading details v1). All five stood.

| Entry | Severity | Resolution in plan v2 |
|---|---|---|
| DD-010 | Major | Dependencies chain made explicit (2 on 1, 3 on 2, 4 on 3, 5 on 4, 6 on 5); header requires `--mode standard`; Risk Log row corrected |
| DD-011 | Major | Step 3.2 edits `argument-hint` at hve-pr-review.md:3; criterion now reachable |
| DD-012 | Major | Steps 3.3 and 3.5 restructure Phase 1 so the mode is chosen before step 2 and applies to file list, stat, commits, and patch; empty working-tree review stops. Semantics chosen: merge-base to working tree (see DD-029) |
| DD-013 | Major | Step 3.4 scans the active mode's full tracking file set (untracked included), checks filenames as well as content, and runs before the guard; guard gains an "only tracking artifacts changed" outcome |
| DR-003 | Major | Step 4.4 adds the three prose copies; Step 4.6 adds a second guard pattern; details 4.3 ties the heredoc edit to its assertion |
| DR-004 | Minor | Recorded as out of scope in DD-030 |
| DR-005 | Minor | Bound carried into details 1.1 and 1.2 |
| DR-006 | Minor | Owners named in DD-030 |
| DD-014 | Minor | Step 6.1 says 253 [MEDIUM] and treats the measured count as the record |
| DD-015 | Minor | Details 3.7 adds the exclusion and the predates-the-task clause; hve-rpi-validator.md:23 updated |
| DD-016 | Minor | Details 2.1 defines complete and adds the implementor case; details 2.4 extends the Coverage rule |
| DD-017 | Minor | Details 1.5 routes falsified findings through Contested severity; details 1.4 records on the Method line |
| DD-018 | Minor | README edit moved to the :134 row plus an example line; bullet uses a colon; flag recorded in DD-029 |
| DD-019 | Minor | Details 3.3 fixes the order and shows where the pathspec goes; details 3.6 adds a `Scope:` line; root pin replaces the cwd assumption |
| DD-020 | Minor | Step 3.1 fixture extended, index compared with `git ls-files --stage`; Step 3.9 re-runs the shipped text |
| DD-021 | Minor | Criteria tightened per phase; drift run added to every phase |
| DD-022 | Minor | Testing Approach now gives both commands and says the drift rc was not captured |
| DD-023 | Minor | Markers added at Steps 1.1, 1.7, 1.8, 2.1, 3.1, 3.3, 3.7, 4.2 |
| DD-024 | Minor | Details 4.1 reworded; the :382 edit is definite |
| DD-025 | Minor | `strflocaltime`; Step 5.2 gives the extraction and `mkdir -p` |
| DD-026 | Minor | test5 assertion added in Step 4.5; Step 6.4 notes extended |
| DD-027 | Minor | Pointer reworded to the Test 14 construction; third branch added to details 1.1 |
| DD-028 | Minor | hve-implementation-validator.md:120-123 folded into Step 2.5; the Glob and Grep instructions in hve-phase-implementor.md:32 and hve-doc-ops.md:70-71 go to DD-030 |

### DD-029: `--working-tree` is a new public flag, and it means "everything not yet on main"
Source: validator DD-012 and DD-018; friction F08 and F09.
Assumption: the flag reviews the merge-base against the working tree plus untracked files, so it covers committed branch work as well as uncommitted work. The alternative is uncommitted work only, against `HEAD`. The first was chosen because `/hve-pr-review` exists to review a change before it merges, and on a branch with no commits the two are the same.
Risk: a user who wants to review only the latest uncommitted fix round gets the whole branch as well. Changing the choice is one line (the BASE definition in details 3.3). Kevin confirms at the plan checkpoint. The flag must be reconciled with `--yes` when Bundle B is planned.

### DD-030: Further items left out of this plan, with owners
Source: validator DR-004, DR-006, DD-028.
- Annotating the HiVE brief where it is false at HEAD (Decision D1 consequence, research W5): owner is a housekeeping pass after PR #4 merges; recorded in the research doc.
- F05, the seed-research convention: owner is the Bundle A plan, which already edits hve-research.md's header template region.
- Whether `hve-implementation-validator` and `hve-phase-implementor` receive Glob and Grep while they hold Bash (research Open Question 1; hve-phase-implementor.md:32; hve-doc-ops.md:70-71): needs one live dispatch test; owner is the Bundle C plan (installer and platform).
- F12: needs Kevin's ruling; recorded in the research doc's Open questions.
Assumption: none blocks this bundle.
Risk: owners are plans not yet written; the research doc remains the record until they are.

## Planning-time checks, second run (2026-10-10, parent, bash)

Commands, run in a scratch repo built to the Step 3.1 fixture, with the recipe script invoked from a subdirectory:

- Recipe without a root pin (`':(top)'` pathspecs, relative `OUT`): FAILED. The patch was written under the subdirectory, was listed as an untracked file, and was appended into itself (`grep -c "staged-change"` returned 2). This is why details 3.1 pins to the repository root.
- Recipe as in details 3.1 (`cd "$(git rev-parse --show-toplevel)"` first): script exit 0; `cmp` of `git ls-files --stage` before and after reported no difference; `git status --porcelain` differed only by the new `?? .claude-hve-tracking/reviews/` output folder; on the patch, `grep -c` returned 1 for the untracked file's content, 1 for the staged change, 1 for the unstaged change, 1 for the branch commit's change, 1 for `Binary files`, and 0 for `claude-hve-tracking`; the file list showed the newline-named file quoted; the tracking list showed the untracked tracking file only; `git log "$BASE"..HEAD --oneline` showed the one branch commit.
- `echo '{"tool_input":{"file_path":"/tmp/x.md"}}' | jq -r '"\(now | strflocaltime("%Y-%m-%d")) - Modified: \(.tool_input.file_path)"'` printed `2026-10-10 - Modified: /tmp/x.md` (jq 1.8.1).

These do not replace Steps 3.1, 3.9, and 5.2.
