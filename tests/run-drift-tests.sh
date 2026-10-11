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
#      {haiku, sonnet, opus, fable, inherit} and a name: matching its filename stem
#   2. internals.md sync     — docs/internals.md agent-table Model column
#      matches frontmatter (case-insensitive)
#   3. CLAUDE.md sync        — Model Selection prose does not claim a
#      different tier for any pinned agent it names
#   4. .gitignore hygiene    — credential patterns from the CLAUDE.md
#      security checklist are present
#   5. --subagent-model      — the boilerplate paragraph is byte-identical
#      across every command that carries it
#   6. (retired)             — the --friction-log block was deduplicated to a
#      single CLAUDE.md carrier; its uniqueness is now one spec row in
#      test 10. The number is left vacant so tests 7-13 keep their labels.
#   7. Response protocol     — every agent's `## Response Format` section
#      carries all six invariant lines of the Subagent Response Protocol
#      (structural greps over that section only, not byte-diff)
#   8. Instructions table    — CLAUDE.md Instructions Reference and
#      .claude/instructions/*.md agree in both directions
#   9. Agent roster refs     — every `hve-*` agent named in a command file
#      exists in .claude/agents/
#  10. Canonical blocks      — the other deliberately-duplicated blocks
#      (discovery stub, concurrent-writes, timestamp, test-count) are
#      byte-identical across their carriers
#  11. Instruction arrays    — HVE_INSTRUCTION_FILES agrees between
#      install.sh and tests/lib/instruction-files.sh
#  12. Dispatch targets      — every command declaring `Agent` in its
#      allowed-tools frontmatter names at least one backticked `hve-*`
#      agent, and each one resolves to .claude/agents/<name>.md
#  13. Prompt option sync    — every option token in an Arguments/Options/
#      Modes section of a .claude/prompts/ file resolves to a real option of
#      its mapped command (argument-hint or a body code span)
#  14. Reference resolution  — every ``per CLAUDE.md's `Section` section``
#      pointer under .claude/ resolves to a real CLAUDE.md heading
#  15. Behavioral presence   — every artifact-discovering command carries a
#      discovery reference (carrier floor, not equality)
#  16. Credential surfaces   — the six credential patterns restated in
#      install.sh (writes and global-mode echo), the install suite's own
#      array, README.md, and docs/installation.md all agree with CLAUDE.md's
#      Security Hygiene bullet, which is the source of truth. Covers the
#      copies that live outside test 10's canonical-block corpus.
#
set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly AGENTS_DIR="${REPO_ROOT}/.claude/agents"
readonly COMMANDS_DIR="${REPO_ROOT}/.claude/commands"
readonly INSTRUCTIONS_DIR="${REPO_ROOT}/.claude/instructions"
readonly PROMPTS_DIR="${REPO_ROOT}/.claude/prompts"
readonly INTERNALS_MD="${REPO_ROOT}/docs/internals.md"
readonly CLAUDE_MD="${REPO_ROOT}/CLAUDE.md"
readonly GITIGNORE="${REPO_ROOT}/.gitignore"
readonly VALID_MODELS="haiku sonnet opus fable inherit"

