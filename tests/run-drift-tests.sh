#!/usr/bin/env bash
# run-drift-tests.sh — docs-vs-frontmatter drift + security hygiene tests
#
# Usage: ./tests/run-drift-tests.sh
#
# Asserts that documentation restating agent `model:` frontmatter has not
# drifted from the frontmatter itself (the source of truth), and that the
# repo .gitignore carries the HVE security-hygiene credential patterns.
#
# Test groups:
#   1. Frontmatter validity  — every .claude/agents/*.md has a model: in
#      {haiku, sonnet, opus, inherit} and a name: matching its filename stem
#   2. internals.md sync     — docs/internals.md agent-table Model column
#      matches frontmatter (case-insensitive)
#   3. CLAUDE.md sync        — Model Selection prose does not claim a
#      different tier for any pinned agent it names
#   4. .gitignore hygiene    — credential patterns from the CLAUDE.md
#      security checklist are present
#
set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly AGENTS_DIR="${REPO_ROOT}/.claude/agents"
readonly INTERNALS_MD="${REPO_ROOT}/docs/internals.md"
readonly CLAUDE_MD="${REPO_ROOT}/CLAUDE.md"
readonly GITIGNORE="${REPO_ROOT}/.gitignore"
readonly VALID_MODELS="haiku sonnet opus inherit"

# Source the assertion library (sets ASSERT_LOG).
# shellcheck source=tests/lib/assert.sh
source "${REPO_ROOT}/tests/lib/assert.sh"

# Cleanup on exit: remove the assertion log (finish also removes it; -f
# makes the double removal safe).
trap 'rm -f "${ASSERT_LOG}"' EXIT

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

# to_lower — lowercase stdin (portable; avoids bash-4-only ${var,,})
to_lower() {
  tr '[:upper:]' '[:lower:]'
}

# frontmatter_value <file> <key>
# Prints the value of <key>: from the file's YAML frontmatter block
# (between the opening and closing --- lines). Empty if absent.
frontmatter_value() {
  local file="${1}"
  local key="${2}"
  awk -v key="${key}" '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { exit }
    in_fm && index($0, key ":") == 1 {
      val = $0
      sub(/^[a-z]+:[[:space:]]*/, "", val)
      print val
      exit
    }
  ' "${file}"
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

  local before_fail
  before_fail="$(grep -c '^FAIL$' "${ASSERT_LOG}" 2>/dev/null)" || before_fail=0

  # Disable -e around the body so a failing assertion doesn't abort the
  # runner; results accumulate in ASSERT_LOG.
  set +e
  "${body_fn}"
  set -e

  local after_fail
  after_fail="$(grep -c '^FAIL$' "${ASSERT_LOG}" 2>/dev/null)" || after_fail=0

  local new_failures=$(( after_fail - before_fail ))
  if (( new_failures == 0 )); then
    echo "[  OK  ] ${name}"
  else
    echo "[ FAIL ] ${name}  (${new_failures} assertion(s) failed)"
  fi

  echo "---" >> "${ASSERT_LOG}"
}

