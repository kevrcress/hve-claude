# Research: Output-Quality Regression Checks for HVE Agent/Command Files
Date: 2026-08-19
Task slug: rpi-output-quality-regression
Confidence: HIGH overall (repo-state claims verified by four parallel researchers; design recommendations are MEDIUM, as marked)

## Summary

Nothing in the repo today executes an HVE agent and grades the quality of its output: the drift suite is purely static, the prompt-builder loop simulates rather than dispatches and grades prompt text rather than RPI output, and everything a test run produces is gitignored. The building blocks for a regression harness already exist, however: the tester/evaluator agents accept fixture-shaped inputs without modification, tests/fixtures/ has a proven seed-and-assert idiom, and tests/run-prompt-upgrade.sh proves the seed-fixture, execute-agent, assert-output pattern works here. The recommended direction is a new lightweight /hve-prompt-regress command over committed seeded-defect scenarios in tests/fixtures/agent-scenarios/, with a deterministic staleness nag in the drift suite and a heavyweight E2E dry-run tier reserved for pre-release.

## Key Findings

### 1. Background claims: verified, with four corrections

- Drift suite claim confirmed in substance, count corrected: 16 labeled test groups but Test 6 is retired, so 15 execute (tests/run-drift-tests.sh:359-373, tests/run-drift-tests.sh:1233-1261). Every group is a static grep/awk assertion; none executes an agent or grades output quality [HIGH]
- The script has no argument parsing or modes: main() ignores "$@" (tests/run-drift-tests.sh:1266, usage at :4); a heavier opt-in mode would be net-new parsing, though the ASSERT_LOG harness (tests/lib/assert.sh:10, :106-116) extends cleanly [HIGH]
- Correction: hve-prompt-tester does NOT literally execute the agent under test. It simulates the scenario inside its own context ("Simulate the scenario", .claude/agents/hve-prompt-tester.md:38-39) and its tools are Read, Write, Glob, Grep only (no Agent, no Bash; :6), so it cannot dispatch anything [HIGH]
- Confirmed: no draft-ness check exists in the tester; it reads whatever path it is given (.claude/agents/hve-prompt-tester.md:17-20, :26-32). Prompt-builder's stated scope is "authoring and improving" (.claude/commands/hve-prompt-builder.md:2,7) so shipped files are in scope, but no procedure step seeds an existing file as the iteration input (:33, :86-90) [HIGH]
- Confirmed: scenarios are invented fresh each run, 2-3 per run, never loaded from anywhere persistent (.claude/commands/hve-prompt-builder.md:47) [HIGH]
- Confirmed: all loop output (execution logs, test-summary, evaluation.md, update-log, intermediate drafts) lands under .claude-hve-tracking/sandbox/, which is gitignored (.gitignore:4; subagents/ ignored at .gitignore:3). Nothing from any test run persists in version control [HIGH]
- Correction: hve-prompt-evaluator grades PROMPT TEXT quality (six dimensions: clarity, completeness, actionability, format compliance, Copilot-isms, template integrity; .claude/agents/hve-prompt-evaluator.md:29-59), not the quality of RPI output the prompt would produce. An output-quality rubric must be supplied separately; its free-form "quality criteria" input accepts one without agent edits (.claude/agents/hve-prompt-evaluator.md:15-22) [HIGH]
- Correction: a second execute-and-assert mechanism exists. tests/run-prompt-upgrade.sh seeds a temp project, has a human run Claude Code against a printed prompt, then asserts structural outcomes (tests/run-prompt-upgrade.sh:29-74, :98-118, :136-173). It asserts structure only, but it is direct in-repo precedent for the seed-fixture / run-agent / assert-output shape [HIGH]
- No prior research on this topic exists from earlier today; all four 2026-08-19 research files belong to the claude-md-lean-restructure task [HIGH]

### 2. Blast radius: 24 prompt files, 13 classified HIGH, all distributed by the installer

