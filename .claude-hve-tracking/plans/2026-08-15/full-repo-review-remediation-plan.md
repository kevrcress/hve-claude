# Implementation Plan: Remediate the 2026-08-10 full-repo senior review

Date: 2026-08-15
Task slug: full-repo-review-remediation
Research: none - remediation driven by review artifact `.claude-hve-tracking/reviews/pr/main/2026-08-10-full-repo-review.md`
Addendum: `.claude-hve-tracking/memory/2026-07-28/resume-verification-follow-up-defects.md` (DEFECT 1-3)
Branch: `fix/full-repo-review-remediation`
Status: Complete (implemented 2026-08-15; reviewed and signed off 2026-08-15, verdict Complete)

## Overview

Close all 39 findings from the 2026-08-10 full-repo review plus 3 addendum defects, grouped by root cause rather than finding ID. Eleven phases: the two outward-facing security defects land first (SC-01 installer, SC-04 untrusted input), the systemic text-duplication cluster (RL) lands at Phase 5 so every later phase edits a reduced surface, and the remaining behavioral, protocol, and documentation fixes follow against that reduced surface.

Every finding is assigned to a numbered step. Nothing is deferred except addendum DEFECT 4, which is explicitly out of scope (see Deferred Items).

---

## Baseline (captured 2026-08-15, before any edit)

Both suites green at `1c2e53e` on branch `fix/full-repo-review-remediation`:

```
./tests/run-drift-tests.sh    -> Results: 211 passed, 0 failed
./tests/run-install-tests.sh  -> Results: 48 passed, 0 failed
```

This is the gate every phase boundary must return to. [HIGH] Verified by running both commands; output quoted verbatim above.

---

## Sequencing Decision: the RL cluster runs EARLY (Phase 5), not last

The RL deduplication rewrites text that other phases also edit, so the two orderings had to be chosen between explicitly. **Decision: run it early, at Phase 5, and write every later phase against the reduced surface.**

Why early beats last:

1. **FC-01 and RL-08 are the same edit.** FC-01 wants `hve-implement.md` to carry the discovery rule; RL-08 wants `hve-memory.md` to stop restating it. Both resolve to "carry the one-line reference." Running RL last would mean FC-01 first pastes a fourth verbatim copy of the discovery stub (bumping `test10: discovery_stub` from 3 to 4), then RL-08 tears it back out. Two test-expectation edits for one net change.
2. **RL-02 collapses from four sites to one.** The missing instructions-file fallback is currently absent from `hve-implement.md:42` and three points in `hve-phase-implementor.md`. After dedup it is authored once in the canonical location. Writing it four times first, then merging, is pure churn.
3. **Test churn happens once.** Tests 6 and 10 assert byte-identical duplication of exactly the blocks RL removes. Deduplicating last would mean every earlier phase edits those blocks under the old assertions, then Phase N rewrites the assertions. Early dedup means each expectation changes exactly once, in the phase that causes it.

Why Phases 1-4 still precede it: SC-01, SC-04/05, DEFECT 1/3, and SC-02/03 are **disjoint from the RL carrier set**, verified below, so putting the outward-facing security work first costs nothing in rework and satisfies the ordering requirement that findings affecting other people land first.

Disjointness evidence [HIGH]:
- `install.sh` is not in the drift-test canonical-block corpus (`canonical_block_corpus()` at `tests/run-drift-tests.sh:565-573` covers `.claude/commands/*.md`, `.claude/agents/*.md`, `.claude/prompts/*.md`, `CLAUDE.md` only). SC-01 cannot collide with RL.
- `hve-pr-reviewer.md:43` is cited by the review as the *precedent* that already references instead of duplicating, not as an RL carrier. SC-04 edits that file without touching an RL block.
- SC-02/SC-03 edit YAML frontmatter (`tools:` lines), which no RL finding touches.

**Consequence for Phases 2 and 3:** any new shared text they introduce (the untrusted-input guard, the security-floor rule) must be authored in reference style from the start, canonical in `CLAUDE.md` plus a one-line pointer, so the Phase 5 sweep does not have to revisit them. This is a hard requirement on those phases, not a preference.

---

## What replaces the drift coverage the RL cluster removes (RO-03)

RO-03 observes that the suite verifies textual consistency of duplicated boilerplate, not that documented behaviors are implemented. Deduplicating removes what tests 6 and 10 currently assert on. Deleting those assertions without replacement would be a net loss of coverage, so Phase 5 swaps them for three checks that are strictly stronger:

