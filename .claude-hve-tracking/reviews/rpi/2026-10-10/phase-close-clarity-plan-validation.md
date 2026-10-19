# Plan Validation: phase-close-clarity (refreshed plan)
Date: 2026-10-10
Validator: hve-plan-validator (read-only; Read and Grep only, no shell)
Plan: .claude-hve-tracking/plans/2026-08-19/phase-close-clarity-plan.md
Details: .claude-hve-tracking/details/2026-08-19/phase-close-clarity-details.md
Planning log: .claude-hve-tracking/plans/logs/2026-08-19/phase-close-clarity-log.md
Research: .claude-hve-tracking/research/2026-08-19/project-communication-phase-close.md (Thread B only)
Sequencing context: .claude-hve-tracking/research/2026-10-10/cross-repo-process-review.md:99-126
Tree read: the worktree this file lives in (stated BASE 0661d62; the commit itself was not confirmed, no shell)

Verdict: Fail. 0 Critical, 1 Major, 15 Minor.

The one Major (DD-009) is a contradiction inside the close contract that an implementor cannot resolve
without asking. Everything else is Minor. The refresh itself is sound: every citation I read resolves, the
counts I could re-derive match, and the HiVE justifications are annotated.

Note on where the entries live: the parent told this run not to edit the planning log, so the DR-/DD-
entries below are written here in the log's format, numbered to continue the log (DR-005 on, DD-009 on),
ready to be appended by the parent.

## What was and was not verified

Verified by reading the shipped files in this worktree: 55 line citations (table below), the corner count
(18 lines in 9 files), the box-row pipe count (3 lines), the stop-line count (12 lines in 8 files), the
absence of any `Completion Summary` or `Handoff Block Format` pointer under `.claude/`, the Step 1.3
negative grep (re-run with the four alternatives over `.claude`, README.md, docs, CONTRIBUTING.md: no
matches), the test-14 counting logic, and that nothing under `tests/` or in install.sh contains "handoff".

Not verified, taken from the log as recorded: the gate baselines (drift 253/0, install 72/0), every
`git diff --stat` figure, the claims about the tree at e78e21c, the old-to-new line mapping, the terminal
banner lines in the two semi-manual scripts, and install.sh:171.

## Check 1: research coverage (Thread B)

| Research item | Covered by | Result |
|---|---|---|
| B1 inventory of all 15 closes (research:79-82) | Phases 2, 3, 4; details:138-148 | covered |
| B1 mismatched corner defect (research:84) | Step 2.1 note; details:150-156; log Correction 6 | covered |
| B1 carrier choice, test 10 and 14 (research:85) | Steps 1.1, 2.6, 3.5, 4.8, 6.2; DD-003 | covered |
| B1 three reference lines (research:86) | Steps 5.1, 5.2, 5.3 | covered |
| B2 Item A, 18 entries (research:90-108) | Phases 1 to 4, Step 6.2, Step 1.3 | covered for files; integration points not addressed, see DR-006 |
| B2 Item B (research:110-118) | Step 1.4, Phases 2, 3, 5 | covered |
| B3 root cause, Fix 2 plus Fix 1 as belt and braces (research:122-125) | D2, DD-002, Step 1.7 | covered |
| B4 fixed keys, field-name divergence, status (research:130-139) | Steps 1.4 to 1.6, DR-002, DR-003, Step 2.5 | covered; status semantics incomplete, see DD-009, DD-010 |
| B5 Lean turns clause and converse guard (research:143-144) | Steps 1.2, 1.3 | covered |
| Open question 4, scope 15 vs 8 (research:179) | D1, DD-001 | resolved |
| Open question 5, live run (research:180) | Step 6.3, DR-004, O4 | open by design |
| Open question 6, four-way verdict (research:181) | Step 2.4, DD-007 | three of four outcomes mapped, see DR-005 |
| Open question 7, sequencing (research:182) | D3, DD-006, plan:36-40 | resolved |
| Follow-on: decide the carrier (research:189) | DD-003 | resolved |

## Check 2: citation spot-check

55 citations read at the cited line. 54 show the text the step quotes or describes. One does not (plan:153).

