# Grader Review: Platform-Drift and Friction Quick Fixes

Date: 2026-10-10 (repo local date; commands ran 2026-10-11 UTC)
Task slug: platform-drift-quick-fixes
Reviewer: independent grader seat `grade-pdqf-r1` (did not write the implementation; edited no shipped file)
Base: `fix/platform-drift-quick-fixes` at f69dd41b1482c7f4ef4ac9d847000f0187586bd2
Comparison point: `main` at f96e34f0859387d0ba871bf4163e5b88159f931a
Plan: .claude-hve-tracking/plans/2026-10-10/platform-drift-quick-fixes-plan.md
Changes log: .claude-hve-tracking/changes/2026-10-10/platform-drift-quick-fixes-changes.md
Method: register-driven review against a 37-criterion acceptance register (R-01 to R-37) that the orchestrator wrote before the implementation was read. Every command below ran in a detached worktree of the base SHA. Scratch installs and fixtures lived in temp directories outside the repo. No HVE phase command and no subagent was used.
Status: Fail. Critical: 0 | Major: 1 | Minor: 8

The one Major (IV-001) is a two-bullet fix to two prompt files. Everything else in the register passes or fails on a record-keeping point only. Both gates reproduce the changes log's figures.

## Summary

| Area | Result |
|---|---|
| Register R-01 to R-37 | 35 PASS, 2 FAIL (R-15, R-37), 0 NOT RUN |
| Drift suite on f69dd41 | 253 passed, 0 failed, rc=0. Reproduces the changes log |
| Install suite on f69dd41 | 72 passed, 0 failed, rc=0. Reproduces the changes log |
| New assertions (4 in total: 1 spec row giving 2 drift asserts, 1 Test 13 assert, 3 install asserts) | All can fail (mutation runs M1 to M9). One blind spot: Test 13 does not guard the `argument-hint` (M7) |
| Semi-manual scripts | `tests/run-prompt-new-install.sh`, `tests/run-prompt-upgrade.sh`: NOT RUN, graded by reading (R-09) |
| Security hygiene, four checks | Clean on the 16 shipped files and on the tracking files in the diff |
| Changes-log corrections | Three falsified statements, each annotated in place and each with a dated Correction entry in its phase section. Residual record gaps in IV-007 |

## Findings

| ID | Severity | Location (at f69dd41) | Finding |
|---|---|---|---|
| IV-001 | Major | `.claude/commands/hve-pr-review.md:149`, `:174`; `.claude/agents/hve-pr-reviewer.md:17` | Tracking-folder scan hits have no slot in the reviewer dispatch inputs or in the reviewer's own input list |
| IV-002 | Minor | `.claude/commands/hve-pr-review.md:33`, `:39`, `:41`, `:52`, `:54` | The root pin is prose only; every Phase 1 command is cwd-relative and silently narrows from a subdirectory |
| IV-003 | Minor | `.claude/commands/hve-pr-review.md:44` | The tracking-only guard outcome stops before uncommitted work is checked |
| IV-004 | Minor | `.claude/commands/hve-pr-review.md:64`; `docs/installation.md:226` | "`diff.patch` is gitignored" is stated without condition; the paste-to-update prompt still has no `.gitignore` step |
| IV-005 | Minor | `README.md:134`; `.claude/prompts/pull-request.md:33`; `CLAUDE.md:47` | The tracking-folder exclusion is documented nowhere outside the command file; the CLAUDE.md row omits the new flag |
| IV-006 | Minor | changes log `:569`, `:676`; 7 other tracking files added on this branch | Absolute home paths in committed tracking files on a public branch |
| IV-007 | Minor | changes log `:178`, `:397`, `:398`, `:399`, `:665`, `:693`, `:791`, Phase 6 | Record gaps: three behavioural criteria not re-run in Phase 6; statements later changed by the parent carry no in-place pointer |
| IV-008 | Minor | `tests/run-drift-tests.sh` Test 13; both suites | Test 13 passes with the flag removed from `argument-hint`; no suite covers the recipe, the scan, the hook JSON, or the doc copies of the rule |
| IV-009 | Minor | `.claude/commands/hve-git-commit.md:9` and 8 more carriers | Nine direct-read carriers of an instructions path have no global-install clause (accepted in plan Step 4.2 as [LOW]) |

### IV-001 [MAJOR] Scan hits have no path to the security reviewer

Re-opened and confirmed before grading: `.claude/commands/hve-pr-review.md:41` and `:149-154`, `.claude/agents/hve-pr-reviewer.md:17-21`.

What is wrong. The scan paragraph at `:41` ends "Pass any hit to the security reviewer as a pre-digested list with file and line." That is the only place the handoff is named. The Phase 2 list a parent builds each prompt from (`:149-154`, "Each review subagent receives:") has five bullets: the diff PATH, the changed-file list, the dimension and prefix, the output path, the finding format. None is the scan hits. The compact-mode sentence at `:174` repeats the same inputs. The reviewer's own definition (`.claude/agents/hve-pr-reviewer.md:17-21`, "You will receive from the parent:") lists four inputs and says nothing about a hit list, so a reviewer that is handed one has no instruction to grade it. The changed-file list the reviewer does receive excludes the tracking folder by construction (`:39`), and the reviewer has no Bash.

Why it matters. Before this change the security reviewer read tracking files in the diff itself. After it, the only security coverage of the tracking folder is the parent's grep, and its result reaches a verdict only if the parent remembers a sentence 108 lines above the input list. If it does not, the `Scope:` header still reads "N hit(s) passed to security reviewer" and the verdict logic (`:198-201`) can Approve, because no `SC-` finding exists. CLAUDE.md's `Security Hygiene` section makes security a floor, and this is the path that keeps the floor under the excluded folder. The register pre-registered the missing slot as a FAIL (R-15).

Origin. The implementation follows details 3.4 word for word. This is a gap in the plan, not an implementor deviation.

Smallest fix, two bullets:
- `.claude/commands/hve-pr-review.md`, after `:154`: "* Security and Compliance reviewer only: the tracking-folder scan hits from Phase 1 as a file-and-line list, or the word `clean`. Each hit is graded as an `SC-` finding."
- `.claude/agents/hve-pr-reviewer.md`, after `:20`: "- (Security and Compliance only) Tracking-folder scan hits: a file-and-line list from the parent's secret scan of `.claude-hve-tracking/`. Read each cited line and grade it."

### IV-002 [MINOR] Root pin is prose only; commands narrow silently from a subdirectory

What is wrong. `:33` says to run every git command from the repository root and shows the `cd` in a code span. The fenced working-tree block (`:54-62`) does not contain the `cd` (details 3.3 strips it), and every one-line command (`:39`, `:41`, `:52`) uses the cwd-relative pathspec `-- . ':(exclude).claude-hve-tracking'`. Measured (Evidence E2): the block as shipped, run from `<fixture>/sub`, exits the same as from the root, writes the patch to `sub/.claude-hve-tracking/...`, and the patch holds 1 of the 7 changed files with no warning. The branch-mode step 2 command from the same subdirectory prints nothing, where the pre-change command (`git diff main...HEAD --name-only`, no pathspec) prints the full list. So branch mode lost cwd-independence in this change.

