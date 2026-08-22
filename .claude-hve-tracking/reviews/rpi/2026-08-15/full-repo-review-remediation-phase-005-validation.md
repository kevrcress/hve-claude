# RPI Validation: Full-repo review remediation — Phase 5
Date: 2026-08-15
Plan phase: RL deduplication and the drift-coverage swap (RL-03, RL-04, RL-05, RL-06, RL-08, FC-01, RO-03)
Coverage: 11/11 (100%)
Status: Pass

---

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| 5.1: Friction paragraph to reference in 6 commands | Found | `.claude/commands/hve-research.md:13` | ✓ Implemented |
| 5.2: test6 retired, folded into CANONICAL_BLOCK_SPECS | Found | `tests/run-drift-tests.sh:351-368` | ✓ Implemented |
| 5.3: Security checklist to reference (2 sites) | Found | `.claude/agents/hve-implementation-validator.md:69` | ✓ Implemented |
| 5.4: "Shell stays" to reference in hve-review.md | Found | `.claude/commands/hve-review.md:81` | ✓ Implemented |
| 5.5: "Concurrent writes" to reference (3 sites) | Found | `.claude/commands/hve.md:107` | ✓ Implemented |
| 5.6: Discovery algorithm to reference in hve-memory.md | Found | `.claude/commands/hve-memory.md:37` | ✓ Implemented |
| 5.7: Discovery reference added to hve-implement.md (FC-01) | Found | `.claude/commands/hve-implement.md:25` | ✓ Implemented |
| 5.8: Update discovery_stub spec count | Found | `tests/run-drift-tests.sh:565` | ✓ Implemented |
| 5.9: New test 14, reference resolution | Found | `tests/run-drift-tests.sh:967-1013` | ✓ Implemented |
| 5.10: New test 15, assertion 1 only | Found | `tests/run-drift-tests.sh:1048-1074` | ✓ Implemented |
| 5.11: Run suites, record new baseline (218/0 drift, 66/0 install) | Found | Changes log Phase 5, Test Delta | ✓ Implemented |

---

## Findings

### Deduplication Verification: All Five Blocks Successfully Collapsed

**RL-03 (Friction Capture):**
- Canonical carrier: `CLAUDE.md:107-111` contains full mechanics section. [HIGH]
- Six command pointers: `hve-research.md:13`, `hve-plan.md:19`, `hve-implement.md:13`, `hve-review.md:13`, `hve-pr-review.md:13`, `hve-challenge.md:13`. All use binding construction `per CLAUDE.md's \`Friction Capture\` section`. [HIGH]
- No additional copies found in command/agent corpus. Grep for `accept an optional \`--friction-log\` flag` in `.claude/` returns zero results (CLAUDE.md canonical only). [HIGH]
- Verdict: **Correctly deduplicated to 1 carrier, 6 references.**

**RL-04 (Security Hygiene Checklist):**
- Canonical carrier: `CLAUDE.md:294-297` lists five credential patterns. [HIGH]
- Two references: `hve-implementation-validator.md:69` ("per CLAUDE.md's `Security Hygiene` section") and `hve-implement.md:155` (same reference). [HIGH]
- File-specific retention verified:
  - `hve-implementation-validator.md:70-71` kept validator-only bullets `Input validation` and `SQL injection / XSS`. [HIGH]
  - `hve-implement.md:156` kept command-specific requirement "record findings under `## Security Hygiene Check`". [HIGH]
- RL-04 narrowing (DD-008): `*.pfx` pattern and explicit `AKIA` prefix no longer listed; replaced by "AWS/GCP key prefixes". This narrowing is acceptable per DD-008 (Phase 1 installer already specifies five patterns, not six; adding here would desynchronize). [HIGH]
- Verdict: **Correctly deduplicated, file-specific mechanics retained, narrowing disclosed.**

**RL-05 (Shell stays in the parent):**
- Canonical carrier: `CLAUDE.md:202` in `## Subagent Dispatch Discipline` section. [HIGH]
- One reference: `hve-review.md:81` uses binding construction `per CLAUDE.md's \`Subagent Dispatch Discipline\` section`. [HIGH]
- Grep for full phrase `Shell stays in the parent.` in `.claude/commands/*.md` returns zero results (only CLAUDE.md match). [HIGH]
- Verdict: **Correctly deduplicated to 1 carrier, 1 reference.**

