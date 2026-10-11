# Implementation Plan: CLAUDE.md Lean Restructure

Date: 2026-08-19
Task slug: claude-md-lean-restructure
Research: .claude-hve-tracking/research/2026-08-19/claude-md-lean-restructure.md
Status: Draft

## Overview

Shrink the CLAUDE.md payload (everything above the `## Your Project` sentinel, which `install.sh:171`
ships into every consuming project) by relocating two adopter-facing sections to `docs/`, slimming the
Command Reference to purpose plus when-to-use, trimming preamble narrative, and filling the empty
`## Your Project` section with repo-local context that ships nowhere. Every frozen heading, sole-copy
canonical block, and machine-parsed table survives byte-intact; the two test suites are the acceptance
gate at both ends.

Difficulty: **Challenging**. Size alone reads Medium-Hard, but the risk override (CLAUDE.md:30) applies
twice over: the file is code consumed outside this repo, and 15 headings plus 5 canonical blocks are
test-frozen.

## Baseline (measured 2026-08-19, before any edit)

Recorded so Phase 7 has something to compare against. Each was produced by the command shown.

- `./tests/run-drift-tests.sh` -> `Results: 255 passed, 0 failed` (exit 0) [HIGH]
- `./tests/run-install-tests.sh` -> `Results: 69 passed, 0 failed` [HIGH]
- `awk '/^## Your Project/{exit} {print}' CLAUDE.md | wc -l` -> `387` [HIGH]
- `awk '/^## Your Project/{exit} {print}' CLAUDE.md | wc -c` -> `23106` [HIGH]
- Command Reference row lengths (CLAUDE.md:41-55, `awk '{print length($0)}'`): 13, 393, 233, 294, 274,
  288, 377, 98, 123, 192, 107, 132, 151, 104, 116 [HIGH]
- `wc -l CLAUDE.md` -> `399` [HIGH]

## Locked decisions carried in from research

These came from the user on 2026-08-19 and are not re-opened during implementation.

1. Move BOTH the Installing section and the Hooks section out of the payload: Installing to
   `docs/installation.md`, Hooks to `docs/reference.md`.
2. Command Reference rows become purpose plus when-to-use; flag semantics leave the table entirely and
   are replaced by a pointer to `.claude/commands/<name>.md`.
3. The false "full = parallel validation" claim stays in `.claude/commands/hve-plan.md:41` and
   `README.md:124` until the deferred feature lands. Recorded as DD-001 in the planning log.
4. The producer-side payload warning goes BELOW the sentinel, as the opening lines of the filled
   `## Your Project` section, so it ships nowhere.
5. Keep `-` bullets; do not convert to `*` per `.claude/instructions/markdown.md:16`. Recorded as
   DD-002.
6. Keep the heading `## Your Project` byte-exact. No rename.

## Pre-flight constraints (verified at plan time)

Each was checked by the command recorded beside it. These are the invariants every phase must not break.

- **14 frozen headings.** `grep -hoE -- "per CLAUDE\.md's \`[^\`]+\` section" .claude/commands/*.md
  .claude/agents/*.md .claude/prompts/*.md | sort -u` returns pointers naming: The RPI Methodology,
  Friction Capture, Artifact Discovery & Relevance, Corrections in Tracking Artifacts, Subagent Dispatch
  Discipline, Subagent Response Protocol, Security Hygiene, Severity Grading, Concurrent Changes-Log
  Writes, Confidence Markers, Instructions Reference, Template Blanks, Untrusted Input, Citation Format.
  Test 14 (`tests/run-drift-tests.sh:972`) resolves each against CLAUDE.md's heading list by literal
  string equality. All 14 were re-checked against the proposed post-restructure heading set and resolve
  (spike in Phase 3a evidence below). [HIGH]
- **5 sole-copy canonical blocks, count must stay exactly 1.** `tests/run-drift-tests.sh:569-584` pins
  the line prefixes `Phase commands discover their input artifacts from`, `**Concurrent writes**`,
  ``accept an optional `--friction-log` flag``, `- **Secret exposure**: grep changed files for`, and
  `**Shell stays in the parent.**` at one carrier each across `.claude/commands/*.md`,
  `.claude/agents/*.md`, `.claude/prompts/*.md`, and CLAUDE.md. `docs/` is NOT in that corpus, so the
  Phase 1 relocations cannot raise a count. [HIGH]
