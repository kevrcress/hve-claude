# Implementation Plan: Phase-Ending Clarity (Thread B)
Date: 2026-08-19
Task slug: phase-close-clarity
Research: .claude-hve-tracking/research/2026-08-19/project-communication-phase-close.md (Thread B)
Sibling plan: .claude-hve-tracking/plans/2026-08-19/project-communication-presence-plan.md (Thread A, runs second)
Status: Approved by Kevin 2026-10-10 with owner decisions O1 to O5 answered as recommended (his chat message to the orchestrator session: "approve step 2"); approval record written 2026-10-11 on his instruction "record it" - refreshed and re-validated 2026-10-10 - validation result Fail (0 Critical, 1 Major, 15 Minor; the Major is confirmed and is owner decision O5) - valid for BASE 0661d621cb4904bf38d9fff8893c2196899e7c3d
Validation: .claude-hve-tracking/reviews/rpi/2026-10-10/phase-close-clarity-plan-validation.md
Valid for: `origin/fix/platform-drift-quick-fixes` @ 0661d621cb4904bf38d9fff8893c2196899e7c3d (the BASE: head of draft PR #6, not yet merged to `main`; `main` is f96e34f0859387d0ba871bf4163e5b88159f931a)
Prior status: Validated (2026-08-19) against the tree at e78e21c (superseded, see Correction 2026-10-10 in the planning log)
Refresh: every line citation, count and baseline below was re-read at the BASE on 2026-10-10. Old values, the
per-citation table, the conflict analysis and the carrier enumeration are in the planning log under
`## Refresh (2026-10-10)`. Steps and notes marked `(added 2026-10-10)` come from that refresh. Owner decisions
O1 to O5 in that section are open and are named at the steps they affect. O5 must be answered before Phase 2
can be implemented consistently. (superseded: Kevin answered all five on 2026-10-10, see
`## Requirements added after plan refresh (2026-10-10)` at the end of this file)

## Overview

Give all 15 HVE commands one uniform close: the locked three-header completion summary
(What I did / What I need from you / Next step) followed by a fenced labeled-line block
carrying three fixed keys (status, artifact, next). The labeled-line block replaces the
box-drawing HANDOFF block and its four sibling boxes, which is both the rendering-bug fix
and the machine-readable carrier HiVE will need (superseded, see Correction 2026-10-10: the carrier is justified by HVE supporting
non-human callers, cross-repo decision D2; hve-claude takes no dependency on HiVE or hve-orchestrator,
cross-repo decision D1). Both formats are defined once in CLAUDE.md
and referenced from each command by a section pointer, so drift test 14 enforces resolution
for free and no byte-identical duplication is introduced.

## Decisions locked before planning (user, 2026-08-19)

- D1: Scope is all 15 commands, including the four that today have no structured close
  (hve-git-setup, hve-git-commit, hve-git-merge, hve-prompt-refactor).
- D2: HANDOFF fix is Fix 2 (drop box-drawing entirely for labeled lines), not Fix 1
  (mandate a fence around the existing box).
- D3: Thread B runs before the in-flight CLAUDE.md lean restructure; that restructure
  rebases onto this work.
- D4: Two separate plans, one per research thread. This is Thread B.

Note (added 2026-10-10): D1 to D4 above are this plan's own decisions. They are not the D1 to D5 recorded in
`.claude-hve-tracking/research/2026-10-10/cross-repo-process-review.md`, which this plan set calls
"cross-repo D1" to "cross-repo D5". D3 above still holds under cross-repo D5 (Path 2): the lean restructure
no longer runs as a standalone plan and is re-planned after the bundles land, so it follows this work in
either reading [HIGH]. This plan is step 2 of that document's recommended sequence.

## Phases

### Phase 1: Define both canonical formats in CLAUDE.md
Dependencies: none
Estimated scope: 1 modified file (CLAUDE.md), roughly 55 to 80 net new lines
Success criteria: CLAUDE.md contains a `## Completion Summary` heading and a rewritten
`## Handoff Block Format` section with zero box-drawing characters; `tests/run-drift-tests.sh`
still reports 255 passed, 0 failed (superseded, see Correction 2026-10-10: 253 passed, 0 failed, rc=0 at the BASE;
Phase 1 adds no pointer under `.claude/`, so the count stays 253).

Steps:
- [ ] Step 1.1: Add a new `## Completion Summary` section to CLAUDE.md, placed immediately
  before the existing `## Handoff Block Format` section (CLAUDE.md:218 at the BASE).
  Specify the three bold headers in fixed order: `**What I did**`, `**What I need from you**`,
  `**Next step**`, with the per-header content rules from the locked format (outcomes one line
  each leading with step or finding ID and a file path; one line of test evidence with
  before/after numbers obtained by execution; "Nothing blocking" stated explicitly when true;
  one concrete next command plus the realistic alternative).
  - The heading text `Completion Summary` was verified by the parent during planning to satisfy
    drift test 14: `claude_md_headings()` at tests/run-drift-tests.sh:968 extracts every
    `^##+ ` heading text, and `REFERENCE_PATTERN` at :962 is
    ``per CLAUDE\.md's \`[^\`]+\` section``. A pointer reading
    ``per CLAUDE.md's `Completion Summary` section`` therefore resolves with no test edit [HIGH]
- [ ] Step 1.2: In the same section, state the converse guard that resolves the Lean-turns
  tension (research B5): the completion summary is emitted once per command, at close, and does
  not license verbose mid-phase turns. Name the failure mode explicitly so it binds: the block
  must not grow into a second findings report.
  - Open, owner decision O5 (resolved 2026-10-10 as recommended, see "Requirements added after plan refresh (2026-10-10)" at the end of this file) (added 2026-10-10, validator finding DD-009, confirmed): "once per command"
    contradicts Step 2.2, which has hve-plan emit `awaiting-approval` before approval and `done` after,
    while hve-plan.md:153 and hve-implement.md:164 say to wait for approval BEFORE emitting anything.
    Step 2.3 names no status for hve-implement at all. Recommended: the rule becomes "once per turn in
    which the command stops and hands control back"; the two gated commands emit the close at the gate with
    `awaiting-approval` and again after approval with `done`. The alternative is one close, after approval
    only, which removes `awaiting-approval` from the enum [LOW until decided]
- [ ] Step 1.3: Append a clarifying clause to CLAUDE.md:19 (principle 5, Lean turns) exempting
  the command-close turn, so principle 5 and the new section do not read as contradictory.
  Smallest viable edit: extend the existing sentence rather than adding a paragraph.
  - Verified by the parent during planning, not inherited from research:
    `grep -rn 'Lean turns|one-line summary after subagent|Parent agents return a one-line' .claude/`
    returned no matches, so no command, agent or prompt file restates principle 5 and this is a
    CLAUDE.md-only edit [HIGH]
  - Re-checked at the BASE (added 2026-10-10): the command as written has no `-E`, so its `|` is a literal
    character and it could not have matched anything (superseded, see Correction 2026-10-10). Re-run as
    `grep -rnE 'Lean turns|one-line summary after subagent|Parent agents return a one-line|lean summar' .claude README.md docs CONTRIBUTING.md`:
    no matches, so the conclusion stands and this is still a CLAUDE.md-only edit [HIGH]
- [ ] Step 1.4: Rewrite the `## Handoff Block Format` section body (CLAUDE.md:220-232 at the BASE) to define
  the labeled-line format. Required keys, always present, always in this order: `status`,
  `artifact`, `next`. Document the status enum in prose above the template, NOT inside the
  template. Rename the section heading only if Step 5.1's reference sweep is done in the same
  phase; otherwise keep the heading text `Handoff Block Format` so existing pointers keep
  resolving.
  - Added 2026-10-10 (validator finding DD-010, confirmed): the plan states a `status:` value for only four
    commands. Recommended default, to be written into the section: a command that reaches its normal end
    emits `done`; the exceptions are the mapped verdicts (Step 2.4, and Step 3.1 under O2) and the gates
    under O5. hve.md's `artifact:` is the review log path, with the other three paths as optional keys
    [MEDIUM: a recommendation, part of O2]
  - The enum-in-prose rule exists because some current templates embed alternatives with bare
    ASCII `|` characters inside box rows. A template whose sample line contains `|` reintroduces
    exactly the table-parse class of bug this phase removes.
    Corrected 2026-08-19 (see Correction below): the offending set is exactly three lines,
    enumerated rather than sampled, via
    `grep -rn '│.*|' .claude/commands/*.md`:
    `hve-doc-ops.md:112`, `hve-pr-review.md:221`, `hve-pr-review.md:222` (lines at the BASE).
    This is an enumeration, not a grep for existence, so it is exhaustive over `.claude/commands/`
    [HIGH]
  - Scope of that enumeration (added 2026-10-10): the pattern matches box rows only. Two fenced templates
    that are not boxes also carry bare `|` between alternatives: `hve.md:141-142` (inside the `RPI Complete`
    block that Step 4.1 reconciles) and `hve-prompt-analyze.md:85` (the `Overall:` line that ends the report
    template, directly above where Step 4.3 adds the close). Steps 4.1 and 4.3 now name them; whether the
    second is in scope is owner decision O3 (resolved 2026-10-10 as recommended, see "Requirements added after plan refresh (2026-10-10)" at the end of this file) [HIGH that both lines contain bare `|`]
- [ ] Step 1.5: Specify the N/A branch for commands with no tracking artifact, per CLAUDE.md's
  `Template Blanks` section: `artifact: none - <reason>` (example:
  `artifact: none - git commands write no tracking artifact`). Without this, hve-git-commit,
  hve-git-merge and hve-git-setup have an unfillable blank.
- [ ] Step 1.6: Specify the optional-extra-keys rule: after the three required lines, a command
  may add further `key: value` lines (lowercase key, colon, value) for secondary artifacts.
  This is how hve-plan carries `details:` and hve-implement carries `plan:` without breaking a
  fixed-key parser.
- [ ] Step 1.7: State the emission rule in the section: the block is emitted inside a fenced
  code block. Retaining this instruction is cheap and is the belt-and-braces half of Fix 1, even
  though the labeled-line format no longer depends on it.
- [ ] Step 1.8: Run `tests/run-drift-tests.sh` and record the pass/fail counts. Baseline before
  any edit was 255 passed, 0 failed (run by the parent during planning, 2026-08-19)
  (superseded, see Correction 2026-10-10: the baseline at the BASE is 253 passed, 0 failed, rc=0).
- [ ] Step 1.9 (added 2026-10-10, conditional on owner decision O1 (resolved 2026-10-10 as recommended, see "Requirements added after plan refresh (2026-10-10)" at the end of this file)): state in the `## Completion Summary`
  section which turns count as a command close. Recommended wording: every terminating path of a command,
  including an early stop, ends with the close, and an early stop uses `status: blocked` with
  `artifact: none - <reason>` when nothing was written. The rule lives once in CLAUDE.md, so no per-path edit
  is needed in the command files.
  - Why: the commands contain 12 lines with a stop instruction across 8 files (`grep -nE '\bstop\b'
    .claude/commands/*.md | wc -l` at the BASE), and the step-1 change added three more early exits at
    hve-pr-review.md:44-46. A caller that reads `status:` learns nothing from a command that stopped without
    emitting one, which matters now that non-human callers are in scope (cross-repo D2) [MEDIUM: the count is
    of lines containing the word, not of distinct exit paths; the grep is case-sensitive and misses
    `Stop after presenting the audit table` at hve-git-setup.md:67]
  - Added after validation (findings DD-011 and DR-005, both confirmed): not every early stop is a failure.
    A clean stop (hve-pr-review.md:45 "nothing to review", hve-git-setup.md:67 audit-only) should emit
    `done`, and `blocked` is for a stop that needs something first, such as hve-review's hard stop at
    hve-review.md:32 when the plan or changes log is missing. That hard stop is the fourth outcome research
    open question 6 named; Step 2.4 maps the three verdicts and only this step covers the fourth, so if O1
    is answered no, hve-review needs its own line for it in Step 2.5 [HIGH that the four outcomes exist]

### Phase 2: Convert the four true-HANDOFF commands
Dependencies: Phase 1
Estimated scope: 4 modified files, roughly 20 to 30 net lines each
Success criteria: none of hve-research.md, hve-plan.md, hve-implement.md, hve-review.md
contains any of the characters in the set box-drawing corners and verticals; each carries a
resolving `per CLAUDE.md's` pointer for both new sections; drift suite still 0 failed.

Steps:
- [ ] Step 2.1: hve-research.md:141-154 - replace the Handoff Block section with the completion
  summary plus labeled-line block. `status: done`, `artifact:` the research doc path,
  `next: /hve-plan`. Removes the mismatched corner defect at hve-research.md:153 by deletion.
  - Added 2026-10-10: the same `╝` closing corner is also at hve-plan.md:173 and hve-implement.md:180, which
    Steps 2.2 and 2.3 remove the same way [HIGH]
- [ ] Step 2.2: hve-plan.md:161-174 - same conversion. `artifact:` the plan path, plus an
  optional `details:` line for the details path, `next: /hve-implement`. Note that hve-plan
  pauses for approval at Phase 4, so its status is `awaiting-approval` before approval and
  `done` after; the command text must say which value applies when.
- [ ] Step 2.3: hve-implement.md:168-181 - same conversion. `artifact:` the changes-log path,
  optional `plan:` line, `next: /hve-review`.
- [ ] Step 2.4: hve-review.md:165-175 - same conversion, and wire the status key to the existing
  verdict rather than hardcoding it.
  - The verdict-to-status mapping was verified by the parent against the command file:
    hve-review.md:153-155 defines exactly three verdicts, `✅ Complete`, `⚠️ Needs Rework`,
    `🚫 Blocked`, mapping to `done`, `needs-rework`, `blocked`. Research open question 6 is
    resolved: the mapping is 1:1 and total [HIGH]
- [ ] Step 2.5: hve-review.md:161 currently gates the block on Complete status only. Change the
  gate: the completion summary and labeled-line block are emitted on every verdict, because a
  machine-readable `status: blocked` is worthless if it is only emitted when the status is done.
  The `next:` value varies by verdict per the existing routing at hve-review.md:152-155
  (superseded, see Correction 2026-10-10: the verdicts are at :152-155; the routing list is at :157-160).
- [ ] Step 2.6: Add the two section pointers to each of the four files, phrased exactly as
  ``per CLAUDE.md's `Completion Summary` section`` and ``per CLAUDE.md's `Handoff Block Format`
  section`` (or the renamed heading if Step 1.4 renamed it, kept consistent).
- [ ] Step 2.7 (added 2026-10-10): update the sentences inside these four files that name the old block
  outside the replaced section, so no file tells the reader to emit a block that no longer exists:
  hve-research.md:40 ("emit the Handoff Block, and stop") and :135 ("The Handoff Block (below)");
  hve-plan.md:153 and :157; hve-implement.md:164; hve-review.md:161 (already Step 2.5) and the heading
  qualifier at hve-review.md:165 ("(on Complete status)"), which Step 2.5 makes false.
  - hve-plan.md:153 and hve-implement.md:164 are approval gates, not just names. Keep the gate; the close
    emitted before approval carries `status: awaiting-approval` per Step 2.2. Bundle B (step 4 of the
    recommended sequence) later revisits the hve-implement.md:164 wait for seat callers and rebases onto
    this wording [MEDIUM: Bundle B is not yet planned]

### Phase 3: Convert the four sibling-box commands
Dependencies: Phase 1
Estimated scope: 4 modified files, roughly 20 to 30 net lines each
Success criteria: no box-drawing characters remain in hve-pr-review.md, hve-doc-ops.md,
hve-memory.md, hve-prompt-builder.md; drift suite still 0 failed.

Steps:
- [ ] Step 3.1: hve-pr-review.md:216-224 - replace the `PR REVIEW COMPLETE` box. This file is
  the highest-priority conversion: its lines 221-222 carry bare ASCII `|` inside box rows
  (`Verdict  : ✅ Approve | ⚠️ Request Changes | 🚫 Block` and `Critical : N | Major: N | Minor: N`),
  which is the strongest table-parse trigger in the repo. Move the verdict alternatives into
  prose and emit one concrete value; carry counts as an optional `findings:` line.
  - Added 2026-10-10, from the step-1 change to this file (61 lines changed since the plan was written):
    (a) hve-pr-review.md:213 now requires the verdict to carry the covered-set suffix on a filtered run, so
    the emitted verdict value must keep that suffix; dropping it would let a partial verdict read as a
    whole-change verdict, which CLAUDE.md's `Security Hygiene` section forbids. (b) The `Coverage:` line at
    :212 stays in the presented review and is not folded into the labeled block. (c) Working-tree mode
    (`--working-tree`) changes what was reviewed, not the close, and needs no extra key. (d) The early exits
    at :44-46 emit no close today; Step 1.9 governs them [HIGH for a, b, d as read at the BASE; MEDIUM for c]
  - Open, owner decision O2 (resolved 2026-10-10 as recommended, see "Requirements added after plan refresh (2026-10-10)" at the end of this file): this plan never said what `status:` hve-pr-review emits. Recommended: map the
    three verdicts the way Step 2.4 maps hve-review's (Approve to `done`, Request Changes to `needs-rework`,
    Block to `blocked`) and carry the verdict text with its suffix as an optional `verdict:` line [LOW until
    decided]
