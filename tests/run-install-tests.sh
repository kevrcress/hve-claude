#!/usr/bin/env bash
# run-install-tests.sh — automated test runner for install.sh
#
# Usage: ./tests/run-install-tests.sh
#
# Runs all 5 install.sh test cases in isolated temp dirs, prints per-test
# pass/fail, exits 0 only if all assertions pass.
#
set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly INSTALL_SH="${REPO_ROOT}/install.sh"
readonly FIXTURES="${REPO_ROOT}/tests/fixtures"

# Parent temp dir for all test subdirs; cleaned up on exit.
WORK_DIR="$(mktemp -d)"

# Source the assertion library (sets ASSERT_LOG) and shared file list.
# shellcheck source=tests/lib/assert.sh
source "${REPO_ROOT}/tests/lib/assert.sh"
# shellcheck source=tests/lib/instruction-files.sh
source "${REPO_ROOT}/tests/lib/instruction-files.sh"
# shellcheck source=tests/lib/prompt-files.sh
source "${REPO_ROOT}/tests/lib/prompt-files.sh"

# Cleanup on exit: remove all temp dirs and the assertion log.
trap 'rm -rf "${WORK_DIR}"; rm -f "${ASSERT_LOG}"' EXIT

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

err() {
  echo "ERROR: $*" >&2
}

# _fail_inline label detail
# Use for inline checks that bypass the assertion functions.
_fail_inline() {
  local label="${1}"
  local detail="${2}"
  echo "    [FAIL] ${label}: ${detail}"
  echo "FAIL" >> "${ASSERT_LOG}"
}

_ok_inline() {
  local label="${1}"
  local detail="${2}"
  echo "    [pass] ${label}: ${detail}"
  echo "PASS" >> "${ASSERT_LOG}"
}

# ---------------------------------------------------------------------------
# run_test <name> <function_name>
# Prints the test banner, calls the function, checks ASSERT_LOG for new
# FAIL lines since the last boundary marker, then prints OK or FAIL.
# ---------------------------------------------------------------------------
run_test() {
  local name="${1}"
  local body_fn="${2}"

  echo ""
  echo "[ TEST ] ${name}"

  # Record how many FAIL entries exist before this test.
  local before_fail
  before_fail="$(grep -c '^FAIL$' "${ASSERT_LOG}" 2>/dev/null)" || before_fail=0

  # Run the test body. Do NOT run in a subshell — assertions write to
  # ASSERT_LOG which is a file, so they survive even if the body exits early.
  # We disable -e temporarily around the call so a failing assertion (which
  # does not set exit code) doesn't abort the runner.
  set +e
  "${body_fn}"
  set -e

  # Count FAIL entries after this test.
  local after_fail
  after_fail="$(grep -c '^FAIL$' "${ASSERT_LOG}" 2>/dev/null)" || after_fail=0

  local new_failures=$(( after_fail - before_fail ))
  if (( new_failures == 0 )); then
    echo "[  OK  ] ${name}"
  else
    echo "[ FAIL ] ${name}  (${new_failures} assertion(s) failed)"
  fi

  # Insert a boundary so per-test results are visible on re-read.
  echo "---" >> "${ASSERT_LOG}"
}

# ---------------------------------------------------------------------------
# seed_old_instructions <target_dir>
# Copies all 12 HVE instruction files from .claude/instructions/ into
# <target_dir>/instructions/ simulating a prior install at the old location.
# ---------------------------------------------------------------------------
seed_old_instructions() {
  local target="${1}"
  local source_dir="${REPO_ROOT}/.claude/instructions"
  mkdir -p "${target}/instructions"
  local fname
  for fname in "${HVE_INSTRUCTION_FILES[@]}"; do
    cp "${source_dir}/${fname}" "${target}/instructions/${fname}"
  done
}