| Removed assertion | Replacement | Precedent in this suite |
|---|---|---|
| `test6` friction block byte-identical across 6 commands | **Inverted to uniqueness**: the block may exist in exactly 1 file (`CLAUDE.md`). A re-introduced copy fails the test. | Same spec table, `expected=1` |
| `test10 concurrent_writes\|4\|identical`, `discovery_stub\|3\|identical` | Same inversion to `expected=1` | `CANONICAL_BLOCK_SPECS` at `tests/run-drift-tests.sh:550` |
| (nothing today) | **New test 14, reference resolution**: every `per CLAUDE.md's <Section>` pointer in `.claude/**/*.md` must resolve to a real `##`/`###` heading in `CLAUDE.md`. This is the failure mode dedup *introduces* (dangling pointer) and nothing currently catches it. | test 9 (agent roster references resolve), test 12 (dispatching commands name a resolvable agent) |
| (nothing today) | **New test 15, behavioral presence**: every artifact-discovering command carries a discovery reference, and every reconstructible-input consumer carries a record-skip branch. Asserts the *behavior* is present, which is RO-03's actual complaint. | test 11 (instruction array sync) |

Net: coverage moves from "N copies agree" to "exactly 1 copy exists, every pointer to it resolves, and the behavior it documents is present in each consumer." Tests 14 and 15 are net-new coverage that did not exist before this remediation.

---

## Phases

### Phase 1: Installer ships the credential rules its own CLAUDE.md asserts (SC-01)

Dependencies: none
Estimated scope: `install.sh` (~10 lines), `tests/run-install-tests.sh` (~20 lines)
Risk grade: **Medium minimum** per the CLAUDE.md risk override (code consumed outside this repo)
Success criteria: a fresh `./install.sh <target>` writes all five credential patterns to the target `.gitignore`; re-running adds no duplicates; install suite green.

Steps:
- [x] Step 1.1: Add `add_ignore` calls for `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` after the two existing tracking rules at `install.sh:239-240`, under a `# HVE security hygiene: never commit credentials` header guarded by a `grep -qF` existence check.
  - Assumption: the existing `add_ignore` helper's `grep -qxF` guard makes each rule idempotent and skips patterns the project already lists. [HIGH] Verified by spike, see below.
- [x] Step 1.2: Add install-suite test asserting a fresh install writes all five patterns, that a second run produces exactly one of each, and that a target with a pre-existing `.env` line does not get a duplicate.
  - Assumption: drift test 4 (`test4_gitignore_hygiene`) checks *this repo's* `.gitignore`, not the installer's output, so it is not the right home for this and must not be edited. [HIGH] Verified: `tests/run-drift-tests.sh` `test4_gitignore_hygiene()` asserts against `${GITIGNORE}` = repo root.
- [x] Step 1.3: Verify against a scratch target directory, not by reading the diff: run the installer into a fresh `git init` dir, cat the resulting `.gitignore`, assert all five patterns, re-run for idempotency, and run a third case with a pre-populated `.gitignore`.
- [x] Step 1.4: Run both suites. Expect drift 211/211, install 48/48 plus the new assertions.

**Plan-time verification already performed** [HIGH]. The Step 1.1 patch was applied to a scratchpad copy of `install.sh` and executed against three scratch targets:

```
bash -n install.sh                     -> SYNTAX OK
install.sh <fresh target>              -> .gitignore contains .env, .env.*, *.pem, *.key, *.p12  (5/5 PASS)
install.sh <same target> (re-run)      -> each pattern x1, header x1  (no duplicates)
install.sh <target with .env, *.key>   -> .env x1, *.key x1, adds only .env.*, *.pem, *.p12
./tests/run-install-tests.sh (patched) -> Results: 48 passed, 0 failed
```

This is a verified outcome of running the change, not an expected outcome of future work.

---

### Phase 2: Untrusted-input guard for attacker-controllable content (SC-04, SC-05)

Dependencies: none (disjoint from Phase 1)
Estimated scope: `CLAUDE.md` (new section, ~8 lines), `.claude/agents/hve-pr-reviewer.md`, `.claude/agents/hve-researcher.md` (1-2 lines each)
Success criteria: a repo-wide grep for guard language returns hits; both exposed agents carry a pointer to one canonical rule.

