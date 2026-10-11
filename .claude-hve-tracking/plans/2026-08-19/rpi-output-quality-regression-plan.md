# Implementation Plan: Output-Quality Regression Checks for HVE Agent/Command Files
Date: 2026-08-19
Task slug: rpi-output-quality-regression
Research: .claude-hve-tracking/research/2026-08-19/rpi-output-quality-regression.md (incl. Correction 2026-08-19 on built-in eval tooling)
Status: v2 Validated (Pass, 2026-08-19) — awaiting user approval. Revised per user direction at checkpoint (align fixtures with `claude plugin eval` case format); v1 was separately validated Pass 2026-08-19 before the revision

## Overview

Build a per-edit output-quality regression tier for the 24 distributed prompt files: committed seeded-defect eval cases under `evals/` in the `claude plugin eval` case format (forward-compatible with the gated built-in harness), a new `/hve-prompt-regress` command that probes for plugin-eval availability and otherwise runs the same cases in-session reusing `hve-prompt-tester` and `hve-prompt-evaluator` unchanged, and a zero-token baseline-staleness check in the drift suite. The heavyweight E2E dry-run tier is documented as a pre-release procedure (scriptable later via `claude -p`), not built as tooling. Design decisions are recorded as DD- entries in the planning log (DD-001..DD-011).

## Phases

### Phase 1: Eval-aligned fixture format spec and scaffold
Dependencies: none
Estimated scope: 2 new files (`evals/README.md`, `.gitignore` edit), ~140-200 lines
Success criteria: README fully specifies the case layout, grader files, and baseline format such that Phase 2 needs no format invention; the layout is loadable by `claude plugin eval` as recorded (or divergences are explicitly noted); `evals/results/` is gitignored.

Steps:
- [ ] Step 1.1: Probe harness availability from the parent shell: `claude plugin eval --help` (record exit status and help text). If available, verify the case-format fields against the tool's own help/init output and prefer those; if gated, use the recorded schema below.
  - Assumption: the recorded schema (from a claude-code-guide consult, 2026-08-19: `evals/<case>/prompt.md` with frontmatter `name, tags, runs, max_turns, timeout_seconds, allowed_tools, model`; `graders/*.md` with `type: llm | regex | tool_used | tool_order | file_exists | baseline`; optional `case.yaml` with `scaffold_script`, `add_dirs`; results JSON with per-grader scores) matches the shipped format [MEDIUM — early-access, version-gated ~v2.1.210+; not independently verifiable while gated]