# Agents that carry the FULL Subagent Response Protocol (6 invariant lines).
# This is EVERY agent in .claude/agents/. The three prompt-builder sandbox
# agents (hve-prompt-evaluator, hve-prompt-tester, hve-prompt-updater) were
# previously excluded on the grounds that their reduced Response Format was
# intentional; the 2026-08-10 full-repo review found it was drift, not
# intent (II-01, II-02, II-03), so they are in scope as of the Phase 10
# remediation. There is no longer a licensed reduced format: an agent that
# omits a protocol part fails this test. This explicit list is the discovery
# idiom — no agent file names the protocol as a greppable string.
readonly FULL_PROTOCOL_AGENTS="hve-researcher hve-phase-implementor \
hve-plan-validator hve-rpi-validator hve-implementation-validator \
hve-pr-reviewer hve-prompt-evaluator hve-prompt-tester hve-prompt-updater"

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
# For each agent pinned to a concrete tier (haiku, sonnet, opus, or fable) in
# frontmatter, the Model Selection
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
    [[ "${fm_model}" == "haiku" || "${fm_model}" == "sonnet" \
       || "${fm_model}" == "opus" || "${fm_model}" == "fable" ]] || continue

    # hve-plan-validator -> "plan validator"
    human="${stem#hve-}"
    human="${human//-/ }"

    mentioned=0
    contradiction=""
    while IFS= read -r clause; do
      [[ "${clause}" == *"${human}"* ]] || continue
      mentioned=1
      for tier in haiku sonnet opus fable inherit; do
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
  for pattern in ".env" ".env.*" "*.pem" "*.key" "*.p12" "*.pfx"; do
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
# Test 6 — RETIRED (RL-03 / RO-03, 2026-08-15)
#
# This test asserted that the `--friction-log` paragraph was byte-identical
# across six command files. That duplication is exactly what RL-03 removed:
# the paragraph is now canonical in CLAUDE.md and each command carries a
# one-line pointer to it. The assertion inverted from "6 identical copies"
# to "exactly 1 carrier", which is the shape `CANONICAL_BLOCK_SPECS` already
# expresses — and whose corpus already includes CLAUDE.md, where the sole
# carrier now lives. The bespoke function was duplicated logic of test 10, so
# it was folded into the spec table (row `friction_capture`) rather than
# rewritten. Presence of the pointer in each command is covered by test 14
# (it resolves) and, for the discovery pointer, test 15 (it is there at all).
#
# The test number is left vacant so tests 7-13 keep their existing labels.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Test 7 — response_protocol_structure
# Each full-protocol agent must carry all six invariant lines of the
# Subagent Response Protocol. Structural greps (not byte-diff), because
# agents vary the status vocabulary (Status/Quality/Validation) and the exact
# wording of each item. See FULL_PROTOCOL_AGENTS for the in-scope set.
#
# The greps run against the `## Response Format` SECTION ONLY, not the whole
# file. Whole-file matching made two parts vacuous: `hve-researcher.md`
# carries "Up to 3 questions" inside its output template and
# `hve-prompt-updater.md` carried "Up to 3 deferred findings", so deleting the
# clarifying-questions part from the Response Format still passed. Section
# anchoring plus the tightened question and checklist patterns is what makes a
# missing part fail mechanically (Phase 10, Step 10.5).
# ---------------------------------------------------------------------------
test7_response_protocol_structure() {
  local stem file section
  for stem in ${FULL_PROTOCOL_AGENTS}; do
    file="${AGENTS_DIR}/${stem}.md"
    if [[ ! -f "${file}" ]]; then
      _fail_inline "test7: ${stem} present" \
        "expected agent file ${file} but not found"
      continue
    fi

    section="$(response_format_section "${file}")"
    if [[ -z "${section}" ]]; then
      _fail_inline "test7: ${stem} Response Format section" \
        "no '## Response Format' section found in ${stem}.md"
      continue
    fi

    _grep_invariant "${section}" "${stem}" "artifact-path line" \
      'One line: `?(Written|Updated):'
    _grep_invariant "${section}" "${stem}" "status line" \
      '(Status|Quality|Validation):'
    _grep_invariant "${section}" "${stem}" "7-bullet cap" \
      'Up to \**7\** bullet'
    _grep_invariant "${section}" "${stem}" "5-item checklist cap" \
      'Up to \**5\** checklist item'
    _grep_invariant "${section}" "${stem}" "3-question cap" \
      'Up to \**3\** clarifying question'
    _grep_invariant "${section}" "${stem}" "Full detail line" \
      'Full detail'
  done
}

# response_format_section <file>
# Print the body of <file>'s `## Response Format` section: every line after
# the heading up to (not including) the next level-2 heading. Empty output
# means the section is absent, which test 7 treats as a failure.
response_format_section() {
  local file="${1}"
  awk '
    /^## Response Format[[:space:]]*$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
  ' "${file}"
}

