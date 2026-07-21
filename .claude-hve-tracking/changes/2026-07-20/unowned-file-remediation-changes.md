# Changes Log: Unowned-File Convention Remediation

Date: 2026-07-20
Plan: .claude-hve-tracking/plans/2026-07-20/unowned-file-remediation-plan.md
Status: Complete — 11 phases done across two rounds. Round 1 (Phases 0-6) fixed the 21 original defects; round 2 (Phases 7-10) remediated the 3 Major findings from `/hve-review`. Suite 211/0, security Pass. One open item: ShellCheck unavailable in this environment, so the bash changes remain unlinted (Steps 6/10.3). (superseded — see Correction 2026-07-21 in Phase 10)

## Test Baseline

`bash tests/run-drift-tests.sh` run at 2026-07-21T04:55:10Z (parent session, Phase 0): **169 passed, 0 failed**. No pre-existing failures; any failure after edits is net-new.

## Phases

### Phase 0: Baseline gate
Status: Complete
Started: 2026-07-21T04:55:10Z
Completed: 2026-07-21T04:55:10Z

#### Files Modified
- None (gate only)

#### Steps Completed
- [x] Step 0.1: Full drift suite run in parent session; 169 passed, 0 failed — matches the planning-time baseline.

---

### Phase 1: Validator/parent contract fixes (M-01, M-05, M-06, placeholder Minor)
Status: Complete
Started: 2026-07-21T04:56:08Z
Completed: 2026-07-21T04:57:49Z

#### Files Modified
- `.claude/commands/hve-review.md:83,93` — parent-side `git diff --name-only <base>` step before validator dispatch; changed-file list added as sixth dispatch input (canonical wording)
- `.claude/agents/hve-rpi-validator.md:23,31,34-35,50,90-91` — changed-file list in Your Assignment; write-after-load Pre-requisite item 1; conditional research read with canonical research-absent wording; parent-supplied unlisted-changes check; Unlisted Changes template N/A branch
- `.claude/agents/hve-plan-validator.md:18,34` — Assignment accepts `Research: none — [reason]` marker; Step 1 research-absent branch with canonical wording, internal-consistency-only validation
- `.claude/commands/hve-plan.md:134` — validator dispatch passes research path or the explicit `Research: none — [reason]` marker

#### Steps Completed
- [x] Step 1.1 (M-01, parent half): hve-review.md — parent-side `git diff --name-only` digest passed as sixth dispatch input — `.claude/commands/hve-review.md:83,93`
- [x] Step 1.2 (M-01, agent half): hve-rpi-validator.md — unlisted-changes check compares parent-supplied list (`.claude/agents/hve-rpi-validator.md:50`); template N/A branch (`.claude/agents/hve-rpi-validator.md:90-91`); changed-file list added to Your Assignment inputs (`.claude/agents/hve-rpi-validator.md:23`)
- [x] Step 1.3 (M-05): hve-plan-validator.md research-absent branch (`.claude/agents/hve-plan-validator.md:34`, canonical wording verbatim plus DR-/DD- note and internal-consistency-only scope); hve-plan.md dispatch passes research path or `Research: none` marker (`.claude/commands/hve-plan.md:134`)
- [x] Step 1.4 (M-06): hve-rpi-validator.md Pre-requisite item 4 conditional on research presence, with canonical research-absent wording as indented note — `.claude/agents/hve-rpi-validator.md:34-35`
- [x] Step 1.5 (placeholder Minor): hve-rpi-validator.md Pre-requisite item 1 — write-after-load with `Status: Blocked` header when blocked mid-run — `.claude/agents/hve-rpi-validator.md:31`

#### Issues Encountered
- None. Success criteria verified by grep 2026-07-21: `git diff --name-only` hits at hve-review.md:83,93 (dispatch-inputs block); both validator bodies carry the research-absent branch; unlisted-change check names the parent-supplied list. Earlier step citations off by one against final file state were corrected in place before phase close (no superseded claims left standing).
- Tests: not run — parent session owns the test gate per dispatch instructions.

---

### Phase 2: Prompt-builder pipeline fixes (M-03, M-04, m-03)
Status: Complete
Started: 2026-07-21T04:56:15Z
Completed: 2026-07-21T04:57:52Z
Tests: not run — parent session owns the drift-suite gate per dispatch instructions

#### Files Modified
- `.claude/commands/hve-prompt-builder.md:40-61` — Phase 2 loop split into sequential Step A (tester) and Step B (evaluator); evaluator receives the test execution log path; template-integrity quality criterion added
- `.claude/agents/hve-prompt-evaluator.md:56-59` — Template Integrity criteria section added; finding tag enum gained `TEMPLATE` (line 76) and Quality Score line gained `Template integrity: Pass/Fail` (line 84)
- `.claude/commands/hve-prompt-refactor.md:51-52` — Enforce HVE Conventions checklist gained Template Blanks and Artifact Discovery & Relevance items

