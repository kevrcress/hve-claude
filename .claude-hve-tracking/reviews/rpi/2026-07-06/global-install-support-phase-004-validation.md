# RPI Validation: Global install support — Phase 4
Date: 2026-07-06
Plan phase: Addendum (2026-07-06): Windows compatibility
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| install.sh: explicit error when $HOME is unset in global mode | Found | `install.sh:41-45` | ✓ Implemented |
| docs/installation.md: state ~/ is %USERPROFILE%\.claude on Windows | Found | `docs/installation.md:122-123` | ✓ Implemented |
| docs/installation.md: add any-OS global paste-to-install prompt | Found | `docs/installation.md:128-151` | ✓ Implemented |
| docs/installation.md: clarify Git Bash vs WSL $HOME semantics | Found | `docs/installation.md:161-165` | ✓ Implemented |
| README.md Installation: pointer rewritten for Windows equivalence | Found | `README.md:197` | ✓ Implemented |
| CLAUDE.md: Windows parenthetical and paste prompt pointer | Found | `CLAUDE.md:280-281` | ✓ Implemented |
| tests/run-install-tests.sh: assertion that `env -u HOME install.sh --global` exits nonzero | Found | `tests/run-install-tests.sh:432-437` | ✓ Implemented |

## Findings

### IV-001 [MINOR]
**File citation inconsistency in changes log**
Changes log cites `tests/run-install-tests.sh:432-441` but the actual test assertion spans lines 429-437.
File: `tests/run-install-tests.sh:429-437`
Impact: Off-by-one in range; minor documentation drift.
Recommendation: No code impact; this is a recording accuracy issue only. Correction annotation could be added if future phases touch this area.

## Verification Summary

**install.sh HOME check:** Lines 41-45 correctly gate global mode with explicit error message when $HOME is unset.
```
if [ "$GLOBAL" -eq 1 ]; then
  if [ -z "${HOME:-}" ]; then
    echo "error: --global needs \$HOME to be set (it installs to \$HOME/.claude)." >&2
    exit 1
```

**Windows path equivalence:** Correctly documented in three locations:
- `docs/installation.md:122-123`: "On Windows, `~` means your user profile folder: the same paths are `%USERPROFILE%\.claude`"
- `README.md:197`: "~/.claude/ folder (`%USERPROFILE%\.claude` on Windows)"
- `CLAUDE.md:280`: "~/.claude/ (`%USERPROFILE%\.claude` on Windows)"

**Any-OS paste prompt:** Lines 132-151 of docs/installation.md provide a complete, OS-agnostic prompt that:
- Instructs cloning to a temp directory (independent of shell/OS)
- Copies files to `~/.claude` (with inline note that this is `%USERPROFILE%\.claude` on Windows — not in the prompt itself, but in surrounding docs)
- Specifies the exact markers to use for merging
- Describes all three cases for handling CLAUDE.md (existing markers, no markers, missing file)
- Instructs creation of "## Your Global Context" placeholder for new global file
- Correctly states to skip .gitignore but remind user to add rules per-project
- Instructs deletion of temp clone and display of changes

Cross-check: The prompt's marker format (`<!-- HVE:START - managed by hve-claude, do not edit between markers -->` / `<!-- HVE:END -->`) matches install.sh lines 179-180 exactly.

**Git Bash vs WSL semantics:** Correctly clarified in docs/installation.md:161-165:
- Git Bash: `$HOME` resolves to Windows user profile, same result as paste prompt
- WSL: `$HOME` resolves to WSL home (different from Windows-native, so WSL users should use paste prompt for Windows Claude Code)

**Test assertion:** Correctly implemented in tests/run-install-tests.sh:429-437:
```bash
env -u HOME "${INSTALL_SH}" --global > /dev/null 2>&1 || rc=$?
if (( rc != 0 )); then
  _ok_inline "test5: --global with unset HOME exits nonzero" "rc=${rc}"
```
Uses `env -u HOME` to unset HOME, runs install.sh --global, expects nonzero exit, passes if it fails as expected.

**Em-dash check:** No em-dashes (—) or Unicode dashes (–) introduced in Phase 4 additions. Existing en-dashes on lines 88 and 182 of docs/installation.md predate this phase.

## Research Coverage

No research document was produced for this task (noted in plan header). All requirements were specified inline in the plan's Addendum section and have been implemented with matching file evidence.

## Unlisted Changes

No files were modified outside those listed in the changes log for Phase 4.
