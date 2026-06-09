# Planning Log: Move `prompts/` → `.claude/prompts/`

Date: 2026-06-08

## Design Decisions
- **DD-001**: Move source repo `prompts/` via `git mv` (not just installer change). Keeps
  source + installed layout identical and installer copies from a parallel `.claude/` path.
  [user-confirmed]
- **DD-002**: Add upgrade migration mirroring the existing `instructions/` migration rather
  than leaving stale root `prompts/`. Byte-compare protects user customizations. [user-confirmed]
- **DD-003**: Reuse the established test harness shape — new `tests/lib/prompt-files.sh` list +
  `seed_old_prompts()` helper + assertions folded into existing test1/test3, rather than a new
  standalone test file. Lower surface area, consistent with instructions tests.
- **DD-004**: Copy at install (`:52`) runs before the migration block, so identical old-location
  files are safely removed after the new-location copy exists. Ordering verified against current
  install.sh structure (instructions migration sits at ~:55-91, after the copies at :45-52).

## Discrepancies from Research
- **DR-001**: None. All references from the research scan are accounted for in the plan's P4 list.

## Open Risks
- Migration list must stay in sync between install.sh and tests/lib/prompt-files.sh (same
  coupling that already exists for instructions; comment notes added in both places).
- blog-porting-*.md is an untracked draft; updated for accuracy but not load-bearing.