| Citation | Used at | Line shows | Result |
|---|---|---|---|
| CLAUDE.md:19 | Step 1.3 | principle 5, Lean turns | ok |
| CLAUDE.md:218 | Step 1.1 | `## Handoff Block Format` | ok |
| CLAUDE.md:220-232 | Step 1.4 | emission sentence :220, box :223-229, orchestrator sentence :232 | ok |
| CLAUDE.md:229 | details:152 | bottom edge ending in the double-line corner | ok |
| CLAUDE.md:232 | Step 4.1 | "The `/hve` orchestrator omits this block" | ok |
| CLAUDE.md:58, :150, :263 | Step 5.6 | "find the handoff file", "handoff artifacts", "phase handoffs" | ok |
| CLAUDE.md:80-102 | Step 5.5 | tree diagram | ok |
| tests/run-drift-tests.sh:962 | Step 1.1, details:129 | `readonly REFERENCE_PATTERN=` | ok |
| tests/run-drift-tests.sh:968 | Step 1.1, details:128 | `claude_md_headings() {` | ok |
| tests/run-drift-tests.sh:571 | Step 6.2 | `readonly -a CANONICAL_BLOCK_SPECS=(` | ok |
| hve-research.md:40 | Step 2.7 | "emit the Handoff Block, and stop" | ok |
| hve-research.md:135 | Step 2.7 | "5. The Handoff Block (below)" | ok |
| hve-research.md:141-154 | Step 2.1 | heading :141, closing fence :154 | ok |
| hve-research.md:153 | Step 2.1 | bottom edge with the mismatched corner | ok |
| hve-plan.md:13 | Step 5.6 | "Ignore any pasted handoff-block text" | ok |
| hve-plan.md:153, :157 | Step 2.7 | the approval wait; "emit the Handoff Block" | ok |
| hve-plan.md:161-174 | Step 2.2 | heading :161, closing fence :174 | ok |
| hve-plan.md:173 | Step 2.1 note | mismatched corner | ok |
| hve-implement.md:19 | Step 5.6 | "Ignore any pasted handoff-block text" | ok |
| hve-implement.md:164 | Step 2.7 | the acknowledgment wait | ok |
| hve-implement.md:168-181 | Step 2.3 | heading :168, closing fence :181 | ok |
| hve-implement.md:180 | Step 2.1 note | mismatched corner | ok |
| hve-review.md:19 | Step 5.6 | "Ignore any pasted handoff-block text" | ok |
| hve-review.md:153-155 | Step 2.4, details:105-112 | the three verdicts | ok |
| hve-review.md:152-155 | Step 2.5 (plan:153), log:27 | "Determine overall status" and the verdicts. The routing list is :157-160 | does NOT show the routing the step describes |
| hve-review.md:161 | Step 2.5 | the Complete-only gate | ok |
| hve-review.md:165-175 | Step 2.4 | heading with "(on Complete status)", fence :175 | ok |
| hve-review.md:172 | details:98-99 | `Status   : ✅ Complete`, no bare pipe | ok |
| hve-pr-review.md:17 | Step 5.6 | "pasted handoff blocks" | ok |
| hve-pr-review.md:44-46 | Steps 1.9, 3.1 | three empty-diff exits | ok |
| hve-pr-review.md:212, :213 | Step 3.1 | `Coverage:` line; verdict with covered-set suffix | ok |
| hve-pr-review.md:216-224 | Step 3.1 | fence, `PR REVIEW COMPLETE` :218, fence | ok |
| hve-pr-review.md:221-222 | Steps 1.4, 3.1, details:86-87 | `Verdict` and `Critical` rows with bare pipes | ok |
| hve-doc-ops.md:107-114, :112 | Steps 3.2, 1.4 | `DOC-OPS COMPLETE` box; `Findings` row with bare pipes | ok |
| hve-memory.md:93-101 | Step 3.3 | `MEMORY SAVED` box | ok |
| hve-prompt-builder.md:92-100 | Step 3.4 | `PROMPT BUILDER COMPLETE` box | ok |
| hve.md:133-143 | Step 4.1 | fenced `RPI Complete` block | ok |
| hve.md:141-142 | Steps 1.4, 4.1 | `Status` and `Critical` lines with bare pipes | ok |
| hve.md:145-155 | Step 4.1 | routing sentence :145, Follow-On heading :147, last line :155 | ok |
| hve-challenge.md:95-102 | Step 4.2 | `## Output` and the per-exchange reminder | ok |
| hve-prompt-analyze.md:85 | Steps 1.4, 4.3 | `Overall:` line with a bare pipe | ok |
| hve-prompt-analyze.md:88-90 | Step 4.3 | "If no issues" and the offer line | ok |
| hve-git-commit.md:56-60 | Step 4.4 | `## Step 5` with two directives (:58 report, :60 offer); the step says "one prose directive" | ok, wording nit |
| hve-git-merge.md:62-69 | Step 4.5 | `## Step 4` completion, "No automatic push" :69 | ok |
| hve-git-setup.md:71-77 | Step 4.6 | `## Critical Constraints` to end of file | ok |
| hve-prompt-refactor.md:50, :64 | Steps 5.2, 4.7 | "Handoff Block for phase commands"; "7. Report what was changed" | ok |
| hve-prompt-updater.md:55 | Step 5.1 | "Handoff Block present at the end (for phase commands)" | ok |
| .claude/prompts/rpi.md:23 | Step 5.3 | "previous session's Handoff Block" | ok |
| docs/internals.md:9, docs/workflow.md:134 | Step 5.4 | "handoff block format"; "handoff block at the end of each phase command" | ok |
| docs/reference.md:10-32, docs/workflow.md:17-33, docs/internals.md:40, .claude/instructions/terraform.md:13 | Step 5.5 | tree diagrams only | ok |

