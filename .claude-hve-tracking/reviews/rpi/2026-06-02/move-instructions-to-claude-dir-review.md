# Review Log: Move instruction files from instructions/ to .claude/instructions/
Date: 2026-06-02
Plan: .claude-hve-tracking/plans/2026-06-01/move-instructions-to-claude-dir-plan.md
Changes: .claude-hve-tracking/changes/2026-06-01/move-instructions-to-claude-dir-changes.md
Research: (none — plan derived directly from source audit)
Overall Status: Complete

## Phase Reviews

### Phase 1 — Move instruction files
Validation: .claude-hve-tracking/reviews/rpi/2026-06-02/move-instructions-to-claude-dir-phase-001-validation.md
Status: ✅ Pass
- All 12 instruction files present at `.claude/instructions/` [HIGH]
- Old `instructions/` directory absent from repo [HIGH]
- Note: plan stated "11 files" — repo has 12 (plan undercount; not an implementation defect)

### Phase 2 — Update internal references in agents and commands
Validation: .claude-hve-tracking/reviews/rpi/2026-06-02/move-instructions-to-claude-dir-phase-002-validation.md
Status: ✅ Pass
- All 13 path replacements across 7 files verified at exact line numbers [HIGH]
- Zero bare `instructions/` references remain in agents or commands [HIGH]
- No unrelated content changed in any file [HIGH]

### Phase 3 — Update references in CLAUDE.md and prompts
Validation: .claude-hve-tracking/reviews/rpi/2026-06-02/move-instructions-to-claude-dir-phase-003-validation.md
Status: ✅ Pass
- All 12 Instructions Reference table rows in CLAUDE.md use `.claude/instructions/` [HIGH]
- Installer description paragraph updated [HIGH]
- prompts/doc-ops.md and prompts/prompt-build.md both updated [HIGH]

### Phase 4 — Update README.md
Validation: .claude-hve-tracking/reviews/rpi/2026-06-02/move-instructions-to-claude-dir-phase-004-validation.md
Status: ✅ Pass
- Option B step 4 uses `.claude/instructions/` [HIGH]
- "Upgrading from an older install?" callout present with accurate migration + rmdir guidance [HIGH]
- Terminal/bash section mentions auto-migration [HIGH]
- "Updating an existing install" subsection added with complete update prompt [HIGH]
- FAQ "How do I update HVE?" links to new update section [HIGH]

### Phase 5 — Update install.sh
Validation: .claude-hve-tracking/reviews/rpi/2026-06-02/move-instructions-to-claude-dir-phase-005-validation.md
Status: ✅ Pass
- mkdir creates `.claude/instructions/` at target [HIGH]
- cp sources from `$SOURCE/.claude/instructions/*.md` [HIGH]
- Migration block: 12-file array, cmp -s byte comparison, warn-on-diverge, rmdir-only [HIGH]
- set -euo pipefail retained [HIGH]

## Quality Findings

### Minor Findings (non-blocking)

**IV-001** [Minor] — `install.sh` migration block lacks an explicit `[ -d "$SOURCE" ]` guard after path resolution; errors would surface via `set -euo pipefail` but with a less informative message.
Recommendation: Add `[ -d "$SOURCE" ]` check with an explicit error message before the copy block.

**IV-002** [Minor] — README "Updating an existing install" prompt does not enumerate the 12 known instruction filenames for users who want to manually verify migration; the prompt itself is complete for Claude-assisted updates.
Recommendation: Optionally note the file list in the "Upgrading from an older install?" callout in Option B, or leave as-is (low user impact).

## Security Findings

None. No credentials, no secrets, no new dependencies introduced. Secret pattern scan (PRIVATE KEY, api_key=, password=, Bearer, -----BEGIN): 0 hits. Status: PASS.

## Minor Finding Remediation

**IV-001** — Addressed 2026-06-02: Added source structure guard to `install.sh` (after line 29) that checks `.claude/commands/` and `.claude/instructions/` exist before proceeding, with an explicit error message pointing to the hve-claude repo root.

**IV-002** — Addressed 2026-06-02: Added enumerated list of all 12 HVE instruction filenames to the "Upgrading from an older install?" callout in README.md Option B.

## Summary
Status: ✅ Complete
Critical: 0 | Major: 0 | Minor: 2 (all remediated)
All 5 plan phases validated Pass. Minor findings remediated.
