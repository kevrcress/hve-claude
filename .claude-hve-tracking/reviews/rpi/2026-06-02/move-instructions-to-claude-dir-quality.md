# Implementation Validation: Move instruction files from instructions/ to .claude/instructions/
Date: 2026-06-02
Scope: full-quality (all 10 dimensions)
Files Reviewed: 24 (11 instruction file renames, 2 prompts, 3 agents, 7 commands, CLAUDE.md, README.md, install.sh)

## Summary
Critical: 0 | Major: 0 | Minor: 2

---

## Findings

### IV-001 [ARCHITECTURE] [MINOR]
**Description:** Missing newline after echo statement in install.sh migration success case
**Evidence:** install.sh:79 — `echo "  ✓ migrated instructions/..."` followed by conditional logic on line 81 without an intervening blank line for clarity
**Impact:** Minimal stylistic issue; does not affect functionality or output clarity
**Recommendation:** Add blank line before `elif` for visual separation and consistency with surrounding code structure

### IV-002 [ERROR HANDLING] [MINOR]
**Description:** Unconditional path resolution at install.sh:22-23 may mask permission errors
**Evidence:** install.sh:22-23 — `cd` operations inside command substitution `$(...)` silently ignore permission/non-existent directory errors
**Impact:** If the source repo directory does not exist or user lacks read permissions, the error will be cryptic (empty paths). Acceptable given this is a library installation script and should be run with proper permissions, but worth noting.
**Recommendation:** Verify the `SOURCE` and `TARGET` variables explicitly after assignment (e.g., `[ -d "$SOURCE" ] || { echo "error: source not a directory"; exit 1; }`) for clearer diagnostics

---

## Coverage by Dimension

### 1. Architecture Conformance ✓ [HIGH]
- Instruction files correctly moved to `.claude/instructions/` — aligns with Claude Code convention that all Claude-specific assets live under `.claude/`
- All references in agents (`.claude/agents/`) and commands (`.claude/commands/`) updated consistently
- Install.sh correctly creates target directory as `$TARGET/.claude/instructions/`, not `$TARGET/instructions`
- No cross-layer violations introduced; migration is purely organizational

### 2. Design Principles ✓ [HIGH]
- Migration logic in install.sh follows Single Responsibility: clear phases (copy files, migrate old location, merge CLAUDE.md, add gitignore rules)
- Safe-to-rerun idempotency maintained — `cmp -s` byte-for-byte comparison ensures existing customizations are not overwritten
- No Open/Closed violations — only appending/replacing, no forced refactoring of user projects

### 3. DRY Compliance ✓ [HIGH]
- `HVE_INSTRUCTION_FILES` array in install.sh (line 51–54) defines single source of truth for migration targets
- Path references use variables (`$SOURCE`, `$TARGET`, `$OLD_INSTRUCTIONS_DIR`) consistently
- No duplication of instruction file paths; all 12 known files listed once in the array
- Verified: 50 occurrences of `.claude/instructions/` path across all files; all consistent

### 4. API Usage ✓ [HIGH]
- `cmp -s` for byte-for-byte comparison (standard, portable, POSIX-compliant) ✓
- `rmdir` for empty directory removal (safe — refuses if non-empty) ✓
- `awk` for CLAUDE.md section extraction (line 90; correct use with `/^## Your Project/{exit}`) ✓
- `ls -A` for detecting empty directory (portable, POSIX) ✓
- All bash idioms correct; no deprecated patterns observed
- Syntax validation passed: `bash -n install.sh` returns success

### 5. Version Consistency ✓ [HIGH]
- All 12 instruction files present in `.claude/instructions/`: bash.md, csharp.md, csharp-tests.md, python.md, python-tests.md, python-uv.md, rust.md, rust-tests.md, terraform.md, markdown.md, git-commit-messages.md, writing-style.md
- References in CLAUDE.md Instructions Reference table (lines 190–201): all 12 entries updated from `instructions/` to `.claude/instructions/`
- References in README.md: Option B step 4, Option A prompt, "Updating an existing install" section, Terminal section all consistently point to `.claude/instructions/`
- No stragglers detected in agents, commands, or prompts

### 6. Refactoring Opportunities ✓ [MEDIUM]
- install.sh migration block (lines 49–84) could be extracted into a shell function for reusability, but current inline implementation is acceptable for a one-shot installer
- The `_migrated` and `_kept` counters could be simplified (conditional reporting on line 78–82 is slightly dense), but logic is sound
- README "Updating an existing install" section (lines 302–317) could potentially reference the bash installer prompt directly, but current separation is clear

### 7. Error Handling ✓ [MEDIUM]
- `cmp -s` properly used: silently returns exit code; migration respects customizations (line 65)
- Old directory removal guarded by `[ -d "$OLD_INSTRUCTIONS_DIR" ] && [ -z "$(ls -A ...)" ]` (line 76) — safe, idempotent
- `rmdir` used (not `rm -rf`), correctly refuses to delete non-empty directories (plan requirement met) ✓
- Silent no-op when no HVE files exist in old location (line 81–82): appropriate for idempotent re-runs
- Warning message for diverged files (line 69) informs user to manual-review; user retains control
- **Minor issue:** Implicit error handling on SOURCE/TARGET path resolution could be more explicit (IV-002)

