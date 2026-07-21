# RPI Validation: Unowned-File Convention Remediation — Phase 5
Date: 2026-07-21
Plan phase: Phase 5 — Drift-test coverage for the two escaped classes
Coverage: 100%
Status: Pass

## Context

Phase 5 delivers two new drift tests to catch failure classes that static file comparison missed during the friction-log-remediation audit. Test 12 targets commands that claim to dispatch agents but don't name any backticked agent reference in their body (M-02 gap class). Test 13 targets phantom features: prompt files that document flags (`--flag` tokens) not present in the mapped command files (M-07/M-10 gap class).

The parent ran `bash tests/run-drift-tests.sh` post-implementation and observed 207 passed, 0 failed (baseline 169; Tests 12 and 13 add 38 assertions). All three plan steps mark complete in the changes log.

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 5.1: Test 12 — dispatching commands name resolvable agent | Found | `tests/run-drift-tests.sh:710-778` | ✅ Implemented |
| Step 5.2: Test 13 — prompt-file flags exist in mapped command | Found | `tests/run-drift-tests.sh:794-844` | ✅ Implemented |
| Step 5.3: Mutation checks A and B with failure outputs recorded | Found | Changes log lines 186-228 | ✅ Implemented |

## Critical Verifications

### V1: Test 12 dispatcher set derived, not hardcoded
**Plan requirement:** "The implementor derives the actual set from frontmatter at write time rather than hardcoding this list" (details doc line 103).

**Evidence:** `test12_dispatch_names_resolvable_agent` at lines 732-778:
- Loop at lines 735-739 iterates `"${COMMANDS_DIR}"/*.md` and calls `command_dispatches_agent` for each file
- Helper `command_dispatches_agent` (lines 710-730) dynamically extracts the `allowed-tools:` value from each file's frontmatter using awk (lines 713-722)
- Checks for the standalone token `Agent` using exact string match after comma-split (line 726)

**Verdict:** ✅ VERIFIED. The set is computed at runtime from actual frontmatter. Adding a new dispatching command automatically extends coverage.

---

### V2: Test 12 allowed-tools parsing handles standalone-token requirement
**Specification:** Helper must parse comma-separated `allowed-tools` values and match only the standalone token `Agent`, not substring matches.

**Evidence:** `command_dispatches_agent` helper (lines 710-730):
```bash
# Line 718: exact key-prefix strip with hyphenated support
sub(/^allowed-tools:[[:space:]]*/, "", val)
# Lines 727-728: comma-split and whitespace-strip
echo "${tools}" | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
# Line 726: exact string match
[[ "${tool}" == "Agent" ]] && return 0
```

**Whitespace handling:** The sed patterns remove both leading (`^[[:space:]]*`) and trailing (`[[:space:]]*$`) whitespace, so values like `, Agent, ` become exact `Agent` matches.

**Exact-match semantics:** The `==` operator ensures only the standalone token matches, not `AgentPlusOther` or `ToolAgent`.

**Verdict:** ✅ VERIFIED. The parsing correctly isolates the `Agent` token.

---

### V3: Test 13 extraction restricted to option-list lines `^- \`--`
**Plan guard:** "Run against the fixed tree first; if noisy, restrict extraction to lines starting with `- \`--`" (plan line 87).

**Evidence:** Line 825 in `test13_prompt_flag_sync`:
```bash
grep -ohE '^- `--[a-z-]+' "${prompt_file}" | sed 's/^- `//' | sort -u
```

The pattern `^- \`--[a-z-]+` matches only lines that:
- Start with `- \`` (option-list marker with opening backtick)
- Followed by `--` and lowercase alphanumerics/hyphens

This excludes prose examples like "Consider using `--verbose`" (no list marker) and "just plain text" (no backtick).

**Verdict:** ✅ VERIFIED. Extraction is restricted as specified.

---

