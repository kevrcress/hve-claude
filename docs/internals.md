# Internals

How HVE works under the hood. You don't need to read this to use HVE, it's here
for contributors, prompt engineers, and anyone who wants to understand the
machinery.

The conventions that govern every subagent (the response protocol, confidence
markers, citation format, severity grading, the five operating principles, and the
handoff block format) live in [CLAUDE.md](../CLAUDE.md), which is the single
source of truth installed into every project. This document covers the pieces that
aren't in CLAUDE.md: the subagent roster and the quality-validator dimensions.

## Subagents reference

Subagents are spawned by the phase commands; you never invoke them directly. They
follow a strict response format and write durable artifacts to disk.

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

**No agent has the Agent tool**: only orchestrator-level commands (`/hve`,
`/hve-research`, etc.) can spawn subagents. This is intentional: it prevents
unbounded spawning chains and keeps each subagent's scope fixed and auditable.

## `hve-implementation-validator` dimensions

The quality validator always runs these 10 checks:

1. **Architecture Conformance**: layering, module boundaries, directory placement
2. **Design Principles**: Single Responsibility, Open/Closed, interface segregation
3. **DRY Compliance**: duplicate logic detection via grep
4. **API Usage**: correct library usage, deprecated API avoidance
5. **Version Consistency**: dependency compatibility and version specifiers
6. **Refactoring Opportunities**: simplifications, patterns that replace verbose code
7. **Error Handling**: propagation, no silent swallowing, safe user-facing errors
8. **Test Coverage**: edge cases, new branches covered
9. **Security Posture** (always runs): greps changed files for `PRIVATE KEY`,
   `api_key =`, `password =`, `Bearer `, `-----BEGIN`, AWS/GCP key prefixes;
   verifies `.env`/`.pem`/`.key` are in `.gitignore`; checks
   `git diff HEAD --name-only` for credential-like filenames; flags new
   unrecognized dependencies
10. **Overall Quality**: readability, naming clarity, appropriate complexity