### 8. Test Coverage
No explicit test files were added for install.sh. This is a deployment artifact, and testing would typically be done:
- Manually by testers before release
- Or via CI/CD test matrix across platforms (Mac/Linux/WSL)
- The migration logic uses standard POSIX utilities and has no external dependencies, reducing test surface area
**Recommendation:** Consider adding a `test-install.sh` that creates a temp project directory and verifies the three migration cases: identical (removed), diverged (warned+kept), absent (no-op). Not blocking, but would increase confidence.

### 9. Security Posture ✓ [CRITICAL]
- **Secret exposure:** No secret patterns detected in modified files (PRIVATE KEY, api_key=, password=, Bearer, -----BEGIN, AKIA, AIza)
- **.gitignore hygiene:** `.env`, `.env.*`, `.pem`, `.key`, `.p12`, `.pfx` not required in this repo's .gitignore (HVE system repo, not a user project), so N/A. Documented in CLAUDE.md and README for users to apply.
- **Committed secrets:** No credential-like files added or modified (all changes are reference docs and configuration)
- **New dependencies:** No new npm/pip/cargo packages added; all changes are text/markdown files and bash scripts
- **Input validation:** `install.sh` accepts a single optional path argument; resolved safely via `cd` and `pwd` (standard pattern)
- Migration uses `cmp -s` to compare files before deletion — prevents accidental loss of customizations

### 10. Overall Quality ✓ [HIGH]
- Code is readable by a new contributor; install.sh is well-commented (line 49 onward clearly labels migration block)
- Function and variable names are clear: `SOURCE`, `TARGET`, `OLD_INSTRUCTIONS_DIR`, `HVE_INSTRUCTION_FILES`, `_migrated`, `_kept`
- Complexity is appropriate: migration block is straightforward loop + cleanup logic
- README.md "Upgrading from an older install?" section (line 282) clearly explains the manual path; "Updating an existing install" section (lines 302–317) provides the automated prompt
- CLAUDE.md Instructions Reference table is comprehensive and up-to-date
- All output messages are user-friendly (checkmarks, warnings, status updates)

---

## Plan Adherence

Comparison against `.claude-hve-tracking/plans/2026-06-01/move-instructions-to-claude-dir-plan.md`:

| Phase | Expected | Actual | Status |
|---|---|---|---|
| Phase 1: Move files | 11 files git mv | 11 files moved; `instructions/` removed from repo | ✓ Complete |
| Phase 2: Update agents/commands | 7 files, 13 occurrences | 7 files (hve-phase-implementor, hve-prompt-updater, hve-implement, hve-git-commit, hve-git-merge, hve-prompt-analyze, hve-prompt-builder); all 13 occurrences updated | ✓ Complete |
| Phase 3: Update CLAUDE.md/prompts | 12 table rows + installer text + 2 prompt files | CLAUDE.md lines 190–201 (12 rows); line 248 (installer description); prompts/doc-ops.md:20, prompts/prompt-build.md:9 | ✓ Complete |
| Phase 4: Update README.md | Option B step 4, upgrade callout, terminal section, FAQ | Lines 252–253, 282, 304–317 (4 sections) | ✓ Complete |
| Phase 5: Update install.sh | Copy from `.claude/instructions/`, migration block with cmp checks | Lines 37–47 (copy), lines 49–84 (migration with byte-for-byte checks) | ✓ Complete |

---

## Testing Approach (from plan)

1. **Grep for bare `instructions/`** — Executed; result: zero hits in `.claude/agents/` and `.claude/commands/` ✓
2. **Verify install.sh target directory** — Confirmed: line 37 creates `$TARGET/.claude/instructions/` ✓
3. **Migration block edge cases** — Verified logic handles:
   - Identical files: removed (line 65–67) ✓
   - Diverged files: warned and kept (line 69–70) ✓
   - Absent files: no-op (implicit in loop) ✓
   - Empty old directory: rmdir'd safely (line 76–77) ✓

---

## Integration Notes

- Instruction files are **not versioned content** (11 .md files, all renames with zero content changes)
- Agent and command references are **documentation strings only** (not code that executes at runtime); changes are safe and verified
- README and CLAUDE.md changes are **purely informational** (no code path changes)
- install.sh migration is **backward-compatible** (handles both new installs and upgrades from old layout)
- No build, test, or deployment artifacts affected

---

## Risk Mitigation

| Original Risk | Mitigation | Status |
|---|---|---|
| Existing projects have `instructions/` hardcoded in CLAUDE.md | README "Upgrading from an older install?" (line 282) and "Updating" prompt (lines 302–317) | ✓ Mitigated |
| Agent prompts reference `instructions/` at runtime | Systematic update across all 7 agents/commands verified; no stragglers | ✓ Verified |
| install.sh migration deletes customized files | `cmp -s` byte-for-byte check only removes exact matches; diverged files warned and kept | ✓ Mitigated |

---

## Conclusion

The implementation is **production-ready**. All 5 plan phases completed successfully. No critical issues detected; 2 minor style/error-handling improvements suggested but not blocking. The migration preserves backward compatibility through install.sh automation and provides clear upgrade guidance in README and CLAUDE.md.