Why Minor and not Major. When the session's working directory is the repository root, which is the normal HVE setup, nothing goes wrong, and `:33` does give the instruction. The patch never includes itself and the index is never touched in any of the five runs. Raise this to Major if sessions launched from a subdirectory of a repository are a supported setup: in this seat's own shell the harness reset the cwd after every command that left the project directory, so a `cd` issued once would not persist there [MEDIUM: observed for a worktree outside the project directory, inferred for a parent directory].

Smallest fix. Either put `cd "$(git rev-parse --show-toplevel)"` back as the first line of the fenced block, or make the pathspecs cwd-independent: `-- ':(top)' ':(top,exclude).claude-hve-tracking'` (measured from `<fixture>/sub`: prints the same list as from the root).

### IV-003 [MINOR] Tracking-only outcome hides uncommitted code

`:44` fires first when the branch diff holds only tracking artifacts. A branch whose plan and research are committed while the code is still uncommitted then gets "only tracking artifacts changed" and a stop. The uncommitted code is never mentioned, and the question that the third bullet (`:46`) asks is never reached. Not an Approve, so the guard's first sentence holds. Read from the text; not run against a live session.

Smallest fix: append to `:44` "In branch mode also run `git status --porcelain` and, if uncommitted or untracked work exists outside the tracking folder, say so and offer working-tree mode."

### IV-004 [MINOR] The ignore story is true only for a fresh project-mode install

One cause, three places:
- `.claude/commands/hve-pr-review.md:64` states "`diff.patch` is regenerable noise and is gitignored (DD-004)". Judged against what `install.sh` now writes: true for a project-mode install or re-install at f69dd41 (R-02). Not true for a global install (`install.sh` writes no `.gitignore` there, by design), for an install updated by the paste prompt, or for a project install that has not been re-run. The scan drops `diff.patch` by name, so the scan is safe either way; the risk is a multi-megabyte patch committed by a user who believes the sentence. `DD-004` is a decision ID from an old planning log that an installed copy cannot resolve.
- `docs/installation.md:226-236`, the paste-to-update prompt, has no `.gitignore` step. Plan Step 6.4 records this as a follow-on note, not an action.
- `docs/reference.md:12` and `:31` annotate `subagents/` and `sandbox/` as "(gitignored)"; `:22` (`pr/branch-name/`) carries no note. Not false, only incomplete. CLAUDE.md's tree has no such annotations at all.

Smallest fix: one sentence in the update prompt asking for the three tracking rules to be added when missing, and at `:64` replace "is gitignored (DD-004)" with "is ignored by the HVE `.gitignore` rules; if `git check-ignore` does not match it, tell the user to add the rule".

### IV-005 [MINOR] Exclusion and flag documentation

- The tracking-folder exclusion and the scan that replaces it are described only in the command file. `README.md:134`, `.claude/prompts/pull-request.md` (intro and `:33`), `docs/` and `CLAUDE.md` do not say that `/hve-pr-review` no longer reviews tracking artifacts. A reader of the docs still expects them to be reviewed.
- `--working-tree` reads the same in the three places that carry it: command `:15` ("everything not yet on main: commits on the branch, plus uncommitted changes, plus untracked files"), prompt `:33` ("review everything not yet on main, including uncommitted and untracked work"), `README.md:134` and `:186` ("include uncommitted and untracked work"). No contradiction. The README wording alone could be read as "uncommitted work only"; the prompt wording is the precise one.
- `CLAUDE.md:47` lists `--dimension` and `--compact` for `/hve-pr-review` and not `--working-tree`. This is planning decision DD-004 (rows lose flags in a later restructure), recorded and accepted. `docs/` has no flag table for this command.

Smallest fix: add "The tracking folder is excluded from the reviewed diff and scanned for secrets instead." to the README row and the prompt file.

### IV-006 [MINOR] Absolute home paths in committed tracking files

The repo is public and this branch is on the remote. Measured (Evidence E7): the task's own changes log has two absolute home paths, at `:569` (the installer's "from:" line in pasted output) and `:676` (a shell-snapshot path in DR-004). Seven other tracking files added on this branch (the backlog commit 42fb86a and the shared research document) have eight more matching lines. Probes for private project names matched files in that set; the names, and the file names that contain one, are withheld from this file and listed in the seat report. The changes log's `## Security Hygiene Check` says the owner approved publishing the names with two redactions. This review cannot verify that approval and it does not mention paths.

Why Minor: a local username in a path is not a credential. It is a pre-registered FAIL (R-37) and an owner decision, so it is surfaced, not waived.

Smallest fix: replace the home prefix with `<home>` or `~` in the two changes-log lines; the owner decides on the backlog files.

### IV-007 [MINOR] Changes-log record gaps

Corrections that exist are done correctly: `:512`, `:660` and `:765` are each annotated in place and each has a dated `Correction (2026-10-10):` entry in its own phase section (`:681`, `:682`, `:800`). Residual gaps, one cause (the log is written forward and not always back-annotated):
- Plan Step 6.2 asks for every phase criterion to be re-run. Phase 6 re-ran the grep criteria and both suites, but not the three behavioural ones (Step 3.1 and 3.9 fixture checks, Step 5.2 hook run), although the parent edited `hve-pr-review.md` (DD-004) and the CLAUDE.md hooks paragraph (DD-008) after those ran. This review re-ran both on f69dd41 and they pass (E2, E4).
- Six statements describe shipped text that a later parent decision changed, with no in-place pointer to that decision: `:178` (DD-001), `:397`, `:398`, `:399` (DD-004), `:665` (DD-007), `:791` (DD-008). Each was true when written and each decision is logged in the same phase section, so this is not a contradiction, but a reader of `:397` alone is told the clean-tree stop is missing when `hve-pr-review.md:46` has it.
- `:693` still shows the Phase 5 `Completed` time that the Correction at `:801` replaces; the stale value has no in-place annotation.
- The annotation is written "(superseded, see Correction 2026-10-10)". CLAUDE.md's `Corrections in Tracking Artifacts` section gives the form with an em-dash. The comma form follows the owner's no-em-dash rule; noted because `/hve-review`'s record-consistency scan quotes the em-dash form.

Smallest fix: add "(changed later, see DD-00N)" to the six lines and "(superseded, see Correction 2026-10-10)" to `:693`.

### IV-008 [MINOR] What the suites still do not see

- Mutation M7: removing `[--working-tree]` from the `argument-hint` alone leaves drift at 253 passed, rc=0. Test 13 resolves the flag from any mention in the command body.
- Nothing in either suite covers: the working-tree recipe, the tracking-folder scan, the hooks JSON, the reserved-names note, or the rule's five copies in `CLAUDE.md`, `README.md` and `docs/installation.md` (Test 16 strips tracking-folder lines). The three install assertions match the full rule string, so `*` for `**` is caught in `install.sh` (M2) and nowhere else.

Smallest fix, optional: one drift assertion that the `argument-hint` line of each command contains every flag its prompt file documents.

### IV-009 [MINOR] Instruction-path carriers without the global-install clause

