# Changes Log: All subagents use `model: inherit` (no pinned tiers)

**Task:** Started as "move the two mechanical validators (`hve-plan-validator`, `hve-rpi-validator`) off their `haiku` pin to `model: inherit`." Mid-task the user extended it: apply the same principle to the three remaining `sonnet` pins so **no** HVE subagent chooses a tier on the user's behalf. Final state: every agent is `inherit`. All documentation restating the old pins synced.

**Difficulty:** Simple (size) / Medium (risk override — edits installed prompts consumed outside this repo). Direct-implementation path, user-confirmed.

**Started:** 2026-08-23T20:43:06Z
**Completed:** 2026-08-23T20:43:06Z
**Branch:** `feature/validators-inherit-model`

## Test Baseline

- Runner: `./tests/run-drift-tests.sh` (docs-vs-frontmatter drift + security hygiene; the relevant gate for frontmatter/doc edits).
- Baseline before edits: **255 passed, 0 failed**.
- After all edits: **250 passed, 0 failed**. The 5-count drop is expected and benign: several per-agent assertions fire only for `haiku`/`sonnet`-pinned agents (e.g. test 3 loops only over pinned agents; tests 1–2 emit per-tier checks). Once all five pinned agents move to `inherit`, those assertions stop generating. Zero failures, no net-new failures against baseline — gate passes.
- Other suites (`run-install-tests.sh`, `run-prompt-*.sh`) exercise install/upgrade flows and are re-covered by the global install step below; not re-run separately.

## Rationale

Same principle, applied twice. A validator's value concentrates in ambiguous cases, and ambiguity scales with phase difficulty, so tying validator capability to the session model tracks that automatically. Extending to the quality reviewers: when HVE does not know the task or the user's intent, it should not pick a tier for them. `inherit` lets the user's `/model` choice govern every subagent, never needs revisiting when the tier lineup changes, and was already the established pattern for researcher/implementor/prompt agents.

## Changes

### Frontmatter (source of truth) — all now `inherit`
- `.claude/agents/hve-plan-validator.md:4` — `haiku` → `inherit`
- `.claude/agents/hve-rpi-validator.md:4` — `haiku` → `inherit`
- `.claude/agents/hve-implementation-validator.md:4` — `sonnet` → `inherit`
- `.claude/agents/hve-pr-reviewer.md:4` — `sonnet` → `inherit`
- `.claude/agents/hve-prompt-evaluator.md:4` — `sonnet` → `inherit`

(Already `inherit` before this change: researcher, phase-implementor, prompt-updater, prompt-tester.)

### Documentation sync
- `CLAUDE.md` Model Selection §2 — rewritten: every subagent uses `model: inherit`; nothing pinned; capability tracks the session model. Follow-up paragraph reworded (all frontmatter already `inherit`, so custom/preview session models are followed automatically). This block also merges into `~/.claude/CLAUDE.md` on `--global` install.
- `docs/internals.md` — agent-table Model column: all five rows `Haiku`/`Sonnet` → `Inherit`.
- `README.md:22,66,262` — three prose/table locations reworded from "Haiku for mechanical validation / Sonnet for quality review" to "every subagent inherits the session model; nothing pinned." `README.md:146` unchanged (documents the `--subagent-model` override flag, where `haiku`/`sonnet`/`opus` remain valid choices). `README.md:65` unchanged (a session-model recommendation, not an agent pin).
- `.claude/commands/hve-prompt-refactor.md:41` — Copilot-string conversion guidance updated: HVE agents use `inherit`; pin a fixed tier only for a deliberate reason.
- `.claude/commands/hve-review.md:148` — removed the false "haiku-pinned validator" phrasing; kept the rule that the parent, not a validator subagent, adjudicates contested severity.

## Remaining model pins after this change

None. No `haiku`, `sonnet`, or `opus` pins in any agent; no `model` key in `settings.json`; no model pins in command files. All nine agents are `inherit`. The `--subagent-model` flag remains the per-run escape hatch for forcing a specific tier.

## Addendum — `fable` tier added to the override surface (2026-08-23)

Follow-on request: anything that accepts, checks, or allows a model tier must
also include `fable` alongside `haiku`/`sonnet`/`opus`. `fable` (Fable 5) is a
valid Agent-tool `model` tier, so the `--subagent-model` override can legitimately
pass it through.

Changes:
- `--subagent-model` placeholder updated to `<sonnet|opus|haiku|fable>` across all
  carriers: 8 command files (argument-hint + body boilerplate), 4 prompt files
  (`rpi`, `pull-request`, `doc-ops`, `prompt-build`), `CLAUDE.md` §3, and
  `README.md:146` (escaped-pipe table cell). Command-file body boilerplate stayed
  byte-identical across carriers, so drift test 5 still passes.
- `CLAUDE.md:70` named-tiers list: added `fable`.
- `.claude/commands/hve-prompt-refactor.md:41` fixed-tier list: added `fable`.
- `tests/run-drift-tests.sh` — the allow-list and checks now include `fable`:
  `VALID_MODELS` (line 62), test-1 comment, test-3 pinned-agent guard (now covers
  all concrete tiers: haiku/sonnet/opus/fable), test-3 tier loop, and the test-3
  header comment.
- Verified: `hve-plan.md` honors `--subagent-model` via its own Argument Parsing
  section (not the shared boilerplate), so its argument-hint update is sufficient
  and no flag-handling gap exists.

Gates after fable edits: drift 250 passed / 0 failed; install 69 passed / 0 failed.
`bash -n` clean on the modified test script.

## Follow-up

- Global install (`./install.sh --global`) run after commit to sync `~/.claude`
  (covers the inherit migration and the fable override-surface additions).