#### Steps Completed
- [x] Step 2.1 (M-04): hve-prompt-builder.md Phase 2 — tester then evaluator, sequential, log path passed — `.claude/commands/hve-prompt-builder.md:40-61`
- [x] Step 2.2 (M-03, builder half): template-blank line added to quality-criteria list — `.claude/commands/hve-prompt-builder.md:59`
- [x] Step 2.3 (M-03, evaluator half): Template Integrity criteria section added to hve-prompt-evaluator.md — `.claude/agents/hve-prompt-evaluator.md:56-59`; also extended the finding tag enum (`|TEMPLATE`) and Quality Score line so the new criterion is reportable in the output template
- [x] Step 2.4 (m-03): hve-prompt-refactor.md checklist — Template Blanks + Artifact Discovery items — `.claude/commands/hve-prompt-refactor.md:51-52`

#### Issues Encountered
- None. Success grep verified: "template blank" hits in all three files; no "parallel" wording remains in the builder's Phase 2 loop.

---

### Phase 3: Command-body gaps in doc-ops and memory (M-02, M-11, M-12, m-01, m-02)
Status: Complete
Started: 2026-07-21T04:56:24Z
Completed: 2026-07-21T04:58:24Z
Tests: not run — parent session owns the test gate for this run (per dispatch instructions)

#### Files Modified
- `.claude/commands/hve-doc-ops.md:3` — argument-hint: path and flags now independent bracketed groups (plan-verbatim string)
- `.claude/commands/hve-doc-ops.md:26` — Phase 1 Discovery item 2 excludes `.claude/commands/`, `.claude/agents/`, `.claude/instructions/`, `.claude/prompts/`; points to `/hve-prompt-analyze` (items renumbered 1–5)
- `.claude/commands/hve-doc-ops.md:49-50` — Phase 2 names `hve-researcher` and adds the roster-deviation fallback sentence per CLAUDE.md Subagent Dispatch Discipline
- `.claude/commands/hve-memory.md:35-45` — new `## Locating tracking artifacts` section (CLAUDE.md Artifact Discovery & Relevance procedure), placed immediately before Phase 2 — Save
- `.claude/commands/hve-memory.md:87` — native memory store corrected to per-project canonical wording (`~/.claude/projects/<project-slug>/memory/`)

#### Steps Completed
- [x] Step 3.1 (M-02): hve-doc-ops.md names `hve-researcher` in dispatch step + roster-deviation fallback sentence — `.claude/commands/hve-doc-ops.md:49-50`
- [x] Step 3.2 (M-11): hve-doc-ops.md Phase 1 Discovery excludes `.claude/commands|agents|instructions|prompts/`, pointing to `/hve-prompt-analyze` (DD-002) — `.claude/commands/hve-doc-ops.md:26`
- [x] Step 3.3 (m-01): hve-doc-ops.md argument-hint rewritten so path and flags are independent, per plan-verbatim string — `.claude/commands/hve-doc-ops.md:3`
- [x] Step 3.4 (M-12): hve-memory.md artifact-discovery subsection per canonical wording — `.claude/commands/hve-memory.md:35-45`
- [x] Step 3.5 (m-02): hve-memory.md native memory store corrected to per-project — `.claude/commands/hve-memory.md:87`

#### Issues Encountered
- Success-criteria grep is case-sensitive: first wording used "Exclude" (capital E) and `grep -c "exclud"` returned 0; reworded to "are excluded" so the literal criterion passes (count now 1).
- Placement note (Step 3.4): the Tracking Artifacts block sits inside the fenced memory-document template, so the new section was inserted at the nearest well-formed position before it — as a standalone H2 immediately before `## Phase 2 — Save`.
- Formatting deviation note (2026-07-21, both prongs hold — cosmetic, Minor): the verbatim block from the plan had `Record \`none\`...` directly after list item 4 with no blank line, which markdown renders as a lazy continuation of item 4; a blank line was added per `.claude/instructions/markdown.md` (blank lines surrounding lists) so it reads as the intended standalone closing sentence. No word changed.

#### Discrepancies & Decisions
- DR-301: Step 3.3's plan-verbatim argument-hint includes `[--friction-log]`, but hve-doc-ops.md has no friction-log mechanics in its body and CLAUDE.md's Friction Capture section lists only six dispatching commands, doc-ops not among them. The hint now advertises a flag the command body does not implement. Implemented verbatim per plan; flagging for parent/review to either add the flag mechanics to hve-doc-ops.md or drop `[--friction-log]` from the hint. (Resolved 2026-07-21 — see DD-004.)
- DD-004 (2026-07-21, parent session): dropped `[--friction-log]` from `.claude/commands/hve-doc-ops.md:3`. Evidence the flag was newly invented rather than pre-existing: `git diff` shows the pre-task hint was `[path-to-docs | --scope all|compliance|accuracy|gaps] [--subagent-model sonnet|opus|haiku]` with no friction token, so plan Step 3.3 introduced it. Documenting a flag no command body implements is the exact M-07/M-10 phantom-feature class this task removes, and the plan's own align-down rule (DD-003) plus CLAUDE.md's six-command friction roster both point to removal rather than to adding mechanics. The m-01 defect Step 3.3 targeted (path and flags wrongly alternated inside one bracket group) is still fixed; only the invented flag came out.

