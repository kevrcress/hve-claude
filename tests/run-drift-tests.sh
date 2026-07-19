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
readonly COMMANDS_DIR="${REPO_ROOT}/.claude/commands"
readonly INSTRUCTIONS_DIR="${REPO_ROOT}/.claude/instructions"
readonly INTERNALS_MD="${REPO_ROOT}/docs/internals.md"
readonly CLAUDE_MD="${REPO_ROOT}/CLAUDE.md"
readonly GITIGNORE="${REPO_ROOT}/.gitignore"
readonly VALID_MODELS="haiku sonnet opus inherit"

# Agents that carry the FULL Subagent Response Protocol (6 invariant lines).
# The three prompt-builder sandbox agents (hve-prompt-evaluator,
# hve-prompt-tester, hve-prompt-updater) intentionally use a reduced,
# sandbox-local Response Format (no 3-question cap; the updater has no
# 5-item checklist), so they are out of scope for the structural check
# below. This explicit list is the discovery idiom — no agent file names
# the protocol as a greppable string.
readonly FULL_PROTOCOL_AGENTS="hve-researcher hve-phase-implementor \
hve-plan-validator hve-rpi-validator hve-implementation-validator \
hve-pr-reviewer"

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
# extract_line <file> <fixed-prefix>
# Prints the FIRST line of <file> beginning with <fixed-prefix> (matched as
# a literal, anchored to start-of-line). Empty if no such line exists. Used
# to pull a single-line boilerplate paragraph for byte-identical comparison.
# ---------------------------------------------------------------------------
extract_line() {
  local file="${1}"
  local prefix="${2}"
  grep -F -m1 -- "${prefix}" "${file}" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Test 5 — subagent_model_boilerplate
# The `--subagent-model` paragraph is duplicated verbatim across every
# command that carries it. Extract that line from each carrier and assert
# all occurrences are byte-identical to the first occurrence.
# ---------------------------------------------------------------------------
readonly SUBAGENT_MODEL_PREFIX='If `--subagent-model'

test5_subagent_model_boilerplate() {
  local file stem line canonical="" canonical_file=""
  local -a carriers=()
  for file in "${COMMANDS_DIR}"/*.md; do
    if grep -qF -- "${SUBAGENT_MODEL_PREFIX}" "${file}"; then
      carriers+=("${file}")
    fi
  done

  if (( ${#carriers[@]} < 2 )); then
    _fail_inline "test5: carrier count" \
      "expected >= 2 commands carrying the --subagent-model block, got ${#carriers[@]}"
    return
  fi
  _ok_inline "test5: carrier count" \
    "${#carriers[@]} command(s) carry the --subagent-model block"

  for file in "${carriers[@]}"; do
    stem="$(basename "${file}" .md)"
    line="$(extract_line "${file}" "${SUBAGENT_MODEL_PREFIX}")"
    if [[ -z "${canonical}" ]]; then
      canonical="${line}"
      canonical_file="${stem}"
      _ok_inline "test5: ${stem} is canonical" "reference occurrence"
      continue
    fi
    if [[ "${line}" == "${canonical}" ]]; then
      _ok_inline "test5: ${stem} matches canonical" \
        "byte-identical to ${canonical_file}"
    else
      _fail_inline "test5: ${stem} matches canonical" \
        "--subagent-model block differs from ${canonical_file}"
    fi
  done
}

# ---------------------------------------------------------------------------
# Test 6 — friction_flag_boilerplate
# The `--friction-log` paragraph is duplicated verbatim across exactly six
# commands (research, plan, implement, review, pr-review, challenge). Assert
# the carrier count is 6 and every occurrence is byte-identical to the first.
# ---------------------------------------------------------------------------
readonly FRICTION_FLAG_PREFIX='If `--friction-log`'
readonly FRICTION_EXPECTED_COUNT=6

test6_friction_flag_boilerplate() {
  local file stem line canonical="" canonical_file=""
  local -a carriers=()
  for file in "${COMMANDS_DIR}"/*.md; do
    if grep -qF -- "${FRICTION_FLAG_PREFIX}" "${file}"; then
      carriers+=("${file}")
    fi
  done

  if (( ${#carriers[@]} == FRICTION_EXPECTED_COUNT )); then
    _ok_inline "test6: carrier count" \
      "${#carriers[@]} commands carry the --friction-log block (expected ${FRICTION_EXPECTED_COUNT})"
  else
    _fail_inline "test6: carrier count" \
      "expected ${FRICTION_EXPECTED_COUNT} commands carrying the --friction-log block, got ${#carriers[@]}"
  fi

  for file in "${carriers[@]}"; do
    stem="$(basename "${file}" .md)"
    line="$(extract_line "${file}" "${FRICTION_FLAG_PREFIX}")"
    if [[ -z "${canonical}" ]]; then
      canonical="${line}"
      canonical_file="${stem}"
      _ok_inline "test6: ${stem} is canonical" "reference occurrence"
      continue
    fi
    if [[ "${line}" == "${canonical}" ]]; then
      _ok_inline "test6: ${stem} matches canonical" \
        "byte-identical to ${canonical_file}"
    else
      _fail_inline "test6: ${stem} matches canonical" \
        "--friction-log block differs from ${canonical_file}"
    fi
  done
}

# ---------------------------------------------------------------------------
# Test 7 — response_protocol_structure
# Each full-protocol agent must carry all six invariant lines of the
# Subagent Response Protocol. Structural greps (not byte-diff), because
# agents vary the status vocabulary (Status/Quality/Verdict) and the exact
# wording of each item. See FULL_PROTOCOL_AGENTS for the in-scope set.
# ---------------------------------------------------------------------------
test7_response_protocol_structure() {
  local stem file
  for stem in ${FULL_PROTOCOL_AGENTS}; do
    file="${AGENTS_DIR}/${stem}.md"
    if [[ ! -f "${file}" ]]; then
      _fail_inline "test7: ${stem} present" \
        "expected agent file ${file} but not found"
      continue
    fi

    _grep_invariant "${file}" "${stem}" "artifact-path line" \
      'One line: `?(Written|Updated):'
    _grep_invariant "${file}" "${stem}" "status line" \
      '(Status:|Quality:|Verdict:)'
    _grep_invariant "${file}" "${stem}" "7-bullet cap" \
      'Up to \**7\** bullet'
    _grep_invariant "${file}" "${stem}" "5-item checklist cap" \
      'Up to \**5\**'
    _grep_invariant "${file}" "${stem}" "3-question cap" \
      'Up to \**3\**'
    _grep_invariant "${file}" "${stem}" "Full detail line" \
      'Full detail'
  done
}

# _grep_invariant <file> <stem> <label> <ere>
# Assert <file> contains at least one line matching <ere>.
_grep_invariant() {
  local file="${1}"
  local stem="${2}"
  local label="${3}"
  local ere="${4}"
  if grep -qE "${ere}" "${file}"; then
    _ok_inline "test7: ${stem} ${label}" "present"
  else
    _fail_inline "test7: ${stem} ${label}" \
      "no line matching /${ere}/ in ${stem}.md"
  fi
}

# ---------------------------------------------------------------------------
# Test 8 — instructions_table_sync
# The CLAUDE.md Instructions Reference table and .claude/instructions/ must
# agree in both directions: every `.claude/instructions/*.md` path cited in
# the table exists on disk, and every file on disk appears as a table row.
# (The install suite only counts the instruction files; it does not check
# the CLAUDE.md table, so this is a new assertion, not a duplicate.)
# ---------------------------------------------------------------------------
test8_instructions_table_sync() {
  local -a table_paths=()
  local path
  # Extract every `.claude/instructions/NAME.md` path cited in CLAUDE.md.
  while IFS= read -r path; do
    [[ -n "${path}" ]] && table_paths+=("${path}")
  done < <(grep -oE '\.claude/instructions/[A-Za-z0-9._-]+\.md' "${CLAUDE_MD}" \
    | sort -u)

  if (( ${#table_paths[@]} == 0 )); then
    _fail_inline "test8: table rows present" \
      "no .claude/instructions/*.md rows found in CLAUDE.md"
    return
  fi

  # Direction 1: every cited path exists on disk.
  for path in "${table_paths[@]}"; do
    if [[ -f "${REPO_ROOT}/${path}" ]]; then
      _ok_inline "test8: cited file exists" "${path}"
    else
      _fail_inline "test8: cited file exists" \
        "CLAUDE.md cites ${path} but the file is missing"
    fi
  done

  # Direction 2: every file on disk appears as a table row.
  local file stem cited
  for file in "${INSTRUCTIONS_DIR}"/*.md; do
    stem="$(basename "${file}")"
    cited=0
    for path in "${table_paths[@]}"; do
      if [[ "${path}" == ".claude/instructions/${stem}" ]]; then
        cited=1
        break
      fi
    done
    if (( cited == 1 )); then
      _ok_inline "test8: file in table" "${stem}"
    else
      _fail_inline "test8: file in table" \
        "${stem} exists but is not a row in the CLAUDE.md Instructions Reference table"
    fi
  done
}

# ---------------------------------------------------------------------------
# Test 9 — agent_roster_references
# Every hve-* agent type referenced by name in a command file must exist as
# .claude/agents/<name>.md. References are extracted as bare backticked
# tokens (`hve-foo`) — this excludes slash-command references (`/hve-foo`)
# and the `.claude-hve-tracking` path token, both of which are backticked
# with a different neighbour. Catches missing-agent regressions such as a
# command dispatching an agent type whose definition file was never added.
# ---------------------------------------------------------------------------
test9_agent_roster_references() {
  local -a tokens=()
  local token
  while IFS= read -r token; do
    [[ -n "${token}" ]] && tokens+=("${token}")
  done < <(grep -rhoE '`hve-[a-z-]+`' "${COMMANDS_DIR}"/*.md \
    | tr -d '`' | sort -u)

  if (( ${#tokens[@]} == 0 )); then
    _fail_inline "test9: references present" \
      "no backticked hve-* agent references found in command files"
    return
  fi

  for token in "${tokens[@]}"; do
    # A token that is itself a command file name is a command reference,
    # not an agent reference; skip it.
    if [[ -f "${COMMANDS_DIR}/${token}.md" ]]; then
      _ok_inline "test9: ${token} is a command name" "not an agent reference"
      continue
    fi
    if [[ -f "${AGENTS_DIR}/${token}.md" ]]; then
      _ok_inline "test9: ${token} resolves" "agent file exists"
    else
      _fail_inline "test9: ${token} resolves" \
        "command references \`${token}\` but ${AGENTS_DIR}/${token}.md is missing"
    fi
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
  for target in "${AGENTS_DIR}" "${COMMANDS_DIR}" "${INSTRUCTIONS_DIR}" \
    "${INTERNALS_MD}" "${CLAUDE_MD}" "${GITIGNORE}"; do
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
  run_test "Test 5: --subagent-model boilerplate drift" \
    test5_subagent_model_boilerplate
  run_test "Test 6: --friction-log boilerplate drift" \
    test6_friction_flag_boilerplate
  run_test "Test 7: Subagent Response Protocol structure" \
    test7_response_protocol_structure
  run_test "Test 8: CLAUDE.md Instructions Reference table sync" \
    test8_instructions_table_sync
  run_test "Test 9: agent roster references resolve" \
    test9_agent_roster_references

  finish
}

main "$@"
