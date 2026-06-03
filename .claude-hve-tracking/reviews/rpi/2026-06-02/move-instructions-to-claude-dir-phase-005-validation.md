# RPI Validation: Move instructions to .claude/instructions — Phase 5
Date: 2026-06-02
Plan phase: Phase 5 — Update install.sh
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 5.1: Update mkdir -p to create $TARGET/.claude/instructions/ | Found | `install.sh:37` | ✅ Implemented |
| Step 5.2: Update cp source path to $SOURCE/.claude/instructions/*.md | Found | `install.sh:45` | ✅ Implemented |
| Step 5.3: Add migration block with cmp -s, warnings, rmdir logic | Found | `install.sh:49-84` | ✅ Implemented |

## File Evidence

### Step 5.1: mkdir -p for .claude/instructions/

**Claim:** `mkdir -p` creates `$TARGET/.claude/instructions/` (not `$TARGET/instructions`)

**Evidence:** `install.sh:37`
```bash
mkdir -p "$TARGET/.claude/commands" "$TARGET/.claude/agents" "$TARGET/.claude/instructions" "$TARGET/prompts"
```

**Verification:** ✅ PASS
- Creates `.claude/instructions/` as a separate target directory
- Does NOT create the old `instructions/` path
- Correctly includes all necessary directories in a single call

---

### Step 5.2: cp source path

**Claim:** `cp` copies from `$SOURCE/.claude/instructions/*.md`

**Evidence:** `install.sh:45`
```bash
cp "$SOURCE"/.claude/instructions/*.md "$TARGET/.claude/instructions/"
```

**Verification:** ✅ PASS
- Source path is correctly `$SOURCE/.claude/instructions/*.md`
- Target is `$TARGET/.claude/instructions/`
- Glob pattern captures all instruction files

---

### Step 5.3: Migration block

**Claim:** Migration block exists with:
- List of known HVE instruction filenames
- cmp -s comparison before removing files
- Warning message for diverged files
- rmdir (not rm -rf) for directory cleanup
- Safety check to only remove if empty

**Evidence:** `install.sh:49-84`

#### 5.3a: Known HVE filenames list

**Evidence:** `install.sh:51-54`
```bash
HVE_INSTRUCTION_FILES=(
  bash.md csharp.md csharp-tests.md python.md python-tests.md python-uv.md
  rust.md rust-tests.md terraform.md markdown.md git-commit-messages.md writing-style.md
)
```

**Verification:** ✅ PASS
- All 12 known HVE instruction files are listed
- Array syntax is correct and idiomatic for bash

#### 5.3b: cmp -s byte-for-byte comparison

**Evidence:** `install.sh:65`
```bash
if cmp -s "$new_source" "$old_file"; then
```

**Verification:** ✅ PASS
- Uses `cmp -s` (silent byte-for-byte comparison) as specified
- Correctly compares the new source against the old file
- Silent flag (-s) prevents output on identical files

#### 5.3c: Warning for diverged files

**Evidence:** `install.sh:68-70`
```bash
else
  echo "  ! kept instructions/$fname — it differs from the installed version (possible local customization); review and remove manually if unneeded."
  _kept=$((_kept + 1))
```

**Verification:** ✅ PASS
- Warns the user that a file differs (possible local customization)
- Does NOT delete the file
- Increments a counter for summary reporting
- Message is clear and actionable

#### 5.3d: rmdir (not rm -rf) for directory cleanup

**Evidence:** `install.sh:77`
```bash
rmdir "$OLD_INSTRUCTIONS_DIR"
```

**Verification:** ✅ PASS
- Uses `rmdir` (safe removal of empty directories only)
- Does NOT use `rm -rf` or `rm -r`
- Will fail gracefully if directory is not empty

#### 5.3e: Safety check for empty directory

**Evidence:** `install.sh:76`
```bash
if [ -d "$OLD_INSTRUCTIONS_DIR" ] && [ -z "$(ls -A "$OLD_INSTRUCTIONS_DIR")" ]; then
```

**Verification:** ✅ PASS
- Checks directory exists: `[ -d "$OLD_INSTRUCTIONS_DIR" ]`
- Checks directory is empty: `[ -z "$(ls -A "$OLD_INSTRUCTIONS_DIR")" ]`
- `ls -A` lists all files including hidden ones
- Only proceeds to `rmdir` if both conditions are true

---

### Step 5.4: Script safety

**Claim:** Script retains `set -euo pipefail`

**Evidence:** `install.sh:19`
```bash
set -euo pipefail
```

**Verification:** ✅ PASS
- Present at the start of the script (standard position)
- Ensures:
  - `-e`: exit on error
  - `-u`: error on undefined variables
  - `-o pipefail`: propagate pipe failures
- No safety-critical lines are missing these protections

---

## Findings

### Zero Critical, Major, or Minor Issues

All plan steps for Phase 5 have been correctly implemented and verified in the codebase. No gaps, deviations, or safety issues detected.

---

## Unlisted Changes

No files were modified outside the install.sh changes specified in the plan and changes log for Phase 5.

---

## Research Coverage

No research document was provided for this task. The plan was derived directly from a source code audit (see plan header). All technical requirements specified in the plan have been met:

- `install.sh` creates the new `.claude/instructions/` directory structure
- File copies originate from the correct source location
- Migration logic is comprehensive, safe, and non-destructive
- The script retains defensive shell practices (set -euo pipefail)

---

## Verification Summary

**Coverage: 100%** (3 of 3 plan steps verified + all sub-requirements met)

**Status: PASS**

All Phase 5 requirements have been correctly implemented. The install script is safe, idempotent, and correctly handles both new installs and migration of existing projects.