---

### Phase 4: Prompt-reference drift (M-07..M-10, m-04..m-09)
Status: Complete
Started: 2026-07-21T04:57:16Z
Completed: 2026-07-21T04:58:44Z
Tests: not run — parent session owns the drift-suite gate per dispatch instructions

#### Files Modified
- `.claude/prompts/rpi.md:9-10` — `continue`/`suggest` option lines deleted; `--think` and `--subagent-model sonnet|opus|haiku` added
- `.claude/prompts/pull-request.md:3` — header rewritten to canonical review wording; PR Description section removed
- `.claude/prompts/checkpoint.md:5-7,25` — Modes section replaced with save-only actual behavior; per-project native-memory wording added to Output
- `.claude/prompts/doc-ops.md:17` — `--subagent-model sonnet|opus|haiku` added to Options
- `.claude/prompts/task-challenge.md:24` — `--friction-log` added to Options
- `.claude/prompts/prompt-build.md:23-30` — Options section (`--iterations N`, `--subagent-model`) and Output section naming the sandbox path added

#### Steps Completed
- [x] Step 4.1 (M-07, m-04): rpi.md — deleted `continue`/`suggest` option lines; added `--think` and `--subagent-model sonnet|opus|haiku` matching hve.md:3 argument-hint — `.claude/prompts/rpi.md:7-10`
- [x] Step 4.2 (M-08, M-09): pull-request.md — line-3 header rewritten to canonical review wording (`.claude/prompts/pull-request.md:3`); "## PR Description" section removed (was lines 33-35)
- [x] Step 4.3 (M-10, m-09): checkpoint.md — Modes section replaced with save-only actual behavior (`.claude/prompts/checkpoint.md:5-7`); per-project native-memory canonical wording added to Output (`.claude/prompts/checkpoint.md:25`)
- [x] Step 4.4 (m-05): doc-ops.md — `--subagent-model sonnet|opus|haiku` added to Options; matches hve-doc-ops.md:3 argument-hint — `.claude/prompts/doc-ops.md:17`
- [x] Step 4.5 (m-06): task-challenge.md — `--friction-log` added to Options; `--subagent-model` deliberately NOT added (hve-challenge.md has no Agent tool) — `.claude/prompts/task-challenge.md:24`
- [x] Step 4.6 (m-07, m-08): prompt-build.md — Options section added with `--iterations N` (default: 3) and `--subagent-model` (both verified in hve-prompt-builder.md:3 argument-hint per plan GUARD); Output section names sandbox `.claude-hve-tracking/sandbox/YYYY-MM-DD-topic-run-N/` — `.claude/prompts/prompt-build.md:23-30`

#### Issues Encountered
- Success-criteria grep run 2026-07-21: every `--flag` token in all six prompt files resolves in the mapped command file (rpi→hve, pull-request→hve-pr-review, checkpoint→hve-memory (no flags), doc-ops→hve-doc-ops, task-challenge→hve-challenge, prompt-build→hve-prompt-builder). Zero misses.
- Note (not a blocker): checkpoint.md per-project wording follows the plan-canonical text; hve-memory.md:74 still says "persists across projects" until sibling Phase 3 Step 3.5 lands its fix. The prompt and command converge once Phase 3 completes. (superseded — see Correction 2026-07-20)

#### Corrections
- Correction (2026-07-20, appended by `/hve-review`): the note above was true when Phase 4 wrote it (Phases 3 and 4 ran concurrently) but is false against the final tree. Phase 3 did land Step 3.5: `.claude/commands/hve-memory.md:87` now carries the per-project canonical wording, and the prompt/command pair has converged as predicted. Recorded per the CLAUDE.md corrections convention; this is a record-only fix, the implementation was correct.
- Note: hve-prompt-builder.md sandbox path uses uppercase `TOPIC` placeholder (`.claude/commands/hve-prompt-builder.md:19`); prompt-build.md uses plan-canonical lowercase `topic`, matching the CLAUDE.md tracking-structure listing. Same path, placeholder-case difference only.

---

### Phase 5: Drift-test coverage for the two escaped classes
Status: Complete
Started: 2026-07-21T04:50:12Z
Completed: 2026-07-21T05:02:55Z

Tests: 207 passed, 0 failed (`./tests/run-drift-tests.sh`, exit 0). Baseline
entering the phase was 169 passed, 0 failed; Tests 12 and 13 add 38 assertions.