Counts re-derived by Grep: close-box corners 18 lines in 9 files (matches plan:248); box rows with a bare
pipe 3 (matches plan:91-92); case-sensitive `\bstop\b` 12 lines in 8 files (matches plan:119); pointers to
either new section under `.claude/` 0 (matches log:291). Expected drift count: test 14 emits one pass for
"pointers present" and one per distinct pointer (tests/run-drift-tests.sh:1001-1015), so two new distinct
pointers give 253 + 2 = 255, as plan:338-344 says. No `CANONICAL_BLOCK_SPECS` row
(tests/run-drift-tests.sh:572-586) pins the HANDOFF box.

## Check 6: carrier completeness

Every close-box corner hit is in one of the nine files the plan converts. Every "handoff" hit under
`.claude`, CLAUDE.md, README.md and docs is covered by a step or a recorded exclusion except CLAUDE.md:3
and CLAUDE.md:76 (DD-018). README.md has no hit. One carrier was found that neither grep term reaches:
hve.md:44 (DD-014).

## Check 7: HiVE and hve-orchestrator

Pass. The only two justifying sentences are annotated in place (plan:20-22, details:116-119) and explained
in log Correction 7 (log:233-235). No step reads, writes or references either project. The research
document's own B4 heading and summary still justify by HiVE without annotation (research:12, :127), which
is outside this plan set and is noted only for whoever next touches that artifact.

## Discrepancies

### DD-009: Approval-gate status contradicts once-per-command emission
Source: Step 1.2 (plan:65-68) and details:12 say the close is emitted once per command, at close. Step 2.2
(plan:138-141) says hve-plan's status is `awaiting-approval` before approval and `done` after. Step 2.7
(plan:162-165, added 2026-10-10) says "Keep the gate; the close emitted before approval carries
`status: awaiting-approval`". The shipped gates say the opposite of emitting before approval:
hve-plan.md:153 and hve-implement.md:164 both read "Wait ... before emitting the Handoff Block".
Step 2.3 (plan:142-143) gives hve-implement no status at all, while details:114-115 says it emits
`awaiting-approval` at its acknowledgment gate.
Assumption: that an implementor will know whether the pre-approval turn carries the labeled block.
Risk: two valid readings give two different contracts. Reading A keeps the gate literally, so nothing is
emitted until approval and `awaiting-approval` is never emitted (a dead enum value, and a waiting seat is
invisible to a non-human caller, which is cross-repo open question 2 at cross-repo-process-review.md:131).
Reading B emits the close twice, which breaks Step 1.2's "once" rule that the plan says must bind. The four
most-used commands would ship one or the other by accident.
Severity: Major
Recommendation: decide it in Phase 1 and state it in the CLAUDE.md section. Either (a) the close is emitted
at the gate turn with `awaiting-approval` and a second, short close with `done` follows approval, written
as a named exception to "once"; or (b) one close only, after approval, and `awaiting-approval` is removed
from hve-plan and hve-implement. Then reword Step 2.7 so "keep the gate" says what the gate now waits for,
and give Step 2.3 its status values, including the `Needs Review` outcome at hve-implement.md:152.
Status: Open