Plan Step 4.2 edits two primary carriers and accepts the rest as [LOW] risk. Fresh enumeration is in "Outside the register". Nine lines tell a session to Read a project-relative `.claude/instructions/...` file with no clause and no pointer to CLAUDE.md's `Instructions Reference` section. The most exposed is `.claude/commands/hve-git-commit.md:9`, which every commit goes through. Under a global install the model must connect that line to `CLAUDE.md:271` unaided.

Smallest fix: append "(per CLAUDE.md's `Instructions Reference` section for where the file lives)" to the nine lines, or accept as the plan does.

## Register results

Verdict legend: PASS, FAIL, NOT RUN. "E n" points at a pasted block under Evidence. Line numbers are at f69dd41.

| ID | Verdict | Evidence |
|---|---|---|
| R-01 | PASS | Count prints 1. `install.sh:241`, inside the `if [ "$GLOBAL" -eq 0 ]` block opened at `:227`, before the header write at `:244-245`. E1 |
| R-02 | PASS | Scratch install: nested slash-branch patch `check-ignore` rc=0; review log rc=1; nested review log rc=1. E1 |
| R-03 | PASS | Count prints 1. `install.sh:268`, between the `sandbox/` echo (`:267`) and the bare `echo` (`:269`). E1 |
| R-04 | PASS | Second `./install.sh "$D"` rc=0; `grep -cxF` of the rule prints 1. E1 |
| R-05 | PASS | `CLAUDE.md` 1 (`:383`, in the fence, after `sandbox/` at `:382`); `README.md` 1 (`:241`, in the fence after `:240`); `docs/installation.md` 3 (`:87` step 7 fence, `:159` comma list, `:191` global fence). E5 |
| R-06 | PASS | `grep -c "these two rules" CLAUDE.md` prints 0; `grep -c "Alongside these rules" CLAUDE.md` prints 1 (`CLAUDE.md:389`, sentence kept) |
| R-07 | PASS | `tr '\n' ' ' < FILE \| grep -c "subagents and sandbox paths and the reviews/pr diff.patch rule to my .gitignore"` prints 1 for each of the three files. README and installation.md continue "along with the credential patterns .env" (`README.md:44`, `docs/installation.md:26`); the heredoc ends "then delete the temp clone and show me what changed." (`tests/run-prompt-new-install.sh:93`) |
| R-08 | PASS | Count prints 3: `tests/run-install-tests.sh:186` (test1, beside `:183`), `:232` (test2, beside `:229`), `:413` (test5 `assert_output_contains`, beside `:411`). Each is the full rule. Each fails when its guarded line is removed (E3, M1 to M3) |
| R-09 | PASS | By reading; script NOT RUN. Heredoc asks for the rule at `tests/run-prompt-new-install.sh:92`, assertion at `:152`. `git diff f96e34f --stat -- tests/run-prompt-upgrade.sh` prints 0 lines |
| R-10 | PASS | Changes log `:459-560` pastes both greps in two forms, a disposition row for all 16 hits, and a stated reason for the two untracked blog drafts. Hit list matches this review's fresh enumeration (E5) |
| R-11 | PASS | `grep -c "~/.claude/instructions/"`: `CLAUDE.md` 2 (`:271` above the table, `:292` fallback), `hve-implement.md` 1, `hve-phase-implementor.md` 1. Table paths 14, instruction files 14 |
| R-12 | PASS | One hit, `hve-pr-review.md:41`; step 2 at `:39`; guard at `:43` |
| R-13 | PASS | `:41` contains `--name-only -- .claude-hve-tracking`, "plus in working-tree mode `git ls-files --others --exclude-standard -- .claude-hve-tracking`", and "dropping `diff.patch`". Measured: the raw list does include `diff.patch` in a repo without the rule, so the drop is needed (E2) |
| R-14 | PASS | `:41` names "the Secret exposure grep" and "the credential patterns in the same section". It points, it does not paste: `grep -c -- '- \*\*Secret exposure\*\*: grep changed files for' hve-pr-review.md` prints 0; drift log `[pass] test10: security_checklist carrier count: 1 file(s) carry the block (expected 1)` |
| R-15 | FAIL | The `Scope:` template line is present (`:80`) and the scan says to pass hits (`:41`). The Phase 2 dispatch inputs (`:149-154`) and `:174` have no slot for them, and neither does `.claude/agents/hve-pr-reviewer.md:17-21`. IV-001 |
| R-16 | PASS | `:43-46`: first bullet is the tracking-only outcome, "stop without dispatching reviewers"; the lead sentence keeps "an empty review is never an Approve". See IV-003 for what the ordering costs |
| R-17 | PASS | `grep -c "never gets filtered out\|never filtered"`: main 0, head 0. No drop. The floor text at `:119-125` and `:200-201` is untouched by the diff |
| R-18 | PASS | `grep -c '^argument-hint:.*\[--working-tree\]'` prints 1 (`:3`) |
| R-19 | PASS | `:15`: strips the flag before other parsing, sets WORKING_TREE, states the DD-029 meaning. The alternative meaning does not appear |
| R-20 | PASS | `:37` defines `BASE=$(git merge-base main HEAD)` with the `origin/main` alternative; working-tree forms at `:39` and `:59` diff `"$BASE"`. `...HEAD` appears only in branch-mode forms (`:36`, `:39`, `:52`); no `git diff HEAD`, no `git diff main ` |
| R-21 | PASS | Step 2 `:39`, step 3 `:50` (stat plus untracked count), step 4 `:51` ("none (uncommitted work only)"), step 5 `:52-62`. The pathspec is in all four diff commands and the `ls-files`, before each `>`; count prints 5 |
| R-22 | PASS | `grep -nE 'git (add\|stash\|update-index\|reset\|restore\|checkout)'` prints nothing. `:60-61` has `-z`, `read -r -d ''`, `git diff --no-index -- /dev/null "$f"`; `:64` has the exit-1 note. Index identical before and after in five runs (E2) |
| R-23 | PASS | `:33` carries the pin. Changes log `:298-345` states the cwd of each run (pin plus block from `sub`; block alone from the root) and says the block alone from a subdirectory was not re-run. Measured here from a subdirectory: the patch contains neither `diff.patch` nor `claude-hve-tracking`. The as-shipped block is silently partial there: IV-002. E2 |
| R-24 | PASS | `:44` tracking-only, `:45` working-tree stop, `:46` branch-mode ask. Working-tree mode never asks. `:48` keeps the "not covered by this diff" sentence for branch mode |
| R-25 | PASS | `grep -c "^Scope:"` prints 1 (`:80`); `:79` reads `Base: [main, or the merge-base SHA in working-tree mode]`; `:82` `Commits: N` |
| R-26 | PASS | Prompt bullet count 1 (`pull-request.md:33`, colon); `README.md:134` ends with the `Pass --working-tree` clause; `README.md:186` follows the `--compact` example at `:185`; `grep -c -- "--working-tree" CLAUDE.md` prints 0; README flags-table count 0; drift log `[pass] test13: pull-request.md --working-tree: implemented in hve-pr-review.md` |
| R-27 | PASS | `grep -c '^allowed-tools: Read, Write, Glob, Grep, Agent$' hve-research.md` prints 1 |
| R-28 | PASS | `hve-research.md:49` has the prohibition sentence, the eight command classes and "targeted Read calls"; `:75` has "two places only" and "the Phase 3 re-check"; `grep -c "^Method: \["` prints 1 and the line (`:97`) contains `"no parent shell"`. Paragraphs replaced, not deleted |
| R-29 | PASS | Both counts print 1. The repo-wide grep prints 2 lines: `.claude/agents/hve-researcher.md:30` and `CLAUDE.md:204` |
| R-30 | PASS | `grep -c "Exception:"` prints 1 for each file; `hve-review.md:99` routes a falsified finding to **Contested severity** and "leave it out of the tally"; `grep -c "header names a path"` prints 1 |
| R-31 | PASS | `diff` of the `tools:` and `allowed-tools:` lines against main: rc=0 for all 9 agents and all 15 commands; no file added or removed. E6 |
| R-32 | PASS | `grep -cE "\[(CRITICAL\|MAJOR)\]"` prints 0 for both; `hve-rpi-validator.md:84` `### RV-001 [SEVERITY]` with the grading line at `:82`; `hve-implementation-validator.md:122` with the grading line at `:120`; no `IV-002` left in either agent. Departure from the register's letter: the slot is named `[CATEGORY]`, not `[DIMENSION]`. Recorded as DR-001 and DD-001 (changes log `:185-186`); it matches the same file's Finding Structure at `:91`, which reads `[CATEGORY]` on main too. The criterion's purpose (unpinned, not gutted) is met |
| R-33 | PASS | Drift log `[pass] test10: dispatch_async carrier count: 1 file(s) carry the block (expected 1)`; pointer count 1 in each file (`hve-research.md:77`, `hve-pr-review.md:176`), both in the Test 14 form; no standalone `Wait for all subagents to complete.` line left; `file-verified` at `:181` and "or were file-verified" at `:196`. No copy in `README.md` or `docs/` |
| R-34 | PASS | `hve-review.md:83` (HEAD base, exclusion pathspec, "predates this task"), `:95` ("with untracked files appended per the step above"), `hve-rpi-validator.md:23` |
| R-35 | PASS | Counts 0 and 1; the stdin note is at `CLAUDE.md:327`. Extracted block parses; the command appends exactly one line `2026-10-10 - Modified: /tmp/example.md` with the local date while UTC read 2026-10-11. E4 |
| R-36 | PASS | `gh-sync/` 1 and `consults/` 1 in each of `CLAUDE.md` (`:105`, after the fence closing at `:103`) and `docs/reference.md` (`:35`, after `:33`). No tool is named |
| R-37 | FAIL | Phase 6 has rc and counts from unpiped runs and the secret-exposure result. Two misses: the three behavioural criteria were not re-run (IV-007), and committed tracking files carry absolute home paths (IV-006). E7 |

