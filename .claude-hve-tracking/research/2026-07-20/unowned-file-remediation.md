# Research: Unowned-File Convention Audit

Date: 2026-07-20
Task slug: unowned-file-remediation
Source: post-implementation audit following the friction-log-remediation branch (`feature/friction-log-remediation`, 9 commits)
Method: 3 parallel read-only audits (agent type `general-purpose` — roster deviation recorded below), plus parent-session verification of the highest-value findings

## Why these files were never inspected

The friction-log remediation defined a file→phase ownership map (`.claude-hve-tracking/details/2026-07-17/friction-log-remediation-details.md`, "File → phase ownership map"). Twenty-two files under `.claude/` appear in **no** phase's map, so no implementor edited them and no validator inspected them.

Two Major defects (IV-006, IV-007) were later found in one of those unowned files, `hve.md`, and both had shipped undetected through 168 static drift assertions. That established the class as real and motivated auditing the remainder. [HIGH — both recorded in `.claude-hve-tracking/reviews/rpi/2026-07-17/friction-log-remediation-review.md`]

**Root cause worth carrying into the plan:** drift tests verify that files agree *with each other*. Every defect in this class involves either a file nobody compared against anything, or text no code path reaches. Static comparison cannot detect either. [HIGH]

## Scope triage

Audited (14 files): 4 commands, 6 prompts, 4 agents — all either dispatch subagents or write tracking artifacts.

Excluded as genuinely out of scope (4 files): `hve-git-commit.md`, `hve-git-merge.md`, `hve-git-setup.md`, `hve-prompt-analyze.md` — none dispatch subagents or write tracking artifacts, so the conventions do not apply. [HIGH — verified by grep for `Agent tool|spawn|dispatch` and `.claude-hve-tracking`]

Totals: **0 Critical, 12 Major, 9 Minor.** No audited file was clean of everything.

---

## Major findings

