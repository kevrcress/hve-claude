#!/usr/bin/env bash
#
# install.sh: install the HVE Claude Code workflow into a project.
#
# Usage:
#   ./install.sh [target-dir]
#   ./install.sh --global
#
#   target-dir   Project to install into. Defaults to the current directory.
#                Pass a path to install elsewhere, e.g. ./install.sh ~/code/my-app
#   --global     Install for all projects: files go to ~/.claude/ and the HVE
#                block merges into ~/.claude/CLAUDE.md. Takes no target-dir.
#                Skips .gitignore rules (those are per-project; see the note the
#                script prints).
#
# What it does (idempotent; safe to re-run for updates):
#   - copies hve-* slash commands     -> <target>/.claude/commands/
#   - copies hve-* agents             -> <target>/.claude/agents/
#   - copies .claude/instructions/ and .claude/prompts/ reference docs
#   - merges the HVE block into       <target>/CLAUDE.md (between HVE markers)
#   - adds tracking rules to          <target>/.gitignore
#   - migrates any old top-level      <target>/instructions/ from prior installs
#   In --global mode the last three steps target ~/.claude/CLAUDE.md, skip
#   .gitignore, and skip migrations (those only ever existed per-project).
#
set -euo pipefail

# --- resolve source (this repo) and target -------------------------------------
SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GLOBAL=0
if [ "${1:-}" = "--global" ]; then
  GLOBAL=1
  shift
  if [ -n "${1:-}" ]; then
    echo "error: --global takes no target directory (it always installs to ~/.claude)." >&2
    exit 1
  fi
fi

if [ "$GLOBAL" -eq 1 ]; then
  if [ -z "${HOME:-}" ]; then
    echo "error: --global needs \$HOME to be set (it installs to \$HOME/.claude)." >&2
    exit 1
  fi
  TARGET="$HOME"
  CLAUDE_DIR="$HOME/.claude"
  CLAUDE_DIR_LABEL="~/.claude"
else
  TARGET="$(cd "${1:-$PWD}" && pwd)"
  CLAUDE_DIR="$TARGET/.claude"
  CLAUDE_DIR_LABEL=".claude"
fi

if [ "$SOURCE" = "$TARGET" ]; then
  echo "error: target is the HVE source repo itself." >&2
  echo "       cd into your project first, or pass a target: ./install.sh /path/to/project" >&2
  exit 1
fi

if [ ! -d "$SOURCE/.claude/commands" ] || [ ! -d "$SOURCE/.claude/instructions" ] || [ ! -d "$SOURCE/.claude/prompts" ]; then
  echo "error: HVE source at $SOURCE appears incomplete: .claude/commands/, .claude/instructions/, or .claude/prompts/ is missing." >&2
  echo "       Ensure you are running install.sh from the root of the hve-claude repository." >&2
  exit 1
fi

echo "Installing HVE"
echo "  from: $SOURCE"
if [ "$GLOBAL" -eq 1 ]; then
  echo "  into: $CLAUDE_DIR (global, all projects)"
else
  echo "  into: $TARGET"
fi
echo

# --- copy command/agent/reference files ----------------------------------------
mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/instructions" "$CLAUDE_DIR/prompts"

cp "$SOURCE"/.claude/commands/hve*.md "$CLAUDE_DIR/commands/"
echo "  ✓ commands -> $CLAUDE_DIR_LABEL/commands/"

cp "$SOURCE"/.claude/agents/hve*.md "$CLAUDE_DIR/agents/"
echo "  ✓ agents   -> $CLAUDE_DIR_LABEL/agents/"