- **Test 8 greps ALL of CLAUDE.md** for `.claude/instructions/[A-Za-z0-9._-]+\.md` and requires every
  hit to exist on disk (`tests/run-drift-tests.sh:459`). New prose anywhere in the file, including the
  filled `## Your Project` section, must not name a nonexistent instruction file. [HIGH]
- **Test 16 parses the credential set from the `.gitignore hygiene` bullet only**
  (`tests/run-drift-tests.sh:1128`), then requires `README.md` and `docs/installation.md` to name all
  six by presence. The Security Hygiene section is not edited by this plan; Phase 1 must not drop a
  pattern from `docs/installation.md`. [HIGH]
- **Test 3** parses the `## Model Selection` section body (`tests/run-drift-tests.sh:243`). That section
  is untouched. [HIGH]
- **Extraction sentinel.** `install.sh:171` runs `awk '/^## Your Project/{exit} {print}'`. The heading
  must remain byte-exact, at line start, and the last `##` section; no payload line may begin with
  `## Your Project`. Inline backticked mentions are safe because they are not at line start. [HIGH]
- **Only one intra-file anchor.** `grep -rn "tracking-folder" --include="*.md" .` outside the tracking
  folder returns `docs/reference.md:40` (points at README, not CLAUDE.md) and CLAUDE.md:76. So CLAUDE.md:76
  is the only link that Phase 2 must reconcile. [HIGH]
- **Install tests never assert payload content**, only the `HVE:START`/`HVE:END` markers and sentinel
  preservation (`tests/run-install-tests.sh:176-179, 285, 313`). Restructuring the payload body cannot
  red that suite. [HIGH]

## Plan-time verification evidence

Four checks ran in this session before the plan was finalized. Each is a check that could have failed.

1. Baseline suites, both green, recorded above.
   - `./tests/run-drift-tests.sh` -> `Results: 255 passed, 0 failed`
   - `./tests/run-install-tests.sh` -> `Results: 69 passed, 0 failed`
2. Test 14 simulation against the PROPOSED heading set. The proposed level-2+ heading list was written to
   a scratchpad file, the 14 live pointers were extracted from `.claude/commands/*.md`,
   `.claude/agents/*.md`, `.claude/prompts/*.md`, and each was matched with `grep -qxF` exactly as test 14
   matches. Output: all 14 printed `OK`, `test14-simulation fail=0`. The proposed restructure does not
   orphan a pointer. [HIGH]
3. Extraction simulation against a structural mock. A mock CLAUDE.md was built from the proposed heading
   list with stub bodies plus a filled `## Your Project` section, then run through `install.sh:171`'s
   exact awk. Output: mock 146 lines, payload 140 lines, payload ends on the `---` before the sentinel,
   `grep -c '^## Your Project'` on the payload printed `0`, and every pointer resolved against the
   payload's own heading list. The heading stays the cut line and nothing above it truncates early. [HIGH]
4. Flag-coverage counts per command file, recorded in the details file's flag table, establishing that
   the Command Reference is a copy rather than a sole carrier. Token presence only [HIGH]; semantic
   equivalence is [MEDIUM] and is guarded by Step 3.1.

What was NOT verified at plan time: the final prose. The mock carries stub bodies, so it proves the
structure extracts and the pointers resolve, not that the rewritten Command Reference rows or the filled
`## Your Project` section are correct. Phase 7 re-runs both real suites against the real file, which is
the check that can actually fail. Recorded as DD-006.

## Phases

### Phase 1: Relocate the two adopter-facing sections into docs

Dependencies: none
Estimated scope: `docs/reference.md` (+~25 lines), `docs/installation.md` (+~10 lines); CLAUDE.md untouched
Success criteria: `./tests/run-drift-tests.sh` still reports 255 passed / 0 failed; `docs/reference.md`
contains the hooks JSON block; `docs/installation.md` still names all six credential patterns
(`*.pfx` included) and now carries whatever installer prose CLAUDE.md held that it did not already.

Content moves to its destination BEFORE it is deleted from CLAUDE.md, so no revision of the tree is
missing the content.

Steps:

- [ ] Step 1.1: Append a `## Hooks for automatic change logging` section to `docs/reference.md` (after
      `## Reusable prompts`, docs/reference.md:71) carrying the body of CLAUDE.md:321-337 including the
      JSON block verbatim, plus the closing sentence at CLAUDE.md:337.
  - Assumption: `docs/reference.md` is the right home because it is the human-browsed reference and no
    machinery references the Hooks section (research PA/RQ1: zero references from `.claude/`) [HIGH]