- [ ] Step 1.2: Create `evals/README.md` defining: case directories `evals/<agent-name>--<scenario-slug>/`, each with `prompt.md` (frontmatter: `name`, `tags` including the agent name for `--tag` filtering, `runs`, `max_turns`, `allowed_tools`, optional `model`; body: the exact dispatch input) and `graders/` (regex graders encoding the seeded-defect answer key as mechanical assertions; one `llm` grader carrying the output-quality rubric). Cases needing a frozen mini-tree get `materials/` plus a `case.yaml` wiring it in.
  - Assumption: `case.yaml` `add_dirs`/`scaffold_script` can place `materials/` content into the run workspace [LOW — implementor verifies if the tool is available, else the in-session runner's tempdir copy is the only exercised path and the README says so]
- [ ] Step 1.3: Define the llm-grader rubric vocabulary in the README: `protocol-compliance`, `citation-resolvability`, `verdict-correctness`, `seeded-defect-detection`, `spurious-findings`; tolerance-band grammar `>=N of M detected`, `<=N spurious <severity>`, `AND` conjunctions only. Regex graders carry the per-defect location + severity tokens; the llm grader adjudicates near-misses. Answer-key content lives ONLY in grader files, never in `prompt.md` (the tester/eval subject must not see it).
- [ ] Step 1.4: Define per-agent baselines at `evals/baselines/<agent-name>.md`: header lines `Agent hash: <git hash-object of the agent file>`, `Scenario-set version: <N>`, `Grader: <agent (model)>`, `Model: <session model of last run>`, a per-case results table (verdict, grader results, seeded-defect ledger detected/missed/spurious), and an append-only `## Baseline history` section. Baselines are staleness metadata and recorded expectations, not authoritative comparators (DD-001).
  - The `Agent hash:` line format was verified by the parent during planning: `git hash-object .claude/agents/hve-plan-validator.md` → `4cafc7bd86765f46dfa20c58b9c56f0bb3f9af47`; a baseline written with that line, re-extracted via `grep -m1 '^Agent hash: ' baseline.md | awk '{print $3}'`, compared equal on the fresh file and unequal (`96c34f3...`) on a simulated edit [HIGH]
- [ ] Step 1.5: Add `evals/results/` to `.gitignore` (plugin eval's default output dir is regenerable noise; committed material is cases + baselines only).

### Phase 2: Prototype case — hve-plan-validator
Dependencies: Phase 1
Estimated scope: 4-5 new files under `evals/hve-plan-validator--seeded-plan-defects/` + `evals/baselines/hve-plan-validator.md`, ~150-250 lines
Success criteria: one complete conforming case with at least 3 seeded defects spanning at least 2 severities, regex graders for each seeded defect, one llm rubric grader; baseline records the current agent hash; a dry read-through confirms the in-session runner can derive the tester's inputs (file path, dispatch input, sandbox path) from `prompt.md` alone.

Steps:
- [ ] Step 2.1: Author `prompt.md` in the all-inline form (no `materials/`): the body embeds a small fabricated research doc plus a plan containing seeded defects, framed as the dispatch input for `hve-plan-validator`.
  - Assumption: `hve-plan-validator` accepts fully-inline research + plan content in its dispatch prompt without agent-file edits (research finding 3) [HIGH per research; the implementor re-reads the agent file before authoring]
- [ ] Step 2.2: Seed at least 3 defects: (a) a plan step claiming "verified" with no adjacent command or citation (expected Major), (b) a key assumption missing a confidence marker (expected Major), (c) a research requirement with no covering plan step (expected Critical coverage gap). Each gets a regex grader (location token + severity token); the llm grader's criteria list all three with expected severities and the tolerance band `>=2 of 3 detected AND 0 spurious Critical`.
- [ ] Step 2.3: Write `evals/baselines/hve-plan-validator.md` per the Step 1.4 format with the current `git hash-object` value (computed by the implementor's parent shell at implement time, not copied from this plan), `Scenario-set version: 1`, results table marked `Results: none — no regress run yet`, and an initial history entry.
- [ ] Step 2.4: Freeze the format: any format change discovered during Phase 4 is made in the README first, then back-propagated here, with a dated note in the README's change-log section.

### Phase 3: New command /hve-prompt-regress (dual-runner)
Dependencies: Phases 1-2
Estimated scope: 1 new file `.claude/commands/hve-prompt-regress.md`, ~140-200 lines
Success criteria: command file passes drift tests 5 and 12 (byte-identical `--subagent-model` paragraph; backticked resolvable `hve-*` agent names); both runner paths are executable end-to-end from the file alone by a fresh session.

Steps:
- [ ] Step 3.1: Create `.claude/commands/hve-prompt-regress.md` with frontmatter: `description`, `argument-hint: [agent-name ...] [--changed] [--subagent-model <sonnet|opus|haiku>] [--friction-log]`, `allowed-tools: Read, Write, Glob, Grep, Bash, Agent`.
- [ ] Step 3.2: Include the `--subagent-model` paragraph byte-identical to the canonical line (verified by the parent during planning via `grep -rhF 'If \`--subagent-model' .claude/commands/ | sort -u` → exactly one distinct line across 7 carriers): "If `--subagent-model <sonnet|opus|haiku>` is present in `$ARGUMENTS`, strip it before other argument parsing and pass its value as the `model` parameter on every Agent tool call; this overrides each subagent's frontmatter model. If absent, omit the parameter so frontmatter applies." [HIGH]
- [ ] Step 3.3: Target selection: explicit agent-name arguments win; `--changed` derives targets from `git diff --name-only HEAD -- .claude/agents/ .claude/commands/` run by the parent; targets without a case directory (`evals/<agent>--*`) are reported as "no cases — skipped", never silently dropped.
- [ ] Step 3.4: Runner probe: parent runs `claude plugin eval --help`; on success (exit 0), tell the user the native harness is available and ask before spending: proposed invocation `claude plugin eval . --tag <agent> --json --max-cost-usd <ceiling>`, then parse the results JSON per-grader scores into the verdict. On nonzero exit (gated/absent), fall through to the in-session runner without asking (DD-009).
  - Assumption: `--tag` filtering and `--json` output behave as recorded [MEDIUM — same early-access caveat as Step 1.1; the command text tells the session to adapt to the tool's actual help output]
- [ ] Step 3.5: In-session runner, default single-side (all shell in the parent, per Subagent Dispatch Discipline): for each case, (1) parent copies `materials/` (if any) into a tempdir and substitutes paths in the dispatch input; (2) dispatch `hve-prompt-tester` with the CURRENT agent file + `prompt.md` body + a sandbox output path under `.claude-hve-tracking/sandbox/YYYY-MM-DD-regress-run-N/`; (3) parent greps the execution log for each regex-grader pattern (mechanical seeded-defect ledger); (4) dispatch `hve-prompt-evaluator` with the execution log + the llm grader's criteria passed through its free-form quality-criteria input.
- [ ] Step 3.6: Escalation to before/after: only when the single-side run fails a grader or degrades against the baseline's recorded expectations, parent writes the before side via `git show HEAD:.claude/agents/NAME.md` into the sandbox and repeats Steps 3.5(2)-(4) for it, then dispatches `hve-prompt-evaluator` once in compare mode — blind, order-randomized side-by-side of the two execution logs (DD-002; instructions live entirely in this command's dispatch prompt). This distinguishes "the edit regressed it" from "it was always failing".
  - Assumption: `git show HEAD:path` yields the pre-edit content even when the working-tree edit is uncommitted [HIGH, research finding 4]
- [ ] Step 3.7: Verdict per target: Pass / Regressed / Inconclusive, with the seeded-defect ledger. Nondeterminism: single run with tolerance bands is the default; a verdict flip at identical agent hash and model escalates to 3-run majority for that case only (the native harness does 3 runs by default, so this applies to the in-session path).
- [ ] Step 3.8: Baseline update: refresh `Agent hash:`, `Model:`, results table, and append a dated history entry; on Regressed the run is still recorded. End with a completion summary; no HANDOFF block (utility command, per `/hve-prompt-analyze` precedent — implementor confirms against hve-prompt-analyze.md before writing [MEDIUM]) and the friction-log paragraph consistent with the other dispatching commands.

### Phase 4: Wave-2 cases for HIGH-radius graders
Dependencies: Phases 2-3
Estimated scope: 8-12 new files under `evals/`, ~400-700 lines
Success criteria: `hve-implementation-validator`, `hve-pr-reviewer`, and `hve-researcher` each have at least 1 committed conforming case (target 2 for the two validators) with graders and baselines; `hve-rpi-validator` is explicitly deferred (DD-004) with a README note.

Steps:
- [ ] Step 4.1: `hve-implementation-validator--seeded-security-defects`: `materials/` mini-tree (small fabricated plan + changes log + 2-3 source files) seeding a security-dimension defect (hardcoded credential pattern) and a spec-deviation Major; regex graders for both, llm rubric grader.
- [ ] Step 4.2: `hve-pr-reviewer--severity-discrimination`: `materials/` frozen diff file seeding one Critical (broken error path) and one Minor (style), to test severity discrimination — the observed failure mode [MEDIUM — the "often wrong severity" signal is from user memory, not a measured baseline]
- [ ] Step 4.3: `hve-researcher--citation-fidelity`: `materials/` mini-tree where the correct answer requires citing 2 specific `file:line` locations; graders check citation resolvability into the fixture tree and confidence-marker presence.
- [ ] Step 4.4: README note: `hve-rpi-validator` cases deferred until the hardcoded `[CRITICAL]` template defect (hve-rpi-validator.md:83) is fixed — a seeded-severity case would fail on the known defect, not on regressions (DD-004).

### Phase 5: Drift-suite baseline-staleness check
Dependencies: Phase 2 (at least one baseline exists)
Estimated scope: 1 modified file (`tests/run-drift-tests.sh`), ~45-70 new lines
Success criteria: `tests/run-drift-tests.sh` passes with the new Test 17 on a clean tree; a simulated agent edit (scratch copy) flips the assertion to FAIL naming `/hve-prompt-regress`.

Steps:
- [ ] Step 5.1: Add `test17_baseline_staleness`: for each `evals/baselines/*.md`, derive the agent name from the filename, extract the recorded hash via `grep -m1 '^Agent hash: ' | awk '{print $3}'`, compute `git hash-object .claude/agents/NAME.md`, `_fail_inline` on mismatch with detail "baseline stale — run /hve-prompt-regress NAME or update the baseline". Emit an `_ok_inline` "no baselines yet" only when the glob matches nothing.
  - The extraction/comparison mechanism was run by the parent during planning (see Step 1.4 evidence); the test body is a direct transcription of that verified spike, with the surrounding idiom matched to run-drift-tests.sh at implement time [HIGH]
  - Assumption: coverage is opt-in — only agents with a committed baseline are checked, so the test never blocks edits to un-baselined agents (DD-005) [HIGH by construction]
- [ ] Step 5.2: Register in `main()` as `run_test "Test 17: eval baselines are fresh" test17_baseline_staleness` after Test 16 (tests/run-drift-tests.sh:1261 region); update the file-header inventory comment if one exists.
- [ ] Step 5.3: Run the full drift suite; all tests including Test 17 must pass on the completed tree.

### Phase 6: Documentation and integration
Dependencies: Phases 3, 5
Estimated scope: 2-3 modified files (repo `CLAUDE.md`, possibly `docs/`), ~50-90 lines
Success criteria: repo CLAUDE.md Command Reference has an `/hve-prompt-regress` row; the three-tier cadence is documented once, including the native-harness forward path; drift tests 13/14/15 still pass.

Steps:
- [ ] Step 6.1: Add `/hve-prompt-regress` to the repo `CLAUDE.md` Command Reference table; flags documented must exactly match Step 3.1's argument-hint (drift test 13).
- [ ] Step 6.2: Add a `## Output-Quality Regression` section to repo CLAUDE.md documenting: (1) per-edit `/hve-prompt-regress` scoped to changed agents, with the dual-runner behavior (native `claude plugin eval` when enabled, in-session fallback otherwise) and measured costs from Step 7.2 (draft this text last or mark figures provisional, per DD-007); (2) the zero-token staleness nag in the drift suite; (3) the pre-release E2E dry-run procedure — documented steps only, flagged at the research's ~1M-3M token estimate, noting `claude -p --output-format json --max-turns N --max-budget-usd X` as the scripting substrate when it is eventually automated (DD-010). Section cross-references must resolve (drift test 14).
- [ ] Step 6.3: Check `docs/` for pages enumerating commands or tests; update any list that claims completeness, else record `docs: no enumerating page — no edit` in the changes log.
  - Assumption: docs/ structure was not researched [LOW — implementor globs docs/ before deciding]
- [ ] Step 6.4: Do NOT edit `~/.claude/CLAUDE.md` directly; global sync happens via `./install.sh --global` after merge.

### Phase 7: Verification and cost measurement
Dependencies: Phases 2-6
Estimated scope: no new files; one measured run (~2 subagent dispatches; optionally one native-harness run if access exists)
Success criteria: full drift suite green; install tests green; prototype case executed once via the in-session runner with token cost recorded in the details file.

Steps:
- [ ] Step 7.1: Run `tests/run-drift-tests.sh` and `tests/run-install-tests.sh`; both must pass. The new command file is picked up by install.sh's existing command-directory copy (install.sh:79) with no installer edit; `evals/` is repo-local test material and is NOT distributed by the installer [HIGH per research finding 2 — implementor confirms install.sh copies only .claude/ subdirs].
- [ ] Step 7.2: Execute the prototype case once via the in-session runner path (Steps 3.5(1)-(4); single side, no edit under test). Record rubric results, seeded-defect ledger, and actual token cost per dispatch in the details file, replacing the research's unmeasured estimates (research Open Question 5). If Step 1.1's probe found the native harness enabled, additionally offer Kevin one gated run `claude plugin eval . --tag hve-plan-validator --json --max-cost-usd 5` and record its report alongside — ask before spending.
  - Assumption: a single-side run suffices for cost measurement and format shakeout; the escalation path is exercised on the first real agent edit [MEDIUM]
- [ ] Step 7.3: Update `evals/baselines/hve-plan-validator.md` results from the Step 7.2 run and append the history entry, so Test 17 has a populated, fresh baseline on the completed tree.

## Risk Log
| Risk | Likelihood | Mitigation |
|---|---|---|
| Early-access eval format drifts from the recorded schema before GA | Medium | Format captured as [MEDIUM] with an implement-time probe (Step 1.1); the in-session runner consumes the same files and is authoritative until the native harness is available; README change-log tracks realignments |
| Native harness never becomes available to Kevin | Medium | The in-session runner is complete on its own; nothing in the harness path is load-bearing (probe-and-fallback, DD-009) |
| Nondeterministic grading makes Pass/Regressed flap | Medium | Regex graders are deterministic; tolerance bands on the llm grader; 3-run majority escalation only on a verdict flip at identical hash+model (Step 3.7) |
| Staleness test nags on every baselined-agent edit | Medium | Opt-in coverage (only baselined agents); FAIL message names both remedies; documented in the CLAUDE.md tier section |
| Evaluator compare-mode (judge role) underperforms | Medium | Compare mode is now escalation-only (Step 3.6), so exposure is rare; a purpose-built judge agent is a recorded follow-on if calibration shows weakness |
| Token-cost estimates wrong by an order of magnitude | Medium | Step 7.2 measures before the cadence is documented as settled; Step 6.2 figures drafted from measurement |
| Model drift invalidates comparisons (tester is model:inherit) | High | Single-side grading is against fixed graders, not a cross-session run; before/after pairs always run fresh in one session (DD-001/DD-009); baseline records the model |
| Answer keys leak into the eval subject's input | Low | README rule (Step 1.3): grader files only; `prompt.md` never contains expected findings; command flow enforces the separation |

## Testing Approach

Deterministic layers first: the full drift suite (including new Test 17) and install tests must pass on the completed tree — zero-token, gating every phase-end. Behavioral layer: one measured in-session run of the prototype case (Step 7.2) validates that the tester consumes `prompt.md`, the evaluator consumes the llm-grader criteria through its free-form input, and the parent can grade the regex-grader ledger mechanically. The native-harness path is exercised only if access exists (with an explicit cost ceiling and Kevin's go-ahead); its absence does not block acceptance. The before/after escalation path is intentionally not exercised until a real agent edit occurs; its first use is itself the acceptance test, with Inconclusive as the designed fallback verdict.