### DR-005: Research open question 6 named four outcomes; the plan maps three
Source: research:181 asks to verify the "four-way verdict (Complete / Needs Rework / Blocked / plan-absent
stop)" before freezing field values. The plan-absent stop is real: hve-review.md:32.
Gap: Step 2.4 (plan:146-149), details:103-112 and DD-007 (log:112-116) call the question resolved and the
mapping "1:1 and total" on the three verdicts alone. The fourth outcome is reached only through Step 1.9,
which is conditional on O1, and log:346-347 says of Step 1.9 "nothing else depends on it".
Severity: Minor (becomes Major if O1 is answered no, because hve-review's hard stop would then emit no status)
Recommendation: record under O1 that research question 6's fourth outcome depends on it, and reword
Step 2.4's claim to "total over the three verdicts; the plan-absent stop is governed by Step 1.9".
Status: Open

### DR-006: Research B2 Item A integration points are not addressed
Source: research:93-105 lists the existing "present to the user" sections as where the summary goes
(for example hve-research.md:127-136, hve-implement.md:157-164, hve-pr-review.md:174-181 as then numbered).
Gap: the plan replaces only the box sections. It does not say how the three headers relate to the response
lists that sit just above them and stay in place: hve-research.md:130-135, hve-implement.md:157-162,
hve-pr-review.md:209-214, hve-doc-ops.md:102-105, hve-memory.md:88-91. Only Steps 3.3 and 4.1 say what
moves into a header. Appending the summary below an unchanged findings list produces the "second findings
report" Step 1.2 names as the failure mode.
Severity: Minor
Recommendation: one sentence per Phase 2 and 3 step, or one rule in Step 1.1, saying whether the existing
list is kept above the headers or folded into `**What I did**`.
Status: Open

### DD-010: `status:` is a required key with no stated value for most commands
Source: details:58 makes `status` required. Steps 2.3, 3.2, 3.3, 3.4 and 4.1 to 4.7 (plan:142-143,
plan:190-195, plan:205-236) name `artifact:` and sometimes `next:` but never `status:`. O2 covers
hve-pr-review only.
Assumption: that `done` is the default and that hve.md maps like hve-review. Neither is written down; no
marker.
Risk: uneven values across files. hve.md also has four artifact paths (hve.md:136-139) and the step does
not say which one is `artifact:`.
Severity: Minor
Recommendation: add to details:56-67 "status is `done` unless the step says otherwise", and name hve.md's
`artifact:` and its verdict mapping in Step 4.1.
Status: Open

### DD-011: Step 1.9's recommended wording marks every early stop `blocked`
Source: plan:114-123.
Assumption: every early stop is a blocked state. The [MEDIUM] marker covers the count, not this.
Risk: several stops are clean outcomes: "nothing to review" at hve-pr-review.md:45-46, the user ending a
session at hve-challenge.md:89, and `--audit-only` at hve-git-setup.md:67. A caller reading `blocked` would
treat a no-op as needing intervention. The supporting count is also off in both directions: the grep is
case-sensitive, so it misses hve-git-setup.md:67 ("Stop after presenting the audit table"), and three of
its twelve lines are the `--conflict-stop` flag name (hve-git-merge.md:3, :18, :58).
Severity: Minor
Recommendation: put the distinction in front of the owner with O1: `blocked` when the command could not do
its job, `done` when it finished with nothing to do.
Status: Open

### DD-012: Owner decision O3 is framed as one line; it is six
Source: plan:95-99, plan:224-227, details:93-95, log:351 ("it is one line").
Assumption: hve-prompt-analyze.md:85 is the only bare-pipe line in that report template.
Risk: hve-prompt-analyze.md:79-83 are five consecutive lines with bare pipes in the same fenced template
(`Clarity: ✅ Pass | ❌ Fail` through `No Copilot-isms: ✅ | ❌`), a stronger table shape than :85 alone. An
owner answering O3 on the stated scope approves less than the fix needs.
Severity: Minor
Recommendation: restate O3 as lines 79-83 and 85, and add them to Step 4.3.
Status: Open

### DD-013: Step 4.3 offers an artifact that cannot exist
Source: plan:222-223, "`artifact:` the analyzed file path or the report path".
Assumption: hve-prompt-analyze writes a report file.
Risk: its frontmatter is `allowed-tools: Read, Glob` (hve-prompt-analyze.md:4); the report is chat output.
"The report path" is an unfillable blank per CLAUDE.md's `Template Blanks` section.
Severity: Minor
Recommendation: drop "or the report path"; use the analyzed file path.
Status: Open

### DD-014: hve.md has a second close path the plan does not name
Source: hve.md:44, the Simple direct path: "Report the changes-log path in the completion summary."
Assumption: Step 4.1's reconciliation of hve.md:133-143 covers every way `/hve` ends.
Risk: on the direct path there is no research, plan or review artifact, so the `RPI Complete` field set
cannot be filled, and the sentence already uses the term this plan turns into a defined section name. The
same sentence carries the phrase pinned by the `simple_carveout_guarantee` row
(tests/run-drift-tests.sh:584), so an edit there must keep that phrase intact.
Severity: Minor
Recommendation: add a note to Step 4.1: the direct path closes with `artifact:` the changes log, and the
pinned phrase is not to be reworded.
Status: Open

### DD-015: The bare-pipe regression guard has no command
Source: risk row plan:321 and DD-004 (log:72-73) both say "Step 5.5 greps for the regression".
Assumption: Step 5.5 checks for `|` in templates.
Risk: Step 5.5 as corrected (plan:260-268) runs the corner-only command. The Phase 5 criterion "zero bare
`|` in any close template" (plan:247-248) has no command and "close template" is not defined, so the
criterion cannot fail. This is the bug class the plan exists to remove.
Severity: Minor
Recommendation: give Step 5.5 a second command, for example a grep for ` | ` over the lines of each new
close section, and list which templates count.
Status: Open

### DD-016: Line citations were replaced in place rather than annotated
Source: CLAUDE.md's `Corrections in Tracking Artifacts` section asks for an in-place marker plus a dated
entry. The dated entry exists (log:211-217) and the plan header discloses the method (plan:9-12).
Assumption: a consolidated entry is enough for line moves.
Risk: about eleven citations now read as if they were always the new numbers, with no marker at the line:
plan:61-62 (:968 and :962, inside a sentence that says the parent verified them "during planning"),
plan:133-135, plan:174-175, plan:215. Others carry only "at the BASE". Two log entries still hold stale
figures with no marker: DD-003 at log:63 (:959, :965) and DR-001 at log:9-11 (255 and 69 as "the plan's
baseline"). DD-004 was marked, so the treatment is uneven.
Severity: Minor
Recommendation: mark log:63 and log:9-11 in place, and add "at the BASE" to the unmarked plan citations so
each one is traceable to Correction 1.
Status: Open

### DD-017: The rename option is unreachable and three lines disagree about it
Source: Step 1.4 (plan:83-85) allows a rename "only if Step 5.1's reference sweep is done in the same
phase"; Step 2.6 (plan:156) allows for a renamed heading; Step 5.6 (plan:273) states the name is kept.
Assumption: that existing pointers constrain the choice.
Risk: Step 1.4 is Phase 1 and Step 5.1 is Phase 5, so the condition can never hold. No pointer to
`Handoff Block Format` exists under `.claude/` (log:291, confirmed by Grep), so "existing pointers keep
resolving" (plan:84-85), the risk row at plan:323 and DD-005 (log:78) describe pointers that are not there.
Severity: Minor
Recommendation: state once that the heading is kept, and remove the conditional from Steps 1.4 and 2.6.
Status: Open

### DD-018: Two generic "handoff" lines are missing from the recorded exclusions
Source: Step 5.6 (plan:269-275) and the carrier table (log:321) list CLAUDE.md:58, :150, :263.
Assumption: the list is complete for CLAUDE.md.
Risk: none in behavior. CLAUDE.md:3 ("file-based handoff artifacts") and CLAUDE.md:76 ("handoff medium")
match the log's own `grep -rniE 'handoff'` and are not listed, so the enumeration is not what it says.
Severity: Minor
Recommendation: add both lines to Step 5.6 as generic uses.
Status: Open

### DD-019: Small stale or inexact statements with no marker
Source and evidence, one line each:
- plan:5 says Thread A "runs second"; the approved sequence puts it last (cross-repo-process-review.md:108),
  which Step 6.5 already annotates.
- log:240-241 (Correction 10) says the Status line now names the BASE and the new validation result;
  plan:6 names neither (the BASE is on plan:7, validation is pending).
- plan:153 and log:27 cite the routing at hve-review.md:152-155; the routing list is :157-160. The citation
  table notes this (log:184) but marks the row "unchanged" and nothing corrects the step.
- plan:228 calls hve-git-commit.md:56-60 "one prose directive"; it is two (:58 and :60).
Risk: none to execution.
Severity: Minor
Status: Open

### DD-020: A risk mitigation has no step behind it
Source: plan:319, "Kevin reviews one converted command before Phases 3 and 4 fan out".
Assumption: someone pauses after Phase 2.
Risk: Phases 3 and 4 depend only on Phase 1 (plan:168, plan:199), so a parallel or unattended implement run
starts them alongside Phase 2, and the only render check is Step 6.3 at the very end. Related: Phase 4's
criterion "all 15 command files contain a completion-summary section" (plan:201) depends on Phases 2 and 3,
which Phase 4 does not list.
Severity: Minor
Recommendation: either add a checkpoint step at the end of Phase 2 and make Phases 3 and 4 depend on it, or
delete the sentence from the risk row. Scope Phase 4's criterion to its seven files.
Status: Open

### DD-021: The `What I did` content rule has a blank some commands cannot fill
Source: details:35 and Step 1.1 (plan:56-57): outcomes lead "with the step or finding ID and a file path".
Assumption: every command has step IDs, finding IDs or files.
Risk: hve-git-setup, hve-git-commit, hve-git-merge, hve-memory and hve-challenge have no step or finding
IDs, and git-setup touches no file. Only the test line has an N/A branch (details:36-37).
Severity: Minor
Recommendation: add "when the command has them" to the rule in Step 1.1.
Status: Open

### DD-022: Factual assertions in steps without a confidence marker
Source: Step 2.2 (hve-plan pauses at Phase 4), Step 2.5 (the Complete-only gate), Step 3.2 (the `Findings`
row has bare pipes), Step 4.1 main text, Step 4.2 (the reminder fires per question), Step 4.6 (no close at
all), Step 4.7; and in the added material, the first paragraph of Step 2.7 (plan:157-161), the recommended
wording of Step 1.9 (plan:114-118) and the risk row at plan:324.
Assumption: these are true. All of them are; I read each cited line.
Risk: convention only.
Severity: Minor
Recommendation: mark them [HIGH].
Status: Open

## Checks that passed without findings

- Baselines: the five places in the plan that carried 255 and 69 are each annotated (plan:49, :113, :280,
  :288, :331), matching log Correction 3.
- Status enum: the four values agree across details:62, Step 2.4, Step 1.9 and the O2 recommendation.
- Phase dependencies are acyclic and Phase 5 and 6 list everything they need.
- Added Steps 2.7 and 5.6 do not contradict an existing step other than as recorded in DD-009.
- Owner decisions O1 to O4 are each named at the step they affect (plan:114, :186, :224, :302).
- Nothing in the read files addressed instructions to the reader; no embedded-directive finding.

## Remaining validation not done here

- Confirm by `git rev-parse` that the BASE is still 0661d62 and how it relates to the local branch head the
  session reports (f69dd41).
- Re-run both suites if the BASE moved; the 253 and 72 figures were not re-measured by this run.
- Confirm the tree at e78e21c matches the "as written" column of the citation table (log:165-204).
- Confirm the terminal-banner exclusions in the two semi-manual test scripts (log:323).
- Grep the tracked root markdown files other than README.md and CLAUDE.md for the box, if any are in scope.
