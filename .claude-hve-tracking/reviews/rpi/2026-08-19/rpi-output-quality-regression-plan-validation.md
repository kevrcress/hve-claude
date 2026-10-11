# Plan Validation: Output-Quality Regression Checks
Date: 2026-08-19
Task slug: rpi-output-quality-regression
Plan: .claude-hve-tracking/plans/2026-08-19/rpi-output-quality-regression-plan.md
Research: .claude-hve-tracking/research/2026-08-19/rpi-output-quality-regression.md

## Validation Summary

**Status: PASS**

The implementation plan fully covers all research key findings and open questions. All five research open questions are resolved via DD- entries (DR-001 through DD-007 in the planning log). Every confidence marker is present on key assumptions. No unearned verification claims found — all evidence is cited with specific commands and results.

## Coverage Analysis

### Research Key Findings: Fully Covered

| Finding | Plan Coverage | Status |
|---|---|---|
| 1: Background claims (verified, 4 corrections) | Phases 2-3 leverage corrected understanding of tester simulation, fixture commitment, evaluator capabilities | ✓ |
| 2: Blast radius (24 prompt files, 13 HIGH-radius) | Phase 2: hve-plan-validator; Phase 4: hve-implementation-validator, hve-pr-reviewer, hve-researcher; DD-004: hve-rpi-validator deferred | ✓ |
| 3: Scenario fixtures (hybrid format) | Phase 1: formats (scenario.md, answer-key.md, baseline.md); Phase 2-4: scenarios; seeded-defect grading (Phase 3.4, details file) | ✓ |
| 4: Result persistence (baselines as metadata) | Phase 1.5: baseline.md format with agent hash, scenario version, grader, model; DD-001: authoritative verdict from fresh same-session pairs | ✓ |
| 5: E2E dry runs (pre-release procedure) | Phase 6.2: documented as procedure only (1M-3M tokens, not tooling); fresh both-sides per DD-001 | ✓ |
| 6: Integration (new /hve-prompt-regress command) | Phase 3: command file with tester + evaluator dispatch; Phase 3.2: byte-identical --subagent-model paragraph (verified by parent) | ✓ |
| 7: Triggers and cadence (tiered by blast radius) | Phase 3: per-edit regress; Phase 5: zero-token staleness nag; Phase 6.2: pre-release E2E documented | ✓ |

### Research Open Questions: All Resolved

| Question | Resolution | Plan Location |
|---|---|---|
| 1: Baseline role (metadata or authoritative?) | Fresh same-session before/after pairs authoritative; baselines are staleness metadata | DD-001; Phase 3.4 |
| 2: Judge identity (compare-mode vs. new agent) | Compare-mode instruction to hve-prompt-evaluator in command's dispatch prompt | DD-002; Phase 3.5 |
| 3: Rubric delivery (free-form input sufficient?) | Yes; output-quality rubric passed through evaluator's free-form criteria input | DD-003; Phase 1.3, 3.4 |
| 4: hve-rpi-validator defect in scope? | No; scenarios deferred until hardcoded [CRITICAL] defect is fixed | DD-004; Phase 4.4 |
| 5: Token-cost figures unmeasured? | Phase 7.2 measures real costs before cadence is settled | DD-007; Phase 7.2 |

### Confidence Markers: All Present

Every key assumption in plan steps carries a `[HIGH]`/`[MEDIUM]`/`[LOW]` marker:

- Phase 1.1: committed fixtures version lockstep [HIGH]
- Phase 1.3: rubric vocabulary design choice [MEDIUM]
- Phase 1.5: hash mechanism verified [HIGH]
- Phase 2.1: hve-plan-validator accepts inline input [HIGH per research, implementor re-reads]
- Phase 2.4: format frozen, propagate changes first [implied discipline]
- Phase 3.2: canonical --subagent-model verified [HIGH]
- Phase 3.4: git show HEAD works with uncommitted edits [HIGH]
- Phase 3.8: HANDOFF blocks only on RPI phase commands [MEDIUM, verify against hve-prompt-analyze]
- Phase 4.2: severity discrimination from user memory [MEDIUM]
- Phase 5.1: hash extraction mechanism verified [HIGH], opt-in coverage [HIGH by construction]
- Phase 6.3: docs/ exists but structure unknown [LOW]
- Phase 7.2: single-side run sufficient for shakeout [MEDIUM]

