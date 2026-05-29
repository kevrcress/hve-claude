# Changes Log: update-readme
Date: 2026-05-29
Plan Phase: 1 (single phase — documentation only)

## Files Modified

| File | Change Type | Summary |
|---|---|---|
| `README.md` | Modified | Full rewrite from 84-line stub to comprehensive documentation |

## Phase 1 Changes

### README.md

**Before**: 84-line minimal overview. Described the project in 2 sentences, listed commands without descriptions, had a 4-line install section, and a 10-line usage snippet.

**After**: Comprehensive documentation covering:

1. **Problem statement** — why phase separation produces verified truth over plausible code
2. **Quick start** — install + first command in under 10 lines
3. **Requirements** — Claude Code, model recommendations
4. **How it works** — 4-phase loop with ASCII diagram, difficulty classification table, checkpoint explanation, phase auto-discovery
5. **Command reference** — all 15 commands in 4 grouped tables with descriptions
6. **Installation** — step-by-step: installer behavior, CLAUDE.md Your Project section, tracking folder gitignore options
7. **Workflow walkthrough** — concrete `/hve add OAuth2` example through all 4 phases
8. **Benefits table** — 9-row comparison: single-agent chat vs. HVE RPI
9. **Tracking folder structure** — full directory tree with annotations, artifact naming
10. **Language instruction files** — table of all 12 files with coverage descriptions
11. **Internals section** (clearly separated):
    - Subagents reference table (8 agents: role, tools, model)
    - Orchestrator spawning tree diagram
    - `hve-implementation-validator` 10 dimensions
    - Subagent response protocol format
    - Artifact conventions (confidence markers, citation format, severity grading)
    - Five operating principles
    - Handoff block format

**Corrections from research**: README previously listed 10 commands; corrected to 15 (added hve-prompt-analyze, hve-prompt-refactor, hve-git-commit, hve-git-merge, hve-git-setup).