cp "$SOURCE"/.claude/instructions/*.md "$CLAUDE_DIR/instructions/"
cp "$SOURCE"/.claude/prompts/*.md "$CLAUDE_DIR/prompts/"
echo "  ✓ $CLAUDE_DIR_LABEL/instructions/ and $CLAUDE_DIR_LABEL/prompts/"

# --- migrate old top-level instructions/ from prior installs -------------------
# Known HVE filenames that may exist in the old location.
# Keep in sync with HVE_INSTRUCTION_FILES in tests/lib/instruction-files.sh.
HVE_INSTRUCTION_FILES=(
  bash.md csharp.md csharp-tests.md python.md python-tests.md python-uv.md
  rust.md rust-tests.md terraform.md javascript.md typescript.md markdown.md
  git-commit-messages.md writing-style.md
)

OLD_INSTRUCTIONS_DIR="$TARGET/instructions"

# Migrations only apply to project installs; a global install never had
# top-level instructions/ or prompts/, and ~/instructions may be the user's own.
if [ "$GLOBAL" -eq 0 ] && [ -d "$OLD_INSTRUCTIONS_DIR" ]; then
  _migrated=0
  _kept=0
  for fname in "${HVE_INSTRUCTION_FILES[@]}"; do
    old_file="$OLD_INSTRUCTIONS_DIR/$fname"
    new_source="$SOURCE/.claude/instructions/$fname"
    if [ -f "$old_file" ]; then
      if cmp -s "$new_source" "$old_file"; then
        rm "$old_file"
        _migrated=$((_migrated + 1))
      else
        echo "  ! kept instructions/$fname: it differs from the installed version (possible local customization); review and remove manually if unneeded."
        _kept=$((_kept + 1))
      fi
    fi
  done

  # Remove the old directory only if it is now empty.
  if [ -d "$OLD_INSTRUCTIONS_DIR" ] && [ -z "$(ls -A "$OLD_INSTRUCTIONS_DIR")" ]; then
    rmdir "$OLD_INSTRUCTIONS_DIR"
    if [ "$_migrated" -gt 0 ]; then
      echo "  ✓ migrated instructions/ to .claude/instructions/ (removed old top-level copy)"
    fi
  elif [ "$_kept" -eq 0 ] && [ "$_migrated" -eq 0 ]; then
    : # directory had no HVE files; leave it untouched silently
  fi
fi

# --- migrate old top-level prompts/ from prior installs ------------------------
# Prior installs copied reference prompts to <target>/prompts/. They now live in
# .claude/prompts/. Move any file that matches the shipped version byte-for-byte,
# keep diverged ones (possible local edits), and remove the old dir once empty.
# Keep in sync with HVE_PROMPT_FILES in tests/lib/prompt-files.sh.
HVE_PROMPT_FILES=(
  checkpoint.md doc-ops.md prompt-build.md pull-request.md rpi.md task-challenge.md
)

OLD_PROMPTS_DIR="$TARGET/prompts"

if [ "$GLOBAL" -eq 0 ] && [ -d "$OLD_PROMPTS_DIR" ]; then
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

  # Remove the old directory only if it is now empty.
  if [ -d "$OLD_PROMPTS_DIR" ] && [ -z "$(ls -A "$OLD_PROMPTS_DIR")" ]; then
    rmdir "$OLD_PROMPTS_DIR"
    if [ "$_p_migrated" -gt 0 ]; then
      echo "  ✓ migrated prompts/ to .claude/prompts/ (removed old top-level copy)"
    fi
  fi
fi

# --- merge CLAUDE.md -----------------------------------------------------------
# The HVE block is everything in the source CLAUDE.md *before* the "## Your Project"
# placeholder. We wrap it in markers so re-runs replace the block in place rather
# than duplicating it, and so the user's own content is never touched.
HVE_BLOCK="$(awk '/^## Your Project/{exit} {print}' "$SOURCE/CLAUDE.md")"
if [ "$GLOBAL" -eq 1 ]; then
  # ~/.claude/CLAUDE.md is what Claude Code loads for every project.
  TARGET_CLAUDE="$CLAUDE_DIR/CLAUDE.md"
  TARGET_CLAUDE_LABEL="~/.claude/CLAUDE.md"
else
  TARGET_CLAUDE="$TARGET/CLAUDE.md"
  TARGET_CLAUDE_LABEL="CLAUDE.md"
fi
MARK_START="<!-- HVE:START - managed by hve-claude, do not edit between markers -->"
MARK_END="<!-- HVE:END -->"

WRAPPED="$(printf '%s\n%s\n%s\n' "$MARK_START" "$HVE_BLOCK" "$MARK_END")"

if [ ! -f "$TARGET_CLAUDE" ]; then
  # No CLAUDE.md yet: write block plus a fresh placeholder section.
  {
    printf '%s\n\n' "$WRAPPED"
    if [ "$GLOBAL" -eq 1 ]; then
      printf '## Your Global Context\n\n<!-- Add preferences that apply to every project below this line. -->\n'
    else
      printf '## Your Project\n\n<!-- Add your project-specific context below this line. -->\n'
    fi
  } > "$TARGET_CLAUDE"
  echo "  ✓ created $TARGET_CLAUDE_LABEL"
elif grep -q "<!-- HVE:START" "$TARGET_CLAUDE"; then
  # Existing managed block: replace it, preserve everything outside the markers.
  # Pattern-match on <!-- HVE:START / <!-- HVE:END so both the old em-dash marker
  # and the current hyphen marker are handled without creating a duplicate block.
  tmp="$(mktemp)"
  block_file="$(mktemp)"
  printf '%s\n' "$WRAPPED" > "$block_file"
  awk -v bf="$block_file" '
    /<!-- HVE:START/ {
      while ((getline line < bf) > 0) print line
      close(bf)
      skip=1; next
    }
    /<!-- HVE:END/  {skip=0; next}
    !skip
  ' "$TARGET_CLAUDE" > "$tmp"
  rm -f "$block_file"
  mv "$tmp" "$TARGET_CLAUDE"
  echo "  ✓ updated $TARGET_CLAUDE_LABEL HVE block"
else
  # Existing CLAUDE.md, no block: prepend ours, keep the user's content intact.
  tmp="$(mktemp)"
  printf '%s\n\n' "$WRAPPED" > "$tmp"
  cat "$TARGET_CLAUDE" >> "$tmp"
  mv "$tmp" "$TARGET_CLAUDE"
  echo "  ✓ prepended HVE block to existing $TARGET_CLAUDE_LABEL"
fi

# --- gitignore rules -----------------------------------------------------------
# Tracking rules are per-project: in global mode there is no project .gitignore
# to write, so print the rules for the user to add wherever they use /hve.
if [ "$GLOBAL" -eq 0 ]; then
  GITIGNORE="$TARGET/.gitignore"
  add_ignore() {
    local rule="$1"
    if [ ! -f "$GITIGNORE" ] || ! grep -qxF "$rule" "$GITIGNORE"; then
      printf '%s\n' "$rule" >> "$GITIGNORE"
    fi
  }
  if [ ! -f "$GITIGNORE" ] || ! grep -qF ".claude-hve-tracking" "$GITIGNORE"; then
    [ -f "$GITIGNORE" ] && printf '\n' >> "$GITIGNORE"
    printf '# HVE tracking: commit durable artifacts, ignore regenerable noise\n' >> "$GITIGNORE"
  fi
  add_ignore '.claude-hve-tracking/**/subagents/'
  add_ignore '.claude-hve-tracking/sandbox/'
  echo "  ✓ .gitignore rules"
else
  echo "  - skipped .gitignore (global mode; rules are per-project)"
fi

echo
echo "Done. Next:"
if [ "$GLOBAL" -eq 1 ]; then
  echo "  1. HVE commands now work in every project; .claude-hve-tracking/ is created"
  echo "     on first use in each project."
  echo "  2. Add these lines to each project's .gitignore where you use /hve:"
  echo "       .claude-hve-tracking/**/subagents/"
  echo "       .claude-hve-tracking/sandbox/"
  echo "  3. Avoid also installing HVE per-project: duplicate copies of the commands"
  echo "     shadow each other and show twice in the command list."
else
  echo "  1. Add project context under '## Your Project' in $TARGET/CLAUDE.md"
  echo "  2. Run /hve <your first task> in Claude Code"
fi
