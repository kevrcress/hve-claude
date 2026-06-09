#!/usr/bin/env bash
# run-prompt-new-install.sh — Semi-manual prompt test: new HVE install via Claude Code
#
# This script:
#   1. Creates a fresh temp directory (empty project — no CLAUDE.md, no HVE files)
#   2. Prints the directory path and the prompt to paste into Claude Code
#   3. Pauses while you run Claude Code in that directory
#   4. Asserts that the install completed correctly
#   5. Prints the temp dir path for inspection (NOT auto-deleted)
#
# NOTE: This test clones the dev branch from GitHub.
# Run only after merging feature/installer-tests into dev and pushing.

set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---------------------------------------------------------------------------
# Source assertion library
# ---------------------------------------------------------------------------

source "${REPO_ROOT}/tests/lib/assert.sh"

# ---------------------------------------------------------------------------
# Local helper: assert a directory contains at least one file matching pattern
# ---------------------------------------------------------------------------

assert_has_files() {
  local dir="${1}"
  local pattern="${2}"
  local label="${3}"
  local count
  count="$(find "${dir}" -maxdepth 1 -name "${pattern}" | wc -l | tr -d '[:space:]')"
  if (( count >= 1 )); then
    echo "[pass] ${label}: found ${count} file(s) matching '${pattern}' in ${dir}"
    echo "PASS" >> "${ASSERT_LOG}"
  else
    echo "[FAIL] ${label}: expected at least 1 file matching '${pattern}' in ${dir}, found 0"
    echo "FAIL" >> "${ASSERT_LOG}"
  fi
}

# ---------------------------------------------------------------------------
# Setup: create fresh temp directory
# ---------------------------------------------------------------------------

WORK_DIR="$(mktemp -d)"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  HVE Installer — Prompt Test: New Install           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "This test seeds an empty project directory, asks you to open"
echo "Claude Code in it and paste a prompt, then asserts the install"
echo "completed correctly."
echo ""

# ---------------------------------------------------------------------------
# STEP 1: Print the target directory prominently
# ---------------------------------------------------------------------------

echo "╔══════════════════════════════════════════════════════╗"
echo "║  STEP 1: Open Claude Code in this directory:        ║"
echo "║  (not your usual project — this specific temp dir)  ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ${WORK_DIR}"
echo ""

# ---------------------------------------------------------------------------
# STEP 2: Print the prompt to paste
# ---------------------------------------------------------------------------

echo "╔══════════════════════════════════════════════════════╗"
echo "║  STEP 2: Paste this prompt into Claude Code:        ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
cat <<'PROMPT'
Please install the HVE Claude Code workflow into this project. Clone
https://github.com/kevrcress/hve-claude -b dev (branch: dev) into a
temporary directory, then copy its hve-* commands and agents into my
.claude/ folder, copy its .claude/instructions/ and .claude/prompts/ files in,
and merge everything above the '## Your Project' heading in its CLAUDE.md
into mine wrapped in these markers:
<!-- HVE:START - managed by hve-claude, do not edit between markers -->
...HVE content...
<!-- HVE:END -->
If my CLAUDE.md already has those markers, replace the content between them.
If it has no markers, prepend the wrapped block before my existing content.
Never touch anything outside the markers or below '## Your Project'. Add the
.claude-hve-tracking subagents and sandbox paths to my .gitignore, then
delete the temp clone and show me what changed.
PROMPT
echo ""
echo "(Note: this test prompt clones the dev branch — run only after merging"
echo "feature/installer-tests into dev and pushing.)"
echo ""

# ---------------------------------------------------------------------------
# Pause for user
# ---------------------------------------------------------------------------

echo "Press Enter once Claude has finished..."
read -r _

# ---------------------------------------------------------------------------
# Assertions — run from WORK_DIR
# ---------------------------------------------------------------------------

echo ""
echo "Running assertions against: ${WORK_DIR}"
echo ""

assert_has_files \
  "${WORK_DIR}/.claude/commands" "hve*.md" \
  ".claude/commands contains at least one hve*.md"

assert_has_files \
  "${WORK_DIR}/.claude/agents" "hve*.md" \
  ".claude/agents contains at least one hve*.md"

assert_has_files \
  "${WORK_DIR}/.claude/instructions" "*.md" \
  ".claude/instructions contains at least one .md"

assert_has_files \
  "${WORK_DIR}/.claude/prompts" "*.md" \
  ".claude/prompts/ contains at least one .md"

assert_exists \
  "${WORK_DIR}/CLAUDE.md" \
  "CLAUDE.md exists"

assert_contains \
  "${WORK_DIR}/CLAUDE.md" \
  "<!-- HVE:START" \
  "CLAUDE.md contains HVE:START marker"

assert_contains \
  "${WORK_DIR}/CLAUDE.md" \
  "<!-- HVE:END" \
  "CLAUDE.md contains HVE:END marker"

assert_contains \
  "${WORK_DIR}/.gitignore" \
  ".claude-hve-tracking/**/subagents/" \
  ".gitignore contains subagents exclusion rule"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

# Print temp dir before finish so it is visible even if finish exits non-zero.
echo ""
echo "Temp directory (inspect if needed): ${WORK_DIR}"
echo "Remove it when done: rm -rf ${WORK_DIR}"

# Tally results; finish exits non-zero on any failure.
# Disable errexit around finish so the note below prints before we exit.
set +e
finish
_finish_rc=$?
set -e

if (( _finish_rc != 0 )); then
  echo ""
  echo "NOTE: If all assertions failed, you may have opened Claude in the"
  echo "wrong directory. Re-run and open Claude specifically in the directory"
  echo "shown in STEP 1."
  exit "${_finish_rc}"
fi
