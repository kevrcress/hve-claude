# Research Findings: HVE Claude Project Overview for README Documentation
Date: 2026-05-29
Question: Gather comprehensive information about RPI methodology, workflows, conventions, benefits, and tool architecture for README documentation
Investigator: hve-researcher (subagent)

## Findings

1. **RPI Core Insight**: When an AI agent cannot implement during research, it stops optimizing for plausible code and starts optimizing for verified truth. Separating research, planning, implementation, and review phases by role produces higher-quality outcomes than asking a single session to do everything at once. CLAUDE.md:9-11 [HIGH]

2. **Five Operating Principles Established**: Context discipline (lean summaries), Durable artifacts over chat (disk is source of truth), Evidence-based responses (file:line citations), Difficulty-adaptive workflow (classify before acting), and Lean turns (full detail in logs, not chat). CLAUDE.md:13-19 [HIGH]

3. **Difficulty Classification System**: Four levels guide workflow routing—Simple (< 50 lines, skip subagents), Medium (2–5 files, 1–2 subagents), Medium-Hard (cross-cutting, parallel research + validation), Challenging (new patterns, full parallel dispatch). CLAUDE.md:21-28 [HIGH]

4. **Nine Slash Commands + Eight Specialized Subagents**: `/hve` (full RPI), `/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review`, `/hve-pr-review`, `/hve-memory`, `/hve-challenge`, `/hve-doc-ops`, `/hve-prompt-builder`, etc. Subagents: hve-researcher, hve-plan-validator, hve-implementation-validator, hve-rpi-validator, hve-phase-implementor, hve-prompt-tester, hve-prompt-evaluator, hve-prompt-updater. README.md:13-14 [HIGH]

5. **Durable Artifact Tracking Structure**: `.claude-hve-tracking/` (gitignored except durable artifacts) organizes research, plans, details, changes, reviews, challenges, memory, doc-ops, and sandbox by date + slug, enabling phase handoff and session resumption without manual file attachment. CLAUDE.md:56-83 [HIGH]

6. **Artifact Naming + Confidence Markers Convention**: Date format `YYYY-MM-DD`, slug `kebab-case`, suffixes `-plan.md`, `-details.md`, `-changes.md`, `-log.md`. Confidence markers `[HIGH]` (direct code/test), `[MEDIUM]` (pattern inference), `[LOW]` (assumed, needs validation) standardize evidence quality in handoffs. CLAUDE.md:87-124 [HIGH]

7. **Phase-Based Specialization Reduces Cognitive Load**: Each phase (Research, Plan, Implement, Review) has a dedicated agent that optimizes for a single role rather than trying to balance research rigor with implementation speed—researcher focuses on verified facts, planner focuses on completeness and dependency correctness, implementor focuses on code patterns, reviewer focuses on quality validation. .claude/agents/hve-researcher.md:1-9, .claude/agents/hve-plan-validator.md:1-9 [HIGH]

## Codebase References

CLAUDE.md
README.md
.claude/commands/hve.md
.claude/commands/hve-research.md
.claude/commands/hve-plan.md
.claude/commands/hve-implement.md
.claude/commands/hve-review.md
.claude/agents/hve-researcher.md
.claude/agents/hve-plan-validator.md
.claude/agents/hve-implementation-validator.md
.claude/agents/hve-phase-implementor.md
.claude/agents/hve-rpi-validator.md
prompts/rpi.md
prompts/checkpoint.md
prompts/doc-ops.md
instructions/bash.md
instructions/python.md
instructions/markdown.md
instructions/git-commit-messages.md
LICENSE
.gitignore
install.sh

## External References

https://github.com/microsoft/hve-core — Original HVE Core project (Microsoft), emphasizes convention-driven workflows, responsible AI practices, and scalability from solo developers to enterprise teams.

## Checklist

- [ ] Document the key benefits of RPI vs. single-agent chat-based development (verified truth emphasis, reduced context thrashing, better quality via role specialization)
- [ ] Explain the difficulty classification system with concrete examples for each level
- [ ] Detail the handoff and resumption mechanism for cross-session work (auto-discovery of artifacts)
- [ ] Create a quick-start section showing a minimal example RPI loop (e.g., `/hve add OAuth2`)
- [ ] Document the security hygiene checks built into the implementation validator (secret exposure, gitignore rules, dependency audits)

## Clarifying Questions

1. Should README document the internal subagent protocol (evidence-based findings format) or keep it user-focused on command usage?
2. What depth of explanation is appropriate for the five operating principles—is the one-line definition in README.md sufficient, or should README expand with examples?
3. Should README include a comparison table showing "Single-Agent Chat" vs. "HVE RPI Workflow" to motivate why this methodology matters?
