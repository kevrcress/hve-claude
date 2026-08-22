# Planning Log: Remediate the 2026-08-10 full-repo senior review

Date: 2026-08-15
Task slug: full-repo-review-remediation
Plan: `.claude-hve-tracking/plans/2026-08-15/full-repo-review-remediation-plan.md`

## Design Decisions

### DD-001: No research artifact; the review IS the research
Source: Artifact Discovery & Relevance convention requires recording a skip of a reconstructible input rather than proceeding silently.
Decision: Planned directly from `.claude-hve-tracking/reviews/pr/main/2026-08-10-full-repo-review.md` with no research phase.
Rationale: The review carries `file:line` evidence per finding, independently re-verified for a ~10-finding sample per its own method note (review artifact, line 5). Re-researching verified evidence would add cost without adding confidence.
Assumption: The review's line citations are still accurate at `1c2e53e`, the commit it was taken against, and no commits have landed since. [HIGH] Verified: `git log` shows `1c2e53e` is HEAD; spot-checks of `hve-review.md:19`, `hve-implement.md:3,19`, `install.sh:239-240`, and `tests/run-drift-tests.sh:551` all matched the review's quoted text exactly.
Risk: Low. Any stale citation surfaces immediately as a failed anchor match during implementation.
Status: Resolved.

### DD-002: `--think` removed from `hve-implement`, not wired
Source: FC-02 found both `MODE` and `THINK_MODE` parsed and never referenced in `hve-implement.md`. The user's decision covered `--mode` (wire it) but `--think` is a separate axis.
Decision: Remove `THINK_MODE` from the parse list at `hve-implement.md:19`.
Rationale: `--think` is not in that file's argument-hint (line 3), so removing it is not a user-visible flag removal. Extended reasoning benefits synthesis and judgment steps (planning, review verdicts), which is why `hve-plan` and `hve-review` carry it. Implement executes an already-reasoned plan.
Assumption: No caller passes `--think` to `/hve-implement` expecting behavior. [HIGH] The flag was never advertised in the argument-hint.
Risk: Low. Reversible in one line if a reasoning-heavy step is later added to implement.
Status: Resolved. Flag this in the Phase 4 user checkpoint if the user wants it wired instead.

### DD-003: RL cluster sequenced early (Phase 5), not last
Source: Task constraint required picking one ordering explicitly and stating why.
Decision: RL deduplication runs at Phase 5, before the remaining behavioral and documentation phases; those phases are written against the reduced surface.
Rationale: Three reasons, detailed in the plan's Sequencing Decision section. Briefly: FC-01 and RL-08 resolve to the same one-line edit and would otherwise be done twice in opposite directions; RL-02's fallback collapses from 4 sites to 1; tests 6 and 10 change expectations exactly once instead of twice.
Assumption: Phases 1-4 are disjoint from the RL carrier set. [HIGH] Verified: `install.sh` is outside `canonical_block_corpus()` (`tests/run-drift-tests.sh:565-573`); `hve-pr-reviewer.md:43` is the RL precedent, not a carrier; SC-02/03 edit frontmatter only.
Risk: Medium. Phases 2 and 3 introduce new shared text, which if duplicated becomes a fresh RL violation the Phase 5 sweep would have to catch. Mitigated by making reference-style authoring a hard requirement on those phases, stated in the plan.
Status: Resolved.

### DD-004: Coverage swap rather than assertion deletion for RO-03
Source: Task constraint: "The plan must say what replaces that coverage, not just delete the assertions."
Decision: Invert tests 6 and 10 from "N copies must be byte-identical" to "exactly 1 carrier may exist," and add two net-new tests: reference resolution (test 14) and behavioral presence (test 15).
Rationale: Dedup changes the failure mode from "copies diverge" to "pointer dangles." The inversion catches re-introduced copies; test 14 catches the new failure mode; test 15 addresses RO-03's actual structural complaint, that the suite checks boilerplate consistency rather than whether documented behavior is implemented. Precedents already in the suite: test 9 and test 12 both do reference resolution; test 11 does array sync.
Assumption: A `grep`-based heading-resolution check is expressible in the existing bash harness without new dependencies. [MEDIUM] The harness already does fixed-string carrier discovery and file-existence resolution (tests 9, 12), so the primitives exist. Guard step: if heading extraction proves brittle, fall back to asserting the referenced section name appears as a `##`/`###` line in CLAUDE.md, which is the same check with a looser matcher.
Risk: Medium. Net coverage after the swap is higher than before, but only if Steps 5.9 and 5.10 actually land. Phase 5 is defined as incomplete until they do.
Status: Resolved.

