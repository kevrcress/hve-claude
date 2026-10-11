# Implementation Details: Output-Quality Regression Checks
Date: 2026-08-19 (v2 — aligned with `claude plugin eval` case format; v1 used a bespoke tests/fixtures/agent-scenarios/ layout, superseded by DD-008 before anything was built)
Task slug: rpi-output-quality-regression
Plan: .claude-hve-tracking/plans/2026-08-19/rpi-output-quality-regression-plan.md

## Eval tree layout (Phase 1)

```
evals/
├── README.md                                  # format spec + change log; source of truth
├── baselines/
│   └── hve-plan-validator.md                  # per-agent staleness metadata + recorded expectations
├── hve-plan-validator--seeded-plan-defects/
│   ├── prompt.md                              # all-inline: no materials/
│   └── graders/
│       ├── defect-1-verified-claim.md         # type: regex
│       ├── defect-2-missing-marker.md         # type: regex
│       ├── defect-3-coverage-gap.md           # type: regex
│       └── rubric.md                          # type: llm
├── hve-implementation-validator--seeded-security-defects/
│   ├── prompt.md
│   ├── case.yaml                              # wires materials/ into the run workspace
│   ├── materials/                             # frozen mini-tree
│   └── graders/ ...
├── hve-pr-reviewer--severity-discrimination/ ...
├── hve-researcher--citation-fidelity/ ...
└── results/                                   # gitignored (native harness default output dir)
```

Format provenance: recorded from a claude-code-guide consult 2026-08-19 (early-access, version-gated ~v2.1.210+; [MEDIUM]). Implement-time rule: if `claude plugin eval --help` succeeds, its own help/init output wins over this section; divergences go in the README change log.

## prompt.md contract (Step 1.2)

```markdown
---
name: hve-plan-validator--seeded-plan-defects
tags: [hve-plan-validator, grader-agents]
runs: 3
max_turns: 10
allowed_tools: [Read, Write, Glob, Grep]
---
[Body: the exact dispatch input the parent pastes into the tester —
for materials/ cases, paths written as {MATERIALS}/relative/path;
the in-session runner substitutes its tempdir, the native harness
gets materials via case.yaml.]
```

Answer-key rule: expected findings, locations, and severities appear ONLY in `graders/`, never in `prompt.md` — the eval subject must not see them.

## Grader contracts (Step 1.3)

Regex grader (one per seeded defect; mechanical, parent-grepable):

```markdown
---
type: regex
---
# expects the execution log to contain the defect location token AND a Major tag
pattern: "Step 2\\.1.*(Major|MAJOR)"
```

llm grader (`rubric.md`) — carries the five properties and tolerance bands:

```markdown
---
type: llm
---
Grade the execution log against these properties only (not prompt-text quality):
- protocol-compliance: response follows the 6-part Subagent Response Protocol
- citation-resolvability: every cited location resolves into the dispatch input (or {MATERIALS})
- verdict-correctness: expected verdict Fail
- seeded-defect-detection: >=2 of 3 detected AND 0 spurious Critical
  (defect 1: "verified" claim without evidence at plan Step 2.1, expected Major;
   defect 2: unmarked assumption at Step 1.3, expected Major;
   defect 3: research requirement R-4 uncovered, expected Critical)
- spurious-findings: <=1 spurious Major
```

Tolerance-band grammar: `>=N of M detected`, `<=N spurious <severity>`, `AND` only (no OR — keeps parent-side grep grading trivial). The regex graders are the mechanical ledger; the llm grader adjudicates near-misses (right location, wrong severity).

## baselines/<agent>.md contract (Step 1.4)

```markdown
# Baseline: hve-plan-validator

Agent hash: 4cafc7bd86765f46dfa20c58b9c56f0bb3f9af47
Scenario-set version: 1
Grader: hve-prompt-evaluator (sonnet)
Model: <session model of last recorded run>

## Results
| Case | Verdict | Graders passed | Seeded: detected/missed/spurious |
|---|---|---|---|
| seeded-plan-defects | — | Results: none — no regress run yet | — |

## Baseline history
- 2026-08-19: initial baseline, hash 4cafc7b (creation, no prior)
```

Hash above is the plan-time illustration; the implementor recomputes at write time. History is append-only; `## Results` rows may be rewritten by a new run, history rows never are.

## Staleness check — verified spike transcription (Phase 5)

Spike run by the planning parent (scratchpad, 2026-08-19):

```
git -C <repo> hash-object .claude/agents/hve-plan-validator.md
  → 4cafc7bd86765f46dfa20c58b9c56f0bb3f9af47
grep -m1 '^Agent hash: ' baseline.md | awk '{print $3}'
  → 4cafc7bd86765f46dfa20c58b9c56f0bb3f9af47   (equal → fresh)
# simulated edit (appended line to a copy):
git hash-object edited-copy.md
  → 96c34f3012d23d601b4c8bdc6de1cb8265886cb9   (differs → stale detected)
```

