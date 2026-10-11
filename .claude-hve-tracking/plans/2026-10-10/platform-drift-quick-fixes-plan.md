# Implementation Plan: Platform-Drift and Friction Quick Fixes

Date: 2026-10-10
Task slug: platform-drift-quick-fixes
Research: .claude-hve-tracking/research/2026-10-10/cross-repo-process-review.md (shared research doc, slug `cross-repo-process-review`; this plan covers step 1 of its Recommended sequence only)
Supporting evidence: .claude-hve-tracking/research/subagents/2026-10-10/cross-repo-process-review-friction-logs.md (F-numbered items)
Details: .claude-hve-tracking/details/2026-10-10/platform-drift-quick-fixes-details.md (replacement text for every step)
Status: Approved by Kevin 2026-10-10 (v2), including the `--working-tree` meaning in DD-029. v1 was validated Fail with 0 Critical, 5 Major, 18 Minor (.claude-hve-tracking/reviews/rpi/2026-10-10/platform-drift-quick-fixes-plan-validation.md). v2 addresses all 5 Major and the Minor items listed in the planning log's Resolutions section. v2 has not been re-validated.
Execution mode: run with `/hve-implement --mode standard` (one phase at a time). Phases share files, so parallel dispatch is not safe.

## Overview

Fix the small defects that make HVE instructions unfollowable or false on the current Claude Code platform and under a global install, plus five open cross-repo friction items. Every change is a text edit to a shipped prompt file, CLAUDE.md, the installer's ignore rules, or the tests that guard them. No new command, agent, or directory ships. One new public flag ships: `--working-tree` on `/hve-pr-review` (DD-029). Decisions D1 to D5 in the research doc are plan content; D4 (read-only parent shell in research) is implemented here.

Out of scope, each recorded in the planning log (DD-008, DD-030): Bundles A, B, C; phase-close-clarity; lean restructure; the external-consumer contract; F05; F12; the seed-research convention; the implementation-validator tool question; annotating the HiVE brief (D1 consequence); the Glob and Grep instructions in hve-phase-implementor.md and hve-doc-ops.md.

Risk classification: Medium-Hard by the risk override (edits installed prompts consumed outside this repo, and install.sh).

## Phases

### Phase 1: Research-phase shell policy and consolidation rules
Dependencies: none
Estimated scope: `.claude/commands/hve-research.md` (4 edits, about 12 lines), `.claude/commands/hve-review.md` (3 edits, about 6 lines)
Success criteria (run each, paste output):
- `grep -c "never add Bash" .claude/commands/hve-research.md` prints 0
- `grep -c "Do not add Bash" .claude/commands/hve-research.md` prints 0
- `grep -c "^Method: \[" .claude/commands/hve-research.md` prints 1
- `grep -c "Exception:" .claude/commands/hve-research.md` prints 1, and the same on `.claude/commands/hve-review.md` prints 1
- `grep -c "header names a path" .claude/commands/hve-review.md` prints 1
- drift suite exits 0 (command in Step 1.9)

Steps:
- [ ] Step 1.1: Rewrite the orientation step at `.claude/commands/hve-research.md:49` per details 1.1: Glob and Grep when exposed; otherwise one read-only shell pass; when neither is available, targeted Read. Commands are recorded on the Method line.
  - Assumption: the frontmatter `allowed-tools` line at :4 stays unchanged; it is a pre-approval list, not a restriction, so Bash is reachable and prompts under the user's permission mode [MEDIUM: from the official docs as relayed by the platform check, not observed in a live `/hve-research` run]
  - Assumption: Glob and Grep are absent from the parent by default on macOS, Linux, and WSL as of Claude Code v2.1.296; the replacement text says "may omit", not "omits" [MEDIUM]
