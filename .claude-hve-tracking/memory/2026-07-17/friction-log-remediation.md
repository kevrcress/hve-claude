# Session Memory: Friction Log Remediation — Analysis and Decisions
Date: 2026-07-17
Session type: research
Task slug: friction-log-remediation

## Decisions Made
- Friction capture becomes part of the process via an optional `--friction-log` flag on every phase command (real-time capture, embedded in command text so it survives phase boundaries): chosen over a standalone-only `/hve-friction` command because chat-level standing instructions are proven to drop at handoffs (O-09). A single canonical artifact home will be picked in the same change (proposal: `.claude-hve-tracking/friction/YYYY-MM-DD-phase-slug.md`), resolving O-43.
- Two slash commands cannot co-fire in one user message (the second becomes `$ARGUMENTS` text, the O-33 hazard); design must not depend on stacking commands.
- Bash access (O-05, F-11): Option B chosen for both researchers and validators. Subagents stay read-only; the parent session runs all git/shell commands and passes pre-digested results into subagent prompts; shell verification in review happens in the parent, never delegated. Rejected: granting Bash to agents (frontmatter cannot scope Bash to read-only git; would trade away the hard guarantee).
- Risk axis (F-05): middle-ground override clause, not a full second classification axis. Classify at least Medium regardless of size if the change touches (a) code consumed outside the repo, (b) auth/security/crypto, (c) migrations or irreversible ops, (d) untested paths. One footnote in CLAUDE.md's difficulty table.
- Sequencing (fan-out dedup vs fixes): ship fixes first; protect the 9-way Subagent Response Protocol copies and 8-way `--subagent-model` boilerplate with drift tests (precedent: docs-drift test in commit 9b610f7). Rejected: consolidate-first refactor (agent files cannot include other files; relying on CLAUDE.md alone weakens subagent behavior).
- PR review: create a dedicated `hve-pr-reviewer` agent pinned `sonnet` (judgment-graded tier). Clarified: `/hve-pr-review` is a command only; no PR agent exists among the 8 in `.claude/agents/`, which caused the O-34 improvisation.
- Observability rule: add one dispatch convention line — "if you dispatch an agent type not in the HVE roster, record which type and why in the artifact." Improvisation stays allowed but becomes visible.
- Artifact discovery: keep slugs as task identity, NO new manifest file. Replace "most recent wins, silently" with a shared deterministic resolution order: (1) slug in arguments wins; (2) else collect distinct slugs from last ~7 days, single candidate wins; (3) multiple candidates: match current git branch name, else list and ask; (4) never silently pick between same-day slugs; always topic-relevance-check the chosen artifact (else record skip per Cluster A rules). Skips and standing instructions live in the plan file header, not a new file type.
- Template rule promoted to design principle: every template blank must be genuinely obtainable or carry an explicit N/A branch (e.g. `Tests: N/A — no test runner in repo`). Audit all templates, add to prompt-authoring conventions so /hve-prompt-builder enforces it.
- Model pinning: keep current tiers (haiku mechanical, sonnet judgment, inherit for researchers/implementors). Two adjustments: haiku validator prompts must contain zero judgment calls (move contested severity reclassification, O-26/O-30 territory, to parent or sonnet validator); write all prompts to the haiku bar.
- Evals: doable entirely in Claude; start with plain test scripts (static consistency suite) + headless `claude -p` scenario runs against fixture repos. No external framework (promptfoo etc.) until outgrown. Cowork's eval skill = skill-creator plugin's eval feature; its harness pattern applies since HVE commands are skills. DEFERRED until remediation lands.

## Failed Approaches
- None tried this session (research + decisions only). Known do-not-break constraints from the logs: Subagent Response Protocol scaling, handoff-by-disk discovery, self-enforcing confidence markers all worked as designed — preserve them while fixing the rest.

## Open Questions
- [ ] Exact canonical friction path and `--friction-log` flag wording (small; decide at plan time)
- [ ] Whether the static consistency suite lands in the same plan as the doc fixes or as a follow-on task
- [ ] Eval loop design (5 proposed: static suite, scenario regressions, weak-model literalism, token-budget regression, friction meta-loop) — deferred by user until after remediation

## Next Steps
- [ ] Run `/hve-plan` in a fresh conversation; it will find `.claude-hve-tracking/research/2026-07-17/friction-log-remediation.md`. Plan must fold in ALL decisions above.
- [ ] Plan scope: Cluster A discovery rules, Cluster B Simple carve-outs, Cluster C template fixes (O-01, F-06 in 2 files, F-07, O-23), Cluster D verdict integrity (O-31, O-22, O-35/O-36/O-38, F-09/F-10), Cluster E PR review fixes + new hve-pr-reviewer agent, Cluster F structural (O-09 appendix promotion, O-12 concurrent-write rule, O-11/O-17 test baseline, O-10 DR- rule), Cluster G parent-runs-shell rules, Cluster H naming/taxonomy + javascript/typescript instructions files, `--friction-log` flag, risk footnote, roster-deviation note, drift tests.
- [ ] After fixes land: `./install.sh --global` to re-sync ~/.claude, then re-run a Simple task end-to-end in a consumer repo to confirm carve-outs fire.
- [ ] Then return to eval loops.

## Key Files
- .claude-hve-tracking/research/2026-07-17/friction-log-remediation.md — consolidated research (61 issues, 8 clusters, all decisions trace to it)
- .claude-hve-tracking/research/subagents/2026-07-17/friction-inventory-fieldnotes.md — F-01..F-14 detail
- .claude-hve-tracking/research/subagents/2026-07-17/friction-inventory-other-repos.md — O-01..O-47 detail
- .claude-hve-tracking/research/subagents/2026-07-17/hve-current-state.md — current-state map, landed-fix timeline, global-install freshness proof
- .claude/commands/hve-plan.md:19, hve-implement.md:19-21, hve-review.md:19-24, hve-challenge.md:26 — discovery logic to replace
- .claude/commands/hve-implement.md:47 (timestamp), :78 (unconditional spawn), :88 (STOP rule), :97-107 (test gate)
- .claude/agents/ — 8 agents; hve-pr-reviewer to be added as the 9th

## Tracking Artifacts
- Research: .claude-hve-tracking/research/2026-07-17/friction-log-remediation.md
- Plan: none yet (next phase)
- Changes: none yet

## Context Notes
The 9 source friction logs live OUTSIDE this repo (4 in Fieldnotes, 2 in privy-mvp, 2 in Krava-Standup, 1 here) and were written 2026-07-12/13 against the CURRENT process definition (global ~/.claude install verified in sync with repo main; every landed improvement predates the complaints). None of the logs' suggested fixes have been applied as of 2026-07-17. Nearly all 61 issues are valid process defects; only O-18 is one-off and O-06 partly platform. Kevin's priorities: real-time friction capture, keep read-only subagents read-only, simplify rather than add machinery (no manifest file), visibility over restriction (roster-deviation notes), evals after remediation.