#### Files Modified
- `tests/run-drift-tests.sh:32-38` — extended the header test-group index with entries for groups 11, 12, and 13 (11 was previously undocumented there)
- `tests/run-drift-tests.sh:46` — added `PROMPTS_DIR` readonly constant
- `tests/run-drift-tests.sh:710-730` — added `command_dispatches_agent` helper: parses the frontmatter `allowed-tools:` line and matches `Agent` as a standalone comma-separated token
- `tests/run-drift-tests.sh:732-778` — added `test12_dispatch_names_resolvable_agent`
- `tests/run-drift-tests.sh:794-801` — added `PROMPT_COMMAND_MAP` (6 prompt→command pairs, `prompt|command` spec format matching the `CANONICAL_BLOCK_SPECS` style)
- `tests/run-drift-tests.sh:803-844` — added `test13_prompt_flag_sync`
- `tests/run-drift-tests.sh:855` — added `PROMPTS_DIR` to the required-path preflight check in `main()`
- `tests/run-drift-tests.sh:883-886` — registered both tests via `run_test`

#### Steps Completed
- [x] Step 5.1: Test 12 — dispatching commands name a resolvable agent
- [x] Step 5.2: Test 13 — prompt-file flags exist in the mapped command
- [x] Step 5.3: Mutation checks A and B with failure outputs recorded

#### Design Notes
- **Test 12 dispatcher discovery is derived, never hardcoded.** The set is
  computed at run time from the frontmatter `allowed-tools` line, per Step 5.1.
  It currently resolves to 8 commands: hve-doc-ops, hve-implement, hve-plan,
  hve-pr-review, hve-prompt-builder, hve-research, hve-review, hve. A new
  dispatching command is covered automatically. `hve-challenge.md` is correctly
  excluded — its `allowed-tools` is `Read, Write, Edit, Glob, Grep`, no `Agent`.
- **`frontmatter_value` could not be reused** for the `allowed-tools` lookup.
  Its key-strip regex is `/^[a-z]+:[[:space:]]*/`, which does not match the
  hyphenated key `allowed-tools:`, so it would return the line including its
  own key prefix. Test 12 uses a local awk block with an exact
  `^allowed-tools:` strip instead. The shared helper was left unmodified —
  Tests 1/2/3 depend on its current behavior and the phase scope is additive.
- **Test 12 reuses Test 9's command-name carve-out**: a backticked `hve-*`
  token that is itself a command filename is a slash-command reference, not an
  agent reference, and is excluded before the non-empty and resolution checks.
- **Test 13 extraction is restricted to option-list lines** (`^- \`--`), per
  the Step 5.2 GUARD. Run against the fixed tree it produced zero false
  positives, so no further tightening was needed.
- **Test 13 handles the zero-flag case as a pass.** `checkpoint.md` has no
  `--flag` option lines; it reports `no --flag option lines to check` rather
  than failing, so the mapping stays visible in the output without a spurious
  failure.
- **DR-301 confirmed, not assumed.** `grep -n friction .claude/prompts/doc-ops.md`
  returns no matches, so removing `[--friction-log]` from
  `.claude/commands/hve-doc-ops.md:3` (DD-004) leaves Test 13 unaffected.
  Verified before writing the test, not inferred.
- ShellCheck was not available in this environment, so the
  `.claude/instructions/bash.md` ShellCheck-validation item could not be run
  for this phase. Recorded rather than silently skipped.

#### Mutation Evidence (Step 5.3)

**Mutation A** — removed the backticks around `hve-researcher` on
`.claude/commands/hve-doc-ops.md:49`, turning the dispatch line into
`- Spawn parallel hve-researcher subagents (...)`. Result:

```
[ TEST ] Test 12: dispatching commands name a resolvable agent
    [pass] test12: dispatcher discovery: 8 command(s) declare Agent in allowed-tools
    [FAIL] test12: hve-doc-ops names an agent: declares Agent in allowed-tools but its body backticks no `hve-*` agent name
[ FAIL ] Test 12: dispatching commands name a resolvable agent  (1 assertion(s) failed)
Results: 205 passed, 1 failed
```