### DD-005: `--dimension` gets a security floor AND a partial-coverage annotation
Source: Open question 1 in `.claude-hve-tracking/memory/2026-07-28/resume-verification-follow-up-defects.md:14`.
Decision (user, 2026-08-15): Always dispatch the security dimension alongside the requested one, and annotate which dimensions were not covered.
Rationale: The verdict rules at `hve-pr-review.md:145-148` include a security-Critical block rule that silently did not apply to filtered runs. A floor keeps that rule meaningful. The annotation is still required because the other six dimensions remain uncovered, so the floor alone would still overstate coverage.
Consequence: DEFECT 3 resolves the same way, making `hve-implementation-validator`'s contract consistent with its own `:152` "never skip security" constraint.
Assumption: The prompt twin `.claude/prompts/pull-request.md` must be updated in the same step. [HIGH] Verified: `tests/run-drift-tests.sh:819` maps `pull-request.md|hve-pr-review.md`, and the baseline run shows test 13 asserting `--dimension` resolves.
Status: Resolved.

### DD-006: `--mode` wired on both `hve-review` and `hve-implement`
Source: Open question 2 in the same memory file (`:15`), plus FC-02.
Decision (user, 2026-08-15): Wire it on both rather than removing it.
Correction (2026-08-15): An earlier framing of this decision claimed that wiring `--mode` on `hve-implement` would require inventing a scaling axis. That was wrong and the user challenged it. `hve-implement.md` already carries both branches `--mode` would gate: the Simple carve-out at `:88` ("do NOT spawn subagents. Implement directly in this session") corresponds exactly to `hve.md`'s `--mode lightweight` row, and parallel execution at `:107` ("if phases have no dependencies on each other, spawn their subagents in parallel") corresponds exactly to `--mode full`. Wiring is the same override one-liner as `hve-plan.md:43`. No new axis is introduced.
Consequence: Wiring `--mode` on `hve-review` also closes PS-05, which found Phase 3 always spawns exactly one validator with no mode or difficulty branch. One change, two findings.
Assumption: No `.claude/prompts/` twin maps to either command, so argument-hint edits do not ripple under test 13. [HIGH] Verified against the map at `tests/run-drift-tests.sh:818-823`.
Status: Resolved.

### DD-007: SC-01 needs a new install-suite test, not a drift-test edit
Source: SC-01, plus the hard constraint that install.sh changes be verified against a scratch target.
Decision: Add coverage to `tests/run-install-tests.sh`; leave drift test 4 alone.
Rationale: Drift `test4_gitignore_hygiene()` asserts against `${GITIGNORE}`, this repo's own root `.gitignore`, which the review confirms is already correct. The broken path is propagation to newly installed projects, which only the install suite exercises. Editing test 4 would assert the wrong thing in the wrong place.
Assumption: [HIGH] Verified by reading `test4_gitignore_hygiene()` in `tests/run-drift-tests.sh`.
Status: Resolved.

### DD-008: Addendum DEFECT 4 deferred
Source: `.claude-hve-tracking/memory/2026-07-28/resume-verification-follow-up-defects.md:21`.
Decision: Not planned.
Rationale: The source file marks it "Optional DEFECT 4 (design gap, lower priority)" and the task scoped in DEFECTS 1-3 by name. Recorded in the plan's Deferred Items table rather than dropped, so it is visible rather than lost.
Status: Resolved (deferred, not closed).

## Discrepancy Log

### DD-009: Cross-phase test 15 dependency not reconciled in Phase 5 success criteria
Source: Plan Phase 5 success criteria (line 152) vs. Details doc section 2, "New test 15: behavioral presence" (lines 111-117)
Assumption: Test 15 will fully pass at the Phase 5 boundary gate.
Risk: Phase 5's gate ("full suite green") will fail if test 15's second assertion hasn't been added yet. Implementor lacks explicit guidance on handling the failing assertion during Phase 5.
Severity: Major
Recommendation: Revise Phase 5 success criteria to read: "tests 14 and 15 exist; test 14 passes fully; test 15's first assertion (discovery references) passes, second assertion (record-skip branches) expected to fail until Phase 9 lands; drift and install suites green." Alternatively, split test 15 across phases in Step 5.10 and Step 9.4 plan text (not just in details), making the phase boundary explicit.

