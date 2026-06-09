# Changes Log: Move `prompts/` → `.claude/prompts/`

Date: 2026-06-08
Plan: .claude-hve-tracking/plans/2026-06-08/move-prompts-into-claude-plan.md

## P1 — Source folder moved
- `git mv prompts .claude/prompts` — 6 files relocated with history (checkpoint, doc-ops,
  prompt-build, pull-request, rpi, task-challenge).

## P2 — install.sh
- `:14` header comment updated to `.claude/prompts/`.
- `:31-32` source-completeness guard now also requires `$SOURCE/.claude/prompts`.
- `:43` mkdir target → `$TARGET/.claude/prompts`.
- `:52` copy source → `$SOURCE/.claude/prompts/*.md` into `$TARGET/.claude/prompts/`.
- `:53` echo text updated.
- New migration block (`:93-130`): `HVE_PROMPT_FILES` list + byte-compare migration of old
  root `$TARGET/prompts/` → `.claude/prompts/`, mirroring the instructions migration. Keeps
  diverged files with a warning; rmdir old dir if empty. Runs after the copy, so identical
  old files are safely removed.

## P3 — Tests
- `tests/lib/prompt-files.sh` (new) — `HVE_PROMPT_FILES` shared list (6 files).
- `tests/run-install-tests.sh`: source new list; test1 asserts `.claude/prompts/` count + no
  root `prompts/`; added `seed_old_prompts()`; test3 seeds old prompts and asserts migration
  (6 files at new path, root removed).
- `tests/run-prompt-new-install.sh`: prompt text + assertion → `.claude/prompts/`.
- `tests/run-prompt-upgrade.sh`: source new list; seed old root `prompts/`; updated comments,
  seed paths, prompt text; added root-`prompts/`-removed assertion.

## P4 — Markdown references (11 files)
- CLAUDE.md, README.md, CONTRIBUTING.md, docs/installation.md (3 spots), docs/workflow.md,
  docs/reference.md, blog-porting-hve-to-claude-code.md (2 spots),
  .claude/commands/hve-prompt-builder.md (2 spots), .claude/commands/hve-prompt-analyze.md,
  .claude/prompts/prompt-build.md, .claude/prompts/doc-ops.md — all `prompts/` path tokens
  updated to `.claude/prompts/`.

## P5 — Verification
- `bash tests/run-install-tests.sh` → **31 passed, 0 failed** (includes new prompts assertions).
- `install.sh` passes `bash -n` syntax check.
- No root `prompts/` remains; `.claude/prompts/` has 6 files.
- Secret scan: only false positive (CLAUDE.md security-hygiene doc line). No real secrets.
- Remaining bare `prompts/` references are intentional: migration code + test assertions about
  the old root location.