- Inventory: 9 agents + 15 commands, no omissions (.claude/agents/, .claude/commands/) [HIGH]
- install.sh copies every agent and command verbatim to target projects (install.sh:79, install.sh:82), and global mode targets ~/.claude for every project on the machine (install.sh:17-19, :77). There is no test gate between editing a prompt file and distributing it [HIGH]
- HIGH-radius agents: hve-researcher (widest fan-in, 3 dispatchers: .claude/commands/hve.md:68, hve-research.md:63, hve-doc-ops.md:50), hve-phase-implementor (writes the changes log, review's unreconstructible input; only agent with no tools: frontmatter, so it inherits everything including Bash/Edit; .claude/agents/hve-phase-implementor.md:1-6), hve-plan-validator, hve-rpi-validator, hve-implementation-validator, hve-pr-reviewer, plus hve-prompt-evaluator as meta-grader [HIGH]
- HIGH-radius commands: hve, hve-research, hve-plan, hve-implement, hve-review, hve-pr-review (each orchestrates gates or produces artifacts two downstream phases consume) [HIGH]
- Both haiku-pinned agents guard quality gates: hve-plan-validator.md:4 and hve-rpi-validator.md:4. Cheapest models sit on the gates with the highest "well-formed but wrong" exposure [HIGH]
- Structural proof the failure mode is real: hve-rpi-validator's findings template hardcodes `[CRITICAL]` severity (.claude/agents/hve-rpi-validator.md:83), a known deferred defect. Perfect format, wrong severity by construction [HIGH]
- Top 5 files where degraded output stays structurally perfect while substantively wrong (priority targets for seeded-defect scenarios): hve-implementation-validator, hve-pr-reviewer, hve-rpi-validator, hve-plan-validator, hve-researcher. Supporting observed signal: user memory records that subagent severity tags and Fail verdicts are often wrong [MEDIUM]

### 3. Scenario fixtures: committed under tests/fixtures/agent-scenarios/, hybrid format

- Fixtures must be committed and live in tests/fixtures/agent-scenarios/AGENT-NAME/SCENARIO-SLUG/, not under .claude-hve-tracking/: sandbox/ and subagents/ are gitignored (.gitignore:3-4), tracking artifacts are dated snapshots by convention (CLAUDE.md:368-377), and fixtures must version in lockstep with the agent files they test so a same-commit review sees both [HIGH]
- The existing fixture idiom transfers directly: descriptive kebab-case names, copy into mktemp workdirs (tests/run-install-tests.sh:16, :201), sentinel strings for exact-grep assertions (tests/fixtures/claude-md-no-hve.md:3), shared assert.sh tally (tests/lib/assert.sh:34-116) [HIGH]
- Fixed scenarios slot into the existing agents WITHOUT editing them: the tester needs only {file path, scenario descriptions, sandbox path} (.claude/agents/hve-prompt-tester.md:17-21) and the evaluator's quality-criteria input is free-form, so an output-quality rubric passes through unmodified (.claude/agents/hve-prompt-evaluator.md:15-22) [HIGH]
- Recommended fixture shape [MEDIUM]: scenario.md (frontmatter: agent, id, version; sections: exact dispatch input, expected-property rubric) plus a materials/ frozen mini-tree copied to a tempdir so results never drift with the live repo, plus a hidden answer-key.md of seeded defects (path:line, expected severity, expected category) for the five grader-type agents. Agents with fully-inline inputs (e.g. plan-validator) can use the degenerate all-inline form
- Seeded-defect grading is the strongest regression signal: "did the reviewer still catch the seeded Major" is a crisp binary that survives phrasing nondeterminism, and it can be graded partly mechanically (grep the output artifact for the seeded path and severity token), shrinking grader token cost [MEDIUM]
- Nondeterminism handling [MEDIUM]: single-run property-based grading (protocol compliance, citation resolvability into fixture materials, correct verdict, seeded-defect detection) with tolerance bands on count-type items (e.g. 3 seeded Majors passes at >=2 detected AND 0 spurious Critical); escalate to 3-run majority only when a verdict flips at the same agent hash and model. Rejected as default: N-run majority everywhere (3x cost)
- Free first layer [HIGH]: extend the zero-token static property checks in tests/run-drift-tests.sh (test 7 already property-checks protocol structure at :390-448) before spending any LLM tokens; spend tokens only on behavioral properties statics cannot see

### 4. Result persistence: committed baselines as metadata, fresh both-side runs as the valid comparison

- A recorded evaluation needs, per run [MEDIUM]: date, agent name + agent-file content hash (git hash-object, computed by the parent shell; content hash beats commit SHA in a dirty tree), scenario-set version, model used, per-scenario verdict + rubric item results + severity counts + seeded-defect ledger (detected/missed/spurious), and grader identity + hash (a grader edit also invalidates comparison)
- Proposed home [MEDIUM]: one committed baseline.md per agent at tests/fixtures/agent-scenarios/AGENT-NAME/baseline.md with a results table and an append-only "Baseline history" section (dated entries, old hash to new hash, reason). CLAUDE.md's Corrections convention (CLAUDE.md:158-166) strictly governs tracking snapshots, not test specs, but its no-silent-rewrite principle carries over cheaply via the history section [HIGH on the convention scope, MEDIUM on the design]
- Critical validity constraint [HIGH]: hve-prompt-tester is model: inherit (.claude/agents/hve-prompt-tester.md:4), so a stored baseline produced under a different session model is not comparable; hve-prompt-evaluator is pinned sonnet (.claude/agents/hve-prompt-evaluator.md:4, CLAUDE.md:67), which stabilizes the grader side. --subagent-model can force a tier for one run but cannot pin exact model IDs (CLAUDE.md:62-71)
- Consequent design tension the plan phase must resolve (see Open Questions): the fixtures researcher proposes committed baseline rows as the "before" side; the E2E researcher shows the only robust comparison runs BOTH sides fresh in the same session, obtaining the pre-edit file via `git show HEAD:.claude/agents/X.md` into sandbox/ (works even for uncommitted edits; HEAD is naturally the before side; shell stays in the parent per CLAUDE.md:200-202). Reconciled recommendation [MEDIUM]: baselines serve as staleness metadata and recorded expectations; the authoritative regression verdict comes from a fresh before/after pair in one session. Fresh both-sides doubles eval cost per run; validity beats cost here
- Storage itself has zero ongoing token cost; the recurring cost is reruns. Reruns scoped to agents changed in the diff cost roughly 2-6 subagent dispatches (~50-200k tokens) per edit; a full-roster rerun (~25+ dispatches) is rejected as a per-edit practice [MEDIUM, unmeasured]

### 5. E2E dry runs: real precedent exists but historical chains are exemplars, not benchmarks

- Three full historical RPI chains exist in the window plus one partial: friction-log-remediation (2026-07-17), unowned-file-remediation (2026-07-20/21), think-skill-grep-fallback-audit (2026-08-04/05), and full-repo-review-remediation (2026-08-15, partial: no research artifact, input was reviews/pr/main/2026-08-10-full-repo-review.md) [HIGH]
- Historical runs are NOT re-runnable benchmarks: their seeded problems are since fixed (e.g. the /think defect cited at research/2026-08-04/think-skill-grep-fallback-audit.md:14-15 was fixed in commit 14a937a), and no chain records its producing model. Re-running against live HEAD yields a different task, not a comparable one [HIGH]
- To get a fixed benchmark [MEDIUM]: either pin think-skill-grep-fallback-audit (smallest chain: 2 phases, 2 files, crisp expected findings) to its pre-fix commit via git worktree and treat its known-good artifacts as the answer key, or build a purpose-made frozen seeded-defect fixture under tests/fixtures/ that never moves. The frozen fixture is more durable; the worktree pin is free to set up
- "Graded against a prior run" concretely [MEDIUM]: (a) evaluator re-grading alone is too coarse (Quality Score is six Pass/Fail, .claude/agents/hve-prompt-evaluator.md:81-83; two runs can both Pass while quality moves); (b) structural metrics (severity counts, citation density, confidence-marker distribution, plan step coverage) are cheap and parent-computable by grep but are proxies; (c) a judge agent doing blind, order-randomized side-by-side comparison per artifact pair is most discriminating. Recommended: (b) as the cheap gate, escalating to (c) on any metric drop or for high-blast-radius edits, with (a) reserved for calibrating the judge
- TOKEN COST FLAG [HIGH that it is 5-10x the scenario tier; LOW on the absolute number]: a before/after E2E comparison is ~12-24 subagent dispatches plus 2-6 judge calls, order-of-magnitude 1M-3M tokens per comparison. This cannot be a per-edit check; it is the pre-merge/pre-release tier only. Scenario-based regression at ~5 Agent calls per changed agent is the per-edit tier
- Dry-run output isolates correctly in .claude-hve-tracking/sandbox/ (gitignored, .gitignore:4; structure defined at CLAUDE.md:101) [HIGH]

### 6. Integration: new standalone /hve-prompt-regress command, reusing tester + evaluator unchanged

- Background premise corrected: hve-prompt-builder is only 101 lines, not an already-long file [HIGH]
- Recommended [MEDIUM]: a NEW command (working name /hve-prompt-regress) rather than a --regress flag on /hve-prompt-builder. Dispatch cost per changed agent: 2 sides x (1 tester + 1 evaluator) + 1 judge = ~5 Agent calls (the tester batches 2-3 scenarios per dispatch, .claude/commands/hve-prompt-builder.md:47). Rationale: prompt-builder's author-then-finalize contract (draft in sandbox, ask before writing to .claude/*; :84-90) inverts under a regress mode (input is an already-edited real file, output is a verdict), and the roster already separates authoring from evaluation-only via /hve-prompt-analyze
- A flag on prompt-builder costs the same 5 dispatches and adds no roster entries, but adds ~40-60 branching lines and blurs the command's identity; Phases 1 and 3 become dead weight in regress mode [MEDIUM]
- The judge role can be a compare-mode instruction to hve-prompt-evaluator rather than a new roster agent, avoiding new drift-test carrier obligations (response protocol test 7, dispatch-target test 12); this is an open trade-off [MEDIUM]
- Protocol/model fit: a new command must carry the byte-identical --subagent-model paragraph (drift test 5, tests/run-drift-tests.sh:320-356) and name resolvable hve-* agents (test 12, :761-807). Model layering supports comparability exactly when both sides run in one session; it hinders any stored-baseline replay across sessions [HIGH]

### 7. Triggers and cadence: manual eval, deterministic nag, no hooks-driven spend

- run-drift-tests.sh takes no arguments and has no mode precedent anywhere in tests/ (tests/run-drift-tests.sh:4, :1266; tests/run-install-tests.sh:4). Embedding an LLM eval in it would be a category break (headless claude -p, auth, spend, nondeterministic pass/fail) [HIGH]
- Realistic drift-suite extension [MEDIUM]: a new deterministic test comparing each agent file's git hash against the hash recorded in its committed baseline metadata, failing or warning "baseline stale, run /hve-prompt-regress". Zero tokens, fits the suite's character
- No CI exists (.github/ absent) and no .claude/settings.json exists in the repo; hooks are documented only as an optional per-user example (CLAUDE.md:319-337). Hooks run shell synchronously, so a hook-triggered eval would spawn a session inside a session on every Edit/Write: blocking, expensive, recursion-prone. Realistic hook role at most: append a one-line staleness reminder [HIGH]
- Recommended cadence [MEDIUM], tiered by blast radius: (1) manual /hve-prompt-regress as the only actual eval trigger, scoped to agents changed in the diff, run per edit before merge for the 13 HIGH-radius files; (2) the deterministic staleness nag in drift tests for everyone; (3) full E2E dry run only before a release or after a batch of core edits; (4) LOW-radius files (git helpers, doc-ops, prompt-builder family) periodic/pre-release only. Cost flags: manual = bounded; auto-eval in drift tests = accidental-spend risk; git hook = worst (spend per commit); periodic-only = regressions live undetected between runs

## Codebase References

tests/run-drift-tests.sh — 15 executing static test groups; extension point for a staleness check
tests/run-install-tests.sh — mktemp + fixture-copy + sentinel idiom to inherit
tests/run-prompt-upgrade.sh — semi-manual seed/execute/assert precedent
tests/run-prompt-new-install.sh — same semi-manual pattern
tests/lib/assert.sh — shared assertion tally, exit semantics
tests/lib/prompt-files.sh, tests/lib/instruction-files.sh — shared filename arrays
tests/fixtures/claude-md-no-hve.md — sentinel-string fixture example
.claude/commands/hve-prompt-builder.md — existing test-evaluate-update loop (101 lines)
.claude/agents/hve-prompt-tester.md — simulation-based tester, fixture-compatible inputs
.claude/agents/hve-prompt-evaluator.md — sonnet-pinned grader, free-form criteria input
.claude/agents/hve-prompt-updater.md — rewrite step (not needed by a regress flow)
.claude/agents/hve-researcher.md, hve-phase-implementor.md, hve-plan-validator.md, hve-rpi-validator.md, hve-implementation-validator.md, hve-pr-reviewer.md — HIGH-blast-radius targets
.claude/commands/hve.md, hve-research.md, hve-plan.md, hve-implement.md, hve-review.md, hve-pr-review.md — HIGH-blast-radius commands
install.sh — distributes all 24 prompt files verbatim (:79, :82)
.gitignore — sandbox/ and subagents/ ignore rules (:3-5)
.claude-hve-tracking/reviews/pr/main/2026-08-10-full-repo-review.md — input to the partial 2026-08-15 chain
.claude-hve-tracking/research/2026-08-04/think-skill-grep-fallback-audit.md — smallest full chain; benchmark-pin candidate

## External References

None. All questions were answerable from repo state. (superseded — see Correction 2026-08-19)

Correction (2026-08-19): During the plan checkpoint Kevin asked whether third-party or built-in tooling should be used; a claude-code-guide consult (plan phase, 2026-08-19) found this section incomplete. Claude Code ships `claude plugin eval` (early-access, org-gated; formats stabilized ~v2.1.210), a purpose-built eval harness that targets `.claude/`-directory repos WITHOUT plugin packaging: per-case `evals/<case>/prompt.md` + pluggable graders (regex, llm rubric, tool_used, tool_order, file_exists, baseline ablation), sandboxed per-run workspaces, default 3 runs/case, `--max-cost-usd` ceiling, JSON per-grader scores. This overlaps most of the hand-built harness this research recommended (fixture format, nondeterminism handling, sandbox isolation, cost tracking). Also relevant: `claude -p --output-format json` returns `total_cost_usd` + token usage with `--max-turns`/`--max-budget-usd` bounds (useful for scripting the E2E tier; cannot invoke slash commands or route to subagents), and the Agent SDK can load `.claude/agents/*.md` with per-run usage metrics (rejected: adds a Python/TS toolchain). Third-party eval tools (promptfoo, DeepEval, inspect-ai, Braintrust/LangSmith) were assessed and rejected: they test prompts against the raw API without Claude Code's tool loop and dispatch semantics, and add dependencies. Consequence: the plan's fixture format should align with the `evals/` case format for forward compatibility, with the in-session command as the runner that works today. Eval-format field details are [MEDIUM] (early-access, version-gated, not verifiable in this gated environment beyond help text).

## Open Questions

1. Baseline role (decision needed): are committed baselines authoritative comparators whenever agent hash + scenario version + model all match, or only staleness metadata + recorded expectations, with a fresh same-session before/after pair as the sole valid verdict? The two researchers landed on different sides; the reconciled lean is the latter [MEDIUM]
2. Judge identity: compare-mode instruction to hve-prompt-evaluator (no new roster entry, no new drift carriers) vs. a purpose-built judge agent (cleaner prompt, more carrier obligations)?
3. Rubric delivery: is passing an output-quality rubric through the evaluator's free-form criteria input sufficient, or do RPI-output artifacts (research docs, plans, review verdicts) need a distinct grader prompt?
4. Is fixing the hve-rpi-validator.md:83 hardcoded [CRITICAL] template defect in scope? Seeded-defect scenarios for that agent will trip on it immediately (Kevin deferred it 2026-08-15)
5. All token-cost figures are unmeasured estimates; a one-scenario prototype against hve-plan-validator (fully inline input, cheapest) should replace them before the plan fixes a cadence

## Recommended Research Follow-On

- [ ] Prototype one seeded-defect scenario for hve-plan-validator and measure actual per-rerun token cost (replaces all [LOW] cost estimates)
- [ ] Define the rubric vocabulary (property ids, tolerance-band syntax) so baselines diff mechanically across runs
- [ ] Verify via git (needs parent Bash, so a later phase) that a worktree at think-skill-grep-fallback-audit's pre-fix commit reproduces the seeded /think defect
- [ ] Spec the deterministic baseline-staleness metadata (agent file hash + date) for the new drift test
- [ ] Confirm with Kevin whether shipped-file iteration should also be made explicit in /hve-prompt-builder, or left entirely to the new regress command