- [ ] Step 1.2: Rewrite the **Tool boundary** paragraph at `.claude/commands/hve-research.md:75` per details 1.2. Bound per Decision D4: one orientation pass in Phase 1 (which may include git history), plus the existence re-checks of Step 1.4 in Phase 3. `hve-researcher` still has no Bash.
- [ ] Step 1.3: Add a `Method:` line to the consolidated-document header template after the `Confidence:` line (`.claude/commands/hve-research.md:96`) per details 1.3.
- [ ] Step 1.4: Extend the trust rule at `.claude/commands/hve-research.md:86` with the existence-and-negative-claims exception per details 1.4 (F14). The check is recorded on the Method line.
- [ ] Step 1.5: Apply the exception to the last sentence of `.claude/commands/hve-review.md:99` per details 1.5 (F14). A finding the re-check falsifies is handled by the existing **Contested severity** and **Tally integrity** rules (:148-149): it stays in the log, tagged, with the evidence, and is excluded from the tally.
- [ ] Step 1.6: In `.claude/commands/hve-review.md`, add the `Research:` header rule to Inputs item 3 (:29) and Phase 1 step 1 (:38) per details 1.6.
- [ ] Step 1.7: Leave `.claude/agents/hve-researcher.md:30` unchanged. Record in the changes log that it was reviewed and why.
  - Assumption: a subagent that lists Glob and Grep and omits Bash still receives both [MEDIUM: official docs; today's three `hve-researcher` runs produced line-cited findings consistent with it]
- [ ] Step 1.8 (guard): run `grep -rnE "never add Bash|read-only by design|Do not add Bash" .claude/ docs/ README.md CLAUDE.md CONTRIBUTING.md` and paste the output into the changes log. Expected survivors: `.claude/agents/hve-researcher.md:30` and `CLAUDE.md:202` only [HIGH: the same grep at planning time returned those two plus hve-research.md:49 and :75, which this phase rewrites]. Any other hit is a missed carrier; fix it in this phase.
- [ ] Step 1.9 (guard): `bash tests/run-drift-tests.sh > "$TMPDIR/drift-p1.log" 2>&1; echo "rc=$?"`, then `tail -3 "$TMPDIR/drift-p1.log"`. Record rc, counts, and log path. Never pipe the suite itself.

### Phase 2: Subagent dispatch and validator template fixes
Dependencies: Phase 1 (shares `.claude/commands/hve-research.md`)
Estimated scope: `CLAUDE.md` (1 new paragraph), `.claude/commands/hve-research.md:77`, `.claude/commands/hve-pr-review.md:147-153, :164`, `.claude/agents/hve-rpi-validator.md:83`, `.claude/agents/hve-implementation-validator.md:120-123`, `tests/run-drift-tests.sh` (1 new Test 10 row)
Success criteria:
- `grep -c "Dispatch is asynchronous" CLAUDE.md` prints 1
- `grep -c "Dispatch is asynchronous rule" .claude/commands/hve-research.md` prints 1, and the same on `.claude/commands/hve-pr-review.md` prints 1
- `grep -cE "\[(CRITICAL|MAJOR)\]" .claude/agents/hve-rpi-validator.md .claude/agents/hve-implementation-validator.md` prints 0 for both files
- drift suite exits 0 with the `dispatch_async` row passing

Steps:
- [ ] Step 2.1: Add the **Dispatch is asynchronous.** paragraph to CLAUDE.md's `Subagent Dispatch Discipline` section, after the "Shell stays in the parent" paragraph (:202), per details 2.1. It covers background dispatch, F04 (check the output path before re-dispatching), the definition of a complete artifact, and the implementor case (resume from the changes log, never blind re-dispatch).
  - Assumption: every dispatching command reads this section because each opens with "Read and follow all HVE conventions in CLAUDE.md" [MEDIUM: checked for hve-research.md, hve-pr-review.md, hve-plan.md; not enumerated for all nine]
- [ ] Step 2.2: Add one row to `CANONICAL_BLOCK_SPECS` in `tests/run-drift-tests.sh` after the `shell_stays_in_parent` row (:576): `'dispatch_async|1|identical|**Dispatch is asynchronous.**'`. The pointer sentences in Steps 2.3 and 2.4 deliberately omit the bold form with its period so the count stays 1.
- [ ] Step 2.3: Replace `Wait for all subagents to complete.` at `.claude/commands/hve-research.md:77` with the pointer sentence in details 2.3.
- [ ] Step 2.4: In `.claude/commands/hve-pr-review.md`: replace :147 with the same pointer sentence; reword the **Blocked reviewers** paragraph (:149-153) per details 2.4; and extend the Coverage rule (:164) per details 2.4 so a reviewer verified complete from its output file counts as covered.
- [ ] Step 2.5: Replace `### RV-001 [CRITICAL]` at `.claude/agents/hve-rpi-validator.md:83` with `### RV-001 [SEVERITY]` and add the grading line from details 2.5 under the template's `## Findings` heading. Apply the same class of fix to `.claude/agents/hve-implementation-validator.md:120` and :123 per details 2.5. Pattern follows `.claude/agents/hve-pr-reviewer.md:94`.
- [ ] Step 2.6 (guard): drift suite as in Step 1.9, log `drift-p2.log`.

### Phase 3: PR-review diff correctness (F08, F09, F11) and review file list
Dependencies: Phase 2 (shares `.claude/commands/hve-pr-review.md`; also shares `.claude/commands/hve-review.md` with Phase 1)
Estimated scope: `.claude/commands/hve-pr-review.md` (frontmatter :3, argument parsing :11-13, Phase 1 steps :30-36, review template :47-55; about 35 lines), `.claude/commands/hve-review.md` (:83, :95), `.claude/agents/hve-rpi-validator.md` (:23 input description), `.claude/prompts/pull-request.md` (1 bullet), `README.md` (:134 row, one example line near :184)
Success criteria:
- Step 3.1 prototype passes all five checks
- Step 3.9 post-edit run (recipe extracted from the edited file) passes the same checks
- `grep -c -- "--working-tree" .claude/commands/hve-pr-review.md` prints at least 2 (argument-hint and argument parsing)
- `grep -c "exclude).claude-hve-tracking" .claude/commands/hve-pr-review.md` prints at least 4
- `grep -c "^Scope:" .claude/commands/hve-pr-review.md` prints 1
- drift suite exits 0

Steps:
- [ ] Step 3.1 (guard, run first): prototype the recipe from details 3.1 in a scratch git repo under `$TMPDIR`, under bash, invoked from a subdirectory. Fixture: `main` with one commit; a branch with one further commit; one modified tracked file; one staged file; one untracked file in a subdirectory; one untracked binary file; one untracked file whose name contains a newline; a tracked file and an untracked file under `.claude-hve-tracking/`. Checks: (1) `git ls-files --stage` identical before and after; (2) the patch contains the untracked file's content, the staged change once, the unstaged change once, and the branch commit's change once; (3) `grep -c "claude-hve-tracking"` on the patch prints 0; (4) the tracking list names the untracked tracking file and not `diff.patch`; (5) the commit list shows the branch commit. If any check fails, stop and record the failure.
  - Assumption: the recipe is correct only when run from the repository root; from a subdirectory without the `cd`, the patch lands in the wrong folder and includes itself [HIGH: both behaviours observed in the planning-time prototype, see planning log]
- [ ] Step 3.2: Add `[--working-tree]` to the `argument-hint` at `.claude/commands/hve-pr-review.md:3`, and add the working-tree paragraph to argument parsing after the friction-capture line (:13), per details 3.2.
- [ ] Step 3.3: Restructure Phase 1 steps 2 to 5 (:30-36) per details 3.3 into: a root-pin line; a mode line that sets BASE and the file-set commands; then the four steps written once using those variables. Branch mode keeps today's `main...HEAD` semantics with the tracking-folder exclusion added (F11). Working-tree mode diffs the merge-base against the working tree and adds untracked files (F09), so it covers committed branch work plus uncommitted and untracked work.
  - Assumption: "everything not yet on main" is the right meaning for the flag; the alternative (uncommitted work only, against `HEAD`) is recorded as an open choice for Kevin in DD-012's resolution [LOW: a design call, not derivable from research]
- [ ] Step 3.4: Insert the security-floor step for the excluded folder before the empty-diff guard, per details 3.4: build the tracking-folder file list for the active mode (including untracked files in working-tree mode, excluding `diff.patch`), run the Secret exposure grep and the credential-filename check over it, and carry hits to the security reviewer.
  - Assumption: excluding tracking artifacts from the code diff without this step would remove them from security coverage, which the "floor, not a filter" rule forbids [HIGH: CLAUDE.md `Security Hygiene` section]
- [ ] Step 3.5: Rewrite the **Empty-diff guard** paragraph (:32) per details 3.5 with three outcomes: only tracking artifacts changed (report that, report the scan result, stop without dispatching); nothing changed in working-tree mode (stop: nothing to review); nothing on the branch diff in branch mode but uncommitted work exists (ask, unless `--working-tree` was passed, in which case the mode already covers it) (F08).
- [ ] Step 3.6: Add a `Scope:` line to the review log template after `Base:` (:51) and make `Base:` and `Commits:` mode-aware, per details 3.6.
- [ ] Step 3.7: In `.claude/commands/hve-review.md`, extend the changed-file instruction at :83 and the dispatch input at :95 per details 3.7: when the base is `HEAD`, append untracked files outside the tracking folder, dropping any the parent can see predate the task. Update the input description at `.claude/agents/hve-rpi-validator.md:23` to match.
  - Assumption: untracked files outside the tracking folder that postdate the task's start belong to the change [MEDIUM: stray drafts exist in this repo's root, hence the drop clause]