Test 9 stayed green throughout this mutation (the run produced exactly one
failure, and it was Test 12's). That is the direct demonstration of the M-02
coverage gap: with no backticked token present, Test 9 has nothing to validate
and passes silently, while Test 12's non-empty requirement catches it.

**Mutation B** — the planned mutation (re-adding `` - `continue` ``) was NOT
used, per the Step 5.3 NOTE: `continue` has no `--` prefix and would not be
matched by the `--[a-z-]+` extraction. Confirmed independently by the working
diff — Phase 1 had already replaced the original `` `continue` ``/`` `suggest` ``
option lines in `.claude/prompts/rpi.md` with `--think`/`--subagent-model`.
(superseded — see Correction 2026-07-20)
Actually run: inserted `` - `--resume`: resume from tracking artifacts `` as a
new option line in the `.claude/prompts/rpi.md` options block, after first
verifying `grep -c -- "--resume" .claude/commands/hve.md` returned 0. Result:

```
[ TEST ] Test 13: prompt-file flags exist in the mapped command
    [pass] test13: rpi.md --mode: implemented in hve.md
    [FAIL] test13: rpi.md --resume: rpi.md documents --resume but hve.md never mentions it
    [pass] test13: rpi.md --subagent-model: implemented in hve.md
    [pass] test13: rpi.md --think: implemented in hve.md
[ FAIL ] Test 13: prompt-file flags exist in the mapped command  (1 assertion(s) failed)
Results: 207 passed, 1 failed
```

**Restoration.** Both files were restored from byte-level backups taken before
each mutation and verified with `diff` (no output, byte-identical), plus
residual greps: `--resume` count 0 in `.claude/prompts/rpi.md`, and
`` `hve-researcher` `` count 1 in `.claude/commands/hve-doc-ops.md`. Final
suite: 207 passed, 0 failed, exit 0.

#### Issues Encountered
- **Step 5.3's `git diff --stat` verification could not be applied as written.**
  The step expects the only modified file outside the changes log to be
  `tests/run-drift-tests.sh`, but Phases 1–4 are uncommitted, so `git diff
  --stat` legitimately shows 16 modified files. The intent of the check —
  proving the temporary mutations left no residue — was met instead by byte-level
  `diff` against pre-mutation backups plus targeted residual greps (both recorded
  above), and by confirming the remaining `.claude/prompts/rpi.md` and
  `.claude/commands/hve-doc-ops.md` diffs are Phase 1–4 content. No plan
  deviation in the work itself; only in the verification instrument.

#### Corrections
- Correction (2026-07-20, appended by `/hve-review`): the Mutation B passage above attributes the removal of the `` `continue` ``/`` `suggest` `` option lines to Phase 1. Phase 1 does not own `.claude/prompts/rpi.md`; the details-doc ownership map assigns that file to Phase 4, and plan Step 4.1 is the step that deleted those lines. The substantive reasoning in the passage is unaffected — only the phase attribution was wrong. Record-only fix.
- Correction (2026-07-20, appended by `/hve-review`): the Mutation B rationale stops one inference short. It correctly observes that `continue` has no `--` prefix and so cannot be matched by Test 13's extraction, then treats that as a reason to substitute a different mutation. The unstated consequence is that **Test 13 therefore does not cover the M-07/M-10 defect forms it was written for** — M-07 appeared as `` - `continue`: `` (bare token) and M-10 as `- **Continue**:` (a Modes list, not an option list). Substituting an invented `--resume` flag proved the test can fail, but not that it can catch the original regression class. Escalated by this review as a Major finding; see the review log.

---

### Phase 6: Full verification and global re-sync
Status: Complete
Started: 2026-07-21T05:03:12Z
Completed: 2026-07-21T05:04:50Z
Tests: 207 passed, 0 failed (parent session, full suite)

#### Files Modified
- None in the repo. The installer wrote to `~/.claude/` (commands, agents, instructions, prompts, CLAUDE.md HVE block).

#### Steps Completed
- [x] Step 6.1: `bash tests/run-drift-tests.sh` — **207 passed, 0 failed**. Exceeds the >= 169 + new-assertions floor; the +38 delta is Tests 12 and 13.
- [x] Step 6.2: `./install.sh --global` completed. Output summary: `commands -> ~/.claude/commands/`, `agents -> ~/.claude/agents/`, `~/.claude/instructions/` and `~/.claude/prompts/`, `updated ~/.claude/CLAUDE.md HVE block`, `skipped .gitignore (global mode; rules are per-project)`. No errors.

#### Issues Encountered
- ShellCheck is not installed in this environment (`command -v shellcheck` empty), so the `.claude/instructions/bash.md` ShellCheck-validation requirement could not be run against the new Test 12/13 code. Recorded, not silently skipped; run before merge. Carried up from the Phase 5 report.
- Sequencing note: Step 6.2 syncs `~/.claude` from the working tree, so the global install now carries these changes before `/hve-review` has run. This is the order the approved plan specified. If review demands changes, re-run `./install.sh --global` afterward to re-sync.

---

## Remediation round 2 (post-review, 2026-07-20)

Triggered by `/hve-review` verdict ⚠️ Needs Rework (0 Critical, 3 Major, 10 Minor).
Plan addendum: `## Requirements added after review (2026-07-20)` in the plan file.
Baseline re-captured at 2026-07-21T05:24:53Z: **207 passed, 0 failed**.

### Phase 7: Test 13 coverage repair and canonical-corpus extension (RV-101, Q-201)
Status: Complete
Started: 2026-07-21T05:25:10Z
Completed: 2026-07-21T05:29:20Z
Tests: 211 passed, 0 failed (`bash tests/run-drift-tests.sh`, final run at 2026-07-21T05:29:05Z; baseline was 207/0, +4 assertions from the two new `memory_store_scope` checks and the widened Test 13 corpus)
Lint: not run — `shellcheck` is not installed in this environment (`command -v shellcheck` returns nothing). No lint claim is made for this change.

#### Files Modified
- `tests/run-drift-tests.sh:37-39` — header test-group summary rewritten for the widened Test 13 contract
- `tests/run-drift-tests.sh:547-552` — canonical-block corpus comment now documents `.claude/prompts/*.md` and why it is in scope
- `tests/run-drift-tests.sh:561` — new `memory_store_scope|2|identical` spec registering the per-project memory-store sentence
- `tests/run-drift-tests.sh:567` — `canonical_block_corpus()` now globs `PROMPTS_DIR` alongside `COMMANDS_DIR` and `AGENTS_DIR`
- `tests/run-drift-tests.sh:791-820` — Test 13 doc comment rewritten to state both narrowings (section scoping, resolution scoping) and why neither is optional
- `tests/run-drift-tests.sh:830-875` — new helpers `prompt_option_tokens`, `code_span_contents`, `option_resolves`
- `tests/run-drift-tests.sh:877-918` — `test13_prompt_flag_sync` renamed to `test13_prompt_option_sync` and rebuilt on the helpers
- `tests/run-drift-tests.sh:958-959` — runner registration updated to the new name and label

#### Steps Completed
- [x] Step 7.1 (RV-101): Test 13 repaired. Extraction is section-scoped to `^## (Arguments|Options|Modes)` blocks and accepts three option shapes (`` - `--flag` ``, `` - `bare-token` ``, `- **BoldToken**`); resolution requires the token in the mapped command's frontmatter `argument-hint` or inside a backtick code span in the body — `tests/run-drift-tests.sh:830-918`
- [x] Step 7.2 (Q-201): `PROMPTS_DIR` added to the canonical-block corpus and the memory-store sentence registered — `tests/run-drift-tests.sh:561`, `tests/run-drift-tests.sh:567`
- [x] Step 7.3: Mutation B applied verbatim, suite FAILED, restored from byte-level backup, `diff` clean (evidence below)

#### Design decision: extend vs. companion test
Extended `test13` in place rather than adding a companion function. The contract is unchanged — prompt-documented options must exist in the mapped command — only the extraction and resolution predicates were wrong. A companion test would have duplicated `PROMPT_COMMAND_MAP` and split one invariant across two failure sites, so a future reader fixing a drift would have to discover both. The function is renamed `test13_prompt_option_sync` (from `_prompt_flag_sync`) because it no longer covers only `--flags`.

#### Verification evidence

Step 7.1 extraction, checked against the live tree before running the suite:

```
-- .claude/prompts/checkpoint.md        (none — no Arguments/Options/Modes section)
-- .claude/prompts/doc-ops.md           --scope, --subagent-model
-- .claude/prompts/prompt-build.md      --iterations, --subagent-model
-- .claude/prompts/pull-request.md      --compact, --dimension, --friction-log, --subagent-model
-- .claude/prompts/rpi.md               --mode, --subagent-model, --think, task
-- .claude/prompts/task-challenge.md    --focus, --friction-log
```

The bold lines at `.claude/prompts/doc-ops.md:7-9` under `## What it checks` are correctly
excluded (they are dimension descriptions, not options), confirming the section scoping works.
All extracted tokens resolve; Test 13 is green on the fixed tree with zero false positives.

Step 7.3 — Mutation B (ORIGINAL wording, re-added to the `## Arguments` section of
`.claude/prompts/rpi.md`):

```
- `continue`: Mention "continue" to resume from the most recent tracking artifacts
```

Suite output under the mutation:

```
    [pass] test13: rpi.md --mode: implemented in hve.md
    [pass] test13: rpi.md --subagent-model: implemented in hve.md
    [pass] test13: rpi.md --think: implemented in hve.md
    [FAIL] test13: rpi.md continue: rpi.md documents continue but hve.md implements no such option
    [pass] test13: rpi.md task: implemented in hve.md
[ FAIL ] Test 13: prompt-file options exist in the mapped command  (1 assertion(s) failed)
Results: 211 passed, 1 failed
```

Restoration from the byte-level backup at
`/private/tmp/claude-501/-Users-kevin-GitHub-hve-claude/6de4b518-ef57-4968-a4b2-66fa26f4eb08/scratchpad/rpi.md.bak`:

```
$ diff "$SCR/rpi.md.bak" .claude/prompts/rpi.md
(no output; exit 0)
$ shasum -a 256 .claude/prompts/rpi.md
d37aea73686893129247d771184b1297a1c2d498539beac380fb3defb53851fb  .claude/prompts/rpi.md
```

The sha256 matches the pre-mutation backup taken at the start of the phase, so the mutation
left no residue. (`git diff --stat` still reports 2 insertions / 2 deletions on `rpi.md`;
those are the earlier phases' uncommitted edits, not the mutation.)

Supplementary mutation, M-10 defect class (bold mode names), added to
`.claude/prompts/checkpoint.md` as a temporary `## Modes` section and then reverted:

```
    [FAIL] test13: checkpoint.md Continue: checkpoint.md documents Continue but hve-memory.md implements no such option
    [FAIL] test13: checkpoint.md Save: checkpoint.md documents Save but hve-memory.md implements no such option
    [FAIL] test13: checkpoint.md Update: checkpoint.md documents Update but hve-memory.md implements no such option
Results: 210 passed, 3 failed
```

Restored and re-verified: `diff` clean, suite back to `Results: 211 passed, 0 failed`.

#### Issues Encountered
- `frontmatter_value()` (`tests/run-drift-tests.sh:103-116`) strips the key with `^[a-z]+:`, which does not match the hyphenated key `argument-hint:`, so it returns the value with the key still prefixed. Rather than change a helper five other tests depend on, `option_resolves()` strips the prefix locally with a documented one-line comment. Flagged for the parent as a latent sharp edge, not fixed here (out of phase scope).
- Naive markdown code-span matching with a regex like `` `[^`]*token[^`]*` `` can pair the closing backtick of one span with the opening backtick of the next, false-passing prose that sits between two spans. `code_span_contents()` avoids this by splitting each line on backticks and taking the even-indexed fields, which keeps pairing within a line.
- Adding `PROMPTS_DIR` to the canonical corpus was verified not to change any existing spec's carrier count (checked all ten pre-existing prefixes against `.claude/prompts/*.md`: zero carriers each) before the edit, so no expected-count values needed adjusting.

### Phase 8: rpi-validator instruction repair (Q-202 + DRY minor)
Status: Complete
Started: 2026-07-21T05:26:55Z
Completed: 2026-07-21T05:27:05Z
Tests: 207 passed, 0 failed (`bash tests/run-drift-tests.sh`, run at 2026-07-21T05:27:00Z; matches the post-review baseline of 207/0)

#### Files Modified
- `.claude/agents/hve-rpi-validator.md:50` — unlisted-changes check now names the entire changes log ("every `### Phase N:` section in the document, not only this phase's section")
- `.claude/agents/hve-rpi-validator.md:34-35` — Pre-requisite item 4 paraphrase removed; the details-doc canonical research-absent sentence survives verbatim as the single statement

#### Steps Completed
- [x] Step 8.1 (Q-202): Disambiguated the Step 2 unlisted-changes instruction to whole-document scope, keeping the trailing "If the parent supplied no list, do not infer one." clause intact — `.claude/agents/hve-rpi-validator.md:50`
- [x] Step 8.2 (Minor, DRY): Collapsed the duplicated research-absent rule; item 4 now reads "Read the research document if the parent supplied one" and the sub-bullet carries the canonical wording byte-identical to the details doc and to `.claude/agents/hve-plan-validator.md:34` — `.claude/agents/hve-rpi-validator.md:34-35`

#### Issues Encountered
- Scope held to the two targeted defects. The Subagent Response Protocol section, all template blocks (including the `## Unlisted Changes` N/A branch at lines 89-91), section order, and item numbering are unchanged.
- Neither edited sentence is registered in `CANONICAL_BLOCK_SPECS` (`tests/run-drift-tests.sh:544-555`), so no drift test enforced the pre-edit text; verified before editing.

#### Discrepancies & Decisions
- DD-008 (2026-07-21): Step 8.1 changes the body instruction that the details doc pins verbatim under "Canonical wording → Unlisted-changes check (Step 1.2, hve-rpi-validator.md)" (`.claude-hve-tracking/details/2026-07-20/unowned-file-remediation-details.md:40`). This is a plan-licensed contract change (Phase 8 Step 8.1 explicitly authorizes it), not an unrecorded drift. The details-doc canonical block is now superseded by the file; the details doc is not owned by this phase, so the correction is surfaced to the parent rather than applied here.

### Phase 9: Residual documentation drift (2 Minor)
Status: Complete
Started: 2026-07-21T05:26:32Z
Completed: 2026-07-21T05:27:41Z
Tests: 207 passed, 0 failed (`bash tests/run-drift-tests.sh`, run 2026-07-21T05:27Z)

#### Files Modified
- `.claude/commands/hve-prompt-builder.md:61` — replaced stale "After both subagents complete" with sequential wording naming Step A's tester log and Step B's evaluator findings
- `docs/internals.md:25` — added the Template Integrity criterion (plus the previously omitted actionability criterion) to the `hve-prompt-evaluator` roster-table description

#### Steps Completed
- [x] Step 9.1: Reworded `.claude/commands/hve-prompt-builder.md:61` to match the sequential tester→evaluator dispatch established by Step 2.1. Sequencing logic itself untouched.
- [x] Step 9.2: Extended the `hve-prompt-evaluator` row in `docs/internals.md` to name the Template Integrity criterion defined in the agent's `## Evaluation Criteria` section, with a parenthetical gloss of what it checks.

#### Issues Encountered
Step 9.2 citation form: `docs/internals.md` is a living doc, so the addition anchors to the
criterion name (`Template Integrity`) and the agent name (`hve-prompt-evaluator`) rather than
to `.claude/agents/hve-prompt-evaluator.md:56-59`. No line-number citation was introduced.

While verifying the criteria list against `.claude/agents/hve-prompt-evaluator.md`, the
internals row was found to omit `Actionability` as well — a pre-existing gap in the same
sentence Step 9.2 was rewriting. Included in the same edit as in-scope repair of the cited
description; no separate finding raised.

Test run returned 207 passed / 0 failed, matching the post-review baseline recorded in the
Phase 7 dependency note. No transient failure or unexpected count, so no re-run was needed
and `tests/run-drift-tests.sh` (owned by a concurrent sibling implementor) was not touched.

### Phase 10: Re-verification and global re-sync
Status: Complete
Started: 2026-07-21T05:28:40Z
Completed: 2026-07-21T05:30:56Z
Tests: 211 passed, 0 failed (parent session, full suite)

#### Files Modified
- `.claude-hve-tracking/details/2026-07-20/unowned-file-remediation-details.md` — Correction appended annotating the superseded unlisted-changes canonical block (DD-008, raised by the Phase 8 implementor, which correctly did not edit a file it did not own)
- No source files. `./install.sh --global` writes outside the repo.

#### Steps Completed
- [x] Step 10.1: Full suite **211 passed, 0 failed**. New green baseline is 211, up from the 207 that entered this round (+4: two canonical-block assertions from Step 7.2, plus the widened Test 13).
- [x] Step 10.2: `./install.sh --global` completed; `~/.claude/` re-synced with the post-remediation tree (commands, agents, instructions, prompts, CLAUDE.md HVE block). No errors.
- [x] Step 10.3: `shellcheck` still not installed (`command -v shellcheck` empty). Recorded as a skip, NOT as a pass. The ~89 lines rewritten in Test 13 remain unlinted. (superseded — see Correction 2026-07-21)

#### Independent verification of the RV-101 fix

The parent did not accept the Phase 7 implementor's mutation evidence on report alone.
Mutation B was re-applied independently, from a separate parent-owned backup, inserting the
original M-07 defect lines verbatim into `.claude/prompts/rpi.md`:

```
[FAIL] test13: rpi.md continue: rpi.md documents continue but hve.md implements no such option
[FAIL] test13: rpi.md suggest: rpi.md documents suggest but hve.md implements no such option
Results: 211 passed, 2 failed
```

Both tokens caught. The `suggest` result is the load-bearing one: `suggest` occurs in prose
at `.claude/commands/hve.md:155`, so the whole-file grep the original Test 13 used would have
resolved it and passed. Catching it proves the new resolution rule (argument-hint or body code
span, never prose or headings) is doing real work rather than merely widening a regex.

Restored from the parent backup; `diff` reported no output (byte-identical) and the suite
returned to 211 passed, 0 failed.

#### Issues Encountered
- Security scan flagged `docs/internals.md` for the secret-pattern grep. **Investigated and
  dismissed as a pre-existing false positive**: lines 59-60 are documentation describing the
  security scanner's own pattern list (the literal strings `PRIVATE KEY`, `api_key =`,
  `Bearer `). `git show HEAD:docs/internals.md` contains the same 2 matches, and this task's
  only diff to that file is the hve-prompt-evaluator table row. Tagged `[pre-existing]` and
  excluded from the tally per the verdict-integrity rules. No secret material present.
- Carried forward unresolved: `frontmatter_value()` (`tests/run-drift-tests.sh:103-116`)
  strips keys with `^[a-z]+:`, which fails on hyphenated keys such as `argument-hint:`,
  returning the value with its key still attached. Two separate implementors have now worked
  around it locally (Phase 5's Test 12 awk block, Phase 7's `option_resolves()`). Five other
  tests share the helper, so fixing it is a real change with real blast radius and was out of
  scope for both. Recommend a dedicated follow-up.

#### Corrections
- Correction (2026-07-21, appended by the round-2 `/hve-review` session): the lint skips recorded in the Status line, Phase 5, Phase 6, and Step 10.3 were true when written but are now resolved. Kevin approved installing ShellCheck per the challenge Q5 escalation rule; `brew install shellcheck` (v0.11.0) succeeded and `shellcheck tests/run-drift-tests.sh` ran clean: 0 errors, 1 `[pre-existing]` SC2155 warning present on HEAD, and one net-new intentional SC2016 info in the Test 12 helper mirroring Test 9's pre-existing idiom. `shellcheck -x` also followed `tests/lib/assert.sh` with no findings. The gate is closed as Pass; full detail in `.claude-hve-tracking/reviews/rpi/2026-07-21/unowned-file-remediation-review.md`.

#### Discrepancies & Decisions
- DD-008 (2026-07-21): the Phase 8 implementor flagged that its Step 8.1 edit superseded the
  details doc's canonical unlisted-changes block, and correctly declined to edit a file
  outside its ownership map. The parent appended the Correction to the details doc in this
  phase. Recording the ownership-respecting escalation as the desired behavior.

---

## Security Hygiene Check

Run 2026-07-21T05:04:50Z (parent session).

- `git diff HEAD --name-only`: 16 files, all `.claude/` prompt/command/agent markdown plus `tests/run-drift-tests.sh`. Exactly the details-doc ownership map; no credential-like files.
- Secret pattern scan (`PRIVATE KEY|api_key\s*=|password\s*=|-----BEGIN|Bearer `) across all 16 changed files: **no matches**.
- `.gitignore` hygiene: `.env` (:21), `.env.*` (:22), `*.pem` (:23), `*.key` (:24), `*.p12` (:25) all present.
- New dependencies: none added.

Status: **Pass**.

