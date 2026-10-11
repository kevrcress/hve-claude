# Research: Workflow Optimization from the 2026-09-14 Usage Report
Date: 2026-09-14
Task slug: usage-report-workflow-optimization
Confidence: HIGH overall (every repo-state claim re-cited at HEAD 01c0e85 by three hve-researcher subagents; usage-report claims remain the report's own model-estimated analysis, marked MEDIUM; design recommendations marked MEDIUM)
Supersedes: the parent-written seed of the same path and date (its Method line declared it the INPUT to this pass). Seed claims are kept under their original numbering and marked confirmed, corrected, or extended; corrections are listed in a dedicated section rather than silently rewritten.
Method: `/hve-research --mode standard --friction-log`. Three researcher subagents (carrier-map, stalled-plans, installer-hooks); their artifacts are under `.claude-hve-tracking/research/subagents/2026-09-14/`. The parent ran one read-only shell listing for orientation because this session exposed neither Glob nor Grep (recorded in the friction log). The installer-hooks researcher fetched two official Claude Code hooks pages.

## Summary

The seed's diagnosis holds: HVE's own implement path instructs the piped test gate (`| head -100`) that the usage report names as its costliest failure class, nothing in review re-reads or re-runs a gate, and the nine generic verification rules stranded in the krava seat brief have no HVE carrier at all. Three seed citations were wrong and are corrected below; the seed's install-test breakage claim is overstated (no existing assertion fails, coverage is additive); and one shipped example is probably defective (the hooks snippet in CLAUDE.md reads an undocumented environment variable). The three-bundle split survives with two adjustments: phase-close-clarity (already validated) must land before Bundle B and before Bundle A's reviewer text, and Bundle C should absorb the hooks-relocation steps of the draft lean-restructure plan. Four of the six open questions are resolved with evidence; the lean-plan path choice and the shared-research discovery fix carry forward.

## Report-Level Signals

Unchanged from the seed (source: `~/.claude/usage-data/`; not re-derived this pass).

| Signal | Value | Source |
|---|---|---|
| Sessions in window | 200 (per-project breakdown withheld from this public repo, redacted 2026-10-10) | session-meta project_path |
| Sessions whose first prompt is an `/hve-*` command | 10 (5 research, 3 plan, 1 pr-review, 1 challenge) | session-meta first_prompt |
| Sessions whose first prompt is `/orchestrator` or `/krava-orchestrator` | 6 | session-meta first_prompt |
| Facet sessions whose goal is "act as a peer / grader / reserve seat" | ~40 of 50 | facets underlying_goal |
| Bash calls vs Edit calls | 14,285 vs 1,776 | session-meta tool_counts |
| Hooks configured (global settings, hve-claude, krava-core) | none | settings files |
| Friction categories (facets) | wrong_approach 6, buggy_code 5, blocked_on_dependency 3, incorrect_verification 1, coordination_race 1, resource_contention 1 | facets friction_counts |

Report headline friction (MEDIUM, model-estimated): false-green verification from `pnpm typecheck | tail` and from a background-task notification mistaken for a passing run; coordination overhead from idle reserve seats and stale register SHAs; brittle `pgrep` wait loops; a brief with a wrong premise about main; a merge commit that shipped conflict markers.

## Corrections to the Seed

- Seed Theme 1 cited hve.md:31-33 for the Simple direct path. Those lines are difficulty-table rows. The Simple direct path is .claude/commands/hve.md:44 and the full-suite baseline rule is :46. [HIGH]
- Seed Theme 6 cited hve-plan.md:37 for the template's success criteria. That line is a Phase 1 bullet. The template line is .claude/commands/hve-plan.md:72. [HIGH]
- Seed Theme 7 said adding a scripts directory requires "count assertions" in tests/run-install-tests.sh. No existing assertion fails when an extra directory is added; exact counts exist only for instructions (14) and prompts (6). The need is additive coverage, not breakage. [HIGH]
- Seed Theme 8 said Test 5 requires "any new command" to carry the byte-identical `--subagent-model` paragraph. Test 5 discovers carriers by the literal prefix ``If `--subagent-model`` (tests/run-drift-tests.sh:322), so a new command only enters Test 5 if it copies the paragraph; hve-plan.md:15 uses a different phrasing and is not a carrier today. [HIGH]
- Seed Theme 8 said the three validated plans were "not read in full". All four plans, their logs, details, and the one plan-validation review were read in full this pass (see Theme 9). [HIGH]
- The 2026-07-20 research cited hve-research.md:73 for the no-Bash rule; at HEAD it is :75. It also said hve-prompt-tester and hve-prompt-updater declare no `tools:`; both do at HEAD (:6 each). [HIGH]

All other seed citations (hve-implement.md:133, :134-138, :31, :164, :46-78; hve-phase-implementor.md:104, :106-110; hve.md:76, :93, :112; hve-review.md:27-32; hve-rpi-validator.md:6; hve-implementation-validator.md:148; hve-plan.md:83, :99; hve-research.md:75; CLAUDE.md:319-337; install.sh:61-65, :77-87) were verified exact at HEAD.

## Key Findings

### Theme 1: HVE's own gate instruction is the report's top failure mode (confirmed)

- .claude/commands/hve-implement.md:133 instructs `[test command] 2>&1 | head -100`; .claude/agents/hve-phase-implementor.md:104 repeats the 100-line cap without a method. The pipe replaces the runner's exit code with head's. [HIGH]
- The test line is two numbers only (`Tests: X passed, Y failed`, hve-implement.md:135; hve-phase-implementor.md:107). No rc, command, log path, or SHA. [HIGH]
- The Simple direct path in hve.md:44-46 restates the test-line rule and the full-suite re-run rule but inherits the capture method by reference. [HIGH]
- The suite already runs twice per phase under subagent dispatch: hve-implement.md:118 and :130 have the parent run tests after each phase, and hve-phase-implementor.md:104 has the implementor run them too. Gate ownership is undefined, which matters for where evidence is written. [HIGH]
- hve-git-merge.md:55 justifies its own `| head -100` by reference to "the same cap this repo uses for test output". If the cap goes, that sentence goes stale. [MEDIUM]
- The only pipeline-exit text in the corpus is `set -euo pipefail` in .claude/instructions/bash.md:10-13, which governs scripts, not tool invocations. No mention of PIPESTATUS, tee, conflict markers as a commit rule, or a third "skipped" count exists anywhere in .claude/. [HIGH]

### Theme 2: Review trusts the implementor's test claim (confirmed)

- hve-review.md:83 and :95 are the parent's only Bash steps: `git diff --name-only <base>`. A grep for `Tests:`, `test log`, `re-run`, `runner output` across hve-review.md, hve-rpi-validator.md, and hve-implementation-validator.md returns zero hits. [HIGH]
- hve-rpi-validator.md:6 has no Bash; hve-implementation-validator.md:148 constrains Bash to `git diff`, `git log`, `git show`. Neither validator is told to read any instructions file today. [HIGH]
- Giving hve-rpi-validator Bash would not fire drift Test 2, which compares only the Model cell (tests/run-drift-tests.sh:215-220); the Tools cell at docs/internals.md:24 would drift with no mechanical guard. [HIGH]

### Theme 3: HVE is called by orchestrator briefs and stalls on that caller (confirmed)

- hve-implement.md:31 hard-stops without a plan, but already carries a user-authorized `Plan: none` branch with a DD- entry. That branch is the direct precedent for `Plan: brief at <path>`. [HIGH]
- CLAUDE.md:253 names the plan file an unreconstructible input for implement and the changes log for review. hve-review.md:27-32 hard-stops without a plan, so a brief-as-plan run cannot be reviewed unless review gains a matching input. [HIGH]
- Every user wait is enumerated: hve.md:42, :75-76, :92-93, :111-112; hve-implement.md:31, :117, :142, :164; hve-plan.md:153-157. hve-review.md has none (:161 emits or reports). hve-pr-review.md:32 and :44 are the only other interactive prompts in a Bash-holding command. [HIGH]
- No command reads an environment variable or detects non-interactive mode. A grep for `CLAUDE_`, `headless`, `non-interactive`, `--yes`, `-y`, `claude -p` across .claude/, docs/, CLAUDE.md, README.md, and CONTRIBUTING.md hits only CLAUDE.md:330 (the hook variable). Hook stdin carries `permission_mode`, so a hook can observe mode but a command prompt cannot. [HIGH]
- The single-parse paragraph at hve-implement.md:19 (also hve-review.md:19, hve-plan.md:13) is the flag-parsing pattern; a boolean `YES` slots in beside `FRICTION_LOG`. hve.md has no Argument Parsing section; :17-19 strip `--mode` and `--think` ad hoc. [HIGH]

### Theme 4: Generic verification rules are stranded (confirmed)

- None of the nine COMMON.md rules named by the seed (read the failure reason; paired must-miss and must-hit grep; three-number report; wrapper rc vs command rc; count is not a classification; typecheck figure with its last three lines; no background job outliving its worktree; self-identifying gate log; never report a gate from a notification) has an HVE carrier. [HIGH]
- Adjacent rules that exist and should be cross-referenced rather than restated: "Never write a count that did not come from output you observed" (hve-implement.md:138, hve-phase-implementor.md:110); "The check must be one that could have failed" (hve-plan.md:96); "A grep/citation proves existence, never exhaustiveness" (hve-plan.md:100); "Unearned verification claims" (hve-plan-validator.md:43); "Re-run the full suite after implementing" (hve.md:46). These cover the count-vs-classification and paired-grep ideas partially, at plan time only. [HIGH]
- The `Started:`/`Completed:` `date -u` lines (hve-implement.md:57-58, hve-phase-implementor.md:79-80) are the precedent for a self-identifying header. [HIGH]

### Theme 5: Premise verification is absent from implement (confirmed)

- hve-plan.md:76 emits `Assumption: ... [MEDIUM]` lines and :98 tells the planner to push guard steps into implementation; hve-plan-validator.md:41 and :44 check markers. hve-implement.md:37-44 Phase 1 has no step that consumes a marker. [HIGH]

### Theme 6: Acceptance-register practice has no home in HVE (confirmed, citation corrected)

- Plan template success criteria at hve-plan.md:72; Risk Log :83-86; Testing Approach :88-89. No falsification requirement. hve-plan-validator.md:48-54 Step 3 checks "explicit success criteria" and is where a falsification check would join. hve-rpi-validator.md:37-42 compares plan steps to changes and would take a register as a third input. [HIGH]

### Theme 7: Scripts and hooks (confirmed and extended)

- install.sh copy scope at HEAD: precondition :61-65 (commands, instructions, prompts; agents not checked), mkdir :77, copies :79 (commands `hve*.md`), :82 (agents `hve*.md`), :85 (instructions), :86 (prompts). Sync arrays `HVE_INSTRUCTION_FILES` :92-96 and `HVE_PROMPT_FILES` :135-137, mirrored by tests/lib/instruction-files.sh:5-20 and tests/lib/prompt-files.sh:5-12. No scripts or hooks directory exists or ships. [HIGH]
- Neither suite sees a new directory: run-drift-tests.sh:55-58 declares four dirs and `main()` at :1227-1228 requires only those plus internals, CLAUDE.md, .gitignore; run-install-tests.sh has exact counts only at :157-159, :258-260, :359-361, :386-388 (instructions, 14) and :267-269 (prompts, 6). A scripts copy needs new assertions in test1 (:125-193) and test5 global (:367-438) plus an executable-bit check (nothing asserts mode). [HIGH]
- A new shipped directory must also be added to the paste-to-install enumerations: docs/installation.md:16-17, :42-63, :145-147, :225-226; tests/run-prompt-new-install.sh:83 and :116-129; tests/run-prompt-upgrade.sh:101-102 and :137-150; and the CLAUDE.md prose at :350-352. [HIGH]
- Hooks carrier is feasible without a settings merge: CLAUDE.md:319-337 already ships a settings snippet via the CLAUDE.md block merge (install.sh:171). Only the script files need a copy step. `--global` lands files in `~/.claude/` (install.sh:46-48), so a snippet using `"$CLAUDE_PROJECT_DIR"/.claude/hooks/x.sh` does not resolve for global installs; the doc needs a per-mode path. [HIGH]
- Official hooks contract (fetched from code.claude.com/docs/en/hooks and /hooks-guide): PreToolUse for Bash receives stdin JSON with the command at `tool_input.command`; block via `exit 2` with stderr reason, or `exit 0` with `hookSpecificOutput.permissionDecision: deny`. PostToolUse for Edit|Write receives `tool_input.file_path`; its block form is top-level `decision: block`. Command hooks are `sh -c` strings with the documented convention `"$CLAUDE_PROJECT_DIR"/.claude/hooks/<script>.sh`; an optional `"if": "Bash(pnpm *)"` narrows by subcommand. Settings scopes: user, project `.claude/settings.json`, local `.claude/settings.local.json`. [HIGH]
- Defect candidate: CLAUDE.md:330 reads `$CLAUDE_TOOL_INPUT_FILE_PATH`, absent from the current hooks docs, whose documented delivery is stdin JSON (`jq -r '.tool_input.file_path'`). The shipped auto-log example is probably non-functional as written. [MEDIUM; absence from docs is not proof]
- Tool boundary: Bash in hve, hve-plan, hve-implement, hve-review, hve-pr-review, hve-doc-ops, hve-git-commit, hve-git-merge, hve-git-setup (all :4); hve-phase-implementor.md has no `tools:` key and inherits Bash. A gate script can be mandatory only for those. hve-implementation-validator could run a `verify` subcommand only if :148 widens from git-only to read-only commands. [HIGH]
- The PreToolUse regex proposed by the seed, `(test|typecheck|lint|build).*\| *(tail|head|grep)`, must not also reject the gate script's own `tee` pipe; prototype before shipping. [MEDIUM]

### Theme 8: Drift suite constraints (confirmed and made precise)

- 16 numbered groups, Test 6 retired (:361-375), 15 executing. Per-change map:

| Change | Drift groups that must change or would fire | Install suite |
|---|---|---|
| 1 tee/PIPESTATUS | Test 10 rows :579-582 (prefixes and both carriers hve-implement.md:135-138, hve-phase-implementor.md:107-110) | none |
| 2 gate evidence | Test 10 (new row if a line is duplicated), Test 14 (if CLAUDE.md-canonical with pointer) | none if committed |
| 3 hve-gate.sh | none (invisible) | new test1/test5 assertions; install.sh:77-87 |
| 4 verification.md | Test 8 (CLAUDE.md:267-282 row), Test 11 (install.sh:92-96 and tests/lib/instruction-files.sh:5-20) | five `14` counts at run-install-tests.sh:94, :158, :259, :360, :387; CONTRIBUTING.md:47-48 delta note |
| 5 --plan | Test 15 pointer at hve-implement.md:25 must survive; nothing new | none |
| 6 premise check | Test 10 only if the line is duplicated | none |
| 7 --yes | Test 10 (new row), Test 14 (if CLAUDE.md-canonical); Test 13 only if .claude/prompts/rpi.md documents it | none |
| 8 register | none mechanical; hve-plan-validator.md:48-54 prose | none |
| 9 hooks | none (invisible) | install.sh:77-87 if shipped |

- Test 10 spec format is `label|count|mode|prefix` (:553-557); `extract_line` takes the first matching line per file (:310-314); hve.md:44 quotes the test line inline without the leading `- ` so it does not count today, and a rewrite that starts a line with ``- `Tests:`` would raise the count to 3 and fail. [HIGH]
- Test 13 is one-directional (prompt to command, :835-837); hve-implement, hve-review, and hve-plan have no prompt twin (:841-848). [HIGH]
- Tests 9 and 12 match backticked `hve-[a-z-]+` tokens only; a backticked `hve-gate.sh` in a command is safe (`.` excluded). [HIGH]
- Test 15 assertion 1 requires the exact discovery-pointer string in five commands (:1046-1049); hve-implement.md carries it at :25 and :31, so rewriting :31 for `--plan` is safe while :25 stays. [HIGH]
- A committed `gates/` folder needs no installer or gitignore change (.gitignore:3-4, install.sh:239-240 ignore only `**/subagents/` and `sandbox/`); an ignored one costs one `add_ignore` line at :240, a test1 assertion, and the global printout at :264-266. [HIGH]

### Theme 9: The four stalled 2026-08-19 plans (new; seed did not read them)

None of the four has an implemented phase at HEAD and none has a changes log; the only completed item is project-communication-presence Phase 0 (PR #3 merged 2026-08-22, commit 0574349). [HIGH]

| Plan | Status | Bundle A | Bundle B | Bundle C |
|---|---|---|---|---|
| rpi-output-quality-regression | v2 Validated; semantically stale on one line | INDEPENDENT (Test 17 name collision only) | OVERLAPS-minor: same Command Reference table, distinct rows | INDEPENDENT: new command ships via install.sh:79 glob |
| phase-close-clarity | Validated; citations still exact | INDEPENDENT on lines; FOLDS-IN hook for gate evidence (extra key on the close block, DR-002) | OVERLAPS: hve-implement.md:164 vs :168, hve-plan.md:153-157 vs :161, hve.md:75-112 vs :133-155, hve-review.md:161 | INDEPENDENT |
| project-communication-presence | Validated; Phase 0 done | INDEPENDENT | INDEPENDENT (asciinema recording last, DD-004) | INDEPENDENT (paste-to-install sync Step 6.3 re-runs) |
| claude-md-lean-restructure | Draft | OVERLAPS: Tracking Folder Structure CLAUDE.md:74-105 and :368-380; Phase 7.3 line bound | OVERLAPS with contradiction: rows :42-46 (lean strips all flags, locked decision 2); Phase 6 vs items 5 and 8 at hve-implement.md:25-31, hve-review.md:25-32 | OVERLAPS: hooks :319-337, installer list :350-351; FOLDS-IN candidate: lean Steps 1.1, 1.2, 2.1 |

- rpi-output-quality-regression Steps 3.1-3.2 quote the canonical `--subagent-model` line as `<sonnet|opus|haiku>`; HEAD is `<sonnet|opus|haiku|fable>` (hve-review.md:11, commit 01c0e85). Pasting the plan's text verbatim fails Test 5. Step 6.1's "drift test 13" rationale is wrong (Test 13 maps prompts to commands, :901-941). One-line amendment, not a re-plan. [HIGH]
- phase-close-clarity's status enum is `done | awaiting-approval | blocked | needs-rework` (details:60), with `awaiting-approval` defined as the value at exactly the pauses `--yes` would skip (details:107-108). Its Step 1.6 optional-extra-keys rule (plan:80-83, DR-002 log:14-21) can carry a `gate:` or `tests:` line without a format change, and its completion summary already mandates "one line of test evidence with before/after numbers obtained by execution" (plan:42-43). Bundle A's evidence line and that mandated line describe the same fact and should be worded once. [HIGH]
- phase-close DD-006 (log:82-109) records Kevin's ruling that lean preserves the new `## Completion Summary` section and notes that three plans queue CLAUDE.md edits. DD-004 (log:67-72) forbids `|` alternatives inside templates, which constrains any status line B adds. [HIGH]
- project-communication-presence log DD-007 (log:108-114) is a direct precedent for Open Question 6: two plans with distinct slugs derived from one research doc, with `/hve-implement` listing both candidates and asking. [HIGH]
- lean DD-003 ("global install ahead of repo") no longer reproduces; neither copy of hve-plan.md contains "Step 3a" at HEAD. lean DD-004 (log:86-100) marks Phase 6 drop-able, and Phase 6 is exactly the region Bundle B items 5 and 8 edit. [HIGH]

## Proposed Changes (seed numbering preserved; all still MEDIUM until the plan phase validates)

1. Replace the piped test gate with tee-to-log plus `${PIPESTATUS[0]}`; record rc, command, and log path beside the counts. Edit both Test 10 carriers identically and update the :579-582 prefixes if the line text changes. Update hve-git-merge.md:55's justification.
2. Define a gate-evidence record. Evidence favors an inline `#### Gate Evidence` subsection under each `### Phase N:` in the changes log (fits the CLAUDE.md:315 ownership rule), carrying gate name, command, git SHA, start and end, rc, and log path; a raw log under `.claude-hve-tracking/gates/YYYY-MM-DD/<slug>-phase-N-<gate>.log` is committed with no installer change. The parent reviewer reads the evidence before accepting any test claim; hve-rpi-validator.md:44-51 cites it.
3. Ship `.claude/scripts/hve-gate.sh` (`run <name> <cmd>`, `verify`, `--lock <class>`): install.sh mkdir at :77 and cp after :86; new test1 and test5 assertions plus an executable-bit check; five paste-to-install enumerations; CLAUDE.md:350-352 prose.
4. Add `.claude/instructions/verification.md` carrying the nine COMMON.md rules, cross-referencing (not restating) hve-implement.md:138 and hve-plan.md:96-100; add the CLAUDE.md:267-282 row, both `HVE_INSTRUCTION_FILES` arrays, and the five `14` counts; have hve-implement.md:42, hve-phase-implementor.md:19/:31/:132, and both validators read it.
5. Let hve-implement accept `--plan <path>`: extend the :19 single-parse paragraph, rewrite :31 keeping :25's pointer, record `Plan: brief at <path>` at :50 plus a DD- entry; add a `brief` clause to CLAUDE.md:253; give hve-review a matching input or item 5 is unreviewable.
6. Add a premise-check step to hve-implement Phase 1 between steps 1 and 2 (:37-44): one falsifying command per `[MEDIUM]`/`[LOW]` assumption the phase depends on, logged in the changes log.
7. Add `--yes` to hve.md and hve-implement.md (and hve-plan.md:153-157 if extended): `YES` in the single-parse paragraph, hve.md gains an Argument Parsing section, each skipped checkpoint logged in the changes log near the :99 mode line. Specify semantics against phase-close's enum: emit `status: done`, never `awaiting-approval`. Do not add flags to Command Reference rows (lean locked decision 2).
8. Add `## Acceptance Register` to the plan template (hve-plan.md:56-90) with a falsification requirement checked at hve-plan-validator.md:48-54; let hve-review accept `--register <path> --head <sha>` (changes base selection at :83 and :95) and feed the register to hve-rpi-validator.md:37-42.
9. Ship hook scripts under `.claude/hooks/` plus a documented settings snippet living in docs/reference.md (after lean Steps 1.1/1.2/2.1 move the hooks text there): PreToolUse blocker with `"if"` narrowing and a regex that spares `tee`; PostToolUse conflict-marker grep reading `tool_input.file_path` from stdin. Fix or verify CLAUDE.md:330 first. Provide a `--global` path variant.

Outside hve-claude (unchanged from seed): orchestrator skill should spawn seats at assignment time rather than pre-warm; COMMON.md shrinks to lane ports, package names, and CI state once items 1-4 land; every seat report pins the register SHA until item 2 carries it.

## Bundle Split Assessment

The evidence supports the three-bundle split with two ordering constraints and one boundary move:

- **Bundle 0 (prerequisite, no new plan needed): land phase-close-clarity first.** It is validated, its citations are exact at HEAD, it touches the same end-of-command lines Bundle B rewrites, and its extra-keys rule is the natural carrier for Bundle A's gate-evidence reference. Its DD-008 citation nit closes in the plan body already. [HIGH]
- **Bundle A (gate evidence: items 1, 2, 4, 6)** stands. It edits hve-implement.md:37-44, :46-78, :84, :133-138; hve-phase-implementor.md:19-33, :76-110; hve-review.md:38-44, :89-95; both validators; CLAUDE.md Instructions Reference and tracking tree; drift Test 10 rows and Tests 8/11; five install-test counts. Item 1 should be written inline (tee + PIPESTATUS) so A works without the installer; item 3 later replaces the inline command with the script call. [HIGH]
- **Bundle B (seat caller: items 5, 7, 8)** stands, sequenced after Bundle 0. Its CLAUDE.md footprint shrinks to the :253 brief clause and possibly one canonical `--yes` paragraph; flags are documented in command files only. Lean Phase 6 folds in here (DD-004 says it is drop-able and it edits the same lines). [HIGH]
- **Bundle C (installer: items 3, 9)** stands and absorbs lean Steps 1.1, 1.2, 2.1 (relocate the hooks section to docs/reference.md, about 25 lines), so the settings snippets are written once in their final home. C also owns the CLAUDE.md:330 defect check, the five paste-to-install enumerations, and the `--global` path variant. [HIGH]
- The rpi-output-quality-regression plan is independent and can run in any slot after its one-line fable amendment. project-communication-presence runs last (its own DD-004). [HIGH]
- Discovery caveat confirmed (Open Question 6): each bundle plan must be created with an explicit TASK_SLUG and a `Research:` header naming this file; see the carried-forward question for the review-side gap. [HIGH]

## Codebase References

.claude/commands/hve.md — Simple direct path :44-46; ad-hoc flag strips :17-19; checkpoints :75-76, :92-93, :111-112; close block :133-155
.claude/commands/hve-implement.md — single-parse :19; inputs :25-31; Phase 1 :37-44; changes-log template :46-78; baseline :84; parent test runs :118, :130; piped gate :133; test line :134-138; failure branch :139; DR stop :117; surface :142; final pass :153; acknowledgment wait :164; close :168-181
.claude/commands/hve-review.md — single-parse :19; required inputs :27-32; Phase 1 :38-44; parent Bash :83, :95; validator inputs :89-95, :119; verdict :161
.claude/commands/hve-plan.md — single-parse :13; discovery :25-27, :35; template :56-90 (success criteria :72, assumption :76, Risk Log :83-86, Testing :88-89); evidence rules :92-100; validator list :137; approval wait :153-157
.claude/commands/hve-research.md — no-Bash boundary :75
.claude/commands/hve-git-merge.md — head cap cross-reference :55
.claude/agents/hve-phase-implementor.md — no tools key :1-6; instructions reads :19, :31, :132; Step 4 template :76-110; cap :104; test line :106-110
.claude/agents/hve-rpi-validator.md — tools :6; inputs :17-23; Step 1 :37-42; Step 2 :44-51; `[CRITICAL]` template defect :83 (from memory; not re-verified)
.claude/agents/hve-implementation-validator.md — tools :6; dimension 8 :63-66; read-only Bash :148
.claude/agents/hve-plan-validator.md — markers :41, :44; completeness :48-54
.claude/instructions/bash.md — pipefail :10-13; script conventions :7, :10, :29, :32, :36, :47
.claude/prompts/rpi.md — Arguments :5-10; see-also :29-32
CLAUDE.md — Command Reference :42-46; Model Selection :68; tracking tree :74-105; DD definition :85; Friction Capture :109; Confidence Markers :146-154; Template Blanks :210; Handoff box :218-226; Discovery :241-253; Instructions Reference :263-286; Concurrent writes :313-315; hooks :319-337; installing :341-366 (copy list :350-352); tracking policy :368-380; `## Your Project` :388
install.sh — BASH_SOURCE :29; --global :31-53; precondition :61-65; mkdir :77; copies :79-86; instruction array :92-96; prompt array :135-137; CLAUDE.md block :171; markers :180-214; gitignore writer :229-251; global printout :262-274
tests/run-drift-tests.sh — dirs :55-58; extract_line :310-314; Test 5 :322-358; Test 6 retired :361-375; Test 8 :460-503; Test 10 :553-626 (rows :577-584); Test 11 :683-720; Test 13 :835-941; Test 14 :961-1020; Test 15 :1046-1109; Test 16 :1154-1216; main :1227-1262
tests/run-install-tests.sh — test1 :125-193; counts :157-159, :258-260, :267-269, :359-361, :386-388; test5 :367-438; Test 6 gitignore :514-561
tests/lib/instruction-files.sh, tests/lib/prompt-files.sh — sync arrays
tests/run-prompt-new-install.sh :83, :116-129; tests/run-prompt-upgrade.sh :101-102, :137-150
docs/installation.md :16-17, :42-63, :145-147, :225-226; docs/reference.md :6-33, after :71; docs/internals.md :19-29
.gitignore :3-5
CONTRIBUTING.md :24, :47-48, :141-142
.claude/settings.local.json :2-54 (permissions only)
.claude-hve-tracking/research/2026-07-20/external-workflow-improvements.md — prior installer/tool-boundary research (two stale citations corrected above)
.claude-hve-tracking/plans/2026-08-19/*.md and plans/logs/2026-08-19/*.md — four stalled plans and logs
.claude-hve-tracking/details/2026-08-19/*.md — phase-close enum :60, :107-108
.claude-hve-tracking/research/subagents/2026-09-14/usage-report-workflow-optimization-{carrier-map,stalled-plans,installer-hooks}.md — this pass's evidence base

## External References

https://code.claude.com/docs/en/hooks (redirect target of docs.claude.com/en/docs/claude-code/hooks; fetched 2026-09-14)
https://code.claude.com/docs/en/hooks-guide (fetched 2026-09-14)
~/.claude/usage-data/report-2026-09-14-091520.html and session-meta/facets JSON — the trigger report (seed pass only)
~/.claude/skills/orchestrator/SKILL.md; ~/Documents/krava-orchestrator-playbook.md; ~/Documents/krava-orchestrator-briefs-2026-09-09/COMMON.md — seat-caller context (seed pass only)

## Open Questions

Seed questions, with resolution status:

1. **Gate evidence location: RESOLVED with recommendation.** Inline `#### Gate Evidence` under each `### Phase N:` is required (ownership rule CLAUDE.md:315; a top-level section has no owner under parallel dispatch). A raw log file is optional; if produced it lives under `gates/` named per phase to avoid the `<slug>-<gate>` collision, and is committed with no installer change. The plan phase decides whether phase-close's extra key (`gate:`) or the inline subsection is the canonical reference the reviewer reads; both cannot be canonical.
2. **Reviewer re-runs or reads: RESOLVED.** The parent reviewer reads the evidence and checks the header's SHA against the changes log; it re-runs only when evidence is missing or the SHA mismatches. Rationale: the suite already runs twice per phase; review's Bash is git-only today; hve-rpi-validator has no Bash and its Tools cell is unguarded. Carried forward as a plan option: widen hve-implementation-validator.md:148 to read-only commands so it can run `hve-gate.sh verify`.
3. **Brief-as-plan and the unreconstructible rule: RESOLVED.** `--plan <path>` extends the existing user-authorized `Plan: none` + DD- branch at hve-implement.md:31; the rule is not weakened if CLAUDE.md:253 gains an explicit brief clause and hve-review gains a matching input. Without the review-side input the rule is weakened, because a brief run becomes unreviewable.
4. **Non-interactive mode: RESOLVED.** A flag. No env-var reading exists; auto-detection is not observable from a command (only hooks see `permission_mode`). Pattern: `YES` in the single-parse paragraph, new Argument Parsing section in hve.md, `status: done` with skipped checkpoints logged.
5. **Stalled plans: RESOLVED except one choice.** phase-close runs before B and before A's reviewer text; project-comms runs last with Phase 0 annotated done; rpi is independent after the fable amendment. Carried forward: Kevin chooses for claude-md-lean-restructure between Path 1 (validate and land Phases 1-5 before any bundle touches CLAUDE.md, drop Phase 6) and Path 2 (fold Steps 1.1/1.2/2.1 into C and Phase 6 into B, add a dated supersede-in-part note, re-plan the rest later). Either path re-derives the Phase 7.3 line bound.
6. **Shared research discovery: PARTIALLY RESOLVED.** DD-007 proves distinct plan slugs from one research doc work at plan and implement time: pass TASK_SLUG explicitly (hve-plan.md:27 prefers it) and write this file's path in the free-text `Research:` header (:61). Gap carried forward: hve-review.md:29 re-globs research by slug and :38 does not follow the plan's `Research:` line, so a bundle-slugged review loses the shared research (it is an optional input, so review still runs). Smallest fix is one sentence in hve-review.md:38; the plan phase decides which bundle carries it.

New questions for the plan phase:

7. Who owns the gate run under subagent dispatch: the parent (hve-implement.md:118, :130) or the implementor (hve-phase-implementor.md:104)? Today both run it; item 2 must name one writer of the evidence.
8. Is `$CLAUDE_TOOL_INPUT_FILE_PATH` (CLAUDE.md:330) a real hook variable? If not, the shipped auto-log example is broken and Bundle C should fix it before adding siblings.
9. Does the PreToolUse blocker regex `(test|typecheck|lint|build).*\| *(tail|head|grep)` spare the gate script's own `tee` pipe and the `2>&1 | tee` form item 1 introduces? Needs a prototype in a Bash-holding phase.
10. Git-history questions this read-only phase could not answer: whether the `HVE_PROMPT_FILES` sync-test gap (2026-07-20 item 10) is still open, and whether hve-rpi-validator.md:83 still hardcodes `[CRITICAL]` (memory says the fix was deferred 2026-08-15).

## Recommended Research Follow-On

- [ ] Prototype the tee + PIPESTATUS gate line and the PreToolUse regex in a Bash-holding session; confirm the regex spares `tee` (question 9)
- [ ] Verify `$CLAUDE_TOOL_INPUT_FILE_PATH` against a live hook run or the hooks reference page's environment-variable list (question 8)
- [ ] Draft `.claude/instructions/verification.md` from the nine COMMON.md rules with cross-references to hve-implement.md:138 and hve-plan.md:96-100 instead of restatement
- [ ] Amend rpi-output-quality-regression Steps 3.1-3.2 (fable) and Step 6.1 (Test 13 rationale) so its Validated status is accurate before it is scheduled
- [ ] Record the 1:N research-to-plan mapping as a process friction item (done in this pass's friction log) and decide whether `--research <path>` on hve-plan is worth adding alongside the hve-review.md:38 sentence
