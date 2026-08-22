# RPI Validation: full-repo-review-remediation — Phase 11
Date: 2026-08-15
Plan phase: Phase 11 — Documentation sync (DO-02, DO-03, DO-04, DO-05, DO-06)
Coverage: 100%
Status: Fail: 3 critical, 0 major

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 11.1: DO-02, `--mode` on research/plan rows | Found | `CLAUDE.md:43-44`, `README.md:123-124` | ✅ Implemented |
| Step 11.2: DO-03, `--dimension` on pr-review row | Found | `CLAUDE.md:47` | ✅ Implemented |
| Step 11.3: DO-04, `--scope` on doc-ops row | Found | `CLAUDE.md:50` | ✅ Implemented |
| Step 11.4: DO-05, javascript.md and typescript.md | Found | `docs/reference.md:65-66`, `docs/installation.md:105` | ✅ Implemented |
| Step 11.5: DO-06, friction/ in tracking diagram | Found | `docs/reference.md:29` | ✅ Implemented |
| Step 11.6: Suite run + installer verification | Found | changes log Phase 11 section | ✅ Implemented |
| Unplanned 11.7: DD-015/DD-016, global-mode guidance | Found | `install.sh:261-272`, `CLAUDE.md:357-359` | ⚠️ Partial (see findings) |
| Unplanned 11.8: DD-017, README.md reconciliation | Found | `README.md:122-136` | ✅ Implemented |
| Unplanned 11.9: DD-018, docs/ stale enumerations | Found | `docs/internals.md:50-52,62` | ✅ Implemented |

## Findings

### RV-001 [CRITICAL]
Plan success criterion: "every flag a command implements appears in its reference row"
Evidence: `/hve-research` argument-hint (`hve-research.md:3`) declares `[--mode lightweight|standard|full] [--subagent-model sonnet|opus|haiku] [--friction-log]`, but the Command Reference rows in both CLAUDE.md:43 and README.md:123 mention only `--mode`. `--subagent-model` and `--friction-log` are absent from both rows. Same defect for `/hve-plan`, `/hve-implement`, `/hve-review`, `/hve-pr-review`, `/hve-doc-ops`, and `/hve-challenge`. These flags are documented elsewhere in the reference section (CLAUDE.md:68 for `--subagent-model`; Friction Capture section for `--friction-log`) but are not enumerated in the command rows themselves.
Impact: The Command Reference table, which is a new user's first stop for available flags, is incomplete for 7 commands. Users may not discover these flags exist or when they apply.
Recommendation: Add `--subagent-model` and/or `--friction-log` to every row that implements them. For brevity, a note like "plus `--subagent-model` and `--friction-log` (available on all dispatching commands)" could apply to the first phase command row, or each row could enumerate its own flags explicitly.

### RV-002 [CRITICAL]
DD-016 scope and testability
Evidence: CLAUDE.md:359 uses a pointer form — "per CLAUDE.md's `Security Hygiene` section" — instead of a verbatim copy. Test 14 (`tests/run-drift-tests.sh:967-1013`) verifies pointers to CLAUDE.md headings resolve. However, this pointer is *inside* CLAUDE.md itself (a self-reference), while test 14 scans only `.claude/commands/*.md`, `.claude/agents/*.md`, and `.claude/prompts/*.md` (line 984-985). The pointer resolves at read-time (the heading exists at line 290), but nothing in the automated test suite would catch if a future edit deleted or renamed the `## Security Hygiene` heading.
Impact: The self-reference at CLAUDE.md:359 has no drift test protecting it, violating the same principle Phase 5 introduced test 14 to enforce.
Recommendation: Expand test 14's search corpus to include `CLAUDE.md` itself, or acknowledge this gap as a known limitation and record it in the changes log. A follow-on item to extend the pointer-resolution test would be appropriate.

### RV-003 [CRITICAL]
Unguarded re-drift of docs/internals.md:62
Evidence: Phase 11 fixed `docs/internals.md:62` by replacing a stale fourth copy of the security checklist with a pointer. However, `canonical_block_corpus()` at `tests/run-drift-tests.sh:582-590` includes only `.claude/commands/*.md`, `.claude/agents/*.md`, `.claude/prompts/*.md`, and `CLAUDE.md`. The `docs/` directory is not included, so no drift test will detect if someone re-introduces a verbatim copy of the credential list at `docs/internals.md:62`.
Impact: The same defect Phase 5 spent coverage swaps fixing — unauthorized duplication of canonical text — can re-occur in `docs/` without detection.
Recommendation: Either (a) extend `canonical_block_corpus()` to include `docs/internals.md`, or (b) document in the changes log that `docs/internals.md` is outside drift coverage and surface as a follow-on review item. The changes log (line 826) flags this but leaves it unresolved.

## Unlisted Changes
No unlisted changes detected. All 30 files in the parent-supplied changed-file list appear in the Phase 11 changes log:
- `.claude/agents/*.md` (8 files) — no Phase 11 edits; list is from Phases 2–10
- `.claude/commands/*.md` (13 files) — Phase 11 does not edit command files themselves
- `.claude/prompts/pull-request.md` — Phase 3 edit; not Phase 11
- `CLAUDE.md` — Phase 11 edits at lines 43–44, 50, 357–359 ✓
- `README.md` — Phase 11 edits at lines 122–126, 134–136 ✓
- `docs/installation.md` — Phase 11 edits listed ✓
- `docs/internals.md` — Phase 11 edits at lines 9, 50, 62 ✓
- `docs/reference.md` — Phase 11 edits at lines 29, 65–66 ✓
- `install.sh` — Phase 11 edits at lines 261–262 ✓
- `tests/run-drift-tests.sh` — no Phase 11 edits (Phase 10 final)
- `tests/run-install-tests.sh` — no Phase 11 edits (Phase 1 final)

