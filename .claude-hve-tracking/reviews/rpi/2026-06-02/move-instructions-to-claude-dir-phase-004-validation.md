# RPI Validation: Move instruction files from instructions/ to .claude/instructions/ — Phase 4
Date: 2026-06-02
Plan phase: Phase 4 — Update README.md
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 4.1: Update Option B step 4 source/target paths | Found | `README.md:252-253` | ✅ Implemented |
| Step 4.2: Rewrite "Upgrading from an older install?" callout | Found | `README.md:282` | ✅ Implemented |
| Step 4.3: Update Terminal/bash description to mention auto-migration | Found | `README.md:298` | ✅ Implemented |
| Step 4.4: Add "Updating an existing install" subsection with update prompt | Found | `README.md:302-317` | ✅ Implemented |
| Step 4.5: Update FAQ "How do I update HVE?" to reference the new update prompt | Found | `README.md:609` | ✅ Implemented |

## Findings

### No Critical or Major Issues

All Phase 4 steps have been implemented correctly with proper verification:

1. **Step 4.1 — Option B Step 4:** Lines 252–253 correctly reference source path `hve-claude/.claude/instructions/*.md` and target path `<your-project>/.claude/instructions/`.

2. **Step 4.2 — Upgrade callout:** Line 282 contains the complete "Upgrading from an older install?" callout with accurate migration instructions: describes the old `<your-project>/instructions/` location, the new `<your-project>/.claude/instructions/` location, byte-for-byte comparison logic, and `rmdir` usage.

3. **Step 4.3 — Terminal/bash section:** Line 298 includes the auto-migration behavior statement: "On upgrade it automatically migrates any old top-level `instructions/` folder: identical files are removed silently; customized files are left in place with a warning."

4. **Step 4.4 — "Updating an existing install" subsection:** Lines 302–317 contain the new subsection with a complete update prompt that covers all required elements:
   - Overwrite of commands, agents, instruction files, and prompts (line 309–310)
   - Reference to HVE:START/HVE:END markers in CLAUDE.md (line 311–312)
   - Old `instructions/` folder migration logic with byte-for-byte checks (lines 313–314)
   - Cleanup of temp clone (line 315)

5. **Step 4.5 — FAQ update:** Line 609 references the update prompt section correctly via `[update prompt](#updating-an-existing-install)` with a hyperlink anchor to the new subsection.

## Bare Path Verification

Grep of all `instructions/` references in README.md shows:
- All non-migration references use `.claude/instructions/` (lines 35, 81, 218, 252, 253, 310, 388, 479, 597, 615)
- All bare `instructions/` references appear only in migration-context sections (lines 282, 298, 304, 313, 314), which is correct and intentional

No stray bare `instructions/` paths found outside migration documentation.

## Research Coverage

No research document was provided for this plan, consistent with the plan header noting "plan derived directly from source audit." Phase 4 focuses on documentation updates, not implementation against external requirements.

## Summary

All five plan steps for Phase 4 are implemented and verified in the README.md file. The changes align with the specification:
- Option B manual installation step correctly targets `.claude/instructions/`
- Migration callout accurately describes the old→new path transition
- Terminal section mentions auto-migration behavior
- New "Updating an existing install" subsection provides a complete natural-language prompt covering all migration scenarios
- FAQ entry references the new update section
- No bare `instructions/` paths remain outside migration documentation context

Phase 4 implementation is complete and correct.
