# Implementation Plan: Unowned-File Convention Remediation

Date: 2026-07-20
Task slug: unowned-file-remediation
Research: .claude-hve-tracking/research/2026-07-20/unowned-file-remediation.md
Status: Approved (2026-07-20)

## Overview

Fix the 12 Major and 9 Minor defects found in the 14 `.claude/` files that no phase of the friction-log remediation owned. Fixes cluster by file so each phase owns a disjoint file set: validator/parent contract repairs, prompt-builder pipeline sequencing, command-body gaps in doc-ops and memory, mechanical prompt-reference drift, and two new drift tests targeting the two failure classes static comparison missed (dispatch with no named agent, prompt flags that no command implements).

Difficulty: Medium-Hard (cross-cutting, ~15 files). Risk override applies regardless of size: every file is an installed prompt consumed outside this repo.

Baseline evidence: `bash tests/run-drift-tests.sh` run 2026-07-20 during planning returned `169 passed, 0 failed`. All 12 Major and 9 Minor findings were re-verified in the planning session by direct read or grep (see planning log DR-001); the research's [MEDIUM] markers are upgraded accordingly.

## Phases

Phases 1-4 touch disjoint file sets and may run in parallel after the baseline step. Phase 5 requires Phases 1-4 complete. Phase 6 requires Phase 5.

### Phase 0: Baseline gate (parent session, not a subagent)
Dependencies: none
Estimated scope: no file edits
Success criteria: full drift suite green before any edit; failure here stops the task.

Steps:
- [ ] Step 0.1: Run `bash tests/run-drift-tests.sh` in the parent session; record the pass count in the changes log. Planning-time run returned 169/0 [HIGH - command run 2026-07-20], but re-run at implementation time since the tree may have moved.

### Phase 1: Validator/parent contract fixes (M-01, M-05, M-06, placeholder Minor)
Dependencies: Phase 0
Estimated scope: 4 files (`.claude/agents/hve-rpi-validator.md`, `.claude/agents/hve-plan-validator.md`, `.claude/commands/hve-review.md`, `.claude/commands/hve-plan.md`), ~40 lines
Success criteria: rpi-validator's unlisted-change check names a parent-supplied input; both validator bodies carry a research-absent branch; `grep -n "git diff --name-only" .claude/commands/hve-review.md` hits in the dispatch-inputs block.

Steps:
- [ ] Step 1.1 (M-01, parent half): In `hve-review.md`, add a parent-side step to run `git diff --name-only` (against the phase-appropriate base) and pass the resulting changed-file list as a sixth input in the rpi-validator dispatch block (currently five inputs at hve-review.md:85-90 [HIGH - read during planning]).
- [ ] Step 1.2 (M-01, agent half): In `hve-rpi-validator.md`, reword line 48 from "Search for files modified but not listed in the changes log" to comparing the parent-supplied changed-file list against the changes log, and give the `## Unlisted Changes` template section (lines 87-88) a true N/A branch: `N/A - no changed-file list supplied by parent`. Canonical wording in the details doc.
- [ ] Step 1.3 (M-05): In `hve-plan-validator.md`, add a research-absent branch to Step 1: when the parent reports research as absent (`Research: none — [reason]` in the plan header), skip requirement extraction, note it in the DR-/DD- log, and validate the plan for internal consistency only. In `hve-plan.md`, extend the validator dispatch to pass the research path or the explicit `Research: none` marker.
- [ ] Step 1.4 (M-06): In `hve-rpi-validator.md`, make Pre-requisite item 4 conditional: "Read the research document if the parent supplied one; if it reports `Research: none`, skip requirement extraction and record that the phase was validated against the plan alone." (`hve-review.md:88` already says "(if present)" [HIGH - read during planning]; only the agent body lacks the branch.)
- [ ] Step 1.5 (placeholder Minor): In `hve-rpi-validator.md` Pre-requisite item 1, replace create-placeholder-first with: write the validation document only once at least the Load Context reads have succeeded, and if blocked mid-run, write the file with an explicit `Status: Blocked` header rather than leaving placeholder sections.
  - Assumption: no other agent creates placeholder-first, so no sibling needs the same edit [HIGH - research "Verified clean" section, confirmed by grep during audit]