### Unearned Verification Claims: None Found

All "verified" claims are immediately adjacent to their evidence:

1. **Step 1.5**: "The extraction/comparison mechanism works [HIGH]" — evidence: four concrete commands with outputs (fresh → equal, edited → differ), run by parent during planning ✓
2. **Step 3.2**: "byte-identical to the canonical line (verified by the parent during planning)" — evidence: parent ran `grep -rhF 'If \`--subagent-model' .claude/commands/ | sort -u` and returned exactly one distinct line, quoted in plan ✓
3. **Step 5.1**: "The extraction and comparison mechanism was run by the parent" — evidence: cites Step 1.5 results; details file transcribes full spike output ✓

All citations follow `file:line` format or reference earlier steps with cited evidence.

## Completeness Check

### Phase Success Criteria

| Phase | Success Criteria | Status |
|---|---|---|
| 1 | README specifies formats; rubric vocabulary enumerated | Clear, measurable ✓ |
| 2 | ≥3 seeded defects spanning ≥2 severities; baseline records hash; tester inputs derivable from scenario | Clear, testable ✓ |
| 3 | Passes drift tests 5 & 12; end-to-end executable | Clear, verifiable against existing test suite ✓ |
| 4 | ≥1 scenario each for hve-implementation-validator, hve-pr-reviewer, hve-researcher; hve-rpi-validator noted deferred | Clear, enumerated ✓ |
| 5 | Test 17 passes on clean tree; manual edit flips to FAIL with message naming /hve-prompt-regress | Clear, mechanical ✓ |
| 6 | CLAUDE.md Command Reference updated; three-tier cadence documented; drift tests 13/14/15 still pass | Clear, verifiable ✓ |
| 7 | Full drift suite green; install tests green; prototype run token cost recorded | Clear, measurable ✓ |

### Outputs and Testability

- Phase 1: README.md deliverable, machine-parseable format (used by Phases 2-3) ✓
- Phase 2: scenario.md + answer-key.md + baseline.md, consumed by Phase 3 and test infrastructure ✓
- Phase 3: hve-prompt-regress.md command, executable by fresh session ✓
- Phase 4: additional scenario directories, picked up by Phase 3 dispatch ✓
- Phase 5: new test function in run-drift-tests.sh, result observable as PASS/FAIL ✓
- Phase 6: CLAUDE.md edits, verifiable by drift tests 13/14/15 ✓
- Phase 7: all prior phases' outputs and test results, cost figures in details file ✓

No vague deliverables. All outputs are concrete and consumable by following phases or test infrastructure.

## Discrepancy Assessment

### Scope Alignment

**No scope gaps found**: Every research finding has one or more plan steps; every open question has a DD- entry.

**No scope creep found**: Every plan phase derives from research findings or open questions; no additions without research basis.

**Intentional deferrals documented**: hve-rpi-validator scenarios deferred due to known template defect (DD-004); E2E procedure documented but not tooled (DD-006); LOW-radius agents scoped to periodic/pre-release tiers (research finding 7, phase 7 cadence notes).

### Design Decisions

All research tensions resolved:

1. **Two-sided cost vs. validity**: DD-001 accepts doubled cost because runs scoped to changed agents ✓
2. **Judge complexity vs. quality**: DD-002 uses compare-mode instruction; escalates to dedicated agent only if calibration weak ✓
3. **Rubric delivery**: DD-003 confirms free-form input sufficient; risk recorded ✓
4. **Defect in scope**: DD-004 defers hve-rpi-validator; visible to user ✓
5. **Cost uncertainty**: DD-007 commits Phase 7.2 measurement before cadence finalized ✓

### Risk Log

Plan risk log (7 entries) addresses:
- Nondeterministic grading → tolerance bands + 3-run escalation
- Staleness nag deletion → opt-in + clear message
- Compare-mode weakness → documented follow-on
- Token-cost estimates → Phase 7.2 measurement
- Model drift → same-session pairs only
- Answer-key leakage → README rule + flow enforcement
- Opt-in coverage → by construction

All risks have mitigations. ✓

## Testing Approach Validation