- [ ] Step 1.2: Update the `docs/reference.md` intro sentence (docs/reference.md:3-4) to name the new
      section alongside the existing three.
- [ ] Step 1.3: Diff CLAUDE.md:343-364 against `docs/installation.md` BEFORE writing anything, and write
      down which sentences are genuinely absent there. `docs/installation.md:110-125` already carries the
      bash invocation and `docs/installation.md:127-211` already carries global mode.
  - Assumption: most of the section is already present, so a blind append would create a duplicate
    [MEDIUM]. That is why the diff is a step, not a note.
- [ ] Step 1.4: Add only the genuinely-absent sentences to `docs/installation.md`. The known candidates
      are the "don't combine a global install with per-project copies" warning (CLAUDE.md:361) and the
      "Together those are exactly what a project-mode install writes" clause (CLAUDE.md:360).
- [ ] Step 1.5: Move the credential-patterns paragraph at CLAUDE.md:382-385 into `docs/installation.md`
      next to the existing global-mode gitignore guidance. Keep the six patterns spelled out or keep the
      existing docs/installation.md occurrences intact. Either way, `docs/installation.md` must still
      name all six after the edit.
  - Assumption: `docs/installation.md` currently names all six [HIGH] (test 16 passes at baseline:
    `test16: docs/installation.md names every pattern: all 6 present`).
- [ ] Step 1.6: Run `./tests/run-drift-tests.sh` and confirm 255 passed / 0 failed. A count change here
      is a regression, not an intentional delta: Phase 1 adds no new test-visible surface.

### Phase 2: Delete the relocated sections from CLAUDE.md and absorb the tracking policy

Dependencies: Phase 1
Estimated scope: CLAUDE.md, roughly -50 net lines
Success criteria: `## Optional Power-User: Hooks for Automatic Change Logging` and
`## Installing HVE in Your Project` are gone from CLAUDE.md; the tracking-gitignore policy and its code
block survive inside `## Tracking Folder Structure`; CLAUDE.md:76's forward link no longer points at a
section that moved; both suites still green.

Steps:

- [ ] Step 2.1: Delete CLAUDE.md:317-339 (the `---` separator plus the whole Hooks section).
- [ ] Step 2.2: Delete CLAUDE.md:341-366 (the `## Installing HVE in Your Project` section through the
      "Run `/hve <your first task>` to begin" list).
- [ ] Step 2.3: Move CLAUDE.md:368-380 (`### Tracking folder & version control` heading, the
      committed-by-default paragraph, the two-rule code block, and the date+slug/private-folder
      paragraph) to sit directly beneath the tracking tree inside `## Tracking Folder Structure`, keeping
      it as an `###` subsection so the existing anchor slug `#tracking-folder--version-control` still
      resolves.
  - Assumption: keeping the `###` heading text byte-identical keeps the anchor valid, so no external
    link breaks [HIGH]. `grep -rn "tracking-folder" --include="*.md" .` outside the tracking folder
    returns only CLAUDE.md:76 and docs/reference.md:40, and the latter targets README, not CLAUDE.md.
- [ ] Step 2.4: Delete CLAUDE.md:382-385 (the credential-patterns installer paragraph, relocated in
      Step 1.5) and the now-orphaned `---` separators left behind by 2.1-2.3.
- [ ] Step 2.5: Rewrite CLAUDE.md:76 to drop the markdown link now that the policy is adjacent, e.g.
      "All runtime artifacts live in `.claude-hve-tracking/`. Durable artifacts are committed; only
      regenerable output is gitignored, per the policy below." Keep the handoff-medium sentence.
- [ ] Step 2.6: Confirm the `## Your Project` heading is still the last `##` section and no earlier line
      starts with it: `awk '/^## Your Project/{exit} {print}' CLAUDE.md | grep -c '^## Your Project'`
      must print `0`.
- [ ] Step 2.7: Run both suites. Expect 255/0 and 69/0.
  - Guard: if test 10 reports a carrier-count change, a canonical block was moved or reworded. Revert the
    offending edit rather than adjusting the spec.

### Phase 3: Slim the Command Reference

