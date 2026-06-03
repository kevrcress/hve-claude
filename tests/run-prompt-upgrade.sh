#!/usr/bin/env bash
# run-prompt-upgrade.sh — Semi-manual prompt test: HVE upgrade scenario
#
# NOTE: This script clones the dev branch from GitHub. Run it only after
# merging feature/installer-tests into dev and pushing to GitHub.
#
# What this script does:
#   1. Seeds a temp project that looks like an older HVE install:
#      - CLAUDE.md with current HVE markers (older content inside)
#      - instructions/ at project root with 12 HVE files (old location)
#      - .claude/commands/, .claude/agents/, .claude/instructions/, prompts/
#        populated with current files (simulates an already-working install)
#   2. Prints the update prompt to paste into Claude Code
#   3. Pauses for you to run Claude Code
#   4. Asserts that the upgrade completed correctly

set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${REPO_ROOT}/tests/lib/assert.sh"
source "${REPO_ROOT}/tests/lib/instruction-files.sh"

# ---------------------------------------------------------------------------
# Setup — create and seed the temp project
# ---------------------------------------------------------------------------

WORK_DIR="$(mktemp -d)"
# Do NOT auto-cleanup — leave for inspection after assertions

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  HVE PROMPT TEST — UPGRADE SCENARIO                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Seeding temp project at:"
echo "  ${WORK_DIR}"
echo ""

# 1. Seed CLAUDE.md with current-marker fixture (older content inside)
cp "${REPO_ROOT}/tests/fixtures/claude-md-current-marker.md" "${WORK_DIR}/CLAUDE.md"

# 2. Seed old-style instructions/ at project root (12 HVE files)
mkdir -p "${WORK_DIR}/instructions"
for fname in "${HVE_INSTRUCTION_FILES[@]}"; do
  cp "${REPO_ROOT}/.claude/instructions/${fname}" \
     "${WORK_DIR}/instructions/${fname}"
done

# 3. Seed current HVE files in new locations (simulates a working install)
mkdir -p "${WORK_DIR}/.claude/commands"
cp "${REPO_ROOT}/.claude/commands/hve"*.md "${WORK_DIR}/.claude/commands/"

mkdir -p "${WORK_DIR}/.claude/agents"
cp "${REPO_ROOT}/.claude/agents/hve"*.md "${WORK_DIR}/.claude/agents/"

mkdir -p "${WORK_DIR}/prompts"
cp "${REPO_ROOT}/prompts/"*.md "${WORK_DIR}/prompts/"

mkdir -p "${WORK_DIR}/.claude/instructions"
cp "${REPO_ROOT}/.claude/instructions/"*.md "${WORK_DIR}/.claude/instructions/"

echo "Seeded upgrade scenario:"
echo "  - CLAUDE.md with current HVE markers (older content)"
echo "  - instructions/ at root with 12 HVE files (old location — should be migrated)"
echo "  - .claude/commands/, .claude/agents/, .claude/instructions/, prompts/ populated"
echo ""

# ---------------------------------------------------------------------------
# Step 1 — Open Claude Code in the temp project
# ---------------------------------------------------------------------------

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  STEP 1 — Open Claude Code in this directory                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  ${WORK_DIR}"
echo ""

# ---------------------------------------------------------------------------
# Step 2 — Paste the update prompt into Claude Code
# ---------------------------------------------------------------------------

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  STEP 2 — Paste this prompt into Claude Code                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "(Note: this test prompt clones the dev branch — run only after merging"
echo "feature/installer-tests into dev and pushing.)"
echo ""
cat <<'PROMPT'
Please update the HVE Claude Code workflow in this project. Clone
https://github.com/kevrcress/hve-claude -b dev into a temporary directory, then
overwrite the hve-* files in .claude/commands/ and .claude/agents/, overwrite
all files in .claude/instructions/ and prompts/ with the latest versions, and
update the HVE block in my CLAUDE.md with the new content from the cloned
repo (everything above its '## Your Project' heading), wrapped in these
markers:
<!-- HVE:START - managed by install.sh, do not edit between markers -->
...HVE content...
<!-- HVE:END -->
If my CLAUDE.md already has those markers, replace the content between them.
If it has no markers, find the existing HVE block (it begins with the HVE
heading and ends just before my project-specific content), replace it with the
new content wrapped in the markers above. Never touch anything outside the
markers or my project-specific content. If an instructions/ folder exists at
the project root from a prior install, move any file that matches the installed
version byte-for-byte to .claude/instructions/ and remove the folder once it
is empty. Delete the temp clone and show me what changed.
PROMPT
echo ""

# ---------------------------------------------------------------------------
# Pause for the user
# ---------------------------------------------------------------------------

echo "Press Enter once Claude has finished..."
read -r _

# ---------------------------------------------------------------------------
# Assertions
# ---------------------------------------------------------------------------

echo ""
echo "Running assertions..."
echo ""

assert_exists \
  "$(find "${WORK_DIR}/.claude/commands" -maxdepth 1 -name 'hve*.md' -print -quit 2>/dev/null)" \
  ".claude/commands/ contains at least one hve*.md"

assert_exists \
  "$(find "${WORK_DIR}/.claude/agents" -maxdepth 1 -name 'hve*.md' -print -quit 2>/dev/null)" \
  ".claude/agents/ contains at least one hve*.md"

assert_exists \
  "$(find "${WORK_DIR}/.claude/instructions" -maxdepth 1 -name '*.md' -print -quit 2>/dev/null)" \
  ".claude/instructions/ contains at least one .md"

assert_exists \
  "$(find "${WORK_DIR}/prompts" -maxdepth 1 -name '*.md' -print -quit 2>/dev/null)" \
  "prompts/ contains at least one .md"

assert_contains \
  "${WORK_DIR}/CLAUDE.md" \
  "<!-- HVE:START" \
  "CLAUDE.md contains HVE:START marker"

assert_contains \
  "${WORK_DIR}/CLAUDE.md" \
  "<!-- HVE:END" \
  "CLAUDE.md contains HVE:END marker"

assert_contains \
  "${WORK_DIR}/CLAUDE.md" \
  "SENTINEL_YOUR_PROJECT_CONTENT" \
  "CLAUDE.md still contains Your Project sentinel (user content preserved)"

assert_not_exists \
  "${WORK_DIR}/instructions" \
  "instructions/ at root no longer exists (migration completed)"

finish

# ---------------------------------------------------------------------------
# Post-run output
# ---------------------------------------------------------------------------

echo ""
echo "Temp project left for inspection at:"
echo "  ${WORK_DIR}"
echo ""
echo "To clean up manually:"
echo "  rm -rf \"${WORK_DIR}\""
echo ""
echo "If assertions failed, check the temp directory for clues."
echo "Wrong directory? Make sure Claude Code was opened in the path shown"
echo "in STEP 1 above, not your repo root or another project."