# ---------------------------------------------------------------------------
# seed_old_prompts <target_dir>
# Copies all HVE prompt files from .claude/prompts/ into <target_dir>/prompts/
# simulating a prior install at the old (root) location.
# ---------------------------------------------------------------------------
seed_old_prompts() {
  local target="${1}"
  local source_dir="${REPO_ROOT}/.claude/prompts"
  mkdir -p "${target}/prompts"
  local fname
  for fname in "${HVE_PROMPT_FILES[@]}"; do
    cp "${source_dir}/${fname}" "${target}/prompts/${fname}"
  done
}

# ---------------------------------------------------------------------------
# Test 1 — New install (no CLAUDE.md at all)
# ---------------------------------------------------------------------------
test1_new_install() {
  local test_dir="${WORK_DIR}/test1"
  mkdir -p "${test_dir}"

  local output
  output="$("${INSTALL_SH}" "${test_dir}" 2>&1)"

  # Commands directory has at least one hve*.md (>=1, not exactly 1)
  local cmd_count
  cmd_count="$(find "${test_dir}/.claude/commands" -maxdepth 1 -name "hve*.md" \
    | wc -l | tr -d '[:space:]')"
  if (( cmd_count >= 1 )); then
    _ok_inline "test1: .claude/commands/ hve*.md count" \
      "found ${cmd_count} file(s)"
  else
    _fail_inline "test1: .claude/commands/ hve*.md count" \
      "expected >=1 hve*.md, got ${cmd_count}"
  fi

  # Agents directory has at least one hve*.md
  local agent_count
  agent_count="$(find "${test_dir}/.claude/agents" -maxdepth 1 -name "hve*.md" \
    | wc -l | tr -d '[:space:]')"
  if (( agent_count >= 1 )); then
    _ok_inline "test1: .claude/agents/ hve*.md count" \
      "found ${agent_count} file(s)"
  else
    _fail_inline "test1: .claude/agents/ hve*.md count" \
      "expected >=1 hve*.md, got ${agent_count}"
  fi

  # .claude/instructions/ has exactly 12 .md files
  assert_file_count \
    "${test_dir}/.claude/instructions" "*.md" 12 \
    "test1: .claude/instructions/ has exactly 12 .md files"

  # .claude/prompts/ has at least one .md
  local prompts_count
  prompts_count="$(find "${test_dir}/.claude/prompts" -maxdepth 1 -name "*.md" \
    | wc -l | tr -d '[:space:]')"
  if (( prompts_count >= 1 )); then
    _ok_inline "test1: .claude/prompts/ .md count" "found ${prompts_count} file(s)"
  else
    _fail_inline "test1: .claude/prompts/ .md count" \
      "expected >=1 .md in .claude/prompts/, got ${prompts_count}"
  fi

  # CLAUDE.md exists
  assert_exists "${test_dir}/CLAUDE.md" "test1: CLAUDE.md exists"

  # CLAUDE.md contains markers
  assert_contains "${test_dir}/CLAUDE.md" "<!-- HVE:START" \
    "test1: CLAUDE.md contains HVE:START"
  assert_contains "${test_dir}/CLAUDE.md" "<!-- HVE:END" \
    "test1: CLAUDE.md contains HVE:END"

  # .gitignore contains tracking rule
  assert_contains "${test_dir}/.gitignore" \
    ".claude-hve-tracking/**/subagents/" \
    "test1: .gitignore contains subagents rule"

  # No root-level instructions/ directory
  assert_not_exists "${test_dir}/instructions" \
    "test1: no instructions/ at root"

  # No root-level prompts/ directory
  assert_not_exists "${test_dir}/prompts" \
    "test1: no prompts/ at root"
}