- [ ] Step 3.2: hve-doc-ops.md:107-114 - replace the `DOC-OPS COMPLETE` box. Its `Findings` row
  also contains bare `|`. `artifact:` the session doc path.
- [ ] Step 3.3: hve-memory.md:93-101 - replace the `MEMORY SAVED` box. `artifact:` the memory
  file path; the resume instruction moves into the `**Next step**` header.
- [ ] Step 3.4: hve-prompt-builder.md:92-100 - replace the `PROMPT BUILDER COMPLETE` box.
  `artifact:` the final written file path; sandbox path and iteration count become optional keys.
- [ ] Step 3.5: Add both section pointers to each of the four files.

### Phase 4: Give the remaining seven commands a close
Dependencies: Phase 1
Estimated scope: 7 modified files, roughly 12 to 30 net lines each
Success criteria: all 15 command files contain a completion-summary section; the four
previously-unstructured commands each end with one.

Steps:
- [ ] Step 4.1: hve.md:133-143 - the orchestrator already closes with a fenced labeled-line
  `RPI Complete` summary, which is the style being standardised on. Reconcile it to the canonical
  key set rather than replacing it wholesale, and add the three bold headers above it. Note that
  hve.md:145-155 (`Discover - Follow-On Items`) currently comes AFTER the summary, so the summary
  is not actually last; move the block to the end or fold follow-on items into
  `**What I need from you**`.
  - Added 2026-10-10: hve.md:141-142 hold bare `|` between alternatives (`Status    : ✅ Complete | ...` and
    `Critical  : N | Major: N | Minor: N`). "Reconcile" includes applying Step 1.4's enum-in-prose rule to
    both lines, exactly as Step 3.1 does for the box rows. The routing sentence at hve.md:145 moves into
    `**Next step**` [HIGH]
  - Added after validation (finding DD-014, confirmed): hve.md:44, the Simple direct path, is a second way
    this command ends and already uses the words "completion summary". Point it at the same close. The
    sentence holds the phrase pinned by the `simple_carveout_guarantee` row at tests/run-drift-tests.sh:584
    ("still creating and updating the changes log and running the test gate"), so edit around that phrase,
    not through it [HIGH]
  - CLAUDE.md:232 exempts the orchestrator from the HANDOFF block by design (it handles
    transitions internally). That exemption covers the handoff block only, not the completion
    summary [MEDIUM: the exemption sentence names the block, not the summary; confirm the reading
    holds after Step 1.4 rewrites the surrounding section]