### Phase 2: Prompt-builder pipeline fixes (M-03, M-04, m-03)
Dependencies: Phase 0
Estimated scope: 3 files (`.claude/commands/hve-prompt-builder.md`, `.claude/agents/hve-prompt-evaluator.md`, `.claude/commands/hve-prompt-refactor.md`), ~30 lines
Success criteria: tester and evaluator run sequentially with the log path passed; `grep -in "template blank" .claude/commands/hve-prompt-builder.md .claude/agents/hve-prompt-evaluator.md .claude/commands/hve-prompt-refactor.md` hits in all three files (planning-time grep of the first two returned nothing [HIGH - command run 2026-07-20]).

Steps:
- [ ] Step 2.1 (M-04): In `hve-prompt-builder.md` Phase 2, change "Steps A and B (parallel)" to sequential: run `hve-prompt-tester` first, wait, then run `hve-prompt-evaluator` with the test execution log path added to its received-inputs list (the evaluator already declares that input at hve-prompt-evaluator.md:18 [HIGH - read during planning]).
- [ ] Step 2.2 (M-03, builder half): Add "Template blanks: every blank obtainable in-session or carries an explicit N/A branch" to the quality-criteria list at hve-prompt-builder.md:53, making CLAUDE.md:208's claim true without editing CLAUDE.md.
- [ ] Step 2.3 (M-03, evaluator half): Add a matching "Template Integrity" criteria section to `hve-prompt-evaluator.md` (canonical wording in details doc) so the delegated evaluation actually checks it.
  - Assumption: builder and evaluator read and enforce items in their criteria lists; the evaluator already assesses five analogous criteria sections at hve-prompt-evaluator.md:25-54 [HIGH - sections read during planning]
- [ ] Step 2.4 (m-03): In `hve-prompt-refactor.md` "Enforce HVE Conventions" checklist (lines 44-51), add two items: Template Blanks (obtainable-or-N/A) and Artifact Discovery & Relevance (slug-first, 7-day window, branch tiebreak, relevance check).

### Phase 3: Command-body gaps in doc-ops and memory (M-02, M-11, M-12, m-01, m-02)
Dependencies: Phase 0
Estimated scope: 2 files (`.claude/commands/hve-doc-ops.md`, `.claude/commands/hve-memory.md`), ~35 lines
Success criteria: doc-ops names `hve-researcher` in its dispatch step and excludes prompt-engineering artifacts in Phase 1 Discovery; hve-memory carries a discovery procedure referencing the CLAUDE.md convention; `grep -c "exclud" .claude/commands/hve-doc-ops.md` > 0 (planning-time grep returned 0 [HIGH - command run 2026-07-20]).