# ---------------------------------------------------------------------------
# Test 2 — Existing CLAUDE.md, no markers (prepend case)
# ---------------------------------------------------------------------------
test2_prepend() {
  local test_dir="${WORK_DIR}/test2"
  mkdir -p "${test_dir}"
  cp "${FIXTURES}/claude-md-no-hve.md" "${test_dir}/CLAUDE.md"

  local output
  output="$("${INSTALL_SH}" "${test_dir}" 2>&1)"

  # CLAUDE.md contains HVE block
  assert_contains "${test_dir}/CLAUDE.md" "<!-- HVE:START" \
    "test2: CLAUDE.md contains HVE:START"

  # Original content preserved
  assert_contains "${test_dir}/CLAUDE.md" "SENTINEL_ORIGINAL_CONTENT" \
    "test2: CLAUDE.md preserves original sentinel content"

  # Exactly one HVE:START marker
  local count
  count="$(grep -c '<!-- HVE:START' "${test_dir}/CLAUDE.md" || true)"
  if [[ "${count}" == "1" ]]; then
    _ok_inline "test2: CLAUDE.md has exactly one HVE:START" "count=${count}"
  else
    _fail_inline "test2: CLAUDE.md has exactly one HVE:START" \
      "expected 1, got ${count}"
  fi

  # .gitignore contains tracking rule
  assert_contains "${test_dir}/.gitignore" \
    ".claude-hve-tracking/**/subagents/" \
    "test2: .gitignore contains subagents rule"

  # HVE:START appears BEFORE SENTINEL_ORIGINAL_CONTENT
  local start_line sentinel_line
  start_line="$(awk '/<!-- HVE:START/{print NR; exit}' "${test_dir}/CLAUDE.md")"
  sentinel_line="$(awk '/SENTINEL_ORIGINAL_CONTENT/{print NR; exit}' \
    "${test_dir}/CLAUDE.md")"
  if [[ -n "${start_line}" && -n "${sentinel_line}" ]] \
      && (( start_line < sentinel_line )); then
    _ok_inline "test2: HVE:START before SENTINEL_ORIGINAL_CONTENT" \
      "HVE:START at line ${start_line}, sentinel at line ${sentinel_line}"
  else
    _fail_inline "test2: HVE:START before SENTINEL_ORIGINAL_CONTENT" \
      "HVE:START at line '${start_line}', sentinel at line '${sentinel_line}'"
  fi
}

# ---------------------------------------------------------------------------
# Test 3 — Clean upgrade (existing instructions/ with identical files)
# ---------------------------------------------------------------------------
test3_clean_upgrade() {
  local test_dir="${WORK_DIR}/test3"
  mkdir -p "${test_dir}"
  cp "${FIXTURES}/claude-md-current-marker.md" "${test_dir}/CLAUDE.md"
  seed_old_instructions "${test_dir}"
  seed_old_prompts "${test_dir}"

  local output
  output="$("${INSTALL_SH}" "${test_dir}" 2>&1)"

  # .claude/instructions/ has exactly 12 .md files
  assert_file_count \
    "${test_dir}/.claude/instructions" "*.md" 12 \
    "test3: .claude/instructions/ has exactly 12 .md files"

  # instructions/ root dir removed (all files were identical)
  assert_not_exists "${test_dir}/instructions" \
    "test3: instructions/ at root removed after clean migration"

  # .claude/prompts/ has exactly 6 .md files
  assert_file_count \
    "${test_dir}/.claude/prompts" "*.md" 6 \
    "test3: .claude/prompts/ has exactly 6 .md files"

  # prompts/ root dir removed (all files were identical)
  assert_not_exists "${test_dir}/prompts" \
    "test3: prompts/ at root removed after clean migration"

  # Output does NOT contain "! kept" (no diverged-file warnings)
  if echo "${output}" | grep -qF "! kept"; then
    _fail_inline "test3: output does not contain '! kept'" \
      "unexpected diverged-file warning in output"
  else
    _ok_inline "test3: output does not contain '! kept'" \
      "no diverged-file warnings"
  fi

  # CLAUDE.md still has sentinel content
  assert_contains "${test_dir}/CLAUDE.md" "SENTINEL_YOUR_PROJECT_CONTENT" \
    "test3: CLAUDE.md preserves Your Project sentinel"

  # CLAUDE.md contains updated HVE block
  assert_contains "${test_dir}/CLAUDE.md" "<!-- HVE:START" \
    "test3: CLAUDE.md contains HVE:START after upgrade"
}

