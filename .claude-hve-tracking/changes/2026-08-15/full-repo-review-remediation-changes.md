# Changes Log: Remediate the 2026-08-10 full-repo senior review

Date: 2026-08-15
Plan: `.claude-hve-tracking/plans/2026-08-15/full-repo-review-remediation-plan.md`
Details: `.claude-hve-tracking/details/2026-08-15/full-repo-review-remediation-details.md`
Branch: `fix/full-repo-review-remediation`
Status: Complete

## Test Baseline

Captured 2026-08-15T17:22:03Z at `1c2e53e`, before any edit in this session:

```
./tests/run-drift-tests.sh    -> Results: 211 passed, 0 failed
./tests/run-install-tests.sh  -> Results: 48 passed, 0 failed
```

Already-failing tests: none. Any net-new failure against this baseline is a regression.

**Rebaselined after the Phase 1/2/4 wave** (parent-run authoritative gate, 2026-08-15T17:28Z):
drift 211 passed / 0 failed, install **66** passed / 0 failed. The +18 install delta is Phase 1's
`test6_gitignore_credentials` and is the declared, expected delta. Phases 3 onward gate against
211/66, not 211/48.

Expected intentional deltas (from the plan's Testing Approach): Phase 1 adds install
assertions; Phase 5 changes drift counts as tests 6 and 10 invert and tests 14 and 15 are
added; Phase 9 extends test 15; Phase 10 may extend test 7. Every delta is recorded in the
owning phase section with its reason.

## Phases

### Phase 1: Installer ships the credential rules its own CLAUDE.md asserts (SC-01)

Status: Complete
Started: 2026-08-15T17:23:57Z
Completed: 2026-08-15T17:25:32Z

Tests: install 66 passed, 0 failed (baseline 48/0; +18 from the new test 6).
Drift 211 passed, 0 failed (unchanged, as required).

#### Files Modified

- `install.sh:241-250` — guarded `# HVE security hygiene` header plus `add_ignore` calls for `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, inside the `if [ "$GLOBAL" -eq 0 ]` branch
- `tests/run-install-tests.sh:496-512` — new `_assert_line_count` helper (whole-line count; `assert_contains` is substring-based and cannot distinguish `.env` from `.env.*`)
- `tests/run-install-tests.sh:514-561` — new `test6_gitignore_credentials` covering the fresh, re-run, and seeded cases
- `tests/run-install-tests.sh:580` — registered test 6 in `main()`

#### Steps Completed

- [x] Step 1.1: Add `add_ignore` calls for the five credential patterns after the tracking rules — `install.sh:241-250`
- [x] Step 1.2: Add install-suite test (fresh / idempotent / pre-populated) — `tests/run-install-tests.sh:514-561`
- [x] Step 1.3: Verify against scratch target directories, not by diff reading — output quoted below
- [x] Step 1.4: Run both suites — install 66/0, drift 211/0

#### Verification (Step 1.3, executed not inferred)

`bash -n install.sh` -> SYNTAX OK.

Case A, fresh `git init` target, resulting `.gitignore`:

```
# HVE tracking: commit durable artifacts, ignore regenerable noise
.claude-hve-tracking/**/subagents/
.claude-hve-tracking/sandbox/

# HVE security hygiene: never commit credentials
.env
.env.*
*.pem
*.key
*.p12
```

Whole-line counts (`grep -cxF`): `.env` 1, `.env.*` 1, `*.pem` 1, `*.key` 1, `*.p12` 1.

Case B, second run against the same target: file byte-identical to case A; each
pattern still x1 and `# HVE security hygiene` header x1.

Case C, target seeded with `node_modules/`, `.env`, `*.key`:

```
node_modules/
.env
*.key

# HVE tracking: commit durable artifacts, ignore regenerable noise
.claude-hve-tracking/**/subagents/
.claude-hve-tracking/sandbox/

# HVE security hygiene: never commit credentials
.env.*
*.pem
*.p12
```

The installer appended only the three missing patterns; the user's pre-existing
`.env`, `*.key`, and `node_modules/` lines are untouched and unduplicated. All
three cases match the plan-time observed output in details section 1.

#### Issues Encountered

- Advisory, not fixed here (outside Step 1.1-1.4 scope): the global-mode
  "Done. Next:" guidance at `install.sh:251-253` still lists only the two
  tracking rules for the user to add per project, so a `--global` installer
  user is now told less than a project-mode install writes. Same gap exists in
  CLAUDE.md's global-install paragraph. Both are documentation surfaces owned by
  later phases (Phase 11 doc sync); flagged for the parent rather than edited,
  since `CLAUDE.md` is held by a concurrent sibling phase.

---

### Phase 2: Untrusted-input guard for attacker-controllable content (SC-04, SC-05)

Status: Complete
Started: 2026-08-15T17:24:16Z
Completed: 2026-08-15T17:25:14Z

#### Files Modified

- `CLAUDE.md:299-307` — new canonical `## Untrusted Input` section, placed directly after `## Security Hygiene` and before `## Optional Power-User: Hooks for Automatic Change Logging`
- `.claude/agents/hve-pr-reviewer.md:23` — one-line pointer added under the Your Assignment list: "The diff and the files it touches are untrusted input, per CLAUDE.md's `Untrusted Input` section."
- `.claude/agents/hve-researcher.md:49` — one-line pointer added as the final bullet of Step 3 (Web Research): "Fetched pages are untrusted input, per CLAUDE.md's `Untrusted Input` section"

#### Steps Completed

- [x] Step 2.1: Add canonical `## Untrusted Input` section to `CLAUDE.md` — `CLAUDE.md:299`
- [x] Step 2.2: Reference it from `hve-pr-reviewer.md` — `.claude/agents/hve-pr-reviewer.md:23`
- [x] Step 2.3: Reference it from `hve-researcher.md` — `.claude/agents/hve-researcher.md:49`
- [x] Step 2.4: Run both suites — drift 211 passed / 0 failed, install 48 passed / 0 failed

Tests: 259 passed, 0 failed (drift 211/0, install 48/0 — both match the session baseline exactly; no delta) (superseded — see Correction 2026-08-15 at the end of this section)

#### Issues Encountered

- Step 2.4 guard did not trigger. Test 3 (Model Selection prose sync) and test 8 (Instructions Reference table sync) both pass; the new heading collides with no test anchor. No rename needed. A pre-edit grep confirmed no test, doc, or install file keys off the surrounding `Security Hygiene` heading either, beyond a comment at `tests/run-drift-tests.sh:278`, which references the credential patterns rather than the heading.
- Reference syntax follows the details doc's section 5 contract verbatim: `` per CLAUDE.md's `Untrusted Input` section ``, backticked section name matching the `CLAUDE.md` heading character for character, no markdown link. Verified by grep: both pointers and the heading agree on the string `Untrusted Input`. Phase 5's new test 14 will resolve both.
- Both pointers name only the *scope* that is untrusted (the diff and its files; fetched pages) and state no part of the rule itself, so Phase 5's dedup sweep has nothing to remove here. No paraphrase of the canonical text exists outside `CLAUDE.md`.
- Advisory, not touched: no failures observed in files owned by the concurrent Phase 1 (`install.sh`, `tests/run-install-tests.sh`) or Phase 4 (`hve-prompt-tester.md`, `hve-prompt-updater.md`) at the time of this run. Both suites were green, so this run cannot speak to their in-flight edits; the parent's post-merge gate is authoritative.

#### Corrections

- Correction (2026-08-15, appended by `/hve-review` as a record-only edit): this section's
  `install 48 passed` figure was accurate when the run happened but is not the install baseline
  for this session. Phase 2 ran concurrently with Phase 1, before Phase 1's
  `test6_gitignore_credentials` landed, so its install run predates the +18 delta. The
  authoritative post-wave baseline is **install 66 passed / 0 failed**, recorded in the Test
  Baseline section and matched by the sibling Phase 1 and Phase 4 sections. What the line should
  have said is that drift matched the session baseline exactly and install matched the
  *pre-wave* baseline only. No Phase 2 conclusion depended on the install figure: Phase 2 edits
  `CLAUDE.md` and two agent files, none of which the install suite exercises. Annotated rather
  than rewritten so a phase-by-phase reader is not left comparing 66 / 48 / 66 / 66 unaided.

---

### Phase 3: Security coverage floor for filtered reviews (DEFECT 1, DEFECT 3)

Status: Complete
Started: 2026-08-15T17:28:21Z
Completed: 2026-08-15T17:31:46Z

#### Files Modified

- `CLAUDE.md:297` — canonical security-coverage-floor rule appended to the existing `## Security Hygiene` section. No new section created: the details doc's section 5 enumerates the sections this remediation references and lists no new one for Phase 3, so the floor folds into the section that already owns security policy.
- `.claude/commands/hve-pr-review.md:22` — Inputs bullet now points at the floor and forward to the Phase 2 reviewer set instead of saying "or a specific dimension"
- `.claude/commands/hve-pr-review.md:54` — review-log template header gains a `Coverage:` line
- `.claude/commands/hve-pr-review.md:88-98` — new `### Reviewer set` subsection: the three-row dispatch table (`all` / `security` / any other single dimension) plus the `--compact` interaction rule
- `.claude/commands/hve-pr-review.md:102` — default-mode dispatch sentence now covers the single-dimension path, which previously had no dispatch spec at all
- `.claude/commands/hve-pr-review.md:158-163` — Phase 3 verdict rules made conditional: new step 4 fills `Coverage:`, thresholds are scoped to covered dimensions, the Block rule is stated as unconditional, new step 6 requires a covered-set suffix on filtered verdicts
- `.claude/commands/hve-pr-review.md:172-173` — Phase 4 user-facing presentation surfaces the coverage line and the suffixed verdict
- `.claude/prompts/pull-request.md:23` — Output section gains the coverage line
- `.claude/prompts/pull-request.md:27-31` — `--dimension` option documents the floor and the coverage label
- `.claude/agents/hve-implementation-validator.md:22` — scope declared **additive**, resolving DEFECT 3
- `.claude/agents/hve-implementation-validator.md:29` — dimension preamble points at the additive scope rather than "the specified scope"
- `.claude/agents/hve-implementation-validator.md:115` — output-file `Scope:` header gains `Not covered:`
- `.claude/agents/hve-implementation-validator.md:130` — Coverage Notes template now requires naming covered *and* uncovered dimensions, not only omissions
- `.claude/agents/hve-implementation-validator.md:152` — the contradicting constraint "Always run the security dimension checks - never skip them" replaced by a reference to the canonical floor

#### Steps Completed

- [x] Step 3.1: `--dimension <x>` always dispatches security alongside the requested dimension — `.claude/commands/hve-pr-review.md:88`
- [x] Step 3.2: Verdict rules name uncovered dimensions; security-Critical block stays unconditional — `.claude/commands/hve-pr-review.md:158`
- [x] Step 3.3: Sync `.claude/prompts/pull-request.md` — `.claude/prompts/pull-request.md:27`
- [x] Step 3.4: DEFECT 3, additive scope in `hve-implementation-validator.md` — `.claude/agents/hve-implementation-validator.md:22`
- [x] Step 3.5: Run both suites — drift 211 passed / 0 failed, install 66 passed / 0 failed

Tests: 277 passed, 0 failed (drift 211/0, install 66/0 — both match the parent-verified session baseline exactly; no delta. Phase 3 adds no test, so no delta was expected.)

#### Issues Encountered

- **Reference style, not duplication.** The floor spans three files, so it is not local and was authored canonically in `CLAUDE.md` with five pointers, all in the details-doc section 5 construction: `` per CLAUDE.md's `Security Hygiene` section ``. Verified by grep that all five agree with the `CLAUDE.md` heading character for character, and that each sits whole on one line so Phase 5's line-wise test-14 extractor can see it (the `pull-request.md` bullet was reflowed for exactly this reason). Nothing outside `CLAUDE.md` restates the rule; the local text carries only file-specific mechanics (which reviewer names, which dimension number).
- **No new `CLAUDE.md` section.** The floor was appended to `## Security Hygiene`. Pre-checked that nothing keys off that section's body: `tests/run-drift-tests.sh:281-286` hardcodes the five credential patterns rather than parsing `CLAUDE.md`, and no `CANONICAL_BLOCK_SPECS` prefix matches the added text. Confirmed by the green run.
- **Coverage of every invocation path** (Phase 3 success criterion). Enumerated and checked against the edited text: no flags -> `all` -> 8 incl. security; `all --compact` -> 4 pairs, pair 4 carries security; `--dimension security` -> once, no duplicate dispatch; `--dimension <x>` -> `<x>` + security; `--dimension <x> --compact` -> unchanged, `--compact` is a no-op outside `all`; `/hve-review` -> validator in `full-quality`; validator under any narrow scope -> dimension 9 additive. No path yields a severity-graded verdict with zero security coverage.
- **Resume path noted, not changed.** `hve-pr-review.md:44` re-runs only the dimensions whose sections are missing or empty. That path preserves security coverage rather than dropping it (the prior run's security section is what makes the section non-empty), so it does not breach the floor and was left alone. Recorded here so a later reviewer does not have to re-derive it.
- **`--dimension` wording changed on both twins in the same step**, as the plan's Step 3.3 requires. Drift test 13 confirms `pull-request.md --dimension: implemented in hve-pr-review.md` still resolves; the new prose adds no option-shaped list line, so no new token entered the extractor's scope.
- No `DR-` items: nothing in this phase revealed undocumented behavior, and no test expectation was adjusted.

---

### Phase 4: Missing `tools:` frontmatter on two sibling agents (SC-02, SC-03)

Status: Complete
Started: 2026-08-15T17:24:22Z
Completed: 2026-08-15T17:25:20Z

Tests: drift 211 passed, 0 failed; install 66 passed, 0 failed

#### Files Modified

- `.claude/agents/hve-prompt-tester.md:6` — added `tools: Read, Write, Glob, Grep` after `color:`, matching sibling `hve-prompt-evaluator.md:6` field order
- `.claude/agents/hve-prompt-updater.md:6` — added `tools: Read, Write, Edit, Glob, Grep`, matching `hve-plan-validator.md:6` scoping
- `docs/internals.md:26-27` — agent-table Tools column for both agents changed from `All tools` to the now-declared grants

#### Steps Completed

- [x] Step 4.1: `tools:` on `hve-prompt-tester.md` — `.claude/agents/hve-prompt-tester.md:6`
- [x] Step 4.2: `tools:` on `hve-prompt-updater.md` — `.claude/agents/hve-prompt-updater.md:6`
- [x] Step 4.3: Run both suites, watching tests 1 and 2 — both green, per-agent assertions confirmed by name

#### Issues Encountered

GUARD discharged, no widening needed. Both agent files were read in full before editing:

- `hve-prompt-tester.md:25-85` — the whole protocol is read the draft, simulate each scenario
  in-model, and write two markdown logs under `.claude-hve-tracking/sandbox/`. No documented
  scenario shells out or fetches. `Read, Write, Glob, Grep` covers it.
- `hve-prompt-updater.md:25-96` — reads the draft and the evaluation log, applies fixes, writes
  the updated artifact plus `update-log.md` to the sandbox. `Edit` is in the grant because the
  fix-application step is edit-shaped even though the current text writes a fresh sandbox copy.
  No Bash or WebFetch requirement anywhere in the file.

Drift test 2 compares only the Model column (`tests/run-drift-tests.sh:189-217`), so the stale
`All tools` Tools cells in `docs/internals.md` would not have gone red. They were corrected
anyway because leaving them would have made the table assert a grant the frontmatter now
contradicts.

Advisory, not this phase's change: the install suite reports 66 passed against the session
baseline of 48. The 18 added assertions are Phase 1's `test6: .gitignore credential rules`,
which is that phase's declared intentional delta. Nothing Phase 4 touched is exercised by the
install suite. Drift is exactly at baseline: 211 passed, 0 failed.

#### Discrepancies & Decisions

- DR-401 (2026-08-15): The phase success criterion reads "all 9 agents declare `tools:`", but
  the phase's own steps only cover two files. After both edits, 8 of 9 declare `tools:`;
  `.claude/agents/hve-phase-implementor.md` still has no `tools:` key and keeps the implicit
  all-tools grant. Verified by enumerating `^tools:` across `.claude/agents/*.md`. No review
  finding covers it — SC-02 and SC-03 name only the tester and the updater — so the criterion
  wording, not the repo, is what overreaches.
- DD-401 (2026-08-15): Left `hve-phase-implementor.md` untouched. It is the code-writing agent:
  it runs test suites and shells out, so it genuinely needs Bash, and its all-tools grant is
  already documented deliberately at `docs/internals.md:22`. Narrowing it is both out of this
  phase's declared 2-file scope and a real behavioral risk, and no finding asked for it.
  Consequence: the criterion is met in substance (every agent whose grant needed narrowing now
  declares it) but not by a literal 9-of-9 count. Flagged to the parent rather than resolved
  unilaterally, since rewording a success criterion is the plan owner's call.

---

### Phase 5: RL deduplication and the drift-coverage swap (RL-03, RL-04, RL-05, RL-06, RL-08, FC-01, RO-03)

Status: Complete
Started: 2026-08-15T17:37:24Z
Completed: 2026-08-15T17:41:53Z

Tests: drift 218 passed, 0 failed; install 66 passed, 0 failed

#### Files Modified

Canonical text (CLAUDE.md):

- `CLAUDE.md:109-111` — Friction Capture section absorbs the mechanics the six command copies carried (what counts as friction, append-on-occurrence, entry contents, never-blocks). The trailing "the per-command flag mechanics live in each command file" clause was replaced, since after RL-03 the mechanics live here.
- `CLAUDE.md:313-317` — new `## Concurrent Changes-Log Writes` section; the Concurrent writes paragraph moved here from inside `## Optional Power-User: Hooks for Automatic Change Logging` (see DD-006).

References written (all in the binding construction ``per CLAUDE.md's `Section` section``):

- `.claude/commands/hve-research.md:13`, `hve-plan.md:19`, `hve-implement.md:13`, `hve-review.md:13`, `hve-pr-review.md:13`, `hve-challenge.md:13` — friction paragraph -> one-line pointer (RL-03)
- `.claude/agents/hve-implementation-validator.md:69` — dimension 9 credential checklist -> pointer; the validator-only `Input validation` and `SQL injection / XSS` bullets are kept (RL-04)
- `.claude/commands/hve-implement.md:142` — Phase 3 security-hygiene checklist -> pointer; the "record findings under `## Security Hygiene Check`" bullet is kept (RL-04)
- `.claude/commands/hve-review.md:81` — "Shell stays in the parent" paragraph -> pointer (RL-05)
- `.claude/commands/hve.md:107`, `hve-implement.md:109`, `.claude/agents/hve-phase-implementor.md:48` — Concurrent writes paragraph -> pointer (RL-06)
- `.claude/commands/hve-plan.md:25`, `hve-review.md:25`, `hve-challenge.md:25` — discovery stub (reference plus a restating summary) -> pure pointer
- `.claude/commands/hve-memory.md:37` — restated 4-step discovery algorithm -> pointer, keeping only the command-local mapping that its slug argument is `topic-slug` (RL-08)
- `.claude/commands/hve-implement.md:25` — discovery pointer added; this command had none (FC-01)

Tests (`tests/run-drift-tests.sh`):

- `tests/run-drift-tests.sh:351-365` — `test6_friction_flag_boilerplate` retired, replaced by a RETIRED banner recording why (DD-005); `FRICTION_FLAG_PREFIX` and `FRICTION_EXPECTED_COUNT` removed
- `tests/run-drift-tests.sh:534-538` — `CANONICAL_BLOCK_SPECS`: `discovery_stub` 3 -> 1 with its prefix repointed at the CLAUDE.md canonical sentence (DD-007), `concurrent_writes` 4 -> 1, and three net-new uniqueness rows `friction_capture`, `security_checklist`, `shell_stays_in_parent`, all `1|identical`
- `tests/run-drift-tests.sh:522-531` — spec-table comment documents that `expected=1` is a uniqueness assertion, not a duplication one
- `tests/run-drift-tests.sh:936` — new `test14_reference_resolution`, plus the `claude_md_headings` helper; every ``per CLAUDE.md's `Section` section`` pointer under `.claude/commands`, `.claude/agents`, `.claude/prompts` must equal a real CLAUDE.md heading. Comparison is literal string equality against the parsed heading list, so `&` and other regex metacharacters in section names need no escaping.
- `tests/run-drift-tests.sh:1009` — new `test15_behavioral_presence`, assertion 1 only, with an in-file comment naming plan Step 9.4 as the owner of assertion 2
- `tests/run-drift-tests.sh:16-18,40-44,955-960` — header comment and `main()` updated for the retirement and the two new tests

#### Steps Completed

- [x] Step 5.1: Friction Capture paragraph -> reference in six commands — `.claude/commands/hve-research.md:13` and five siblings
- [x] Step 5.2: `test6_friction_flag_boilerplate` retired and folded into `CANONICAL_BLOCK_SPECS` — `tests/run-drift-tests.sh:351`, `:536`
- [x] Step 5.3: Security Hygiene checklist -> reference (2 sites) — `.claude/agents/hve-implementation-validator.md:69`, `.claude/commands/hve-implement.md:142`
- [x] Step 5.4: "Shell stays in the parent" -> reference in `hve-review.md` — `.claude/commands/hve-review.md:81`
- [x] Step 5.5: "Concurrent writes" -> reference (3 sites); spec expects 1 — `tests/run-drift-tests.sh:535`
- [x] Step 5.6: Discovery algorithm -> reference in `hve-memory.md` — `.claude/commands/hve-memory.md:37`
- [x] Step 5.7: Discovery reference added to `hve-implement.md` (FC-01) — `.claude/commands/hve-implement.md:25`
- [x] Step 5.8: Update `discovery_stub` spec carrier count — `tests/run-drift-tests.sh:534`
- [x] Step 5.9: New test 14, reference resolution — `tests/run-drift-tests.sh:936`
- [x] Step 5.10: New test 15, behavioral presence, assertion 1 only — `tests/run-drift-tests.sh:1009`
- [x] Step 5.11: Run both suites; record the new drift baseline explicitly — see Test Delta below

#### Test Delta

New drift baseline: **218 passed, 0 failed** (was 211/0). Install unchanged at **66 passed, 0 failed**.

The +7 is fully accounted for; no assertion changed for a reason not listed here.

| Change | Assertions | Delta |
|---|---|---|
| Test 6 retired | 1 carrier-count + 6 per-carrier identity | -7 |
| `discovery_stub` 3 carriers -> 1 | was 1 count + 3 identity; now 1 count + 1 canonical | -2 |
| `concurrent_writes` 4 carriers -> 1 | was 1 count + 4 identity; now 1 count + 1 canonical | -3 |
| New rows `friction_capture`, `security_checklist`, `shell_stays_in_parent` | 1 count + 1 canonical each | +6 |
| New test 14 | 1 pointers-present + 6 distinct sections resolved | +7 |
| New test 15 | 5 per-command + 1 carrier floor | +6 |
| **Net** | | **+7** |

Distinct sections test 14 now resolves: `Artifact Discovery & Relevance`, `Concurrent Changes-Log Writes`, `Friction Capture`, `Security Hygiene`, `Subagent Dispatch Discipline`, `Untrusted Input`.

**Negative control run** (the three new guarantees were verified to fail when violated, not merely to pass): pointing `hve-memory`'s reference at a `Nonexistent Section` and appending a second `**Concurrent writes**` copy to `hve.md` produced `Results: 214 passed, 4 failed` — test 10 `concurrent_writes` carrier count, test 14 dangling pointer, and both test 15 assertions. Files were restored and the suite returned to 218/0. Without this, a test that passes vacuously would be indistinguishable from one that works.

#### Issues Encountered

- Step 5.1's replacement text could not be a bare pointer. `hve-research.md`, `hve-pr-review.md` and `hve-challenge.md` have no `## Argument Parsing` section, so "strip it before other parsing" existed only inside the friction paragraph in those three files. The replacement keeps that clause and defers only the behavior to CLAUDE.md.
- The RL-04 copies had already drifted, which is the finding itself: the validator's list carried `*.pfx` and an explicit `AKIA` prefix that CLAUDE.md's canonical list does not. Consolidating on CLAUDE.md drops both. See DD-008.
- Test 14 caught a violation in this phase's own edits before the suite was green: the first three concurrent-writes pointers were written as "in CLAUDE.md's ..." rather than the binding "per CLAUDE.md's ...", so they extracted as zero pointers and the section went unchecked. The test found it on the first run; the wording was corrected.

#### Discrepancies & Decisions

- DD-005 (2026-08-15): Retired `test6_friction_flag_boilerplate` as a bespoke function rather than rewriting it, per details section 2. Its inverted assertion ("exactly 1 carrier") is the shape `CANONICAL_BLOCK_SPECS` already expresses, and its corpus already includes `CLAUDE.md` where the sole carrier now lives; the function was duplicated logic of test 10, so keeping it would have re-created inside the test suite the defect the suite exists to catch. Test number 6 is left vacant so tests 7-13 keep their labels.
- DD-006 (2026-08-15): Promoted the Concurrent writes paragraph to its own `## Concurrent Changes-Log Writes` section (`CLAUDE.md:313`) instead of leaving it inside `## Optional Power-User: Hooks for Automatic Change Logging`. The reference contract requires pointing at a heading by name, and three files reading "see the Hooks section" for a rule that has nothing to do with hooks is the pointer rot the contract exists to prevent. Content is unchanged and byte-identical to the original paragraph.
- DD-007 (2026-08-15): Repointed the `discovery_stub` spec prefix from `Discover inputs per the Artifact Discovery & Relevance convention` (which existed only in the three command copies) to `Phase commands discover their input artifacts from` (the canonical CLAUDE.md sentence). Details section 2 requires the post-dedup count to be 1, which the old prefix cannot produce: after dedup it matches zero files, since CLAUDE.md never carried that wording. Verified unique to `CLAUDE.md:241`. The label is kept as `discovery_stub` because the plan and details cite it by that name.
- DD-008 (2026-08-15): Accepted a narrowing in the RL-04 consolidation. `hve-implementation-validator.md` asserted `*.pfx` in `.gitignore` and named `AKIA` explicitly; CLAUDE.md's canonical checklist lists five patterns and says "AWS/GCP key prefixes". `AKIA` is an example of what the canonical wording already covers, so nothing is lost there. `*.pfx` is a genuine narrowing, and widening the canonical bullet was rejected as the wrong phase to do it in: `CLAUDE.md`'s bullet states what `.gitignore` must list, and Phase 1 shipped an installer plus install-suite assertions for exactly five patterns. Adding a sixth here would desynchronize CLAUDE.md from `install.sh` and from test 4's list. Raised as a follow-on item instead.

#### Corrections

- Correction (2026-08-15): this section was first written with `Completed: 2026-08-15T17:53:11Z`, a value that came from no clock reading. The `date -u +%Y-%m-%dT%H:%M:%SZ` call made at completion returned `2026-08-15T17:41:53Z`, which is what the field now carries. Nothing else in the section depended on the value.

---

### Phase 6: Convention gaps, now single-site (RL-01, RL-02, RL-07)

Status: Complete
Started: 2026-08-15T17:46:27Z
Completed: 2026-08-15T17:47:38Z

Tests: drift 219 passed, 0 failed; install 66 passed, 0 failed

#### Files Modified

- `.claude/commands/hve-implement.md:19` — rewrote the Argument Parsing invariant so the flag-strip instructions are part of the single parse (RL-01)
- `.claude/commands/hve-review.md:19` — same rewrite, byte-identical (RL-01)
- `.claude/commands/hve-plan.md:13` — same rewrite, byte-identical (RL-01)
- `.claude/commands/hve-implement.md:42` — added the missing-instructions-file fallback reference to the Phase 1 instructions step (RL-02)
- `.claude/agents/hve-phase-implementor.md:19` — same reference on the Your Assignment bullet (RL-02)
- `.claude/agents/hve-phase-implementor.md:31` — same reference on Step 1 item 3 (RL-02)
- `.claude/agents/hve-phase-implementor.md:132` — same reference in Constraints (RL-02)
- `.claude/commands/hve-prompt-builder.md:30` — new Phase 1 step reading `writing-style.md` and `markdown.md` before drafting; later steps renumbered 3-5 (RL-07)
- `.claude/commands/hve-prompt-refactor.md:59` — new Protocol step 2 reading both files; later steps renumbered 3-7 (RL-07)
- `.claude/commands/hve-doc-ops.md:27` — Phase 1 step 3 now names both files as the compliance baseline (RL-07)
- `.claude/agents/hve-prompt-updater.md:32` — new Step 1 item 5 reading both files before the rewrite (RL-07)

#### Steps Completed

- [x] Step 6.1: RL-01 — Argument Parsing invariant matches actual order (3 files) — `hve-implement.md:19`, `hve-review.md:19`, `hve-plan.md:13`
- [x] Step 6.2: RL-02 — missing-instructions-file fallback reference — `hve-implement.md:42`, `hve-phase-implementor.md:19,31,132`
- [x] Step 6.3: RL-07 — wire `writing-style.md` and `markdown.md` into 4 prose commands — `hve-prompt-builder.md:30`, `hve-prompt-refactor.md:59`, `hve-doc-ops.md:27`, `hve-prompt-updater.md:32`
- [x] Step 6.4: Run both suites — drift 219/0, install 66/0

#### Issues Encountered

**Drift count moved 218 to 219, fully accounted for.** The single new row is
`test14: 'Instructions Reference' resolves`. Step 6.2 introduced the first pointer to that
CLAUDE.md section anywhere under `.claude/`, and test 14 emits one row per *distinct* section
pointed at (`sort -u` over the extracted matches). The seven Step 6.2/6.3 pointer sites collapse
to that one new distinct section, so the delta is +1, not +7. No other test row changed and no
test file was edited.

**Step 6.1 approach, and why the flag-strip paragraphs were left byte-identical.** Two rewrites
were available. (a) Convert the `--subagent-model` and `--friction-log` strip paragraphs in the
three files to consume the already-parsed named values, following `hve-plan.md`'s existing
`If SUBAGENT_MODEL is set, ...` precedent. (b) Leave those paragraphs untouched and reword the
invariant so it correctly describes them as the front half of one parse. Option (a) would have
dropped `hve-implement.md` and `hve-review.md` out of test 5's carrier set (`SUBAGENT_MODEL_PREFIX`
= `` If `--subagent-model ``, `tests/run-drift-tests.sh:312`), taking the carrier count from 7 to 5
and silently removing two byte-identity assertions on shared boilerplate. Option (b) was taken:
it fixes the stated defect (a self-contradicting parse instruction) without spending drift
coverage, and it keeps the rewrite minimal and structural as Phase 7 requires. Recorded as DD-009.

**Position-neutral wording was required.** `hve-plan.md` already places `## Argument Parsing`
above its friction paragraph while `hve-implement.md` and `hve-review.md` place it below both flag
paragraphs. The replacement sentence therefore says "elsewhere in this file" rather than "above",
so one byte-identical string is true in both structures. Verified identical: `grep -h ... | sort -u
| wc -l` returns 1 across the three files.

**Phase 7 handoff intact.** No `CANONICAL_BLOCK_SPECS` entry keys on the Argument Parsing
sentence (checked against `tests/run-drift-tests.sh:533-548`), so Step 7.3 can still remove
`THINK_MODE` from `hve-implement.md:19`'s parse list alone and make the three sentences
non-identical without reding the suite, exactly as the details doc section 3 states.

#### Discrepancies & Decisions

- DD-009 (2026-08-15): For RL-01, reworded the invariant rather than converting the flag-strip
  paragraphs to consume named values. Rationale: the conversion would have reduced test 5's
  `--subagent-model` byte-identity carriers from 7 to 5, trading a fixed documentation defect for
  lost drift coverage on shared boilerplate. The reworded invariant is truthful in all three files
  and costs no assertions. Scope note: `hve-research.md`, `hve-pr-review.md`, and `hve-challenge.md`
  keep the "strip before other parsing" wording untouched because they carry no single-parse
  invariant, so nothing in those files contradicts itself.

---

### Phase 7: Flag correctness, the dead-flag cluster (FC-02, DO-01, DEFECT 2, PS-05)

Status: Complete
Started: 2026-08-15T17:49:15Z
Completed: 2026-08-15T17:52:12Z
Tests: drift 219 passed, 0 failed; install 66 passed, 0 failed

#### Files Modified

- `.claude/commands/hve-review.md:87` — Phase 2 gains the one-line `--mode full` instruction to dispatch the Phase 3 quality validator in the same Agent batch as the RPI validators
- `.claude/commands/hve-review.md:105-114` — Phase 3 gains the `**Dispatch gate**` line (the `hve-plan.md` "If MODE is set… otherwise infer" pattern), a four-row mode table, and the invariant paragraph fixing the validator count at one in every mode
- `.claude/commands/hve-implement.md:88-97` — Phase 2 gains the `**Dispatch gate**` line, a four-row mode table, and the sentence stating `--mode lightweight` never suppresses the changes log, test gate, or security checks
- `.claude/commands/hve-implement.md:118` — Parallel-execution branch now names `--mode standard` as the mode that suppresses it
- `.claude/commands/hve-implement.md:19` — `THINK_MODE (\`--think\` present), ` removed from the parse list (DD-002)
- `CLAUDE.md:45` — `/hve-implement` Command Reference row documents all three `--mode` values (DO-01)
- `CLAUDE.md:46` — `/hve-review` Command Reference row documents what `--mode` now changes there

#### Steps Completed

- [x] Step 7.1: Wire `MODE` in `hve-review.md` to gate validator dispatch — `.claude/commands/hve-review.md:105`, `.claude/commands/hve-review.md:87`
- [x] Step 7.2: Wire `MODE` in `hve-implement.md` — `.claude/commands/hve-implement.md:88`, `.claude/commands/hve-implement.md:118`
- [x] Step 7.3: Remove `THINK_MODE` from `hve-implement.md` parse list (DD-002) — `.claude/commands/hve-implement.md:19`
- [x] Step 7.4: Document `--mode` on the `/hve-implement` CLAUDE.md row — `CLAUDE.md:45-46`
- [x] Step 7.5: Run both suites — drift 219/0, install 66/0, both equal to the entry baseline

#### Issues Encountered

- The `simple_carveout_guarantee` spec (`tests/run-drift-tests.sh:545`, `2|present`) was the live hazard. The carve-out sentence at `.claude/commands/hve-implement.md:99` is untouched; the new mode-table paragraph states the same guarantee in deliberately different words ("never suppresses the changes log, the per-phase test gate, or the security hygiene checks") so the carrier count stays at 2 rather than rising to 3. Test 10 passes.
- `--mode standard` on `hve-implement` is a narrowing of the unset default, not a no-op: unset still parallelizes independent phases (`.claude/commands/hve-implement.md:118`, unchanged wording), while `standard` now serializes them. Details section 3 is binding here, listing `standard` as "Dispatch phase implementors sequentially"; the plan's "unset -> unchanged" requirement is met because the unset path never consults the new table.
- Out of scope, surfaced not fixed: `.claude/commands/hve-review.md:142` reads "If `--think` was passed in `$ARGUMENTS`", which re-reads `$ARGUMENTS` and contradicts the parse-once invariant Phase 6 wrote at `:19` ("none re-reads `$ARGUMENTS`"). `hve-plan.md:36` already has the correct form, "Use THINK_MODE from Argument Parsing". Minor, and it belongs to the invariant Phase 6 owns rather than to the `--mode` wiring; no edit made.

#### Discrepancies & Decisions

- DD-002 (2026-08-15): Removed `THINK_MODE` from `hve-implement.md`'s parse list rather than wiring it. `/hve-implement` executes an already-reasoned plan, so it has no synthesis step for extended reasoning to improve, and the flag was absent from the file's `argument-hint` at `:3` anyway, so no advertised interface shrinks. The identical sentences in `hve-review.md:19` and `hve-plan.md:13` are untouched, where `--think` is both advertised and used. The three Argument Parsing sentences are now non-identical, which is safe: no `CANONICAL_BLOCK_SPECS` row covers that sentence (verified against `tests/run-drift-tests.sh:532-547`), and test 10 passes.
- DD-003 (2026-08-15): Documented `--mode` on the `/hve-review` CLAUDE.md row as well as the `/hve-implement` row DO-01 named. Step 7.1 changes what `--mode` does on `/hve-review`, and the plan's own scope line for this phase budgets "CLAUDE.md (2 table rows)". Leaving the review row silent would have shipped the same undocumented-flag defect DO-01 exists to close.

---

### Phase 8: Dispatch bounds and context discipline (PS-01, PS-02, PS-03, PS-04, PS-06, PS-07)

Status: Complete
Started: 2026-08-15T17:54:00Z
Completed: 2026-08-15T17:56:43Z

Tests: drift 219 passed, 0 failed; install 66 passed, 0 failed. No delta from the phase-entry
baseline, which is the expected outcome: every edit is prose inside command files, and none of
them touches a `CANONICAL_BLOCK_SPECS` prefix, a test 14 pointer, or a test 15 carrier.

#### Files Modified

- `.claude/commands/hve-research.md:29` — Phase 0 table column renamed to `Subagent count (upper number is a hard cap)`
- `.claude/commands/hve-research.md:38` — new paragraph making the tier's upper number binding on Phase 2 dispatch (Medium 2, Medium-Hard 3, Challenging 5; `--mode` caps 1/3/5), with an ask-the-user escape
- `.claude/commands/hve-research.md:51` — Phase 1 step 4 now caps the theme count at the Phase 0 cap and forbids one-subagent-per-question
- `.claude/commands/hve-research.md:63` — Phase 2 dispatch restated as "theme count IS the dispatch count", regroup rather than exceed
- `.claude/commands/hve.md:67-68` — inline research steps carry the same classification-derived cap; `--mode` sets the classification, so it sets the cap
- `.claude/commands/hve-review.md:99` — context-discipline paragraph rewritten: full-text consolidation wins; context discipline moves to the layer below the validation artifacts
- `.claude/commands/hve-review.md:142` — `--think` consumed as `THINK_MODE from Argument Parsing` instead of re-reading `$ARGUMENTS` (parent-added Step 8.7)
- `.claude/commands/hve-implement.md:113-114` — post-subagent verification scoped to the one `### Phase N:` section just written
- `.claude/commands/hve-doc-ops.md:49-54` — Phase 2 fan-out bounded at 8 subagents with an explicit descending-size batching rule, per-subagent file lists, and a session-log record requirement
- `.claude/commands/hve-git-merge.md:55` — conflict-marker dump capped at `head -100` with a truncation-disclosure rule

#### Steps Completed

- [x] Step 8.1: PS-01 — tie research theme count to the difficulty tier — `.claude/commands/hve-research.md:29,38,51,63`
- [x] Step 8.2: PS-02 — same gate in `hve.md` — `.claude/commands/hve.md:67-68`
- [x] Step 8.3: PS-03 — resolve the `hve-review.md` consolidation contradiction — `.claude/commands/hve-review.md:99`
- [x] Step 8.4: PS-04 — scope post-subagent changes-log verification — `.claude/commands/hve-implement.md:113-114`
- [x] Step 8.5: PS-06 — bound the `hve-doc-ops.md` fan-out — `.claude/commands/hve-doc-ops.md:49-54`
- [x] Step 8.6: PS-07 — cap the `hve-git-merge.md` diff dump — `.claude/commands/hve-git-merge.md:55`
- [x] **Step 8.7 (ADDED by the parent this session; not in the original plan)**: consume `THINK_MODE` from Argument Parsing in `hve-review.md` instead of re-reading `$ARGUMENTS` — `.claude/commands/hve-review.md:142`. See DD-010
- [x] Step 8.8: Run both suites — drift 219/0, install 66/0

#### Issues Encountered

- PS-03's contradiction could not be closed by softening either side, because the two sentences
  disagreed on a load-bearing question. Phase 4's tally-integrity rule ("never write a tally from
  memory", `hve-review.md:149`) already decides it: a Critical finding or a count reconstructed
  from a chat summary is exactly what that rule forbids. So full-text consolidation wins and the
  skim instruction is deleted, not hedged. The replacement mirrors `hve-research.md:83-84`, which
  had already solved the same problem correctly (read the subagent artifacts in full; apply context
  discipline to the layer below them).
- Phase 7's `--mode` wiring in `hve-review.md` Phase 3 and `hve-implement.md` Phase 2 was preserved
  intact; both mode tables are untouched by this phase's edits. The `simple_carveout_guarantee`
  spec still counts 2 carriers.
- Step 8.5 left `hve-doc-ops.md:55`'s "(per the CLAUDE.md Subagent Dispatch Discipline)" in its
  existing non-contract form. It is a Minor consistency gap against the reference syntax contract
  and belongs to no Phase 8 step, so it is raised as a follow-on rather than fixed here.

#### Discrepancies & Decisions

- DD-010 (2026-08-15): Executed a parent-added Step 8.7 that the plan does not contain. `hve-review.md:142` read "If `--think` was passed in `$ARGUMENTS`", contradicting the parse-once invariant Phase 6 wrote into `:19` of the same file ("Every other section uses these named values; none re-reads `$ARGUMENTS`"). It is the same file and the same defect class as PS-03 — an instruction contradicting another instruction in one file — and this phase's success criterion is exactly that no two instructions in one file contradict. Fixed to `hve-plan.md:36`'s already-correct form, "Use THINK_MODE from Argument Parsing". Swept the rest of the file: the only other `$ARGUMENTS` mentions are the `--subagent-model` strip at `:11` and the `--friction-log` strip at `:13`, both of which `:19` explicitly claims as part of the single parse, so neither is a re-read and neither was changed.
- DD-011 (2026-08-15): Set the `hve-doc-ops.md` fan-out cap at 8 rather than inventing a doc-ops-specific number. The plan directs this step to follow `/hve-pr-review`'s "explicitly capped 8/4 design", and 8 is that precedent's own maximum. A doc set has no fixed natural cardinality to derive a cap from (unlike pr-review's eight fixed dimensions), so any other number would have been arbitrary. `--compact`'s 4-way pairing was NOT ported: it exists to halve a fixed dimension list, and doc-ops has no such list — the batching rule (7 largest get their own subagent, the remainder share the eighth) is what bounds an oversized split instead.

---

### Phase 9: Missing fallbacks and the corrections protocol (RO-01, RO-02, DA-01)

Status: Complete
Started: 2026-08-15T17:59:26Z
Completed: 2026-08-15T18:03:18Z

Tests: drift 229 passed, 0 failed; install 66 passed, 0 failed.

#### Files Modified

RO-01 / RO-02 (Steps 9.1, 9.2):

- `.claude/commands/hve-implement.md:28` — Details declared a RECONSTRUCTIBLE input with a record-skip-and-proceed branch (`Details: none — [reason]` in the changes log header plus a `DD-` entry), shaped after `hve-plan.md:27` and `hve-review.md:32`
- `.claude/commands/hve-implement.md:29` — resume path on the changes log now invokes the annotate-in-place-plus-dated-Correction protocol by reference
- `.claude/commands/hve-implement.md:82` — new trigger paragraph naming what fires the `#### Corrections` stub at `:74-75`, tied to the Phase 3 consolidation gate
- `.claude/commands/hve-plan.md:28` — resume/update path on an existing plan now invokes the same corrections protocol by reference

DA-01 (Step 9.3):

- `.claude/commands/hve-review.md:4` — `allowed-tools` gains `Edit`, so the append instructions at `:43` and `:153` no longer force a whole-file `Write`

Test coverage (Step 9.4):

- `tests/run-drift-tests.sh:999-1006` — test 15 banner: the deferred-assertion notice replaced by the rationale for assertion 2 and its mechanical proxy
- `tests/run-drift-tests.sh:1013-1015` — new `RECORD_SKIP_MARKER`, `RECONSTRUCTIBLE_CONSUMERS`, `RECORD_SKIP_CARRIER_FLOOR` constants
- `tests/run-drift-tests.sh:1045-1070` — assertion 2 body, matching assertion 1's per-file row plus floor-row shape
- `tests/run-drift-tests.sh:1115` — run_test label widened from "artifact-discovering commands carry the reference" to "documented behaviors present in their consumers", which is now what the test asserts

Reference normalization (Step 9.5, parent-added):

- `.claude/commands/hve-doc-ops.md:54` — "(per the CLAUDE.md Subagent Dispatch Discipline)" -> contract form (the one Phase 8 surfaced)
- `.claude/commands/hve-implement.md:31` — "(see the CLAUDE.md Artifact Discovery & Relevance convention)" -> contract form
- `.claude/commands/hve-implement.md:101` — "per the CLAUDE.md difficulty table including the risk-override footnote: < 50 lines, single file, clear requirements, no elevated-risk surface" -> `The RPI Methodology` contract form, restated criteria dropped (see DD-013)
- `.claude/commands/hve-plan.md:97` and `.claude/agents/hve-plan-validator.md:44` — bare "per CLAUDE.md." / "(CLAUDE.md)" -> `Confidence Markers` contract form
- `.claude/commands/hve-review.md:41,43,153` and `.claude/agents/hve-phase-implementor.md:70` — "per the CLAUDE.md corrections convention" -> `Corrections in Tracking Artifacts` contract form
- `.claude/agents/hve-implementation-validator.md:81` — "Per the CLAUDE.md citation convention" -> `Citation Format` contract form, reworded so `per` is lowercase mid-sentence (the extractor is case-sensitive)
- `.claude/commands/hve-prompt-builder.md:60` — "(per CLAUDE.md Template Blanks)" -> `Template Blanks` contract form
- `.claude/commands/hve-pr-review.md:86` and `.claude/agents/hve-pr-reviewer.md:66` — bare "per CLAUDE.md" -> `Severity Grading` contract form
- `.claude/commands/hve-pr-review.md:116` and `.claude/agents/hve-pr-reviewer.md:45` — "Run the full security checklist from CLAUDE.md: secret exposure, .gitignore hygiene, ..." -> `Security Hygiene` contract form, with the two canonical bullets dropped and only the four non-canonical dimensions retained

#### Steps Completed

- [x] Step 9.1: RO-01 — record-skip branch for a missing Details doc — `.claude/commands/hve-implement.md:28`
- [x] Step 9.2: RO-02 — resume paths invoke the corrections protocol; `#### Corrections` stub given a trigger — `.claude/commands/hve-implement.md:29,82`, `.claude/commands/hve-plan.md:28`
- [x] Step 9.3: DA-01 — `Edit` added to `hve-review.md` allowed-tools — `.claude/commands/hve-review.md:4`
- [x] Step 9.4: Assertion 2 added to test 15, negative control run — `tests/run-drift-tests.sh:1045-1070`
- [x] **Step 9.5 (ADDED by the parent this session; not in the original plan)**: normalize `hve-doc-ops.md`'s non-contract reference and sweep `.claude/**/*.md` for other near-misses; 13 lines across 9 files normalized. See DD-012 and DD-013
- [x] Step 9.6: Run both suites — drift 229/0, install 66/0

#### Issues Encountered

**Step 9.4 negative control (the assertion is not vacuous).** With the record-skip
clause stripped from `hve-implement.md:28` by a scripted edit and nothing else changed,
the suite returned **227 passed, 2 failed**: `test15: hve-implement record-skip branch`
and `test15: record-skip carrier floor` (expected >= 3 carriers, got 2). The file was
restored from a scratchpad backup and the suite returned to 229/0. Both the per-file row
and the floor row fire, so neither is dead weight.

**Drift delta arithmetic: 219 -> 229 (+10).** Both halves are Phase 9's own additions;
no pre-existing row changed state.

| Source | Rows | Detail |
|---|---|---|
| Step 9.4, test 15 assertion 2 | +4 | 3 per-command rows (`hve-plan`, `hve-implement`, `hve-review`) + 1 carrier-floor row |
| Step 9.5, test 14 new resolvable sections | +6 | `Citation Format`, `Confidence Markers`, `Corrections in Tracking Artifacts`, `Severity Grading`, `Template Blanks`, `The RPI Methodology` |

Test 14's pointer inventory went 7 -> 13 distinct sections. Only 6 of the 7 sections
Step 9.5 normalized produce a new row: `Subagent Dispatch Discipline` already had a
carrier elsewhere in the corpus, so normalizing `hve-doc-ops.md:54` added a pointer to an
already-asserted section rather than a new assertion row. Install stayed 66/0 as required;
nothing in this phase touches `install.sh` or its suite.

**Constraints verified intact.** `CANONICAL_BLOCK_SPECS` uniqueness rows all pass: no
canonical block was re-introduced. `simple_carveout_guarantee` is still `2|present` — the
guarantee sentence at `hve-implement.md:101` ("still creating and updating the changes log
and running the test gate") was left byte-intact while the parenthetical before it was
normalized, and no third carrier was added. Phase 7's `--mode` tables in `hve-review.md`
and `hve-implement.md` and Phase 8's tier-caps and PS-04 scoping are untouched; test 10
and test 13 are green.

**Not normalized, deliberately.** Two `CLAUDE.md` mentions were left in prose form because
neither names a section: the whole-file preamble "Read and follow all HVE conventions in
CLAUDE.md before proceeding" (present in 20 files — it points at the document, not a
heading), and `hve-doc-ops.md:27` "check CLAUDE.md and existing templates for
project-specific additions", which is an instruction to search the file rather than a
pointer to a named rule. Forcing either into the contract construction would name a
section neither one means.

#### Discrepancies & Decisions

- DD-012 (2026-08-15): Executed a parent-added Step 9.5 the plan does not contain. Phase 8
  surfaced `hve-doc-ops.md:54` carrying "(per the CLAUDE.md Subagent Dispatch Discipline)",
  a pointer in prose form that test 14's extractor cannot see. Swept `.claude/commands/*.md`,
  `.claude/agents/*.md`, and `.claude/prompts/*.md` for the same defect class and found 12
  more lines across 8 further files. All 13 were normalized to the binding construction. The
  scope expansion is justified by the finding's own logic rather than by convenience: a
  pointer test 14 cannot see is a pointer nothing protects, so leaving eight of nine files in
  prose form would have closed the instance and left the class open. Net effect is measurable
  — test 14's inventory rose from 7 to 13 distinct sections, all resolving.
- DD-013 (2026-08-15): Dropped the restated difficulty criteria at `hve-implement.md:101`
  ("< 50 lines, single file, clear requirements, no elevated-risk surface") when converting
  its parenthetical to the contract construction, rather than keeping them alongside the new
  pointer. The reference syntax contract (details section 5) states the canonical text is
  never restated alongside the reference, "not even as a summary", and that rule binds every
  reference this phase writes. Keeping the list would have shipped a contract-form pointer in
  violation of the contract on the same line. Verified nothing depends on the removed string:
  `grep -rn "elevated-risk surface\|50 lines, single file" tests/ .claude/ docs/` returns only
  that line, and the `simple_carveout_guarantee` spec keys off the sentence that follows it,
  which is unchanged.
- No `DR-` items: nothing in this phase revealed undocumented behavior, and no test
  expectation was adjusted. The +4 rows from test 15 assertion 2 are net-new coverage the
  plan scheduled here (Step 5.10's deferred half), not a loosened expectation; the +6 rows
  from test 14 are the existing assertion applied to newly-visible pointers.

---

### Phase 10: Subagent Response Protocol, criterion before formats (II-01 through II-07)

Status: Complete
Started: 2026-08-15T18:04:28Z
Completed: 2026-08-15T18:09:06Z

Tests: drift 248 passed, 0 failed; install 66 passed, 0 failed

#### Files Modified

- `.claude/agents/hve-prompt-evaluator.md:45` — QA criterion replaced by a reference to CLAUDE.md's `Subagent Response Protocol` section (II-04)
- `.claude/agents/hve-prompt-evaluator.md:85-86` — evaluation-log `## Verdict` block switched to Pass / Fail vocabulary
- `.claude/agents/hve-prompt-evaluator.md:91-100` — Response Format rebuilt to the six-part protocol with validator Pass/Fail status and the clarifying-questions part (II-03)
- `.claude/agents/hve-prompt-tester.md:90-99` — Response Format gained the clarifying-questions part and a documented `Blocked` variant (II-02)
- `.claude/agents/hve-prompt-updater.md:60` — QA criterion replaced by the same reference (II-07)
- `.claude/agents/hve-prompt-updater.md:102-110` — Response Format rebuilt: Complete/Blocked status, 5-item checklist, clarifying-questions part (II-01)
- `.claude/commands/hve-prompt-analyze.md:53` — QA criterion replaced by the same reference (II-05)
- `.claude/commands/hve-prompt-refactor.md:47` — QA criterion replaced by the same reference (II-06)
- `tests/run-drift-tests.sh:27-29` — test 7 header comment rewritten for the widened scope
- `tests/run-drift-tests.sh:58-70` — `FULL_PROTOCOL_AGENTS` widened from 6 to all 9 agents; the comment licensing a "reduced, sandbox-local" format was removed, since the review found it was drift rather than intent
- `tests/run-drift-tests.sh:369-415` — `test7_response_protocol_structure` and its rewritten header comment; the greps now cover the `## Response Format` section only, with tightened question and checklist patterns
- `tests/run-drift-tests.sh:417-428` — new `response_format_section` helper (awk section slicer)
- `tests/run-drift-tests.sh:430-443` — `_grep_invariant` takes section text instead of a file path

#### Steps Completed

- [x] Step 10.1: Fix the QA criterion first, in all four carriers — replaced each 3-part paraphrase with a reference in the Phase 5 contract form: `.claude/agents/hve-prompt-evaluator.md:45` (II-04), `.claude/commands/hve-prompt-analyze.md:53` (II-05), `.claude/commands/hve-prompt-refactor.md:47` (II-06), `.claude/agents/hve-prompt-updater.md:60` (II-07)
- [x] Step 10.2: II-01 — `hve-prompt-updater.md` Response Format — `.claude/agents/hve-prompt-updater.md:102-110`: status line is now `Status: Complete` | `Blocked: [reason]`, the follow-on checklist caps at 5 (was 3 deferred findings), the clarifying-questions part was added, and the applied-fix counts moved into the findings bullets so the format is exactly 6 parts
- [x] Step 10.3: II-02 — `hve-prompt-tester.md` Response Format — `.claude/agents/hve-prompt-tester.md:90-99`: added the clarifying-questions part and documented the `Blocked` variant (was hardcoded `Status: Complete`), including the rule that an ambiguity is a finding rather than a block
- [x] Step 10.4: II-03 — `hve-prompt-evaluator.md` Response Format — `.claude/agents/hve-prompt-evaluator.md:91-100`: replaced `Verdict: No issues remaining: Yes/No` with validator Pass/Fail and added the clarifying-questions part; the evaluation-log template's own `## Verdict` block at `:85-86` was switched to the same vocabulary so the file does not contradict itself
- [x] Step 10.5: Extend drift test 7 — two changes, both required. (a) `tests/run-drift-tests.sh:68-70` brings the three prompt-builder agents into `FULL_PROTOCOL_AGENTS`, so their status line and clarifying-questions part are now asserted at all. (b) `tests/run-drift-tests.sh:385-419` anchors the invariant greps to the `## Response Format` section via the new `response_format_section` helper, and tightens the patterns to `Up to 3 clarifying question` and `Up to 5 checklist item`. Part (b) is what removes the vacuity: the old whole-file grep `Up to \**3\**` matched incidental text elsewhere in the same agent.
- [x] Step 10.6: Run both suites — drift 248 passed / 0 failed; install 66 passed / 0 failed

#### Test gate and delta arithmetic

Baseline entering Phase 10 (re-verified in-session before any edit, not taken on trust): drift **229 passed, 0 failed**; install **66 passed, 0 failed**.

Exit: drift **248 passed, 0 failed**; install **66 passed, 0 failed**. Delta **+19 drift assertions, 0 failures**, fully accounted for:

| Source | Assertions | Arithmetic |
|---|---|---|
| Test 7 widened from 6 to 9 agents | +18 | 3 new agents x 6 invariant lines each; observed `grep -c "test7:"` = 54, was 36 |
| Test 14 gained a new distinct pointer target | +1 | The four Step 10.1 references all name `Subagent Response Protocol`, a section no pointer previously named; test 14 emits one assertion per distinct section, now 14 |
| **Total** | **+19** | 229 + 18 + 1 = 248 |

No assertion was removed, weakened, or renumbered. Install is untouched by this phase and held at 66/0.

#### Step 10.5 negative control (proof the test is not vacuous)

Two controls were run, each restored immediately afterward from a scratchpad backup; the suite returned to 248/0 after each restore.

1. **Clarifying-questions part.** Deleted `5. Up to 3 clarifying questions (only if blocking)` from `.claude/agents/hve-researcher.md`'s Response Format. Result: `[FAIL] test7: hve-researcher 3-question cap` — suite 247 passed, 1 failed. Critically, `grep -cE 'Up to \**3\**'` against the same mutated file still returned **1** (the decoy `[Up to 3 questions that are blocking...]` in the output template at `.claude/agents/hve-researcher.md:81`), so the pre-Phase-10 whole-file grep would have stayed **green** on this exact mutation. That is the vacuity Step 10.5 existed to close, demonstrated rather than asserted.
2. **Status line.** Deleted the `Status: Pass | Fail` line from `.claude/agents/hve-prompt-evaluator.md`'s Response Format. Result: `[FAIL] test7: hve-prompt-evaluator status line` — suite 247 passed, 1 failed. Before this phase the evaluator was not in `FULL_PROTOCOL_AGENTS` at all, so no status assertion covered it.

Both files verified restored byte-for-byte (`.claude/agents/hve-researcher.md:94` and `.claude/agents/hve-prompt-evaluator.md:94` present) before the phase was closed.

#### Issues Encountered

- The plan's Step 10.5 wording ("extend test 7 so a missing status line or clarifying-questions section fails mechanically") understates the work: test 7 already *had* status-line and 3-question greps, but they ran against the whole agent file and excluded the three agents Phase 10 was fixing. Both defects had to be closed for the step to mean anything. Recorded as DD-014.
- The three prompt-builder agents' reduced format was not merely undocumented drift: `tests/run-drift-tests.sh:59-64` actively *licensed* it in a comment ("intentionally use a reduced, sandbox-local Response Format"). The comment was removed rather than narrowed; there is now no licensed reduced format.
- Scope note: Step 10.4 names only the Response Format, but the same non-standard verdict vocabulary also appeared in the evaluator's own evaluation-log template (`## Verdict / No issues remaining: Yes/No`). Leaving it would have made the file contradict itself one screen apart, so it was changed to match. Verified by grep that nothing consumes the old string — `hve-prompt-builder.md`, `.claude/prompts/`, and `docs/` have no reference to it.
- Repo-wide grep confirms no paraphrase of the protocol survives anywhere: `grep -rn "7-finding\|full-detail pointer" .claude/ docs/ README.md CLAUDE.md` returns nothing. CLAUDE.md is the sole carrier.

#### Discrepancies & Decisions

- DD-014: Step 10.5 implemented as a two-part change (widen `FULL_PROTOCOL_AGENTS`; anchor the greps to the `## Response Format` section) rather than the single "extend test 7" the plan implies. Rationale: widening alone would have left the pre-existing whole-file greps vacuous for all nine agents, and anchoring alone would have left the three non-compliant agents unchecked. Negative control 1 above is the evidence that the anchoring half is load-bearing. No plan step was skipped or added; this records how one step was executed.

---

### Phase 11: Documentation sync (DO-02, DO-03, DO-04, DO-05, DO-06)

Status: Complete
Started: 2026-08-15T18:11:01Z
Completed: 2026-08-15T18:17:02Z

Tests: drift 248 passed, 0 failed; install 66 passed, 0 failed (both identical to the
baseline entering this phase — no doc-sync drift test picks up any of these rows, so no
count was expected to move and none did).

#### Files Modified

- `CLAUDE.md:43` — `/hve-research` reference row gains `--mode` with its dispatch caps (1/3/5), read from `hve-research.md:20,38`
- `CLAUDE.md:44` — `/hve-plan` reference row gains `--mode` with its planning-complexity branches, read from `hve-plan.md:38-43`
- `CLAUDE.md:47` — `/hve-pr-review` row gains `--dimension` describing the Phase 3 security floor as landed in `hve-pr-review.md:90-98`
- `CLAUDE.md:50` — `/hve-doc-ops` row gains `--scope all|compliance|accuracy|gaps`, read from `hve-doc-ops.md:3,18`
- `CLAUDE.md:357` — global-install paragraph: `--global` now points at both the tracking rules and the credential patterns (Step 11.7)
- `CLAUDE.md:382` — new closing paragraph under `### Tracking folder & version control` noting the credential patterns are also written and are not replaced by the private-folder rule
- `README.md:43` — project paste-install prompt now instructs adding the five credential patterns (Step 11.7 extension)
- `README.md:123-126` — the four phase-command rows reconciled against `CLAUDE.md:43-46`; all four now carry `--mode` (Step 11.8)
- `README.md:134` — `/hve-pr-review` row reconciled to the same security-floor wording as `CLAUDE.md:47`
- `README.md:136` — `/hve-doc-ops` row reconciled to `CLAUDE.md:50`, plus a note that the path argument is separate from `--scope`
- `README.md:178` — corrected the invalid example `--scope src/auth/`; `--scope` takes `all|compliance|accuracy|gaps`, a path is positional
- `README.md:238` — credential-pattern note added after the gitignore options block
- `docs/reference.md:29` — `friction/` entry added to the tracking-folder diagram (DO-06)
- `docs/reference.md:65-66` — `javascript.md` and `typescript.md` added to the language table (DO-05), in the same order as `install.sh:92-95`
- `docs/installation.md:25` — paste-install prompt gains the credential patterns (Step 11.7 extension)
- `docs/installation.md:88` — Option B step 7 gitignore block gains the security-hygiene group
- `docs/installation.md:105` — `javascript.md` / `typescript.md` added to the manual-migration list (DO-05)
- `docs/installation.md:157` — global paste-install prompt gains the credential patterns
- `docs/installation.md:189` — global-install "what differs" gitignore block gains the security-hygiene group
- `docs/internals.md:9` — CLAUDE.md convention list extended with untrusted-input handling and the concurrent changes-log-write rule (Step 11.9)
- `docs/internals.md:50` — "always runs these 11 checks" corrected: scope is additive since Phase 3
- `docs/internals.md:62` — restated security checklist replaced by a pointer to CLAUDE.md's Security Hygiene section; the restatement had gone stale at 3 of 5 patterns
- `install.sh:262` — global-mode "Done. Next:" guidance now emits the full set project mode writes (Step 11.7)

#### Steps Completed

- [x] Step 11.1: DO-02 — `--mode` on the research/plan rows — `CLAUDE.md:43-44`, `README.md:123-124`
- [x] Step 11.2: DO-03 — `--dimension` with Phase 3 security-floor semantics — `CLAUDE.md:47`
- [x] Step 11.3: DO-04 — `--scope` on the doc-ops row — `CLAUDE.md:50`
- [x] Step 11.4: DO-05 — `javascript.md` / `typescript.md` — `docs/reference.md:65-66`, `docs/installation.md:105`
- [x] Step 11.5: DO-06 — `friction/` in the tracking diagram — `docs/reference.md:29`
- [x] **Step 11.7 (ADDED by the parent this session; not in the original plan)**: global-mode gitignore guidance brought level with what project mode writes — `install.sh:262`, `CLAUDE.md:357`, plus four further install surfaces carrying the same understatement. See DD-015 and DD-016
- [x] **Step 11.8 (ADDED by the parent this session; not in the original plan)**: `README.md` Command Reference reconciled against `CLAUDE.md`'s — `README.md:123-126,134,136,178`. See DD-017
- [x] **Step 11.9 (ADDED by the parent this session; not in the original plan)**: `docs/` checked for stale enumeration of CLAUDE.md sections and tracking conventions — `docs/internals.md:9,50,62`. See DD-018
- [x] Step 11.6: Final suite run plus by-execution installer verification (below)

#### Installer verification (Step 11.6, by execution)

Run against a fresh scratch tree, not by reading the diff. `bash -n install.sh` exited 0.

Fresh `git init` target, first install — full `.gitignore` as written:

```
# HVE tracking: commit durable artifacts, ignore regenerable noise
.claude-hve-tracking/**/subagents/
.claude-hve-tracking/sandbox/

# HVE security hygiene: never commit credentials
.env
.env.*
*.pem
*.key
*.p12
```

Whole-line assertions on that target: `PASS .env x1`, `PASS .env.* x1`, `PASS *.pem x1`,
`PASS *.key x1`, `PASS *.p12 x1`.

Second install on the same target (idempotency): all five patterns still `x1`, plus
`PASS header x1` and `PASS tracking-header x1`; file still 10 lines, so nothing duplicated.

Third target seeded with `node_modules/`, `.env`, `*.key` before installing — resulting file:

```
node_modules/
.env
*.key

# HVE tracking: commit durable artifacts, ignore regenerable noise
.claude-hve-tracking/**/subagents/
.claude-hve-tracking/sandbox/

# HVE security hygiene: never commit credentials
.env.*
*.pem
*.p12
```

Only the three missing patterns were appended; the user's pre-existing `.env` and `*.key`
were left in place and unduplicated (`PASS node_modules/ x1`, `PASS .env x1`, `PASS *.key x1`).
The Phase 1 change survived all eleven phases intact.

Global mode re-run with `HOME` redirected into the scratch tree, `Done. Next:` item 2 output:

```
  2. Add these lines to each project's .gitignore where you use /hve
     (this is exactly what a project-mode install writes):
       # HVE tracking: commit durable artifacts, ignore regenerable noise
       .claude-hve-tracking/**/subagents/
       .claude-hve-tracking/sandbox/

       # HVE security hygiene: never commit credentials
       .env
       .env.*
       *.pem
       *.key
       *.p12
```

#### DD-008 leftover: the three credential lists

Verified rather than reconciled, per the phase instruction. `*.pfx` was NOT added.

| Surface | Patterns named |
|---|---|
| `CLAUDE.md:295` | `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` |
| `install.sh:246-250` | `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` |
| `tests/run-drift-tests.sh:291` | `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` |

All three name the same five, in the same order. **No mismatch to report.** `*.pfx` appears
in none of them, so DD-008's narrowing is consistent across every surface and needs no
follow-up beyond the feature question of whether five is the right set — out of scope here.

#### Issues Encountered

- Step 11.7 as written named two surfaces (`install.sh` global guidance, `CLAUDE.md` global
  paragraph). Four more carried the identical understatement: `README.md:43`,
  `docs/installation.md:25`, `:88`, `:157`, `:189`. Fixing only the two named would have left
  a paste-install or Option-B user with a different `.gitignore` than `install.sh` produces,
  which is the asymmetry the step exists to close. All six fixed. See DD-015.
- `README.md:178` carried an invalid usage example, `/hve-doc-ops --scope src/auth/`. `--scope`
  accepts `all|compliance|accuracy|gaps` (`hve-doc-ops.md:3`); a path is the positional
  argument. Corrected while reconciling the doc-ops row. Not a new finding class — the same
  undocumented/misdocumented-flag defect DO-04 covers.
- `docs/internals.md:62` held a fourth copy of the security checklist that had drifted to 3 of
  5 patterns (`.env`/`.pem`/`.key`). Replaced with a pointer. Note for review: `docs/` is not
  in `canonical_block_corpus` (`tests/run-drift-tests.sh:582-590`, which covers commands,
  agents, prompts, and `CLAUDE.md` only), so no drift test would have caught this and none
  guards the replacement. Flagged as a follow-on rather than fixed here.
- No `CANONICAL_BLOCK_SPECS` prefix was touched. The five `CLAUDE.md`-carried prefixes
  (`Phase commands discover their input artifacts from`, `**Concurrent writes**`,
  ``accept an optional `--friction-log` flag``, `- **Secret exposure**: grep changed files for`,
  `**Shell stays in the parent.**`) all sit outside the Command Reference table and the two
  install sections this phase edited. Test 10 confirms.
- The `CLAUDE.md:382` and `CLAUDE.md:357` additions use the reference contract form
  (per CLAUDE.md's `Security Hygiene` section). Test 14 scans `.claude/**` only, not
  `CLAUDE.md` itself, so these self-references are unenforced; the heading exists at
  `CLAUDE.md:290` and was verified by grep.

#### Discrepancies & Decisions

- DD-015 (2026-08-15): Extended parent-added Step 11.7 from the two named surfaces to all six
  carrying the defect. The step's stated purpose is that a `--global` user is not told less
  than a project install writes; `README.md:43`, `docs/installation.md:25`, `:88`, `:157`, and
  `:189` are the surfaces a Windows or no-bash user actually follows, and leaving them stale
  would have shipped exactly the asymmetry the step closes while satisfying its literal wording.
  Every list was transcribed from `install.sh:239-250` and then re-verified by executing the
  installer, not written from memory.
- DD-016 (2026-08-15): Wrote `CLAUDE.md:357` as a pointer to `CLAUDE.md`'s `Security Hygiene`
  section rather than as a sixth verbatim copy of the five patterns. Step 11.7 says the guidance
  must "list what project mode actually writes"; a reader following the pointer reaches the full
  list twelve lines up in the same file, so the information is obtainable. Restating it inline
  would have created a duplicate of the canonical list within `CLAUDE.md` itself, which is the
  RL-04 defect class this remediation spent Phase 5 removing. Terminal output (`install.sh`) and
  paste prompts got literal lists instead, because neither can carry a resolvable pointer.
- DD-017 (2026-08-15): Executed parent-added Step 11.8. Beyond the `/hve-implement` row DO-01
  named, four more `README.md` rows disagreed with `CLAUDE.md`: `/hve-research` and `/hve-plan`
  (missing `--mode`, the DO-02 defect in the second doc tree), `/hve-review` (missing `--mode`),
  `/hve-pr-review` ("Supports `--dimension` to focus on one area", which is now false — a
  filtered run also dispatches the security reviewer), and `/hve-doc-ops` (`--scope` described
  vaguely, with an invalid example at `:178`). All reconciled to the `CLAUDE.md` wording. The
  two tables are now equivalent in flag coverage; they remain differently worded by design,
  since `README.md` describes what each command does for a new reader and `CLAUDE.md` states
  when to reach for it.
- DD-018 (2026-08-15): Executed parent-added Step 11.9 with a narrower result than the step
  anticipated. Neither `docs/reference.md` nor `docs/internals.md` enumerates `CLAUDE.md`'s
  sections, so there is no section list to sync and none was invented. `docs/internals.md:7-11`
  carries an illustrative, non-exhaustive list of conventions that live in `CLAUDE.md`; the two
  new ones were added there because both genuinely govern subagents. Two adjacent staleness
  defects surfaced while checking and were fixed: `:50` claimed the quality validator "always
  runs these 11 checks", which Phase 3 falsified by making scope additive
  (`hve-implementation-validator.md:22`), and `:62` restated a security checklist that had
  drifted to three of five patterns.

---

## Session Decisions

- DD-001 (2026-08-15): Phases 1, 2, and 4 dispatched in parallel per the plan's dependency
  graph (their file sets are disjoint, verified in the plan's Disjointness evidence). The
  authoritative phase-boundary gate is run by the parent session after the whole wave
  returns, not by each concurrent subagent, so a mid-edit read by a sibling cannot produce a
  misleading red at a gate.

## Final Test Pass

Parent-run, 2026-08-15, after all eleven phases:

```
./tests/run-drift-tests.sh    -> Results: 248 passed, 0 failed
./tests/run-install-tests.sh  -> Results: 66 passed, 0 failed
```

Full delta arithmetic from the session baseline, every step accounted:

| Suite | Baseline | Final | Delta | Owning phases |
|---|---|---|---|---|
| install | 48 | 66 | +18 | Phase 1 `test6_gitignore_credentials` |
| drift | 211 | 248 | +37 | Phase 5 +7 (test 6 retired, specs inverted, tests 14/15 added); Phase 6 +1 (new test 14 section); Phase 9 +10 (test 15 assertion 2, test 14 normalizations); Phase 10 +19 (test 7 widened to all 9 agents, test 14 gains a section) |

No phase produced an unexplained delta, and no test was ever red at a phase boundary. Three of
the new assertions were proved non-vacuous by negative control (Phase 5 broke a pointer and
re-added a duplicate; Phase 9 stripped a record-skip branch; Phase 10 deleted a status line and a
clarifying-questions section), each confirming the suite goes red and then restoring.

## Security Hygiene Check

Run by the parent session, 2026-08-15, per CLAUDE.md's `Security Hygiene` section.

| Check | Result |
|---|---|
| Secret patterns in changed files | Clean. One match, `CLAUDE.md:294`, is the documented grep pattern list itself, not a secret. |
| Credential-like files in `git diff HEAD --name-only` | None. |
| `.gitignore` hygiene (`.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`) | All five present as whole lines. |
| New dependencies | None. No new command, package, or registry introduced. |

Note: this remediation *strengthened* the same surface it is checked against. Phase 1 made
`install.sh` write these five patterns into every project it installs into, and Phase 11 verified
by execution that `CLAUDE.md`'s stated list, `install.sh`'s written list, and drift test 4's
hardcoded list all name the same five patterns in the same order.

## Post-Review Remediation (2026-08-15, after `/hve-review` returned ✅ Complete)

Review verdict was 0 Critical / 0 Major / 9 Minor, so none of this was blocking. Three items were
closed on the user's explicit decision after the review checkpoint.

### 1. `*.pfx` added to the credential set (closes IV-002 / DD-008)

**Decision reversed deliberately.** DD-008 accepted the narrowing and Phase 11 verified the three
lists agreed on five. The user chose to widen to six instead. The DD-008 reasoning (that adding a
sixth pattern in Phase 5 would desynchronize `CLAUDE.md` from `install.sh` and test 4) was correct
*at that time*; it is satisfied here by changing every surface in one pass rather than one of them.

Note the repo's own `.gitignore:26` already listed `*.pfx`, so this brings the shipped guidance in
line with what this repo already practised.

All 11 sites, verified 1:1 against `*.p12` on every surface:

- `.gitignore` — already present, unchanged
- `CLAUDE.md:295` — Security Hygiene gitignore-hygiene bullet
- `install.sh:251` — `add_ignore '*.pfx'`; `install.sh:273` — global-mode `Done. Next:` output
- `README.md:44` — paste-install prompt; `README.md:238` — credential note
- `docs/installation.md:26,93,157,194` — paste-install prompt, Option B block, global paste prompt, global "what differs" block
- `tests/run-drift-tests.sh:291` — test 4 pattern loop
- `tests/run-install-tests.sh:515` — `credential_rules` array (plus two "all five" comments corrected to "all six")

### 2. `carriers` identifier collision renamed (closes IV-001)

`tests/run-drift-tests.sh` used `carriers` as an array in `assert_canonical_block` and
`test5_subagent_model_boilerplate`, and as a scalar counter in `test15_behavioral_presence`,
producing shellcheck SC2178/SC2128. The test-15 scalar is now `discovery_carriers`, mirroring the
sibling `skip_carriers` already used by assertion 2 in the same function. No behavior change.

### 3. `README.md` documents the two cross-cutting flags (closes the surviving half of Phase 11 RV-001)

New `### Flags every dispatching command accepts` subsection between the utility-command and
prompt-engineering tables, covering `--subagent-model` and `--friction-log`. Deliberately **not**
added to eight individual table rows: that would re-create the duplication the RL cluster removed.
The review rejected the CLAUDE.md half of RV-001 for exactly this reason.

### Test delta

| Suite | Before | After | Delta | Cause |
|---|---|---|---|---|
| drift | 248 | 249 | +1 | test 4 now loops six patterns instead of five |
| install | 66 | 69 | +3 | test 6's `credential_rules` gains one pattern across its three cases |

Both suites green: `drift 249 passed, 0 failed`; `install 69 passed, 0 failed`. `bash -n install.sh`
exits 0.

### Installer re-verified by execution, not by diff reading

Fresh target: `.gitignore` carries all six patterns in order. Re-run: each pattern `x1`, header `x1`,
no duplicates. Seeded target pre-populated with `node_modules/`, `.env`, and `*.pfx`: the installer
appended only the four missing patterns and left all three pre-existing lines untouched and
unduplicated. Global mode (`HOME` redirected into the scratch tree) emits all six in its
`Done. Next:` guidance.

### Plan-file bookkeeping

`Status: Draft` → `Complete`; all 60 step checkboxes checked. The Phase 4 success criterion was
amended from "all 9 agents declare `tools:`" to name the two agents SC-02/SC-03 actually scoped,
with an inline note recording that the original wording overreached and that 8 of 9 is the intended
end state (DR-401/DD-401). This closes the review follow-on that both the implementor and the
Phase 4 validator raised independently.

## Open Items Carried to Review

Not defects in this implementation; recorded so review can rule on them rather than rediscover them.

- **DD-008 leftover, `*.pfx`**: deliberately NOT added. The plan and the verified Phase 1 patch
  both specify exactly five patterns; widening the installer's write set is a feature decision,
  not remediation. All three lists agree on the current five.
- **DR-401, `hve-phase-implementor.md` has no `tools:` key**: Phase 4's success criterion said
  "all 9 agents declare `tools:`"; the result is 8 of 9. Left deliberately (DD-401) — that agent
  runs test suites so it genuinely needs Bash, its all-tools grant is documented, and no review
  finding asked for it. The criterion wording, not the code, is what was imprecise.
- **`docs/` is outside `canonical_block_corpus`**: nothing stops `docs/internals.md` from
  re-drifting into a restatement of canonical text. Phase 11 fixed one such drift by hand.
- **No drift test compares `README.md`'s Command Reference to `CLAUDE.md`'s**: Phase 11
  reconciled five divergent rows, but future divergence stays invisible.
- **Test 14 scans `.claude/**` only**, so `CLAUDE.md`'s two internal self-references are
  unenforced (headings verified by grep at the time of writing).
- **Three parent-added steps** (8.7, 9.5, 11.7/11.8/11.9) were not in the approved plan. Each is
  recorded as parent-added in its phase section with a DD- entry. They are same-file, same-defect-
  class extensions surfaced by the phase before them, not scope creep — but review should confirm
  that judgment rather than assume it.