Steps:
- [ ] Step 3.1 (M-02): In `hve-doc-ops.md:48`, name the roster agent: "Spawn parallel `hve-researcher` subagents (read-only inventory work fits its tool set)". Add the roster-deviation fallback sentence for any future non-roster dispatch.
- [ ] Step 3.2 (M-11): In `hve-doc-ops.md` Phase 1 Discovery, add the exclusion the prompt already promises: skip `.claude/commands/`, `.claude/agents/`, `.claude/instructions/`, `.claude/prompts/` and point to `/hve-prompt-analyze` for those. (Decision to honor the prompt's promise rather than delete it: DD-002.)
- [ ] Step 3.3 (m-01): Fix `hve-doc-ops.md:3` argument-hint to make path and flags independent: `[path-to-docs] [--scope all|compliance|accuracy|gaps] [--subagent-model sonnet|opus|haiku] [--friction-log]`. Must match the body at lines 17-18 and the prompt file edited in Step 4.4.
- [ ] Step 3.4 (M-12): In `hve-memory.md`, add an artifact-discovery subsection before the Tracking Artifacts block: follow the CLAUDE.md Artifact Discovery & Relevance convention (slug argument first, else distinct slugs from the last 7 days, branch-name tiebreak, list-and-ask on ambiguity, relevance check); populate the Research/Plan/Changes paths only from that procedure, never newest-match-wins.
- [ ] Step 3.5 (m-02): Fix `hve-memory.md:74`: the native memory store is per-project (`~/.claude/projects/<project-slug>/memory/`), not cross-project. Canonical wording in details doc; the same wording feeds checkpoint.md in Step 4.3.

### Phase 4: Prompt-reference drift (M-07, M-08, M-09, M-10, m-04, m-05, m-06, m-07, m-08, m-09)
Dependencies: Phase 0
Estimated scope: 6 files, all in `.claude/prompts/` (`rpi.md`, `pull-request.md`, `checkpoint.md`, `doc-ops.md`, `task-challenge.md`, `prompt-build.md`), ~50 lines
Success criteria: every `--flag` token in each prompt file exists in the corresponding command file's argument-hint or body; no prompt documents a mode, argument, or output the command lacks. All prompt edits align the prompt DOWN to actual command behavior; no new command features (DD-003).

Steps:
- [ ] Step 4.1 (M-07, m-04): In `rpi.md`, delete the `continue` and `suggest` option lines (0 mentions of either token in hve.md [HIGH - grep run during research, re-confirmed]); add `--think` and `--subagent-model sonnet|opus|haiku` to match hve.md:3's argument-hint.
- [ ] Step 4.2 (M-08, M-09): In `pull-request.md`, remove the "## PR Description" section (lines 33-35) and rewrite the line-3 header to describe what the command does: senior-level review across 8 quality dimensions. Canonical header wording in details doc.
- [ ] Step 4.3 (M-10, m-09): In `checkpoint.md`, replace the Modes section with actual behavior: Save is the only operation; Continue is a printed instruction for the next session, not a selectable mode; no Update path exists. Add the per-project native-memory write to the Output list using the same canonical wording as Step 3.5.
- [ ] Step 4.4 (m-05): In `doc-ops.md`, add `--subagent-model sonnet|opus|haiku` to the options list, matching the hint fixed in Step 3.3.
- [ ] Step 4.5 (m-06): In `task-challenge.md`, add `--friction-log` to the options. Do NOT add `--subagent-model`: hve-challenge.md has no Agent tool [HIGH - research verified].
- [ ] Step 4.6 (m-07, m-08): In `prompt-build.md`, add an Options section (`--iterations N` default 3, `--subagent-model sonnet|opus|haiku`) and an Output line naming the sandbox location `.claude-hve-tracking/sandbox/YYYY-MM-DD-topic-run-N/`.
  - Assumption: `--iterations` is the actual flag name in hve-prompt-builder.md [MEDIUM - not verified during planning]. Guard: implementor greps hve-prompt-builder.md for the real flag name before writing; if the command has no such flag, document "default 3 iterations" as behavior, not as an option.

### Phase 5: Drift-test coverage for the two escaped classes
Dependencies: Phases 1-4 (tests must be written against the fixed tree)
Estimated scope: 1 file (`tests/run-drift-tests.sh`), ~80 lines
Success criteria: both new tests pass on the fixed tree AND each fails when its target regression is reintroduced (demonstrated by temporary mutation, then revert); full suite green.

Steps:
- [ ] Step 5.1 (Test 12 - dispatch names an agent): For each command file whose frontmatter `allowed-tools` includes `Agent`, assert the body contains at least one backticked `hve-*` token that resolves to `.claude/agents/<name>.md`. Rationale: Test 9 only validates tokens that exist; M-02's "Spawn parallel Doc-Ops subagents" contained no backticked token, so Test 9 had nothing to match [HIGH - Test 9 extraction logic read at tests/run-drift-tests.sh:490-496 during planning].
- [ ] Step 5.2 (Test 13 - prompt flags resolve): Using the fixed prompt→command map (rpi.md→hve.md, pull-request.md→hve-pr-review.md, checkpoint.md→hve-memory.md, doc-ops.md→hve-doc-ops.md, task-challenge.md→hve-challenge.md, prompt-build.md→hve-prompt-builder.md), extract every `--[a-z-]+` token from each prompt file and assert it appears in the mapped command file. Catches the M-07/M-10 phantom-feature class mechanically.
  - Assumption: flag-token extraction has no false positives from prose examples [MEDIUM]. Guard: run the test against the fixed tree first; if noisy, restrict extraction to lines starting with `- \`--`.
- [ ] Step 5.3: Mutation check: temporarily revert one Phase 3 edit (remove the backticked agent name from hve-doc-ops.md) and one Phase 4 edit (re-add `continue` to rpi.md); confirm each new test fails; restore. Record both command outputs in the changes log.

### Phase 6: Full verification and global re-sync
Dependencies: Phase 5
Estimated scope: no repo file edits (installer writes to `~/.claude`)
Success criteria: full drift suite green; `./install.sh --global` completes and reports the marker-managed update.

Steps:
- [ ] Step 6.1: Run `bash tests/run-drift-tests.sh` (full suite, parent session); record final pass count in the changes log. Must be >= 169 plus the new Phase 5 assertions.
- [ ] Step 6.2: Run `./install.sh --global` to re-sync `~/.claude` (marker-managed as of 2026-07-06; never hand-copy). Record the installer output summary in the changes log.

## Requirements added after review (2026-07-20)

Source: `/hve-review` verdict ⚠️ Needs Rework, 0 Critical / 3 Major / 10 Minor
(`.claude-hve-tracking/reviews/rpi/2026-07-20/unowned-file-remediation-review.md`).
Recorded here per the CLAUDE.md Mid-Flow Scope Changes convention so later phase commands
treat these as plan content. Phases 7-9 touch disjoint file sets and may run in parallel;
Phase 10 requires all three.

### Phase 7: Test 13 coverage repair and canonical-corpus extension (RV-101, Q-201)
Dependencies: none (post-review baseline: 207 passed, 0 failed at 2026-07-21T05:24:53Z)
Estimated scope: 1 file (`tests/run-drift-tests.sh`)
Success criteria: the details-doc Mutation B, run UNMODIFIED, makes the suite fail; the
fixed tree stays green; `PROMPTS_DIR` participates in the canonical-block corpus.

- [ ] Step 7.1 (RV-101): Repair Test 13 so it covers the defect forms it was written for.
  The current extraction anchor `^- \`--[a-z-]+` cannot see M-07's bare tokens
  (`` - `continue`: ``) or M-10's bold mode names (`- **Continue**:`). Widening the anchor
  alone is NOT sufficient and must not be done naively: `suggest` occurs in prose at
  `.claude/commands/hve.md:155` and `continue` occurs as a heading at
  `.claude/commands/hve-memory.md:91`, so a whole-file grep FALSE-PASSES both defects.
  Required contract, verified by the parent session against the live tree before dispatch:
  - **Extract** leading tokens from option lines only within sections whose heading matches
    `^## (Arguments|Options|Modes)`. Section-scoping is load-bearing: it excludes
    `.claude/prompts/doc-ops.md:7-9`, whose bold lines sit under `## What it checks` and are
    dimension descriptions, not options. Accept three shapes: `` - `--flag` ``,
    `` - `bare-token` ``, and `- **BoldToken**`.
  - **Resolve** each token against the mapped command's frontmatter `argument-hint`, or
    failing that, a backticked occurrence of the token in the command body. Prose mentions
    and headings must NOT count as resolution.
  - Parent-verified expected outcomes: all 17 tokens currently present across the six
    prompt files resolve (zero false positives); `continue`, `suggest`, and checkpoint's
    `Save`/`Continue`/`Update` all fail to resolve (both defect classes caught).
- [ ] Step 7.2 (Q-201): Add `PROMPTS_DIR` to the canonical-block corpus at
  `tests/run-drift-tests.sh:560` (currently globs only `COMMANDS_DIR` and `AGENTS_DIR`) and
  register the per-project memory-store sentence in `CANONICAL_BLOCK_SPECS`, so the
  byte-identical copies at `.claude/commands/hve-memory.md:87` and
  `.claude/prompts/checkpoint.md:25` cannot silently diverge.
- [ ] Step 7.3: Verification. Run the details-doc Mutation B EXACTLY as originally written
  (re-add `` - `continue`: Mention "continue" to resume from the most recent tracking
  artifacts `` to the `## Arguments` section of `.claude/prompts/rpi.md`), confirm the suite
  FAILS, then restore from a byte-level backup and confirm with `diff`. This is the
  acceptance test the original Phase 5 could not pass. Record both outputs.

### Phase 8: rpi-validator instruction repair (Q-202 + DRY minor)
Dependencies: none
Estimated scope: 1 file (`.claude/agents/hve-rpi-validator.md`)
Success criteria: the unlisted-changes instruction names the whole changes log
unambiguously; the research-absent rule is stated once.

- [ ] Step 8.1 (Q-202): At `.claude/agents/hve-rpi-validator.md:50`, disambiguate
  "the changes log" to state explicitly that the comparison is against the ENTIRE changes
  log, not only this phase's `### Phase N:` section. Under the phase-scoped reading every
  sibling phase's files false-flag as unlisted; this task's own 5-phase log is a reproducing
  case.
- [ ] Step 8.2 (Minor, DRY): At `.claude/agents/hve-rpi-validator.md:34-35` the
  research-absent rule appears twice (paraphrase plus verbatim restatement). Collapse to a
  single statement, preserving the details-doc canonical wording as the surviving copy.

### Phase 9: Residual documentation drift (2 Minor)
Dependencies: none
Estimated scope: 2 files
Success criteria: no stale parallel-dispatch wording remains; internals doc lists the
Template Integrity criterion.

- [ ] Step 9.1: `.claude/commands/hve-prompt-builder.md:61` retains "After both subagents
  complete", a residue of the pre-fix parallel design that Step 2.1 replaced with sequential
  dispatch. Reword to match the sequential flow.
- [ ] Step 9.2: `docs/internals.md:25` describes hve-prompt-evaluator's criteria without the
  Template Integrity criterion added at `.claude/agents/hve-prompt-evaluator.md:56-59`.
  Add it. Per the CLAUDE.md living-docs rule, anchor by symbol/section name, not line number.

### Phase 10: Re-verification and global re-sync (parent session)
Dependencies: Phases 7-9
- [ ] Step 10.1: Full suite green, count recorded.
- [ ] Step 10.2: Re-run `./install.sh --global` to re-sync `~/.claude`, which currently
  carries the pre-remediation state.
- [ ] Step 10.3: Run `shellcheck tests/run-drift-tests.sh` if available; if still not
  installed, record the skip rather than claiming the check passed.

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| A "smallest fix" is wrong-direction (the IV-004 lesson: reported defect was the opposite of the real one) | Medium | Every finding was re-verified during planning by direct read or grep; Phase 4 steps carry the align-down rule (DD-003) so no phantom feature gets implemented as real |
| Test 13 flag extraction too noisy or too loose | Medium | Step 5.2 guard: restrict to option-list lines; mutation check in 5.3 proves it can fail |
| Parallel phases collide on a shared file | Low | Phases 1-4 file sets are disjoint by construction (verified in details doc ownership map); shared wording lives in the details doc, not cross-phase edits |
| Sequencing tester→evaluator (Step 2.1) slows prompt-builder loops | Low | Accepted: correctness over speed; the evaluator was silently degraded before, so the parallel speed was buying nothing |
| Installer re-sync diverges from marker-managed `~/.claude` state | Low | install.sh is idempotent; Step 6.2 records output for review |

## Testing Approach

Three gates: (1) Phase 0 baseline run proves the suite is green before edits; (2) Phase 5 mutation checks prove the two new tests actually detect their target regressions, not just pass; (3) Phase 6 full-suite run plus installer re-sync proves the tree and the global install both land clean. Per-phase success criteria use greps whose predicates target the claim itself (e.g. `grep -c "exclud"` on the file that had zero hits at planning time).
