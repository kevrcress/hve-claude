# Changes Log: Phase-Ending Clarity (Thread B), one uniform close for all 15 commands
Date: 2026-10-10
Plan: .claude-hve-tracking/plans/2026-08-19/phase-close-clarity-plan.md
Details: .claude-hve-tracking/details/2026-08-19/phase-close-clarity-details.md
Status: Needs Review
Mode: `--mode lightweight` (named by the brief). The implementing seat wrote the changes itself; no phase-implementor subagent was dispatched.
Base: `origin/wip/pcc-plan-refresh` @ 43e7ef9f460c9819a42260c3215a8a865abd34af, with 06f31ae8f71d84787bd457b462be087967eb0092 (head of draft PR #6) merged in as Step 0. Merge commit d421bce, no conflicts.
Delivery ref: `wip/pcc-impl`

## Run conditions

- Orchestrated run, non-interactive caller. Every "wait for user acknowledgment" in `/hve-implement` was skipped: the seat's brief says the caller is non-interactive and tells it to continue to delivery. Skipped waits: the Phase 3 acknowledgment gate, and the plan's Risk Log mitigation "Kevin reviews one converted command before Phases 3 and 4 fan out".
- Owner decisions O1 to O5: the seat's brief states that the owner approved the plan on 2026-10-10 with O1 to O5 answered as recommended, and this implementation follows those five answers. See DR-001 below: the seat could not write that approval into the plan file, so the plan on disk still reads "awaiting user approval".

## Test Baseline

Measured after Step 0, before any edit, from the worktree root:

- `./tests/run-drift-tests.sh`: 253 passed, 0 failed, rc=0
- `./tests/run-install-tests.sh`: 72 passed, 0 failed, rc=0
- Already-failing tests: none
- NOT RUN: `tests/run-prompt-new-install.sh`, `tests/run-prompt-upgrade.sh` (semi-manual, a human pastes a prompt into Claude Code)

## Discrepancies & Decisions (run level)

- DR-001: the brief's Step 1 (record the owner's approval in the plan header, append `## Requirements added after plan refresh (2026-10-10)`, annotate each open O-note as resolved) was NOT done. The session's permission system refused the write, because the approval reached this seat through a brief file and not from the owner directly. The plan file is byte-identical to the base. Consequence: CLAUDE.md's `Mid-Flow Scope Changes` section is not yet satisfied for O1 to O5, and a later phase command reading the plan will see them as open. The owner or the orchestrator needs to add that record.
- DD-001 (2026-10-10): proceed with the implementation on the brief's statement of O1 to O5, on a `wip/` ref only, and report DR-001 as the first finding. Rationale: the work is reversible and unmerged, and the five answers are all the plan's own recommended options.
- DD-002 (2026-10-10): no line that already holds an em-dash was edited. Where the plan asked to extend such a line (CLAUDE.md principle 5, `hve.md` Simple direct path), the new text went on a new line next to it. Rationale: the brief's acceptance check A9 rejects any added line with an em-dash, and an edited line counts as added.

## Phases

### Phase 1: Define both canonical formats in CLAUDE.md
Status: Complete
Started: 2026-10-11T02:11:33Z
Completed: 2026-10-11T02:12:30Z

#### Files Modified
- `CLAUDE.md:20` - new continuation line under principle 5 (Lean turns) exempting the stopping turn (Step 1.3)
- `CLAUDE.md:219-253` - new `## Completion Summary` section: three headers, content rules, the concise rule, the once-per-stopping-turn rule, the early-stop rule (Steps 1.1, 1.2, 1.9)
- `CLAUDE.md:257-279` - `## Handoff Block Format` body rewritten: labeled-line template, three required keys, four status values in prose, no-artifact branch, optional keys, fence rule, no-pipes rule (Steps 1.4 to 1.7)

#### Steps Completed
- [x] Step 1.1: `## Completion Summary` added immediately before `## Handoff Block Format`
- [x] Step 1.2: converse guard written as "once per stopping turn" (O5), with the "second findings report" failure mode named
- [x] Step 1.3: Lean-turns exemption added as a continuation line of principle 5 (DD-002)
- [x] Step 1.4: section body rewritten; heading text kept, so existing pointers resolve; status enum is in prose, the template shows one value; default `done` written in (O2)
- [x] Step 1.5: `artifact: none - <reason>` branch specified
- [x] Step 1.6: optional-keys rule specified
- [x] Step 1.7: fenced-code-block emission rule stated
- [x] Step 1.8: drift suite run, counts below
- [x] Step 1.9: early-stop rule centralized: `blocked` when the stop needs something first, `done` for a clean stop (O1)

Tests: drift 253 passed, 0 failed, rc=0; install 72 passed, 0 failed, rc=0 (unchanged, as the plan expects: Phase 1 adds no pointer under `.claude/`)

#### Success criteria, run
- `grep -n '^## Completion Summary\|^## Handoff Block Format' CLAUDE.md` returns `219:## Completion Summary` and `257:## Handoff Block Format`
- `grep -nE '[╭╮╰╯╝]' CLAUDE.md` returns nothing: the section holds no close-box corner