**Deterministic layer (zero tokens)**:
- Drift suite new Test 17 (baseline staleness check)
- Install tests (command discovery)
- No LLM dispatch at plan-verification time ✓

**Behavioral layer (measured)**:
- Phase 7.2: single-side prototype run against hve-plan-validator
- Measures: rubric results, seeded-defect ledger, token cost per dispatch
- Before/after comparison path exercised on first real edit (designed fallback: Inconclusive verdict)

This approach is sound: deterministic checks gate the build; behavioral tests measured before release; real-world use validates integration point.

**Caveat**: The before/after comparison path (Phase 3.5 conditional dispatch, compare-mode evaluator) is not exercised in testing, only in real use. Plan explicitly acknowledges this as acceptable. ✓

## Dependencies and Ordering

Phase dependency graph:
```
Phase 1 (format spec)
  ├→ Phase 2 (prototype) → Phase 3 (command)
  ├→ Phase 3 → Phase 4 (wave-2 scenarios)
  ├→ Phase 2 → Phase 5 (staleness check)
  ├→ Phase 3, 5 → Phase 6 (documentation)
  └→ Phases 2–6 → Phase 7 (verification + cost measurement)
```

All dependencies declared at phase headers. Linear + Phase 4 parallel to 3/5 is feasible.

**Cross-phase constraint noted but not in header**: Phase 6.2 figures should be drafted provisionally and updated after Phase 7.2 measures. Plan text in Step 6.2 says "explicitly flagged at ~1M-3M tokens" and testing approach section says "Step 7.2 replaces them with measured figures". Implementor is warned; not a blocker.

## Recommendation

**Plan is ready for implementation.** All research requirements traced to plan steps; all open questions resolved via design decisions; all assumptions marked; no unverified claims; phases properly ordered; success criteria measurable; risks documented.

The plan correctly interprets research findings 1-7 (with noted corrections), resolves all five open questions, implements the recommended three-tier cadence (per-edit regress, staleness nag, pre-release E2E), and leaves hve-rpi-validator's scenarios explicitly deferred pending defect fix.

**Minor note for implementor**: Phase 6.2 should draft cost figures as provisional (e.g., "~1M-3M tokens (pending Phase 7.2 measurement)") to avoid lock-in before Phase 7.2 completes.

---

# Plan Validation v2 (2026-08-19)
## Design Revision: claude plugin eval alignment

**Status: PASS — internal consistency, coherence, and correction coverage verified**

### Change Summary

User directed redesign at checkpoint: align fixtures with Claude Code's `claude plugin eval` case format (early-access, org-gated; research Correction 2026-08-19 records findings). Consequences: Phase 1–3 restructured to use `evals/<agent>--<slug>/prompt.md` + `graders/` (regex + llm types); Phase 5 test updated to `evals/baselines/`; Phase 3 now dual-runner (probe native harness, fallback to in-session); DD-009 introduces single-side default with before/after as escalation (cost optimization amending DD-001 mechanics); DD-008 through DD-011 document new design decisions. v1 validated Pass before revision; all following re-validation.

### Validation: Internal Consistency (v2 Layout)

**All phases 4–7 reference new `evals/` paths consistently**:

- **Phase 4 cases** (Step 4.1–4.3): "`hve-implementation-validator--seeded-security-defects`", "`hve-pr-reviewer--severity-discrimination`", "`hve-researcher--citation-fidelity`" all under `evals/` namespace ✓
- **Phase 5 staleness check** (Step 5.1): "for each `evals/baselines/*.md`, derive the agent name from the filename" ✓
- **Phase 5 test body** (details file): `for file in "${REPO_ROOT}/evals/baselines"/*.md; do ... agent="$(basename "${file}" .md)"` ✓
- **Phase 6 documentation** (Step 6.2): References "native-harness forward path", DD-010 (`claude -p` E2E substrate), cost figures from Step 7.2 ✓
- **Phase 7 verification** (Step 7.1): "`evals/` is repo-local test material and is NOT distributed by the installer [HIGH per research finding 2]" ✓
- **Risk log** (8 rows in v2): Row 1 "Early-access eval format drifts", Row 2 "Native harness never becomes available", both reference new dual-runner design; rows 3–8 address nondeterminism (now specifies "Regex graders are deterministic"), model drift, etc. ✓
- **Details file**: Tree layout shows `evals/` structure; Phase 1 contract for `prompt.md` with frontmatter; Phase 1.3 shows regex and llm grader contracts; Phase 1.4 baseline format for `evals/baselines/<agent>.md` ✓