Resolution (parent, 2026-08-15): Finding accepted after independent check against the plan text. The second alternative was taken; the first was rejected because it would ship a knowingly-failing assertion at a phase boundary, which violates the task's hard constraint that both suites pass at every phase boundary, not only at the end. Changes applied:
- Phase 5 success criteria now read "test 15 exists with **assertion 1 only** and passes," followed by an explicit paragraph naming this as the plan's only intentional cross-phase test dependency.
- Step 5.10 now states assertion 1 only, defines it as a carrier-count floor, and forbids writing assertion 2 in that phase.
- Step 9.4 is now the step that adds assertion 2, with Step 9.1 named as its precondition inside the same phase. Prior Step 9.4 (run both suites) renumbered to Step 9.5.
Also applied from the validator's follow-on checklist: Step 5.10 gained an explicit `[HIGH]` assumption binding Steps 5.9/5.10 to the Reference Syntax Contract in details section 5, since test 14's extractor depends on that exact form.
Answer to the validator's clarifying question: the Finding Coverage Map counts do not change. Splitting test 15 is a step-level implementation detail, not a new or reassigned finding. Totals stay 42 assigned, 0 unassigned; Phase 9 simply gains a step (3 findings, 5 steps).
Status: Resolved.

---

## Discrepancies from the source artifacts

### DR-001: Review's RL preamble says four instances; the cluster is five
Source: Review artifact line 94: "RL-03 through RL-06 below are four instances of one systemic pattern... One fix closes all four." The verdict paragraph at line 20 similarly says "several (RL-01 through RL-04) share one root cause."
Finding: RL-08 (`hve-memory.md:37-42` restating the discovery algorithm) is the same pattern and the same fix, so the cluster is five: RL-03, RL-04, RL-05, RL-06, RL-08. RL-01 and RL-02 are named in the verdict paragraph's range but are *not* duplication findings; RL-01 is a self-contradicting instruction and RL-02 is a missing fallback. They do not share the dedup fix.
Resolution: Plan groups RL-03/04/05/06/08 into Phase 5 (the dedup sweep) and RL-01/02/07 into Phase 6 (convention gaps). The task brief's grouping (RL-03/04/05/06/08 as one systemic pattern) is followed over the review preamble's narrower count.
Status: Resolved.

### DR-002: FC-01's fix is a Phase 5 edit, not a Functional Correctness edit in isolation
Source: FC-01 is filed under Functional Correctness; the natural reading is "add the missing discovery rule to `hve-implement.md`."
Finding: Adding it as a verbatim copy would raise `test10: discovery_stub` from 3 carriers to 4, and Phase 5's RL-08 step would then reduce it again. Both edits touch the same test spec.
Resolution: FC-01 is executed as Step 5.7 inside the dedup phase, so the `discovery_stub` expectation changes exactly once (Step 5.8). Recorded here because it moves a finding out of its review dimension's natural phase.
Status: Resolved.

### DR-003: Review's own tally footnote vs. the coverage map
Source: Review artifact line 222 states DO-01 is "Counted once under FC-02" and "not separately tallied."
Finding: DO-01 is nevertheless a distinct edit (a `CLAUDE.md` Command Reference row) from FC-02 (dead flag in the command file). Treating it as fully subsumed would leave the doc row unfixed.
Resolution: Both appear in the Phase 7 coverage map as separate steps (7.2/7.3 for FC-02, 7.4 for DO-01) while remaining one root cause. The plan's total of 42 counts DO-01 once, consistent with the review's 39-finding tally.
Status: Resolved.

## Plan-time verification performed

Checks that actually ran during planning, with the command and its outcome:

| Check | Command | Result |
|---|---|---|
| Drift baseline | `./tests/run-drift-tests.sh` | `Results: 211 passed, 0 failed` |
| Install baseline | `./tests/run-install-tests.sh` | `Results: 48 passed, 0 failed` |
| SC-01 patch syntax | `bash -n install.sh` (patched copy) | `SYNTAX OK` |
| SC-01 fresh install | patched `install.sh` into fresh `git init` target | all 5 credential patterns present (5/5 PASS) |
| SC-01 idempotency | second run against same target | each pattern x1, header x1, no duplicates |
| SC-01 pre-populated target | target with existing `.env` and `*.key` | no duplicates; adds only the 3 missing patterns |
| SC-01 regression | `./tests/run-install-tests.sh` (patched) | `Results: 48 passed, 0 failed` |
| Prompt-command map | read `tests/run-drift-tests.sh:818-823` | no twin maps to `hve-review.md` or `hve-implement.md` |
| Argument-parse duplication | `grep -n "MODE" .claude/commands/hve-{review,implement}.md` | one hit each, at line 19 only; confirms FC-02 and DEFECT 2 |

Not verifiable at plan time: the Phase 5 test rewrites (tests 6, 10, 14, 15) cannot be validated without writing them, so their assumptions are marked `[MEDIUM]` with guard steps in the plan (DD-004).