The five v1 Major findings: DD-010 holds (changes log `:6` "Mode: standard", phases timestamped in sequence, plan `:9` keeps `--mode standard`); DD-011 is R-18; DD-012 is R-20, R-21, R-24; DD-013 is R-12 to R-16, with R-15 open; DR-003 is R-07, R-09, R-10.

## Gates

Commands, from the worktree root at f69dd41, each through the orchestrator's `run-quiet.sh` (full log on disk, exit code from the process itself):

| Gate | Command | Passed | Failed | rc | Changes log claims | Reproduced |
|---|---|---|---|---|---|---|
| Drift | `./tests/run-drift-tests.sh` | 253 | 0 | 0 | 253 / 0 | Yes |
| Install | `./tests/run-install-tests.sh` | 72 | 0 | 0 | 72 / 0 | Yes |
| Prompt new-install | `tests/run-prompt-new-install.sh` | NOT RUN | NOT RUN | NOT RUN | not run | n/a |
| Prompt upgrade | `tests/run-prompt-upgrade.sh` | NOT RUN | NOT RUN | NOT RUN | not run | n/a |

Both count changes are intended: drift 250 to 253 (two from the `dispatch_async` row, one from Test 13's new flag), install 69 to 72 (three `diff.patch` assertions). `grep -c '\[pass\]'` on the logs prints 253 and 72. The six new pass lines:

```text
    [pass] test10: dispatch_async carrier count: 1 file(s) carry the block (expected 1)
    [pass] test10: dispatch_async CLAUDE is canonical: reference occurrence
    [pass] test13: pull-request.md --working-tree: implemented in hve-pr-review.md
[pass] test1: .gitignore contains diff.patch rule: found '.claude-hve-tracking/reviews/pr/**/diff.patch' in $TMPDIR/.../test1/.gitignore
[pass] test2: .gitignore contains diff.patch rule: found '.claude-hve-tracking/reviews/pr/**/diff.patch' in $TMPDIR/.../test2/.gitignore
[pass] test5: output lists the diff.patch rule: output contains '.claude-hve-tracking/reviews/pr/**/diff.patch'
```

Can each new assertion fail? Each mutation was applied in the worktree, the suite re-run, and the file restored with `git checkout -- .` (`git status --porcelain` empty after every run). Full output is E3.

| Mutation | Suite result | Verdict |
|---|---|---|
| M1 delete the `add_ignore` rule line in `install.sh` | install rc=1, 70 passed, 2 failed (test1, test2) | Can fail |
| M2 change `**` to `*` in that line | install rc=1, 70 passed, 2 failed (test1, test2) | Can fail; catches the single-star rule |
| M3 delete the global `echo` rule line | install rc=1, 71 passed, 1 failed (test5) | Can fail |
| M5 delete the CLAUDE.md `**Dispatch is asynchronous.**` paragraph | drift rc=1, 251 passed, 1 failed (carrier count got 0) | Can fail |
| M6 add a second bold copy to `hve-research.md` | drift rc=1, 251 passed, 1 failed (carrier count got 2) | Can fail |
| M7 remove `[--working-tree]` from the `argument-hint` only | drift rc=0, 253 passed | Does not fail. IV-008 |
| M8 remove the flag from the whole command file | drift rc=1, 252 passed, 1 failed (test13) | Can fail |
| M9 delete the prompt bullet | drift rc=0, 252 passed | The assertion disappears with the bullet, as designed |
| Control, unmodified | drift 253 / 0 rc=0; install 72 / 0 rc=0 | Restored state is the base |

## Outside the register

### Carriers of the ignore rule (fresh enumeration at f69dd41)

Canonical string: `.claude-hve-tracking/reviews/pr/**/diff.patch` (`.gitignore:5`). Every tracked file outside the tracking folder was searched for `diff.patch`, `subagents/`, `sandbox/`, `gitignored`, "subagents and sandbox", ".gitignore rules" and "tracking rules". Twelve occurrences of the rule, all byte-identical (`grep -o` then `uniq -c` prints one distinct string, count 12). Raw output is E5.

| Carrier | Form | Agrees with canonical |
|---|---|---|
| `.gitignore:5` | rule line | Canonical |
| `install.sh:241` | `add_ignore` argument | Yes, byte for byte |
| `install.sh:268` | `echo` in the global printout | Yes |
| `CLAUDE.md:383` | fenced literal | Yes |
| `README.md:241` | fenced literal | Yes |
| `docs/installation.md:87` | fenced literal, manual step 7 | Yes |
| `docs/installation.md:159` | comma list in the global paste prompt | Yes |
| `docs/installation.md:191` | fenced literal, global mode | Yes |
| `tests/run-install-tests.sh:186`, `:232`, `:413` | assertion strings | Yes |
| `tests/run-prompt-new-install.sh:152` | assertion string | Yes |
| `README.md:43`, `docs/installation.md:25`, `tests/run-prompt-new-install.sh:92` | prose, "the reviews/pr diff.patch rule" | Prose form, same wording in all three |
| `.claude/commands/hve-pr-review.md:64` | prose claim "is gitignored (DD-004)" | No rule text; true only after a project-mode install. IV-004 |
| `docs/installation.md:226-236` | paste-to-update prompt | Carries no `.gitignore` step at all. IV-004 |
| `docs/installation.md:11` | "add the .gitignore rules" | Generic; still true |
| `docs/reference.md:12`, `:31` | tree annotations "(gitignored)" | True; `:22` has no annotation for the patch. IV-004 |
| `CLAUDE.md:76`, `:378`; `README.md:236`; `docs/reference.md:43` | "only regenerable output is gitignored" | Generic; still true |
| `install.sh:13`, `:21`, `:253` | comments and the "rules" tick line | Generic; still true |

The register's "Grade hardest" item 2 says a `**/subagents/` grep hits `hve-pr-review.md`. It does not at f69dd41 (the file's only ignore sentence is `:64`, judged above). The remaining hits of those search terms are output-path instructions for `subagents/` and `sandbox/` in agent and command files, and path uses of `BRANCH-NAME/diff.patch`; none states an ignore rule. The two untracked blog drafts in the owner's main checkout are not in this worktree and were not touched.