- [ ] Step 4.2: hve-challenge.md:95-102 - the existing reminder fires per question. Add a
  session-end completion summary distinct from the per-question reminder, leaving the per-question
  reminder in place.
- [ ] Step 4.3: hve-prompt-analyze.md:88-90 - add a completion summary after the existing full
  report template. `artifact:` the analyzed file path or the report path.
  - Added 2026-10-10, owner decision O3 (resolved 2026-10-10 as recommended, see "Requirements added after plan refresh (2026-10-10)" at the end of this file): hve-prompt-analyze.md:85 (`Overall: ✅ No issues | ⚠️ N findings ...`)
    is the last line of the report template and carries bare `|`. Recommended: apply the enum-in-prose rule
    here too, since it sits directly above the new close [MEDIUM that it table-parses in practice; it is in
    a fence like the boxes were]
  - Added after validation (findings DD-012 and DD-013, both confirmed): the same template has five more
    bare-pipe lines at hve-prompt-analyze.md:79-83, so O3 is a six-line question, not one line. And this
    command's allowed tools are Read and Glob (hve-prompt-analyze.md:4), so it writes no report file:
    `artifact:` is the analyzed file path, and "or the report path" above cannot be filled [HIGH]
- [ ] Step 4.4: hve-git-commit.md:56-60 - currently one prose directive. Add a completion summary.
  `artifact: none - git commands write no tracking artifact`; `next:` the realistic next command
  (`git push` is not a slash command, so the `next:` value here is prose, which Step 1.4's format
  spec must permit).