**No survivors of old `tests/fixtures/agent-scenarios/` path**. ✓

### Validation: DD-009 Coherence with DD-001 (Amending, not contradicting)

**Quote from DD-001 (v1)**: "the authoritative regression verdict always comes from a fresh before/after pair in one session"

**Quote from DD-009 (v2)**: "Default = grade the current (after) side against fixed graders (~2 dispatches/case); escalate to a fresh same-session before/after pair + blind compare only on a grader failure or degradation vs recorded expectations. DD-001's core holds unchanged: cross-session baselines are never authoritative comparators; every before/after pair runs fresh in one session."

**Coherence Analysis**:
- **DD-001 principle (preserved)**: Every before/after pair that executes must run fresh in one session (not cross-session baselines) → **YES, explicitly restated in DD-009**
- **DD-009 amendment**: Default path is single-side (after only) graded against fixed regex + llm graders; escalate to before/after ONLY on grader failure/degradation → **COST OPTIMIZATION**
- **Trade-off documented**: "A subtle regression that still passes all graders goes undetected by the default path; accepted — graders are the definition of "quality floor", and the pre-release E2E tier exists for whole-chain drift" → **EXPLICIT RISK ACCEPTANCE**

Plan steps verify this:
- **Step 3.5** (default): "dispatch hve-prompt-tester with the CURRENT agent file + prompt.md body" (no before side) ✓
- **Step 3.6** (escalation): "only when the single-side run fails a grader or degrades against the baseline's recorded expectations, parent writes the before side via `git show HEAD:.claude/agents/NAME.md` into the sandbox and repeats Steps 3.5(2)-(4) for it, then dispatches hve-prompt-evaluator once in compare mode" ✓
- Both before/after instances guaranteed fresh, same-session ✓

**Verdict: Coherent amendment. DD-001's authority principle unchanged; DD-009 optimizes cost by deferring before/after to escalation-only path.** ✓

### Validation: Unearned Verification + Missing Confidence Markers (v2 additions)

**New assumptions in v2 text all carry markers**:

- **Step 1.1** (probe): "Assumption: the recorded schema... matches the shipped format [MEDIUM — early-access, version-gated ~v2.1.210+; not independently verifiable while gated]" ✓ (marked with explicit caveat)
- **Step 1.2** (case.yaml): "Assumption: `case.yaml` `add_dirs`/`scaffold_script` can place `materials/` content into the run workspace [LOW — implementor verifies if the tool is available, else the in-session runner's tempdir copy is the only exercised path and the README says so]" ✓ (marked with fallback path)
- **Step 3.4** (native runner): "Assumption: `--tag` filtering and `--json` output behave as recorded [MEDIUM — same early-access caveat as Step 1.1; the command text tells the session to adapt to the tool's actual help output]" ✓ (marked with adaptation)
- **Step 7.1** (install scope): "`evals/` is repo-local test material and is NOT distributed by the installer [HIGH per research finding 2 — implementor confirms install.sh copies only .claude/ subdirs]" ✓ (marked with verification guard)
- **Step 7.2** (single-side sufficiency): "Assumption: a single-side run suffices for cost measurement and format shakeout; the escalation path is exercised on the first real agent edit [MEDIUM]" ✓

**v1 evidence still cited correctly**:
- Step 1.4 hash-mechanism: "The `Agent hash:` line format was verified by the parent during planning: `git hash-object ...` → result; ... re-extracted via `grep -m1 '^Agent hash: ' | awk '{print $3}'` compared equal (fresh) and unequal (edited). The extraction/comparison mechanism works [HIGH]" ✓
- Step 3.2 --subagent-model: "verified by the parent during planning via `grep -rhF 'If \`--subagent-model' .claude/commands/ | sort -u` → exactly one distinct line across 7 carriers: [quoted]" [HIGH] ✓
- Step 5.1 test transcription: "The extraction/comparison mechanism was run by the parent during planning (see Step 1.4 evidence); the test body is a direct transcription of that verified spike ... [HIGH]" ✓

All new and existing claims have evidence adjacent. ✓

