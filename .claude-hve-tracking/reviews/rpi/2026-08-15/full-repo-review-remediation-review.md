# Review Log: Remediate the 2026-08-10 full-repo senior review

Date: 2026-08-15
Plan: `.claude-hve-tracking/plans/2026-08-15/full-repo-review-remediation-plan.md`
Changes: `.claude-hve-tracking/changes/2026-08-15/full-repo-review-remediation-changes.md`
Research: none — recorded absent by design in the plan header (`Research: none - remediation driven by review artifact .claude-hve-tracking/reviews/pr/main/2026-08-10-full-repo-review.md`). Reduced-scope review: research-to-plan traceability cannot be checked; plan-to-implementation traceability is checked in full against the source review artifact instead.
Details: `.claude-hve-tracking/details/2026-08-15/full-repo-review-remediation-details.md`
Overall Status: ✅ Complete

## Review Scope

- Base for the changed-file list: `HEAD` (`1c2e53e`). The merge-base with `main` equals `HEAD`, so every remediation edit is uncommitted working-tree change.
- 30 files changed. All eleven plan phases are marked Complete in the changes log.
- Parent-run dispatch note: the eleven `hve-rpi-validator` runs (Phase 2) and the single
  `hve-implementation-validator` run (Phase 3) were dispatched in one batch rather than in two
  sequential waves. Phase 3's inputs (files-modified list, plan path, research status) do not
  depend on any Phase 2 output, so the sequencing carries no information dependency. Recorded
  here because it deviates from the command's literal phase order.

## Independent Test Verification (parent-run, not taken from the changes log)

Both suites were re-run by the reviewer against the working tree before any validator finding was accepted:

```
./tests/run-drift-tests.sh    -> Results: 248 passed, 0 failed
./tests/run-install-tests.sh  -> Results: 66 passed, 0 failed
```

These match the changes log's Final Test Pass claim exactly (drift 248/0, install 66/0). The
implementation's headline test claim is therefore verified, not trusted. Validators were told
test counts were out of their scope for this reason.

## Phase Reviews

Eleven `hve-rpi-validator` runs, one per Complete phase. Each output file is named
`full-repo-review-remediation-phase-0NN-validation.md` in this directory.

| Phase | Validator verdict | Severity-tagged items in its file | Accepted defects |
|---|---|---|---|
| 1 — Installer credential rules (SC-01) | Pass | none | 0 |
| 2 — Untrusted-input guard (SC-04, SC-05) | Pass | none | 0 |
| 3 — Security coverage floor (DEFECT 1, 3) | Pass | 1 Minor | 1 Minor |
| 4 — `tools:` frontmatter (SC-02, SC-03) | Pass with plan-criterion observation | none | 1 Minor (plan wording, see PR-004) |
| 5 — RL dedup + coverage swap | Pass | none | 0 |
| 6 — Convention gaps (RL-01, 02, 07) | Pass | none | 0 |
| 7 — Flag correctness | Pass | none | 0 |
| 8 — Dispatch bounds (PS cluster) | Pass | 3 Minor | 3 Minor |
| 9 — Fallbacks + corrections protocol | Pass | none | 0 |
| 10 — Subagent Response Protocol (II-01..07) | Pass | 4 Critical, 1 Major — **all rejected, see below** | 0 |
| 11 — Documentation sync (DO cluster) | Fail: 3 Critical | 3 Critical — **all reclassified, see below** | 2 Minor + 1 Minor `[pre-existing]` |

### Rejected findings (Phase 10)

`full-repo-review-remediation-phase-010-validation.md` tags five items `[CRITICAL]`/`[MAJOR]`,
but every one of them is a statement that the implementation is **correct**, not a defect. RV-001
reads "All three agent Response Formats now correctly implement the six-part protocol"; RV-002
"All four QA criterion carriers now reference CLAUDE.md… instead of paraphrasing"; RV-003 "Test 7
now enforces the protocol for all 9 agents"; RV-004 the Verdict template "was updated… consistent
with the Response Format"; RV-005 "Step 10.4 scope expansion was necessary for internal
consistency." The validator's own status line is `Pass`.

These are severity labels misapplied to passing checks. **All five are rejected as tally items**
(0 Critical, 0 Major from Phase 10). The underlying verification work is sound and is accepted as
evidence that Phase 10 met its success criterion. Parent judgment per the contested-severity rule.