## Research Coverage
Research: none — recorded absent by design in the plan header (line 5). Not a defect. Validation against the plan alone; research was recorded absent at planning time.

## Verification Detail

### Credential Lists (DD-008 validation)
All three surfaces verified to name the same five patterns in the same order, no `*.pfx`:
- CLAUDE.md:295: `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` ✓
- install.sh:246–250: `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` ✓
- tests/run-drift-tests.sh:291: `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` ✓

### DO-05 Verification
- `javascript.md` present in `.claude/instructions/` ✓
- `typescript.md` present in `.claude/instructions/` ✓
- Both listed in `docs/reference.md:65–66` language table ✓
- Both listed in `docs/installation.md:105` manual-migration list ✓
- Both listed in `install.sh:92–95` instruction array ✓

### DO-06 Verification
- `friction/` entry added to tracking-folder diagram at `docs/reference.md:29` ✓

### DD-015 (Global-mode gitignore guidance expansion)
Phase 11 extended Step 11.7 from two surfaces (install.sh global guidance + CLAUDE.md global paragraph) to six surfaces to ensure parity for all installation paths:
- `install.sh:261–262` — verbatim list (5 patterns) ✓
- `CLAUDE.md:357–359` — pointer form (no verbatim copy) ✓
- `README.md:43` — verbatim list ✓
- `docs/installation.md:25, :88, :157, :189` — verbatim lists ✓

### DD-016 (Pointer vs. verbatim choice)
CLAUDE.md:359 uses a pointer instead of a sixth verbatim copy: "per CLAUDE.md's `Security Hygiene` section". The target heading exists at line 290 and test 14 can resolve it from `.claude/**/*.md` pointers, but this self-reference inside CLAUDE.md itself is not covered by test 14's corpus (line 984–985 searches `.claude/commands`, `.claude/agents`, `.claude/prompts` only).

### DD-017 (README.md reconciliation)
Rows reconciled: `/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review` (all now document `--mode`); `/hve-pr-review` (now documents Phase 3 security-floor semantics); `/hve-doc-ops` (now documents `--scope` and corrects invalid example `--scope src/auth/` to `--scope all|compliance|accuracy|gaps`). README.md:123–126 and 134–136 now match CLAUDE.md:43–50 in flag coverage.

### DD-018 (docs/ stale enumerations)
Two staleness defects found and fixed:
1. `docs/internals.md:50` claimed quality validator "always runs these 11 checks"; corrected to state dimension 9 (security) is additive and never filtered out, matching Phase 3's security-floor decision.
2. `docs/internals.md:62` restated a 3-of-5 patterns security checklist (missing `.env.*` and `*.pem`); replaced with a pointer to CLAUDE.md's `Security Hygiene` section. **However, this file is outside drift coverage** (see RV-003).

## Cross-Phase Finding Consistency

No contradictions detected between Phase 11 claims and prior phases. Phase 3's security-floor decision (documented at `hve-implementation-validator.md:22` as additive scope) is correctly reflected in the Phase 11 updates to `docs/internals.md:50` and `hve-pr-review.md:90–98`.

## Summary

Planned scope (DO-02 through DO-06) is fully implemented and correct. The three unplanned parent-added steps (11.7, 11.8, 11.9) are also correctly implemented according to their stated purposes (DD-015, DD-017, DD-018). However, **the phase fails to close the success criterion** ("every flag a command implements appears in its reference row") because:

1. **RV-001**: Flags `--subagent-model` and `--friction-log` are not enumerated in the Command Reference rows, though they are documented elsewhere in CLAUDE.md.
2. **RV-002/RV-003**: Two pointers were added (CLAUDE.md:359 for credential patterns; `docs/internals.md:62` for security checklist) without drift-test coverage for either. Test 14 scans `.claude/**/*.md` but not CLAUDE.md itself or `docs/`. The self-reference and the docs-file reference are both unguarded against re-drift.

The changes themselves are correct and functional; the defects are about documentation completeness and test coverage, both labeled as supporting criteria to the Phase 11 success criterion.

---

## Checklist for Recommended Follow-On

- [ ] RV-001: Add `--subagent-model` and `--friction-log` to Command Reference rows, or justify why they are excluded for brevity.
- [ ] RV-002: Expand test 14 to scan CLAUDE.md itself, or document the self-reference limitation and mark it as a known gap.
- [ ] RV-003: Extend `canonical_block_corpus()` to cover `docs/internals.md`, or formally record that `docs/` is outside drift coverage.
- [ ] Verify that the Phase 1 installer change (adding five credential patterns to `.gitignore`) survived the full 11-phase run; the changes log reports this in Step 11.6 execution but a spot-check would confirm.
- [ ] Verify all test assertions referenced in Phase 11 (tests 248 passed / 66 install passed) are as expected from the Phase 10 baseline.

---

## Clarifying Questions
None. All implementation claims are verifiable from the file evidence.

---

Full detail: re-read `.claude-hve-tracking/reviews/rpi/2026-08-15/full-repo-review-remediation-phase-011-validation.md`