- [ ] Step 4.5: hve-git-merge.md:62-69 - same treatment.
- [ ] Step 4.6: hve-git-setup.md:71-77 - this file has no close at all; it ends at
  `## Critical Constraints`. Add a new `## Completion` section.
- [ ] Step 4.7: hve-prompt-refactor.md:64 - currently a single prose line. Add a completion
  summary; `artifact:` the refactored file path.
- [ ] Step 4.8: Add both section pointers to each of the seven files.

### Phase 5: Reference sanity pass
Dependencies: Phases 2, 3, 4
Estimated scope: 5 modified files, 1 to 3 lines each
Success criteria: no file describes the close as a box or as "the Handoff Block" in a way the
new format contradicts; `grep -rn` for box-drawing characters across `.claude/`, `docs/`,
`README.md` and `CLAUDE.md` returns only intentional occurrences (expected: none)
(superseded, see Correction 2026-10-10: "none" was never reachable, because directory-tree diagrams use the same
characters. The criterion is: zero hits for the close-box corners,
`grep -rnE '[╭╮╰╯╝]' .claude CLAUDE.md README.md CONTRIBUTING.md docs`, and zero bare `|` in any close
template. At the BASE that command returns 18 lines in 9 files, the top and bottom edge of each of the nine close boxes).