Dependencies: none (independent of Phases 1-2; may run in parallel with Phase 1)
Estimated scope: CLAUDE.md:38-60, ~18 rewritten table rows plus one new pointer line
Success criteria: no `--` flag token appears anywhere in the Command Reference table; every row is under
200 characters; `grep -nE '\-\-(mode|think|dimension|scope|compact)' CLAUDE.md` returns no hit inside
the Command Reference section; both suites still green.

Steps:

- [ ] Step 3.1: Before deleting any flag prose, confirm each flag the table currently describes is
      documented in its own command file, so the table is a copy and not a sole carrier. Plan-time check
      already run (`grep -c` per flag per command file): `--mode` present in hve.md (8), hve-research.md
      (6), hve-plan.md (3), hve-implement.md (5), hve-review.md (4); `--think` in hve.md (4),
      hve-plan.md (3), hve-review.md (3); `--dimension` in hve-pr-review.md (10); `--compact` in
      hve-pr-review.md (7); `--scope` in hve-doc-ops.md (2). [HIGH for token presence]
  - Assumption: token presence implies the *semantics* are also documented there, not just the flag name
    [MEDIUM]. Guard: for each of the six rows carrying semantics (CLAUDE.md:42-47), read the matching
    command file's argument-parsing section and confirm the same three-way `lightweight/standard/full`
    behavior is stated before deleting the row's prose. If a semantic exists only in CLAUDE.md, move it
    into the command file rather than deleting it.
- [ ] Step 3.2: Rewrite rows CLAUDE.md:42-55 to purpose plus when-to-use only. Target under 160
      characters per row (baseline worst rows: 393, 377, 294, 288, 274, 233).
- [ ] Step 3.3: Add one line under the table: flags and options for each command live in that command's
      file, `.claude/commands/<name>.md`.
  - Assumption: naming `.claude/commands/` is test-safe because test 8 greps only
    `.claude/instructions/` paths [HIGH].
- [ ] Step 3.4: Keep the "**Standalone phase commands** discover the latest tracking artifact
      automatically" paragraph (CLAUDE.md:57) unchanged; it is behavior, not flag semantics.
- [ ] Step 3.5: Note that slimming removes the false "`full` uses parallel validation" clause from
      CLAUDE.md as a side effect. Do NOT touch `.claude/commands/hve-plan.md:41` or `README.md:124`
      (locked decision 3). DD-001 records this.
- [ ] Step 3.6: Re-measure row lengths with the baseline command and record the new numbers.

### Phase 4: Trim the preamble narrative

Dependencies: none (independent; may run in parallel with Phases 1-3)
Estimated scope: CLAUDE.md:1-11, -3 to -4 lines
Success criteria: the MIT provenance line survives; `## The RPI Methodology` heading is byte-exact and
still present (test 14 depends on it); the section now opens on `**Five operating principles:**`.

Steps:

- [ ] Step 4.1: Replace the two-clause pitch at CLAUDE.md:3 with one operational framing line describing
      what the file governs, not why the project exists (the why lives at README.md:3, 11-22).
- [ ] Step 4.2: Keep CLAUDE.md:5 (the MIT attribution) verbatim.
- [ ] Step 4.3: Delete CLAUDE.md:11 (the "HVE's core insight" paragraph, a paraphrase of README.md:11-22)
      and its trailing blank line. `sed -n '9,22p' CLAUDE.md` at plan time showed CLAUDE.md:13 is
      `**Five operating principles:**`, so the
      section reads correctly with :11 removed. [HIGH]
- [ ] Step 4.4: Do not add any producer-side payload note above the sentinel. Anything above the heading
      ships to every install (research addendum, `install.sh:171`); the note belongs in Phase 5.

### Phase 5: Fill the `## Your Project` section with repo-local context

Dependencies: Phases 1-4 (so the counts and claims it states describe the finished file)
Estimated scope: CLAUDE.md, ~20 lines below the sentinel
Success criteria: the heading `## Your Project` is byte-identical and remains the last `##` section;
`awk '/^## Your Project/{exit} {print}' CLAUDE.md | wc -l` is unchanged by this phase (the section is
below the cut, so extraction output must not grow); `./tests/run-drift-tests.sh` still green, in
particular test 8.

Steps:

- [ ] Step 5.1: Open the section with the producer-side payload warning (locked decision 4): this section
      is repo-local, everything above the heading is extracted by `install.sh:171` and merged into every
      consuming project, and installed projects get their own equivalent section created by the installer.
