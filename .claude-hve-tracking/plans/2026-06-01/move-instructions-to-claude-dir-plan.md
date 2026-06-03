# Implementation Plan: Move instruction files from instructions/ to .claude/instructions/
Date: 2026-06-01
Task slug: move-instructions-to-claude-dir
Research: (no prior research document — plan derived directly from source audit)
Status: Complete (retroactive)

## Overview

HVE instruction files lived at `instructions/` at the project root. This is non-standard — Claude Code's native conventions keep all Claude-specific assets under `.claude/`. Moving them into `.claude/instructions/` aligns with the platform layout, reduces top-level directory clutter, and mirrors where commands and agents already live. All internal references must be updated; `install.sh` must also handle migration for existing projects that have the old location.

## Source boundary verification

All files modified are within this repository. No user projects are touched by this plan — only the source repo that gets cloned during install.

## Phases

### Phase 1: Move instruction files

Dependencies: none
Estimated scope: 11 file renames under `.claude/instructions/`
Success criteria: All `instructions/*.md` files exist at `.claude/instructions/`; `instructions/` directory is removed from repo

Steps:
- [ ] 1.1: `git mv instructions/*.md .claude/instructions/` (all 11 files)
- [ ] 1.2: Confirm `instructions/` directory is empty and removed from index

### Phase 2: Update internal references in agents and commands

Dependencies: Phase 1
Estimated scope: 7 files with `instructions/` → `.claude/instructions/` string replacements
Success criteria: No file in `.claude/agents/` or `.claude/commands/` contains a bare `instructions/` path reference

Files:
- `.claude/agents/hve-phase-implementor.md` — 4 occurrences
- `.claude/agents/hve-prompt-updater.md` — 1 occurrence
- `.claude/commands/hve-implement.md` — 2 occurrences
- `.claude/commands/hve-git-commit.md` — 2 occurrences
- `.claude/commands/hve-git-merge.md` — 1 occurrence
- `.claude/commands/hve-prompt-analyze.md` — 1 occurrence
- `.claude/commands/hve-prompt-builder.md` — 2 occurrences

### Phase 3: Update references in CLAUDE.md and prompts

Dependencies: Phase 1
Estimated scope: CLAUDE.md (12 table rows), prompts/doc-ops.md (1 line), prompts/prompt-build.md (1 line)
Success criteria: Instructions Reference table in CLAUDE.md uses `.claude/instructions/` paths; `prompts/` files reference new path

Steps:
- [ ] 3.1: Update all 12 rows of the Instructions Reference table in `CLAUDE.md`
- [ ] 3.2: Update the installer description paragraph in `CLAUDE.md`
- [ ] 3.3: Update `prompts/doc-ops.md` excludes list
- [ ] 3.4: Update `prompts/prompt-build.md` artifact type list

### Phase 4: Update README.md

Dependencies: Phase 1
Estimated scope: README.md — Option B step 4, upgrade callout, Terminal section, FAQ update answer
Success criteria: All README path references use `.claude/instructions/`; upgrade callout accurately describes the migration

Steps:
- [ ] 4.1: Update Option B step 4 source/target paths
- [ ] 4.2: Rewrite the "Upgrading from an older install?" callout with accurate migration instructions
- [ ] 4.3: Update Terminal/bash description to mention auto-migration
- [ ] 4.4: Add "Updating an existing install" subsection with a natural language update prompt [HIGH PRIORITY]
- [ ] 4.5: Update FAQ "How do I update HVE?" to reference the new update prompt

### Phase 5: Update install.sh

Dependencies: Phase 1
Estimated scope: install.sh — source path, mkdir, migration block
Success criteria: `install.sh` copies from `.claude/instructions/`; creates `.claude/instructions/` at target; migrates old `instructions/` files for existing installs

Steps:
- [ ] 5.1: Update `mkdir -p` to include `$TARGET/.claude/instructions/`; remove `$TARGET/instructions`
- [ ] 5.2: Update `cp` source path to `$SOURCE/.claude/instructions/*.md`
- [ ] 5.3: Add migration block: for each known HVE instruction filename, if old `$TARGET/instructions/$fname` exists and matches the new source byte-for-byte, delete it; if it differs, warn and leave it; `rmdir` the old directory if empty

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| Existing projects have `instructions/` hardcoded in their CLAUDE.md | High | Migration handled in install.sh; README callout explains manual migration path |
| Agent prompts reference `instructions/` at runtime | Medium | Systematic grep across all agents and commands before completing |
| install.sh migration deletes customized files | Low | `cmp -s` check — only remove byte-for-byte identical files; warn and keep diverged files |

## Testing Approach

1. Grep the repo for bare `instructions/` (not `.claude/instructions/`) — should return zero hits after completion
2. Confirm `install.sh` creates `.claude/instructions/` at target, not `instructions/`
3. Confirm `install.sh` migration block handles the three cases: identical (remove), different (warn+keep), absent (no-op)
