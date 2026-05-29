# Research Findings: HVE Agents & Subagents Inventory
Date: 2026-05-29
Question: Gather comprehensive information about all agents and subagents in the HVE Claude project, their purpose, tools, relationships, and when/how they are used for README documentation purposes.
Investigator: hve-researcher (subagent)

## Executive Summary

The HVE Claude project implements a structured RPI (Research → Plan → Implement → Review) methodology using 8 specialized agent definitions and 15 slash commands. The agents are organized hierarchically: orchestrator commands (hve, hve-research, hve-plan, hve-implement, hve-review) spawn specialized subagents to execute individual phases. Additional utility commands support prompt engineering, version control, PR review, challenge/adversarial analysis, and documentation QA.

---

## Findings

1. **Eight core agent definitions exist** — `.claude/agents/` contains hve-researcher, hve-plan-validator, hve-phase-implementor, hve-implementation-validator, hve-rpi-validator, hve-prompt-evaluator, hve-prompt-tester, hve-prompt-updater. Each has frontmatter (name, description, model, color) and subagent response format constraints (≤7 findings, checklist, full-detail pointer). `hve-researcher`, `hve-plan-validator`, `hve-phase-implementor`, `hve-implementation-validator`, `hve-rpi-validator` are directly mentioned in CLAUDE.md Security Hygiene section. [HIGH]

2. **Subagent response protocol (CLAUDE.md:142-152)** requires: (1) artifact path written, (2) status line, (3) ≤7 bullet findings (≤240 chars each), (4) ≤5 checklist items, (5) ≤3 clarifying questions, (6) full-detail pointer. All research, plan, implement, and review phase agents follow this protocol. Prompt builder agents (evaluator/tester/updater) follow slightly modified format. [HIGH]

3. **Orchestrator spawning relationships**: `/hve` (main RPI orchestrator) spawns `hve-researcher` parallel subagents (Phase 1), `hve-plan-validator` (Phase 2 for standard/complex plans), `hve-phase-implementor` parallel per plan phase (Phase 3), `hve-rpi-validator` per completed phase + `hve-implementation-validator` in full-quality mode (Phase 4). `/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review` are phase-specific commands that embed the same subagent logic. [HIGH]

4. **Tool access distribution** — `hve-researcher` has Read/Write/Glob/Grep/WebFetch; `hve-plan-validator` has Read/Write/Edit/Glob/Grep; `hve-phase-implementor` inherits model from orchestrator and handles code modification; `hve-implementation-validator` has Read/Write/Glob/Grep/Bash (git read-only); `hve-rpi-validator` has Read/Write/Glob/Grep; prompt agents (evaluator/tester/updater) have Read/Write/Glob/Grep (tester/updater inherit model). No agent has access to Agent tool for further subagent spawning (only orchestrator commands do). [HIGH]

5. **Prompt engineering pipeline** — `/hve-prompt-builder` orchestrates iterative test-evaluate-update loop via 3 specialized subagents: `hve-prompt-tester` (executes draft literally against scenarios), `hve-prompt-evaluator` (rates against clarity/completeness/actionability/format/no-copilot-isms), `hve-prompt-updater` (rewrites based on findings). Output goes to `.claude-hve-tracking/sandbox/` with run numbering. Quality criteria check for 5-point compliance. [HIGH]

6. **Standalone utility commands** — `/hve-pr-review` (senior code review, spawns 8 parallel dimension-focused subagents for functional/design/idiomatic/reuse/performance/reliability/security/docs), `/hve-challenge` (adversarial interrogation, reads artifacts only), `/hve-doc-ops` (documentation QA with compliance/accuracy/gaps phases), `/hve-memory` (session context save), `/hve-git-commit`, `/hve-git-merge`, `/hve-git-setup` (git operations). PR review supports `--dimension` filtering. Doc-ops supports `--scope` filtering. [HIGH]

7. **Prompt-specific tools and constraints**: `hve-prompt-evaluator` checks for Copilot anti-patterns (no `runSubagent()`, no Copilot model strings, no VS Code shortcuts, no `applyTo` globs, no `/prompt-name` syntax). `hve-phase-implementor` mandates reading relevant `instructions/` file before implementing (e.g., `instructions/python.md`). `hve-implementation-validator` dimension 10 checks security automatically (secret exposure, .gitignore hygiene, committed secrets, dependency audit). [HIGH]

---

## Codebase References

`.claude/agents/hve-researcher.md`
`.claude/agents/hve-plan-validator.md`
`.claude/agents/hve-phase-implementor.md`
`.claude/agents/hve-implementation-validator.md`
`.claude/agents/hve-rpi-validator.md`
`.claude/agents/hve-prompt-evaluator.md`
`.claude/agents/hve-prompt-tester.md`
`.claude/agents/hve-prompt-updater.md`
`.claude/commands/hve.md`
`.claude/commands/hve-research.md`
`.claude/commands/hve-plan.md`
`.claude/commands/hve-implement.md`
`.claude/commands/hve-review.md`
`.claude/commands/hve-pr-review.md`
`.claude/commands/hve-challenge.md`
`.claude/commands/hve-doc-ops.md`
`.claude/commands/hve-prompt-builder.md`
`.claude/commands/hve-prompt-analyze.md`
`.claude/commands/hve-prompt-refactor.md`
`.claude/commands/hve-memory.md`
`.claude/commands/hve-git-commit.md`
`.claude/commands/hve-git-merge.md`
`.claude/commands/hve-git-setup.md`
`CLAUDE.md` (lines 142-152 for subagent protocol; lines 204-209 for security dimension)

---

## External References

None consulted; all information derived directly from codebase files.

---

## Checklist

- [ ] Create master agents reference table (name, description, role, tools, when-used)
- [ ] Document subagent response protocol visual diagram (format constraints)
- [ ] Create orchestrator spawning diagram showing Phase 1-4 agent tree
- [ ] Document tool access matrix (which tools each agent has)
- [ ] Verify all 15 slash commands are documented in command reference table
- [ ] Check for any undocumented or ad-hoc agents in prompts/ directory

---

## Clarifying Questions

1. Should README document all 15 slash commands or focus on the 4 primary phase commands + orchestrator? (Research indicates users may call `/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review` directly for phase-specific workflows, in addition to full `/hve` loop.)
2. Are the prompt-builder agents (`hve-prompt-evaluator`, `hve-prompt-tester`, `hve-prompt-updater`) intended for end-user documentation, or are they internal tooling for the HVE maintainers? (Found in agents/ directory with same structure as phase agents, but used only by `/hve-prompt-builder` command.)
3. Should README include a security checklist section that documents the automatic security scanning performed by `hve-implementation-validator` dimension 10? (Currently in CLAUDE.md:204-209 but not in README.)