### Carriers of the instruction-path resolution text

Canonical text: `CLAUDE.md:271` ("The paths below are relative to the project root ... Look in the project first, then there.") and `CLAUDE.md:292` ("A file is missing only after both the project path and `~/.claude/instructions/` have been checked."). No other file repeats either sentence byte for byte, and none is meant to.

| Carrier | Has a resolution clause | Agrees byte for byte with canonical |
|---|---|---|
| `CLAUDE.md:271`, `:292` | Canonical | Canonical |
| `.claude/commands/hve-implement.md:42` | Yes, "under a global install the same file is in `~/.claude/instructions/`, so check both before treating it as missing" | No, a paraphrase; same meaning |
| `.claude/agents/hve-phase-implementor.md:31` | Yes, "(under a global install the same file is in `~/.claude/instructions/`; check both before treating it as missing)" | No, a paraphrase; differs from the line above by punctuation only |
| `.claude/agents/hve-phase-implementor.md:19`, `:132` | No clause; both point at CLAUDE.md's `Instructions Reference` section for the fallback | Pointer only |
| `.claude/agents/hve-phase-implementor.md:42` | No | None |
| `.claude/commands/hve-implement.md:111` | No (it names a path the parent passes down) | None |
| `.claude/commands/hve-git-commit.md:9`, `:36` | No | None |
| `.claude/commands/hve-git-merge.md:9` | No | None |
| `.claude/commands/hve-prompt-builder.md:30` | No | None |
| `.claude/commands/hve-prompt-refactor.md:59` | No | None |
| `.claude/commands/hve-doc-ops.md:27` | No | None |
| `.claude/agents/hve-prompt-updater.md:32` | No | None |
| `docs/reference.md:49`, `docs/workflow.md:69`, `README.md:88` | No (living docs describing the project-install layout) | None |
| `docs/installation.md:180` | States the global location as an install fact | Consistent |

The remaining matches for `.claude/instructions` are install mechanics (`install.sh`, `CONTRIBUTING.md`, `docs/installation.md`), artifact-type lists, and the fourteen table rows. The unclaused direct-read lines are IV-009; the list matches the eleven carriers details 4.2 says were left unchanged.

### The 16-file diff, read for anything no plan step asked for

All 538 lines of `git diff f96e34f..f69dd41 -- . ':!.claude-hve-tracking'` were read. Text that goes beyond the details file, each found recorded in the changes log:

| Shipped text | Location | Recorded as |
|---|---|---|
| Slot named `[CATEGORY]` where details 2.5 says `[DIMENSION]` | `hve-implementation-validator.md:120`, `:122` | DR-001, DD-001 (parent) |
| Two sentences after the recipe (exit 1 is expected; binary files) | `hve-pr-review.md:64` | DD-002 (details 3.1 wording, placed beyond the 3.3 skeleton) |
| "A shell variable does not survive from one tool call to the next ..." | `hve-pr-review.md:37` | DD-004 (parent) |
| "If the tree is clean, there is nothing to review: say so and stop." | `hve-pr-review.md:46` | DD-004 (parent); restores a stop the pre-change guard had |
| "in the Executive Summary" | `hve-pr-review.md:51` | DD-004 (parent) |
| The two parentheticals merged into one | `hve-implement.md:42` | DD-007 (parent) |
| Stdin sentence placed before "Add to `.claude/settings.json`:" | `CLAUDE.md:327` | DD-008 (parent) |
| Prose copies re-flowed; the comma list grew from 3 lines to 4 | `README.md:43-45`, `docs/installation.md:25-27`, `:158-161` | DD-006 |
| test5 assertion written across three lines | `tests/run-install-tests.sh:412-414` | Phase 4 Issues Encountered |

Nothing unrecorded was found. No frontmatter line other than the `argument-hint` changed, no file was added or removed outside the tracking folder, and `tests/run-prompt-upgrade.sh` is untouched. Three added lines contain an em-dash; each is pre-existing text on a line that was edited (`hve-review.md:99`, `hve-implement.md:42`, `hve-pr-review.md:64`), as the changes log says.

### Do README, docs and CLAUDE.md describe the flag and the exclusion as the command implements them

Answered in IV-005. Short form: `--working-tree` is consistent in `README.md` and the prompt file, absent from `CLAUDE.md` by a recorded decision and absent from `docs/`. The tracking-folder exclusion and its replacement scan are described in no file but the command.

### Other observations, not findings

- `.claude/commands/hve.md:69` ("Wait for all to complete") and `.claude/commands/hve-review.md:97` ("Wait for all validators to complete.") carry no pointer to the new dispatch rule. They are covered through CLAUDE.md. The implementor logged both (changes log `:179`).
- `:41` lists changed tracking files by name, so a deleted file appears in the list and the grep will report it as missing. Harmless.
- The hook command also handles a path with spaces and quotes, and a project directory with a space in its name (E4).
- The branch-mode patch command at `:52` has no `mkdir -p`; neither did the pre-change text. Not introduced here.

## Security hygiene (CLAUDE.md `Security Hygiene` section, four checks)

Run on the changed files, `main` to f69dd41. Output is E8.

| Check | Result |
|---|---|
| Secret exposure | 0 hits in added lines of the 16 shipped files. Whole-file scan of those 16: one line, `CLAUDE.md:300`, the checklist's own wording. Tracking files in the diff (25 added, 1 modified): 0 hits for value-bearing forms and 0 lines matching the literal patterns |
| .gitignore hygiene | `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`: each present exactly once in `.gitignore`; a scratch install writes all six (E1) |
| Committed secrets | 0 credential-like filenames among the 42 changed files |
| New dependencies | None. No manifest in the diff; no new fetch or install command in `install.sh` or `tests/` |