### Validation: Research Correction Coverage

**Correction (2026-08-19) states**: claude plugin eval (gated, ~v2.1.210) provides case format `evals/<case>/prompt.md` + graders; sandboxed runs; 3-run default; `--max-cost-usd` ceiling; JSON scores. Also: `claude -p --output-format json` for E2E scripting. Third-party tools (promptfoo, etc.) rejected for fidelity.

**Plan addresses all consequences**:

| Consequence | Plan Location | Status |
|---|---|---|
| Case format: `evals/<agent>--<slug>/prompt.md` | Phase 1 Steps 1.1–1.2; Phase 2–4 implementation | ✓ |
| Pluggable graders (regex, llm, etc.) | Step 1.3 defines both; Step 1.2 frontmatter | ✓ |
| Sandboxed workspaces | Step 3.5 references `.claude-hve-tracking/sandbox/` | ✓ |
| Default 3 runs/case | Step 1.2 shows `runs: 3` in prompt.md frontmatter | ✓ |
| `--max-cost-usd` ceiling | Step 3.4 "proposed invocation ... `--max-cost-usd <ceiling>`"; Step 7.2 offers Kevin one run with ceiling | ✓ |
| JSON per-grader scores | Step 3.4 "parse per-grader scores from the results JSON"; details "per-grader scores" | ✓ |
| `claude -p` E2E substrate | Step 6.2 documents; DD-010 records decision; details file lists flags and options | ✓ |
| Agent SDK rejected (Python/TS) | Not used anywhere; rejection implicit; Correction documents it | ✓ |
| Third-party tools rejected | DD-011 explicitly records rejection with rationale ✓ |

All consequences addressed. ✓

### Validation: New Risk Mitigation (Rows 1–2 in v2 Risk Log)

**Row 1: "Early-access eval format drifts from the recorded schema before GA"**
- Plan Step 1.1: "If available, verify the case-format fields against the tool's own help/init output and prefer those; if gated, use the recorded schema below."
- Mitigation text: "Format captured as [MEDIUM] with an implement-time probe (Step 1.1); the in-session runner consumes the same files and is authoritative until the native harness is available; README change-log tracks realignments"
- **Reasonable**: In-session runner is stable baseline; native harness is forward-compat bonus; format divergences tracked ✓

**Row 2: "Native harness never becomes available to Kevin"**
- Plan dual-runner design (Step 3.4): Probe, ask, fallback
- Mitigation text: "The in-session runner is complete on its own; nothing in the harness path is load-bearing (probe-and-fallback, DD-009)"
- **Reasonable**: Plan works fully without native harness; harness is optional ✓

Existing risks (rows 3–8): Nondeterminism, staleness nags, compare-mode quality, token cost, model drift, answer-key leakage — all carry existing mitigations from v1, now updated for dual-runner context. ✓

### No New Discrepancies

- **Internal consistency**: ✓ `evals/` layout referenced uniformly through phases 4–7
- **Coherence of amendments**: ✓ DD-009 is cost optimization; DD-001 principle preserved
- **Verification hygiene**: ✓ All v2 claims cited; all assumptions marked
- **Correction coverage**: ✓ All research findings on plugin eval integrated
- **Risk handling**: ✓ New risks (format drift, harness unavailability) mitigated

### v2 Plan Status

**PASS** — The redesign to align with `claude plugin eval` is coherent and internally consistent. Key coherence points:

1. **Fixture format** now native to plugin eval case format while remaining parseable by in-session runner today
2. **Dual-runner strategy** (native if available + explicit consent, else in-session fallback) ensures robustness whether harness is gated or not
3. **Single-side default + escalation** (DD-009) is a cost-optimization amendment that preserves DD-001's principle: when before/after pairs run, they run fresh in one session, never cross-session
4. **All research Correction consequences** (format, graders, sandbox, cost ceiling, JSON output, `claude -p`, third-party rejection) addressed in plan
5. **New risks** (eval format drift, harness unavailability) explicitly documented and mitigated

Recommendation: Proceed with implementation. Implementor should execute Step 1.1 probe at write time to confirm plugin eval case format. The in-session runner is the primary consumption path; forward-compatibility with native harness is a bonus that requires no plan changes even if it never ships.

**No blocking issues identified in v2 revision.**