# ---------------------------------------------------------------------------
# Test 1 — Frontmatter validity
# Every .claude/agents/*.md must declare model: in the valid set and a
# name: equal to its filename stem.
# ---------------------------------------------------------------------------
test1_frontmatter_validity() {
  local file stem model name
  for file in "${AGENTS_DIR}"/*.md; do
    stem="$(basename "${file}" .md)"

    model="$(frontmatter_value "${file}" "model")"
    case " ${VALID_MODELS} " in
      *" ${model} "*)
        _ok_inline "test1: ${stem} model valid" "model=${model}"
        ;;
      *)
        _fail_inline "test1: ${stem} model valid" \
          "model='${model}' not in {${VALID_MODELS// /, }}"
        ;;
    esac

    name="$(frontmatter_value "${file}" "name")"
    if [[ "${name}" == "${stem}" ]]; then
      _ok_inline "test1: ${stem} name matches filename" "name=${name}"
    else
      _fail_inline "test1: ${stem} name matches filename" \
        "name='${name}' != filename stem '${stem}'"
    fi
  done
}

# ---------------------------------------------------------------------------
# Test 2 — docs/internals.md agent-table sync
# For each agent, the Model column of its table row (last cell) must equal
# the frontmatter model, case-insensitively. A missing row is a failure.
# ---------------------------------------------------------------------------
test2_internals_table_sync() {
  local file stem fm_model row doc_model
  for file in "${AGENTS_DIR}"/*.md; do
    stem="$(basename "${file}" .md)"
    fm_model="$(frontmatter_value "${file}" "model" | to_lower)"

    row="$(grep -F "| \`${stem}\` |" "${INTERNALS_MD}" || true)"
    if [[ -z "${row}" ]]; then
      _fail_inline "test2: ${stem} table row" \
        "no row for \`${stem}\` in docs/internals.md agent table"
      continue
    fi

    # Last non-empty cell of the pipe-delimited row is the Model column.
    doc_model="$(echo "${row}" | awk -F'|' '{
      cell = $(NF-1)
      gsub(/^[ \t]+|[ \t]+$/, "", cell)
      print cell
    }' | to_lower)"

    if [[ "${doc_model}" == "${fm_model}" ]]; then
      _ok_inline "test2: ${stem} Model column matches frontmatter" \
        "both '${fm_model}'"
    else
      _fail_inline "test2: ${stem} Model column matches frontmatter" \
        "internals.md says '${doc_model}', frontmatter says '${fm_model}'"
    fi
  done
}

# ---------------------------------------------------------------------------
# Test 3 — CLAUDE.md Model Selection prose sync (narrow check)
# For each agent pinned haiku or sonnet in frontmatter, the Model Selection
# section must not claim a different tier for that agent by name. The prose
# names agents in human form ("plan validator" for hve-plan-validator), so
# we derive that form, split the section into clauses on ';', and require
# that any tier word in a clause naming the agent equals the pinned tier.
# Not being named at all is a pass (no contradiction possible).
# ---------------------------------------------------------------------------
test3_claudemd_prose_sync() {
  local section
  section="$(awk '/^## Model Selection$/ { flag = 1; next }
                  /^## / { flag = 0 }
                  flag' "${CLAUDE_MD}" | to_lower)"

  if [[ -z "${section}" ]]; then
    _fail_inline "test3: Model Selection section present" \
      "no '## Model Selection' section found in CLAUDE.md"
    return
  fi

  local file stem fm_model human clause tier
  local mentioned contradiction
  for file in "${AGENTS_DIR}"/*.md; do
    stem="$(basename "${file}" .md)"
    fm_model="$(frontmatter_value "${file}" "model" | to_lower)"
    [[ "${fm_model}" == "haiku" || "${fm_model}" == "sonnet" ]] || continue

    # hve-plan-validator -> "plan validator"
    human="${stem#hve-}"
    human="${human//-/ }"

    mentioned=0
    contradiction=""
    while IFS= read -r clause; do
      [[ "${clause}" == *"${human}"* ]] || continue
      mentioned=1
      for tier in haiku sonnet opus inherit; do
        if [[ "${clause}" == *"${tier}"* && "${tier}" != "${fm_model}" ]]; then
          contradiction="clause names '${human}' with tier '${tier}'"
        fi
      done
    done < <(echo "${section}" | tr ';' '\n')

    if [[ -n "${contradiction}" ]]; then
      _fail_inline "test3: ${stem} prose tier matches frontmatter" \
        "${contradiction}, but frontmatter says '${fm_model}'"
    elif (( mentioned == 1 )); then
      _ok_inline "test3: ${stem} prose tier matches frontmatter" \
        "prose names '${human}' consistently with '${fm_model}'"
    else
      _ok_inline "test3: ${stem} prose tier matches frontmatter" \
        "'${human}' not named in prose; no contradiction possible"
    fi
  done
}

# ---------------------------------------------------------------------------
# Test 4 — .gitignore security hygiene
# The credential patterns from the CLAUDE.md Security Hygiene checklist
# must be present in the repo .gitignore.
# ---------------------------------------------------------------------------
test4_gitignore_hygiene() {
  local pattern
  for pattern in ".env" ".env.*" "*.pem" "*.key" "*.p12"; do
    assert_contains "${GITIGNORE}" "${pattern}" \
      "test4: .gitignore contains '${pattern}'"
  done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  echo "HVE docs-drift automated test suite"
  echo "  Repo root : ${REPO_ROOT}"
  echo "  Agents    : ${AGENTS_DIR}"

  local target
  for target in "${AGENTS_DIR}" "${INTERNALS_MD}" "${CLAUDE_MD}" \
    "${GITIGNORE}"; do
    if [[ ! -e "${target}" ]]; then
      err "required path not found: ${target}"
      exit 1
    fi
  done

  run_test "Test 1: Agent frontmatter validity" test1_frontmatter_validity
  run_test "Test 2: docs/internals.md agent-table sync" \
    test2_internals_table_sync
  run_test "Test 3: CLAUDE.md Model Selection prose sync" \
    test3_claudemd_prose_sync
  run_test "Test 4: .gitignore security hygiene" test4_gitignore_hygiene

  finish
}

main "$@"