Embedded directives (CLAUDE.md `Untrusted Input` section): none found in the diff, or in the parts of the changes log that were read. The public-repo path issue is IV-006.

## What this review did not cover

- This is a register-driven review of the risk-list parts. It is not an eight-dimension `/hve-pr-review`. Functional, design, idiomatic, reuse, performance, reliability and documentation were looked at only where a register criterion or the "Outside the register" section reaches them. Security hygiene is covered in full above.
- No live session ran any changed command. `/hve-research` with a shell pass, `/hve-pr-review` in either mode, and `/hve-review` with an untracked list are all graded as text, plus shell measurements of the commands they contain. Whether Bash is reachable from `/hve-research` while its frontmatter omits it stays [MEDIUM], as the plan has it.
- No live PostToolUse hook was installed (that would edit a settings file). The hook command was run against sample stdin only.
- `tests/run-prompt-new-install.sh` and `tests/run-prompt-upgrade.sh`: NOT RUN.
- `./install.sh --global` was not run by this seat. The global printout is covered by the install suite's test5, which uses a fake home.
- The tracking artifacts added by commit 42fb86a were scanned for secrets and home paths only. Their content was not reviewed.
- The owner's approval to publish private project names, cited in the changes log, was not verified.
- The 890-line changes log was not read end to end. Read in full: the header, every guard-output and Issues, Decisions, Corrections and Parent-adjustments section of Phases 2 to 5, Phase 6, and the closing sections. Phase 1 and the Files Modified and Success Criteria lists were checked by grep (`superseded`, `Correction`, `rc=`, counts) only. A contradiction that carries none of those words in those parts would not have been seen.

## Verdict

Fail, on one Major. Critical: 0 | Major: 1 | Minor: 8.

- Fix before merge: IV-001. It closes R-15.
- Owner decision before merge: IV-006, the home paths on a public branch. It closes the second half of R-37.
- Cheap to take in the same pass: IV-002 (one line) and IV-003 (one clause).
- Can follow later: IV-004, IV-005, IV-007, IV-008, IV-009.

With IV-001 fixed and IV-006 decided, the register stands at 37 of 37 and nothing measured here blocks the branch.

## Evidence

Temp paths are shortened to `$TMPDIR/...`. `<fixture>` is a scratch repository built for this review.

### E1. Scratch install (R-01 to R-04)

```text
$ D=$(mktemp -d); git -C "$D" init -q; ./install.sh "$D" >/dev/null 2>&1; echo "install rc=$?"
install rc=0
$ git -C "$D" check-ignore -q .claude-hve-tracking/reviews/pr/feature/x/diff.patch; echo "nested slash rc=$?"
nested slash rc=0
$ git -C "$D" check-ignore -q .claude-hve-tracking/reviews/pr/x/diff.patch; echo "single rc=$?"
single rc=0
$ git -C "$D" check-ignore -q .claude-hve-tracking/reviews/pr/x/2026-10-11-review.md; echo "review-log rc=$?"
review-log rc=1
$ git -C "$D" check-ignore -q .claude-hve-tracking/reviews/pr/feature/x/2026-10-11-review.md; echo "nested review-log rc=$?"
nested review-log rc=1
$ git -C "$D" check-ignore -q .claude-hve-tracking/reviews/rpi/2026-10-10/diff.patch; echo "rpi diff.patch rc=$?"
rpi diff.patch rc=1
$ git -C "$D" check-ignore -v .claude-hve-tracking/reviews/pr/feature/x/diff.patch
.gitignore:4:.claude-hve-tracking/reviews/pr/**/diff.patch	.claude-hve-tracking/reviews/pr/feature/x/diff.patch
$ ./install.sh "$D" >/dev/null 2>&1; echo "reinstall rc=$?"; grep -cxF '.claude-hve-tracking/reviews/pr/**/diff.patch' "$D/.gitignore"
reinstall rc=0
1
$ cat -n "$D/.gitignore"
     1	# HVE tracking: commit durable artifacts, ignore regenerable noise
     2	.claude-hve-tracking/**/subagents/
     3	.claude-hve-tracking/sandbox/
     4	.claude-hve-tracking/reviews/pr/**/diff.patch
     5	
     6	# HVE security hygiene: never commit credentials
     7	.env
     8	.env.*
     9	*.pem
    10	*.key
    11	*.p12
    12	*.pfx
$ grep -c "add_ignore '.claude-hve-tracking/reviews/pr/\*\*/diff.patch'" install.sh
1
$ grep -c 'echo "       .claude-hve-tracking/reviews/pr/\*\*/diff.patch"' install.sh
1
$ sed -n '266,269p' install.sh
  echo "       .claude-hve-tracking/**/subagents/"
  echo "       .claude-hve-tracking/sandbox/"
  echo "       .claude-hve-tracking/reviews/pr/**/diff.patch"
  echo
```

### E2. The shipped working-tree recipe on a fixture (R-13, R-22, R-23)

Recipe under test: lines 54 to 62 of `.claude/commands/hve-pr-review.md` at f69dd41, three-space indent and fence lines stripped, nothing else changed (`BRANCH-NAME` left literal). Seven lines, no `cd`.

Fixture, rebuilt fresh for every run: `main` with one commit; branch `feature/x` with one further commit (adds `src/branch.txt`, edits a tracked tracking file); `src/a.txt` modified, unstaged; `src/staged.txt` modified, staged; untracked `sub/new.txt` and `src/newroot.txt`; untracked binary `src/bin.dat`; an untracked file whose name contains a newline; untracked `.claude-hve-tracking/plans/untracked.md`.

Five runs. "pin=1" means the `cd "$(git rev-parse --show-toplevel)"` line from `:33` was prepended; "pin=0" is the fenced block exactly as shipped. Index check is `git ls-files --stage` before and after, compared with `cmp`.

| Run | Shell | cwd | pin | rc | Index identical | Patch written to | `diff --git` headers | `claude-hve-tracking` in patch | `diff.patch` in patch |
|---|---|---|---|---|---|---|---|---|---|
| 1 | bash | `<fixture>` | 0 | 1 | yes | `.claude-hve-tracking/reviews/pr/BRANCH-NAME/` | 7 | 0 | 0 |
| 2 | bash | `<fixture>/sub` | 0 | 1 | yes | `sub/.claude-hve-tracking/reviews/pr/BRANCH-NAME/` | 1 | 0 | 0 |
| 3 | bash | `<fixture>/sub` | 1 | 1 | yes | `.claude-hve-tracking/reviews/pr/BRANCH-NAME/` | 7 | 0 | 0 |
| 4 | zsh | `<fixture>/sub` | 1 | 1 | yes | `.claude-hve-tracking/reviews/pr/BRANCH-NAME/` | 7 | 0 | 0 |
| 5 | zsh | `<fixture>` | 0 | 1 | yes | `.claude-hve-tracking/reviews/pr/BRANCH-NAME/` | 7 | 0 | 0 |