Test 17 body shape (final code follows run-drift-tests.sh local idiom — implementor confirms repo-root variable name and `_ok_inline`/`_fail_inline` availability):

```bash
test17_baseline_staleness() {
  local file agent recorded current found=0
  for file in "${REPO_ROOT}/evals/baselines"/*.md; do
    [[ -f "${file}" ]] || continue
    found=1
    agent="$(basename "${file}" .md)"
    recorded="$(grep -m1 '^Agent hash: ' "${file}" | awk '{print $3}')"
    current="$(git -C "${REPO_ROOT}" hash-object ".claude/agents/${agent}.md")"
    if [[ "${recorded}" == "${current}" ]]; then
      _ok_inline "test17: ${agent}" "baseline fresh (${current:0:7})"
    else
      _fail_inline "test17: ${agent}" \
        "baseline stale — run /hve-prompt-regress ${agent} or update the baseline"
    fi
  done
  (( found )) || _ok_inline "test17: coverage" "no baselines yet — nothing to check"
}
```

## /hve-prompt-regress dual-runner flow (Phase 3)

```
parse args → targets (explicit names | --changed via git diff)
probe: claude plugin eval --help  (parent Bash, exit status)
├─ available → tell user, propose: claude plugin eval . --tag <agent> --json
│              --max-cost-usd <ceiling>; ASK before spending; parse per-grader
│              scores from the results JSON into the verdict
└─ gated/absent → in-session runner, per case:
     1. parent: copy materials/ (if any) to tempdir, substitute {MATERIALS}
     2. Agent(hve-prompt-tester, current agent file + prompt.md body + sandbox path)
     3. parent: grep execution log for each regex-grader pattern (seeded ledger)
     4. Agent(hve-prompt-evaluator, execution log + rubric.md criteria)
     verdict vs graders + baseline expectations
     └─ failure or degradation → ESCALATE:
          parent: git show HEAD:.claude/agents/A.md > sandbox/.../before/A.md
          repeat 2-4 for the before side
          Agent(hve-prompt-evaluator, compare mode: blind, order-randomized pair)
          → Regressed (after worse) | Inconclusive (equal/unclear) | pre-existing failure
update baselines/<agent>.md (results rewrite + history append)
```

Default cost per case: 2 dispatches (tester + evaluator). Escalation adds 3 (before-side tester + evaluator + compare). Compare-mode dispatch prompt sketch (lives in the command file, not the agent): "You are grading two anonymized execution logs, LOG-X and LOG-Y, of the same scenario. Do not assume which is newer. For each rubric property, state which log is stronger or 'equal', then an overall better/equal/worse. Cite log line numbers." Parent randomizes X/Y and de-anonymizes after.

## Native-harness reference (recorded 2026-08-19, [MEDIUM] — verify at implement time)

- Availability probe: `claude plugin eval --help`; gated builds print an early-access message and exit 1
- Useful flags: `--case <glob>`, `--tag <tag>`, `--runs <n>` (default 3), `--model`, `--judge-model` (default haiku — consider sonnet to match the evaluator pin), `--max-cost-usd` (exit 2 on breach), `--json [file]`, `--threshold <0..1>`, `--output-dir` (default ./evals/results/<timestamp>/)
- Targets `.claude/`-directory repos directly (`claude plugin eval .`) — no plugin packaging needed
- Version gates: command ≥2.1.198; enablement ≥2.1.207; stable `--json` ≥2.1.210
- `claude -p` (E2E tier scripting, Step 6.2): `--output-format json` returns `total_cost_usd`, `usage`, `num_turns`; `--max-turns`, `--max-budget-usd`; cannot invoke slash commands or route to subagents; `--model` accepts tiers only

## Cost model to validate in Step 7.2 (currently unmeasured)

- In-session, default single-side: 2 dispatches per case (research estimate ~50-200k tokens per changed agent — replace with measured figures)
- Escalated before/after: 5 dispatches per case
- Record per-dispatch token counts in this file under `## Measured costs (2026-MM-DD)`

## Deferred / explicitly out of scope

- `hve-rpi-validator` cases — blocked on the hve-rpi-validator.md:83 hardcoded [CRITICAL] defect (Kevin deferred the fix 2026-08-15). README carries the note (Step 4.4).
- E2E pre-release tier — documented procedure only (Step 6.2); `claude -p` noted as its future scripting substrate (DD-010); no tooling.
- Purpose-built judge agent — only if compare-mode calibration shows the evaluator is inadequate.
- Native-harness enablement — org-gated; nothing in the plan depends on it (DD-009).
- Shipped-file iteration support in /hve-prompt-builder — research follow-on question for Kevin, untouched here.