Steps:
- [ ] Step 5.1: .claude/agents/hve-prompt-updater.md:55 - "Handoff Block present at the end (for
  phase commands)". Update to name the completion summary and labeled-line block.
- [ ] Step 5.2: .claude/commands/hve-prompt-refactor.md:50 - "Handoff Block for phase commands"
  in the convention checklist. Same update.
- [ ] Step 5.3: .claude/prompts/rpi.md:23 - "Note the handoff artifact path from the previous
  session's Handoff Block". Update the wording to the new block name.
- [ ] Step 5.4: docs/internals.md:9 and docs/workflow.md:134 both describe the handoff block.
  Update per CLAUDE.md's `Citation Format` section: these are living docs, so anchor to section
  names, not line numbers.
- [ ] Step 5.5: Run `grep -rn` for the box-drawing set across the repo and confirm the only
  remaining hits are in `.claude-hve-tracking/` (dated snapshots, which are never rewritten) and
  in this plan's own quoted examples.
  - Corrected 2026-10-10: run the corner-only command from the Phase 5 success criterion, not a grep for the
    whole box-drawing set. Recorded exclusions, left untouched because they are tree diagrams or terminal
    banners and not a close: CLAUDE.md:80-102, docs/reference.md:10-32, docs/workflow.md:17-33,
    docs/internals.md:40, .claude/instructions/terraform.md:13, and the `echo` banners in
    tests/run-prompt-upgrade.sh and tests/run-prompt-new-install.sh (double-line boxes printed to a terminal
    by the two semi-manual scripts) [HIGH]
  - Added after validation (finding DD-015, confirmed): the bare-pipe half of the criterion needs its own
    command, which the Risk Log row "Enum alternatives leak back" relies on. Run
    `grep -rnE '^(status|artifact|next|[a-z]+) *:.*\|' .claude/commands CLAUDE.md` and read each hit:
    none may sit inside a close template [MEDIUM: the pattern over-matches prose lines with a colon, so it
    is a list to read, not a pass or fail count]
    (superseded, see Correction 2026-10-10 in the Phase 6 section of
    `.claude-hve-tracking/changes/2026-10-10/phase-close-clarity-changes.md`: the pattern under-matches. It
    returns 0 lines at the base as well, because every template key there is capitalized)