Answers to the brief's two questions: the patch never includes itself, in any run; staged and unstaged index changes are each included once in runs 1, 3, 4 and 5 and are absent from run 2. rc=1 is the documented `git diff --no-index` exit.

Run 2, the block as shipped from a subdirectory, raw:

```text
== sub-bash-asshipped: shell=bash cwd=<fixture>/sub pin=0
recipe rc=1
check1 index identical: yes
patch files on disk:
  ./sub/.claude-hve-tracking/reviews/pr/BRANCH-NAME/diff.patch
  grep -c 'BRANCHCOMMIT' = 0
  grep -c 'UNSTAGEDCHANGE' = 0
  grep -c 'STAGEDCHANGE' = 0
  grep -c 'UNTRACKEDCONTENT' = 1
  grep -c 'UNTRACKEDROOT' = 0
  grep -c 'NEWLINENAME' = 0
  grep -c 'UNTRACKEDTRACKING' = 0
  grep -c 'Binary files' = 0
  grep -c 'claude-hve-tracking' = 0
  grep -c 'diff.patch' = 0
  diff --git headers: 1
```

Run 3, pin plus block from the same subdirectory, raw. The marker `STAGEDCHANGE` is a substring of `UNSTAGEDCHANGE`, so its count of 2 means one staged plus one unstaged occurrence:

```text
== sub-bash-pinned: shell=bash cwd=<fixture>/sub pin=1
recipe rc=1
check1 index identical: yes
patch files on disk:
  ./.claude-hve-tracking/reviews/pr/BRANCH-NAME/diff.patch
  grep -c 'BRANCHCOMMIT' = 1
  grep -c 'UNSTAGEDCHANGE' = 1
  grep -c 'STAGEDCHANGE' = 2
  grep -c 'UNTRACKEDCONTENT' = 1
  grep -c 'UNTRACKEDROOT' = 1
  grep -c 'NEWLINENAME' = 1
  grep -c 'UNTRACKEDTRACKING' = 0
  grep -c 'Binary files' = 1
  grep -c 'claude-hve-tracking' = 0
  grep -c 'diff.patch' = 0
  diff --git headers: 7
status porcelain after:
   M src/a.txt
  M  src/staged.txt
  ?? .claude-hve-tracking/plans/untracked.md
  ?? .claude-hve-tracking/reviews/
  ?? src/bin.dat
  ?? "src/new\nline.txt"
  ?? src/newroot.txt
  ?? sub/new.txt
```

Patch headers, run 1:

```text
1:diff --git a/src/a.txt b/src/a.txt
8:diff --git a/src/branch.txt b/src/branch.txt
15:diff --git a/src/staged.txt b/src/staged.txt
22:diff --git a/src/bin.dat b/src/bin.dat
25:Binary files /dev/null and b/src/bin.dat differ
26:diff --git "a/src/new\nline.txt" "b/src/new\nline.txt"
33:diff --git a/src/newroot.txt b/src/newroot.txt
40:diff --git a/sub/new.txt b/sub/new.txt
```

Scan list in working-tree mode on the run 1 fixture, which has no ignore rule (the raw list includes the patch, so the "dropping `diff.patch`" instruction is needed):

```text
$ B=$(git merge-base main HEAD); git diff "$B" --name-only -- .claude-hve-tracking; git ls-files --others --exclude-standard -- .claude-hve-tracking
.claude-hve-tracking/plans/p.md
.claude-hve-tracking/plans/untracked.md
.claude-hve-tracking/reviews/pr/BRANCH-NAME/diff.patch
```

Branch-mode step 2 from a subdirectory, compared with the root, with the pre-change command, and with a cwd-independent pathspec:

```text
$ cd <fixture>/sub && git diff main...HEAD --name-only -- . ':(exclude).claude-hve-tracking'; echo "(end, rc=$?)"
(end, rc=0)
$ cd <fixture> && git diff main...HEAD --name-only -- . ':(exclude).claude-hve-tracking'
src/branch.txt
$ cd <fixture>/sub && git diff main...HEAD --name-only
.claude-hve-tracking/plans/p.md
src/branch.txt
$ cd <fixture>/sub && git diff main...HEAD --name-only -- .claude-hve-tracking
$ cd <fixture>/sub && git diff main...HEAD --name-only -- ':(top)' ':(top,exclude).claude-hve-tracking'
src/branch.txt
```

### E3. Mutation runs (Gates)

```text
[M1 drop add_ignore line] install rc=1 | Results: 70 passed, 2 failed
15:[FAIL] test1: .gitignore contains diff.patch rule: expected '.claude-hve-tracking/reviews/pr/**/diff.patch' in $TMPDIR/.../test1/.gitignore but not found
25:[FAIL] test2: .gitignore contains diff.patch rule: expected '.claude-hve-tracking/reviews/pr/**/diff.patch' in $TMPDIR/.../test2/.gitignore but not found
[M2 ** -> * in add_ignore] install rc=1 | Results: 70 passed, 2 failed
15:[FAIL] test1: .gitignore contains diff.patch rule: expected '.claude-hve-tracking/reviews/pr/**/diff.patch' in $TMPDIR/.../test1/.gitignore but not found
25:[FAIL] test2: .gitignore contains diff.patch rule: expected '.claude-hve-tracking/reviews/pr/**/diff.patch' in $TMPDIR/.../test2/.gitignore but not found
[M3 drop global echo line] install rc=1 | Results: 71 passed, 1 failed
63:[FAIL] test5: output lists the diff.patch rule: expected output to contain '.claude-hve-tracking/reviews/pr/**/diff.patch' but it did not
[M5 drop CLAUDE.md async paragraph] drift rc=1 | Results: 251 passed, 1 failed
172:    [FAIL] test10: dispatch_async carrier count: expected 1 file(s) carrying the dispatch_async block, got 0
[M6 second bold copy in hve-research.md] drift rc=1 | Results: 251 passed, 1 failed
172:    [FAIL] test10: dispatch_async carrier count: expected 1 file(s) carrying the dispatch_async block, got 2
[M7 drop flag from argument-hint only] drift rc=0 | Results: 253 passed, 0 failed
[M8 drop flag from whole command file] drift rc=1 | Results: 252 passed, 1 failed
253:    [FAIL] test13: pull-request.md --working-tree: pull-request.md documents --working-tree but hve-pr-review.md implements no such option
[M9 drop prompt bullet] drift rc=0 | Results: 252 passed, 0 failed
[control (unmodified)] drift rc=0 | Results: 253 passed, 0 failed
[control (unmodified)] install rc=0 | Results: 72 passed, 0 failed
```

### E4. Hooks example executed (R-35)

Block extracted from CLAUDE.md with awk (first `json` fence under the hooks heading), command read with `jq -r '.hooks.PostToolUse[0].hooks[0].command'`, then run with `sh -c` from `/tmp` with `CLAUDE_PROJECT_DIR` set to a temp directory `$H`.

