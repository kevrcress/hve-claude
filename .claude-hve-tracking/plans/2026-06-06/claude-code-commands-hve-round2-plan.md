# Implementation Plan: Claude Code Commands Integration with HVE (Round 2)
Date: 2026-06-06
Task slug: claude-code-commands-hve-round2
Research: .claude-hve-tracking/research/2026-06-06/claude-code-commands-hve-round2.md
Details: .claude-hve-tracking/details/2026-06-06/claude-code-commands-hve-round2-details.md
Status: Draft

## Overview

Document four newly-confirmed Claude Code commands in CLAUDE.md and integrate `/goal` directly into `hve-implement`. The CLAUDE.md changes cover `/goal` (with HVE example conditions), `/btw` (context discipline tip), `/simplify` (post-review cleanup), and `/rewind` (recovery note). The `hve-implement` change adds a `/goal` suggestion block so users can opt into unattended execution before starting an implement run. `/fork`, `/ultraplan`, and `/background` are explicitly out of scope.

## Phases

### Phase 1: CLAUDE.md Updates
Dependencies: none
Estimated scope: CLAUDE.md -- 4 additions across 2 sections (~30-40 lines total)
Success criteria: CLAUDE.md contains `/goal` and `/btw` entries in Context Management; Command Reference table contains `/simplify` and a `/rewind` note near `hve-implement`

Steps:
- [ ] Step 1.1: In CLAUDE.md, add a `/goal` subsection to "Context Management Between Phases" (or immediately after it) covering: what it does, the transcript-only evaluator caveat, the "or stop after N turns" requirement, and 2 HVE example conditions
- [ ] Step 1.2: In CLAUDE.md, add a `/btw` tip sentence to "Context Management Between Phases" -- "Use `/btw` for quick clarifying questions during a session; they are not added to conversation history and do not affect subagent context"
- [ ] Step 1.3: In CLAUDE.md Command Reference table, add a `/simplify` row with purpose "Automated cleanup pass: 4 parallel agents cover reuse, simplification, efficiency, and abstraction level -- no bug hunting" and when-to-use "After `hve-review` passes, before committing"
- [ ] Step 1.4: In CLAUDE.md Command Reference table, add a `/rewind` row with purpose "Roll back code on disk and conversation to a prior checkpoint" and when-to-use "Recovery if an `hve-implement` phase corrupts files"

### Phase 2: hve-implement.md -- /goal Integration
Dependencies: none
Estimated scope: `.claude/commands/hve-implement.md` -- ~15 lines added
Success criteria: `hve-implement` Phase 1 includes a `/goal` suggestion block with a ready-to-use example condition; phase completion announcements in the command body are clearly stated for transcript legibility

Steps:
- [ ] Step 2.1: In `.claude/commands/hve-implement.md`, add a "Unattended Execution (optional)" note early in the command -- after reading the plan but before spawning subagents -- that suggests the user set `/goal` with a ready-to-copy condition: "all implementation phases complete and [test command] exits 0 and security check passes or stop after 20 turns"
- [ ] Step 2.2: Verify the Phase 3 consolidation summary in `hve-implement.md` emits "Phases completed: N/N" clearly in chat (not just in the changes log file) so the Haiku evaluator can read it from the transcript. If not already present, add an explicit "Report to the user: 'Phases completed: N/N, Tests: [result], Security: [result]'" instruction.

## Deferred Work

- `/fork`, `/ultraplan`, `/background` -- explicitly out of scope per user decision
- `/context`, `/diff` -- low HVE value; no action

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| `/goal` evaluator misreads transcript if phase summary is buried in file output | Medium | Step 2.2 explicitly ensures the summary is echoed in chat |
| CLAUDE.md Context Management section becomes too long with two new entries | Low | Keep entries concise: 2-3 sentences each; no full subsections |
| `/rewind` note near `hve-implement` in Command Reference causes visual clutter | Low | Add as a separate table row, not an inline annotation |

## Testing Approach

- Phase 1: Read CLAUDE.md and confirm all four new entries are present, accurate, and follow markdown conventions (no em-dashes, `*` lists, blank lines around blocks)
- Phase 2: Read `hve-implement.md` and confirm the `/goal` suggestion block is present with a ready-to-copy condition; confirm Phase 3 summary is explicitly instructed to appear in chat
