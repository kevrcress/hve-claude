# hve-claude

**HVE Core for Claude Code** — a convention-driven agentic development workflow that enforces a Research → Plan → Implement → Review discipline, using Claude Code slash commands, parallel subagents, and durable file-based artifacts.

Adapted from [microsoft/hve-core](https://github.com/microsoft/hve-core) under the MIT License.

> **Scope:** This repo currently covers the core RPI workflow. The longer-term goal is to port the full agent library from [microsoft/hve-core](https://github.com/microsoft/hve-core) — ADR creation, BRD/PRD builders, security planner, UX designer, backlog managers, and more. If you want the full set now, the upstream repo has them.

---

## Why this exists

When you ask a single Claude session to research, plan, and implement all at once, it optimizes for *plausible code* — code that looks right but may not be. When a research agent **cannot** write code during its turn, it has no choice but to optimize for *verified truth*.

HVE separates the phases by role:

- **Researcher** finds facts and cites them — no implementation pressure
- **Planner** turns findings into a dependency-correct, phased plan — no implementation pressure
- **Implementor** writes code against a verified plan — no research or planning pressure
- **Reviewer** validates changes against the plan and runs quality checks — no implementation pressure

The result: higher-quality output, leaner context windows, lower cost (Haiku for research/validation, Sonnet/Opus only for implementation), and artifacts on disk that survive session boundaries.

---

## Quick start

Works for new or existing projects — never touches your source code.

1. Paste this into Claude Code in your project directory to install HVE:
```
Please install HVE into this project: clone https://github.com/kevrcress/hve-claude to a temporary directory, run install.sh targeting the current directory, then clean up the temp clone.
```
2. Paste this to add your project context:
```
Please add context about this project under ## Your Project in CLAUDE.md.
```
3. Run your first task _(replace the OAuth2 example with your own)_:
```
/hve add OAuth2 authentication to the API
```

That's it. Claude researches, plans, implements, and reviews — pausing for your approval between phases.

> **Prefer the terminal?** Clone the repo anywhere outside your project and run `./hve-claude/install.sh /path/to/your/project` manually.

---

## Requirements

- [Claude Code](https://claude.ai/code) — desktop app, VS Code/JetBrains extension, or CLI
- **Sonnet or Opus** recommended for implementation phases (configurable)
- **Haiku** used automatically for research and validation subagents (cost optimization — no configuration needed)

---

## How it works

> **Note:** The examples throughout this documentation use "add OAuth2 authentication to the API" as a sample task. Substitute any task relevant to your project.

HVE runs a four-phase loop. Each phase is handled by a specialized agent that only does one thing:

```
/hve <task description>

  Phase 1 — Research    Parallel subagents investigate the codebase (and web if needed),
                        write findings to .claude-hve-tracking/research/, return summaries.
                        ↓  [checkpoint: "Research complete. Proceed to planning?"]

  Phase 2 — Plan        Converts findings into a phased implementation plan. A plan-validator
                        subagent checks it for completeness and coverage gaps.
                        ↓  [checkpoint: "Plan ready. Proceed to implementation?"]

  Phase 3 — Implement   Dispatches phase-implementor subagents per plan phase. Each reads the
                        relevant instructions/ file, writes code, and updates the changes log.
                        ↓  [checkpoint: "Implementation complete. Run review?"]

  Phase 4 — Review      RPI-validator subagents check each phase against the plan. An
                        implementation-validator runs a 10-dimension quality + security check.
```

### Subagent parallelism

Within each phase, subagents run in parallel where possible:

```
Phase 1 — Research
  ├── hve-researcher (auth middleware)  ─┐
  ├── hve-researcher (OAuth2 libraries)  ├── parallel
  └── hve-researcher (session handling) ─┘

Phase 2 — Plan
  └── hve-plan-validator                    (after plan is drafted)

Phase 3 — Implement
  ├── hve-phase-implementor (phase 1) ─┐
  ├── hve-phase-implementor (phase 3)  ├── parallel (where independent)
  └── hve-phase-implementor (phase 5) ─┘

Phase 4 — Review
  ├── hve-rpi-validator (phase 1) ─┐
  ├── hve-rpi-validator (phase 2)  ├── parallel
  ├── hve-rpi-validator (phase 3)  │
  └── hve-implementation-validator ─┘
```

### Difficulty classification

Before starting, HVE classifies the task and adjusts how many subagents to dispatch:

| Level | Signals | Approach |
|---|---|---|
| **Simple** | < 50 lines, single file, zero ambiguity | Implement directly — no subagents |
| **Medium** | 2–5 files, known patterns | 1–2 researcher subagents |
| **Medium-Hard** | Cross-cutting changes, multiple modules | Multiple researchers run in parallel, plan is validated before implementation begins |
| **Challenging** | New patterns, high risk, unclear requirements | Multiple researchers run in parallel, plan is validated, implementors run per-phase in parallel, and two validators run in parallel during review |

### User checkpoints

The `/hve` orchestrator pauses between every phase and asks for confirmation. You can review the research findings before a plan is written, review the plan before any code is touched, and review the implementation before the formal review runs. You're always in the loop.

Standalone phase commands (`/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review`) run one phase at a time and **auto-discover** the previous phase's artifact from `.claude-hve-tracking/` — no manual file attachment, no re-explaining context, even across separate conversations. For large tasks, running each phase in a fresh conversation keeps context lean.

---

## Command reference

### Phase commands

| Command | Purpose |
|---|---|
| `/hve <task>` | Full RPI loop in one conversation with user checkpoints between every phase. Accepts `--mode lightweight\|standard\|full` to override the automatic difficulty classification. |
| `/hve-research <task>` | Research phase only — spawns parallel investigators, writes findings |
| `/hve-plan` | Plan phase only — reads latest research artifact, writes implementation plan |
| `/hve-implement` | Implement phase only — reads latest plan, dispatches implementors per phase |
| `/hve-review` | Review phase only — validates changes against plan, runs quality checks |

> **`/hve` vs standalone phase commands** — `/hve` runs all four phases in one conversation, which is convenient for most tasks. Context accumulates across phases, though. For large or multi-day tasks, run each phase command in a fresh conversation to keep each phase lean. The standalone commands auto-discover the previous phase's artifact from `.claude-hve-tracking/` automatically — nothing is lost between sessions. See the [FAQ](#faq) for more detail.

### Utility commands

| Command | Purpose |
|---|---|
| `/hve-pr-review` | Senior-level code review across 8 quality dimensions (functional, design, idiomatic, reuse, performance, reliability, security, docs). Supports `--dimension` to focus on one area. |
| `/hve-challenge` | Adversarial questioning of any current plan or implementation — acts as an uninformed skeptic to surface hidden assumptions |
| `/hve-doc-ops` | Documentation QA: pattern compliance, accuracy verification, gap detection. Supports `--scope` to target a specific area. |
| `/hve-memory` | Saves current session context, decisions, and open questions to `.claude-hve-tracking/memory/` for future conversations |

### Prompt engineering commands

These commands are for extending HVE itself — building new slash commands, agent definitions, and instruction files that follow HVE conventions.

| Command | Purpose |
|---|---|
| `/hve-prompt-builder` | Iterative sandbox for authoring new HVE agents, slash commands, and instruction files — uses a test → evaluate → update loop with specialized subagents |
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
/hve --mode lightweight fix the typo in the 404 error message
/hve --mode full migrate the database schema to support multi-tenancy

# Run phases individually (recommended for large tasks)
/hve-research investigate the existing auth middleware
/hve-plan
/hve-implement
/hve-review

# Utility
/hve-pr-review                          # review current branch
/hve-pr-review --dimension security     # security-only review
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

### Step 1: Run the installer

```bash
# From the hve-claude repo root
./install.sh /path/to/your/project

# Or from inside the target project
/path/to/hve-claude/install.sh
```

The installer:
- Copies `.claude/commands/hve*.md` and `.claude/agents/hve*.md` into your project
- Copies `instructions/` (language conventions) and `prompts/` (reusable task prompts: `rpi.md`, `checkpoint.md`, `doc-ops.md`, `pull-request.md`, `task-challenge.md`, `prompt-build.md`)
- **Merges** the HVE methodology block into your project's `CLAUDE.md` — it preserves any content you have under `## Your Project` and is safe to re-run
- Adds `.gitignore` rules for the regenerable parts of `.claude-hve-tracking/`

The installer is **idempotent** — re-run it any time to pull in updates from this repo.

### Step 2: Add your project context

Open `CLAUDE.md` and add your project-specific details under `## Your Project`:

```markdown
## Your Project

This is a Node.js REST API using Express and PostgreSQL. The main entry point is
`src/server.ts`. Authentication uses JWT tokens stored in Redis.
```

This context is loaded into every Claude Code session and gives the agents the background they need to make good decisions.

### Tracking folder and version control

By default, durable HVE artifacts are **committed** — they are the shared history and rationale behind your work:

```
research/     plans/     details/     changes/     reviews/
challenges/   memory/    doc-ops/
```

**Note:** Your initial task prompt is captured at the top of the research and plan artifacts as the task description. Only the initial prompt is stored — not subsequent conversation. If you'd prefer not to commit these artifacts (for privacy or any other reason), see the gitignore options below.

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

## Workflow walkthrough

> **Note:** "Add OAuth2 authentication to the API" is used as an example task throughout — substitute your own.

Here's what happens when you run `/hve add OAuth2 to the API`:

**Phase 1 — Research**

Three researcher subagents run in parallel:
- One maps the existing auth middleware
- One surveys the OAuth2 library landscape for this stack
- One checks for existing session handling and token storage

All three write their findings to `.claude-hve-tracking/research/2026-05-29/add-oauth2-api.md`. You see a summary and are asked: *"Research complete. Shall I proceed to planning?"*

**Phase 2 — Plan**

A plan is created with phases like:
1. Add OAuth2 dependencies
2. Implement the authorization code flow
3. Wire up the callback route
4. Add session persistence
5. Update existing tests

A `hve-plan-validator` subagent checks the plan against the research for gaps or contradictions. You see the phase list and are asked: *"Does this plan look right? Proceed to implementation?"*

**Phase 3 — Implement**

Independent phases run in parallel (phases 1 and 5 can run simultaneously). Each `hve-phase-implementor` subagent reads `instructions/` for the relevant language before writing any code, then updates the changes log. You see a summary of files changed and are asked: *"Implementation complete. Shall I run the review?"*

**Phase 4 — Review**

Two things run in parallel:
- `hve-rpi-validator` subagents verify each plan phase was actually implemented correctly
- `hve-implementation-validator` runs a 10-dimension quality check including automated security hygiene

You get a final report with a severity-graded finding list and overall status.

---

## Benefits

| Aspect | Single-agent chat | HVE RPI |
|---|---|---|
| Research quality | Mixed with implementation pressure; optimizes for plausible code | Dedicated researcher optimizes for verified truth |
| Context window | Grows unbounded; quality degrades in long sessions | Each phase starts lean; artifacts on disk |
| Cross-session work | Requires re-explaining everything | Phase commands auto-discover artifacts — just run the next command |
| Quality gates | Ad hoc or none | Plan validation, per-phase RPI validation, 10-dimension review |
| Parallel investigation | Sequential | Multiple researchers run in parallel per research question |
| Security | Manual | Automatic security hygiene scan in every review |
| Cost | Expensive (large context, expensive model throughout) | Haiku for research/validation; Sonnet/Opus only for implementation |
| Commit messages | Manual | `/hve-git-commit` generates conventional messages from changes log |
| PR reviews | Manual or generic | `/hve-pr-review` runs 8 specialized reviewers in parallel |

---

## Limitations

**HVE verifies structure, not external truth.** Researchers treat the codebase as the source of truth — they'll confirm a term *is* defined, but won't catch a wrong definition unless you tell them where to verify against. Example: vanilla Claude Code defined HVE as "Human-Value Engineering" (incorrect). When asked to audit CLAUDE.md and verify abbreviations were correctly defined, `/hve-research` marked it ✅ — because the term *was* defined. It only caught the error when explicitly told to cross-reference against the Microsoft repo, where the correct definition ("Hypervelocity Engineering") is documented.

**Tip:** If your task involves verifying correctness against a spec, upstream repo, or external standard, include the reference explicitly in your prompt — e.g. *"verify terms against microsoft/hve-core."*

---

## See it in action

This repo was initially built with vanilla Claude Code, then HVE was installed into itself and used to improve its own README. The artifacts below are real output from that first dogfood run:

```
/hve Update the README and make sure it's comprehensive: describe the project, goal, what everything does, all agents and subagents, the workflow, the methodology, how to use the tool, quick setup, and benefits.
```

Not hand-crafted examples — browse them to see what each phase actually produces:

| Artifact | What it shows |
|---|---|
| [Consolidated research](/.claude-hve-tracking/research/2026-05-29/update-readme.md) | Findings from 3 parallel researcher subagents, consolidated |
| [Research: agents](/.claude-hve-tracking/research/2026-05-29/update-readme-agents.md) | Subagent findings on the agent inventory |
| [Research: commands](/.claude-hve-tracking/research/2026-05-29/update-readme-commands.md) | Subagent findings on the command reference |
| [Research: methodology](/.claude-hve-tracking/research/2026-05-29/update-readme-methodology.md) | Subagent findings on the RPI methodology |
| [Changes log](/.claude-hve-tracking/changes/2026-05-29/update-readme-changes.md) | What the implementor did, phase by phase |
| [RPI validation](/.claude-hve-tracking/reviews/rpi/2026-05-29/update-readme-rpi.md) | Did the implementation match the plan? |
| [Quality review](/.claude-hve-tracking/reviews/rpi/2026-05-29/update-readme-quality.md) | 10-dimension quality check output |

---

## Tracking folder structure

```
.claude-hve-tracking/
├── research/
│   ├── YYYY-MM-DD/topic.md                     # Consolidated findings
│   └── subagents/YYYY-MM-DD/topic.md            # Per-subagent raw findings (gitignored)
├── plans/
│   ├── YYYY-MM-DD/task-slug-plan.md             # Implementation plan (phases + deps)
│   └── logs/YYYY-MM-DD/task-slug-log.md         # Planning discrepancy log
├── details/
│   └── YYYY-MM-DD/task-slug-details.md
├── changes/
│   └── YYYY-MM-DD/task-slug-changes.md          # Updated per implemented phase
├── reviews/
│   ├── rpi/YYYY-MM-DD/                          # RPI validation output
│   └── pr/branch-name/                          # PR review output
├── challenges/
│   └── YYYY-MM-DD-topic-challenge.md
├── memory/
│   └── YYYY-MM-DD/kebab-slug.md
├── doc-ops/
│   └── YYYY-MM-DD-session.md
└── sandbox/                                     # Prompt builder runs (gitignored)
    └── YYYY-MM-DD-topic-run-N/
```

**Artifact naming:**
- Date format: `YYYY-MM-DD`
- Slug: `kebab-case-description` (3–6 words), e.g. `add-oauth2-api`
- Suffixes: `-plan.md`, `-details.md`, `-changes.md`, `-log.md`

---

## Language instruction files

HVE works with any language or tech stack — these instruction files are optional style guides, not a requirement. The `hve-phase-implementor` reads the relevant file in `instructions/` before writing code if one exists for that language. If your language isn't listed, HVE still implements — it just won't have a pre-loaded convention guide. You can add your own instruction files for any language and reference them in `CLAUDE.md`.

The files below are included out of the box (ported from the MS repo):

| File | Covers |
|---|---|
| `bash.md` | `set -euo pipefail`, 2-space indent, portable POSIX patterns |
| `python.md` | PEP 8, ruff, type annotations, import order |
| `python-uv.md` | uv tooling, lockfiles, virtual environments |
| `python-tests.md` | pytest conventions, fixtures, parametrize |
| `csharp.md` | .NET naming, async/await, nullable reference types |
| `csharp-tests.md` | xUnit, Arrange/Act/Assert, test isolation |
| `rust.md` | Rust idioms, error handling, ownership patterns |
| `rust-tests.md` | `#[cfg(test)]`, integration test layout, cargo test |
| `terraform.md` | HCL style, module conventions, variable naming |
| `markdown.md` | Document structure, heading hierarchy, table formatting |
| `git-commit-messages.md` | Conventional commits, scope, subject line rules |
| `writing-style.md` | Prose clarity, active voice, technical writing conventions |

---

## Reusable prompts

The `prompts/` directory contains task-specific prompts copied into your project by the installer. They're used internally by phase commands and can also be referenced directly.

| File | Used by |
|---|---|
| `rpi.md` | Core Research → Plan → Implement → Review loop template |
| `checkpoint.md` | User checkpoint format used between phases |
| `doc-ops.md` | Documentation QA workflow template |
| `pull-request.md` | PR review prompt template |
| `task-challenge.md` | Adversarial challenge workflow template |
| `prompt-build.md` | Prompt engineering sandbox workflow template |

---

## After an RPI loop: what to do with follow-on items

Every review surfaces a short list of follow-on items — adjacent work, technical debt, test gaps, documentation holes. Don't ignore them, but don't feel obligated to act on all of them immediately either.

**Your options:**

- **Act now** — if the item is small and clearly related to the task you just finished, run `/hve <follow-on task>` while the context is fresh.
- **Save for later** — run `/hve-memory` before ending the session. It writes a structured memory entry to `.claude-hve-tracking/memory/` that any future conversation can load. Use this for items you intend to do soon but not right now.
- **Open a GitHub issue** — for non-trivial items that need team visibility, backlog tracking, or a future milestone.

**Warning: don't leave follow-on items only in the chat transcript.** Chat sessions are ephemeral — transcripts are not searchable, not shared, and vanish when you close the window. An item that only exists in chat history is an item that will be forgotten. Write it down somewhere durable.

---

## FAQ

**`/hve` vs standalone phase commands — which should I use?**

`/hve` runs all four phases in one conversation, which is convenient for most tasks. The tradeoff is that context accumulates across phases — by the time you reach Review, the conversation window includes Research, Plan, and Implement output. For large or multi-day tasks, run each phase command in a fresh conversation instead:

```
# New conversation per phase keeps context lean
/hve-research add OAuth2 to the API
# [start new conversation]
/hve-plan
# [start new conversation]
/hve-implement
# [start new conversation]
/hve-review
```

Each command auto-discovers the previous phase's artifact from `.claude-hve-tracking/` — nothing is lost between sessions.

---

**How do I resume a task in a new conversation?**

Just run the next phase command. It finds the most recent artifact for its phase automatically — no file paths, no manual attachment. If you're between phases, the handoff block at the end of each phase command tells you exactly which command to run next.

---

**Can I use HVE for small tasks?**

Yes. HVE classifies difficulty before starting. Simple tasks (< 50 lines, single file, zero ambiguity) skip subagents entirely and implement directly — no overhead. You can also just ask: `/hve fix the typo in the error message` and it will handle it appropriately without spinning up a research team.

---

**Can I use HVE for non-code tasks?**

Yes — HVE is a research and structured output framework, not a coding tool. It works for any task where you want to investigate before acting, plan before writing, and validate the result. Examples:

- **Writing and research** — drafting guides, blog posts, reports, documentation
- **Architecture decisions** — researching trade-offs, drafting an ADR, reviewing it against requirements
- **Requirements analysis** — researching stakeholder needs, drafting a PRD or BRD, validating coverage
- **Configuration and audits** — researching current state, planning changes, reviewing for correctness
- **Content strategy** — researching a topic, outlining, drafting, reviewing for clarity

**Example 1 — writing a beginner's vegetable garden guide (non-technical):**

```
/hve Research and write a guide to starting a home vegetable garden — cover soil prep, what to plant by season, watering, and common beginner mistakes.
```

- **Research:** Two subagents run in parallel — one researches soil preparation and planting schedules by season, one surveys common beginner mistakes and watering best practices. Sources are drawn from the model's training knowledge; you can also specify URLs to fetch (e.g. `reference almanac.com for planting schedules`) and the researcher will pull from those directly.
- **Plan:** A structured outline is proposed — intro, soil prep, seasonal planting guide, watering, common mistakes, quick-start checklist. You review and approve: *"Does this plan look right? Proceed to writing?"*
- **Implement:** Each section is written against the outline, grounded in the research findings.
- **Review:** Checked for accuracy against the research, completeness against the outline, and clarity for a beginner audience.

**Example 2 — writing a technical blog post (tech-adjacent, no code):**

```
/hve Research and write a blog post explaining how React Server Components work and when to use them — aimed at developers who know React but haven't used RSCs yet.
```

This uses the same four phases, but research looks different: subagents fetch the official React docs, scan the codebase for any existing RSC usage to ground examples in reality, and survey common misconceptions. The plan produces a narrative outline rather than implementation phases. Review checks technical accuracy against the docs, not code correctness.

The difficulty classification still applies — a one-paragraph edit is Simple and skips subagents; a full multi-section guide warrants parallel researchers and a review pass.

---

**Does HVE only work with the languages listed in the instruction files?**

No — HVE works with any language or tech stack. The `instructions/` files are optional style guides that give the implementor subagent pre-loaded conventions (naming, formatting, test patterns) for specific languages. If your language isn't listed, HVE will still research, plan, implement, and review — it just won't have a dedicated convention file to reference. You can add your own by creating a file in `instructions/` and referencing it in `CLAUDE.md`.

---

**What if I want to skip a phase?**

Run the standalone phase commands directly. If you already know what needs to be done, skip research and go straight to `/hve-plan` with your own brief. If you've already written the plan, run `/hve-implement`. Each command reads from whatever artifact exists on disk.

---

**How do I update HVE in my project?**

Pull the latest from this repo and re-run `install.sh` — it's idempotent. It overwrites the command and agent files but preserves your `## Your Project` section in `CLAUDE.md`.

---

**How do I extend or customize HVE?**

Add your own language instruction files to `instructions/` and reference them in `CLAUDE.md`. Add prompts to `prompts/`. Modify agent definitions in `.claude/agents/` — or use `/hve-prompt-builder` to iteratively develop new ones with an automated test-evaluate-update loop.

---

## Internals

The following sections document how HVE works under the hood. You don't need to read this to use HVE — it's here for contributors, prompt engineers, and anyone who wants to understand the machinery.

---

### Subagents reference

Subagents are spawned by the phase commands — you never invoke them directly. They follow a strict response format and write durable artifacts to disk.

| Agent | Role | Tools | Model |
|---|---|---|---|
| `hve-researcher` | Targeted codebase + web investigation | Read, Write, Glob, Grep, WebFetch | Haiku |
| `hve-plan-validator` | Validates plan against research for completeness and coverage gaps | Read, Write, Edit, Glob, Grep | Haiku |
| `hve-phase-implementor` | Executes one plan phase: writes code, updates changes log | All tools | Inherit |
| `hve-rpi-validator` | Verifies a completed implementation phase matches what the plan required | Read, Write, Glob, Grep | Haiku |
| `hve-implementation-validator` | 10-dimension quality check including automated security hygiene | Read, Write, Glob, Grep, Bash | Haiku |
| `hve-prompt-evaluator` | Rates draft prompts against clarity / completeness / format / no-Copilot criteria | Read, Write, Glob, Grep | Haiku |
| `hve-prompt-tester` | Executes a draft prompt or agent definition literally against test scenarios | All tools | Inherit |
| `hve-prompt-updater` | Rewrites a draft prompt based on evaluator findings | All tools | Inherit |

**Orchestrator spawning tree:**

```
/hve
├── Phase 1: hve-researcher × N    (parallel, one per research question)
├── Phase 2: hve-plan-validator    (after plan is drafted)
├── Phase 3: hve-phase-implementor × N  (parallel where plan phases are independent)
└── Phase 4: hve-rpi-validator × N      (parallel, one per completed phase)
            hve-implementation-validator (parallel with rpi-validators)
```

**No agent has the Agent tool** — only orchestrator-level commands (`/hve`, `/hve-research`, etc.) can spawn subagents. This is intentional: it prevents unbounded spawning chains and keeps each subagent's scope fixed and auditable.

---

### `hve-implementation-validator` dimensions

The quality validator always runs these 10 checks:

1. **Architecture Conformance** — layering, module boundaries, directory placement
2. **Design Principles** — Single Responsibility, Open/Closed, interface segregation
3. **DRY Compliance** — duplicate logic detection via grep
4. **API Usage** — correct library usage, deprecated API avoidance
5. **Version Consistency** — dependency compatibility and version specifiers
6. **Refactoring Opportunities** — simplifications, patterns that replace verbose code
7. **Error Handling** — propagation, no silent swallowing, safe user-facing errors
8. **Test Coverage** — edge cases, new branches covered
9. **Security Posture** (always runs) — greps changed files for `PRIVATE KEY`, `api_key =`, `password =`, `Bearer `, `-----BEGIN`, AWS/GCP key prefixes; verifies `.env`/`.pem`/`.key` are in `.gitignore`; checks `git diff HEAD --name-only` for credential-like filenames; flags new unrecognized dependencies
10. **Overall Quality** — readability, naming clarity, appropriate complexity

---

### Subagent response protocol

All HVE subagents return in this exact format — no more, no less:

```
1. <artifact path written>
2. <status: Pass / Fail / Complete / Blocked>
3. Up to 7 bullet findings (≤ 240 chars each; Critical/Major first)
4. Checklist of up to 5 recommended follow-on items
5. Up to 3 clarifying questions — only if blocking
6. Full detail: re-read `<path>`
```

The parent agent reads the written artifact for full detail. Chat responses are executive summaries only. This is what keeps the main context window lean.

---

### Artifact conventions

**Confidence markers** — all key assumptions in handoff artifacts carry a marker:

| Marker | Meaning |
|---|---|
| `[HIGH]` | Verified directly from code, tests, or documentation |
| `[MEDIUM]` | Inferred from patterns or indirect evidence |
| `[LOW]` | Assumed; needs validation in the next phase |

Example: `Authentication uses JWT tokens [HIGH] with 24h expiry [MEDIUM]`

**Citation format** — all findings cite locations as `file:line`:

```
src/auth/middleware.ts:47          ✓ correct
./src/auth/middleware.ts           ✓ acceptable (no line number)
[middleware.ts](src/auth/...)      ✗ wrong — no markdown links
```

**Severity grading** — used in reviews, validations, and challenge outputs:

| Level | Definition |
|---|---|
| **Critical** | Missing or incorrect required functionality; blocks completion |
| **Major** | Specification deviation that degrades correctness, maintainability, or security |
| **Minor** | Style gap, documentation omission, or improvement opportunity |

Finding IDs are sequential: `IV-001`, `IV-002`, etc., reset per artifact.

---

### The five operating principles

1. **Context discipline** — After a subagent returns, the parent responds with a lean summary only. Full detail lives in the log file, not chat.
2. **Durable artifacts over chat** — All research, plans, and reviews live in `.claude-hve-tracking/`. Chat is ephemeral; disk is the source of truth. Phase commands are fully self-contained — they discover artifacts from disk, not from conversation history.
3. **Evidence-based responses** — Every finding cites `file:line`. No unsupported claims in any handoff artifact.
4. **Difficulty-adaptive workflow** — Classify tasks before acting. Simple tasks skip subagents. Challenging tasks use full parallel dispatch. Don't over-engineer the process for a one-liner change.
5. **Lean turns** — Parent agents return a one-line summary after subagent work. Three sentences is a paragraph; a paragraph is a context leak.

---

### Handoff block format

Every standalone phase command ends with this block so you know exactly where to pick up next — even in a brand new conversation:

```
╭─────────────────────────────────────────────────────╮
│  HANDOFF                                            │
│  Artifact : .claude-hve-tracking/[path/to/file.md] │
│  Next     : /hve-[next-phase]                       │
│  Tip      : Start a new conversation, then run the  │
│             next command — it finds this auto.      │
╰─────────────────────────────────────────────────────╯
```

---

## License

MIT — see [LICENSE](LICENSE)

Adapted from [microsoft/hve-core](https://github.com/microsoft/hve-core), also MIT.