- [ ] Step 5.6 (added 2026-10-10): recorded exclusions for sentences that say "handoff" without describing
  the box. Leave as written: the argument-parsing sentence "Ignore any pasted handoff-block text" at
  hve-plan.md:13, hve-implement.md:19 and hve-review.md:19, and "pasted handoff blocks" at
  hve-pr-review.md:17; CLAUDE.md:3 ("handoff artifacts"), :76 ("handoff medium"), :58 ("find the handoff file"), :150 ("handoff artifacts") and :263 ("phase
  handoffs"). The section keeps the name `Handoff Block Format` (DD-005), so the phrase still names the
  thing a user would paste. Confirm at implement time that a pasted labeled-line block is still read as
  handoff-block text by a converted command [MEDIUM: wording judgment, not testable from disk]

### Phase 6: Verify and propagate
Dependencies: Phases 1 through 5
Estimated scope: 0 to 1 modified files, plus test runs
Success criteria: both suites pass at or above baseline (drift 255+/0, install 69+/0) (superseded, see Correction 2026-10-10:
baseline at the BASE is drift 253 passed, 0 failed, rc=0 and install 72 passed, 0 failed, rc=0; expected
after implementation is drift 255 and install 72, see Testing Approach); a live
run of one converted command emits a close that renders without table mangling.

Steps:
- [ ] Step 6.1: Run `tests/run-drift-tests.sh` and `tests/run-install-tests.sh`. Baseline
  measured by the parent during planning on 2026-08-19: drift 255 passed 0 failed, install 69
  passed 0 failed (superseded, see Correction 2026-10-10: measured at the BASE on 2026-10-10, drift 253 passed, 0 failed,
  rc=0 and install 72 passed, 0 failed, rc=0). Record before/after counts in the changes log; any drop is a
  blocker. The two semi-manual scripts, `tests/run-prompt-new-install.sh` and `tests/run-prompt-upgrade.sh`,
  are not gates and are recorded as NOT RUN.
- [ ] Step 6.2: Confirm no new test-10 row is needed. Because both formats are centralized in
  CLAUDE.md and referenced by pointer, no byte-identical block is duplicated across command files,
  so `CANONICAL_BLOCK_SPECS` (tests/run-drift-tests.sh:571 at the BASE) needs no new entry.
  - Verify this by inspection at implement time rather than assuming it: if any implementor ends
    up pasting the same multi-line block into two or more command files, a test-10 row IS
    required. Guard step, not a claim [MEDIUM]
- [ ] Step 6.3: Live-run verification, which resolves research open question 5. Run one converted
  command (`/hve-research` on a throwaway topic is cheapest) in a real session and capture the
  raw rendered close. Confirm it does not table-parse. This is the only step that can confirm the
  rendering hypothesis; it cannot be done from disk.
  - Added 2026-10-10, owner decision O4 (resolved 2026-10-10 as recommended, see "Requirements added after plan refresh (2026-10-10)" at the end of this file): this needs an interactive session, so an unattended implementing
    seat cannot do it. Recommended: the implementor records it as NOT RUN and the owner runs it before
    merge [HIGH that it cannot run unattended]
- [ ] Step 6.4: Do NOT hand-edit `~/.claude`. Propagate globally with `./install.sh --global`
  after merge, per established install-state practice.
  - Added 2026-10-10: this is an owner action after merge. It rewrites the live `~/.claude`, so no
    implementing session runs it; the implementor records it as NOT RUN [HIGH]
- [ ] Step 6.5: Update README.md and docs/ only if they show the old box verbatim. Coordinate
  with the Thread A plan, which rewrites README sections in the same window
  (superseded, see Correction 2026-10-10: Thread A is now last in the recommended sequence, so there is no shared window;
  and at the BASE neither README.md nor docs/ shows a close box; their only mentions are the two prose lines
  Step 5.4 already covers, so this step is expected to change nothing further [HIGH]).

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| Losing the box loses visual scannability of the close | Medium | The three bold headers carry the visual structure now; the labeled-line block is deliberately small. Kevin reviews one converted command before Phases 3 and 4 fan out |
| A converted command still table-parses in chat | Low | Labeled lines contain no `|` at all, so no table can form. Step 6.3 confirms on live output rather than asserting it |
| Enum alternatives leak back into a template and reintroduce `|` | Medium | Step 1.4 forbids alternatives inside the template; Step 5.5 greps for the regression |
| CLAUDE.md conflict with the in-flight lean restructure | Medium | D3 sequences Thread B first; the restructure rebases. Thread B's CLAUDE.md footprint is one new section plus one rewritten section plus one clause |
| Section rename breaks existing pointers | Medium | Step 1.4 keeps the heading text unless the rename and the sweep land together; drift test 14 fails loudly if a pointer stops resolving |
| The BASE moves before PR #6 merges (added 2026-10-10) | Low | The citation table in the planning log lists the anchor text per row; re-print each row at the new head before implementing |
| A close-format consumer outside this repo breaks (added 2026-10-10) | Low | gh-tracker parses plan and changes-log fields and finding IDs, not the chat close, per the cross-repo review; no file under this repo's `tests/` names the HANDOFF block [MEDIUM: the consumer's own source was not read in this refresh] |
| 15 files edited in one sweep, uneven quality | Medium | Phases 2, 3, 4 are grouped by current close-shape so each group is a uniform transformation; test gate runs at each phase boundary |