### Reclassified findings (Phase 11)

The Phase 11 validator returned `Fail: 3 critical`. Each was checked against the files by the
parent before being acted on; none survives at Critical.

- **RV-001 → Minor, and narrowed.** Claim: seven commands implement `--subagent-model` and/or
  `--friction-log` but the flags are absent from the `CLAUDE.md` and `README.md` reference rows.
  Verified: 8 commands carry `--subagent-model`, 6 carry `--friction-log`. **The CLAUDE.md half of
  the claim is rejected** — both flags are documented centrally and deliberately, at `CLAUDE.md:68`
  ("Every subagent-dispatching command accepts this flag") and `CLAUDE.md:109` (which names all six
  dispatching commands). Repeating them across eight table rows is precisely the duplication the RL
  cluster spent Phase 5 removing, so their absence from the rows is a design choice, not a defect.
  What survives is the README half: `grep` for either flag across `README.md` returns **nothing**,
  so a README-only reader cannot discover either flag anywhere. Genuine but Minor, and outside all
  39 source findings.
- **RV-002 → Minor.** Test 14 scans `.claude/**` only, so `CLAUDE.md`'s own internal pointers are
  unenforced. Verified: both self-references (`CLAUDE.md:359` and the line-wrapped one at `:381-382`)
  currently resolve to `## Security Hygiene` at `CLAUDE.md:290`. Nothing is dangling today; this is a
  coverage gap in new test code, already disclosed by the implementation in Open Items Carried to Review.
- **RV-003 → Minor `[pre-existing]`, excluded from the tally.** `docs/` sits outside
  `canonical_block_corpus()`. Verified against the base commit: `git show HEAD:tests/run-drift-tests.sh`
  shows the function already covered only `COMMANDS_DIR`, `AGENTS_DIR`, `PROMPTS_DIR`, and `CLAUDE_MD`.
  The exclusion predates this change and was untouched by it, so per the pre-existing-defect rule it is
  recorded and excluded from the verdict tally.

## Quality Findings

One `hve-implementation-validator` run in `full-quality` mode across all 11 dimensions.
Output: `full-repo-review-remediation-quality.md`. Verdict: **Pass — no Critical, no Major.**

It verified by execution rather than by reading the log: it re-ran both suites, executed the
installer into scratch targets (fresh / re-run / seeded / global), and read the implementations of
tests 7, 14, and 15 to judge non-vacuity directly instead of trusting the logged negative controls.
All matched the changes log's claims.

Minor findings (counts and titles copied from that file):

- **IV-001 [Minor]** — `tests/run-drift-tests.sh` reuses the identifier `carriers` as both an array
  (in `assert_canonical_block`) and a scalar (in `test15_behavioral_presence`), producing shellcheck
  SC2178/SC2128 noise. No runtime bug; 248/0 confirms. Worth renaming. **Not previously disclosed.**
- **IV-002 [Minor]** — DD-008's consolidation dropped `*.pfx` from the validator's own
  gitignore-hygiene check, a real but small narrowing of dimension 9 coverage. Already disclosed by
  the implementation.
- **IV-003 [Minor]** — `hve-phase-implementor.md` still lacks `tools:`. Already disclosed (DR-401/DD-401).
- **IV-004 [Minor]** — `docs/` and `README.md` remain outside the drift suite's canonical-block corpus.
  Already disclosed. Same underlying gap as Phase 11 RV-003; see the dedup note in the tally.
- **IV-005 — not a repo defect.** The validator reported that an unrelated MCP server-instructions
  block (otter.ai) appeared in its session context, and recorded that it invoked nothing and acted
  on nothing. That block is ordinary harness configuration, not content originating in this repo or
  its diff, so it is not a finding against the change. It is noted here only because the validator
  correctly followed the very `Untrusted Input` rule this remediation added — reporting rather than
  acting — which is incidental evidence the new rule works.

## Security Findings

**No Critical or Major security findings.** Dimension 9 is where this change concentrates, and it
moved the security posture forward rather than back:

- `install.sh` now writes five credential patterns (`.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`)
  into every project it installs into. Verified by execution against fresh, re-run, and seeded
  scratch targets by both the implementation and the quality validator independently; idempotent,
  and it never duplicates or disturbs a user's pre-existing rules.