- [ ] Step 5.2: Add the stack line. Re-count at implement time rather than copying the research numbers:
      `ls .claude/commands/*.md | wc -l`, `ls .claude/agents/*.md | wc -l`,
      `ls .claude/instructions/*.md | wc -l`, `ls .claude/prompts/*.md | wc -l`, `wc -l install.sh`,
      `wc -l tests/*.sh`.
  - Assumption: research counted 15 commands, 9 agents, 14 instruction files, 6 prompts, install.sh 280
    lines, tests 2389 lines [MEDIUM]. Counts drift, so the step re-derives them.
- [ ] Step 5.3: Add the product-boundary line: CLAUDE.md and `.claude/` edits are externally consumed, so
      the risk override applies and they classify at least Medium.
- [ ] Step 5.4: Add the test-gate lines: `./tests/run-install-tests.sh` and `./tests/run-drift-tests.sh`
      from repo root, offline, seconds, run after any edit to `.claude/`, `CLAUDE.md`, `README.md`,
      `docs/`, or `install.sh`; count deltas are intentional-or-regression (CONTRIBUTING.md:21, :33, :45).
      Note that the interactive prompt tests are not part of the routine gate (CONTRIBUTING.md:55, :62).
- [ ] Step 5.5: Add the branch-flow line: `feature/*` -> `dev` -> `main` (CONTRIBUTING.md:8).
- [ ] Step 5.6: Add the deliberate-duplication line: canonical blocks are byte-identical across carriers
      and drift-tested; never reword one copy alone; heading renames must update every
      ``per CLAUDE.md's `...` section`` pointer.
- [ ] Step 5.7: Add the tracking-folder line: committed by design, only `subagents/` and `sandbox/`
      gitignored.
- [ ] Step 5.8: Verify no line in this section names a `.claude/instructions/<file>.md` path that does
      not exist on disk (test 8 greps the whole file).
- [ ] Step 5.9: Verify no line in this section begins with `## Your Project`.

### Phase 6: Protect Mid-Flow Scope Changes from silent deletion (adjacent scope)

Dependencies: none
Estimated scope: `.claude/commands/hve-implement.md`, `.claude/commands/hve-review.md`, 1-2 lines each
Success criteria: test 14 gains a `Mid-Flow Scope Changes` row and it passes; both suites green with a
drift-test count of 256 or 257 (an intentional delta, recorded in the changes log).

`grep -rn "Requirements added after" .claude/ CLAUDE.md` returns exactly one hit, CLAUDE.md:259, and
`grep -rn "Mid-Flow" .claude/` returns nothing. So the section is a sole copy that no command implements
and no test protects: deleting it during a restructure would be silent. This phase is adjacent to the
lean-restructure scope; it is included because the restructure is exactly the operation that would lose
it. It can be dropped without affecting Phases 1-5.

Steps:

- [ ] Step 6.1: In `.claude/commands/hve-implement.md`, in the plan-discovery step, add the sentence
      that the implementor must read the plan's `## Requirements added after <phase>` section
      ``per CLAUDE.md's `Mid-Flow Scope Changes` section``, using that exact backticked construction so
      test 14 extracts it.
- [ ] Step 6.2: Do the same in `.claude/commands/hve-review.md`.
- [ ] Step 6.3: Run `./tests/run-drift-tests.sh`; confirm the new `test14: 'Mid-Flow Scope Changes'
      resolves` row is present and passing, and record the new total as an intentional count delta.

### Phase 7: Verification gate

Dependencies: Phases 1-6
Estimated scope: no file edits; measurement and recording only
Success criteria: every check below produces the stated result, and the numbers land in the changes log.

Steps:

- [ ] Step 7.1: `./tests/run-drift-tests.sh` -> 0 failed. Total is 255 without Phase 6, 256-257 with it.
      Any other number is investigated before the phase closes.
- [ ] Step 7.2: `./tests/run-install-tests.sh` -> `Results: 69 passed, 0 failed`.
- [ ] Step 7.3: `awk '/^## Your Project/{exit} {print}' CLAUDE.md | wc -l` and `| wc -c`. Target: at
      most 340 lines (from 387) and at least 3,000 characters smaller (from 23,106).
  - Assumption: the arithmetic of the removals (Hooks ~23 lines, Installing ~26, tracking-policy
    relocation net ~9, preamble ~4, Command Reference character-level only) lands in the 315-330 line
    range [MEDIUM]. The success criterion is stated as a bound, not a target number, because the exact
    figure depends on rewrite wording.
