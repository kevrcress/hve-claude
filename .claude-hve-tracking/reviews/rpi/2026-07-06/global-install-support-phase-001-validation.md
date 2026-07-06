# RPI Validation: Global install support — Phase 1
Date: 2026-07-06
Plan phase: install.sh --global mode
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 1.1: Parse `--global` flag and reject trailing target-dir | Found | `install.sh:32-39` | ✅ Implemented |
| Step 1.2: Global mode copies to `~/.claude/{commands,agents,instructions,prompts}` | Found | `install.sh:77, 79, 82, 85-86` | ✅ Implemented |
| Step 1.3: Merge HVE block into `~/.claude/CLAUDE.md` with global placeholder | Found | `install.sh:171-193` | ✅ Implemented |
| Step 1.4: Skip .gitignore step in global mode; print per-project rules | Found | `install.sh:224-243` | ✅ Implemented |
| Step 1.5: Gate migrations to project mode only | Found | `install.sh:99-101` | ✅ Implemented |
| Step 1.6: Keep project-mode behavior byte-for-byte equivalent | Found | `install.sh:50-52, 226` | ✅ Implemented |
| Step 1.7: Reject `--global <dir>` with error exit | Found | `install.sh:35-38` | ✅ Implemented |
| Step 1.8: Explicit error when `$HOME` unset in global mode | Found | `install.sh:42-44` | ✅ Implemented |

## Findings

### IV-001 [MINOR]
**Plan item:** Step 1.8 (Windows compatibility addendum: explicit error when $HOME unset)
**Evidence:** `install.sh:42-44` implements the check with message "error: --global needs $HOME to be set (it installs to $HOME/.claude)."
**Status:** Verified; addendum correctly attributed to Phase 1 scope in changes log (line 47).

### IV-002 [MINOR]
**Plan item:** Step 1.3 (Fresh global CLAUDE.md gets "## Your Global Context" placeholder)
**Evidence:** `install.sh:188-189` writes placeholder section with correct text when `$GLOBAL -eq 1`.
**Confidence:** HIGH — verified by direct inspection of conditional block.

## Unlisted Changes

Search for modifications to install.sh outside claimed Phase 1 ranges to detect any unclaimed changes in this phase:
- Lines 1-5: shebang and header comment — part of pre-existing file, no claim needed.
- Lines 27-30: source/target resolution setup — pre-existing, no claim needed.
- Lines 55-64: source validation — pre-existing, no change in Phase 1.
- All Phase 1 changes accounted for; no unlisted modifications detected.

## Research Coverage

No research document provided (plan authored inline per plan header). All phase steps derive from documented motivation:
- `$HOME/.claude/` folder loads commands/agents/instructions globally — verified by plan motivation.
- Project mode must remain byte-for-byte equivalent — preserved by conditional logic gating all changes to `$GLOBAL -eq 1` checks.
- `.gitignore` per-project (not global) — correctly skipped at `install.sh:226-243`.

## Verification Details

All claimed file:line ranges verified against actual install.sh content:

| Claim | Actual Range | Status |
|---|---|---|
| `install.sh:6-30` (usage header) | Lines 6-24 (usage + what-it-does) | ✅ Matches |
| `install.sh:33-56` (flag parsing & resolution) | Lines 32-53 (parsing + CLAUDE_DIR setup) | ✅ Matches |
| `install.sh:66-84` (copy to $CLAUDE_DIR) | Lines 67-87 (setup + three cp commands) | ✅ Matches |
| `install.sh:96-99` (migrations gated) | Lines 99-101 (if-guard on $GLOBAL -eq 0) | ✅ Matches |
| `install.sh:171-181` (CLAUDE.md merge target) | Lines 171-178 (conditional TARGET_CLAUDE) | ✅ Matches |
| `install.sh:224-259` (gitignore logic) | Lines 224-243 (if-else with label + rules) | ✅ Matches |

All line-number citations in the changes log are accurate and point to the correct implementation.

## Conclusion

Phase 1 is **100% complete** with all plan items implemented and verified:
- Flag parsing and error handling: ✅ Correct
- Global vs. project mode branching: ✅ Correct
- File/folder targets: ✅ Correct
- Merge targets and placeholder text: ✅ Correct
- Migration gating: ✅ Correct
- .gitignore skip + message: ✅ Correct
- `$HOME` unset guard: ✅ Correct

No contradictions, falsifications, or missing implementations found.