# _grep_invariant <section-text> <stem> <label> <ere>
# Assert <section-text> contains at least one line matching <ere>.
_grep_invariant() {
  local section="${1}"
  local stem="${2}"
  local label="${3}"
  local ere="${4}"
  if grep -qE "${ere}" <<<"${section}"; then
    _ok_inline "test7: ${stem} ${label}" "present"
  else
    _fail_inline "test7: ${stem} ${label}" \
      "no line matching /${ere}/ in ${stem}.md Response Format section"
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
# Test 10 — canonical_block_drift
# Tests 5 and 6 protect the --subagent-model and --friction-log paragraphs.
# The remediation deliberately duplicates several OTHER canonical blocks whose
# single source of truth is the implementation details doc; without a check
# they can diverge silently. Each spec names one block by a fixed-string line
# prefix plus the number of files expected to carry it, and asserts every
# occurrence is byte-identical to the first.
#
# Spec format: label|expected_carrier_count|mode|fixed-string line prefix
#   mode=identical — every carrier's line must be byte-identical to the first
#   mode=present   — carrier count only; use when the same guarantee is stated
#                    inside different surrounding sentences, so byte-identity
#                    would fail on legitimate variation
#
# A spec with expected_carrier_count=1 is a UNIQUENESS assertion, not a
# duplication one: the block was deduplicated to a single CLAUDE.md carrier
# and every other file points at it by name. Re-introducing a copy anywhere in
# the corpus raises the count and fails the row. Those rows are the RL-cluster
# replacements (RL-03 through RL-08); their pointers are checked by test 14.
# Corpus: .claude/commands/*.md, .claude/agents/*.md, .claude/prompts/*.md,
#         CLAUDE.md
# .claude/prompts/ is in the corpus because the paste-to-run prompt files carry
# byte-identical copies of command prose (e.g. the per-project memory-store
# sentence shared by hve-memory.md and checkpoint.md); without them in the
# corpus those copies can diverge silently.
# ---------------------------------------------------------------------------
readonly -a CANONICAL_BLOCK_SPECS=(
  'discovery_stub|1|identical|Phase commands discover their input artifacts from'
  'concurrent_writes|1|identical|**Concurrent writes**'
  'friction_capture|1|identical|accept an optional `--friction-log` flag'
  'security_checklist|1|identical|- **Secret exposure**: grep changed files for'
  'shell_stays_in_parent|1|identical|**Shell stays in the parent.**'
  'timestamp_started|2|identical|Started: [run `date -u'
  'timestamp_completed|2|identical|Completed: [same command at completion'
  'testcount_passed|2|identical|- `Tests: X passed, Y failed`'
  'testcount_na|2|identical|- `Tests: N/A'
  'testcount_notrun|2|identical|- `Tests: not run'
  'testcount_never|2|identical|Never write a count that did not come from'
  'simple_carveout_guarantee|2|present|still creating and updating the changes log and running the test gate'
  'test_baseline_semantics|2|present|pre-existing failures are noted, not blocking'
  'memory_store_scope|2|identical|Also write the most non-obvious decisions and patterns to the Claude Code native memory store'
)

# canonical_block_corpus — prints the search corpus, one path per line.
canonical_block_corpus() {
  local file
  for file in "${COMMANDS_DIR}"/*.md "${AGENTS_DIR}"/*.md "${PROMPTS_DIR}"/*.md; do
    if [[ -f "${file}" ]]; then
      echo "${file}"
    fi
  done
  echo "${CLAUDE_MD}"
}

# assert_canonical_block label expected_count mode prefix
# Discovers every corpus file containing <prefix>, then asserts (a) the
# carrier count matches <expected_count> and, when mode=identical, (b) each
# occurrence is byte-identical to the first. A carrier-count mismatch
# short-circuits: a block that vanished from a file is the signal, not the
# identity diff.
assert_canonical_block() {
  local label="${1}"
  local expected="${2}"
  local mode="${3}"
  local prefix="${4}"
  local file stem line canonical="" canonical_file=""
  local -a carriers=()

  while IFS= read -r file; do
    if grep -qF -- "${prefix}" "${file}"; then
      carriers+=("${file}")
    fi
  done < <(canonical_block_corpus)

  if (( ${#carriers[@]} == expected )); then
    _ok_inline "test10: ${label} carrier count" \
      "${#carriers[@]} file(s) carry the block (expected ${expected})"
  else
    _fail_inline "test10: ${label} carrier count" \
      "expected ${expected} file(s) carrying the ${label} block, got ${#carriers[@]}"
    return
  fi

  if [[ "${mode}" == "present" ]]; then
    return
  fi

  for file in "${carriers[@]}"; do
    stem="$(basename "${file}" .md)"
    line="$(extract_line "${file}" "${prefix}")"
    if [[ -z "${canonical}" ]]; then
      canonical="${line}"
      canonical_file="${stem}"
      _ok_inline "test10: ${label} ${stem} is canonical" "reference occurrence"
      continue
    fi
    if [[ "${line}" == "${canonical}" ]]; then
      _ok_inline "test10: ${label} ${stem} matches canonical" \
        "byte-identical to ${canonical_file}"
    else
      _fail_inline "test10: ${label} ${stem} matches canonical" \
        "${label} block differs from ${canonical_file}"
    fi
  done
}

test10_canonical_block_drift() {
  local spec label expected mode prefix
  for spec in "${CANONICAL_BLOCK_SPECS[@]}"; do
    IFS='|' read -r label expected mode prefix <<< "${spec}"
    assert_canonical_block "${label}" "${expected}" "${mode}" "${prefix}"
  done
}

# ---------------------------------------------------------------------------
# Test 11 — instruction_array_sync
#
# The instruction-file list is hand-duplicated in tests/lib/instruction-files.sh
# (the shared, sourceable list) and in install.sh (used to migrate pre-existing
# installs). Nothing derives one from the other, so adding a file to one and not
# the other is a silent divergence. The two arrays are formatted differently
# (one entry per line vs. several), so compare the SET of entries, not the text.
# ---------------------------------------------------------------------------

# extract_bash_array file array_name — prints the array's entries, one per
# line, sorted. Reads from `NAME=(` to the first line that is exactly `)`.
extract_bash_array() {
  local file="${1}" name="${2}"
  awk -v want="${name}" '
    $0 ~ "^(declare -a )?" want "=\\(" { collecting = 1; next }
    collecting && /^\)/ { exit }
    collecting {
      sub(/#.*/, "")
      for (i = 1; i <= NF; i++) { print $i }
    }
  ' "${file}" | sort
}

