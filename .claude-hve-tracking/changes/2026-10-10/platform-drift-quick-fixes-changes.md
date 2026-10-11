# Changes Log: Platform-Drift and Friction Quick Fixes
Date: 2026-10-10
Plan: .claude-hve-tracking/plans/2026-10-10/platform-drift-quick-fixes-plan.md
Details: .claude-hve-tracking/details/2026-10-10/platform-drift-quick-fixes-details.md
Branch: fix/platform-drift-quick-fixes (cut from main at f96e34f, after PR #4 merged)
Mode: standard (from `--mode standard`; the plan header requires it because phases share files)
Status: In Progress

Note on dates: the folder date is the local date (2026-10-10, US Pacific). Timestamps below are UTC and read 2026-10-11.

## Test Baseline

Captured 2026-10-11T00:50:30Z at commit 42fb86a, before any phase ran. Suites were redirected to log files and the exit code read from `$?`, not piped.

- `bash tests/run-drift-tests.sh > <scratchpad>/drift-baseline.log 2>&1; echo "drift rc=$?"`: rc=0, `Results: 250 passed, 0 failed`
- `bash tests/run-install-tests.sh > <scratchpad>/install-baseline.log 2>&1; echo "install rc=$?"`: rc=0, `Results: 69 passed, 0 failed`
- Already-failing tests: none.

## Phases

### Phase 1: Research-phase shell policy and consolidation rules
Status: Complete
Started: 2026-10-11T00:50:58Z
Completed: 2026-10-11T00:51:48Z

#### Files Modified
- `.claude/commands/hve-research.md:49`: orientation step rewritten. Glob and Grep when exposed, otherwise one read-only shell pass, otherwise targeted Read; commands recorded on the `Method:` line (details 1.1)
- `.claude/commands/hve-research.md:75`: **Tool boundary** paragraph rewritten. Parent read-only shell in two places only (Phase 1 orientation, Phase 3 re-check); `hve-researcher` still has no Bash (details 1.2, Decision D4)
- `.claude/commands/hve-research.md:86`: trust rule extended with the existence, negative-claim, and disagreement exception (details 1.4, F14)
- `.claude/commands/hve-research.md:97`: new `Method:` line in the consolidated-document header template, at column 0, after `Confidence:` (details 1.3)
- `.claude/commands/hve-review.md:29`: Inputs item 3 now reads the path named by the plan's `Research:` header instead of globbing by slug (details 1.6)
- `.claude/commands/hve-review.md:38`: Phase 1 step 1 takes the research path from the plan's `Research:` line (details 1.6)
- `.claude/commands/hve-review.md:99`: **Context discipline** paragraph gains the exception for existence or negative claims and validator disagreement; a falsified finding stays in the log under **Contested severity** and out of the tally (details 1.5, F14)

`git diff --stat -- .claude/` after the edits: 2 files changed, 7 insertions(+), 6 deletions(-). No other tracked file changed.

#### Steps Completed
- [x] Step 1.1: Orientation step rewritten per details 1.1, at `.claude/commands/hve-research.md:49`. Frontmatter `allowed-tools` at :4 left unchanged, per the plan's assumption.
- [x] Step 1.2: **Tool boundary** paragraph rewritten per details 1.2, at `.claude/commands/hve-research.md:75`
- [x] Step 1.3: `Method: [` template line added after `Confidence:`, at `.claude/commands/hve-research.md:97`
- [x] Step 1.4: Trust rule extended with the exception, at `.claude/commands/hve-research.md:86`
- [x] Step 1.5: Exception appended to the last sentence of the Context discipline paragraph, at `.claude/commands/hve-review.md:99`
- [x] Step 1.6: `Research:` header rule added in both places, at `.claude/commands/hve-review.md:29` and `.claude/commands/hve-review.md:38`
- [x] Step 1.7: Recorded no-change. `.claude/agents/hve-researcher.md:30` reviewed and left as is. Reason: the agent's frontmatter (`.claude/agents/hve-researcher.md:6`) lists `tools: Read, Write, Glob, Grep, WebFetch`, so it has no Bash to fall back to, and its Glob-plus-Read fallback stays correct. The shell policy this phase adds applies to the parent only. `git diff --stat -- .claude/agents/` printed nothing. The plan's assumption that a subagent listing Glob and Grep receives both stays [MEDIUM]; it was not tested in this phase.
- [x] Step 1.8 (guard): carrier grep run as written; two survivors, both expected. Output below.
- [x] Step 1.9 (guard): drift suite rc=0, `Results: 250 passed, 0 failed`. Detail below.

#### Guard Step 1.8 output

Command: `grep -rnE "never add Bash|read-only by design|Do not add Bash" .claude/ docs/ README.md CLAUDE.md CONTRIBUTING.md` (grep rc=0)

```text
.claude/agents/hve-researcher.md:30:2. Use Grep to search for key symbols, function names, or patterns relevant to the question. If no standalone Grep tool is available in this session, fall back to Glob (broad filename/pattern matching) plus targeted Read calls for content search — do not reach for Bash to work around this; this agent stays read-only by design regardless of what the harness happens to expose.
CLAUDE.md:202:**Shell stays in the parent.** HVE subagents are read-only by design; most have no Bash. The parent session runs all git/shell commands and passes pre-digested results (short excerpts, counts, file lists) into subagent prompts. Never delegate a step requiring command execution to a subagent without checking its tool list; a validator without Bash will silently downgrade to static inference.
```

Survivors are exactly the two the plan expects (`.claude/agents/hve-researcher.md:30`, `CLAUDE.md:202`). The same grep before the edits returned four hits; the two extra were `.claude/commands/hve-research.md:49` and `:75`, both rewritten by Steps 1.1 and 1.2. No missed carrier.

#### Guard Step 1.9 output

```text
$ bash tests/run-drift-tests.sh > "$TMPDIR/drift-p1.log" 2>&1; echo "rc=$?"
rc=0
$ tail -3 "$TMPDIR/drift-p1.log"
[  OK  ] Test 16: credential-pattern surfaces agree with CLAUDE.md

Results: 250 passed, 0 failed
```

Log path: `/var/folders/t2/lgmxzs012z19716my6ky1hdh0000gn/T//drift-p1.log` (`$TMPDIR/drift-p1.log`). `grep -c "FAIL"` on the log printed 0. Matches the baseline (rc=0, 250 passed, 0 failed).

Tests: 250 passed, 0 failed

#### Success Criteria

```text
$ grep -c "never add Bash" .claude/commands/hve-research.md
0
$ grep -c "Do not add Bash" .claude/commands/hve-research.md
0
$ grep -c "^Method: \[" .claude/commands/hve-research.md
1
$ grep -c "Exception:" .claude/commands/hve-research.md
1
$ grep -c "Exception:" .claude/commands/hve-review.md
1
$ grep -c "header names a path" .claude/commands/hve-review.md
1
```

Drift suite exits 0: see Guard Step 1.9 output above. All six criteria met. Before the edits the last four greps printed 0.

#### Issues Encountered
- No blocker. Every anchor in details 1.1 to 1.6 was found once, at the line numbers the plan cites.
- Wording: the replacement text from the details file was used verbatim. Two joins needed a period that the details text does not show, because the anchored list items ended without one: `.claude/commands/hve-research.md:86` (`...citations. Exception:`) and `.claude/commands/hve-review.md:29` (`...TASK-SLUG.md`. When the plan's...`). Punctuation only; meaning unchanged.
- Em-dashes: `git diff -U0` on the two files, filtered to added lines, shows one em-dash, at `.claude/commands/hve-review.md:99`. It is in the paragraph's existing text (after `Read every validation output file in full`), carried on the same line as the appended sentences. The appended prose contains none.
- Process note: the six text edits (Steps 1.1 to 1.6) were applied in one batch and logged together afterwards, not logged one step at a time. The guard steps ran after all six.
- Not verified here: that Bash is reachable from `/hve-research` while the frontmatter `allowed-tools` omits it. The plan carries this as [MEDIUM]; no live `/hve-research` run was made in this phase. Step 1.1's third branch (targeted Read) covers the case where the shell call is denied.
- Instructions files read before editing: `.claude/instructions/markdown.md`, `.claude/instructions/writing-style.md`.

---

### Phase 2: Subagent dispatch and validator template fixes
Status: Complete
Started: 2026-10-11T00:54:22Z
Completed: 2026-10-11T00:55:45Z

#### Files Modified
- `CLAUDE.md:204`: new **Dispatch is asynchronous.** paragraph in `Subagent Dispatch Discipline`, between the "Shell stays in the parent" paragraph (:202) and the "If you dispatch an agent type" paragraph (now :206). Text verbatim from details 2.1
- `tests/run-drift-tests.sh:577`: new `CANONICAL_BLOCK_SPECS` row `'dispatch_async|1|identical|**Dispatch is asynchronous.**'`, after the `shell_stays_in_parent` row (:576), same two-space indent and single quotes
- `.claude/commands/hve-research.md:77`: `Wait for all subagents to complete.` replaced with the pointer sentence (details 2.3)
- `.claude/commands/hve-pr-review.md:147`: same pointer sentence (details 2.4)
- `.claude/commands/hve-pr-review.md:149-156`: **Blocked reviewers** paragraph reworded. A reviewer that returned nothing gets its output path checked first; a present and complete file is recorded as file-verified; `Blocked`, or a missing or incomplete file, means the dimension was not covered (details 2.4, F04)
- `.claude/commands/hve-pr-review.md:167`: Coverage rule (Phase 3 item 4) now counts reviewers that returned `Complete` or were file-verified (details 2.4)
- `.claude/agents/hve-rpi-validator.md:82`: grading line added under the template's `## Findings` heading (details 2.5)
- `.claude/agents/hve-rpi-validator.md:84`: `### RV-001 [CRITICAL]` is now `### RV-001 [SEVERITY]`
- `.claude/agents/hve-implementation-validator.md:120-123`: the two hardcoded example headings (`IV-001 [ARCHITECTURE] [MAJOR]`, `IV-002 [SECURITY] [CRITICAL]`) replaced by the grading line and one generic `### IV-001 [DIMENSION] [SEVERITY]` block (details 2.5)

`git diff --stat -- . ':!.claude-hve-tracking'` after the edits: 6 files changed, 17 insertions(+), 11 deletions(-). Those six are the files the phase names; no other tracked file outside the tracking folder changed. `~/.claude/CLAUDE.md` was not edited (`grep -c "Dispatch is asynchronous" ~/.claude/CLAUDE.md` prints 0).

#### Steps Completed
- [x] Step 2.1: **Dispatch is asynchronous.** paragraph added, at `CLAUDE.md:204`. Opens with the exact bold form, period inside the bold.
- [x] Step 2.2: `dispatch_async` row added to `CANONICAL_BLOCK_SPECS`, at `tests/run-drift-tests.sh:577`. `bash -n tests/run-drift-tests.sh` rc=0.
- [x] Step 2.3: pointer sentence in place, at `.claude/commands/hve-research.md:77`. Plain words, no bold form.
- [x] Step 2.4: three edits in `.claude/commands/hve-pr-review.md`: pointer sentence at :147, **Blocked reviewers** reworded at :149-156, Coverage rule extended at :167.
- [x] Step 2.5: `[SEVERITY]` placeholder and grading line at `.claude/agents/hve-rpi-validator.md:82` and :84; generic block at `.claude/agents/hve-implementation-validator.md:120-123`. The IV-002 check came back clean (see Issues Encountered), so one generic block was kept, not two.
- [x] Step 2.6 (guard): drift suite rc=0, `Results: 252 passed, 0 failed`. Detail below.

#### Guard Step 2.6 output

```text
$ bash tests/run-drift-tests.sh > "$TMPDIR/drift-p2.log" 2>&1; echo "rc=$?"
rc=0
$ tail -3 "$TMPDIR/drift-p2.log"
[  OK  ] Test 16: credential-pattern surfaces agree with CLAUDE.md

Results: 252 passed, 0 failed
$ grep -n "dispatch_async\|FAIL" "$TMPDIR/drift-p2.log"
172:    [pass] test10: dispatch_async carrier count: 1 file(s) carry the block (expected 1)
173:    [pass] test10: dispatch_async CLAUDE is canonical: reference occurrence
```

Log path: `/var/folders/t2/lgmxzs012z19716my6ky1hdh0000gn/T//drift-p2.log` (`$TMPDIR/drift-p2.log`). `grep -c "FAIL"` on the log printed 0. The count rose from the baseline 250 to 252: the new row adds two assertions (carrier count, canonical reference). The suite was run twice, once after the edits and once more after a line re-wrap in `.claude/commands/hve-pr-review.md`; both runs gave rc=0 and 252 passed, 0 failed. The output above is from the second run, which is the state on disk.

Tests: 252 passed, 0 failed

#### Success Criteria

```text
$ grep -c "Dispatch is asynchronous" CLAUDE.md
1
$ grep -c "Dispatch is asynchronous rule" .claude/commands/hve-research.md
1
$ grep -c "Dispatch is asynchronous rule" .claude/commands/hve-pr-review.md
1
$ grep -cE "\[(CRITICAL|MAJOR)\]" .claude/agents/hve-rpi-validator.md .claude/agents/hve-implementation-validator.md
.claude/agents/hve-implementation-validator.md:0
.claude/agents/hve-rpi-validator.md:0
```

Drift suite exits 0 with the `dispatch_async` row passing: see Guard Step 2.6 output above. All four criteria met.

Extra check for the Test 10 constraint, not in the plan's list:

```text
$ grep -c '\*\*Dispatch is asynchronous\.\*\*' .claude/commands/hve-research.md .claude/commands/hve-pr-review.md CLAUDE.md
.claude/commands/hve-research.md:0
.claude/commands/hve-pr-review.md:0
CLAUDE.md:1
```

#### Issues Encountered
- No blocker. Every anchor in details 2.1, 2.3, 2.4, and 2.5 was found once. Line numbers matched the plan except `.claude/commands/hve-pr-review.md`, where the Coverage rule moved from :164 to :167 because this phase's own rewording of the paragraph above it added three lines.
- IV-002 check (Step 2.5): `grep -n "IV-00"` on `.claude/agents/hve-implementation-validator.md` before the edit returned :91, :120, :123 only. Nothing after the template refers to `IV-002` by number, so one generic block replaced both examples. `CLAUDE.md:142` still names `IV-002` in the Finding ID format line; that describes the numbering sequence, not this template, and was left alone.
- Wording: replacement text from the details file was used verbatim. The only liberty is line wrapping: the **Blocked reviewers** paragraph in `.claude/commands/hve-pr-review.md` is hard-wrapped at about 100 columns, so the new sentences were wrapped to match and the unchanged tail of the paragraph (`If it blocks again ... as reviewed.`) was re-flowed across the line breaks. Its words are unchanged.
- Placement of the grading line in `.claude/agents/hve-rpi-validator.md`: directly under `## Findings` with no blank line between, matching how the same template writes `## Unlisted Changes` followed by its bracketed note.
- Em-dashes: `git diff -U0` outside the tracking folder, filtered to added lines, contains zero em-dashes.
- Observed, not changed (outside this phase's anchors): `.claude/agents/hve-implementation-validator.md:91` (the Finding Structure block) writes the heading as `IV-001 [CATEGORY] [SEVERITY]`, while the Output File template now reads `[DIMENSION] [SEVERITY]` as the details file specifies. Two names for the same slot in one file. Minor; a later phase or sweep can align them.
- Observed, not changed (outside this phase's file list): `.claude/commands/hve.md:69` (`Wait for all to complete`) and `.claude/commands/hve-review.md:97` (`Wait for all validators to complete.`) carry no pointer to the new rule. They are still covered by it through CLAUDE.md, per the plan's Step 2.1 assumption, which stays [MEDIUM]: this phase did not enumerate the opening line of all nine dispatching commands.
- Not verified here: `~/.claude/CLAUDE.md` does not carry the new paragraph until `./install.sh --global` is re-run. This phase edits the repo-root `CLAUDE.md` only, as instructed.
- ShellCheck was not run on `tests/run-drift-tests.sh`; the change is one array row copied from its neighbour's shape, and `bash -n` passed.
- Instructions files read before editing: `.claude/instructions/markdown.md`, `.claude/instructions/writing-style.md`, `.claude/instructions/bash.md`.

#### Discrepancies & Decisions
- DR-001: the details file (2.5) named the template slot `[DIMENSION]`, but `.claude/agents/hve-implementation-validator.md:91` already calls the same slot `[CATEGORY]`. The implementor applied the details text as written and flagged the mismatch.
- DD-001 (2026-10-10, parent): renamed the new template heading and grading line to `[CATEGORY]` so the file uses one name. Two-word edit in the same file, made by the parent after the implementor returned; drift suite re-run by the parent afterwards (see the parent test line below).

Parent re-run after DD-001: `bash tests/run-drift-tests.sh > <scratchpad>/drift-p2-parent.log 2>&1`, rc=0, `Results: 252 passed, 0 failed`

---

### Phase 3: PR-review diff correctness (F08, F09, F11) and review file list
Status: Complete
Started: 2026-10-11T00:57:33Z
Completed: 2026-10-11T01:01:44Z

#### Files Modified
- `.claude/commands/hve-pr-review.md:3`: `[--working-tree]` added to `argument-hint`, before `[--compact]` (details 3.2)
- `.claude/commands/hve-pr-review.md:15`: new **Working-tree mode** argument-parsing paragraph, after the friction-capture line (details 3.2)
- `.claude/commands/hve-pr-review.md:33`: new root-pin line, with the tracking-folder exclusion pathspec and the reason for it (details 3.3, F11)
- `.claude/commands/hve-pr-review.md:35-37`: new `Mode:` block. Branch mode is `main...HEAD` (or `origin/main...HEAD`); working-tree mode sets `BASE` to the merge-base and adds untracked files (details 3.3, DD-029)
- `.claude/commands/hve-pr-review.md:39`: step 2 rewritten for both modes, pathspec spelled out (details 3.3)
- `.claude/commands/hve-pr-review.md:41`: new **Tracking-folder scan** paragraph, after step 2 and before the guard (details 3.4)
- `.claude/commands/hve-pr-review.md:43-48`: **Empty-diff guard** rewritten with three outcomes plus the "not covered by this diff" sentence for branch-mode runs that proceed (details 3.5, F08)
- `.claude/commands/hve-pr-review.md:50-51`: steps 3 and 4 rewritten once for both modes (details 3.3)
- `.claude/commands/hve-pr-review.md:52-64`: step 5 rewritten. Branch-mode command carries the pathspec before the `>` redirect; working-tree mode is the seven-line bash block from details 3.1 (without its `cd` line), indented three spaces to stay inside list item 5; the two existing sentences (subagents receive the PATH and Read the diff themselves; the gitignore note) are kept word for word (details 3.3, F09)
- `.claude/commands/hve-pr-review.md:79-80`: review log template. `Base:` is mode-aware and a `Scope:` line follows it (details 3.6)
- `.claude/commands/hve-review.md:83`: changed-file instruction extended. When the base is `HEAD`, untracked files outside the tracking folder are appended, minus any that predate the task (details 3.7)
- `.claude/commands/hve-review.md:95`: dispatch input parenthetical now ends `with untracked files appended per the step above)` (details 3.7)
- `.claude/agents/hve-rpi-validator.md:23`: input description gains `(for uncommitted work it includes untracked files outside the tracking folder)` (details 3.7)
- `.claude/prompts/pull-request.md:33`: new `--working-tree` bullet after the `--compact` bullet, with a colon (details 3.8)
- `README.md:134`: `/hve-pr-review` row gains `Pass \`--working-tree\` to include uncommitted and untracked work.` (details 3.8)
- `README.md:186`: new example line after the `--compact` example, comment at the same column (details 3.8)

`git diff --stat -- . ':(exclude).claude-hve-tracking'` after the edits: 5 files changed, 42 insertions(+), 11 deletions(-). Those five are the files the phase names. `CLAUDE.md` is unchanged (`grep -c "working-tree" CLAUDE.md` prints 0) and the cross-cutting flags table in `README.md` is untouched. Steps 1, 6, and 7 of the command's Phase 1 keep their numbers and text; the only step-number reference in the file is the new guard's "step 2" (`.claude/commands/hve-pr-review.md:43`), which is correct.

#### Steps Completed
- [x] Step 3.1 (guard, run first): prototype passed all five checks under bash, invoked from a subdirectory of the fixture. Detail below. The command file was not edited until this passed.
- [x] Step 3.2: `[--working-tree]` in the argument-hint at `.claude/commands/hve-pr-review.md:3`; working-tree paragraph at `.claude/commands/hve-pr-review.md:15`
- [x] Step 3.3: Phase 1 steps 2 to 5 restructured: root-pin line at `.claude/commands/hve-pr-review.md:33`, `Mode:` block at :35-37, steps 2 to 5 at :39, :50, :51, :52-64
- [x] Step 3.4: **Tracking-folder scan** at `.claude/commands/hve-pr-review.md:41`, after step 2 and before the guard
- [x] Step 3.5: **Empty-diff guard** rewritten at `.claude/commands/hve-pr-review.md:43-48`
- [x] Step 3.6: `Base:` and new `Scope:` template lines at `.claude/commands/hve-pr-review.md:79-80`. `Commits: N` left as is, per details 3.6 (see DR-003)
- [x] Step 3.7: `.claude/commands/hve-review.md:83` and :95; `.claude/agents/hve-rpi-validator.md:23`
- [x] Step 3.8: `.claude/prompts/pull-request.md:33`; `README.md:134` and `README.md:186`. Not added to the CLAUDE.md Command Reference row (DD-004)
- [x] Step 3.9 (guard): recipe extracted from the edited command file passed the same five checks on a fresh fixture; drift suite rc=0, `Results: 253 passed, 0 failed`. Detail below.

#### Guard Step 3.1 output

Environment: `GNU bash, version 3.2.57(1)-release (arm64-apple-darwin25)`, `git version 2.50.1 (Apple Git-155)`. Everything lives under `$TMPDIR/hve-p3/` (`/var/folders/t2/lgmxzs012z19716my6ky1hdh0000gn/T//hve-p3/`), outside the workspace: `build-fixture.sh`, `recipe-details.sh`, `checks.sh`, and the fixture repo `fixture-a/`.

Fixture (`build-fixture.sh`, run before the "before" snapshot): `main` with one commit (`1ff40db`); branch `feature/x` with one further commit (`cb38123`, appends `MARK-branch-commit-change` to `src/branch.txt`); `src/tracked.txt` modified and unstaged (`MARK-unstaged-change`); `src/staged.txt` new and staged (`MARK-staged-change`); untracked `sub/untracked.txt` (`MARK-untracked-content`); untracked binary `blob.bin`; untracked file named `new<LF>line.txt` (`MARK-newline-name-content`); under `.claude-hve-tracking/plans/`, `tracked-plan.md` (committed on `main`, then given an uncommitted edit `MARK-tracking-tracked-change`) and untracked `untracked-note.md` (`MARK-tracking-untracked-content`). The uncommitted edit to the tracked tracking file goes one step past the plan's fixture list, so that check 3 exercises the exclusion on the tracked half of the diff as well as on the untracked loop.

Recipe script: `recipe-details.sh` is the bash block from details 3.1, all eight lines, with `BRANCH-NAME` replaced by `feature-x`. Verified with `sed -n '152,159p' <details file> | sed 's/BRANCH-NAME/feature-x/' | diff - recipe-details.sh` (no difference).

"Before" snapshot, taken from the fixture root: `git ls-files --stage > a-before.stage` and `git status --porcelain > a-before.porcelain`.

```text
$ (cd "$A/sub" && bash "$S/recipe-details.sh"); echo "recipe rc=$?"
recipe rc=1
$ bash "$S/checks.sh" "$A" "$S/a-before.stage"
== check 1: git ls-files --stage identical before and after
cmp rc=0
== check 2: patch content counts (grep -c on .claude-hve-tracking/reviews/pr/feature-x/diff.patch)
MARK-untracked-content: 1
MARK-staged-change: 1
MARK-unstaged-change: 1
MARK-branch-commit-change: 1
MARK-newline-name-content: 1
Binary files: 1
== check 3: grep -c claude-hve-tracking on the patch
0
MARK-tracking-tracked-change: 0
MARK-tracking-untracked-content: 0
== check 4: tracking-folder list (details 3.4 commands, diff.patch dropped)
.claude-hve-tracking/plans/tracked-plan.md
.claude-hve-tracking/plans/untracked-note.md
-- same list before dropping diff.patch:
.claude-hve-tracking/plans/tracked-plan.md
.claude-hve-tracking/plans/untracked-note.md
.claude-hve-tracking/reviews/pr/feature-x/diff.patch
== check 5: commit list (git log main..HEAD --oneline)
cb38123 branch: MARK-branch-commit
== extra: changed-file list for working-tree mode (details 3.3 step 2)
src/branch.txt
src/staged.txt
src/tracked.txt
blob.bin
"new\nline.txt"
sub/untracked.txt
== extra: git status --porcelain after
 M .claude-hve-tracking/plans/tracked-plan.md
A  src/staged.txt
 M src/tracked.txt
?? .claude-hve-tracking/plans/untracked-note.md
?? .claude-hve-tracking/reviews/
?? blob.bin
?? "new\nline.txt"
?? sub/untracked.txt
```

What `checks.sh` runs, per check, from the fixture root with `base=$(git merge-base main HEAD)` and `patch=.claude-hve-tracking/reviews/pr/feature-x/diff.patch`:
1. `git ls-files --stage > a-before.stage.after; cmp a-before.stage a-before.stage.after`
2. `grep -c -- "<marker>" "$patch"` for each of the six markers shown
3. `grep -c "claude-hve-tracking" "$patch"`, then the same for the two tracking markers
4. `{ git diff "$base" --name-only -- .claude-hve-tracking; git ls-files --others --exclude-standard -- .claude-hve-tracking; } | grep -v '/diff\.patch$'`
5. `git log main..HEAD --oneline`

Results:
- Check 1 pass: index identical (`cmp rc=0`). `git status --porcelain` differs from the "before" snapshot only by the new `?? .claude-hve-tracking/reviews/` line, which is the output folder.
- Check 2 pass: untracked content 1, staged change 1, unstaged change 1, branch commit's change 1. Also 1 for the newline-named file's content and 1 `Binary files` line.
- Check 3 pass: 0. Negative control: `git diff "$base" | grep -c "claude-hve-tracking"` (no exclusion) prints 3, so the check can fail.
- Check 4 pass: the list names the untracked tracking file (and the edited tracked one) and not `diff.patch`. Without the drop, `diff.patch` is listed, because the fixture has no ignore rule for it.
- Check 5 pass: the one branch commit.
- `find` for `diff.patch` in the fixture returns one file, under the repo root's `.claude-hve-tracking/reviews/pr/feature-x/`. Nothing was written under `sub/`.
- The recipe script exits 1, not 0. The last command it runs is `git diff --no-index`, which exits 1 when it finds differences. Details 3.1 says this is expected. See DR-002 below.

#### Guard Step 3.9 output

Run after all edits. The script under test is built from the edited `.claude/commands/hve-pr-review.md` only:
- `block-raw.sh`: the fenced `bash` block that follows the line starting `5. **Write the diff ONCE**` and ending `Working-tree mode:`, extracted with awk, with the three-space list indent stripped. Seven lines.
- `pin.sh`: the command in the code span of the root-pin line (`.claude/commands/hve-pr-review.md:33`), extracted with sed. One line: `cd "$(git rev-parse --show-toplevel)"`.
- `recipe-shipped.sh`: `pin.sh` followed by `block-raw.sh` with `BRANCH-NAME` replaced by `feature-x`. The shipped block has no `cd` line of its own (details 3.3), so the pin comes from the sentence that tells the reader to run it.
- `diff recipe-details.sh recipe-shipped.sh` reports no difference (rc=0): the shipped text reproduces the Step 3.1 prototype byte for byte. `bash -n recipe-shipped.sh` rc=0.

Fixture: `fixture-b/`, a fresh build from the same `build-fixture.sh` (commit SHAs differ from `fixture-a/` because of commit times). "Before" snapshot taken the same way.

```text
$ (cd "$B/sub" && bash "$S/recipe-shipped.sh"); echo "recipe rc=$?"
recipe rc=1
$ bash "$S/checks.sh" "$B" "$S/b-before.stage"
== check 1: git ls-files --stage identical before and after
cmp rc=0
== check 2: patch content counts (grep -c on .claude-hve-tracking/reviews/pr/feature-x/diff.patch)
MARK-untracked-content: 1
MARK-staged-change: 1
MARK-unstaged-change: 1
MARK-branch-commit-change: 1
MARK-newline-name-content: 1
Binary files: 1
== check 3: grep -c claude-hve-tracking on the patch
0
MARK-tracking-tracked-change: 0
MARK-tracking-untracked-content: 0
== check 4: tracking-folder list (details 3.4 commands, diff.patch dropped)
.claude-hve-tracking/plans/tracked-plan.md
.claude-hve-tracking/plans/untracked-note.md
-- same list before dropping diff.patch:
.claude-hve-tracking/plans/tracked-plan.md
.claude-hve-tracking/plans/untracked-note.md
.claude-hve-tracking/reviews/pr/feature-x/diff.patch
== check 5: commit list (git log main..HEAD --oneline)
7538ad6 branch: MARK-branch-commit
== extra: changed-file list for working-tree mode (details 3.3 step 2)
src/branch.txt
src/staged.txt
src/tracked.txt
blob.bin
"new\nline.txt"
sub/untracked.txt
```

All five checks pass, with the same counts as Step 3.1. `git status --porcelain` before and after differs by one line, `?? .claude-hve-tracking/reviews/`. `find` returns one `diff.patch`, under the fixture root.

Second run, block alone: `block-raw.sh` with the same substitution and no pin line, run with the fixture root as cwd on a third fresh fixture (`fixture-c/`): rc=1, and checks 1 to 5 give the same results. `cmp` of the three patches (`fixture-a`, `fixture-b`, `fixture-c`) reports no difference. Not re-run here: the block alone from a subdirectory, which the planning log's second run already recorded as failing; that is the case the root-pin line exists for.

Branch-mode sanity check on this repo, read-only, using the step 2 command as shipped: `git diff main...HEAD --name-only` lists 33 files, 26 of them under `.claude-hve-tracking/`; `git diff main...HEAD --name-only -- . ':(exclude).claude-hve-tracking'` lists 7 files, 0 of them under `.claude-hve-tracking/`.

Drift suite:

```text
$ bash tests/run-drift-tests.sh > "$TMPDIR/drift-p3.log" 2>&1; echo "rc=$?"
rc=0
$ tail -3 "$TMPDIR/drift-p3.log"
[  OK  ] Test 16: credential-pattern surfaces agree with CLAUDE.md

Results: 253 passed, 0 failed
$ grep -n "FAIL" "$TMPDIR/drift-p3.log"
$ grep -n "working-tree" "$TMPDIR/drift-p3.log"
253:    [pass] test13: pull-request.md --working-tree: implemented in hve-pr-review.md
```

Log path: `/var/folders/t2/lgmxzs012z19716my6ky1hdh0000gn/T//drift-p3.log` (`$TMPDIR/drift-p3.log`). `grep -n "FAIL"` printed nothing; `grep -c FAIL` prints 0. The count rose from 252 to 253: Test 13 gains one assertion for the new `--working-tree` bullet in `.claude/prompts/pull-request.md`, and it passes. The suite ran once, after all edits; no test failed, so no fix-and-re-run cycle was needed. The install suite (`tests/run-install-tests.sh`) was not run in this phase; the plan does not ask for it here.

Tests: 253 passed, 0 failed

#### Success Criteria

```text
$ grep -c -- "--working-tree" .claude/commands/hve-pr-review.md
2
$ grep -c "exclude).claude-hve-tracking" .claude/commands/hve-pr-review.md
5
$ grep -c "^Scope:" .claude/commands/hve-pr-review.md
1
```

- Step 3.1 prototype passes all five checks: met, see Guard Step 3.1 output.
- Step 3.9 post-edit run passes the same checks: met, see Guard Step 3.9 output.
- `--working-tree` count at least 2: met (2; lines :3 and :15).
- `exclude).claude-hve-tracking` count at least 4: met (5 lines: :33, :37, :39, :52, :55).
- `^Scope:` count 1: met (:80).
- Drift suite exits 0: met.

In this session's shell `grep` is a function that calls `ugrep`. The three counts were repeated with `/usr/bin/grep -c` and are the same: 2, 5, 1. Before the edits the three counts were 0, 0, 0 by inspection of the file as read at the start of the phase (no occurrence of any of the three strings); they were not run as commands before editing. Confirmed afterwards against the committed version: `git show HEAD:.claude/commands/hve-pr-review.md | /usr/bin/grep -c -- "<pattern>"` prints 0 for each of the three patterns.

#### Issues Encountered
- No blocker. Every anchor in details 3.2 to 3.8 was found once, by its quoted text. As the dispatch note said, lines below :149 of `.claude/commands/hve-pr-review.md` had moved by 3; none of this phase's anchors sit there.
- Wording: replacement text from the details file was used as written. Adaptations, none of which changes meaning:
  - `MAIN` is written as `main` with the `origin/main` alternative in the file's existing forms: a second full command in step 2 (as the old step 2 had), `(or the \`origin/main\` base)` in the mode line and step 5 (as the old step 5 had), and the `# or origin/main` comment inside the bash block. Step 4 keeps `git log main..HEAD --oneline` with no alternative shown, as before.
  - `EXCL` in the prose is spelled out as `-- . ':(exclude).claude-hve-tracking'` in every command. In the root-pin sentence the clause ", written here as EXCL" was dropped, since the prose no longer uses the placeholder. Inside the bash block `EXCL` stays: there it is a shell variable the block defines on its first line, and the block is the tested recipe.
  - A blank line was added before `In a branch-mode run that proceeds, ...` so Markdown does not fold that sentence into the third guard bullet.
  - The bash block and the paragraph after it are indented three spaces so they stay inside list item 5 and items 6 and 7 keep their numbers.
- Em-dashes: `git diff -U0` outside the tracking folder, filtered to added lines, shows one em-dash, at `.claude/commands/hve-pr-review.md:64`. It is inside the existing sentence the details say to keep (`Reads the diff itself — the diff text is never pasted into multiple prompts`). The new prose contains none. The new bullet in `.claude/prompts/pull-request.md:33` uses a colon while its neighbours use an em-dash, as instructed.
- Line length: `.claude/commands/hve-pr-review.md:41` (675 characters) and :64 (547) are over the "~500 characters" guide in `.claude/instructions/markdown.md`. Both are single paragraphs from the details text; the file writes paragraphs on one line (`.claude/commands/hve-review.md:99` is 931). Left as is. Minor.
- Bash conventions: `.claude/instructions/bash.md` asks for a shebang, `set -euo pipefail`, braces, and a `main()` in scripts. The block written into the command file is a snippet the parent pastes into its shell, not a script, and it is the recipe Step 3.1 tested, so it was kept as details 3.1 gives it. `set -e` would also be wrong here: `git diff --no-index` exits 1 on every untracked file, which would end the loop after the first one. The scratch scripts under `$TMPDIR` follow the conventions where they are scripts (`build-fixture.sh`); `checks.sh` omits `-e` because its expected-zero `grep -c` calls exit 1.
- Observed, not changed (meaning is fixed by details 3.5): the old guard said "do NOT proceed" for any empty diff. The new third bullet (branch mode, nothing in the tracking folder) says what to do when uncommitted or untracked work exists, and says nothing explicit for a clean tree. The lead sentence "an empty review is never an Approve" still covers it, but the stop is implied, not stated. One clause would close it ("Otherwise say there is nothing to review and stop"). Minor; needs the parent's or Kevin's call because it adds meaning the details do not contain.
- Observed, not changed: step 4 says an empty commit list in working-tree mode "is written as" the quoted phrase but not where. Details 3.6 says it goes in the Executive Summary; that instruction is in the details file only, not in the shipped text. Minor.
- Observed, not changed: the mode line defines `BASE` and step 2 uses `"$BASE"`. Shell variables do not persist between separate Bash tool calls, so a run that issues step 2 as its own call must set `BASE` in that call. The step 5 block sets `BASE` itself and is unaffected. Minor.
- Not verified here: no live `/hve-pr-review` or `/hve-pr-review --working-tree` run was made. The proof is of the shell recipe and the step 2 pathspec, not of a model following the rewritten prose end to end. The plan's Step 3.3 assumption about the flag's meaning stays as Kevin approved it (DD-029); the Step 3.7 assumption (untracked files that postdate the task belong to the change) stays [MEDIUM] and was not tested.
- Not verified here: `~/.claude/` copies of the five files do not carry these edits until `./install.sh --global` is re-run. This phase edits the repo only.
- Process note: Steps 3.2 to 3.8 were applied in one batch of edits after Step 3.1 passed and logged together afterwards, not one step at a time. Step 3.1 was logged before any edit to the command file.
- Instructions files read before editing: `.claude/instructions/markdown.md`, `.claude/instructions/writing-style.md`, `.claude/instructions/bash.md`.
- Scratch files are left in place under `$TMPDIR/hve-p3/` for the reviewer: `build-fixture.sh`, `checks.sh`, `recipe-details.sh`, `block-raw.sh`, `pin.sh`, `recipe-shipped.sh`, `block-only.sh`, the snapshots, and `fixture-a/`, `fixture-b/`, `fixture-c/`.

#### Discrepancies & Decisions
- DR-002: the planning log's second run records "script exit 0" for the recipe. Here the recipe exits 1 in all three runs (`recipe-details.sh`, `recipe-shipped.sh`, `block-only.sh`), because the last command the loop runs is `git diff --no-index` on an untracked file. Details 3.1 states that exit code is expected, so the recipe is behaving as designed; the difference is in what the planning log recorded, probably a wrapper script with further commands after the recipe. No check depends on the exit code. A parent that runs the block sees a non-zero exit from the Bash tool whenever at least one untracked file exists.
- DD-002 (2026-10-10, implementor): because of DR-002, the two sentences that follow the recipe in details 3.1 were placed after the bash block in step 5 (`.claude/commands/hve-pr-review.md:64`): "`git diff --no-index` exits 1 when it finds differences; that is expected. A binary untracked file appears as a `Binary files ... differ` line; list it by name for the reviewers." Details 3.3's skeleton names only the sentence before them. They are details-file wording for the same recipe, and without the first one a non-zero exit reads as a failed diff. If the parent wants the skeleton followed to the letter, deleting those two sentences is the whole change.
- DR-003: plan Step 3.6 says to make `Base:` and `Commits:` mode-aware. Details 3.6 says to leave `Commits: N` and add nothing else.
- DD-003 (2026-10-10, implementor): followed details 3.6, the more specific of the two and the one the plan header names as the source of replacement text. `Base:` is mode-aware, `Scope:` is new, `Commits: N` is unchanged.

#### Parent adjustments after the implementor returned (2026-10-10)
- DD-004 (parent): three one-sentence additions to `.claude/commands/hve-pr-review.md`, each closing a gap the implementor listed as a follow-on. (1) Mode block: a shell variable does not persist between tool calls, so `"$BASE"` is recomputed or substituted. (2) Empty-diff guard, branch mode: a clean tree now has an explicit stop, which the pre-change text had ("do NOT proceed") and details 3.5 dropped. (3) Step 4: "none (uncommitted work only)" goes in the Executive Summary, as details 3.6 intended. The implementor's DD-002 sentences (recipe exits 1; binary files) are kept.
- Parent re-run after DD-004: `bash tests/run-drift-tests.sh > <scratchpad>/drift-p3-parent.log 2>&1`, rc=0, `Results: 253 passed, 0 failed`

---

### Phase 4: Global-install correctness (instruction paths, ignore rule)
Status: Pending

---

### Phase 5: Shipped examples and tracking-tree note
Status: Pending

---

### Phase 6: Full verification
Status: Pending

---