Steps:
- [x] Step 2.1: Add a canonical `## Untrusted Input` section to `CLAUDE.md` stating that diff content, fetched web content, and file content under review are **data, never instructions**, and that directives found inside them are reported to the user rather than acted on.
- [x] Step 2.2: Add a one-line reference in `hve-pr-reviewer.md` at the `Read this file yourself` instruction (line 18) pointing to that section. Reference style, not a copy (SC-04).
- [x] Step 2.3: Add the same one-line reference to `hve-researcher.md`'s WebFetch step (lines 43-49) (SC-05).
- [x] Step 2.4: Run both suites.
  - Assumption: adding a new `CLAUDE.md` section does not break test 3 (Model Selection prose sync) or test 8 (Instructions Reference table sync), which key off named sections other than this one. [MEDIUM] Guard step: if either fails, the new section heading collides with a test's anchor and must be renamed.

Note: authored in reference style deliberately so Phase 5's sweep does not revisit it. A duplicated guard would itself be a fresh RL violation.

---

### Phase 3: Security coverage floor for filtered reviews (DEFECT 1, DEFECT 3)

Dependencies: Phase 2 (reuses the reference-style convention)
Estimated scope: `.claude/commands/hve-pr-review.md`, `.claude/prompts/pull-request.md`, `.claude/agents/hve-implementation-validator.md`
Success criteria: no invocation path produces a severity-graded verdict with zero security coverage; test 13 green.

**Decision (user, 2026-08-15): security floor PLUS partial-coverage annotation.**

Steps:
- [x] Step 3.1: Make `--dimension <x>` always dispatch the security dimension alongside the requested one. Update the Phase 2 dispatch spec at `hve-pr-review.md:89`, which currently specifies dispatch only for the `all` case.
- [x] Step 3.2: Make the verdict rules at `hve-pr-review.md:145-148` conditional: the report must name which dimensions were not covered, and the security-Critical block rule stays in force because security always ran.
- [x] Step 3.3: Update `.claude/prompts/pull-request.md` to match any `--dimension` wording change.
  - Assumption: test 13 asserts prompt-file options resolve to command options, and `pull-request.md` is mapped to `hve-pr-review.md` and documents `--dimension`, so this twin edit is mandatory. [HIGH] Verified: `tests/run-drift-tests.sh:819` maps `pull-request.md|hve-pr-review.md`; baseline run shows `test13: pull-request.md --dimension: implemented in hve-pr-review.md`.
- [x] Step 3.4: Resolve DEFECT 3: `hve-implementation-validator.md:20` offers single-dimension scopes that contradict `:152` "Always run the security dimension checks - never skip them." Apply the same floor so the agent contract cannot express a security-free scope.
- [x] Step 3.5: Run both suites.

---

### Phase 4: Missing `tools:` frontmatter on two sibling agents (SC-02, SC-03)