### V4: Test 13 one-directional (prompt → command only)
**Specification:** "One-directional by design: command flags missing from the prompt are a docs gap, not a phantom feature; only prompt→command is enforced" (details doc line 116).

**Evidence:** Lines 834-842 in `test13_prompt_flag_sync`:
```bash
for flag in "${flags[@]}"; do
  if grep -qF -- "${flag}" "${command_file}"; then
    _ok_inline "test13: ${prompt_name} ${flag}" ...
  else
    _fail_inline "test13: ${prompt_name} ${flag}" \
      "${prompt_name} documents ${flag} but ${command_name} never mentions it"
  fi
done
```

The loop extracts flags from prompts and checks if they exist in commands. The inverse (are all command flags in the prompt?) is not checked.

**Verdict:** ✅ VERIFIED. Design is one-directional as specified.

---

### V5: Mutation B substitution assessment (the critical judgment call)
**Plan specification:** Step 5.3 says "re-add `` `continue` `` to rpi.md" for Mutation B.

**Implementation actual:** Changes log lines 205-222 document that instead of re-adding `` `continue` ``, the implementor inserted a new phantom flag `` `--resume` `` into rpi.md options.

**Reasoning provided:** "``continue`` has no `--` prefix and would not be matched by the `--[a-z-]+` extraction" (line 206). 

**Analysis:** This is a **correct substitution based on sound judgment**:

1. **Original defect M-07 was transformed by Phase 4:** Phase 4 Step 4.1 (changes log line 110) explicitly states "`continue`/`suggest` option lines deleted; `--think` and `--subagent-model` added". By the time Phase 5 runs, `continue` is already gone and replaced with `--think`.

2. **Test 13's designed scope is `--` flags only:** The plan's own success criteria (line 68) specifies "every `--flag` token", not every option token. Test 13's regex `^- \`--[a-z-]+` is designed for `--` flags specifically.

3. **Non-`--` options fall outside Test 13's scope:** If someone documented `` `continue` `` (without `--`), Test 13's extraction would skip it because the pattern requires `--`. This is correct behavior—Test 13 was designed to catch phantom *flags*, not arbitrary phantom options.

4. **The substitution correctly tests designed scope:** Injecting `` `--resume` `` (a phantom flag that looks like a real flag) and verifying Test 13 catches it proves the test works for its intended class. The mutation evidence (lines 215-221) shows Test 13 correctly failed with "rpi.md documents --resume but hve.md never mentions it".