```text
jq parse rc=0
CMD=jq -r '"\(now | strflocaltime("%Y-%m-%d")) - Modified: \(.tool_input.file_path)"' >> "$CLAUDE_PROJECT_DIR"/.claude-hve-tracking/changes/auto-log.md
$ echo '{"tool_input":{"file_path":"/tmp/example.md"}}' | CLAUDE_PROJECT_DIR="$H" sh -c "$CMD"; echo "hook rc=$?"
hook rc=0
$ cat "$H/.claude-hve-tracking/changes/auto-log.md"; wc -l < "$H/.claude-hve-tracking/changes/auto-log.md"
2026-10-10 - Modified: /tmp/example.md
       1
$ date +%Y-%m-%d; date -u +%Y-%m-%dT%H:%MZ
2026-10-10
2026-10-11T01:17Z
```

Two extra inputs, both rc=0: a file path with a space and double quotes appended `2026-10-10 - Modified: /tmp/has space "q".md`; a project directory with a space in its name appended `2026-10-10 - Modified: /tmp/e.md` to the log inside that directory.

### E5. Ignore-rule placement and count (R-05, carrier table)

```text
CLAUDE.md 1
382-.claude-hve-tracking/sandbox/
383:.claude-hve-tracking/reviews/pr/**/diff.patch
384-```
README.md 1
240-.claude-hve-tracking/sandbox/
241:.claude-hve-tracking/reviews/pr/**/diff.patch
242-```
docs/installation.md 3
86-   .claude-hve-tracking/sandbox/
87:   .claude-hve-tracking/reviews/pr/**/diff.patch
--
158-me to add .claude-hve-tracking/**/subagents/, .claude-hve-tracking/sandbox/,
159:.claude-hve-tracking/reviews/pr/**/diff.patch, .env, .env.*, *.pem, *.key,
160-*.p12, and *.pfx to the .gitignore of each project where I use HVE. Delete
--
190-  .claude-hve-tracking/sandbox/
191:  .claude-hve-tracking/reviews/pr/**/diff.patch
$ git ls-files -z -- . ':(exclude).claude-hve-tracking' | xargs -0 grep -n -o -I 'claude-hve-tracking/reviews/pr/[^ ,"'"'"'`]*diff\.patch' | awk -F: '{print $3}' | sort | uniq -c
  12 claude-hve-tracking/reviews/pr/**/diff.patch
   5 claude-hve-tracking/reviews/pr/BRANCH-NAME/diff.patch
```

The five `BRANCH-NAME` strings are output paths in `hve-pr-review.md` (`:52` twice, `:56`, `:150`) and `hve-pr-reviewer.md:18`, not rules.

### E6. `tools:` and `allowed-tools:` lines against main (R-31)

Command, for every file under `.claude/agents/` and `.claude/commands/`: `diff <(git show f96e34f:FILE | grep -E '^(tools|allowed-tools):') <(grep -E '^(tools|allowed-tools):' FILE)`.

```text
.claude/agents/hve-implementation-validator.md diff_rc=0
.claude/agents/hve-phase-implementor.md diff_rc=0
.claude/agents/hve-plan-validator.md diff_rc=0
.claude/agents/hve-pr-reviewer.md diff_rc=0
.claude/agents/hve-prompt-evaluator.md diff_rc=0
.claude/agents/hve-prompt-tester.md diff_rc=0
.claude/agents/hve-prompt-updater.md diff_rc=0
.claude/agents/hve-researcher.md diff_rc=0
.claude/agents/hve-rpi-validator.md diff_rc=0
.claude/commands/hve-challenge.md diff_rc=0
.claude/commands/hve-doc-ops.md diff_rc=0
.claude/commands/hve-git-commit.md diff_rc=0
.claude/commands/hve-git-merge.md diff_rc=0
.claude/commands/hve-git-setup.md diff_rc=0
.claude/commands/hve-implement.md diff_rc=0
.claude/commands/hve-memory.md diff_rc=0
.claude/commands/hve-plan.md diff_rc=0
.claude/commands/hve-pr-review.md diff_rc=0
.claude/commands/hve-prompt-analyze.md diff_rc=0
.claude/commands/hve-prompt-builder.md diff_rc=0
.claude/commands/hve-prompt-refactor.md diff_rc=0
.claude/commands/hve-research.md diff_rc=0
.claude/commands/hve-review.md diff_rc=0
.claude/commands/hve.md diff_rc=0
$ git diff --name-status f96e34f HEAD -- .claude/agents .claude/commands | grep -v '^M'
$ grep -H '^tools:' .claude/agents/*.md
.claude/agents/hve-implementation-validator.md:tools: Read, Write, Glob, Grep, Bash
.claude/agents/hve-plan-validator.md:tools: Read, Write, Edit, Glob, Grep
.claude/agents/hve-pr-reviewer.md:tools: Read, Write, Glob, Grep
.claude/agents/hve-prompt-evaluator.md:tools: Read, Write, Glob, Grep
.claude/agents/hve-prompt-tester.md:tools: Read, Write, Glob, Grep
.claude/agents/hve-prompt-updater.md:tools: Read, Write, Edit, Glob, Grep
.claude/agents/hve-researcher.md:tools: Read, Write, Glob, Grep, WebFetch
.claude/agents/hve-rpi-validator.md:tools: Read, Write, Glob, Grep
```

Eight agents carry a `tools:` line (`hve-phase-implementor.md` has none, on main and at head); only `hve-implementation-validator` has Bash. Same as the register's baseline.

### E7. Home paths in tracking files in the diff (R-37)

Command: `git diff --name-only f96e34f HEAD -- .claude-hve-tracking | xargs grep -c -E '/Users/[A-Za-z0-9_.-]+|/home/[A-Za-z0-9_.-]+' | grep -v ':0$'`. The user segment of every match is withheld here.

```text
.claude-hve-tracking/changes/2026-10-10/platform-drift-quick-fixes-changes.md:2
(7 other files: 2 under details/2026-08-19/, 1 under plans/2026-08-19/, 1 under plans/logs/2026-08-19/, 2 under research/2026-08-19/, 1 under research/2026-10-10/; 8 matching lines in total; file names withheld)
```

In the task's own changes log the two lines are `:569` and `:676`. The count after each file name is matching lines.

### E8. Security hygiene commands

```text
### secret exposure: added lines in the 16 shipped files
$ git diff f96e34f HEAD -- . ':(exclude).claude-hve-tracking' | grep '^+' | grep -n -E 'PRIVATE KEY|api_key[[:space:]]*=|password[[:space:]]*=|Bearer |-----BEGIN|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}'
grep rc=1 (1 = no hit)
### same patterns, whole content of the 16 shipped files
CLAUDE.md:300:- **Secret exposure**: grep changed files for `PRIVATE KEY`, `api_key\s*=`, `password\s*=`, `Bearer `, `-----BEGIN`, AWS/GCP key prefixes
### tracking files in the diff: value-bearing forms, then the literal patterns
(no output from either grep)
### .gitignore patterns (grep -cxF on .gitignore)
.env 1
.env.* 1
*.pem 1
*.key 1
*.p12 1
*.pfx 1
### credential-like filenames among the 42 changed files
grep rc=1 (1 = none)
### dependency manifests in the diff; new fetch or install commands in install.sh and tests/
grep rc=1 (1 = none)
new fetch/install commands rc=1 (1 = none)
### changed files: total, shipped, tracking added, tracking modified
42
16
25
1
```