Dependencies: none
Estimated scope: 2 files, 1 line each
Success criteria: both agents named by SC-02 and SC-03 declare `tools:`; test 1 (frontmatter validity) green. (Amended 2026-08-15 during review: this criterion originally read "all 9 agents declare `tools:`", which overreached the phase's own two-file scope. `hve-phase-implementor.md` deliberately keeps its implicit all-tools grant because it shells out to run test suites; see DR-401/DD-401 in the changes log. 8 of 9 declaring `tools:` is the intended end state.)

Steps:
- [x] Step 4.1: Add `tools: Read, Write, Glob, Grep` to `hve-prompt-tester.md`, matching sibling `hve-prompt-evaluator` (SC-02).
  - Assumption: the tester simulates a draft against 2-3 scenarios and writes a log to sandbox, needing no Bash, network, or Agent dispatch. [MEDIUM] The agent roster currently grants it "All tools". Guard step: if a test scenario legitimately requires executing a command, record it in the changes log and widen the grant deliberately rather than reverting the restriction.
- [x] Step 4.2: Add `tools: Read, Write, Edit, Glob, Grep` to `hve-prompt-updater.md`, matching `hve-plan-validator`'s scoping (SC-03).
- [x] Step 4.3: Run both suites, watching test 1 and test 2 (docs/internals.md agent-table sync) in particular.
  - Assumption: `docs/internals.md` carries an agent table that may enumerate tools and would then need the same edit. [MEDIUM] Guard step: if test 2 fails, update the table in the same phase.

---

### Phase 5: RL deduplication and the drift-coverage swap (RL-03, RL-04, RL-05, RL-06, RL-08, FC-01, RO-03)

Dependencies: Phases 1-4 complete (their surfaces are disjoint but their edits should be settled before the sweep)
Estimated scope: ~10 command/agent files, `CLAUDE.md`, `tests/run-drift-tests.sh` (~80 lines of test change)
Success criteria: each deduplicated block has exactly one carrier; every reference resolves; test 14 exists and passes; test 15 exists with **assertion 1 only** and passes; full suite green.

**Test 15 ships in two halves, deliberately.** Its second assertion (every reconstructible-input consumer carries a record-skip branch) cannot pass until Step 9.1 adds that branch to `hve-implement.md`. Writing both assertions here would red the Phase 5 boundary gate. Assertion 1 lands in Step 5.10; assertion 2 lands in Step 9.4. This is the plan's only cross-phase test dependency and it is intentional.

This is the phase the sequencing decision is about. One decision, "reference by name, do not duplicate," closes five findings. The precedent is `hve-pr-reviewer.md:43` ("Run the full security checklist from CLAUDE.md").

Steps:
- [x] Step 5.1: Replace the verbatim Friction Capture paragraph in all six commands (`hve-research.md:13`, `hve-plan.md:19`, `hve-implement.md:13`, `hve-review.md:13`, `hve-pr-review.md:13`, `hve-challenge.md:13`) with a one-line reference to `CLAUDE.md`'s Friction Capture section (RL-03).
- [x] Step 5.2: Update `test6_friction_flag_boilerplate` in `tests/run-drift-tests.sh:346-390`. `FRICTION_EXPECTED_COUNT` changes from 6, and the assertion inverts from "6 byte-identical copies" to "exactly 1 carrier."
  - Assumption: the test keys off the fixed-string prefix `` If `--friction-log` `` (`tests/run-drift-tests.sh:351`), so the replacement reference text must not begin with that prefix or the count will not drop. [HIGH] Verified by reading the test body.
- [x] Step 5.3: Replace the re-typed Security Hygiene grep checklist in `hve-implementation-validator.md:68-71` and `hve-implement.md:142-144` with references to `CLAUDE.md:292-295` (RL-04). Security-relevant list where drift is costly, so this is the highest-value dedup in the cluster.
- [x] Step 5.4: Replace the copied "Shell stays in the parent" paragraph at `hve-review.md:81` with a reference, matching the same file's own line 25 which already does it correctly (RL-05).
- [x] Step 5.5: Replace the "Concurrent writes" rule in `hve.md:107`, `hve-implement.md:109`, `hve-phase-implementor.md:48` with references, leaving `CLAUDE.md:319` canonical (RL-06). Update `CANONICAL_BLOCK_SPECS` entry `concurrent_writes|4|identical` to expect 1.
- [x] Step 5.6: Replace the restated 4-step discovery algorithm at `hve-memory.md:37-42` with the one-line reference other commands use (RL-08).
- [x] Step 5.7: Add the same one-line discovery reference to `hve-implement.md:27`, closing FC-01. The plan is the single unreconstructible input to that phase, so the missing branch-tiebreak and ask-on-ambiguity rule is the most consequential gap in the cluster.
- [x] Step 5.8: Update `CANONICAL_BLOCK_SPECS` entry `discovery_stub|3|identical` (`tests/run-drift-tests.sh:551`) to reflect the post-dedup carrier count. RO-03 notes this hardcoded 3 already excluded `hve-implement.md` from its baseline rather than catching FC-01.
- [x] Step 5.9: Add **test 14, reference resolution**: every `per CLAUDE.md's <Section>` pointer across `.claude/**/*.md` resolves to a real heading in `CLAUDE.md`. This catches the dangling-pointer failure mode that dedup introduces.
- [x] Step 5.10: Add **test 15, behavioral presence**, with assertion 1 only: every artifact-discovering command (`hve-plan`, `hve-implement`, `hve-review`, `hve-challenge`, `hve-memory`) carries a discovery reference, asserted as a carrier-count **floor** so a future sixth command does not fail the suite spuriously. Answers RO-03's structural complaint that the suite tests boilerplate consistency, not behavior. Do NOT write assertion 2 here; it belongs to Step 9.4 and would red this phase's gate.
  - Assumption: Steps 5.9 and 5.10 both emit references in the exact form `` per CLAUDE.md's `Section Name` section `` defined in the details doc's Reference Syntax Contract; test 14's extractor depends on it. [HIGH] The contract is stated once in `.claude-hve-tracking/details/2026-08-15/full-repo-review-remediation-details.md` section 5 and is binding on Phases 2, 3, 5, 6, and 10.
- [x] Step 5.11: Run both suites. Expect the drift count to change from 211 as assertions are replaced; record the new baseline explicitly in the changes log rather than treating any delta as noise.

---

### Phase 6: Convention gaps, now single-site (RL-01, RL-02, RL-07)

Dependencies: Phase 5
Estimated scope: 3-5 files
Success criteria: no self-contradicting parse instruction; a language with no instructions file has a documented path.

Steps:
- [x] Step 6.1: Fix RL-01. `hve-implement.md:11-19`, `hve-review.md:11-19`, `hve-plan.md:11-19` each claim "Parse `$ARGUMENTS` exactly once, before anything else... none re-reads `$ARGUMENTS`" while two preceding flag-strip instructions already read it. Rewrite so the stated invariant matches the actual order.
  - Assumption: this sentence is byte-identical across the three files. [HIGH] Verified by grep: `hve-review.md:19` and `hve-implement.md:19` are identical strings.
- [x] Step 6.2: Fix RL-02. Add CLAUDE.md's "no instructions file exists" fallback ("follow the dominant conventions of the existing code, note the missing file in the changes log") as a reference at `hve-implement.md:42` and the three points in `hve-phase-implementor.md` (lines 19, 31, 132).
- [x] Step 6.3: Fix RL-07. Wire `writing-style.md` and `markdown.md` into the four commands that author prose artifacts (`hve-prompt-builder.md`, `hve-prompt-refactor.md`, `hve-doc-ops.md`, `hve-prompt-updater.md`). Today the generic "read the relevant instructions file for the language" instruction is scoped to programming languages, so neither file is reachable.
- [x] Step 6.4: Run both suites.

---

### Phase 7: Flag correctness, the dead-flag cluster (FC-02, DO-01, DEFECT 2, PS-05)

Dependencies: Phase 6 (Step 6.1 rewrites the same Argument Parsing block)
Estimated scope: `hve-review.md`, `hve-implement.md`, `CLAUDE.md` (2 table rows)
Success criteria: no parsed flag is unreferenced; `/hve --mode full`'s review promise is true.

**Decision (user, 2026-08-15): wire `--mode` on both commands.** The knobs already exist and need no invention: `hve-implement.md:88`'s Simple carve-out ("do NOT spawn subagents, implement directly") is exactly `--mode lightweight` per `hve.md`'s mode table, and `hve-implement.md:107`'s parallel execution ("spawn their subagents in parallel") is exactly `--mode full`. The wiring is the one-liner `hve-plan.md:43` already uses.

Steps:
- [x] Step 7.1: Wire `MODE` in `hve-review.md` to gate validator dispatch count in Phase 3, using the `hve-plan.md:43` pattern ("If MODE is set, use it. Otherwise, infer from complexity"). This closes DEFECT 2 and PS-05 together: PS-05 found Phase 3 always spawns exactly one `hve-implementation-validator` with no mode or difficulty branch, which is precisely the gate `--mode` should drive.
- [x] Step 7.2: Wire `MODE` in `hve-implement.md` to override the difficulty grade that the Simple carve-out (line 88) and parallel-execution branch (line 107) already key off. Closes FC-02's `--mode` half.
- [x] Step 7.3: Remove `THINK_MODE` from `hve-implement.md:19`'s parse list. It is parsed, absent from the argument-hint at line 3, and never referenced. Implement executes an already-reasoned plan, so there is no synthesis step for extended reasoning to improve. Recorded as DD-002.
- [x] Step 7.4: Update the `CLAUDE.md` Command Reference row for `/hve-implement` to document `--mode` (DO-01).
- [x] Step 7.5: Run both suites.
  - Assumption: no prompt file maps to `hve-review.md` or `hve-implement.md`, so argument-hint edits here do **not** ripple into `.claude/prompts/` twins under test 13. [HIGH] Verified: the `PROMPT_COMMAND_MAP` at `tests/run-drift-tests.sh:818-823` maps only `rpi->hve`, `pull-request->hve-pr-review`, `checkpoint->hve-memory`, `doc-ops->hve-doc-ops`, `task-challenge->hve-challenge`, `prompt-build->hve-prompt-builder`.

---

### Phase 8: Dispatch bounds and context discipline (PS-01, PS-02, PS-03, PS-04, PS-06, PS-07)

Dependencies: Phase 7
Estimated scope: `hve-research.md`, `hve.md`, `hve-review.md`, `hve-implement.md`, `hve-doc-ops.md`, `hve-git-merge.md`
Success criteria: every fan-out has a stated upper bound tied to its classification tier; no two instructions in one file contradict on how much to load.

Steps:
- [x] Step 8.1: PS-01. Tie research theme count back to the Phase 0 difficulty tier in `hve-research.md:29-34,48-49,61`. Today the "Subagent count" column never gates dispatch, and "List 3-7 research questions" plus "one subagent per theme" lets a Medium task legally spawn 7 researchers.
- [x] Step 8.2: PS-02. Apply the same gate in `hve.md:34-40,67-68`, which inlines the research steps and inherits the ungated mechanic.
- [x] Step 8.3: PS-03. Resolve the direct contradiction between `hve-review.md:95` ("Consolidate Critical and Major findings in full text") and `:97` ("read only the status line and top findings"). State which wins.
- [x] Step 8.4: PS-04. Scope the post-subagent changes-log verification at `hve-implement.md:100` to the newly-added phase section. Read literally, phase K re-reads all K prior sections, which is O(N^2) reads across an N-phase plan.
- [x] Step 8.5: PS-06. Bound the `hve-doc-ops.md:49,51` fan-out ("one subagent per section or doc type" for any doc set >= 10 files) with a cap and batching strategy, following `hve-pr-review`'s explicitly capped 8/4 design.
- [x] Step 8.6: PS-07. Cap the unconditional full `git diff FILENAME` dump at `hve-git-merge.md:55`, matching the `head -100` cap used elsewhere in this repo.
- [x] Step 8.7: Run both suites.

---

### Phase 9: Missing fallbacks and the corrections protocol (RO-01, RO-02, DA-01)

Dependencies: Phase 8
Estimated scope: `hve-implement.md`, `hve-plan.md`, `hve-review.md`
Success criteria: every reconstructible input has a record-skip branch; resume paths invoke the corrections protocol; the reviewer has the tool it is told to use.

Steps:
- [x] Step 9.1: RO-01. Add the record-skip-and-proceed branch for a missing Details doc at `hve-implement.md:28`. CLAUDE.md classifies details as reconstructible, and `hve-plan.md:27` and `hve-review.md:32` both already apply the rule correctly.
- [x] Step 9.2: RO-02. Make the resume paths at `hve-implement.md:29` and `hve-plan.md:28` invoke the annotate-in-place-plus-dated-Correction protocol, and tie a trigger to the empty `#### Corrections` stub at `hve-implement.md:74-76`.
- [x] Step 9.3: DA-01. Add `Edit` to `hve-review.md`'s `allowed-tools` frontmatter (line 4). Line 43 instructs the reviewer to *append* a Correction entry, which without `Edit` can only be done by a whole-file `Write`, the exact clobber risk CLAUDE.md:319 warns against.
- [x] Step 9.4: Add **assertion 2 to test 15**, the half deferred from Step 5.10: every consumer of a reconstructible input (research, details) carries a record-skip branch, covering `hve-plan.md`, `hve-review.md`, and `hve-implement.md`. Step 9.1 is what makes this assertion passable, so it must land before the assertion is written, within this same phase.
- [x] Step 9.5: Run both suites. Test 15 now carries both assertions and must be green before Phase 10 starts.

---

### Phase 10: Subagent Response Protocol, criterion before formats (II-01 through II-07)

Dependencies: Phase 9
Estimated scope: 3 agents, 2 commands, possibly `tests/run-drift-tests.sh` test 7
Success criteria: the QA criterion describes all 6 protocol parts; all three agent Response Formats comply; test 7 enforces it.

**Order within the phase is load-bearing.** II-04/05/06/07 are the incomplete 3-part protocol description used as the QA criterion; II-01/02/03 are the non-compliant formats that criterion failed to catch. Fixing formats first without fixing the criterion means the same drift returns on the next authoring pass.

Steps:
- [x] Step 10.1: Fix the criterion first, in all four carriers. `hve-prompt-evaluator.md:43-46`, `hve-prompt-analyze.md:53`, `hve-prompt-refactor.md:47`, and `hve-prompt-updater.md:58` all read some variant of "7-finding max, checklist, full-detail pointer," omitting the status line and the clarifying-questions section (II-04, II-05, II-06, II-07). Per the Phase 5 convention, make this a reference to CLAUDE.md's Subagent Response Protocol rather than a fourth paraphrase.
- [x] Step 10.2: Fix `hve-prompt-updater.md:100-106` (II-01): status line must be Complete/Blocked, follow-on checklist caps at 5 not 3, and the missing clarifying-questions part is added. Currently 6 required parts collapse into 5 different ones.
- [x] Step 10.3: Fix `hve-prompt-tester.md:89-95` (II-02): add the clarifying-questions part and document the Blocked status variant, currently hardcoded to `Status: Complete`.
- [x] Step 10.4: Fix `hve-prompt-evaluator.md:91-97` (II-03): replace the non-standard `Verdict: No issues remaining: Yes/No` status vocabulary with Pass/Fail or Complete/Blocked, and add the clarifying-questions part.
- [x] Step 10.5: Extend drift test 7 (`test7_response_protocol_structure`) so a missing status line or clarifying-questions section fails mechanically. Without this the criterion fix is documentation only and the drift can return.
- [x] Step 10.6: Run both suites.

---

### Phase 11: Documentation sync (DO-02, DO-03, DO-04, DO-05, DO-06)

Dependencies: Phase 10
Estimated scope: `CLAUDE.md`, `README.md`, `docs/reference.md`, `docs/installation.md`
Success criteria: every flag a command implements appears in its reference row; both doc trees match the real file set.

Steps:
- [x] Step 11.1: DO-02. Add `--mode` to the `/hve-research` and `/hve-plan` Command Reference rows in `CLAUDE.md:43-44` and the same rows in `README.md:123-124`. Both commands actually branch on it (`hve-research.md:19-20`, `hve-plan.md:43`).
- [x] Step 11.2: DO-03. Add `--dimension` to the `/hve-pr-review` row at `CLAUDE.md:47`, reflecting the Phase 3 security-floor semantics.
- [x] Step 11.3: DO-04. Add `--scope` to the `/hve-doc-ops` row at `CLAUDE.md:50`.
- [x] Step 11.4: DO-05. Add `javascript.md` and `typescript.md` to the language table at `docs/reference.md:52-65` and the manual-migration list at `docs/installation.md:97`. Both files exist, are in `CLAUDE.md:277-278`, and are in install.sh's instruction array.
- [x] Step 11.5: DO-06. Add the `friction/` entry to the tracking-folder diagram at `docs/reference.md:6-31`.
- [x] Step 11.6: Final full-suite run plus a fresh scratch-target install verification, confirming the Phase 1 installer change survived all eleven phases.

---

## Finding Coverage Map

All 39 review findings plus 3 addendum defects. A finding in neither this table nor Deferred Items would be a planning defect.

| Phase | Findings closed | Count |
|---|---|---|
| 1 | SC-01 | 1 |
| 2 | SC-04, SC-05 | 2 |
| 3 | DEFECT 1, DEFECT 3 | 2 |
| 4 | SC-02, SC-03 | 2 |
| 5 | RL-03, RL-04, RL-05, RL-06, RL-08, FC-01, RO-03 | 7 |
| 6 | RL-01, RL-02, RL-07 | 3 |
| 7 | FC-02, DO-01, DEFECT 2, PS-05 | 4 |
| 8 | PS-01, PS-02, PS-03, PS-04, PS-06, PS-07 | 6 |
| 9 | RO-01, RO-02, DA-01 | 3 |
| 10 | II-01, II-02, II-03, II-04, II-05, II-06, II-07 | 7 |
| 11 | DO-02, DO-03, DO-04, DO-05, DO-06 | 5 |
| **Total** | | **42** |

Cross-check: 39 review findings (FC 2, DA 1, II 7, RL 8, PS 7, RO 3, SC 5, DO 6) + 3 addendum defects = 42. Assigned: 42. Unassigned: 0.

## Deferred Items

| Item | Reason |
|---|---|
| Addendum DEFECT 4 (changes-log section-ownership has no enforcement hook) | Marked "Optional, lower priority" in the source memory file and outside the three defects the task scoped in. Candidate for a follow-up review-side check in `hve-rpi-validator`. |
| `/hve-audit` or `/hve-review-codebase` command | Explicitly out of scope: separate feature. |
| HiVE orchestrator project | Explicitly out of scope. |
| `/hve-challenge --all` flag | Explicitly out of scope. |
| HANDOFF box-drawing render issue | Explicitly out of scope. |
| Five unmerged local branches | Explicitly out of scope. |

---

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| Phase 5 drops drift coverage instead of replacing it, leaving dedup unguarded | High if unmanaged | Steps 5.9 and 5.10 add tests 14 and 15 in the same phase as the removals. Phase 5 is not complete until both exist and pass. Coverage swap is specified in the table above, not left to the implementor. |
| `install.sh` change breaks installs in other projects | Medium | Phase 1 graded Medium minimum per the risk override. Already verified against three scratch targets (fresh, re-run, pre-populated) with the full install suite green. Step 11.6 re-verifies after all phases. |
| Test expectation edits mask a real regression | Medium | Every phase boundary runs both suites. Step 5.11 requires recording the new drift baseline explicitly rather than accepting any count delta silently. |
| Phase 6 Step 6.1 and Phase 7 edit the same Argument Parsing block | Medium | Sequenced, not parallel: Phase 7 depends on Phase 6. Step 6.1 rewrites the invariant sentence, Step 7.2/7.3 then change what it parses. |
| Restricting `hve-prompt-tester` tools breaks a legitimate test scenario | Low-Medium | Step 4.1 carries an explicit guard: widen deliberately and record it, do not silently revert the restriction. |
| Reference-style dedup creates dangling pointers into CLAUDE.md | Medium | Exactly what new test 14 exists to catch. This is the failure mode dedup introduces and nothing currently covers. |

## Testing Approach

- **Gate at every phase boundary**, not only at the end: `./tests/run-drift-tests.sh` and `./tests/run-install-tests.sh` both green before the next phase starts.
- **Baseline is 211/211 drift and 48/48 install**, captured on this branch before any edit.
- **Expected intentional deltas**: Phase 1 adds install assertions; Phase 5 changes drift counts as tests 6 and 10 invert and tests 14 and 15 are added; Phase 9 extends test 15 with its second assertion; Phase 10 may extend test 7. Every delta is recorded in the changes log with the reason. An unexplained delta is treated as a regression.
- **One intentional cross-phase test dependency**: test 15 ships in halves (assertion 1 in Step 5.10, assertion 2 in Step 9.4) precisely so no phase boundary is crossed with a known-red assertion. Any other test that cannot pass in the phase that writes it is a planning defect, not a precedent.
- **`install.sh` is never verified by diff reading**: Phases 1 and 11 both run the installer into a scratch target directory and assert against the produced files.

---

## Requirements added after Review (2026-08-15)

Source: `/hve-pr-review` on branch `fix/full-repo-review-remediation`, artifact
`.claude-hve-tracking/reviews/pr/fix-full-repo-review-remediation/2026-08-15-review.md`
(0 Critical, 6 Major, 18 Minor). User scoped this pass to the Majors only; Minors are
deferred, not closed.

### Phase 12 — Major review findings

- [ ] **12.1 (RO-001)** `.claude/commands/hve-pr-review.md` — handle a reviewer returning
  `Blocked` (contract at `.claude/agents/hve-pr-reviewer.md:109`). A blocked reviewer is
  recorded as NOT covered, and a blocked Security reviewer forbids an Approve verdict.
  Today `Coverage:` is filled from the set dispatched, so a blocked security run reads as
  Approve. Success: the word `Blocked` appears in the Phase 3 consolidation rules and the
  verdict rules; no path yields Approve with a blocked security reviewer.
- [ ] **12.2 (RL-004 / DA-002)** Credential-pattern list has 7 copies outside any drift
  guard (`README.md` x2, `docs/installation.md` x4, `install.sh` global-mode echo block).
  `canonical_block_corpus()` (`tests/run-drift-tests.sh:582-589`) covers only
  `.claude/{commands,agents,prompts}` and `CLAUDE.md`. Success: a drift test fails if any
  surface drifts from the canonical six patterns.
- [ ] **12.3 (II-001)** `.claude-hve-tracking/changes/2026-08-15/full-repo-review-remediation-changes.md:997`
  asserts `*.pfx` was "deliberately NOT added"; the Post-Review Remediation section at :932
  reversed it. Annotate the stale claim per CLAUDE.md's `Corrections in Tracking Artifacts`
  section. Success: stale claim carries `(superseded — see Correction 2026-08-15)`.
- [ ] **12.4 (DO-003)** `CONTRIBUTING.md:24` says "Covers 7 `install.sh` scenarios" (now 8),
  and never mentions `tests/run-drift-tests.sh` at all. Success: count corrected, drift
  suite documented with what it guards and how to run it.
- [ ] **12.5 (DO-002 / FC-003)** `README.md:139-146` claims `--subagent-model` and
  `--friction-log` "work the same way everywhere"; the two flags have different command
  sets and `/hve-challenge` + `/hve-memory` accept neither `--subagent-model` nor the Agent
  tool. Success: `--subagent-model` row scoped to its actual command set; "everywhere"
  framing dropped.

### Deferred by user decision (2026-08-15)

- **FC-002** — `/hve-plan` documents a parallel-validation path that does not exist
  (`hve-plan.md:41` and `:131` contradict; `CLAUDE.md:44` and `README.md:124` echo the false
  claim). User chose **defer and log as a feature** rather than reword or build. The false
  claim remains in three shipped docs until the feature lands. Recorded so review does not
  rediscover it as new.
- **18 Minor findings** — listed in the review artifact; not in scope for this pass.

### Testing

Gate unchanged: `./tests/run-drift-tests.sh` and `./tests/run-install-tests.sh` both green.
Baseline entering Phase 12 is 249 drift / 69 install, verified by execution 2026-08-15.
Step 12.2 is expected to raise the drift count; record the delta and the reason.