- The three credential lists (`CLAUDE.md`, `install.sh`, `tests/run-drift-tests.sh`) were confirmed
  to name the same five patterns in the same order.
- A canonical `## Untrusted Input` section was added and is referenced from the two agents that
  consume attacker-controllable content (`hve-pr-reviewer` reads diffs, `hve-researcher` fetches web
  pages). This closes a genuine prompt-injection exposure that had no rule at all before.
- The security-coverage floor means no `/hve-pr-review` or `/hve-review` invocation path can now
  produce a severity-graded verdict with zero security coverage. All eight paths were independently
  re-derived by the Phase 3 validator.

One disclosed narrowing: `*.pfx` and the explicit `AKIA` prefix were dropped when the duplicated
checklist was consolidated (IV-002 / DD-008). `AKIA` is subsumed by the canonical "AWS/GCP key
prefixes" wording, so nothing is lost there. `*.pfx` is a real if small coverage reduction, honestly
flagged, and deliberately deferred as a feature question rather than widened mid-remediation — which
would have desynchronized the three lists that Phase 11 verified agree.

## Record Consistency

[populated in Phase 1 — see below, finalized after validation]

### Parent scan (changes log read end-to-end, 2026-08-15)

Arithmetic chains were checked for internal agreement first:

- Drift totals across phases: 211 → 218 (P5) → 219 (P6) → 219 (P7) → 219 (P8) → 229 (P9) → 248 (P10) → 248 (P11). The Final Test Pass delta table attributes +7/+1/+10/+19 to phases 5/6/9/10; 211+7+1+10+19 = 248. Agrees.
- Install totals: 48 → 66 (+18, Phase 1's `test6_gitignore_credentials`). Agrees.
- Test 14 distinct-section inventory: 6 (P5) → 7 (P6) → 13 (P9) → 14 (P10). Agrees with each phase's own stated delta.

Candidate contradiction carried to the validators for a ruling:

- **RC-001 (candidate, Minor)**: Phase 2's test line reads `install 48 passed, 0 failed — both match the session baseline exactly; no delta`, while its concurrent siblings Phase 1 and Phase 4 both report `install 66`. A phase-by-phase reader sees 66 / 48 / 66 / 66 with no in-place annotation on the 48. The mechanism is explained in three other places (the Test Baseline rebaseline note, Phase 2's own fourth Issues bullet disclaiming that its run cannot speak to in-flight sibling edits, and Phase 4's advisory deriving 48→66), so this may be a correctly-disclosed snapshot of a concurrent run rather than a falsified claim needing a dated Correction.

Confirmed working instance of the corrections convention (not a finding):

- Phase 5 carries a `#### Corrections` entry dated 2026-08-15 retracting a fabricated `Completed:` timestamp and replacing it with the value an actual `date -u` call returned.

## Tally

Every number below traces to a validation output file in this directory.

Raw severity-tagged items as written by the validators, before parent adjudication:

| Source file | Critical | Major | Minor |
|---|---|---|---|
| phase-003-validation | 0 | 0 | 1 |
| phase-008-validation | 0 | 0 | 3 |
| phase-010-validation | 4 | 1 | 0 |
| phase-011-validation | 3 | 0 | 0 |
| quality | 0 | 0 | 4 |
| all other phase files | 0 | 0 | 0 |
| **Raw total** | **7** | **1** | **8** |

Parent adjudication, with rationale recorded per the contested-severity rule:

- −4 Critical, −1 Major: every Phase 10 item is a confirmation that the implementation is correct,
  mislabeled with a severity tag. Its own status line is `Pass`. Rejected as tally items.
- −3 Critical, +3 Minor: the Phase 11 Criticals were each checked against the files and none
  survives at Critical (see Reclassified findings above). One of the three is `[pre-existing]`.
- −1 Minor (pre-existing exclusion): `docs/` outside `canonical_block_corpus()` is verified present
  on the base commit and untouched by this change.
- −1 Minor (dedup): quality IV-004 and Phase 11 RV-003 are the same defect reported by two
  validators. Merged, keeping the higher severity assigned to either — both graded Minor.
- Phase 8's three Minor items each state "no defect" in their own body (they record that a
  parent-added step was authorized and properly annotated). Retained in the count as recorded
  observations rather than promoted or discarded, since they are genuine record notes.