# ---------------------------------------------------------------------------
# Test 3b — Old em-dash marker upgrade
# ---------------------------------------------------------------------------
test3b_old_marker_upgrade() {
  local test_dir="${WORK_DIR}/test3b"
  mkdir -p "${test_dir}"
  cp "${FIXTURES}/claude-md-old-marker.md" "${test_dir}/CLAUDE.md"

  local output
  output="$("${INSTALL_SH}" "${test_dir}" 2>&1)"

  # CLAUDE.md contains current hyphen marker format
  assert_contains "${test_dir}/CLAUDE.md" "<!-- HVE:START -" \
    "test3b: CLAUDE.md contains hyphen-format HVE:START"

  # CLAUDE.md does NOT contain old em-dash marker
  assert_not_contains "${test_dir}/CLAUDE.md" "<!-- HVE:START —" \
    "test3b: CLAUDE.md does not contain em-dash HVE:START"

  # CLAUDE.md still has Your Project sentinel
  assert_contains "${test_dir}/CLAUDE.md" "SENTINEL_YOUR_PROJECT_CONTENT" \
    "test3b: CLAUDE.md preserves Your Project sentinel"

  # Exactly one HVE:START
  local count
  count="$(grep -c '<!-- HVE:START' "${test_dir}/CLAUDE.md" || true)"
  if [[ "${count}" == "1" ]]; then
    _ok_inline "test3b: CLAUDE.md has exactly one HVE:START" "count=${count}"
  else
    _fail_inline "test3b: CLAUDE.md has exactly one HVE:START" \
      "expected 1, got ${count}"
  fi
}

# ---------------------------------------------------------------------------
# Test 4 — Diverged upgrade (one instruction file locally modified)
# ---------------------------------------------------------------------------
test4_diverged_upgrade() {
  local test_dir="${WORK_DIR}/test4"
  mkdir -p "${test_dir}"
  cp "${FIXTURES}/claude-md-current-marker.md" "${test_dir}/CLAUDE.md"
  seed_old_instructions "${test_dir}"

  # Diverge bash.md by appending a local customization.
  printf '\n# local customization\n' >> "${test_dir}/instructions/bash.md"

  local output
  output="$("${INSTALL_SH}" "${test_dir}" 2>&1)"

  # Output contains "! kept instructions/bash.md"
  assert_output_contains "${output}" "! kept instructions/bash.md" \
    "test4: output contains diverged-file warning for bash.md"

  # Diverged bash.md was kept (not removed)
  assert_exists "${test_dir}/instructions/bash.md" \
    "test4: diverged instructions/bash.md was kept"

  # instructions/ directory still exists (has the diverged file)
  assert_exists "${test_dir}/instructions" \
    "test4: instructions/ dir still exists (has diverged file)"

  # Non-diverged file was removed (python.md should not exist)
  assert_not_exists "${test_dir}/instructions/python.md" \
    "test4: non-diverged instructions/python.md was removed"

  # .claude/instructions/ has exactly 12 .md files
  assert_file_count \
    "${test_dir}/.claude/instructions" "*.md" 12 \
    "test4: .claude/instructions/ has exactly 12 .md files"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  echo "HVE install.sh automated test suite"
  echo "  Repo root : ${REPO_ROOT}"
  echo "  Work dir  : ${WORK_DIR}"
  echo "  Install   : ${INSTALL_SH}"

  run_test "Test 1: New install (no CLAUDE.md)" test1_new_install
  run_test "Test 2: Existing CLAUDE.md, no markers (prepend)" test2_prepend
  run_test "Test 3: Clean upgrade (identical instructions/)" test3_clean_upgrade
  run_test "Test 3b: Old em-dash marker upgrade" test3b_old_marker_upgrade
  run_test "Test 4: Diverged upgrade (bash.md modified)" test4_diverged_upgrade

  finish
}

main "$@"
