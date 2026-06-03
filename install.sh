#!/usr/bin/env bash
#
# install.sh: install the HVE Claude Code workflow into a project.
#
# Usage:
#   ./install.sh [target-dir]
#
#   target-dir   Project to install into. Defaults to the current directory.
#                Pass a path to install elsewhere, e.g. ./install.sh ~/code/my-app
#
# What it does (idempotent; safe to re-run for updates):
#   - copies hve-* slash commands     -> <target>/.claude/commands/
#   - copies hve-* agents             -> <target>/.claude/agents/
#   - copies .claude/instructions/ and prompts/ reference docs
#   - merges the HVE block into       <target>/CLAUDE.md (between HVE markers)
#   - adds tracking rules to          <target>/.gitignore
#   - migrates any old top-level      <target>/instructions/ from prior installs
#
set -euo pipefail

# --- resolve source (this repo) and target -------------------------------------
SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$(cd "${1:-$PWD}" && pwd)"

if [ "$SOURCE" = "$TARGET" ]; then
  echo "error: target is the HVE source repo itself." >&2
  echo "       cd into your project first, or pass a target: ./install.sh /path/to/project" >&2
  exit 1
fi

if [ ! -d "$SOURCE/.claude/commands" ] || [ ! -d "$SOURCE/.claude/instructions" ]; then
  echo "error: HVE source at $SOURCE appears incomplete: .claude/commands/ or .claude/instructions/ is missing." >&2
  echo "       Ensure you are running install.sh from the root of the hve-claude repository." >&2
  exit 1
fi

echo "Installing HVE"
echo "  from: $SOURCE"
echo "  into: $TARGET"
echo

# --- copy command/agent/reference files ----------------------------------------
mkdir -p "$TARGET/.claude/commands" "$TARGET/.claude/agents" "$TARGET/.claude/instructions" "$TARGET/prompts"

cp "$SOURCE"/.claude/commands/hve*.md "$TARGET/.claude/commands/"
echo "  ✓ commands -> .claude/commands/"

cp "$SOURCE"/.claude/agents/hve*.md "$TARGET/.claude/agents/"
echo "  ✓ agents   -> .claude/agents/"

cp "$SOURCE"/.claude/instructions/*.md "$TARGET/.claude/instructions/"
cp "$SOURCE"/prompts/*.md "$TARGET/prompts/"
echo "  ✓ .claude/instructions/ and prompts/"

# --- migrate old top-level instructions/ from prior installs -------------------
# Known HVE filenames that may exist in the old location.
# Keep in sync with HVE_INSTRUCTION_FILES in tests/lib/instruction-files.sh.
HVE_INSTRUCTION_FILES=(
  bash.md csharp.md csharp-tests.md python.md python-tests.md python-uv.md
  rust.md rust-tests.md terraform.md markdown.md git-commit-messages.md writing-style.md
)

OLD_INSTRUCTIONS_DIR="$TARGET/instructions"

if [ -d "$OLD_INSTRUCTIONS_DIR" ]; then
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

# --- merge CLAUDE.md -----------------------------------------------------------
# The HVE block is everything in the source CLAUDE.md *before* the "## Your Project"
# placeholder. We wrap it in markers so re-runs replace the block in place rather
# than duplicating it, and so the user's own content is never touched.
HVE_BLOCK="$(awk '/^## Your Project/{exit} {print}' "$SOURCE/CLAUDE.md")"
TARGET_CLAUDE="$TARGET/CLAUDE.md"
MARK_START="<!-- HVE:START - managed by install.sh, do not edit between markers -->"
MARK_END="<!-- HVE:END -->"

WRAPPED="$(printf '%s\n%s\n%s\n' "$MARK_START" "$HVE_BLOCK" "$MARK_END")"

if [ ! -f "$TARGET_CLAUDE" ]; then
  # No CLAUDE.md yet: write block plus a fresh Your Project placeholder.
  {
    printf '%s\n\n' "$WRAPPED"
    printf '## Your Project\n\n<!-- Add your project-specific context below this line. -->\n'
  } > "$TARGET_CLAUDE"
  echo "  ✓ created CLAUDE.md"
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
  echo "  ✓ updated CLAUDE.md HVE block"
else
  # Existing CLAUDE.md, no block: prepend ours, keep the user's content intact.
  tmp="$(mktemp)"
  printf '%s\n\n' "$WRAPPED" > "$tmp"
  cat "$TARGET_CLAUDE" >> "$tmp"
  mv "$tmp" "$TARGET_CLAUDE"
  echo "  ✓ prepended HVE block to existing CLAUDE.md"
fi

# --- gitignore rules -----------------------------------------------------------
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

echo
echo "Done. Next:"
echo "  1. Add project context under '## Your Project' in $TARGET/CLAUDE.md"
echo "  2. Run /hve <your first task> in Claude Code"
