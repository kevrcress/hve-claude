# hve-claude

**HVE (Hypervelocity Engineering) Core for Claude Code**, a convention-driven agentic development workflow that enforces a Research → Plan → Implement → Review discipline, using Claude Code slash commands, parallel subagents, and durable file-based artifacts.

Adapted from [microsoft/hve-core](https://github.com/microsoft/hve-core) under the MIT License.

> **Scope:** This repo currently covers the core RPI workflow. The longer-term goal is to port the full agent library from [microsoft/hve-core](https://github.com/microsoft/hve-core), ADR creation, BRD/PRD builders, security planner, UX designer, backlog managers, and more. If you want the full set now, the upstream repo has them.

---

## Why this exists

When you ask a single Claude session to research, plan, and implement all at once, it optimizes for *plausible code*: code that looks right but may not be. When a research agent **cannot** write code during its turn, it has no choice but to optimize for *verified truth*.

HVE separates the phases by role:

- **Researcher** finds facts and cites them (no implementation pressure)
- **Planner** turns findings into a dependency-correct, phased plan (no implementation pressure)
- **Implementor** writes code against a verified plan (no research or planning pressure)
- **Reviewer** validates changes against the plan and runs quality checks (no implementation pressure)

The result: higher-quality output, leaner context windows, lower cost (Haiku for research/validation, Sonnet/Opus only for implementation), and artifacts on disk that survive session boundaries.

---

## Quick start

Works for new or existing projects, never touches your source code.

1. Paste this into Claude Code in your project directory to install HVE:
```
Please install the HVE Claude Code workflow into this project. Clone
https://github.com/kevrcress/hve-claude into a temporary directory, then
copy its hve-* commands and agents into my .claude/ folder, copy its
.claude/instructions/ and .claude/prompts/ files in, and merge everything above the
'## Your Project' heading in its CLAUDE.md into mine wrapped in these markers:
<!-- HVE:START - managed by install.sh, do not edit between markers -->
...HVE content...
<!-- HVE:END -->
If my CLAUDE.md already has those markers, replace the content between them.
If it has no markers, prepend the wrapped block before my existing content.
Never touch anything outside the markers or below '## Your Project'. Add the
.claude-hve-tracking subagents and sandbox paths to my .gitignore, then
delete the temp clone and show me what changed.
```
2. Paste this to add your project context:
```
Please add context about this project under ## Your Project in CLAUDE.md.
```
3. Run your first task _(replace the OAuth2 example with your own)_:
```
/hve add OAuth2 authentication to the API
```

That's it. Claude researches, plans, implements, and reviews, pausing for your approval between phases.

> **Prefer manual steps or the bash installer?** See [docs/installation.md](docs/installation.md) for the step-by-step manual instructions, the bash script option for Mac/Linux/WSL users, and the update prompt.

---

## Requirements

- [Claude Code](https://claude.ai/code), desktop app, VS Code/JetBrains extension, or CLI
- **Sonnet or Opus** recommended for implementation phases (configurable)
- **Haiku** used automatically for research and validation subagents (cost optimization, no configuration needed)

---

## How it works

> **Note:** Examples throughout the docs use "add OAuth2 authentication to the API" as a sample task. Substitute any task relevant to your project.

HVE runs a four-phase loop. Each phase is handled by a specialized agent that only does one thing:

```
/hve <task description>

  Phase 1 - Research    Parallel subagents investigate the codebase (and web if needed),
                        write findings to .claude-hve-tracking/research/, return summaries.
                        ↓  [checkpoint: "Research complete. Proceed to planning?"]

  Phase 2 - Plan        Converts findings into a phased implementation plan. A plan-validator
                        subagent checks it for completeness and coverage gaps.
                        ↓  [checkpoint: "Plan ready. Proceed to implementation?"]

  Phase 3 - Implement   Dispatches phase-implementor subagents per plan phase. Each reads the
                        relevant .claude/instructions/ file, writes code, and updates the changes log.
                        ↓  [checkpoint: "Implementation complete. Run review?"]

  Phase 4 - Review      RPI-validator subagents check each phase against the plan. An
                        implementation-validator runs a 10-dimension quality + security check.
```

Within each phase, subagents run in parallel where possible. See [docs/workflow.md](docs/workflow.md) for the full parallelism diagram and a phase-by-phase walkthrough.

### Difficulty classification

Before starting, HVE classifies the task and adjusts how many subagents to dispatch:

| Level | Signals | Approach |
|---|---|---|
| **Simple** | < 50 lines, single file, zero ambiguity | Implement directly, no subagents |
| **Medium** | 2–5 files, known patterns | 1–2 researcher subagents |
| **Medium-Hard** | Cross-cutting changes, multiple modules | Multiple researchers run in parallel, plan is validated before implementation begins |
| **Challenging** | New patterns, high risk, unclear requirements | Multiple researchers run in parallel, plan is validated, implementors run per-phase in parallel, and two validators run in parallel during review |

### User checkpoints

The `/hve` orchestrator pauses between every phase and asks for confirmation. You can review the research findings before a plan is written, review the plan before any code is touched, and review the implementation before the formal review runs. You're always in the loop.

Standalone phase commands (`/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review`) run one phase at a time and **auto-discover** the previous phase's artifact from `.claude-hve-tracking/`, no manual file attachment, no re-explaining context, even across separate conversations. For large tasks, running each phase in a fresh conversation keeps context lean.

---

## Command reference

### Phase commands

| Command | Purpose |
|---|---|
| `/hve <task>` | Full RPI loop in one conversation with user checkpoints between every phase. Accepts `--mode lightweight\|standard\|full` to override difficulty classification: `lightweight` skips subagents and implements directly; `standard` runs the full loop with 1–2 researchers; `full` uses maximum parallel dispatch (multiple researchers, parallel implementors, parallel review validators). Pass `--think` to activate extended reasoning during planning (auto-enabled for `--mode full` and Challenging tasks). |
| `/hve-research <task>` | Research phase only, spawns parallel investigators, writes findings |
| `/hve-plan` | Plan phase only, reads latest research artifact, writes implementation plan. Pass `--think` to activate extended reasoning. |
| `/hve-implement` | Implement phase only, reads latest plan, dispatches implementors per phase |
| `/hve-review` | Review phase only, validates changes against plan, runs quality checks. Pass `--think` to activate extended reasoning during verdict synthesis. |

> **`/hve` vs standalone phase commands**, `/hve` runs all four phases in one conversation, convenient for most tasks. Context accumulates across phases, though. For large or multi-day tasks, run each phase command in a fresh conversation to keep each phase lean; the standalone commands auto-discover the previous phase's artifact automatically. See [docs/workflow.md](docs/workflow.md#faq) for detail.

### Utility commands

| Command | Purpose |
|---|---|
| `/hve-pr-review` | Senior-level code review across 8 quality dimensions (functional, design, idiomatic, reuse, performance, reliability, security, docs). Supports `--dimension` to focus on one area. Pass `--compact` to run 4 paired subagents instead of 8 for a faster, lower-cost review. |
| `/hve-challenge` | Adversarial questioning of any current plan or implementation, acts as an uninformed skeptic to surface hidden assumptions |
| `/hve-doc-ops` | Documentation QA: pattern compliance, accuracy verification, gap detection. Supports `--scope` to target a specific area. |
| `/hve-memory` | Saves current session context, decisions, and open questions to `.claude-hve-tracking/memory/` for future conversations |

### Prompt engineering commands

These commands are for extending HVE itself, building new slash commands, agent definitions, and instruction files that follow HVE conventions.

| Command | Purpose |
|---|---|
| `/hve-prompt-builder` | Iterative sandbox for authoring new HVE agents, slash commands, and instruction files, uses a test → evaluate → update loop with specialized subagents |
| `/hve-prompt-analyze <file>` | Evaluates an existing HVE agent or prompt file against HVE quality criteria, returns severity-graded findings |
| `/hve-prompt-refactor <file>` | Cleans up and removes anti-patterns (including Copilot-specific syntax) from existing HVE prompt artifacts |

### Git workflow commands

| Command | Purpose |
|---|---|
| `/hve-git-commit` | Stages changes safely, generates a conventional commit message, and commits |
| `/hve-git-merge <op> <branch>` | Coordinates merge, rebase, and rebase-onto operations with consistent conflict handling |
| `/hve-git-setup` | Audits and configures git identity, editor, and tooling non-destructively |

### Examples

```
# Full RPI loop
/hve add OAuth2 authentication to the API
/hve --mode lightweight fix the typo in the 404 error message   # skip subagents, implement directly
/hve --mode full migrate the database schema to support multi-tenancy  # max parallel dispatch
/hve --think redesign the caching layer                 # extended reasoning during planning

# Run phases individually (recommended for large tasks)
/hve-research investigate the existing auth middleware
/hve-plan
/hve-implement
/hve-review

# Utility
/hve-pr-review                          # review current branch
/hve-pr-review --dimension security     # security-only review
/hve-pr-review --compact                # faster review with 4 paired subagents
/hve-challenge                          # challenge the latest plan
/hve-doc-ops                            # full documentation QA
/hve-doc-ops --scope src/auth/          # scoped to one directory
/hve-memory                             # save session context before closing

# Prompt engineering
/hve-prompt-builder                     # start authoring a new agent
/hve-prompt-analyze .claude/agents/hve-researcher.md
/hve-prompt-refactor .claude/agents/hve-researcher.md

# Git
/hve-git-commit
/hve-git-merge rebase main
/hve-git-merge rebase-onto main feature/old-base
```

---

## Installation

The paste-to-install prompt in [Quick start](#quick-start) is the fastest path and works on any OS. For step-by-step manual instructions, the bash installer, and the update prompt, see **[docs/installation.md](docs/installation.md)**.

### Add your project context

Open `CLAUDE.md` and add your project-specific details under `## Your Project`:

```markdown
## Your Project

This is a Node.js REST API using Express and PostgreSQL. The main entry point is
`src/server.ts`. Authentication uses JWT tokens stored in Redis.
```

This context is loaded into every Claude Code session and gives the agents the background they need to make good decisions.

### Tracking folder and version control

By default, durable HVE artifacts are **committed**, they are the shared history and rationale behind your work:

```
research/     plans/     details/     changes/     reviews/
challenges/   memory/    doc-ops/
```

**Note:** Your initial task prompt is captured at the top of the research and plan artifacts as the task description. Only the initial prompt is stored, not subsequent conversation. If you'd prefer not to commit these artifacts (for privacy or any other reason), see the gitignore options below.

Only the regenerable noise is gitignored by default:

```
.claude-hve-tracking/**/subagents/
.claude-hve-tracking/sandbox/
```

To keep the entire tracking folder private instead, replace those rules with:

```
.claude-hve-tracking/
```

---

## Benefits

| Aspect | Single-agent chat | HVE RPI |
|---|---|---|
| Research quality | Mixed with implementation pressure; optimizes for plausible code | Dedicated researcher optimizes for verified truth |
| Context window | Grows unbounded; quality degrades in long sessions | Each phase starts lean; artifacts on disk |
| Cross-session work | Requires re-explaining everything | Phase commands auto-discover artifacts, just run the next command |
| Quality gates | Ad hoc or none | Plan validation, per-phase RPI validation, 10-dimension review |
| Parallel investigation | Sequential | Multiple researchers run in parallel per research question |
| Security | Manual | Automatic security hygiene scan in every review |
| Cost | Expensive (large context, expensive model throughout) | Haiku for research/validation; Sonnet/Opus only for implementation |
| Commit messages | Manual | `/hve-git-commit` generates conventional messages from changes log |
| PR reviews | Manual or generic | `/hve-pr-review` runs 8 specialized reviewers in parallel |

---

## Limitations

**HVE verifies structure, not external truth.** Researchers treat the codebase as the source of truth. They'll confirm a term *is* defined, but won't catch a wrong definition unless you tell them where to verify against. Example: vanilla Claude Code defined HVE as "Human-Value Engineering" (incorrect). When asked to audit CLAUDE.md and verify abbreviations were correctly defined, `/hve-research` marked it ✅ because the term *was* defined. It only caught the error when explicitly told to cross-reference against the Microsoft repo, where the correct definition ("Hypervelocity Engineering") is documented.

**Tip:** If your task involves verifying correctness against a spec, upstream repo, or external standard, include the reference explicitly in your prompt, e.g. *"verify terms against microsoft/hve-core."*

---

## See it in action

This repo was initially built with vanilla Claude Code, then HVE was installed into itself and used to improve its own README. The artifacts below are real output from that first dogfood run:

```
/hve Update the README and make sure it's comprehensive: describe the project, goal, what everything does, all agents and subagents, the workflow, the methodology, how to use the tool, quick setup, and benefits.
```

These aren't hand-crafted examples. Browse them to see what each phase actually produces:

| Artifact | What it shows |
|---|---|
| [Consolidated research](/.claude-hve-tracking/research/2026-05-29/update-readme.md) | Findings from 3 parallel researcher subagents, consolidated |
| [Changes log](/.claude-hve-tracking/changes/2026-05-29/update-readme-changes.md) | What the implementor did, phase by phase |
| [RPI validation](/.claude-hve-tracking/reviews/rpi/2026-05-29/update-readme-rpi.md) | Did the implementation match the plan? |
| [Quality review](/.claude-hve-tracking/reviews/rpi/2026-05-29/update-readme-quality.md) | 10-dimension quality check output |

---

## Further reading

| Document | Covers |
|---|---|
| [docs/installation.md](docs/installation.md) | Manual install steps, bash installer, updating an existing install |
| [docs/workflow.md](docs/workflow.md) | Subagent parallelism, phase-by-phase walkthrough, follow-on items, full FAQ |
| [docs/reference.md](docs/reference.md) | Tracking folder structure, language instruction files, reusable prompts |
| [docs/internals.md](docs/internals.md) | Subagent roster, quality-validator dimensions |
| [CLAUDE.md](CLAUDE.md) | The conventions installed into every project, response protocol, confidence markers, citation format, severity grading, operating principles |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Branch strategy and how to run the test suite |

---

## License

MIT, see [LICENSE](LICENSE)

Adapted from [microsoft/hve-core](https://github.com/microsoft/hve-core), also MIT.