## Testing Approach

Drift suite and install suite before and after every phase, with counts recorded (baseline
drift 255/0, install 69/0 as of 2026-08-19) (superseded, see Correction 2026-10-10: drift 253/0 rc=0, install 72/0 rc=0 at the
BASE, measured 2026-10-10). Drift test 14 is the primary automated guard: it
fails if any `per CLAUDE.md's <Section> section` pointer stops resolving, which covers every
pointer added in Phases 2 through 4. Test 10 needs no new row as long as centralization holds
(Step 6.2 verifies rather than assumes). The rendering fix itself has no automated test and is
confirmed by one live run at Step 6.3.

Expected counts after implementation (added 2026-10-10): test 14 prints one pass per distinct section
pointer under `.claude/` (the loop over the `sort -u` match list in `test14_reference_resolution`), and its
"pointers present" pass is already counted. This plan adds two distinct pointers, `Completion Summary` and
`Handoff Block Format`, neither of which exists under `.claude/` at the BASE, so drift should finish at 255
passed, 0 failed, with the rise landing in whichever of Phases 2 to 4 runs first. Install should stay at 72.
A different number is to be explained, not assumed benign [MEDIUM: derived by reading the test, not by
running it against the change].

## Requirements added after plan refresh (2026-10-10)

Kevin approved this plan on 2026-10-10, in chat with the orchestrator session, in the words "approve step 2".
The orchestrator had put the plan to him with owner decisions O1 to O5 answered as the refresh recommended,
and the five answers below are plan content. This record was written on 2026-10-11, after the implementation,
on his instruction "record it": the implementing session could not write an approval it had not received
first-hand (DR-001 in `.claude-hve-tracking/changes/2026-10-10/phase-close-clarity-changes.md`).

- O5: the close is emitted once per stopping turn, not once per command. `/hve-plan` and `/hve-implement`
  emit it at their approval gate with `status: awaiting-approval` and again after approval. Sentences that
  said to wait before emitting the Handoff Block are rewritten to match.
- O1: early stops emit the close, by one centralized rule in `CLAUDE.md` (Step 1.9): `blocked` when the stop
  needs something first, `done` for a clean stop.
- O2: `/hve-pr-review` maps its verdicts as `/hve-review` does (Approve to `done`, Request Changes to
  `needs-rework`, Block to `blocked`) and keeps the covered-set suffix in an optional `verdict:` line. Every
  command this plan gave no status defaults to `done` at a normal end.
- O3: the six bare-pipe lines in the `hve-prompt-analyze` report template are in scope.
- O4: the owner runs the live render check (Step 6.3) and `./install.sh --global` (Step 6.4). An unattended
  implementing session records both as NOT RUN.

Not an owner decision: the review fix pass later narrowed what `done` means (IV-001, IV-002 and IV-004 under
`## Review Fixes` in the changes log). That was a review disposition and is Kevin's to confirm at PR review.