- [ ] Step 7.4: `awk '/^## Your Project/{exit} {print}' CLAUDE.md | grep -c '^## Your Project'` -> `0`.
- [ ] Step 7.5: `tail -1 CLAUDE.md | od -c | tail -2`: file ends with exactly one newline
      (`.claude/instructions/markdown.md:36`).
- [ ] Step 7.6: `grep -n "—" CLAUDE.md` restricted to the lines this task rewrote: no em-dash in new or
      rewritten prose. Pre-existing em-dashes in untouched lines are left alone; this task does not churn
      them.
- [ ] Step 7.7: `grep -rn "Installing HVE in Your Project\|Optional Power-User" . --include="*.md"`
      outside `.claude-hve-tracking/` returns nothing, so no dangling cross-reference to a moved section survives.
- [ ] Step 7.8: Confirm `docs/installation.md` and `docs/reference.md` render as valid markdown per
      `.claude/instructions/markdown.md`: blank lines around headings, code blocks and tables; no
      consecutive blank lines.

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| A frozen heading is renamed or dropped, breaking test 14 for 14 pointers at once | Low | Heading set was simulated against all 14 pointers before planning (Phase 3a evidence); Phases 2/7 re-run the suite |
| A sole-copy canonical block is reworded during the Command Reference or preamble rewrite, flipping a test 10 carrier count | Medium | None of the five block prefixes live in the edited regions; Step 2.7 and 7.1 catch it; guard is "revert the edit, never adjust the spec" |
| A payload line beginning with `## Your Project` silently truncates every future install | Low | Steps 2.6, 5.9, 7.4 assert `grep -c` is 0 on the extracted payload |
| The Installing content is appended to `docs/installation.md` as a duplicate of what is already there | Medium | Step 1.3 makes the diff a required step before any write |
| Deleting flag prose loses a semantic that lived only in CLAUDE.md | Medium | Step 3.1's guard reads each command file first and moves the semantic rather than deleting it |
| Test 16 goes red because a credential pattern is dropped from `docs/installation.md` during the move | Low | Step 1.5 states the constraint explicitly; Step 1.6 re-runs the suite immediately |
| Consuming projects lose the Installing/Hooks sections at their next update | Certain, and intended | Locked decision 1; the content lives in `docs/` and README already defers there |

## Testing Approach

There is no build, no package manager, and no CI in this repo. The gate is the two bash suites plus
direct measurement of the extraction boundary.

- `./tests/run-drift-tests.sh` from the repo root. Baseline 255 passed / 0 failed. Failures are read
  per-row: a test 10 carrier-count change means a canonical block moved; a test 14 row means a heading
  changed; test 8 means a nonexistent instruction path was cited; test 16 means a credential pattern was
  dropped from a prose surface.
- `./tests/run-install-tests.sh` from the repo root. Baseline 69 passed / 0 failed. This suite exercises
  install.sh end to end against temp directories, which is the real check that the payload extraction
  still produces a sane block.
- The extraction spike: `awk '/^## Your Project/{exit} {print}' CLAUDE.md`, measuring its line count, character
  count, and the absence of a `^## Your Project` line inside it.
- Run the drift suite after each of Phases 1, 2, 3, 5, and 6, not only at the end. Each phase touches a
  different test surface, and a mid-phase failure is far cheaper to localize than a failure at Phase 7.
- The interactive prompt tests (`tests/run-prompt-new-install.sh`, `tests/run-prompt-upgrade.sh`) need
  `dev` pushed to GitHub plus a Claude Code session and are NOT part of this gate (CONTRIBUTING.md:55,
  :62). If the restructure is expected to change what the paste-to-install prompts produce, that is a
  manual follow-up, not an automated one.

## Out of scope

- Renaming the `## Your Project` sentinel (locked decision 6).
- Fixing the "full = parallel validation" claim in `.claude/commands/hve-plan.md:41` and `README.md:124`
  (locked decision 3; DD-001).
- Converting `-` bullets to `*` (locked decision 5; DD-002).
- Deduplicating the tracking tree between CLAUDE.md and `docs/reference.md`. Compared at plan time: they
  are structurally identical, differing only in the `(gitignored)` annotations `docs/reference.md` adds.
  Both copies are kept.
- Reconciling the severity-wording variant at `.claude/agents/hve-implementation-validator.md:99-101`
  (research follow-on; unrelated file).
- The repo-vs-global command drift recorded as DD-003.