**Adjudicated total: 0 Critical, 0 Major, 9 Minor** (plus 1 Minor `[pre-existing]`, excluded).

Of the 9 Minor items, 7 were already self-disclosed by the implementation before review. Only two
are new: quality IV-001 (the `carriers` shellcheck identifier collision) and the surviving half of
Phase 11 RV-001 (`README.md` documents neither `--subagent-model` nor `--friction-log` anywhere).

## Record Consistency — ruling

**Consistent.** The changes log's arithmetic chains all agree, and the one candidate contradiction
(RC-001) resolves in the implementation's favour: Phase 2's `install 48` is a timestamped
observation that was true when its concurrent run happened, and the mechanism is explained in three
separate places. It is not a falsified claim.

Record-only edit applied by this review, per the CLAUDE.md corrections convention and the
record-only-corrections rule: the Phase 2 test line is now annotated
`(superseded — see Correction 2026-08-15…)` and a dated `#### Corrections` entry was appended to
that section explaining the concurrency and stating that no Phase 2 conclusion depended on the
install figure. This does not route the task to Needs Rework.

The log's own corrections discipline was already working before review: Phase 5 carries a dated
Correction retracting a fabricated `Completed:` timestamp and replacing it with an actual clock
reading. That is the convention catching a real defect unprompted.

## Summary

Status: ✅ Complete
Critical: 0 | Major: 0 | Minor: 9 (+1 pre-existing, excluded)
Record consistency: ✅ Consistent (one record-only Correction appended by this review)

All eleven plan phases validated. Both suites verified green by the reviewer independently of the
implementation's claims (drift 248/0, install 66/0), and the installer verified by execution rather
than by diff reading. The verdict threshold for ✅ Complete (no Critical, ≤ 2 Major) is met with
margin.

### Post-review disposition (2026-08-15, same session)

Four of the six follow-on items below were closed immediately after the checkpoint on the user's
decision. Detail in the changes log's `## Post-Review Remediation` section.

| Item | Disposition |
|---|---|
| IV-001 `carriers` collision | **Closed.** Test-15 scalar renamed `discovery_carriers`. |
| Phase 11 RV-001 (README flags) | **Closed.** New "Flags every dispatching command accepts" subsection in `README.md`; not duplicated into eight rows. |
| IV-002 `*.pfx` | **Closed, decision reversed.** Widened to six patterns across all 11 sites rather than confirming five. User's call at the review checkpoint. |
| Phase 4 criterion overreach | **Closed.** Plan criterion amended to the two agents actually scoped, with the DR-401 rationale inline. |
| Plan bookkeeping | **Closed.** `Status: Complete`, 60 checkboxes checked. |
| IV-004 `docs/` outside corpus `[pre-existing]` | **Still open.** Not attempted; unchanged from base. |

Post-change verification, run after these edits: drift **249 passed / 0 failed**, install
**69 passed / 0 failed** (+1 / +3, both fully attributable to the sixth credential pattern), and the
installer re-verified by execution against fresh, re-run, seeded, and global-mode targets. The
review verdict is unaffected: these edits closed Minor items and introduced no new ones.

### Follow-on items (none blocking)

- [ ] Rename the scalar `carriers` counter in `test15_behavioral_presence` to clear the shellcheck
      SC2178/SC2128 collision (IV-001).
- [ ] Add `--subagent-model` and `--friction-log` to `README.md` somewhere — a short "flags common to
      all dispatching commands" note, not eight repeated table cells (Phase 11 RV-001, narrowed).
- [ ] Decide the `*.pfx` question: either add it to all three credential lists together, or record
      that five is final (IV-002 / DD-008).
- [ ] Consider extending `canonical_block_corpus()` to `docs/*.md` and `README.md`, or add a
      dedicated README ↔ CLAUDE.md Command Reference sync test (IV-004, `[pre-existing]`).
- [ ] Amend the plan's Phase 4 success criterion, which reads "all 9 agents declare `tools:`" when 8
      is correct and intended. Both the implementor (DR-401) and the Phase 4 validator independently
      concluded the criterion wording overreached, not the implementation.
- [ ] Plan-file bookkeeping: `Status:` is still `Draft` and all 60 step checkboxes are still
      unchecked, while the changes log records every step complete. Left untouched by this review so
      the validated artifacts were not altered under it.
