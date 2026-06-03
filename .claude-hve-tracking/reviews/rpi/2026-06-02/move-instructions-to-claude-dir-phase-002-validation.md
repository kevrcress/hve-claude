# RPI Validation: Move instructions/ to .claude/instructions/ — Phase 2
Date: 2026-06-02
Plan phase: Phase 2 — Update internal references in agents and commands
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 2.1: `.claude/agents/hve-phase-implementor.md` — 4 occurrences | Found | `.claude/agents/hve-phase-implementor.md:19,31,42,103` | ✅ Implemented |
| Step 2.1: `.claude/agents/hve-prompt-updater.md` — 1 occurrence | Found | `.claude/agents/hve-prompt-updater.md:62` | ✅ Implemented |
| Step 2.1: `.claude/commands/hve-implement.md` — 2 occurrences | Found | `.claude/commands/hve-implement.md:30,71` | ✅ Implemented |
| Step 2.1: `.claude/commands/hve-git-commit.md` — 2 occurrences | Found | `.claude/commands/hve-git-commit.md:9,36` | ✅ Implemented |
| Step 2.1: `.claude/commands/hve-git-merge.md` — 1 occurrence | Found | `.claude/commands/hve-git-merge.md:9` | ✅ Implemented |
| Step 2.1: `.claude/commands/hve-prompt-analyze.md` — 1 occurrence | Found | `.claude/commands/hve-prompt-analyze.md:27` | ✅ Implemented |
| Step 2.1: `.claude/commands/hve-prompt-builder.md` — 2 occurrences | Found | `.claude/commands/hve-prompt-builder.md:26,87` | ✅ Implemented |

## Verification Results

### File-by-File Analysis

**hve-phase-implementor.md (4 occurrences)**
- Line 19: `.claude/instructions/` path in assignment docs ✓
- Line 31: `.claude/instructions/` in step 1 context loading ✓
- Line 42: `.claude/instructions/` in step 2 execution protocol ✓
- Line 103: `.claude/instructions/` in constraints section ✓
- Bare `instructions/` check: 0 matches ✓

**hve-prompt-updater.md (1 occurrence)**
- Line 62: `.claude/instructions/` in convention verification for instruction files ✓
- Bare `instructions/` check: 0 matches ✓

**hve-implement.md (2 occurrences)**
- Line 30: `.claude/instructions/` in phase 1 plan analysis ✓
- Line 71: `.claude/instructions/` in phase 2 iterative execution ✓
- Bare `instructions/` check: 0 matches ✓

**hve-git-commit.md (2 occurrences)**
- Line 9: `.claude/instructions/git-commit-messages.md` in preamble ✓
- Line 36: `.claude/instructions/git-commit-messages.md` in step 3 ✓
- Bare `instructions/` check: 0 matches ✓

**hve-git-merge.md (1 occurrence)**
- Line 9: `.claude/instructions/git-commit-messages.md` in preamble ✓
- Bare `instructions/` check: 0 matches ✓

**hve-prompt-analyze.md (1 occurrence)**
- Line 27: `.claude/instructions/` in phase 1 read and understand ✓
- Bare `instructions/` check: 0 matches ✓

**hve-prompt-builder.md (2 occurrences)**
- Line 26: `.claude/instructions/` in phase 1 initialize ✓
- Line 87: `.claude/instructions/` in phase 3 finalize ✓
- Bare `instructions/` check: 0 matches ✓

### Coverage Assessment

- Total plan steps: 7 files × 1 replacement step = 7
- Completed steps: 7
- Coverage: 100%

All claimed path replacements in the changes log match exactly with the code:
- 4 occurrences in hve-phase-implementor.md [HIGH]
- 1 occurrence in hve-prompt-updater.md [HIGH]
- 2 occurrences in hve-implement.md [HIGH]
- 2 occurrences in hve-git-commit.md [HIGH]
- 1 occurrence in hve-git-merge.md [HIGH]
- 1 occurrence in hve-prompt-analyze.md [HIGH]
- 2 occurrences in hve-prompt-builder.md [HIGH]

**Total occurrences updated: 13** (plan claimed 13: 4+1+2+2+1+1+2)

### Bare Reference Check

Negative grep for bare `instructions/` patterns (not preceded by `.claude/`) in all 7 files returned zero matches, confirming the success criterion: **No file in `.claude/agents/` or `.claude/commands/` contains a bare `instructions/` path reference.**

## Findings

None. Phase 2 is complete and correct.

## Unlisted Changes

None detected. All modified files are accounted for in the changes log.

## Research Coverage

No research document was provided for this task. Phase 2 requirements are derived directly from the implementation plan and are satisfied:
- [HIGH] All `instructions/` → `.claude/instructions/` replacements completed in specified files
- [HIGH] No bare `instructions/` references remain in agent or command files
- [HIGH] File integrity maintained (no unrelated edits detected)

