#!/usr/bin/env bash
# assert.sh — shared assertion library for HVE installer tests
#
# Usage: source this file; call assertions; call finish at the end.
# This file is SOURCED, not executed directly.
#
# Design: results are written to ASSERT_LOG (a temp file) so assertions
# work correctly when called from subshells. finish() tallies the log.

ASSERT_LOG="$(mktemp)" || { echo "ERROR: mktemp failed" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

_ok() {
  local label="${1}"
  local detail="${2}"
  echo "[pass] ${label}: ${detail}"
  echo "PASS" >> "${ASSERT_LOG}"
}

_fail() {
  local label="${1}"
  local detail="${2}"
  echo "[FAIL] ${label}: ${detail}"
  echo "FAIL" >> "${ASSERT_LOG}"
}

# ---------------------------------------------------------------------------
# Public assertion functions
# ---------------------------------------------------------------------------

assert_exists() {
  local path="${1}"
  local label="${2}"
  if [[ -e "${path}" ]]; then
    _ok "${label}" "exists: ${path}"
  else
    _fail "${label}" "expected to exist but not found: ${path}"
  fi
}

assert_not_exists() {
  local path="${1}"
  local label="${2}"
  if [[ ! -e "${path}" ]]; then
    _ok "${label}" "correctly absent: ${path}"
  else
    _fail "${label}" "expected to be absent but found: ${path}"
  fi
}

assert_contains() {
  local path="${1}"
  local string="${2}"
  local label="${3}"
  if grep -qF "${string}" "${path}" 2>/dev/null; then
    _ok "${label}" "found '${string}' in ${path}"
  else
    _fail "${label}" "expected '${string}' in ${path} but not found"
  fi
}

assert_not_contains() {
  local path="${1}"
  local string="${2}"
  local label="${3}"
  if ! grep -qF "${string}" "${path}" 2>/dev/null; then
    _ok "${label}" "'${string}' correctly absent from ${path}"
  else
    _fail "${label}" "expected '${string}' to be absent from ${path} but found"
  fi
}

assert_file_count() {
  local dir="${1}"
  local pattern="${2}"
  local expected_count="${3}"
  local label="${4}"
  local actual_count
  actual_count="$(find "${dir}" -maxdepth 1 -name "${pattern}" | wc -l | tr -d '[:space:]')"
  if (( actual_count == expected_count )); then
    _ok "${label}" "found ${actual_count} file(s) matching '${pattern}' in ${dir}"
  else
    _fail "${label}" \
      "expected ${expected_count} file(s) matching '${pattern}' in ${dir}, got ${actual_count}"
  fi
}

assert_output_contains() {
  local output="${1}"
  local string="${2}"
  local label="${3}"
  if [[ "${output}" == *"${string}"* ]]; then
    _ok "${label}" "output contains '${string}'"
  else
    _fail "${label}" "expected output to contain '${string}' but it did not"
  fi
}

# ---------------------------------------------------------------------------
# Summary and exit
# ---------------------------------------------------------------------------

finish() {
  local pass_count fail_count
  pass_count="$(grep -c '^PASS$' "${ASSERT_LOG}" 2>/dev/null)" || pass_count=0
  fail_count="$(grep -c '^FAIL$' "${ASSERT_LOG}" 2>/dev/null)" || fail_count=0
  rm -f "${ASSERT_LOG}"
  echo ""
  echo "Results: ${pass_count} passed, ${fail_count} failed"
  if (( fail_count > 0 )); then
    exit 1
  fi
}