**RL-06 (Concurrent writes rule):**
- Canonical carrier: `CLAUDE.md:313-315` in new `## Concurrent Changes-Log Writes` section. DD-006 correctly promoted it from inside `Optional Power-User` section (details: "Content is unchanged and byte-identical to the original paragraph"). [HIGH]
- Three references: `hve.md:107`, `hve-implement.md:122`, `hve-phase-implementor.md:48`. All use binding construction. [HIGH]
- Grep for `**Concurrent writes**` returns CLAUDE.md only (the fixed-string prefix in test 10 spec). [HIGH]
- Verdict: **Correctly deduplicated, promotion to new section verified.**

**RL-08 (Discovery algorithm with FC-01):**
- Canonical reference: `CLAUDE.md:241-250` documents the 4-step discovery algorithm. [HIGH]
- Five pointers in discovering commands: `hve-plan.md:25`, `hve-implement.md:25`, `hve-review.md:25`, `hve-challenge.md:25`, `hve-memory.md:37`. All reference `per CLAUDE.md's \`Artifact Discovery & Relevance\` section`. [HIGH]
- FC-01 verified: `hve-implement.md:25` now carries discovery reference where it was previously absent. Step 5.7 claim "discovery reference added to hve-implement.md (FC-01)" confirmed. [HIGH]
- RL-08 retention: `hve-memory.md:37` kept command-local mapping "this command's slug argument is `topic-slug`". [HIGH]
- Verdict: **RL-08 correctly deduplicated with topic-slug mapping retained. FC-01 closure verified.**

---

## Test Harness Verification

### Test 6 Retirement (RL-03 in test logic)

Claim: `test6_friction_flag_boilerplate` retired and folded into `CANONICAL_BLOCK_SPECS` with new row `friction_capture|1|identical`.

Evidence: `tests/run-drift-tests.sh:354-368` contains RETIRED banner with rationale: "The bespoke function was duplicated logic of test 10, so it was folded into the spec table (row `friction_capture`) rather than rewritten. Presence of the pointer in each command is covered by test 14 (it resolves) and, for the discovery pointer, test 15 (it is there at all)." [HIGH]

CANONICAL_BLOCK_SPECS entry at line 567: `friction_capture|1|identical|accept an optional \`--friction-log\` flag`. Grep for prefix in CLAUDE.md returns one match (`CLAUDE.md:109`). [HIGH]

**Verdict: Test 6 correctly retired with rationale recorded.**

### CANONICAL_BLOCK_SPECS Updates (RL-03 through RL-08)

Claim: `discovery_stub` 3→1, `concurrent_writes` 4→1, three new rows `friction_capture`, `security_checklist`, `shell_stays_in_parent` all `1|identical`.

Evidence at `tests/run-drift-tests.sh:564-579`:
- Line 565: `discovery_stub|1|identical|Phase commands discover their input artifacts from` — matches CLAUDE.md:243 [HIGH]
- Line 566: `concurrent_writes|1|identical|**Concurrent writes**` — matches CLAUDE.md:315 [HIGH]
- Lines 567-569: Three new `1|identical` entries with correct prefixes [HIGH]
- Spec table comment at `:552-556` correctly documents that `expected=1` is a **uniqueness assertion**, not duplication. [HIGH]

**Verdict: All spec entries updated correctly, uniqueness semantics documented.**

### Test 14 Implementation (Reference Resolution)

Claim: New test 14 asserts every `per CLAUDE.md's \`Section\` section` pointer resolves to a real heading.

Evidence: `tests/run-drift-tests.sh:936-1013`:
- Pattern definition at `:954-956` correctly anchors on backticks and the word "section". [HIGH]
- Helper `claude_md_headings()` at `:960-965` correctly extracts level 2+ headings from CLAUDE.md. [HIGH]
- Test body `:967-1013` performs literal string equality matching (not regex). [HIGH]
- Comment at `:950-952` correctly notes that regex metacharacters need no escaping (literal match). [HIGH]

Changes log Phase 5 claim: Test 14 resolves 6 distinct sections: `Artifact Discovery & Relevance`, `Concurrent Changes-Log Writes`, `Friction Capture`, `Security Hygiene`, `Subagent Dispatch Discipline`, `Untrusted Input`.

All six sections verified present in CLAUDE.md as headings. [HIGH]

**Verdict: Test 14 correctly implemented, all section references resolve.**

### Test 15 Implementation (Behavioral Presence)

Claim Phase 5: Assertion 1 (discovery pointers) only. Assertion 2 (record-skip branches) deferred to Phase 9.