### M-01 — `hve-rpi-validator` emits false assurance on unlisted-change detection
`.claude/agents/hve-rpi-validator.md:48` instructs: "Search for files modified but not listed in the changes log that relate to the phase". Its frontmatter is `tools: Read, Write, Glob, Grep` (line 6) — no Bash. The parent (`.claude/commands/hve-review.md:85-90`) passes exactly five inputs: plan path, changes-log path, research path, phase number, output path. No git-derived changed-file list. [HIGH — personally verified: read line 6, line 48, and the parent's dispatch block]

Compounding: the output template at `:87-88` has `## Unlisted Changes` / `[Files modified but not in the changes log, if any]`. The "if any" reads as an N/A branch but is not one — the agent can never observe a modified file, so the section always renders empty and reads as a positive "no unlisted changes" result.

**This is the highest-priority finding.** It silently degrades every review the framework produces, and it degraded the 2026-07-17 review in this repo: all nine dispatched rpi-validators carried it.

Smallest fix: parent passes a `git diff --name-only` digest (it has Bash); reword `:48` to "Compare the parent-supplied changed-file list against the changes log."

### M-02 — `hve-doc-ops` dispatches an agent that does not exist
`.claude/commands/hve-doc-ops.md:48`: "Spawn parallel Doc-Ops subagents for large doc sets (one per section or doc type)". No doc-ops agent exists in `.claude/agents/`. [HIGH — personally verified: `ls .claude/agents/ | grep -i doc` returns nothing]

The file declares `Agent` in allowed-tools (`:4`) and pipes `--subagent-model` to "every Agent tool call" (`:11`) but never names a dispatchable type. It will improvise, and unlike the CLAUDE.md roster-deviation rule requires, never records which type or why. Flagged independently by two auditors.

Smallest fix: name a roster agent (`hve-researcher` fits read-only inventory work), or add the roster-deviation recording sentence.

### M-03 — Template Blanks convention is enforced by nothing
`CLAUDE.md:208` states the rule is one "`/hve-prompt-builder` enforces … when authoring or revising templates." It does not. Its only quality gate is the criteria list at `hve-prompt-builder.md:53` (clarity, completeness, actionability, format compliance, absence of Copilot-isms), and the delegate `hve-prompt-evaluator.md:25-54` lists five criteria sections, none about template blanks. [MEDIUM — auditor-reported with citations; not independently re-verified]

Same shape as IV-006: a rule owned by file A, assumed carried by file B, carried by nobody.

### M-04 — `hve-prompt-builder` dispatches the evaluator without its required input
`hve-prompt-builder.md:42` spawns `hve-prompt-tester` and `hve-prompt-evaluator` **in parallel**. But `hve-prompt-evaluator.md:18` declares its required input as "The test execution log path", and its description (`:3`) is "evaluate a test execution log against quality criteria". Run in parallel, the log does not exist yet, and `:50-53` does not pass it. The evaluator silently degrades to static review. [MEDIUM — auditor-reported with citations]

Smallest fix: sequence tester → evaluator; add the log path to the evaluator's inputs.

### M-05 / M-06 — Both validators hard-require research that CLAUDE.md permits to be absent
`hve-plan-validator.md:27-30` opens "Read the research document in full", and `hve-rpi-validator.md:33` says "Read the research document; extract requirements relevant to the phase". CLAUDE.md classes research as *reconstructible* — `Research: none — [reason]` is legitimate, and `hve-plan.md:27` implements that branch. The parents anticipate absence (`hve-review.md:88` says "(if present)"); the agent bodies never got the matching branch. With no research, the DR- mechanism has no basis and the agent may manufacture findings against invented requirements. [MEDIUM — auditor-reported with citations]

**Generalizable pattern for the plan:** agent bodies written against an assumed-present input, while the parent command was later hardened to tolerate absence. Worth auditing the remaining agents specifically for this.

### M-07 — `rpi.md` documents two arguments that do not exist
`.claude/prompts/rpi.md:9-10` documents `continue` and `suggest`. `hve.md:3` argument-hint is `<task-description> [--mode ...] [--think] [--subagent-model ...]`, and grep for either token in `hve.md` returns **0 mentions**. [HIGH — personally verified]

### M-08 — `pull-request.md` promises PR-description generation that does not exist
`.claude/prompts/pull-request.md:33-35`: "Claude can also generate a PR description template." `hve-pr-review.md` Phase 4 (`:152-168`) is finalize-only. [MEDIUM — auditor-reported]

Note: this file was *already* partially fixed this session (commit `2b254ac`, IV-004). That fix corrected the option list but missed this section — an incomplete fix, same as IV-007 was to IV-006.

### M-09 — `pull-request.md:3` mischaracterizes the command
Header reads "Generate a PR description with /hve-pr-review [branch]." The command is a senior-level 8-dimension review (`hve-pr-review.md:2`). [MEDIUM]

### M-10 — `checkpoint.md` invents a mode mechanism
`.claude/prompts/checkpoint.md:6-9` documents Save/Continue/Update modes. `hve-memory.md:3` takes `[topic-slug]` only; its phases are Detect/Save/Continue, where Continue is a printed post-save instruction, not a selectable mode. No Update path exists. [MEDIUM]

### M-11 — `doc-ops.md` promises an exclusion rule the command lacks
`.claude/prompts/doc-ops.md:18-20` says prompt-engineering artifacts are excluded. `hve-doc-ops.md:25` scans "Markdown in /docs/, README.md, API docs, inline code comments" with no exclusion anywhere (grep `exclud` returns nothing). The prompt promises an unenforced guardrail. [MEDIUM]

### M-12 — `hve-memory` has no artifact-discovery procedure
`hve-memory.md:65-68` emits a Tracking Artifacts block (Research / Plan / Changes paths) with no discovery procedure anywhere — no slug-first rule, no 7-day window, no relevance check, no branch tiebreak. With `Glob` available and no instruction, default behavior is "newest match wins", which CLAUDE.md explicitly forbids. Consequence: a resumed session points at another task's plan. [MEDIUM]

---

## Minor findings

- **m-01** `hve-doc-ops.md:3` vs `:17-18` — argument-hint makes path and `--scope` mutually exclusive (`|`); body treats them as independent. `/hve-doc-ops docs/ --scope gaps` is valid per body, invalid per hint.
- **m-02** `hve-memory.md:74` — "native memory system (this persists across projects)" is wrong and self-contradicting; the store is per-project (`~/.claude/projects/<slug>/memory/`). Risks pushing project detail into a store believed global. No target path given.
- **m-03** `hve-prompt-refactor.md:46-51` — convention checklist omits Template Blanks and Artifact Discovery, the two conventions this audit found most violated. The cleanup tool cannot catch M-03 or M-12.
- **m-04** `rpi.md:7-10` — omits `--think` and `--subagent-model`.
- **m-05** `doc-ops.md:12-16` — omits `--subagent-model`.
- **m-06** `task-challenge.md:20-23` — omits `--friction-log`. (Correctly omits `--subagent-model`: `hve-challenge.md:4` has no Agent tool.)
- **m-07** `prompt-build.md` — no Options section; omits `--iterations N` and `--subagent-model`. Line 18's "default: 3" implies a knob it never names.
- **m-08** `prompt-build.md:12-20` — never states its output location (`sandbox/YYYY-MM-DD-TOPIC-run-N/`); the only prompt of six missing this.
- **m-09** `checkpoint.md:19-25` — Output list omits the native-memory write at `hve-memory.md:74`.

Plus one Minor from the agent audit: `hve-rpi-validator.md:30` creates a placeholder artifact before it has content, so a mid-run block leaves a placeholder-only file at a committed path that a later phase could mistake for real validation output. No sibling agent does this.

---

## Verified clean (recorded so the plan does not re-litigate)

- **Tracking paths**: all 14 files clean; every `.claude-hve-tracking/...` path matches the CLAUDE.md tree. The `pr/review` → `reviews/pr` fix is complete. [HIGH]
- **Model pinning**: researcher `inherit`, plan-validator `haiku`, rpi-validator `haiku`, implementation-validator `sonnet` — consistent across frontmatter, CLAUDE.md, and `docs/internals.md:20-24`. [MEDIUM]
- **Response protocol**: all four audited agents conform, including status vocabulary (validators Pass/Fail, researcher Complete/Blocked) and the 7/5/3 caps. They are already in `FULL_PROTOCOL_AGENTS` (`tests/run-drift-tests.sh:51-53`) — so drift-test coverage was *not* why they escaped inspection. [MEDIUM]
- **Bash allocation**: only `hve-implementation-validator` has Bash and genuinely needs it (`git diff HEAD --name-only`, line 70; fenced read-only at line 150). No agent holds an unused tool. [MEDIUM]
- **Fabrication-inviting blanks**: none of the `Started: [timestamp]` kind in the audited agents. Auditors retracted two suspected blank findings after confirming date-stamped paths need only `YYYY-MM-DD`, supplied in-session — the established repo pattern, not a defect. [MEDIUM]
- **All six designated commands carry `--friction-log`.** [HIGH — personally verified]

## Confidence and method notes

Findings marked [HIGH] were re-verified in the parent session by direct file read or grep. Findings marked [MEDIUM] are auditor-reported with file:line citations but not independently re-checked; the plan phase should verify before acting. This distinction matters: one earlier finding this session (IV-004) was reported as "stale options" when the real defect was the opposite — incomplete options — and implementing it as written would have removed a working feature.

**Roster deviation** (per CLAUDE.md): the three audits ran on `general-purpose`, not an HVE roster agent. Reason: read-only inspection against a fixed checklist, with no tracking-artifact write wanted from the subagents themselves. The parent consolidated and wrote this document.

## Suggested phase shape for planning

Findings cluster by coupling, not by file:

1. **Validator/parent contract fixes** (M-01, M-05, M-06) — each needs a matching parent-side change; do not split agent and parent across phases.
2. **Dispatch correctness** (M-02, M-04) — nonexistent agent, wrong dispatch order.
3. **Unenforced guarantee** (M-03) — touches CLAUDE.md, prompt-builder, and prompt-evaluator together.
4. **Prompt drift** (M-07 through M-11, m-04 through m-09) — mechanical, parallelizable, low risk.
5. **Command-body gaps** (M-12, m-01, m-02, m-03).
6. **Test coverage** — a check that every `hve-*` agent name in commands resolves (Test 9 exists but did not catch M-02; determine why) and, if feasible, something covering the unreachable-text class.

Risk override applies: these are installed prompts consumed outside this repo, so classify at least Medium regardless of size.
