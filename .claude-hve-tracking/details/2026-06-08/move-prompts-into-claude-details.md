# Implementation Details: Move `prompts/` → `.claude/prompts/`

Date: 2026-06-08

## P1 — git mv
```
git mv prompts .claude/prompts
```
6 files: checkpoint.md, doc-ops.md, prompt-build.md, pull-request.md, rpi.md, task-challenge.md.

## P2 — install.sh edits

`:14` comment → `#   - copies .claude/instructions/ and .claude/prompts/ reference docs`

`:31` guard — extend to also require `.claude/prompts` (optional parity; the dir always ships).

`:43` mkdir → replace `"$TARGET/prompts"` with `"$TARGET/.claude/prompts"`.

`:52` → `cp "$SOURCE"/.claude/prompts/*.md "$TARGET/.claude/prompts/"`

`:53` echo → `echo "  ✓ .claude/instructions/ and .claude/prompts/"`

**New migration block** — insert after the instructions migration (after line ~91), before the
CLAUDE.md merge. Mirror the instructions pattern exactly:
```bash
# --- migrate old top-level prompts/ from prior installs ------------------------
# Keep in sync with HVE_PROMPT_FILES in tests/lib/prompt-files.sh.
HVE_PROMPT_FILES=(
  checkpoint.md doc-ops.md prompt-build.md pull-request.md rpi.md task-challenge.md
)
OLD_PROMPTS_DIR="$TARGET/prompts"
if [ -d "$OLD_PROMPTS_DIR" ]; then
  _p_migrated=0
  _p_kept=0
  for fname in "${HVE_PROMPT_FILES[@]}"; do
    old_file="$OLD_PROMPTS_DIR/$fname"
    new_source="$SOURCE/.claude/prompts/$fname"
    if [ -f "$old_file" ]; then
      if cmp -s "$new_source" "$old_file"; then
        rm "$old_file"
        _p_migrated=$((_p_migrated + 1))
      else
        echo "  ! kept prompts/$fname: it differs from the installed version (possible local customization); review and remove manually if unneeded."
        _p_kept=$((_p_kept + 1))
      fi
    fi
  done
  if [ -d "$OLD_PROMPTS_DIR" ] && [ -z "$(ls -A "$OLD_PROMPTS_DIR")" ]; then
    rmdir "$OLD_PROMPTS_DIR"
    if [ "$_p_migrated" -gt 0 ]; then
      echo "  ✓ migrated prompts/ to .claude/prompts/ (removed old top-level copy)"
    fi
  fi
fi
```
Note: the `.claude/prompts/` copy at P2 runs BEFORE this migration (copy is at :52, migration
inserted after instructions block ~:91), so files already exist at the new location when we
delete the old identical ones. Confirm ordering holds after edit.

## P3 — Tests

`tests/lib/prompt-files.sh` (new):
```bash
#!/usr/bin/env bash
# Shared list of HVE prompt filenames.
# Keep in sync with HVE_PROMPT_FILES in install.sh.
declare -a HVE_PROMPT_FILES=(
  checkpoint.md doc-ops.md prompt-build.md pull-request.md rpi.md task-challenge.md
)
```

`tests/run-install-tests.sh`:
- After `:22` source line, add `source "${REPO_ROOT}/tests/lib/prompt-files.sh"`.
- `:144-153` change `${test_dir}/prompts` → `${test_dir}/.claude/prompts`, expect count 6,
  relabel "test1: .claude/prompts/ .md count".
- In test1, add `assert_not_exists "${test_dir}/prompts"  "test1: no prompts/ at root"`.
- Add `seed_old_prompts()` helper after `seed_old_instructions()` — copy 6 files from
  `${REPO_ROOT}/.claude/prompts` into `${target}/prompts/`.
- In `test3_clean_upgrade`: call `seed_old_prompts "${test_dir}"`; add
  `assert_file_count "${test_dir}/.claude/prompts" "*.md" 6 ...` and
  `assert_not_exists "${test_dir}/prompts" "test3: prompts/ at root removed after clean migration"`.

`tests/run-prompt-new-install.sh`:
- `:83` prompt text "copy its .claude/instructions/ and .claude/prompts/ files in".
- `:127-129` assertion target → `${WORK_DIR}/.claude/prompts`, message ".claude/prompts/ contains at least one .md".

`tests/run-prompt-upgrade.sh`:
- `:11` comment list and `:66` echo → `.claude/prompts/`.
- `:57-58` seed: `mkdir -p "${WORK_DIR}/.claude/prompts"` and
  `cp "${REPO_ROOT}/.claude/prompts/"*.md "${WORK_DIR}/.claude/prompts/"`.
- `:95` prompt text → ".claude/instructions/ and .claude/prompts/".
- `:140-142` assertion → `${WORK_DIR}/.claude/prompts`, message ".claude/prompts/ contains at least one .md".

## P4 — Markdown
Replace the `prompts/` path token with `.claude/prompts/` in each listed location. Keep prose
natural (e.g. "Add prompts to `.claude/prompts/`"). For the two moved self-ref files, the path
references update to `.claude/prompts/`.

Files: CLAUDE.md:251, README.md:35, CONTRIBUTING.md:100, docs/installation.md:17/61-62/131,
docs/workflow.md:221, docs/reference.md:69, blog-porting-hve-to-claude-code.md:131,
.claude/commands/hve-prompt-builder.md:27/81, .claude/commands/hve-prompt-analyze.md:28,
.claude/prompts/prompt-build.md:10, .claude/prompts/doc-ops.md:20.

## P5 — Verify
- `bash tests/run-install-tests.sh` → all OK.
- `grep -rn "[^.]prompts/" --include=*.md --include=*.sh` for stragglers (allow `.claude/prompts/`).
- `ls prompts 2>/dev/null` → should not exist at root.

## No-em-dash reminder
Per user preference, no em-dashes in any prose/comments written.