test11_instruction_array_sync() {
  local shared_list install_list
  shared_list="$(extract_bash_array "${REPO_ROOT}/tests/lib/instruction-files.sh" HVE_INSTRUCTION_FILES)"
  install_list="$(extract_bash_array "${REPO_ROOT}/install.sh" HVE_INSTRUCTION_FILES)"

  if [[ -z "${shared_list}" ]]; then
    _fail_inline "test11: shared array parses" \
      "extracted no entries from tests/lib/instruction-files.sh"
    return
  fi
  if [[ -z "${install_list}" ]]; then
    _fail_inline "test11: install.sh array parses" \
      "extracted no entries from install.sh"
    return
  fi

  if [[ "${shared_list}" == "${install_list}" ]]; then
    _ok_inline "test11: HVE_INSTRUCTION_FILES in sync" \
      "$(echo "${shared_list}" | wc -l | tr -d ' ') entries match across both files"
  else
    _fail_inline "test11: HVE_INSTRUCTION_FILES in sync" \
      "install.sh and tests/lib/instruction-files.sh disagree: $(
        diff <(echo "${shared_list}") <(echo "${install_list}") | tr '\n' ' '
      )"
  fi

  # Every listed file must also exist on disk.
  local fname
  while IFS= read -r fname; do
    [[ -z "${fname}" ]] && continue
    if [[ -f "${INSTRUCTIONS_DIR}/${fname}" ]]; then
      _ok_inline "test11: ${fname} exists" "found in .claude/instructions/"
    else
      _fail_inline "test11: ${fname} exists" \
        "listed in HVE_INSTRUCTION_FILES but missing from .claude/instructions/"
    fi
  done <<< "${shared_list}"
}

# ---------------------------------------------------------------------------
# Test 12 — dispatch_names_resolvable_agent
#
# Test 9 validates the agent tokens it finds, so a dispatch instruction that
# names NO agent at all has nothing to match and passes silently — that was
# the M-02 defect. Test 12 adds the missing non-empty requirement: every
# command declaring the standalone token `Agent` in its allowed-tools
# frontmatter must (a) backtick at least one `hve-*` agent name in its body
# and (b) have every such name resolve to .claude/agents/<name>.md.
#
# The dispatcher set is derived from frontmatter at run time, never
# hardcoded, so a newly-added dispatching command is covered automatically.
# ---------------------------------------------------------------------------