Evidence: `tests/run-drift-tests.sh:1015-1101`:
- Comment at `:1030-1036` describes "ASSERTION 2 asserts..." but does not appear to name Phase 9 explicitly in the current text (changes log Phase 9 line 524 says "the deferred-assertion notice replaced by the rationale").
- Assertion 1 at `:1052-1074` checks discovery references; assertion 2 at `:1076-1101` checks record-skip markers.
- Both assertions present in the function now, which is correct for post-Phase 9 state.

The current file state reflects Phase 9's addition of assertion 2. Phase 5 changes log correctly claimed "assertion 1 only" and Phase 9 changes log correctly claimed it "added" assertion 2. Carrier floors are appropriate (5 discovering commands, 3 reconstructible consumers). [HIGH]

**Verdict: Test 15 correctly structured with both assertions present post-Phase 9. Phase 5 claim (assertion 1 only) deferred to Phase 9 per plan.**

---

## Coverage Assessment

**Planned steps:** 11 (5.1 through 5.11)
**Implemented steps:** 11
**Coverage: 100%**

All seven findings (RL-03, RL-04, RL-05, RL-06, RL-08, FC-01, RO-03) closed per plan Phase 5.

---

## Design Decisions Verified

- **DD-005 (Test 6 retirement):** Rationale recorded — it was duplicate logic of test 10. Folding into spec table preserves coverage (inverted to uniqueness). [HIGH]
- **DD-006 (Promote Concurrent writes section):** New section `## Concurrent Changes-Log Writes` prevents pointer rot (no longer "see the Hooks section"). Content byte-identical. [HIGH]
- **DD-007 (Discovery stub prefix repoint):** From "Discover inputs per the Artifact Discovery & Relevance convention" (existed only in copies) to "Phase commands discover their input artifacts from" (canonical CLAUDE.md sentence, line 243). Verified unique in CLAUDE.md. [HIGH]
- **DD-008 (RL-04 narrowing):** `*.pfx` and explicit `AKIA` dropped when consolidating. Acceptable because Phase 1 installer specifies five patterns; adding a sixth here would desynchronize. Trade-off disclosed. [HIGH]

---

## Cross-Reference: Parent-Supplied Changed-File List

Parent supplied 30 files from `git diff --name-only HEAD`. Phase 5 changes log cites modifications to:
- `.claude/commands/`: hve-research.md, hve-plan.md, hve-implement.md, hve-review.md, hve-pr-review.md, hve-challenge.md (6 files) [✓ all on list]
- `.claude/agents/`: hve-implementation-validator.md, hve-phase-implementor.md (2 files) [✓ all on list]
- `CLAUDE.md` (1 file) [✓ on list]
- `tests/run-drift-tests.sh` (1 file) [✓ on list]

No unlisted changes in Phase 5 section. All cited files appear in the parent-supplied changed-file list. [HIGH]

---

## Test Gate Results

Claimed baseline exit for Phase 5: **drift 218 passed, 0 failed** (was 211/0; +7 delta), **install 66 passed, 0 failed** (unchanged from Phase 1/4 baseline).

Delta accounting per changes log Phase 5, Test Delta table:
- Test 6 retired: -7 (1 count + 6 identity assertions)
- `discovery_stub` 3→1: -2 (was 1 count + 3 identity; now 1 count + 1)
- `concurrent_writes` 4→1: -3 (was 1 count + 4 identity; now 1 count + 1)
- Three new uniqueness rows: +6 (friction_capture, security_checklist, shell_stays_in_parent)
- New test 14: +7 (1 pointers-present + 6 distinct sections)
- New test 15: +6 (5 per-command + 1 carrier floor)
- **Net: -7 - 2 - 3 + 6 + 7 + 6 = +7** [HIGH]

Negative control run documented at changes log Phase 5, line 313: pointing `hve-memory` at nonexistent section and adding a concurrent-writes copy produced failures in test 10 and test 14. Files restored, suite returned to 218/0. [HIGH]

---

## Conclusion

Phase 5 successfully completed all 11 steps as planned. All five deduplicated blocks (Friction Capture, Security Hygiene, Shell stays in parent, Concurrent writes, Discovery stub) are now single carriers in CLAUDE.md with correct references in dependent files. File-specific mechanics (validator Input validation bullets, command security check recording requirements, command-local slug mappings) correctly retained. Test 6 retired with justification; tests 14 and 15 added with correct assertions and boundaries. DD-005 through DD-008 all properly recorded and verified.

**Status: PASS**