- [ ] Step 3.8: Document the flag per details 3.8: a bullet in `.claude/prompts/pull-request.md` after :32 (colon, not an em-dash), a clause in the `/hve-pr-review` row at `README.md:134`, and one example line after `README.md:184`. Do not add it to the CLAUDE.md Command Reference row (DD-004).
  - Assumption: drift Test 13 requires every flag a prompt documents to exist in its command, so adding the flag to both passes [MEDIUM: from the validator's reading of tests/run-drift-tests.sh:931-934, not run]
- [ ] Step 3.9 (guard): extract the fenced bash block that follows the working-tree mode line from the edited `.claude/commands/hve-pr-review.md`, run it against the Step 3.1 fixture, and repeat the five checks. Then run the drift suite, log `drift-p3.log`.

### Phase 4: Global-install correctness (instruction paths, ignore rule)
Dependencies: Phase 3 (shares `README.md`; also shares `CLAUDE.md` with Phase 2)
Estimated scope: `CLAUDE.md` (Instructions Reference, 2 sentences; tracking policy block, 1 rule line and 1 count word at :382), `.claude/commands/hve-implement.md:42`, `.claude/agents/hve-phase-implementor.md:31`, `install.sh` (:240, :266), `README.md` (:42-44, :238-239), `docs/installation.md` (:24-26, :85-86, :157, :187-188), `tests/run-install-tests.sh` (test1, test2, test5), `tests/run-prompt-new-install.sh` (:91-93, :147), `tests/run-prompt-upgrade.sh` (only if Step 4.6 finds a copy)
Success criteria:
- after `./install.sh "$TMPDIR/scratch"` on a fresh `git init` directory, `git -C "$TMPDIR/scratch" check-ignore -q .claude-hve-tracking/reviews/pr/x/diff.patch; echo $?` prints 0
- `grep -c "~/.claude/instructions/" CLAUDE.md` prints at least 2; the same on `.claude/commands/hve-implement.md` and `.claude/agents/hve-phase-implementor.md` prints at least 1 each
- `grep -c "these two rules" CLAUDE.md` prints 0
- install suite exits 0 with more assertions than the baseline; drift suite exits 0

Steps:
- [ ] Step 4.1: Add the install-location rule to CLAUDE.md's `Instructions Reference` section per details 4.1: one sentence above the table and a rewritten fallback sentence (:286).
  - Assumption: drift Test 8 extracts only `.claude/instructions/NAME.md` paths, so a directory-only mention of `~/.claude/instructions/` adds no table row [MEDIUM: regex read at tests/run-drift-tests.sh:466; the suite run is the check]
- [ ] Step 4.2: Add the resolution clause to the two primary carriers, `.claude/commands/hve-implement.md:42` and `.claude/agents/hve-phase-implementor.md:31`, per details 4.2.
  - Assumption: the eleven other carriers (listed in details 4.2) need no edit because CLAUDE.md is in context for every command and agent; seven of them carry no explicit pointer to the section [LOW: accepted risk; the language-specific lookups that produced the seven recorded misses all go through the two primary carriers]
- [ ] Step 4.3: Add `add_ignore '.claude-hve-tracking/reviews/pr/**/diff.patch'` after `install.sh:240`, and the matching `echo` line after `install.sh:266` in the global printout.
- [ ] Step 4.4: Add the rule to every documented copy. Literal copies: CLAUDE.md tracking policy block (after :376), `README.md` (after :239), `docs/installation.md` (after :86, in the sentence at :157, after :188). Prose copies (paste-to-install prompts): `README.md:42-44`, `docs/installation.md:24-26`, `tests/run-prompt-new-install.sh:91-93`; reword each per details 4.4. Change "these two rules" at `CLAUDE.md:382` to "these rules".
- [ ] Step 4.5: Add assertions: `tests/run-install-tests.sh` test1 and test2 (beside the subagents assertions at :183 and :226); test5, an `assert_output_contains` for the new printed line (beside :404); `tests/run-prompt-new-install.sh` (beside :147).
- [ ] Step 4.6 (guard): enumerate carriers with two patterns and paste both outputs into the changes log: `grep -rn '\*\*/subagents/' . --include='*.md' --include='*.sh' --include='.gitignore' | grep -v '^./.claude-hve-tracking'` (planning-time result, 11 hits: `.gitignore:3`, `install.sh:239`, `install.sh:265`, `CLAUDE.md:375`, `README.md:238`, `tests/run-install-tests.sh:183`, `:226`, `tests/run-prompt-new-install.sh:147`, `docs/installation.md:85`, `:157`, `:187`) and `grep -rn 'subagents and sandbox' . --include='*.md' --include='*.sh' | grep -v '^./.claude-hve-tracking'` (planning-time result, 3 hits: `README.md:43`, `docs/installation.md:25`, `tests/run-prompt-new-install.sh:92`). Every hit must have the `diff.patch` rule beside it or a stated reason.
- [ ] Step 4.7 (guard): run the scratch-install check from the success criteria; then `bash tests/run-install-tests.sh > "$TMPDIR/install-p4.log" 2>&1; echo "rc=$?"` and the drift suite (log `drift-p4.log`). Record rc and counts for both.

### Phase 5: Shipped examples and tracking-tree note
Dependencies: Phase 4 (shares `CLAUDE.md`)
Estimated scope: `CLAUDE.md` (hooks example :321-335; note after the tracking tree's closing fence), `docs/reference.md` (note after :33)
Success criteria:
- `grep -c "CLAUDE_TOOL_INPUT_FILE_PATH" CLAUDE.md` prints 0
- Step 5.2 run appends one correctly formed line with today's local date
- `grep -c "gh-sync/" CLAUDE.md` prints 1 and `grep -c "gh-sync/" docs/reference.md` prints 1
- drift suite exits 0

Steps:
- [ ] Step 5.1: Replace the hook command at `CLAUDE.md:330` with the stdin-reading form in details 5.1 (local date via `strflocaltime`), and add the one-line note that hooks receive JSON on stdin and the example needs `jq`.
  - Assumption: `tool_input.file_path` on stdin and `$CLAUDE_PROJECT_DIR` are the documented hook contract [MEDIUM: official docs as read 2026-10-10; a live hook run would require editing settings, which is out of scope]
- [ ] Step 5.2 (guard): save the edited JSON block to `$TMPDIR/hooktest/block.json`; `mkdir -p "$TMPDIR/hooktest/.claude-hve-tracking/changes"`; `CMD=$(jq -r '.hooks.PostToolUse[0].hooks[0].command' "$TMPDIR/hooktest/block.json")`; `cd "$TMPDIR/hooktest" && echo '{"tool_input":{"file_path":"/tmp/example.md"}}' | CLAUDE_PROJECT_DIR="$PWD" sh -c "$CMD"; echo "rc=$?"`; `cat .claude-hve-tracking/changes/auto-log.md`. Paste the output. If the block does not parse or the line is malformed, fix the command before continuing.
- [ ] Step 5.3: Add the reserved-names note under the tracking tree in CLAUDE.md and under the copy in `docs/reference.md` per details 5.3 (Decision D1: no dependency on either companion tool).
- [ ] Step 5.4 (guard): drift suite, log `drift-p5.log`.

### Phase 6: Full verification
Dependencies: Phase 5
Estimated scope: no file edits unless a suite fails
Success criteria: both suites exit 0; counts recorded with rc and log path; every success criterion above re-run and pasted.

Steps:
- [ ] Step 6.1: Run both suites unpiped, logging to files, and record rc, counts, and log paths. Baselines: drift 250 passed, 0 failed; install 69 passed, 0 failed (commands and rc values in Testing Approach). Expected drift count 253 [MEDIUM: derived by the plan validator from the test source, the Test 10 row adding 2 and the new prompt flag adding 1 in Test 13; not run]. Record the measured figure whatever it is; a different count with rc=0 is a note, not a failure.
- [ ] Step 6.2: Re-run each phase's success-criteria commands and paste the outputs into the changes log.
- [ ] Step 6.3: Run the Security Hygiene secret-exposure grep over the changed files and record the result.
- [ ] Step 6.4: Record these follow-ons for Kevin as notes, not actions: `./install.sh --global` must be re-run after merge for `~/.claude` to pick up the fixes; existing project installs get the ignore rule only on re-install, where it lands at the end of `.gitignore`; a `diff.patch` already committed in a consumer repo stays tracked until `git rm --cached`; the paste-to-update prompt has no `.gitignore` step, so paste upgraders must add the rule by hand.

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| Sanctioning shell in research invites writes or long-running commands in a read-only phase | Medium | Steps 1.1 and 1.2 name the allowed command classes, bound the pass, forbid writes, installs, and network, and require the commands on the Method line |
| The working-tree diff recipe mutates the index, misses files, or runs from the wrong directory | Medium | Step 3.1 prototypes it before text ships; Step 3.9 re-runs the shipped text; the recipe pins to the repo root and never stages |
| `--working-tree` semantics (merge-base, not `HEAD`) are not what Kevin wants | Medium | Flagged at the plan checkpoint; changing it is a one-line change to the BASE definition in details 3.3 |
| Excluding the tracking folder from PR review hides a pasted secret or credential file | Low | Step 3.4 scans content and filenames for the active mode's full tracking file set, before the guard |
| A missed carrier leaves two copies of a rule disagreeing | Medium | Guard Steps 1.8 and 4.6 enumerate by grep with two patterns and require the output in the changes log |
| CLAUDE.md grows while a plan to shrink it is pending | Certain, small | About 10 lines; DD-005 tells the lean-restructure plan to re-derive its line bound |
| Hook example still wrong after the rewrite | Low | Step 5.2 executes the shipped command against sample stdin; the live hook contract stays [MEDIUM] |
| Phases share files | Certain | Dependencies chain 1 to 6 is explicit and the header requires `--mode standard` |
| A non-interactive caller cannot answer the Bash prompt in research | Medium | Step 1.1's third branch (targeted Read, "no parent shell" on the Method line) keeps the phase runnable; full non-interactive support is Bundle B |

## Testing Approach

No product code changes; the tests are the two shell suites plus the guard steps.

Baselines, measured by the parent on 2026-10-10 on commit 01c0e85 (the shipped files are unchanged at ba369fd, which adds tracking artifacts only):
- `bash tests/run-drift-tests.sh 2>&1 | tail -6` printed `Results: 250 passed, 0 failed`. The rc was not captured for this run because of the pipe; treat the exit code as unmeasured.
- `bash tests/run-install-tests.sh > <scratchpad>/install-tests.log 2>&1; echo "install tests rc=$?"` printed `install tests rc=0`, and the log ends `Results: 69 passed, 0 failed`.

Every phase ends with a drift run; Phase 4 also runs the install suite; Phase 6 runs both and re-checks every criterion. Behavioural claims that cannot be tested in-session (live hook delivery, subagent tool restoration, `allowed-tools` semantics) are marked [MEDIUM] at their steps and are not asserted as outcomes.
