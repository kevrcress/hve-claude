# Implementation Plan: Phase-Ending Clarity (Thread B)
Date: 2026-08-19
Task slug: phase-close-clarity
Research: .claude-hve-tracking/research/2026-08-19/project-communication-phase-close.md (Thread B)
Sibling plan: .claude-hve-tracking/plans/2026-08-19/project-communication-presence-plan.md (Thread A, runs second)
Status: Validated (2026-08-19) - awaiting user approval

## Overview

Give all 15 HVE commands one uniform close: the locked three-header completion summary
(What I did / What I need from you / Next step) followed by a fenced labeled-line block
carrying three fixed keys (status, artifact, next). The labeled-line block replaces the
box-drawing HANDOFF block and its four sibling boxes, which is both the rendering-bug fix
and the machine-readable carrier HiVE will need. Both formats are defined once in CLAUDE.md
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

## Phases

### Phase 1: Define both canonical formats in CLAUDE.md
Dependencies: none
Estimated scope: 1 modified file (CLAUDE.md), roughly 55 to 80 net new lines
Success criteria: CLAUDE.md contains a `## Completion Summary` heading and a rewritten
`## Handoff Block Format` section with zero box-drawing characters; `tests/run-drift-tests.sh`
still reports 255 passed, 0 failed.

Steps:
- [ ] Step 1.1: Add a new `## Completion Summary` section to CLAUDE.md, placed immediately
  before the existing `## Handoff Block Format` section (CLAUDE.md:214 as of 2026-08-19).
  Specify the three bold headers in fixed order: `**What I did**`, `**What I need from you**`,
  `**Next step**`, with the per-header content rules from the locked format (outcomes one line
  each leading with step or finding ID and a file path; one line of test evidence with
  before/after numbers obtained by execution; "Nothing blocking" stated explicitly when true;
  one concrete next command plus the realistic alternative).
  - The heading text `Completion Summary` was verified by the parent during planning to satisfy
    drift test 14: `claude_md_headings()` at tests/run-drift-tests.sh:965 extracts every
    `^##+ ` heading text, and `REFERENCE_PATTERN` at :959 is
    ``per CLAUDE\.md's \`[^\`]+\` section``. A pointer reading
    ``per CLAUDE.md's `Completion Summary` section`` therefore resolves with no test edit [HIGH]
- [ ] Step 1.2: In the same section, state the converse guard that resolves the Lean-turns
  tension (research B5): the completion summary is emitted once per command, at close, and does
  not license verbose mid-phase turns. Name the failure mode explicitly so it binds: the block
  must not grow into a second findings report.
- [ ] Step 1.3: Append a clarifying clause to CLAUDE.md:19 (principle 5, Lean turns) exempting
  the command-close turn, so principle 5 and the new section do not read as contradictory.
  Smallest viable edit: extend the existing sentence rather than adding a paragraph.
  - Verified by the parent during planning, not inherited from research:
    `grep -rn 'Lean turns|one-line summary after subagent|Parent agents return a one-line' .claude/`
    returned no matches, so no command, agent or prompt file restates principle 5 and this is a
    CLAUDE.md-only edit [HIGH]
- [ ] Step 1.4: Rewrite the `## Handoff Block Format` section body (CLAUDE.md:216-228) to define
  the labeled-line format. Required keys, always present, always in this order: `status`,
  `artifact`, `next`. Document the status enum in prose above the template, NOT inside the
  template. Rename the section heading only if Step 5.1's reference sweep is done in the same
  phase; otherwise keep the heading text `Handoff Block Format` so existing pointers keep
  resolving.
  - The enum-in-prose rule exists because some current templates embed alternatives with bare
    ASCII `|` characters inside box rows. A template whose sample line contains `|` reintroduces
    exactly the table-parse class of bug this phase removes.
    Corrected 2026-08-19 (see Correction below): the offending set is exactly three lines,
    enumerated rather than sampled, via
    `grep -rn '│.*|' .claude/commands/*.md`:
    `hve-doc-ops.md:112`, `hve-pr-review.md:188`, `hve-pr-review.md:189`.
    This is an enumeration, not a grep for existence, so it is exhaustive over `.claude/commands/`
    [HIGH]
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
  any edit was 255 passed, 0 failed (run by the parent during planning, 2026-08-19).

### Phase 2: Convert the four true-HANDOFF commands
Dependencies: Phase 1
Estimated scope: 4 modified files, roughly 20 to 30 net lines each
Success criteria: none of hve-research.md, hve-plan.md, hve-implement.md, hve-review.md
contains any of the characters in the set box-drawing corners and verticals; each carries a
resolving `per CLAUDE.md's` pointer for both new sections; drift suite still 0 failed.

Steps:
- [ ] Step 2.1: hve-research.md:140-153 - replace the Handoff Block section with the completion
  summary plus labeled-line block. `status: done`, `artifact:` the research doc path,
  `next: /hve-plan`. Removes the mismatched corner defect at hve-research.md:152 by deletion.
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
  The `next:` value varies by verdict per the existing routing at hve-review.md:152-155.