# command_dispatches_agent <file>
# Succeeds when the file's frontmatter allowed-tools line lists `Agent` as a
# standalone comma-separated token (so a future tool named e.g. AgentRunner
# does not match). Note: frontmatter_value cannot be reused here — its key
# strip pattern is /^[a-z]+:/, which does not cover the hyphenated key.
command_dispatches_agent() {
  local file="${1}"
  local tools tool
  tools="$(awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { exit }
    in_fm && index($0, "allowed-tools:") == 1 {
      val = $0
      sub(/^allowed-tools:[[:space:]]*/, "", val)
      print val
      exit
    }
  ' "${file}")"
  [[ -n "${tools}" ]] || return 1

  while IFS= read -r tool; do
    [[ "${tool}" == "Agent" ]] && return 0
  done < <(echo "${tools}" | tr ',' '\n' \
    | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  return 1
}

test12_dispatch_names_resolvable_agent() {
  local file stem token
  local -a dispatchers=()
  for file in "${COMMANDS_DIR}"/*.md; do
    if command_dispatches_agent "${file}"; then
      dispatchers+=("${file}")
    fi
  done

  if (( ${#dispatchers[@]} == 0 )); then
    _fail_inline "test12: dispatcher discovery" \
      "no command declares Agent in its allowed-tools frontmatter"
    return
  fi
  _ok_inline "test12: dispatcher discovery" \
    "${#dispatchers[@]} command(s) declare Agent in allowed-tools"

  local -a agent_tokens=()
  for file in "${dispatchers[@]}"; do
    stem="$(basename "${file}" .md)"
    agent_tokens=()
    while IFS= read -r token; do
      [[ -n "${token}" ]] || continue
      # A token that is itself a command file name is a slash-command
      # reference, not an agent reference (same carve-out as test9).
      [[ -f "${COMMANDS_DIR}/${token}.md" ]] && continue
      agent_tokens+=("${token}")
    done < <(grep -ohE '`hve-[a-z-]+`' "${file}" | tr -d '`' | sort -u)

    if (( ${#agent_tokens[@]} == 0 )); then
      _fail_inline "test12: ${stem} names an agent" \
        "declares Agent in allowed-tools but its body backticks no \`hve-*\` agent name"
      continue
    fi
    _ok_inline "test12: ${stem} names an agent" \
      "${#agent_tokens[@]} token(s): ${agent_tokens[*]}"

    for token in "${agent_tokens[@]}"; do
      if [[ -f "${AGENTS_DIR}/${token}.md" ]]; then
        _ok_inline "test12: ${stem} -> ${token}" "agent file exists"
      else
        _fail_inline "test12: ${stem} -> ${token}" \
          "${stem} dispatches \`${token}\` but ${AGENTS_DIR}/${token}.md is missing"
      fi
    done
  done
}

# ---------------------------------------------------------------------------
# Test 13 — prompt_option_sync
#
# Each .claude/prompts/ file is the paste-to-run twin of one command. An option
# documented in the prompt but absent from the command is a phantom feature:
# users invoke it and nothing implements it.
#
# Both halves of the check are deliberately narrow, and neither narrowing is
# optional:
#
#   Extraction is SECTION-SCOPED to "## Arguments", "## Options" and "## Modes"
#   blocks, and within those to leading tokens of list lines. Three shapes
#   count: "- \`--flag\`", "- \`bare-token\`" and "- **BoldToken**". Anchoring on
#   "- \`--" alone would miss bare tokens and bold mode names, which are exactly
#   the phantom-option forms this test exists to catch. Dropping the section
#   scope would sweep in list lines that are not options at all — the bold
#   lines under "## What it checks" in doc-ops.md are dimension descriptions.
#
#   Resolution requires the token in the mapped command's frontmatter
#   argument-hint, or failing that inside a backtick code span in the command
#   body. A whole-file grep would false-pass: "suggestions" appears in hve.md
#   prose and "## Phase 3 — Continue" is a heading in hve-memory.md, so a
#   phantom \`suggest\` option and a phantom **Continue** mode would both
#   resolve against text that implements nothing.
#
# One-directional by design: a command option missing from the prompt is a docs
# gap, not a phantom feature, so only prompt -> command is enforced.
#
# Map format: prompt-file|command-file
# ---------------------------------------------------------------------------
readonly -a PROMPT_COMMAND_MAP=(
  'rpi.md|hve.md'
  'pull-request.md|hve-pr-review.md'
  'checkpoint.md|hve-memory.md'
  'doc-ops.md|hve-doc-ops.md'
  'task-challenge.md|hve-challenge.md'
  'prompt-build.md|hve-prompt-builder.md'
)

# prompt_option_tokens <file>
# Prints the leading token of every option line inside an Arguments/Options/
# Modes section, one per line, sorted and de-duplicated. Anything after the
# first whitespace inside the token span is description text, not the token.
prompt_option_tokens() {
  awk '
    /^## (Arguments|Options|Modes)([[:space:]]|$)/ { in_section = 1; next }
    /^## / { in_section = 0 }
    !in_section { next }
    {
      token = ""
      if (match($0, /^- `[^`]+`/)) {
        token = substr($0, RSTART + 3, RLENGTH - 4)
      } else if (match($0, /^- \*\*[^*]+\*\*/)) {
        token = substr($0, RSTART + 4, RLENGTH - 6)
      }
      if (token == "") { next }
      sub(/[[:space:]].*/, "", token)
      if (token ~ /^(--)?[A-Za-z][A-Za-z0-9_-]*$/) { print token }
    }
  ' "${1}" | sort -u
}

# code_span_contents <file>
# Prints the contents of every backtick code span, one per line. Splitting per
# line keeps the pairing honest: a span never straddles a newline, so text
# sitting between two unrelated spans cannot masquerade as one.
code_span_contents() {
  awk '
    {
      n = split($0, parts, "`")
      for (i = 2; i <= n; i += 2) { print parts[i] }
    }
  ' "${1}"
}

# option_resolves <command_file> <token>
# True when the token appears in the command frontmatter argument-hint, or
# inside a backtick code span in the command body. Prose and headings do not
# resolve an option.
option_resolves() {
  local command_file="${1}" token="${2}" hint
  hint="$(frontmatter_value "${command_file}" "argument-hint")"
  # frontmatter_value only strips unhyphenated keys, so drop the key here.
  hint="${hint#argument-hint:}"
  if [[ -n "${hint}" && "${hint}" == *"${token}"* ]]; then
    return 0
  fi
  code_span_contents "${command_file}" | grep -qF -- "${token}"
}

