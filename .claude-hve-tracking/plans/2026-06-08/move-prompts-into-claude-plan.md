# Plan: Move `prompts/` → `.claude/prompts/`

Date: 2026-06-08
Research: .claude-hve-tracking/research/2026-06-08/move-prompts-into-claude.md
Decisions: (1) move source repo folder via git mv; (2) add upgrade migration mirroring instructions/.

## Phase 1 — Move source folder
- `git mv prompts .claude/prompts` (moves all 6 tracked files with history).
- Verify `.claude/prompts/` has the 6 files and root `prompts/` is gone.

## Phase 2 — Installer (install.sh)
- `:14` header comment: ".claude/instructions/ and prompts/" → ".claude/instructions/ and .claude/prompts/".
- `:43` mkdir target: `"$TARGET/prompts"` → `"$TARGET/.claude/prompts"`.
- `:52` copy: `cp "$SOURCE"/.claude/prompts/*.md "$TARGET/.claude/prompts/"`.
- `:53` echo text → ".claude/instructions/ and .claude/prompts/".
- Source-completeness guard `:31` — optionally also check `.claude/prompts` exists (low risk; add for parity).
- **New migration block** (after the instructions migration, ~`:91`): migrate old root
  `$TARGET/prompts/` → `.claude/prompts/`, mirroring the instructions logic:
  - Add `HVE_PROMPT_FILES=(checkpoint.md doc-ops.md prompt-build.md pull-request.md rpi.md task-challenge.md)`.
  - For each known file in old `$TARGET/prompts/`: if byte-identical to shipped version, `rm`
    (it's now in `.claude/prompts/`); else warn "kept prompts/<f>: differs" and keep.
  - rmdir old `prompts/` only if empty; echo migrated message.
  - Keep comment noting the list must stay in sync with the test list.

## Phase 3 — Tests
- `tests/lib/prompt-files.sh` (new) — define `HVE_PROMPT_FILES` (6 files), mirroring
  `tests/lib/instruction-files.sh`. Source it where needed.
- `tests/run-install-tests.sh`:
  - Source the new list file alongside instruction-files.sh.
  - test1 assertions `:144-152`: count `.md` in `${test_dir}/.claude/prompts` (expect 6),
    label "test1: .claude/prompts/ .md count". Add `assert_not_exists "${test_dir}/prompts"`.
  - Add `seed_old_prompts()` helper mirroring `seed_old_instructions()` (copy 6 files to
    `${target}/prompts/`).
  - Extend the clean-upgrade test (test3) — seed old prompts too, assert root `prompts/`
    removed and `.claude/prompts/` has 6 after install. (Or add test3c specifically for prompts.)
- `tests/run-prompt-new-install.sh`:
  - `:83` prompt text and `:128-129` assertion → `.claude/prompts`.
- `tests/run-prompt-upgrade.sh`:
  - `:11, 66` comments; `:57-58` seed copy → `${WORK_DIR}/.claude/prompts`;
    `:95` prompt text; `:140-142` assertion → `.claude/prompts`.

## Phase 4 — Markdown / docs
Update path text `prompts/` → `.claude/prompts/` in:
- `CLAUDE.md:251`
- `README.md:35`
- `CONTRIBUTING.md:100`
- `docs/installation.md:17, 61-62, 131`
- `docs/workflow.md:221`
- `docs/reference.md:69`
- `blog-porting-hve-to-claude-code.md:131`
- `.claude/commands/hve-prompt-builder.md:27, 81`
- `.claude/commands/hve-prompt-analyze.md:28`
- `.claude/prompts/prompt-build.md:10` (self-ref, post-move path)
- `.claude/prompts/doc-ops.md:20` (self-ref in exclude list, post-move path)

## Phase 5 — Verify
- Run `bash tests/run-install-tests.sh` (automated) — expect all green.
- Grep repo for residual ` prompts/` path references that should be `.claude/prompts/`.
- Confirm no stray root `prompts/` in source tree.

## Dependencies
P1 → P2 (cp source path depends on move). P2 → P3 (tests assert installer behavior).
P4 independent of P1-3 (docs). P5 last.
