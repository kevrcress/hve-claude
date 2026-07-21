# Implementation Plan: Friction Log Remediation
Date: 2026-07-17
Task slug: friction-log-remediation
Research: .claude-hve-tracking/research/2026-07-17/friction-log-remediation.md
Decisions: .claude-hve-tracking/memory/2026-07-17/friction-log-remediation.md (all locked decisions folded in below)
Status: Draft

## Overview

Apply the 61-issue friction-log remediation to the HVE prompt/doc definition: one shared discovery-and-relevance convention, Simple-task carve-outs, template integrity fixes, verdict-integrity rules, PR-review mechanical fixes plus a new `hve-pr-reviewer` agent, cross-phase structural rules, a `--friction-log` capture flag, and drift tests protecting the deliberately-duplicated boilerplate. Fixes ship before any dedup refactor (locked decision); subagents stay read-only throughout.

Phase 1 establishes shared conventions in CLAUDE.md that Phases 2-6 reference. Phases 2-7 touch disjoint files and can run in parallel after Phase 1. Phase 8 (drift tests) runs after all content edits. Phase 9 re-syncs the global install.

Canonical wording for every text block that appears in more than one file lives in the details doc; implementors paste from there, never improvise per-file variants.

## Phases

### Phase 1: Shared conventions in CLAUDE.md
Dependencies: none
Estimated scope: CLAUDE.md only; ~120 lines added/changed
Success criteria: CLAUDE.md contains all nine convention blocks below, worded exactly as in the details doc; `grep -c "friction" CLAUDE.md` returns > 0; difficulty table carries the risk footnote.

Steps:
- [ ] Step 1.1: Add an "Artifact Discovery & Relevance" convention section: (1) slug in arguments wins; (2) else collect distinct slugs from last ~7 days, single candidate wins; (3) multiple candidates: match current git branch name, else list and ask; (4) never silently pick between same-day slugs; (5) always topic-relevance-check the chosen artifact; if irrelevant or absent, record the skip (`Research: none` plus a DD- entry) and proceed; hard stop only for unreconstructible inputs (plan file, changes log). Resolves F-01, F-02, O-14, O-19, O-21, O-29.
  - Assumption: no manifest file is introduced; slugs remain task identity [HIGH] (locked decision)
- [ ] Step 1.2: Add the risk-override footnote to the difficulty table: classify at least Medium regardless of size if the change touches (a) code consumed outside the repo, (b) auth/security/crypto, (c) migrations or irreversible ops, (d) untested paths. Resolves F-05.
- [ ] Step 1.3: Add the template-blank design principle to conventions: every template blank must be genuinely obtainable in-session or carry an explicit N/A branch (example: `Tests: N/A - no test runner in repo`). Note it as a check /hve-prompt-builder enforces.
- [ ] Step 1.4: Add the parent-runs-shell rule: HVE subagents are read-only; the parent session runs all git/shell commands and passes pre-digested results into subagent prompts; shell verification is never delegated to a subagent without Bash. Resolves F-11, O-05 (Option B, locked).
- [ ] Step 1.5: Add the roster-deviation dispatch line: if a command dispatches an agent type not in the HVE roster, record which type and why in the artifact. Resolves O-34's visibility half.
- [ ] Step 1.6: Add friction capture convention: optional `--friction-log` flag on the six dispatching commands (research, plan, implement, review, pr-review, challenge); canonical artifact home `.claude-hve-tracking/friction/YYYY-MM-DD-phase-slug.md`; add `friction/` to the tracking tree diagram. Resolves O-43 and the capture-mechanism gap.
- [ ] Step 1.7: Add the slug-derivation rule for compound prompts: slug comes from the primary deliverable named in the task description, 3-6 kebab words; when a prompt bundles multiple asks, slug the first/primary one and note the rest in the artifact body. Resolves O-44.
- [ ] Step 1.8: Promote the user-ratified "Requirements added after <phase>" appendix convention: mid-flow scope changes and standing instructions are appended to the PLAN file under a `## Requirements added after <phase>` heading, and every later phase command must read that section. Resolves O-09.
- [ ] Step 1.9: Add JavaScript and TypeScript rows to the Instructions Reference table plus a fallback rule: if no instructions file exists for the language, follow dominant existing-code conventions and note the gap in the changes log; do not block. Resolves the rule half of F-08/O-13.
- [ ] Step 1.10: Add the concurrent changes-log rule: when phase implementors run in parallel, each agent owns exactly one `### Phase N` section and updates it via targeted Edit; whole-file Write of the shared changes log is forbidden. Resolves O-12 (convention half; command text in Phase 4).
  - Assumption: repo CLAUDE.md is the single source; the ~/.claude global copy is refreshed only via `./install.sh --global` in Phase 9 [HIGH]

