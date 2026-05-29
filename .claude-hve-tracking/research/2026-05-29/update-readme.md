# Research Findings: HVE Claude — Comprehensive README Documentation
Date: 2026-05-29
Task: Update README.md to be thorough — project description, methodology, commands, agents, workflow, setup, benefits

---

## Project Overview

HVE Claude is a **convention-driven agentic development workflow** for [Claude Code](https://claude.ai/code), adapted from [microsoft/hve-core](https://github.com/microsoft/hve-core). It enforces a Research → Plan → Implement → Review (RPI) methodology using Claude Code slash commands, specialized subagents, and durable file-based handoff artifacts. [HIGH]

**Core Insight**: When an AI agent cannot implement during research, it stops optimizing for plausible code and starts optimizing for verified truth. Separating phases by role produces higher-quality outcomes than asking a single session to do everything at once. [HIGH]

---

## The RPI Methodology

### Five Operating Principles

1. **Context discipline** — After a subagent returns, respond with lean summaries only. Full detail lives in the log file, not chat.
2. **Durable artifacts over chat** — All research, plans, and reviews live in `.claude-hve-tracking/`. Chat is ephemeral; disk is the source of truth.
3. **Evidence-based responses** — Every finding cites `file:line`. No unsupported claims.
4. **Difficulty-adaptive workflow** — Classify tasks before acting. Simple tasks skip subagents. Complex tasks use full parallel dispatch.
5. **Lean turns** — Parent agents return a one-line summary after subagent work.

### Difficulty Classification

| Level | Characteristics | Approach |
|---|---|---|
| Simple | < 50 lines, single file, clear requirements | Skip subagents; implement directly |
| Medium | 2–5 files, known patterns | 1–2 researcher subagents |
| Medium-Hard | Cross-cutting, multiple modules | Parallel research + plan validation |
| Challenging | New patterns, high risk, unclear requirements | Full parallel dispatch: research, plan, implement, review |

---

## All 15 Slash Commands

### Primary Phase Commands

| Command | Purpose |
|---|---|
| `/hve <task>` | Full RPI orchestrator: Research → Plan → Implement → Review with user checkpoints |
| `/hve-research <task>` | Phase 1: Spawn parallel researcher subagents, consolidate findings |
| `/hve-plan` | Phase 2: Convert research to implementation plan with phases + dependencies |
| `/hve-implement` | Phase 3: Execute plan phase-by-phase with implementor subagents, write changes log |
| `/hve-review` | Phase 4: Validate changes against plan, run quality + security checks |

### Utility Commands

| Command | Purpose |
|---|---|
| `/hve-pr-review` | Senior-level code review across 8 parallel quality dimensions |
| `/hve-memory` | Save session decisions, open questions, and context for future conversations |
| `/hve-challenge` | Adversarial interrogation of current plans or implementations |
| `/hve-doc-ops` | Documentation QA: compliance, accuracy verification, gap detection |

### Prompt Engineering Commands

| Command | Purpose |
|---|---|
| `/hve-prompt-builder` | Iterative test → evaluate → update loop for authoring/improving agents and prompts |
| `/hve-prompt-analyze <file>` | Evaluate an existing agent or prompt file against quality criteria |
| `/hve-prompt-refactor <file>` | Clean up and de-Copilot an existing prompt artifact |

### Git Workflow Commands

| Command | Purpose |
|---|---|
| `/hve-git-commit` | Stage safely, generate conventional commit message, commit |
| `/hve-git-merge <op> <branch>` | Merge/rebase/rebase-onto with conflict handling |
| `/hve-git-setup` | Audit and configure git identity and tooling safely |

---

## All 8 Subagents

Subagents are specialized agents spawned by the phase commands. They are not invoked directly by the user — the orchestrator commands dispatch them.

| Agent | Role | Tools | Model | When Spawned |
|---|---|---|---|---|
| `hve-researcher` | Targeted codebase + web investigation | Read, Write, Glob, Grep, WebFetch | Haiku | Phase 1: parallel per research question |
| `hve-plan-validator` | Validates plan against research for completeness | Read, Write, Edit, Glob, Grep | Haiku | Phase 2: after plan is drafted |
| `hve-phase-implementor` | Executes one plan phase: writes code + updates changes log | All tools | Inherit | Phase 3: parallel per independent plan phase |
| `hve-rpi-validator` | Verifies completed phase implementation matches plan | Read, Write, Glob, Grep | Haiku | Phase 4: per completed plan phase |
| `hve-implementation-validator` | 10-dimension quality check including security hygiene | Read, Write, Glob, Grep, Bash | Haiku | Phase 4: overall quality gate |
| `hve-prompt-evaluator` | Rates prompts against clarity/completeness/format/no-copilot criteria | Read, Write, Glob, Grep | Haiku | `/hve-prompt-builder` evaluate loop |
| `hve-prompt-tester` | Executes draft prompt/agent literally against test scenarios | All tools | Inherit | `/hve-prompt-builder` test loop |
| `hve-prompt-updater` | Rewrites prompts based on evaluator findings | All tools | Inherit | `/hve-prompt-builder` update loop |

### Tool Access Matrix

- **Read-only investigation**: hve-researcher, hve-plan-validator, hve-rpi-validator — no code modification
- **Code writing**: hve-phase-implementor — full tool access
- **Quality validation**: hve-implementation-validator — Bash for git read-only operations
- **No Agent tool**: Subagents cannot spawn further subagents; only orchestrator commands can

### The `hve-implementation-validator` 10 Dimensions

1. Architecture conformance
2. Design quality
3. DRY / reuse
4. API usage correctness
5. Security (automatic: secret exposure, .gitignore hygiene, committed secrets, dependency audit)
6. Test coverage
7. Error handling
8. Performance
9. Documentation
10. Security hygiene (grepping for PRIVATE KEY, api_key, password, Bearer, etc.)

---

## Subagent Response Protocol

All subagents return in a strict format:
1. One line: artifact path written
2. One line: status (Pass / Fail / Complete / Blocked)
3. Up to **7 bullet findings** (≤ 240 chars each; Critical/Major prioritized)
4. A checklist of up to **5 follow-on items**
5. Up to **3 clarifying questions** (only if blocking)
6. One line: "Full detail: re-read `<path>`"

---

## Tracking Folder Structure

All runtime artifacts live in `.claude-hve-tracking/`. The durable folders are committed by default.

```
.claude-hve-tracking/
├── research/
│   ├── YYYY-MM-DD/topic.md          # Consolidated findings
│   └── subagents/YYYY-MM-DD/        # Per-subagent raw findings (gitignored)
├── plans/
│   ├── YYYY-MM-DD/task-slug-plan.md # Implementation plan
│   └── logs/YYYY-MM-DD/task-slug-log.md  # Planning discrepancy log
├── details/
│   └── YYYY-MM-DD/task-slug-details.md
├── changes/
│   └── YYYY-MM-DD/task-slug-changes.md  # Updated per phase
├── reviews/
│   ├── rpi/YYYY-MM-DD/              # RPI validation output
│   └── pr/branch-name/              # PR review output
├── challenges/
├── memory/
├── doc-ops/
└── sandbox/                         # gitignored
```

---

## Artifact Conventions

- **Date format**: `YYYY-MM-DD`
- **Slug**: `kebab-case-description` (3–6 words)
- **Suffixes**: `-plan.md`, `-details.md`, `-changes.md`, `-log.md`
- **Confidence markers**: `[HIGH]` (direct evidence), `[MEDIUM]` (inferred), `[LOW]` (assumed)
- **Citations**: `file:line` — plain paths, no markdown links

---

## Installation

`install.sh` is an idempotent installer. What it does:
1. Copies `.claude/commands/hve*.md` and `.claude/agents/hve*.md` to target project
2. Copies `instructions/` and `prompts/` directories
3. Merges the HVE block into `CLAUDE.md` (between markers, preserving `## Your Project`)
4. Adds `.gitignore` rules for `subagents/` and `sandbox/` (regenerable noise)

---

## Language/Tool Instruction Files

12 files in `instructions/` covering:
- `bash.md` — `set -euo pipefail`, 2-space indent, no bashisms
- `python.md`, `python-uv.md`, `python-tests.md` — PEP 8, ruff, type annotations, uv tooling, pytest conventions
- `csharp.md`, `csharp-tests.md` — .NET conventions, xUnit
- `rust.md`, `rust-tests.md` — Rust idioms, cargo test
- `terraform.md` — HCL conventions
- `markdown.md` — document structure rules
- `git-commit-messages.md` — conventional commits
- `writing-style.md` — prose guidelines

The `hve-phase-implementor` reads the relevant instruction file before writing any code.

---

## Benefits vs. Single-Agent Chat

| Aspect | Single-Agent Chat | HVE RPI |
|---|---|---|
| Research quality | Mixed with implementation pressure | Dedicated researcher optimizes for verified truth |
| Context management | Grows unbounded; late-session drift | Each phase starts lean; artifacts on disk |
| Cross-session work | Requires re-explaining everything | Phase commands auto-discover artifacts |
| Quality gates | Ad hoc or none | Mandatory plan validation, RPI validation, 10-dimension review |
| Parallel investigation | Sequential | Multiple researchers in parallel per question |
| Security | Manual | Automatic security hygiene in every review |
| Cost | Expensive (large context, expensive model) | Haiku for research/validation, Sonnet/Opus only for implementation |

---

## Current README Gaps

The existing README.md (84 lines) is a minimal overview. It is missing:
- Methodology section (operating principles, difficulty classification)
- Full command reference (only lists 10 of 15, no descriptions)
- Agent/subagent documentation (no agent details or when they're used)
- Workflow diagram or phase-by-phase walkthrough
- Benefits section
- Tracking folder structure visualization
- Artifact conventions
- Language instruction file list
- Comparison with single-agent workflow
- Quick-start section with concrete example
