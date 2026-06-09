# Research: Move `prompts/` into `.claude/prompts/`

Date: 2026-06-08
Task: Move the prompts folder so no HVE artifacts land at the user's project root;
ensure new installs + upgrades work; update tests and all markdown references.

## Goal

Installer currently drops `prompts/` at the **project root** of the target. The user wants
all HVE artifacts under `.claude/` so a consuming project's root stays clean. Target
location: `.claude/prompts/`.

## Current State [HIGH]

### Source repo layout
- `prompts/` at repo root, 6 git-tracked files: `checkpoint.md`, `doc-ops.md`,
  `prompt-build.md`, `pull-request.md`, `rpi.md`, `task-challenge.md` (`git ls-files prompts/`)
- No `.claude/prompts/` exists yet.
- No `.gitignore` entry references `prompts`.

### install.sh behavior
- `install.sh:43` — `mkdir -p ... "$TARGET/prompts"`
- `install.sh:52` — `cp "$SOURCE"/prompts/*.md "$TARGET/prompts/"`
- `install.sh:53` — echo "✓ .claude/instructions/ and prompts/"
- `install.sh:14` — header comment mentions `prompts/`
- No upgrade/migration logic exists for `prompts/` (unlike `instructions/`).

### Existing migration precedent [HIGH]
The installer already migrates an old top-level `instructions/` → `.claude/instructions/`:
- `install.sh:55-91` — migration block (byte-compare, move-or-keep, rmdir-if-empty)
- `tests/lib/instruction-files.sh` — `HVE_INSTRUCTION_FILES` shared list
- `tests/run-install-tests.sh` — `seed_old_instructions()` helper (`:91-101`),
  test1 asserts no root `instructions/` (`:169-171`), test3 clean-upgrade (`:224-263`)
This is the exact pattern to mirror for `prompts/`.

## All `prompts/` references to update [HIGH]

### Code / installer
- `install.sh:14, 43, 52, 53`

### Test scripts
- `tests/run-install-tests.sh:144-152` (prompts/ .md count assertion)
- `tests/run-prompt-upgrade.sh:11, 58, 66, 95, 142`
- `tests/run-prompt-new-install.sh:83, 129`

### Markdown / docs
- `CLAUDE.md:251`
- `README.md:35`
- `CONTRIBUTING.md:100`
- `docs/installation.md:17, 61-62, 131`
- `docs/workflow.md:221`
- `docs/reference.md:69`
- `blog-porting-hve-to-claude-code.md:131` (untracked draft — update for accuracy)
- `.claude/commands/hve-prompt-builder.md:27, 81`
- `.claude/commands/hve-prompt-analyze.md:28`
- `prompts/prompt-build.md:10` (self-reference)
- `prompts/doc-ops.md:20` (self-reference in exclude list)

## Open Decisions (for user checkpoint)

1. **Move source repo's `prompts/` too?** [recommend YES]
   For consistency, relocate this repo's own `prompts/` → `.claude/prompts/` via `git mv`,
   so the installer copies from `$SOURCE/.claude/prompts/`. Keeps source + installed layout
   identical and the repo root clean. The 6 files move with history preserved.

2. **Add upgrade migration?** [recommend YES]
   Existing installs have `prompts/` at the target root. Mirror the `instructions/` migration:
   byte-compare each known prompt file, move identical ones to `.claude/prompts/`, keep
   diverged ones with a warning, rmdir the old folder if empty. Needs a known-filename list
   (like `HVE_INSTRUCTION_FILES`) — add `HVE_PROMPT_FILES`.

## Risks [MEDIUM]
- Migration must only move files it owns (byte-identical to shipped), never clobber user edits.
- Tests run interactively (new-install / upgrade scripts prompt a human); `run-install-tests.sh`
  is the automated one — that's where the migration assertions belong.
- `blog-*.md` is an untracked personal draft; update for correctness but low priority.