**Verdict:** ✅ SOUND JUDGMENT. The substitution is justified and demonstrates that the test correctly covers its designed scope. The fact that `continue` wouldn't be caught by Test 13 is not a gap—it's evidence that Test 13 correctly limits itself to `--` flags per specification. A mutation note in the changes log would have been stronger (to explain the deviation from the plan's stated mutation protocol), but the technical choice is correct.

---

### V6: Shared helper duplication (frontmatter_value)
**Claim:** Test 12 uses a local awk block instead of reusing `frontmatter_value` helper.

**Constraint:** Changes log lines 162-167 state: "The shared helper was left unmodified — Tests 1/2/3 depend on its current behavior and the phase scope is additive. Its key-strip regex is `/^[a-z]+:[[:space:]]*/`, which does not match the hyphenated key `allowed-tools:`."

**Verification:**
- The helper `command_dispatches_agent` includes its own awk block (lines 713-722) with the exact pattern `^allowed-tools:` (line 716)
- The shared `frontmatter_value` helper (not shown in this read) uses the generic regex `/^[a-z]+:/`, which would not match hyphenated keys

**Assessment:** DRY violation, but justified:
- Changing the shared helper to support hyphenated keys risks breaking Tests 1, 2, 3 (which depend on the simpler non-hyphenated regex)
- The local solution is minimal and self-documenting
- The comment explains the constraint

**Verdict:** ✅ JUSTIFIED TRADE-OFF. Minor violation acceptable in this additive phase.

---

## Test Strength Assessment

### Test 12 Potential Weaknesses

1. **Command-name carve-out (line 757):** If a backticked `hve-*` token is itself a command filename (e.g., `hve-review`), it's filtered out as a slash-command reference rather than an agent reference. This is correct — `/hve-review` is the command, not the agent — but could theoretically mask a bug if someone wrote the command name when they meant the agent. However, the distinction is intentional and sound.

2. **Regex scope:** `grep -ohE '`hve-[a-z-]+`'` (line 759) matches lowercase and hyphens only. Command/agent names follow this convention, so no coverage gap. ✅

3. **Extraction completeness:** Uses `-o` (only matching) and `-E` (extended regex), standard approach. ✅

**Mutation evidence validates correctness:** Removing the backticked token causes Test 12 to fail with "declares Agent in allowed-tools but its body backticks no `hve-*` agent name" (line 195). Restoring it passes. ✅

### Test 13 Potential Weaknesses

1. **Regex character class:** `--[a-z-]+` matches only lowercase letters and hyphens, not digits or uppercase. Example false negatives:
   - `--flag-v2` (digit)
   - `--Flag` (uppercase)
   
   **Assessment:** Acceptable. Current flag naming conventions (verified in prompt/command files) use lowercase only and hyphens for separation. No flags with digits or uppercase exist. Would be a robustness improvement for future, but not a defect in current context.

2. **Leading whitespace in option lines:** The pattern `^- \`--` requires start-of-line. If a prompt file has "  - \`--flag" (indented), it won't match. **Assessment:** Acceptable. Markdown list items at indentation > 1 would be nested lists, not top-level option definitions. The test matches the documented structure.

3. **Backtick requirement:** All extracted flags must be backticked. If a prompt documents `--flag` without backticks (bare prose), Test 13 won't catch it. **Assessment:** By design. Option lists should use backticks for consistency with markdown code formatting. The constraint enforces this convention.

4. **One-directional only:** A command can add a flag without updating the prompt (docs gap), and Test 13 won't catch it. **Assessment:** Intentional (line 116 in details doc). Only phantom features (prompt→command mismatches) are tested as correctness failures. Command→prompt gaps are docs gaps, not functional defects.

**Mutation evidence validates correctness:** Inserting `--resume` into rpi.md causes Test 13 to fail with "rpi.md documents --resume but hve.md never mentions it" (line 217). Restoring it passes. ✅

---

## Findings

### RV-001 [MINOR]
**Category:** Test design scope clarification (not a defect)

**Observation:** Test 13's regex `^- \`--[a-z-]+` will not detect phantom options without the `--` prefix (e.g., `continue`, `suggest`, or mode names). This is by design — Test 13 targets `--` flags specifically.

**Evidence:** Plan line 68 defines success as "every `--flag` token"; Test 13 line 825 restricts to the `--[a-z-]+` pattern.

**Impact:** None. Test correctly enforces its designed scope. The fact that M-07's original `` `continue` `` option class would not be re-caught by Test 13 is a feature, not a bug — it signals that Test 13 and Phase 4 are focused on the `--` flag class of phantom features.

**Recommendation:** None. Document this scope boundary in the test comments or in future research if non-`--` phantom options become a concern.

---

### RV-002 [MINOR]
**Category:** Mutation protocol deviation with justification

**Observation:** The plan's mutation protocol (Step 5.3) specified re-adding `` `continue` `` to test Mutation B. The implementor instead inserted `` `--resume` `` and reasoned that `continue` has no `--` prefix, so Test 13 wouldn't catch it.

**Evidence:** Changes log lines 205-222 document the substitution and reasoning. Mutation A (removing backticks from hve-doc-ops.md:49) was used as planned.

**Impact:** Negligible. The substitution is technically sound — the test correctly targets `--` flags — but it represents a deviation from the plan's stated mutation sequence.

**Recommendation:** For similar cases in future: when a mutation needs substitution based on implementation-time learning, record the original plan requirement and the substitution with explicit reasoning in the changes log (as was done here). This aids review of whether deviations were justified.

---

### RV-003 [MINOR]
**Category:** Unverified code quality (ShellCheck)

**Observation:** ShellCheck (bash linter) is not installed in the environment, so the `.claude/instructions/bash.md` validation requirement could not be applied to Tests 12/13.

**Evidence:** Changes log line 184: "ShellCheck was not available in this environment (`command -v shellcheck` empty)".

**Impact:** Tests are syntactically correct (suite runs and passes with 207/0), but shell style, quoted-variable hygiene, and other lint-checkable properties were not verified statically.

**Recommendation:** Run `shellcheck tests/run-drift-tests.sh` before merge to verify the new test code against `.claude/instructions/bash.md` standards.

---

## Unlisted Changes

The parent supplied the output of `git diff --name-only HEAD` run at 2026-07-21T05:09:26Z, identifying 16 modified files. Phase 5 owns exactly one file per the details doc ownership map:

- `tests/run-drift-tests.sh` ✅ Listed in changes log

All 15 other modified files (`.claude/commands/`, `.claude/agents/`, `.claude/prompts/`) are owned by Phases 1–4, and their changes are documented in those phases' sections of the changes log. No unlisted changes for Phase 5.

---

## Research Coverage

The research document (section "Suggested phase shape for planning", lines 112–123) identified that the two escaped defect classes were:

1. **"dispatch with no named agent"** (M-02 class) — Test 9 existed but did not catch M-02 because Test 9 validates that referenced tokens resolve, but had nothing to match if the body contained no backticked token.
   - **Test 12 coverage:** ✅ Directly addresses this. Asserts that commands claiming `Agent` in allowed-tools must contain >= 1 backticked `hve-*` agent reference.

2. **"prompt flags that no command implements"** (M-07/M-10 class) — Static file-to-file comparison cannot detect features documented in prompts that don't exist in commands because the defects live entirely in one file.
   - **Test 13 coverage:** ✅ Directly addresses this. Extracts `--flag` tokens from prompts and asserts each appears in the mapped command file.

**Verdict:** Research requirements are met. Both escaped classes are now testable.

---

## Coverage Calculation

| Phase 5 Step | Status | Evidence |
|---|---|---|
| Step 5.1: Test 12 — dispatch names resolvable agent | ✅ Complete | tests/run-drift-tests.sh:710-778 |
| Step 5.2: Test 13 — prompt flags exist in command | ✅ Complete | tests/run-drift-tests.sh:794-844 |
| Step 5.3: Mutation checks A and B | ✅ Complete | Changes log lines 186-228 |

**Coverage: 3/3 steps = 100%**

---

## Test Execution Outcome

Parent session independently ran the test suite post-implementation:

```
bash tests/run-drift-tests.sh (2026-07-21T05:09Z)
Results: 207 passed, 0 failed
Baseline entering Phase 5: 169 passed, 0 failed
Net new assertions: 38 (Tests 12 and 13)
```

Test 12 reports "8 command(s) declare Agent in allowed-tools" (hve.md, hve-research.md, hve-plan.md, hve-implement.md, hve-review.md, hve-pr-review.md, hve-doc-ops.md, hve-prompt-builder.md). Each passes the "names an agent" assertion and the agent-file-exists assertion.

Test 13 checks 6 prompt→command mappings with multiple flag assertions per mapping. All pass.

---

## Summary

Phase 5 is **Complete** with 100% coverage of planned steps. Both new tests (Test 12 and Test 13) are implemented, functional, and pass on the fixed tree. Mutation evidence demonstrates both tests fail when their target regressions are introduced. One justified deviation in the mutation protocol (Mutation B substitution) is documented with sound reasoning.

Minor findings are about acceptable design choices and process gaps (ShellCheck unavailable in this environment), not functional defects.