### Phase 2: hve-research.md fixes
Dependencies: Phase 1
Estimated scope: .claude/commands/hve-research.md; ~40 lines changed
Success criteria: Phase 3 step 1/step 2 no longer contradict; Inputs line no longer claims a no-flag default that conflicts with the Phase 0 table; `--friction-log` documented.

Steps:
- [ ] Step 2.1: Rewrite Phase 3 consolidation steps (hve-research.md:77-78): read each subagent artifact IN FULL (they are already condensed summaries); context discipline means not re-opening the sources those artifacts cite, not skimming the artifacts themselves. Resolves O-01.
- [ ] Step 2.2: Fix the mode conflict: Inputs line (hve-research.md:18) applies only when `--mode` is explicitly passed; the Phase 0 difficulty table governs the no-flag case. Resolves O-02.
- [ ] Step 2.3: Add parent-digest routing note: git-history questions are answered by the parent (which has no Bash in this command's allowed-tools; use Glob/Grep-obtainable evidence or note the gap) and passed to subagents as digests; never delegate shell-dependent questions to hve-researcher. Resolves O-05 per locked Option B.
  - Assumption: hve-research.md allowed-tools stays `Read, Write, Glob, Grep, Agent` (no Bash added) [HIGH] (locked: subagents and this orientation stay read-only; git evidence arrives via user or parent session with Bash)
- [ ] Step 2.4: Add WebFetch guidance: use raw URLs (raw.githubusercontent.com) for GitHub file content; when the research subject IS an external repo, the 3-URL cap becomes 3 per question with a bounded follow-up round (one extra dispatch max) for flagged evidence gaps. Resolves O-06, O-07, O-03.
- [ ] Step 2.5: Add the `--friction-log` flag block (canonical wording from details doc) and `--friction-log` to the argument-hint frontmatter.

### Phase 3: hve-plan.md and hve-challenge.md fixes
Dependencies: Phase 1
Estimated scope: .claude/commands/hve-plan.md, .claude/commands/hve-challenge.md; ~50 lines changed
Success criteria: hve-plan discovery references the shared convention with a no-relevant-research branch; `$ARGUMENTS` parsed once; Evidence Rules cover verification-timing semantics; challenge discovery aligned.

Steps:
- [ ] Step 3.1: Replace hve-plan.md:19 discovery with the shared convention: slug-first resolution, topic-relevance check, and an explicit branch for "no relevant research exists" (record `Research: none` + DD- entry in the planning log; plan from the task description; do not attach an irrelevant doc as evidence). Resolves F-01/O-14 for plan.
- [ ] Step 3.2: Consolidate argument parsing (hve-plan.md:11, 19, 28, 35): one "Argument Parsing" preamble that extracts slug, `--mode`, `--think`, `--subagent-model`, `--friction-log` once into named values; later sections reference the values, never re-parse `$ARGUMENTS`. Resolves F-12.
- [ ] Step 3.3: Extend the Plan-Step Evidence Rules (hve-plan.md:84-90) with verification-timing semantics: a claim is plan-time verified only if the check ran during planning; implementation-time expectations are written as steps with success criteria, not as verified claims; a grep citation supports an existence claim, never an exhaustiveness claim; exhaustiveness needs an enumerated-and-checked list or stays [MEDIUM]. Resolves F-09, F-10.
- [ ] Step 3.4: Add the `--friction-log` flag block to hve-plan.md.
- [ ] Step 3.5: Align hve-challenge.md:26 discovery to the shared convention (slug-first, relevance check, ask on ambiguity) and add the `--friction-log` flag block. Resolves the challenge slice of Cluster A.

### Phase 4: hve-implement.md and hve-phase-implementor.md fixes
Dependencies: Phase 1
Estimated scope: .claude/commands/hve-implement.md, .claude/agents/hve-phase-implementor.md; ~80 lines changed
Success criteria: cold-start branch exists; Simple carve-out present with "steps" footnote; both timestamp templates instruct an obtainable source; test gate handles no-runner and dirty-baseline repos; STOP rule scoped to unresolved/functionality-affecting/beyond-latitude.

Steps:
- [ ] Step 4.1: Add a cold-start branch to Inputs (hve-implement.md:19-21): if no plan matching the slug/convention exists, stop and tell the user to run /hve-plan (or confirm lightweight direct implementation, recorded as `Plan: none` + DD- entry). Never proceed on a topically irrelevant plan. Resolves K-IMP/Cluster A for implement.
- [ ] Step 4.2: Add the Simple carve-out before Phase 2 dispatch (hve-implement.md:78): when the active plan is Simple grade (per difficulty table + risk footnote), implement directly in the parent session, still writing the changes log; subagent dispatch applies from Medium up. Add the footnote defining "steps" as plan checklist bullets, not phases. Resolves F-03, F-04, O-15.
- [ ] Step 4.3: Fix the timestamp template in BOTH files (hve-implement.md:47, hve-phase-implementor.md:75-76): `Started:`/`Completed:` must be obtained via Bash `date -u +%Y-%m-%dT%H:%M:%SZ` (both the command and the agent have Bash/all tools); if the clock is genuinely unavailable, write `Started: N/A - no clock available`, never a fabricated value. Resolves F-06.
- [ ] Step 4.4: Fix the test-count template (hve-implement.md:103 and the agent's report format): `Tests: X passed, Y failed` gains an explicit branch: `Tests: N/A - no test runner detected in repo` when detection (step 1 of Testing) finds none. Resolves F-07.
- [ ] Step 4.5: Add `## Test Baseline` capture to Phase 1 (hve-implement.md:27-34): before any phase runs, run the suite once, record pass/fail counts and failing test names in the changes log; the per-phase gate then triggers on NET-NEW failures only; pre-existing failures are noted, not blocking. Resolves O-11.
- [ ] Step 4.6: Add the contract-change license to the testing section (hve-implement.md:97-107): when the plan explicitly changes a behavior contract, rewriting the covering tests is in-scope and logged as a DD- decision, not treated as a regression; the phase-implementor's "never adjust expectations" rule (hve-phase-implementor.md:52-57) gains the same carve-out citing a plan step as license. Resolves O-17.
- [ ] Step 4.7: Refine the STOP rule (hve-implement.md:88): stop only when a discrepancy is unresolved, functionality-affecting, or beyond latitude the plan explicitly granted; plan-pre-authorized adaptations proceed with a logged DD- entry. Resolves O-10.
- [ ] Step 4.8: Add the concurrent changes-log write rule to the parallel-execution note (hve-implement.md:91) and to hve-phase-implementor.md log duties: one `### Phase N` section per agent, targeted Edit only, no whole-file Write. Resolves O-12.
- [ ] Step 4.9: Add the `--friction-log` flag block to hve-implement.md; add argument parsing preamble consolidation as in Step 3.2.

### Phase 5: hve-review.md fixes
Dependencies: Phase 1
Estimated scope: .claude/commands/hve-review.md; ~70 lines changed
Success criteria: missing research/details no longer hard-stops; Simple carve-out present; Minor findings consolidated without fabrication; review writes record-only corrections; dedup severity and pre-existing-defect rules present; shell verification stays in parent.

Steps:
- [ ] Step 5.1: Replace the Inputs hard stop (hve-review.md:24): hard stop ONLY when plan or changes log is missing (unreconstructible); research and details are optional inputs; when absent-by-design (recorded skip in the plan header) proceed with reduced-scope review and note the skip in the review log. Details file becomes optional everywhere it is referenced. Resolves F-02, O-19, O-20.
- [ ] Step 5.2: Add the Simple carve-out: for Simple-grade tasks, skip per-phase hve-rpi-validator dispatch; run ONE consolidated validator pass (single hve-rpi-validator covering all phases, or parent-direct check for single-phase lightweight runs, recorded either way). Resolves O-15 review half, token waste F-03 tail.
- [ ] Step 5.3: Fix the Minor-tally trap (hve-review.md:60, 77, 122): parent consolidates Critical AND Major findings in full text, and copies each validator's Minor COUNT and one-line titles from its output file into the review log; the Summary tally sums those recorded counts; forbid writing any tally number not traceable to a validation file. Resolves O-23.
- [ ] Step 5.4: Add record-only corrections authority: when the only defect is an un-annotated contradiction in the changes log (a Minor record-consistency finding), the reviewer itself appends the dated Correction entry (record-only edit, not implementation), logs it in the review, and does not route to Needs Rework for that alone. Resolves O-22.
- [ ] Step 5.5: Add severity-reconciliation and pre-existing-defect rules to Phase 4: (a) when deduplicating findings that multiple validators reported, keep the HIGHEST severity and note the disagreement; (b) defects demonstrably pre-existing (present on the base, untouched by the change) are recorded with a `pre-existing` tag and excluded from the verdict tally; contested reclassifications are decided by the parent (sonnet-tier judgment), never by a haiku validator. Resolves O-35, O-36, O-26/O-30 pinning decision.
- [ ] Step 5.6: Add the parent-shell rule to Phase 2/3 dispatch text: any verification requiring command execution runs in the parent before/after validator dispatch; validators receive digests; check an agent's tool list before delegating. Resolves F-11.
- [ ] Step 5.7: Add the `--friction-log` flag block and argument-parsing preamble.

### Phase 6: hve-pr-review.md overhaul and new hve-pr-reviewer agent
Dependencies: Phase 1
Estimated scope: .claude/commands/hve-pr-review.md (~70 lines), new .claude/agents/hve-pr-reviewer.md (~90 lines), docs/internals.md agent table, CLAUDE.md model prose if it names pinned agents
Success criteria: output path matches CLAUDE.md (`reviews/pr/`); empty diff never yields a verdict; finding IDs carry dimension prefixes; dedicated agent exists pinned sonnet; `./tests/run-drift-tests.sh` passes with the new agent listed.

Steps:
- [ ] Step 6.1: Fix the output path (hve-pr-review.md:19, 137): `.claude-hve-tracking/reviews/pr/BRANCH-NAME/YYYY-MM-DD-review.md`, with slashes in branch names sanitized to `-` (e.g. `feature/x` → `feature-x`). Resolves O-32, O-40.
- [ ] Step 6.2: Add argument parsing (hve-pr-review.md:17): branch name = first whitespace-delimited token of `$ARGUMENTS` that matches `git branch --list` output; anything else in `$ARGUMENTS` (pasted handoff blocks, flags) is ignored for branch selection; no match → current branch. Resolves O-33.
- [ ] Step 6.3: Add the empty-diff guard to Phase 1: if `git diff <base>...HEAD --name-only` is empty, DO NOT proceed to a verdict; run `git status --porcelain`; if uncommitted/untracked work exists, tell the user and ask whether to review the working tree or stop; an empty review is never an Approve. Also surface untracked files as an explicit "not covered by diff" list when reviewing. Resolves O-31, O-42 untracked half.
- [ ] Step 6.4: Write the diff ONCE to `.claude-hve-tracking/reviews/pr/BRANCH-NAME/diff.patch` in Phase 1; each subagent receives the path plus its changed-file list and Reads the diff itself; the diff text is never pasted into 8 prompts. Resolves O-42 duplication half.
  - Assumption: reviews/pr subfolder is committed by default (not in the gitignored set); diff.patch is regenerable noise, add a step to gitignore `diff.patch` or place it under sandbox [MEDIUM]; decide in implementation, log DD-
- [ ] Step 6.5: Replace IV-NNN (hve-pr-review.md:86, 95-104) with dimension-prefixed IDs: FC-, DA-, II-, RL-, PS-, RO-, SC-, DO- (mapping in details doc); compact pairs use both prefixes. IV- remains reserved for /hve-review implementation validation. Resolves O-38.
- [ ] Step 6.6: Create `.claude/agents/hve-pr-reviewer.md`: pinned `model: sonnet`; tools Read, Write, Glob, Grep (read-only + own artifact, per parent-shell rule); embeds the dimension definitions, prefixed-ID format, severity grading, and Subagent Response Protocol; parent passes diff path + dimension assignment. Update hve-pr-review.md Phase 2 to dispatch `hve-pr-reviewer` (with the roster-deviation line for any fallback). Resolves O-34.
- [ ] Step 6.7: Add resume semantics: if today's review file for the branch already exists with completed dimension sections, offer to resume (re-run only missing dimensions) or restart. Resolves O-37.
- [ ] Step 6.8: Update docs/internals.md agent table (add hve-pr-reviewer, model sonnet) and any CLAUDE.md Model Selection prose naming pinned agents, so drift test groups 2-3 pass.
  - Assumption: internals.md lists agents in a table with a Model column, per run-drift-tests.sh group 2 [HIGH]
- [ ] Step 6.9: Add the `--friction-log` flag block to hve-pr-review.md.

### Phase 7: JavaScript and TypeScript instructions files
Dependencies: none (table rows land in Phase 1)
Estimated scope: 2 new files in .claude/instructions/; ~80 lines each
Success criteria: both files exist, follow the structure of existing instructions files, and `tests/lib/instruction-files.sh` checks (if any enumerate the set) pass.

Steps:
- [ ] Step 7.1: Read 2 existing instructions files (python.md, rust.md) to extract the shared structure before authoring.
- [ ] Step 7.2: Author `.claude/instructions/javascript.md`: modern ES modules, const/let, async/await over callbacks, error handling, package.json script conventions, no framework lock-in.
- [ ] Step 7.3: Author `.claude/instructions/typescript.md`: builds on javascript.md by reference; strict mode, explicit exported-API types, no `any` without justification, type-only imports, narrowing over assertions.
  - Assumption: tests/lib/instruction-files.sh may enumerate expected instruction files; check and update it if so [MEDIUM]

### Phase 8: Drift tests for duplicated boilerplate
Dependencies: Phases 2-7 (asserts final wording)
Estimated scope: tests/run-drift-tests.sh (or new tests/run-boilerplate-drift.sh) + tests/lib; ~150 lines
Success criteria: test run fails when any of the protected copies diverges; full `./tests/run-drift-tests.sh` and `./tests/run-install-tests.sh` pass on the finished tree.

Steps:
- [ ] Step 8.1: Add a check that the `--subagent-model` boilerplate paragraph is byte-identical across all commands that carry it (extract-and-diff against the first occurrence).
- [ ] Step 8.2: Add a check that the Subagent Response Protocol copies in the 9 agent files share the invariant lines (artifact-path line, status line, 7-bullet cap, 5-item checklist, 3-question cap, full-detail line) - structural greps per file rather than byte-diff, since agents vary status vocabulary. 
- [ ] Step 8.3: Add a check that the `--friction-log` flag block is identical across the six commands carrying it.
- [ ] Step 8.4: Add a check that every language listed in CLAUDE.md's Instructions Reference table has a file in .claude/instructions/ and vice versa.
- [ ] Step 8.5: Add a check that every agent referenced by name in any command file exists in .claude/agents/ (catches future O-34s).
- [ ] Step 8.6: Run `./tests/run-drift-tests.sh` and `./tests/run-install-tests.sh`; fix any failures surfaced in Phases 1-7 edits.

### Phase 9: Global re-sync and verification
Dependencies: Phase 8
Estimated scope: no repo file edits (installer run + checks)
Success criteria: `./install.sh --global` completes; spot-diff of ~/.claude/commands/hve-review.md against repo copy shows the new text; criticized strings are gone from the repo tree.

Steps:
- [ ] Step 9.1: Negative greps on the repo tree: `grep -rn "most recent" .claude/commands/` returns no unqualified discovery text; `grep -rn "pr/review" .claude` returns nothing; `grep -n "Started: \[timestamp\]" .claude/commands/hve-implement.md` returns nothing.
- [ ] Step 9.2: Run `./install.sh --global`; verify exit 0 and that ~/.claude/agents/hve-pr-reviewer.md now exists.
  - Assumption: Kevin's ~/.claude is marker-managed and safe to re-sync via the installer [HIGH] (memory: project-global-install-state)
- [ ] Step 9.3: Record in the changes log that end-to-end consumer-repo verification (run a Simple task in Fieldnotes or privy-mvp, confirm the carve-outs fire and no fabricated timestamps appear) is a USER follow-up outside this repo; do not attempt it from this session (cross-repo tracking writes are forbidden).

## Risk Log
| Risk | Likelihood | Mitigation |
|---|---|---|
| Canonical text drifts while 6 parallel implementors paste it into different files | High | Single source of wording in the details doc; Phase 8 drift tests fail on divergence |
| Parallel phases corrupt the shared changes log (the exact O-12 failure, self-referentially) | Medium | Apply the O-12 rule to THIS implementation: one `### Phase N` section per agent, targeted Edit only |
| Simple carve-out wording reintroduces the phases-vs-steps ambiguity (F-04) | Medium | "Steps" footnote lands in the same edit; validator instructed to check for it |
| New agent breaks docs-drift tests (internals.md table, CLAUDE.md prose) | Medium | Step 6.8 updates docs in the same phase; Step 8.6 gates completion |
| CLAUDE.md edits collide with installer HVE-block markers | Low | Edit repo CLAUDE.md only; global copy refreshed exclusively via `./install.sh --global` (Phase 9) |
| Review-phase changes weaken fabrication guards while fixing process theater | Low | Hard stop retained for plan/changes log; skips must be RECORDED to be legitimate; validator checks the distinction |

## Testing Approach

1. **Drift tests** (Phase 8): extended `./tests/run-drift-tests.sh` covering boilerplate copies, instructions-table sync, and agent-roster references; plus existing frontmatter/internals/gitignore groups.
2. **Install tests**: `./tests/run-install-tests.sh` unchanged; must still pass (new files ride the existing copy of `.claude/instructions/` and `.claude/agents/`).
3. **Negative greps** (Step 9.1): criticized strings verifiably absent.
4. **Manual end-to-end** (user follow-up, out of repo): one Simple task in a consumer repo after global re-sync; confirms carve-outs fire, timestamps real, no fabricated test counts.
