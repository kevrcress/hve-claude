# Implementation Plan: Make HVE installation cross-platform and script-free in the README
Date: 2026-06-01
Task slug: cross-platform-install-readme
Research: (no prior research document — plan derived directly from task description and source audit)
Status: Draft

## Overview

The README currently directs users to run `install.sh`, which is bash-only and asks strangers to execute arbitrary shell code. This plan rewrites the README to lead with two script-free, cross-platform install paths — an Option A paste-to-install prompt (Claude does the work) and an Option B numbered manual steps — then demotes `install.sh` to an optional sidebar for terminal users. No files other than `README.md` are modified.

## Source boundary verification

Confirmed: `CLAUDE.md:273` has `## Your Project` — the merge boundary for the paste-to-install prompt is valid.

## Phases

### Phase 1: Rewrite the Quick Start section

Dependencies: none
Estimated scope: README.md lines 30–45 (~15 lines replaced)
Success criteria: Step 1 of Quick Start uses the exact Option A prompt verbatim; the "Prefer the terminal?" callout mentions install.sh as bash-only (Mac/Linux/WSL)

Steps:
- [ ] 1.1: Replace the Step 1 paste prompt (README.md:32–33) with the exact Option A prompt from requirements
- [ ] 1.2: Update the "Prefer the terminal?" callout (README.md:45) to say bash-only (Mac/Linux, or WSL/Git Bash on Windows) and link to the Installation section for full options

### Phase 2: Rewrite the Installation section

Dependencies: none (independent of Phase 1)
Estimated scope: README.md lines 204–258 — full section replacement (~55 lines → ~90 lines)
Success criteria: Section leads with Option A, then Option B (7 numbered steps), then a brief install.sh callout as bash-only optional. install.sh is NOT deleted.

Steps:
- [ ] 2.1: Replace `### Step 1: Run the installer` with `### Option A — Paste to install (recommended)` containing the exact Option A prompt in a code block, plus a one-sentence explanation
- [ ] 2.2: Add `### Option B — Manual steps` with 7 numbered steps derived from install.sh steps 1–6:
    1. Clone or download `https://github.com/kevrcress/hve-claude` to a temp directory
    2. Copy `.claude/commands/hve*.md` → `<your-project>/.claude/commands/`
    3. Copy `.claude/agents/hve*.md` → `<your-project>/.claude/agents/`
    4. Copy `instructions/*.md` → `<your-project>/instructions/`
    5. Copy `prompts/*.md` → `<your-project>/prompts/`
    6. Merge HVE block into `<your-project>/CLAUDE.md` using the HVE markers (three sub-cases from install.sh)
    7. Add two `.gitignore` lines under the HVE comment header
- [ ] 2.3: Add `### Terminal / bash users (optional)` brief callout noting install.sh is available, bash-only (Mac/Linux, or WSL/Git Bash on Windows), with the existing usage lines
- [ ] 2.4: Keep `### Step 2: Add your project context` and `### Tracking folder and version control` subsections intact (no changes needed)

### Phase 3: Update FAQ "How do I update HVE"

Dependencies: Phase 2 (for consistent terminology)
Estimated scope: README.md lines 510–511 (~2 lines)
Success criteria: Update FAQ answer to mention Option A paste prompt or re-cloning, note install.sh still works for bash users

Steps:
- [ ] 3.1: Update the FAQ answer (README.md:510–511) to say users can re-run Option A, use install.sh for bash, or manually re-copy the files to get updates

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| Option A prompt text must be verbatim — any deviation breaks blog post consistency | High | Copy exact prompt from requirements; do not paraphrase |
| CLAUDE.md merge case descriptions in Option B must be accurate | Medium | Derive directly from install.sh:60–84 logic, which was read directly |
| Removing install.sh from primary flow could confuse users who already followed it | Low | Keep install.sh present; FAQ update addresses "how do I update" path |

## Testing Approach

After edit:
1. Read the modified Quick Start — confirm Step 1 paste prompt matches requirements verbatim
2. Read the modified Installation section — confirm three subsections (Option A, Option B, bash optional) are present and correct
3. Grep README.md for "run install.sh" as primary instruction — should return zero hits (only demoted references remain)
4. Confirm `install.sh` file still exists in repo root