#### Discrepancies & Decisions
- DD-003 (2026-10-10): the template spells the keys `status: done` with no column padding. The details file's sample pads the colon (`status  : done`). Rationale: one spelling for every key, including optional keys of any length, is what a fixed-key reader needs; padding would make the spelling depend on the longest key.
- DD-004 (2026-10-10): O5's "stopping turn" needed a boundary, or every turn that asks a question would carry a close. CLAUDE.md now names three stopping turns (normal end, an approval gate the command's file marks as a close point, an early stop) and says a working question is not one. This keeps Step 4.2 (the per-question `/hve-challenge` reminder is not a close) and the `/hve` exemption consistent with O5.
- DD-005 (2026-10-10): the exemption sentence for `/hve` was rewritten from "omits this block" to "emits no close between phases and one close at its end", which is the reading Step 4.1's [MEDIUM] note asked to be confirmed.
- DD-006 (2026-10-10): one sentence added that a pasted labeled-line block is handoff-block text, so the unchanged "Ignore any pasted handoff-block text" sentences in four commands still name something (Step 5.6's confirm-at-implement-time note).

---

### Phase 2: Convert the four true-HANDOFF commands
Status: Complete
Started: 2026-10-11T02:13:18Z
Completed: 2026-10-11T02:13:43Z

#### Files Modified
- `.claude/commands/hve-research.md:40` - "emit the Handoff Block" becomes "emit the close (see Close below)" (Step 2.7)
- `.claude/commands/hve-research.md:135` - list item 5 names the close (Step 2.7)
- `.claude/commands/hve-research.md:141-149` - `## Handoff Block` box replaced by `## Close` (Steps 2.1, 2.6)
- `.claude/commands/hve-plan.md:153` - the gate sentence now emits the close with `status: awaiting-approval`, then waits (Steps 2.2, 2.7, O5)
- `.claude/commands/hve-plan.md:157` - after approval, emit the close again with `status: done` (Steps 2.2, 2.7)
- `.claude/commands/hve-plan.md:161-171` - box replaced by `## Close`, with the optional `details:` key (Steps 2.2, 2.6)
- `.claude/commands/hve-implement.md:164` - the acknowledgment gate emits the close with `status: awaiting-approval`, waits, then emits it again with `status: done` (Steps 2.3, 2.7, O5)
- `.claude/commands/hve-implement.md:168-178` - box replaced by `## Close`, with the optional `plan:` key (Steps 2.3, 2.6)
- `.claude/commands/hve-review.md:161` - step 5 emits the close on every verdict (Step 2.5)
- `.claude/commands/hve-review.md:165-175` - `## Handoff Block (on Complete status)` box replaced by `## Close` with the verdict-to-status mapping (Steps 2.4, 2.6, 2.7)

#### Steps Completed
- [x] Step 2.1: hve-research converted; the mismatched closing corner is gone by deletion
- [x] Step 2.2: hve-plan converted; the text says which status applies when
- [x] Step 2.3: hve-implement converted; it now names both statuses (the plan named none)
- [x] Step 2.4: hve-review converted; Complete maps to `done`, Needs Rework to `needs-rework`, Blocked to `blocked`
- [x] Step 2.5: the Complete-only gate is removed; `next:` varies by verdict
- [x] Step 2.6: both section pointers added to each of the four files
- [x] Step 2.7: every sentence that named the old block outside the replaced section is rewritten

Tests: drift 255 passed, 0 failed, rc=0; install 72 passed, 0 failed, rc=0. Drift rose by 2, intended: test 14 prints one pass per distinct section pointer under `.claude/`, and the two new passes are `'Completion Summary' resolves` and `'Handoff Block Format' resolves`.

#### Success criteria, run
- `grep -nE '[╭╮╰╯╝│─]' .claude/commands/hve-{research,plan,implement,review}.md | wc -l` returns 0
- pointer lines: hve-research.md:143, hve-plan.md:163, hve-implement.md:170, hve-review.md:167, each carrying both pointers
- `grep -n 'Handoff Block\|handoff'` over the four files leaves only the two pointer lines and the unchanged argument-parsing sentence "Ignore any pasted handoff-block text" (hve-plan.md:13, hve-implement.md:19, hve-review.md:19), a recorded exclusion in Step 5.6

#### Discrepancies & Decisions
- DR-002: the hve-review hard stop for a missing plan or changes log (hve-review.md:32) and the hve-implement cold start (hve-implement.md:31) got no per-path text. They fall under the centralized early-stop rule in CLAUDE.md, as Step 1.9 intends.
- DD-007 (2026-10-10): the headings in these four files changed from `## Handoff Block` to `## Close`, so no command tells the reader to emit a block that no longer exists (Step 2.7). The CLAUDE.md heading keeps its name.
- DD-008 (2026-10-10): hve-review gained an optional `findings:` key and hve-research and hve-implement gained one sentence each saying the presentation list is the content of the summary headers, not a second report before it. Rationale: without it the old "present a summary" steps and the new close would be emitted back to back, which the concise rule forbids.
- Re-anchored after Step 0: none of these four files moved. The one sentence of hve-review.md that the merge reworded is at hve-review.md:67 and is not a close sentence.

---

### Phase 3: Convert the four sibling-box commands
Status: Complete
Started: 2026-10-11T02:13:59Z
Completed: 2026-10-11T02:14:20Z

#### Files Modified
- `.claude/commands/hve-pr-review.md:219-230` - `PR REVIEW COMPLETE` box replaced by the close paragraph, the verdict-to-status mapping, `verdict:` and `findings:` (Steps 3.1, 3.5, O2)
- `.claude/commands/hve-doc-ops.md:107-112` - `DOC-OPS COMPLETE` box replaced (Steps 3.2, 3.5)
- `.claude/commands/hve-memory.md:93-97` - `MEMORY SAVED` box replaced; the resume instruction goes under **Next step** (Steps 3.3, 3.5)
- `.claude/commands/hve-prompt-builder.md:92-98` - `PROMPT BUILDER COMPLETE` box replaced; `sandbox:` and `iterations:` are optional keys (Steps 3.4, 3.5)

#### Steps Completed
- [x] Step 3.1: hve-pr-review converted. Approve maps to `done`, Request Changes to `needs-rework`, Block to `blocked`. The verdict text with its covered-set suffix is carried in `verdict:`, the counts in `findings:` with commas. The `Coverage:` line stays in the presented review
- [x] Step 3.2: hve-doc-ops converted; the bare-pipe `Findings` row is gone
- [x] Step 3.3: hve-memory converted
- [x] Step 3.4: hve-prompt-builder converted
- [x] Step 3.5: both section pointers added to each of the four files

Tests: drift 255 passed, 0 failed, rc=0; install 72 passed, 0 failed, rc=0

#### Success criteria, run
- `grep -cE '[╭╮╰╯╝│─]'` over the four files returns 0 for each

#### Discrepancies & Decisions
- Re-anchored after Step 0 (the brief's note): the plan cites the hve-pr-review box at :216-224 and its bare-pipe rows at :221-222. After the merge they were at :219-227 and :224-225. The `Coverage:` and verdict presentation lines the plan cites at :212 and :213 were at :215 and :216. Every edit was anchored on the quoted text.
- DR-003: the three early exits of hve-pr-review (hve-pr-review.md:44-46) got no per-path text; the centralized rule covers them (clean stop, `done`).
- DD-009 (2026-10-10): `verdict:` is an optional key in the format but hve-pr-review always emits it, and the file says never to drop the suffix. Rationale: Step 3.1 note (a), a partial verdict must not read as a whole-change verdict.
- DD-010 (2026-10-10): no new heading in these four files. The close paragraph sits at the end of the existing final phase section, where the box was.

---

### Phase 4: Give the remaining seven commands a close
Status: Complete
Started: 2026-10-11T02:15:09Z
Completed: 2026-10-11T02:15:12Z

#### Files Modified
- `.claude/commands/hve.md:48` - new line: the Simple direct path ends with the same close (Step 4.1, finding DD-014)
- `.claude/commands/hve.md:129-145 at the base` - `## Completion` with the `RPI Complete` block removed (Step 4.1)
- `.claude/commands/hve.md:143-156` - `## Close` added after `Discover`, so the close is last (Steps 4.1, 4.8)
- `.claude/commands/hve-challenge.md:104-108` - session-end close after the per-question reminder (Steps 4.2, 4.8)
- `.claude/commands/hve-prompt-analyze.md:65` - the allowed values of the Quality Summary lines, in prose (Step 4.3, O3)
- `.claude/commands/hve-prompt-analyze.md:79-85` - six bare-pipe template lines now carry one value each (Step 4.3, O3)
- `.claude/commands/hve-prompt-analyze.md:92-96` - close added (Steps 4.3, 4.8)
- `.claude/commands/hve-git-commit.md:62-67` - close added to Step 5 (Steps 4.4, 4.8)
- `.claude/commands/hve-git-merge.md:71-75` - close added to Step 4 (Steps 4.5, 4.8)
- `.claude/commands/hve-git-setup.md:79-87` - new `## Completion` section (Steps 4.6, 4.8)
- `.claude/commands/hve-prompt-refactor.md:72-78` - new `## Close` section (Steps 4.7, 4.8)

#### Steps Completed
- [x] Step 4.1: hve reconciled to the canonical keys. `artifact:` is the review log; `research:`, `plan:`, `changes:` and `findings:` are optional keys; the two bare-pipe lines are gone; the routing sentence moved into `next:` and **Next step**; follow-on items go under **What I need from you**; the Simple direct path points at the same close
- [x] Step 4.2: hve-challenge has a session-end close; the per-question reminder is unchanged and is stated not to be a close
- [x] Step 4.3: hve-prompt-analyze has a close; `artifact:` is the analyzed file path; all six bare-pipe lines fixed
- [x] Step 4.4: hve-git-commit has a close, with the no-artifact branch and a prose `next:`
- [x] Step 4.5: hve-git-merge has a close
- [x] Step 4.6: hve-git-setup has a `## Completion` section
- [x] Step 4.7: hve-prompt-refactor has a close
- [x] Step 4.8: both section pointers added to each of the seven files

Tests: drift 255 passed, 0 failed, rc=0; install 72 passed, 0 failed, rc=0

#### Success criteria, run
- All 15 command files carry the pointer line, one each: hve-challenge.md:104, hve-doc-ops.md:107, hve-git-commit.md:62, hve-git-merge.md:71, hve-git-setup.md:83, hve-implement.md:170, hve-memory.md:93, hve-plan.md:163, hve-pr-review.md:219, hve-prompt-analyze.md:92, hve-prompt-builder.md:92, hve-prompt-refactor.md:74, hve-research.md:143, hve-review.md:167, hve.md:145
- The four previously unstructured commands (hve-git-setup, hve-git-commit, hve-git-merge, hve-prompt-refactor) each carry one

#### Discrepancies & Decisions
- DD-011 (2026-10-10): hve.md:44 was not edited. It holds an em-dash and the drift-pinned phrase "still creating and updating the changes log and running the test gate", and it already says "completion summary". The pointer to the close went on a new line at hve.md:48 (DD-002).
- DD-012 (2026-10-10): the `## Completion` section of hve.md was removed and a `## Close` section was added after `Discover`, instead of moving `Discover` up. Same result as the plan's "move the block to the end", and the `Discover` lines stay byte-identical.
- DD-013 (2026-10-10): in the hve-prompt-analyze report template, four lines that read as a bare mark pair now read `✅ Pass` or `❌ Fail`, the wording the Clarity line already used. This is a small change to that command's chat report, made so each line can show one concrete value.
- DD-014 (2026-10-10): the three git commands' `artifact:` reasons each name their own command (`none - /hve-git-commit writes no tracking artifact`) instead of the plan's shared sample (`none - git commands write no tracking artifact`). Rationale: a shared reason line under `status: done` would have been the same two-line block in three files, which Step 6.2 says needs a drift row.

---

### Phase 5: Reference sanity pass
Status: Complete
Started: 2026-10-11T02:15:25Z
Completed: 2026-10-11T02:15:29Z

#### Files Modified
- `.claude/agents/hve-prompt-updater.md:55` - checklist line names the close and carries both pointers (Step 5.1)
- `.claude/commands/hve-prompt-refactor.md:50` - convention checklist line, same update (Step 5.2; edited with Phase 4's commit)
- `.claude/prompts/rpi.md:23` - "from the `artifact:` line of the previous session's close block" (Step 5.3)
- `docs/internals.md:9` - "completion summary and handoff block format" (Step 5.4)
- `docs/workflow.md:134-136` - the FAQ answer describes the close and names the CLAUDE.md section, no line number (Step 5.4)

#### Steps Completed
- [x] Step 5.1: hve-prompt-updater.md updated
- [x] Step 5.2: hve-prompt-refactor.md checklist updated
- [x] Step 5.3: rpi.md updated
- [x] Step 5.4: both docs lines updated, anchored to section names
- [x] Step 5.5: corner-only command run, 0 hits; bare-pipe command run and found unable to match, see the Correction in Phase 6
- [x] Step 5.6: recorded exclusions left as written; CLAUDE.md now says a pasted labeled-line block is handoff-block text (DD-006)

Tests: drift 255 passed, 0 failed, rc=0; install 72 passed, 0 failed, rc=0

#### Success criteria, run
- `grep -rnE '[╭╮╰╯╝]' .claude CLAUDE.md README.md CONTRIBUTING.md docs | wc -l` returns 0. Control: the same command over an export of the base tree returns 18 lines in 9 files, the figure the plan recorded.
- Carriers outside the commands, `grep -rniE 'handoff|completion summary|the close\b' README.md docs CONTRIBUTING.md .claude/agents .claude/prompts .claude/instructions tests install.sh`: four hits, docs/internals.md:9, docs/workflow.md:135, .claude/agents/hve-prompt-updater.md:55, .claude/prompts/rpi.md:23. All four were updated by Steps 5.1, 5.3 and 5.4. README.md, CONTRIBUTING.md, `.claude/instructions/`, `tests/` and `install.sh` have none, at the base or now.

---

### Phase 6: Verify and propagate
Status: In Progress
Started: 2026-10-11T02:15:29Z
Completed: N/A - Steps 6.3 and 6.4 are owner actions and are NOT RUN

#### Files Modified
- `.claude-hve-tracking/plans/2026-08-19/phase-close-clarity-plan.md` - Step 5.5's bare-pipe command annotated as superseded (Corrections rule). No other line of the plan changed.

#### Steps Completed
- [x] Step 6.1: both suites run, counts below
- [x] Step 6.2: no new test-10 row needed. A script compared every pair of consecutive non-blank lines across the 15 command files with the same files at the base: 9 pairs are shared by two or more files now, and 0 of them are new in this change. `tests/run-drift-tests.sh` is unchanged
- [ ] Step 6.3: NOT RUN. The live render check needs an interactive session; the owner runs it before merge (O4)
- [ ] Step 6.4: NOT RUN. `./install.sh --global` is an owner action after merge (O4)
- [x] Step 6.5: nothing further to change. README.md and docs/ showed no close box at the base

Tests: drift 255 passed, 0 failed, rc=0 (baseline 253; plus 2, the two new test-14 section pointers); install 72 passed, 0 failed, rc=0 (baseline 72)
NOT RUN: `tests/run-prompt-new-install.sh`, `tests/run-prompt-upgrade.sh`

#### Every phase's success criteria, re-run at the end
- Phase 1: `## Completion Summary` at CLAUDE.md:219 and `## Handoff Block Format` at CLAUDE.md:257, each heading present once; the three headers are defined once (`**What I did**` at line start appears only at CLAUDE.md:224) and the template once (`status: done` at line start appears only at CLAUDE.md:262)
- Phases 2 and 3: 0 box-drawing characters in the eight converted command files
- Phase 4: 15 of 15 command files carry the pointer line
- Phase 5: corner-only command returns 0; control at the base returns 18
- Box-drawing characters of any kind, per file, base then now: CLAUDE.md 30 then 23 (the 7 removed are the close box; the directory tree is untouched), docs/internals.md 4 and 4, docs/reference.md 23 and 23, docs/workflow.md 11 and 11, .claude/instructions/terraform.md 5 and 5, tests/run-prompt-new-install.sh 10 and 10, tests/run-prompt-upgrade.sh 9 and 9. The eight command files went from 6 to 10 each to 0
- `git diff -U0` against the base shows hunks in CLAUDE.md at lines 20 and 219-279 only, in docs/internals.md at line 9 only, in docs/workflow.md at lines 134-136 only, and none in docs/reference.md, .claude/instructions/terraform.md or tests/
- Keys: every `status:`, `artifact:` and `next:` value line in the 15 command files is a bullet holding one backticked `key: value` pair; the only fenced template is CLAUDE.md:262-264. One spelling (lowercase key, colon, one space). `status` values in use: `done`, `awaiting-approval`, `blocked`, `needs-rework`, and no other
- No sentence still says to wait before emitting the Handoff Block: `grep -rniE 'handoff block|before emitting|once per command|emitted once|only on complete|on Complete status|omits this block' CLAUDE.md .claude README.md CONTRIBUTING.md docs` returns only the CLAUDE.md heading and the lines that point at it
- No line added by this change contains an em-dash; no `tools:` or `allowed-tools:` line changed

#### Issues Encountered
- A stray `git stash --keep-index` was run by mistake in the seat's worktree during Phase 3. It created one stash entry labeled with this branch. The entry was verified identical to the working tree and dropped; it was the only entry in the stash list. No work was lost and the main checkout was not touched.
- `git grep -E` with a box-drawing character class gave false positives (564 lines at the base for the corner check). The checks above were re-run with plain `grep` over an export of the base tree, which reproduces the plan's 18.

#### Discrepancies & Decisions
- DR-004: bare pipes remain in templates that are written to disk, not emitted as a close or a chat report: hve-review.md:70-72 (review log header), hve-pr-review.md:83, :86, :95, :96 (PR review log header), hve-implement.md:56 (changes log phase status), hve-doc-ops.md:34 and :41 (session log), hve-memory.md:52, hve-plan.md:70, hve-prompt-analyze.md:69. No plan step names them and they were not changed. Two of them are read by a companion tool (the changes log `Status:` field), so they should not change without that tool.
- DD-015 (2026-10-10): overall status is Needs Review, not Complete, because DR-001 is open and Phase 6 has two owner steps left.

#### Corrections
- Correction (2026-10-10): the plan's Step 5.5 says to run `grep -rnE '^(status|artifact|next|[a-z]+) *:.*\|' .claude/commands CLAUDE.md` and read each hit, and calls the pattern over-matching. It under-matches: it returns 0 lines at the base too, although the base holds the bare-pipe lines the plan itself names (hve.md:141-142, hve-prompt-analyze.md:79-85), because those keys start with a capital letter or hold a space. The check that was run instead is `grep -rnE '^[A-Za-z -]+ *:.*\|' .claude/commands CLAUDE.md`, read hit by hit. At the base it lists the eight lines above among its hits; now it lists none of them, and what remains is the three `argument-hint` and flag lines plus the on-disk templates in DR-004. The plan step is annotated in place.

---

## Security Hygiene Check

- Secret exposure: the pattern grep over the 20 changed files outside the tracking folder hits one line, CLAUDE.md:347, which is the checklist's own description of the patterns. No secret.
- .gitignore hygiene: `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx` are all listed.
- Committed secrets: no credential-like file name among the changed files.
- New dependencies: none.

## Final Test Pass

- `./tests/run-drift-tests.sh`: 255 passed, 0 failed, rc=0
- `./tests/run-install-tests.sh`: 72 passed, 0 failed, rc=0
- NOT RUN: `tests/run-prompt-new-install.sh`, `tests/run-prompt-upgrade.sh`, plan Step 6.3 (live render check), plan Step 6.4 (`./install.sh --global`)

## Review Fixes (grader review, 2026-10-10)

Base: `origin/wip/pcc-impl` @ 6e4daeb9cf935e01cde08d3e0e57621a25159e15. One fix pass over the grader review at `.claude-hve-tracking/reviews/rpi/2026-10-10/phase-close-clarity-grader-review.md` (commit 9b1e1e7, a byte-for-byte copy, not edited). Fixed here: IV-001 (Major), IV-002 and IV-004 (Minor). Not fixed, by instruction: IV-003, IV-005, IV-006, IV-007, IV-008. Fix commit: 17227d1. No HVE phase command ran; the seat brief was the plan and this section is hand-written.

Files modified: `CLAUDE.md` (4 lines, all inside `## Completion Summary` and `## Handoff Block Format`), `.claude/commands/hve-pr-review.md` (the Empty-diff guard and the Phase 4 close). No other command file was edited. Line numbers below are at commit 17227d1; `CLAUDE.md` numbering is unchanged from the base, and `hve-pr-review.md` lines after :46 moved down by 2.

### IV-001 (Major): `done` no longer reads as approved

1a. `CLAUDE.md:251`, the early-stop rule.
- Before: "... and `status: done` for a clean stop (nothing to do, an audit-only run, the user declined or asked to stop). When nothing was written, use the no-artifact branch from the `Handoff Block Format` section. This rule lives here once; ..."
- After: "... and `status: done` for a clean stop (nothing to do, an audit-only run, the user stopped the command or declined a confirmation outside an approval gate). A decline or a request for changes at an approval gate is not a clean stop and never produces `done`: the gate is still open, so the close keeps `status: awaiting-approval` until the user approves. [IV-002 sentence, below] This rule lives here once; ..."

1b. `CLAUDE.md:269`, the `status` definition.
- Before: "`done` (normal end or clean stop), ... `needs-rework` (a review verdict sent the work back). A command that reaches its normal end emits `done` unless ..."
- After: "`done` (the command finished, at its normal end or by a clean stop), ... `needs-rework` (a review verdict sent the work back). `done` says only that the command finished: it does not say the work passed or was approved, and a reader that needs the outcome reads `verdict` where a command emits one. A command that reaches its normal end emits `done` unless ..."
- The other three values and their meanings are unchanged. `done` is defined in this one place; `CLAUDE.md:251` uses it and does not redefine it.

1c. `.claude/commands/hve-pr-review.md`, empty-diff stops.
- `:48` added after the guard's three bullets: "Every stop under this guard ends with the close in its no-review form (see **Empty-diff guard stops** in Phase 4): no reviewer ran, no review log was written, and no verdict exists."
- `:221` before: "`status` follows the Phase 3 verdict, one value per run:". After: "On a run that reached Phase 3, `status` follows the Phase 3 verdict, one value per run (a run stopped by the Empty-diff guard has no verdict and uses **Empty-diff guard stops** below):"
- `:229` the `verdict:` description, before: "... and no suffix on a `--dimension all` run)". After: "... and no suffix on a `--dimension all` run; on an Empty-diff guard stop no verdict exists and the line is `verdict: none - no review ran`)"
- `:232` one sentence added after the never-drop-the-suffix rule: "The one value that carries no suffix on a filtered run is `verdict: none - no review ran`: no dimension ran, so there is no covered set to state."
- `:234-240` new paragraph **Empty-diff guard stops**: each of the three guard outcomes that stops emits `artifact: none - nothing to review, no review log written` (`:236`), `next: none - nothing to review`, or `next: /hve-pr-review --working-tree` when the guard reported work outside the tracking folder (`:237`), and `verdict: none - no review ran` (`:238`). `:240` says `status` comes from the central early-stop rule (a clean stop, so `done`, which says only that the command finished) and that `findings:` is omitted.
- O2 mapping, before (base `:221-223`) and after (`:223-225`), text identical: `status: done` when the verdict is ✅ Approve; `status: needs-rework` when the verdict is ⚠️ Request Changes; `status: blocked` when the verdict is 🚫 Block. The covered-set suffix rule is intact.

### IV-002 (Minor): listed values are normal-end values

`CLAUDE.md:251`, one sentence, replacing "When nothing was written, use the no-artifact branch from the `Handoff Block Format` section.":
"The `status`, `artifact` and `next` values a command file lists are its normal-end values: on an early stop this rule sets `status`, the no-artifact branch from the `Handoff Block Format` section applies when nothing was written, `next` names what unblocks or resumes the run (the end-of-chain form when nothing does), and an optional key is emitted only when its value exists."
None of the 14 per-command close paragraphs was rewritten.

### IV-004 (Minor): two definitions widened

- `CLAUDE.md:270` before: "`artifact` is the path of the primary tracking artifact the command wrote or updated. When there is none, ...". After: "`artifact` is the path of the primary file the command wrote or updated: its tracking artifact, or, when its deliverable is another file in the workspace, that file. A command that writes nothing but evaluates one file names that file. When there is none, ..."
- `CLAUDE.md:271` before: "`next` is the next slash command when one applies, and short prose when the next action is not a slash command (example: `next: git push when ready`)." After: "`next` is the next slash command when one applies, alone or followed by its argument or a short phrase saying when or why (example: `next: /hve-pr-review after the findings are fixed`), short prose when the next action is not a slash command (example: `next: git push when ready`), and `next: none - <reason>` at the end of a chain, when no next action applies (example: `next: none - task complete`)."
- The brief asked for one clause per definition. Each got two, because one clause would have left existing commands outside the definition (A5): `/hve-prompt-builder` and `/hve-prompt-refactor` name a file that is not a tracking artifact, and three commands write a slash command followed by a phrase.

### A1 enumeration: approval gates and confirmations, all 15 command files

Approval gates, meaning points the command's own file marks as a close point (`CLAUDE.md:250`). There are two.

| Gate | At the gate | On approval | On a decline | On a request for changes |
|---|---|---|---|---|
| `hve-plan.md:153` (Phase 4 checkpoint; values at `:165-166`) | `awaiting-approval` | `done` (`:157`, `:166`) | `awaiting-approval` (`CLAUDE.md:251`) | `awaiting-approval` again once the revised plan is presented (`CLAUDE.md:251`) |
| `hve-implement.md:164` (Phase 3 summary; values at `:172-173`) | `awaiting-approval` | `done` (`:164`, `:173`) | `awaiting-approval` (`CLAUDE.md:251`) | `awaiting-approval` (`CLAUDE.md:251`) |

Confirmations that are not close points. Each is a working question under `CLAUDE.md:253`, so the asking turn carries no close, and a change request leads to a revised proposal and the same question again, also with no close. The table gives the status when the answer ends the command.

| Confirmation | On yes | On a decline that ends the command |
|---|---|---|
| `hve.md:42` proceed directly or run the full loop | continues | not a stop: either answer continues |
| `hve.md:78`, `:95`, `:114` checkpoints between phases | continues | `done`, a stop outside a gate; `artifact` and `next` per the early-stop sentence, and `findings:` is absent because no review ran |
| `hve-implement.md:31` implement without a plan | continues, `Plan: none` recorded | `blocked` (missing input) |
| `hve-pr-review.md:46` review the working tree or stop | re-runs the phase in working-tree mode | `done` with `artifact: none - ...` and `verdict: none - no review ran` (`:234-240`) |
| `hve-git-commit.md:26` which files to stage | continues | `done` with `artifact: none - ...`; `commit:` is absent |
| `hve-git-commit.md:45` approve the message | commits, `done` with `commit:` | `done` with `artifact: none - ...`; `commit:` is absent |
| `hve-git-merge.md:27` stash or commit first | continues after the user does so | `blocked` (failed precondition) |
| `hve-git-merge.md:58` `--conflict-stop` pause; `:81` abort | continues | `done`, the user stopped the command |
| `hve-git-setup.md:41`, `:76` confirm each config change | applies it | `done` at the normal end; declined changes are not applied |
| `hve-prompt-builder.md:85` write to the final location | writes, `done` | `done` with `artifact: none - final write declined, draft is in the sandbox` (`:95`) |
| `hve-prompt-refactor.md:62` apply the changes | applies, `done` | `done` with the no-artifact branch (nothing was written) |
| `hve-prompt-analyze.md:17` which file | continues | not a stop: the command has no file to analyze |
| `hve-challenge.md:89` the user says to stop | n/a | `done`, named in the file (`:104`) |

`hve-research.md`, `hve-review.md`, `hve-doc-ops.md` and `hve-memory.md` hold no approval question.

Result: no decline or change request at an approval gate yields `done`. Declines outside a gate still yield `done`, as the brief's item 1a specifies ("a user who stops a command outside a gate is still a clean stop"); after 1b that value claims only that the command finished, and on each of those paths the block also lacks the artifact or the optional key that an approved run carries. Whether the `/hve` checkpoints should become gates is IV-006, not in this pass.

Command sentences checked against the corrected rule: none states a status the rule contradicts. One count is loose and was left alone by instruction: `hve-plan.md:163` and `hve-implement.md:170` say the command "emits the close twice", which is the approve-first-time path; after a change request there are more than two closes. That is IV-003 (b), which predates this pass (the grader derived the same sequence from the base text).

### A4 enumeration: every early exit, against the corrected rule

Starts from the review's table (item 3). "Rule" is `CLAUDE.md:251`.

| # | Command and exit | Rule gives | Command sentence in conflict |
|---|---|---|---|
| 1 | `hve.md:42` proceed-directly question | no close (working question) | none |
| 2 | `hve.md:78` user says no after research | `done`, stop outside a gate | none; `:147-152` are normal-end values |
| 3 | `hve.md:95` user says no after the plan | `done` | none |
| 4 | `hve.md:114` user says no after implementation | `done` | none |
| 5 | `hve.md:44-48` Simple direct path | `done` (normal end of that path) | none, named in the file |
| 6 | `hve-research.md:40` Simple path | `done` (normal end) | none, named in the file |
| 7 | `hve-plan.md:155-157` user declines or asks for changes at the gate | `awaiting-approval` | none; `:166` gives `done` only after approval |
| 8 | `hve-implement.md:31` no plan | `blocked`, no-artifact branch | none |
| 9 | `hve-implement.md:31` irrelevant plan | `blocked`, no-artifact branch | none |
| 10 | `hve-implement.md:117` unresolved discrepancy | `blocked`; `artifact` is the changes log already written | none |
| 11 | `hve-implement.md:139-142` test failure surfaced | `blocked` | none |
| 12 | `hve-implement.md:164` user declines or asks for changes at the gate | `awaiting-approval` | none |
| 13 | `hve-review.md:32` plan or changes log missing | `blocked`, no-artifact branch | none; `:171` maps a verdict, not this stop |
| 14 | `hve-pr-review.md:44` only tracking artifacts changed | `done`, `artifact: none - ...`, `verdict: none - no review ran` | none after the 1c edit |
| 15 | `hve-pr-review.md:45` nothing to review, working-tree mode | same as 14 | none |
| 16 | `hve-pr-review.md:46` clean tree, branch mode | same as 14 | none |
| 17 | `hve-pr-review.md:46` user chooses stop | same as 14 | none |
| 18 | `hve-challenge.md:88-91` three end conditions | `done` | none, named in the file |
| 19 | `hve-git-commit.md:18` no `.gitignore`; `:26` staging question | no close (working questions) | none |
| 20 | `hve-git-commit.md:45` user does not approve the message | `done`, `commit:` omitted | none; `:64-67` are normal-end values |
| 21 | `hve-git-commit.md:54` commit fails | `blocked`, `commit:` omitted, `next` names the fix | none; `:64` is a normal-end value |
| 22 | `hve-git-merge.md:27` uncommitted changes | `blocked` | none; `:73` is a normal-end value |
| 23 | `hve-git-merge.md:79-83` user aborts | `done`; `next` is not `git push when ready` because nothing was merged | none; `:75` is a normal-end value |
| 24 | `hve-git-setup.md:67` audit-only | `done` | none, named in the file (`:87`) |
| 25 | `hve-prompt-builder.md:85-86` user declines the final write | `done` | none, named in the file (`:95`) |
| 26 | `hve-prompt-refactor.md:62-63` user declines the changes | `done`, no-artifact branch | none; `:77` is a normal-end value |
| 27 | `hve-prompt-analyze.md:17` no argument | no close (working question) | none |

`hve-memory.md` and `hve-doc-ops.md`: no early exit found. The review's table has 21 rows covering these 27 paths; rows that group several paths are split here, and the two gate rows (7 and 12) now give `awaiting-approval` where the review recorded `done` for row 7.

### A5 enumeration: every `artifact:` and `next:` template line

Command: `grep -n -E '`(artifact|next): ' CLAUDE.md .claude/commands/*.md`, read line by line, including the alternates inside parentheses. Classes for `artifact`: T tracking artifact, W another workspace file the command delivers, E evaluated file, N no-artifact form. Classes for `next`: S slash command alone, SA slash command plus argument or a when-or-why phrase, P prose, X end-of-chain form.

| Line | `artifact` value | Class |
|---|---|---|
| `CLAUDE.md:263` | `.claude-hve-tracking/[path/to/file.md]` | T |
| `CLAUDE.md:270` | `none - <reason>`, `none - git commands write no tracking artifact` | N |
| `hve-research.md:146`, `hve-plan.md:167`, `hve-implement.md:174`, `hve-review.md:172`, `hve-pr-review.md:226`, `hve-challenge.md:107`, `hve-doc-ops.md:110`, `hve-memory.md:96` | a path under `.claude-hve-tracking/` | T |
| `hve.md:150` | the review log, or the changes log on the Simple direct path | T |
| `hve-prompt-builder.md:95` | `[final file path]`; on a declined write `none - final write declined, draft is in the sandbox` | W; N |
| `hve-prompt-refactor.md:77` | `[refactored file path]` | W |
| `hve-prompt-analyze.md:95` | `[analyzed file path]` | E |
| `hve-git-commit.md:65`, `hve-git-merge.md:74`, `hve-git-setup.md:86` | `none - /hve-git-... writes no tracking artifact` | N |
| `hve-pr-review.md:236` | `none - nothing to review, no review log written` | N |

| Line | `next` value | Class |
|---|---|---|
| `CLAUDE.md:264` | `/hve-[next-phase]` | S |
| `CLAUDE.md:271` | the three examples | SA, P, X |
| `hve-research.md:147` | `/hve-plan` | S |
| `hve-plan.md:168` | `/hve-implement` | S |
| `hve-implement.md:175` | `/hve-review` | S |
| `hve-review.md:173`, `:174` | `/hve-pr-review`; `/hve-implement` or `/hve-plan` | S |
| `hve.md:151` | `/hve-pr-review`; Simple path `none - task complete` | S; X |
| `hve.md:152` | `/hve-implement` or `/hve-plan` | S |
| `hve-pr-review.md:227` | `merge when ready` | P |
| `hve-pr-review.md:228` | `/hve-pr-review after the findings are fixed` | SA |
| `hve-pr-review.md:237` | `none - nothing to review`; `/hve-pr-review --working-tree` | X; SA |
| `hve-challenge.md:108` | `/hve-plan`; `none - no changes needed` | S; X |
| `hve-doc-ops.md:111` | `fix the top findings, then re-run /hve-doc-ops`; `none - documentation is clean` | P; X |
| `hve-memory.md:97` | `in a new session, read the memory file and continue from its Next Steps` | P |
| `hve-git-commit.md:66`, `hve-git-merge.md:75` | `git push when ready` | P |
| `hve-git-setup.md:87` | `/hve-git-commit when there is work to commit`; `/hve-git-setup to apply the proposed changes` | SA |
| `hve-prompt-analyze.md:96` | `/hve-prompt-builder [file]`; `none - no issues found` | SA; X |
| `hve-prompt-builder.md:96` | `/hve-prompt-analyze [final file path]` | SA |
| `hve-prompt-refactor.md:78` | `/hve-prompt-analyze [file]` | SA |

Every line falls in a class the widened definitions name. No command file was edited to make it so: the only command file in the diff is `hve-pr-review.md`, and its pre-existing `artifact:` and `next:` lines are unchanged (`:236` and `:237` are new).

### Gates and scope

Run from the worktree root at commit 17227d1, each through the orchestrator's `run-quiet.sh`:

- `./tests/run-drift-tests.sh`: 255 passed, 0 failed, rc=0 (base 255; unchanged, as intended)
- `./tests/run-install-tests.sh`: 72 passed, 0 failed, rc=0 (base 72; unchanged, as intended)

Scope: the fix commit touches `CLAUDE.md` and `.claude/commands/hve-pr-review.md` only. No added line holds an em-dash or an en-dash (17 added lines scanned). No `tools:` or `allowed-tools:` line changed. `tests/`, `install.sh`, `.claude/agents/`, `docs/`, `README.md`, the plan, the details file and the planning log are untouched.

Side effect to know about: `hve-pr-review.md` now holds two `artifact:` bullets (`:226`, `:236`), where the first review's A3 counted exactly one per command.

NOT RUN: `tests/run-prompt-new-install.sh`, `tests/run-prompt-upgrade.sh`, any live command session (whether a model emits the corrected close as written is untested), `./install.sh --global`.