test13_prompt_option_sync() {
  local entry prompt_name command_name prompt_file command_file token
  local -a tokens=()
  for entry in "${PROMPT_COMMAND_MAP[@]}"; do
    IFS='|' read -r prompt_name command_name <<< "${entry}"
    prompt_file="${PROMPTS_DIR}/${prompt_name}"
    command_file="${COMMANDS_DIR}/${command_name}"

    if [[ ! -f "${prompt_file}" ]]; then
      _fail_inline "test13: ${prompt_name} present" \
        "mapped prompt file missing: ${prompt_file}"
      continue
    fi
    if [[ ! -f "${command_file}" ]]; then
      _fail_inline "test13: ${command_name} present" \
        "mapped command file missing: ${command_file}"
      continue
    fi

    tokens=()
    while IFS= read -r token; do
      [[ -n "${token}" ]] && tokens+=("${token}")
    done < <(prompt_option_tokens "${prompt_file}")

    if (( ${#tokens[@]} == 0 )); then
      _ok_inline "test13: ${prompt_name} option tokens" \
        "no Arguments/Options/Modes option lines to check"
      continue
    fi

    for token in "${tokens[@]}"; do
      if option_resolves "${command_file}" "${token}"; then
        _ok_inline "test13: ${prompt_name} ${token}" \
          "implemented in ${command_name}"
      else
        _fail_inline "test13: ${prompt_name} ${token}" \
          "${prompt_name} documents ${token} but ${command_name} implements no such option"
      fi
    done
  done
}

# ---------------------------------------------------------------------------
# Test 14 — reference_resolution
#
# Deduplicating shared prose into CLAUDE.md replaces one failure mode (copies
# drift apart) with another (a pointer outlives the section it names). Nothing
# else in this suite catches a dangling pointer, so every reference written in
# the fixed construction
#
#     per CLAUDE.md's `Section Name` section
#
# must resolve to a real `##`/`###` heading in CLAUDE.md. The backticks are
# what make extraction a matter of matching a delimiter rather than parsing
# prose, which is why the construction is fixed rather than free-form.
#
# Heading comparison is a literal string equality against the parsed heading
# list, not a regex match, so section names containing regex metacharacters
# ("Artifact Discovery & Relevance") need no escaping.
# ---------------------------------------------------------------------------
readonly REFERENCE_PATTERN="per CLAUDE\.md's \`[^\`]+\` section"
readonly REFERENCE_OPEN="per CLAUDE.md's \`"
readonly REFERENCE_CLOSE="\` section"

# claude_md_headings — prints every CLAUDE.md heading of level 2 or deeper,
# heading text only, one per line.
claude_md_headings() {
  awk '/^##+[[:space:]]/ {
    sub(/^#+[[:space:]]+/, "")
    print
  }' "${CLAUDE_MD}"
}

test14_reference_resolution() {
  local -a headings=()
  local heading match section found

  while IFS= read -r heading; do
    [[ -n "${heading}" ]] && headings+=("${heading}")
  done < <(claude_md_headings)

  if (( ${#headings[@]} == 0 )); then
    _fail_inline "test14: CLAUDE.md headings parse" \
      "no '## ' headings extracted from ${CLAUDE_MD}"
    return
  fi

  local -a matches=()
  while IFS= read -r match; do
    [[ -n "${match}" ]] && matches+=("${match}")
  done < <(grep -hoE -- "${REFERENCE_PATTERN}" \
    "${COMMANDS_DIR}"/*.md "${AGENTS_DIR}"/*.md "${PROMPTS_DIR}"/*.md \
    2>/dev/null | sort -u)

  if (( ${#matches[@]} == 0 )); then
    _fail_inline "test14: pointers present" \
      "no \`per CLAUDE.md's <Section> section\` pointers found under .claude/"
    return
  fi
  _ok_inline "test14: pointers present" \
    "${#matches[@]} distinct section pointer(s) under .claude/"

  for match in "${matches[@]}"; do
    section="${match#"${REFERENCE_OPEN}"}"
    section="${section%"${REFERENCE_CLOSE}"}"
    found=0
    for heading in "${headings[@]}"; do
      if [[ "${heading}" == "${section}" ]]; then
        found=1
        break
      fi
    done
    if (( found == 1 )); then
      _ok_inline "test14: '${section}' resolves" "matches a CLAUDE.md heading"
    else
      _fail_inline "test14: '${section}' resolves" \
        "pointers name '${section}' but CLAUDE.md has no such heading"
    fi
  done
}

# ---------------------------------------------------------------------------
# Test 15 — behavioral_presence
#
# Every other test in this suite checks that duplicated text agrees with
# itself. None checks that a documented behavior is actually present in the
# command that needs it — the gap RO-03 named. Test 15 asserts presence of the
# behavior, not consistency of its wording: each command that discovers
# tracking artifacts must carry the discovery pointer, so a command cannot
# silently ship without the branch-tiebreak and ask-on-ambiguity rule (the
# FC-01 defect in hve-implement).
#
# The carrier count is a FLOOR, not an equality. A seventh discovering command
# added later is a legitimate addition, not a drift regression, and must not
# red the suite; a command that loses its pointer still fails on its own row.
#
# ASSERTION 2 asserts the other half of the discovery convention: research and
# details are RECONSTRUCTIBLE inputs, so a command that consumes one must be
# able to proceed without it by recording the skip, never by hard-stopping and
# never by silently continuing. The mechanical proxy is the recorded-skip
# token the convention itself prescribes — `<Input>: none — [reason]` — which
# is the artifact a later phase reads to learn the input was absent by design.
# A command that drops the branch loses the token, so the row goes red.
# Carrier count is a floor here too, for the same reason as assertion 1.
# ---------------------------------------------------------------------------
readonly DISCOVERY_REFERENCE="per CLAUDE.md's \`Artifact Discovery & Relevance\` section"
readonly DISCOVERING_COMMANDS="hve-plan hve-implement hve-review hve-challenge \
hve-memory"
readonly DISCOVERY_CARRIER_FLOOR=5

readonly RECORD_SKIP_MARKER=": none — [reason]"
readonly RECONSTRUCTIBLE_CONSUMERS="hve-plan hve-implement hve-review"
readonly RECORD_SKIP_CARRIER_FLOOR=3

test15_behavioral_presence() {
  local stem file
  local discovery_carriers=0

  for stem in ${DISCOVERING_COMMANDS}; do
    file="${COMMANDS_DIR}/${stem}.md"
    if [[ ! -f "${file}" ]]; then
      _fail_inline "test15: ${stem} present" \
        "expected command file ${file} but not found"
      continue
    fi
    if grep -qF -- "${DISCOVERY_REFERENCE}" "${file}"; then
      _ok_inline "test15: ${stem} discovery reference" "present"
      discovery_carriers=$(( discovery_carriers + 1 ))
    else
      _fail_inline "test15: ${stem} discovery reference" \
        "${stem}.md discovers tracking artifacts but carries no \`${DISCOVERY_REFERENCE}\` pointer"
    fi
  done

  if (( discovery_carriers >= DISCOVERY_CARRIER_FLOOR )); then
    _ok_inline "test15: discovery carrier floor" \
      "${discovery_carriers} command(s) carry the pointer (floor ${DISCOVERY_CARRIER_FLOOR})"
  else
    _fail_inline "test15: discovery carrier floor" \
      "expected >= ${DISCOVERY_CARRIER_FLOOR} carriers, got ${discovery_carriers}"
  fi

  # Assertion 2 — reconstructible-input consumers carry a record-skip branch.
  local skip_carriers=0

  for stem in ${RECONSTRUCTIBLE_CONSUMERS}; do
    file="${COMMANDS_DIR}/${stem}.md"
    if [[ ! -f "${file}" ]]; then
      _fail_inline "test15: ${stem} present" \
        "expected command file ${file} but not found"
      continue
    fi
    if grep -qF -- "${RECORD_SKIP_MARKER}" "${file}"; then
      _ok_inline "test15: ${stem} record-skip branch" "present"
      skip_carriers=$(( skip_carriers + 1 ))
    else
      _fail_inline "test15: ${stem} record-skip branch" \
        "${stem}.md consumes a reconstructible input but carries no \`<Input>${RECORD_SKIP_MARKER}\` record-skip branch"
    fi
  done

  if (( skip_carriers >= RECORD_SKIP_CARRIER_FLOOR )); then
    _ok_inline "test15: record-skip carrier floor" \
      "${skip_carriers} command(s) carry the branch (floor ${RECORD_SKIP_CARRIER_FLOOR})"
  else
    _fail_inline "test15: record-skip carrier floor" \
      "expected >= ${RECORD_SKIP_CARRIER_FLOOR} carriers, got ${skip_carriers}"
  fi
}

# ---------------------------------------------------------------------------
# Test 16 — credential-pattern surfaces agree with CLAUDE.md
#
# The six credential patterns are restated literally in ten places across
# install.sh, the docs, and the test suites. Test 4 checks only that the repo
# .gitignore carries them; canonical_block_corpus() (test 10) never walks
# README.md, docs/, or install.sh, so every copy outside .claude/ was
# previously unguarded. CLAUDE.md's Security Hygiene bullet is the source of
# truth: this test parses the set from there and holds every other surface to
# it, in both directions where the surface is machine-extractable.
# ---------------------------------------------------------------------------

# Surfaces that restate the patterns as prose. Presence-checked only: the
# wording around them varies, so an exact set comparison is not available.
readonly CREDENTIAL_PROSE_SURFACES="README.md docs/installation.md"

# extract_canonical_credentials — prints the canonical set, one per line,
# parsed from CLAUDE.md's `.gitignore hygiene` bullet.
extract_canonical_credentials() {
  grep -F '.gitignore hygiene' "${CLAUDE_MD}" \
    | grep -oE '`[^`]+`' \
    | tr -d '`' \
    | grep -v 'gitignore hygiene' || true
}

# _assert_credential_set label expected actual
# Compares two newline-separated pattern lists as sorted sets.
_assert_credential_set() {
  local label="${1}" expected="${2}" actual="${3}"
  local exp_sorted act_sorted
  exp_sorted="$(printf '%s\n' "${expected}" | sort)"
  act_sorted="$(printf '%s\n' "${actual}" | sort)"
  if [[ "${exp_sorted}" == "${act_sorted}" ]]; then
    _ok_inline "${label}" "matches CLAUDE.md's $(printf '%s\n' "${expected}" | grep -c .) pattern(s)"
  else
    # Flatten via tr, never an unquoted expansion: the patterns are globs
    # (`*.pem`, `*.key`), so word-splitting them would pathname-expand each
    # one against the working directory and print whatever happened to match.
    _fail_inline "${label}" \
      "drifted from CLAUDE.md — expected [$(printf '%s' "${exp_sorted}" | tr '\n' ' ')], got [$(printf '%s' "${act_sorted}" | tr '\n' ' ')]"
  fi
}

test16_credential_surface_sync() {
  local canonical canonical_count pattern surface file
  canonical="$(extract_canonical_credentials)"
  canonical_count="$(printf '%s\n' "${canonical}" | grep -c . || true)"

  if (( canonical_count == 0 )); then
    _fail_inline "test16: canonical set parses" \
      "no patterns extracted from ${CLAUDE_MD} '.gitignore hygiene' bullet"
    return
  fi
  _ok_inline "test16: canonical set parses" \
    "${canonical_count} pattern(s) from CLAUDE.md"

  # install.sh writes the rules through add_ignore. Exact set comparison.
  local installer_written
  installer_written="$(grep -oE "add_ignore '[^']+'" "${REPO_ROOT}/install.sh" \
    | sed "s/add_ignore '//; s/'\$//" \
    | grep -v 'claude-hve-tracking' || true)"
  _assert_credential_set "test16: install.sh add_ignore set" \
    "${canonical}" "${installer_written}"

  # install.sh also echoes the rules for the user in --global mode. That block
  # is plain text, so nothing but this test keeps it in step with the writes.
  local installer_echoed
  installer_echoed="$(grep -oE 'echo "       [^"]+"' "${REPO_ROOT}/install.sh" \
    | sed 's/echo "       //; s/"$//' \
    | grep -vE '^#| ' \
    | grep -v 'claude-hve-tracking' || true)"
  _assert_credential_set "test16: install.sh global-mode echo set" \
    "${canonical}" "${installer_echoed}"

  # The install suite asserts against its own hardcoded array; if that array
  # drifts, the suite passes while testing the wrong thing.
  local suite_array
  suite_array="$(grep -oE "credential_rules=\([^)]*\)" "${REPO_ROOT}/tests/run-install-tests.sh" \
    | sed "s/credential_rules=(//; s/)\$//" \
    | tr -d "'" \
    | tr ' ' '\n' \
    | grep -v '^$' || true)"
  _assert_credential_set "test16: run-install-tests.sh credential_rules array" \
    "${canonical}" "${suite_array}"

  # Prose surfaces: presence only.
  for surface in ${CREDENTIAL_PROSE_SURFACES}; do
    file="${REPO_ROOT}/${surface}"
    if [[ ! -f "${file}" ]]; then
      _fail_inline "test16: ${surface} present" "expected ${file} but not found"
      continue
    fi
    local missing=""
    while IFS= read -r pattern; do
      [[ -z "${pattern}" ]] && continue
      grep -qF -- "${pattern}" "${file}" || missing="${missing} ${pattern}"
    done <<< "${canonical}"
    if [[ -z "${missing}" ]]; then
      _ok_inline "test16: ${surface} names every pattern" \
        "all ${canonical_count} present"
    else
      _fail_inline "test16: ${surface} names every pattern" \
        "missing:${missing}"
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
    "${PROMPTS_DIR}" "${INTERNALS_MD}" "${CLAUDE_MD}" "${GITIGNORE}"; do
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
  # Test 6 is retired; see the RETIRED banner above.
  run_test "Test 7: Subagent Response Protocol structure" \
    test7_response_protocol_structure
  run_test "Test 8: CLAUDE.md Instructions Reference table sync" \
    test8_instructions_table_sync
  run_test "Test 9: agent roster references resolve" \
    test9_agent_roster_references
  run_test "Test 10: canonical block drift" \
    test10_canonical_block_drift
  run_test "Test 11: instruction array sync" \
    test11_instruction_array_sync
  run_test "Test 12: dispatching commands name a resolvable agent" \
    test12_dispatch_names_resolvable_agent
  run_test "Test 13: prompt-file options exist in the mapped command" \
    test13_prompt_option_sync
  run_test "Test 14: CLAUDE.md section references resolve" \
    test14_reference_resolution
  run_test "Test 15: documented behaviors present in their consumers" \
    test15_behavioral_presence
  run_test "Test 16: credential-pattern surfaces agree with CLAUDE.md" \
    test16_credential_surface_sync

  finish
}

main "$@"
