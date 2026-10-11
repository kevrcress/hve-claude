# Planning Log: Output-Quality Regression Checks for HVE Agent/Command Files
Date: 2026-08-19
Task slug: rpi-output-quality-regression

## Discrepancies

### DR-001: Research's two researchers disagreed on the baseline's role
Source: Research finding 4 / Open Question 1 — fixtures researcher proposed committed baselines as authoritative "before" comparators; E2E researcher showed only fresh same-session pairs are valid (tester is model:inherit, so cross-session baselines compare across unknown models).
Resolution: Plan adopts the research's reconciled lean — baselines are staleness metadata + recorded expectations; the authoritative regression verdict always comes from a fresh before/after pair in one session (plan Step 3.4-3.5; risk log row 5).
Status: Resolved

### DD-001: Baselines are metadata, not comparators
Source: Design decision closing Open Question 1 (see DR-001).
Assumption: The doubled eval cost of fresh both-sides runs is acceptable because runs are scoped to changed agents only.
Risk: If per-run cost measures much higher than estimated (Step 7.2), the cadence may need loosening — the decision structure survives, the recommended frequency changes.

### DD-002: Judge = compare-mode instruction to hve-prompt-evaluator, no new roster agent
Source: Open Question 2. A purpose-built judge adds drift-test carrier obligations (response protocol test 7, dispatch-target test 12) and a 10th agent file for one conditional role.
Assumption: The sonnet-pinned evaluator can execute a blind side-by-side comparison from dispatch-prompt instructions alone.
Risk: Compare quality may be weaker than a dedicated prompt; mitigation is the recorded follow-on (details file, "Deferred") rather than up-front complexity.

### DD-003: Output-quality rubric passes through the evaluator's free-form criteria input
Source: Open Question 3. Research verified the input accepts arbitrary criteria without agent edits (hve-prompt-evaluator.md:15-22).
Assumption: RPI-output artifacts do not need a distinct grader prompt for v1; the rubric + answer key give the evaluator enough structure.
Risk: Evaluator's six built-in dimensions (prompt-text quality) may bleed into output grading; the rubric explicitly instructs grading the execution log against the scenario properties only.

### DD-004: hve-rpi-validator scenarios deferred
Source: Open Question 4. The hve-rpi-validator.md:83 hardcoded [CRITICAL] template defect (fix deferred by Kevin 2026-08-15) would make any seeded-severity scenario fail on the known defect, not on a regression.
Assumption: Deferring one HIGH-radius agent's coverage is better than either fixing the defect out-of-scope or committing a scenario that is red from birth.
Risk: The widest "wrong severity by construction" agent stays uncovered until the defect fix lands. Surfaced to Kevin at the plan checkpoint.

### DD-005: Staleness check fails (not warns), with opt-in coverage
Source: Research finding 7 left "failing or warning" open; assert.sh has only pass/fail semantics (no warn primitive).
Assumption: FAIL is acceptable because only agents with a committed baseline.md are checked — coverage grows deliberately, and the failure message names both remedies (run regress, or update baseline).
Risk: A contributor may update baseline.md by hand to silence the nag without running regress; history append-only rule makes that visible in review.

### DD-006: E2E tier is documented procedure, not tooling
Source: Research finding 5 (1M-3M tokens per comparison; pre-release only) and finding 7 (no CI, no hook-driven spend).
Assumption: A documented manual procedure in CLAUDE.md is sufficient for a tier expected to run a few times per release cycle.
Risk: An undocumented-in-practice procedure may simply never be run; the staleness nag and per-edit tier carry the actual regression-catching load.

### DD-007: Token costs remain unmeasured at plan time
Source: Open Question 5. No LLM dispatch was run during planning (planning spends no eval tokens by design).
Assumption: The research's order-of-magnitude estimates are good enough to sequence phases; Step 7.2 replaces them with measured figures before the cadence is documented as settled.
Risk: If measurement lands 10x higher, the per-edit cadence for all 13 HIGH-radius files becomes impractical; Phase 6 text must then be written from the measured number, not the estimate (Step 6.2 depends on Step 7.2 output — implementor should draft 6.2's cost figures last or mark them provisional).

### DD-008: Fixture format aligned with `claude plugin eval` case format (plan v2)
Source: User question at the plan checkpoint ("any third-party or built-in tools?") triggered a claude-code-guide consult; research Correction 2026-08-19 records the findings. `claude plugin eval` (early-access, org-gated) targets `.claude/`-directory repos without plugin packaging and natively provides graders, sandboxed runs, 3-run defaults, cost ceilings, and JSON reports.
Assumption: Authoring fixtures as `evals/<agent>--<slug>/prompt.md` + `graders/` makes them directly runnable by the native harness when access lands, while remaining parseable by the in-session runner today. Supersedes the v1 `tests/fixtures/agent-scenarios/` scenario.md/answer-key.md layout before anything was built.
Risk: The eval format details are [MEDIUM] (recorded from help-text-level verification while gated; version-gated ~v2.1.210+). Mitigated by the Step 1.1 probe and the README change log; the in-session runner is the authoritative consumer until GA.

### DD-009: Dual-runner strategy; single-side default, before/after as escalation (amends DD-001 mechanics)
Source: Same consult (DD-008). With deterministic regex graders plus an llm rubric, absolute single-side grading carries most of the regression signal at roughly half the dispatch cost.
Assumption: Default = grade the current (after) side against fixed graders (~2 dispatches/case); escalate to a fresh same-session before/after pair + blind compare only on a grader failure or degradation vs recorded expectations. DD-001's core holds unchanged: cross-session baselines are never authoritative comparators; every before/after pair runs fresh in one session.
Risk: A subtle regression that still passes all graders goes undetected by the default path; accepted — graders are the definition of "quality floor", and the pre-release E2E tier exists for whole-chain drift.

### DD-010: `claude -p` recorded as the E2E-tier scripting substrate
Source: Same consult. Headless mode returns `total_cost_usd` + token usage as JSON with `--max-turns`/`--max-budget-usd` bounds, but cannot invoke slash commands or route to subagents, so it fits the scripted-E2E role only.
Assumption: Documenting it in the CLAUDE.md tier section (Step 6.2) is sufficient for v1; no script is built.
Risk: None material; documentation-only.

### DD-011: Third-party eval tools rejected
Source: Same consult. promptfoo, DeepEval, inspect-ai, Braintrust/LangSmith all test prompts against the raw API without Claude Code's tool loop, agent frontmatter, or dispatch semantics, and add dependencies (or SaaS accounts) to a deliberately bash-and-markdown repo.
Assumption: Fidelity to the real dispatch environment outweighs their mature tooling; the native harness closes most of the tooling gap anyway.
Risk: If the native harness stays gated indefinitely, promptfoo remains the best third-party fallback for grader-style regression of the fully-inline cases; recorded here so the option isn't lost.