- [ ] Step 2.6: Add the two section pointers to each of the four files, phrased exactly as
  ``per CLAUDE.md's `Completion Summary` section`` and ``per CLAUDE.md's `Handoff Block Format`
  section`` (or the renamed heading if Step 1.4 renamed it, kept consistent).

### Phase 3: Convert the four sibling-box commands
Dependencies: Phase 1
Estimated scope: 4 modified files, roughly 20 to 30 net lines each
Success criteria: no box-drawing characters remain in hve-pr-review.md, hve-doc-ops.md,
hve-memory.md, hve-prompt-builder.md; drift suite still 0 failed.

Steps:
- [ ] Step 3.1: hve-pr-review.md:183-191 - replace the `PR REVIEW COMPLETE` box. This file is
  the highest-priority conversion: its lines 188-189 carry bare ASCII `|` inside box rows
  (`Verdict  : ✅ Approve | ⚠️ Request Changes | 🚫 Block` and `Critical : N | Major: N | Minor: N`),
  which is the strongest table-parse trigger in the repo. Move the verdict alternatives into
  prose and emit one concrete value; carry counts as an optional `findings:` line.
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
  - CLAUDE.md:228 exempts the orchestrator from the HANDOFF block by design (it handles
    transitions internally). That exemption covers the handoff block only, not the completion
    summary [MEDIUM: the exemption sentence names the block, not the summary; confirm the reading
    holds after Step 1.4 rewrites the surrounding section]
- [ ] Step 4.2: hve-challenge.md:95-102 - the existing reminder fires per question. Add a
  session-end completion summary distinct from the per-question reminder, leaving the per-question
  reminder in place.
- [ ] Step 4.3: hve-prompt-analyze.md:88-90 - add a completion summary after the existing full
  report template. `artifact:` the analyzed file path or the report path.
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
`README.md` and `CLAUDE.md` returns only intentional occurrences (expected: none).

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

### Phase 6: Verify and propagate
Dependencies: Phases 1 through 5
Estimated scope: 0 to 1 modified files, plus test runs
Success criteria: both suites pass at or above baseline (drift 255+/0, install 69+/0); a live
run of one converted command emits a close that renders without table mangling.

Steps:
- [ ] Step 6.1: Run `tests/run-drift-tests.sh` and `tests/run-install-tests.sh`. Baseline
  measured by the parent during planning on 2026-08-19: drift 255 passed 0 failed, install 69
  passed 0 failed. Record before/after counts in the changes log; any drop is a blocker.
- [ ] Step 6.2: Confirm no new test-10 row is needed. Because both formats are centralized in
  CLAUDE.md and referenced by pointer, no byte-identical block is duplicated across command files,
  so `CANONICAL_BLOCK_SPECS` (tests/run-drift-tests.sh:around 940) needs no new entry.
  - Verify this by inspection at implement time rather than assuming it: if any implementor ends
    up pasting the same multi-line block into two or more command files, a test-10 row IS
    required. Guard step, not a claim [MEDIUM]
- [ ] Step 6.3: Live-run verification, which resolves research open question 5. Run one converted
  command (`/hve-research` on a throwaway topic is cheapest) in a real session and capture the
  raw rendered close. Confirm it does not table-parse. This is the only step that can confirm the
  rendering hypothesis; it cannot be done from disk.
- [ ] Step 6.4: Do NOT hand-edit `~/.claude`. Propagate globally with `./install.sh --global`
  after merge, per established install-state practice.
- [ ] Step 6.5: Update README.md and docs/ only if they show the old box verbatim. Coordinate
  with the Thread A plan, which rewrites README sections in the same window.

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| Losing the box loses visual scannability of the close | Medium | The three bold headers carry the visual structure now; the labeled-line block is deliberately small. Kevin reviews one converted command before Phases 3 and 4 fan out |
| A converted command still table-parses in chat | Low | Labeled lines contain no `|` at all, so no table can form. Step 6.3 confirms on live output rather than asserting it |
| Enum alternatives leak back into a template and reintroduce `|` | Medium | Step 1.4 forbids alternatives inside the template; Step 5.5 greps for the regression |
| CLAUDE.md conflict with the in-flight lean restructure | Medium | D3 sequences Thread B first; the restructure rebases. Thread B's CLAUDE.md footprint is one new section plus one rewritten section plus one clause |
| Section rename breaks existing pointers | Medium | Step 1.4 keeps the heading text unless the rename and the sweep land together; drift test 14 fails loudly if a pointer stops resolving |
| 15 files edited in one sweep, uneven quality | Medium | Phases 2, 3, 4 are grouped by current close-shape so each group is a uniform transformation; test gate runs at each phase boundary |

## Testing Approach

Drift suite and install suite before and after every phase, with counts recorded (baseline
drift 255/0, install 69/0 as of 2026-08-19). Drift test 14 is the primary automated guard: it
fails if any `per CLAUDE.md's <Section> section` pointer stops resolving, which covers every
pointer added in Phases 2 through 4. Test 10 needs no new row as long as centralization holds
(Step 6.2 verifies rather than assumes). The rendering fix itself has no automated test and is
confirmed by one live run at Step 6.3.
