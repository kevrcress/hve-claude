# Plan Validation: Platform-Drift and Friction Quick Fixes

Date: 2026-10-10
Validator: hve-plan-validator (subagent)
Plan: .claude-hve-tracking/plans/2026-10-10/platform-drift-quick-fixes-plan.md
Details: .claude-hve-tracking/details/2026-10-10/platform-drift-quick-fixes-details.md
Planning log: .claude-hve-tracking/plans/logs/2026-10-10/platform-drift-quick-fixes-log.md
Research: .claude-hve-tracking/research/2026-10-10/cross-repo-process-review.md (step 1 of the Recommended sequence and the Decisions recorded section only)
Supporting evidence: .claude-hve-tracking/research/subagents/2026-10-10/cross-repo-process-review-friction-logs.md
Method: static reading with Read, Grep, and Glob. No shell, so no suite was run and no git command was executed. Every statement about test behaviour below is derived from the test source and is marked as such. Working tree read at HEAD ba369fd on branch feature/validators-inherit-model.
Status: Fail (0 Critical, 5 Major, 18 Minor)

## Summary

Coverage of research step 1 is complete in outline: all thirteen named items map to at least one step, and all five DD-008 exclusions are defensible. Every cited line holds its quoted anchor. No existing assertion in either suite would fail after the planned edits.

The plan fails on five Major items, all of which are small text fixes to the plan or details file and none of which needs new research:

1. DD-010: four pairs of phases share a file and are free to run in parallel.
2. DD-011: a Phase 3 success criterion cannot pass from the details text, and the command's argument-hint is not updated.
3. DD-012: `--working-tree` is routed only through the empty-diff guard, and an empty working-tree review is not stopped.
4. DD-013: the security-floor step for the excluded folder misses untracked files, credential-like filenames, and tracking-only branches.
5. DR-003: the ignore-rule fix misses the three prose copies in the paste-to-install prompts.

## 1. Coverage of research step 1

| Research item | Plan steps | Result |
|---|---|---|
| Hook example (CLAUDE.md:330) | 5.1, 5.2 | Covered. Minor: DD-025 |
| hve-rpi-validator.md:83 | 2.5 | Covered |
| diff.patch ignore rule in install.sh plus install tests | 4.3, 4.4, 4.5, 4.6, 4.7 | Partial. Major: DR-003. Minor: DD-026 |
| Instruction path resolution under global install | 4.1, 4.2 | Covered. Minor: DD-024, DD-023 (f) |
| Research shell policy per D4 | 1.1, 1.2, 1.3, 1.7, 1.8 | Covered. Minor: DR-005, DD-027 |
| Background-dispatch wait sentence | 2.1, 2.2, 2.3, 2.4 | Covered by a canonical paragraph plus two pointers instead of one sentence per command. Deviation is recorded in DD-006 and is defensible because CLAUDE.md is loaded in every parent session |
| hve-review.md:38 sentence | 1.6 | Covered. hve-plan.md:61 confirms the plan template has a `Research:` header to read |
| F09 | 3.1, 3.5, 3.7 | Covered. Major: DD-012. Minor: DD-015, DD-020 |
| F11 | 3.3, 3.6 | Covered. Major: DD-013. Minor: DD-019 |
| F08 | 3.2, 3.4 | Covered. Major: DD-011, DD-012 |
| F14 | 1.4, 1.5 | Covered. Minor: DD-017 |
| F04 | 2.1, 2.4 | Covered. Minor: DD-016 |
| Declare `consults/` and `gh-sync/` | 5.3 | Covered as a reserved-names note instead of tree entries. Recorded in DD-007 and consistent with Decision D1 |

Decisions recorded:

| Decision | Plan handling | Result |
|---|---|---|
| D1 | Step 5.3 names the folders without naming the tools | Covered, except the stated consequence that the HiVE brief needs Corrections annotations: no step, no recorded exclusion. Minor: DR-004 |
| D2 | No step needed here (Bundle B is another plan) | Consistent. One interaction noted in DD-027: a Bash prompt in research has no fallback for a non-interactive caller |
| D3 | No step needed | Consistent |
| D4 | Phase 1 | Covered. The "one pass" bound is not carried into the text. Minor: DR-005 |
| D5 | DD-004 relies on lean-restructure locked decision 2 (confirmed at .claude-hve-tracking/plans/2026-08-19/claude-md-lean-restructure-plan.md:39) | Does not block. That plan is still Draft, so DD-004 rests on a [MEDIUM] footing |

Scope creep: none that lacks a basis. Step 3.6 follows from CLAUDE.md:299. The `--working-tree` flag is a reasonable carrier for F08, but it is a new public flag and no DD entry records the decision (DD-018).

## 2. DD-008 exclusions

| Excluded item | Named in research step 1? | Defensible? | Note |
|---|---|---|---|
| F05, date folder split at midnight | No. Theme 5 mentions it beside F04, step 1 names F04 only | Yes | The friction log grades it Minor, traceability only. No later sequence step names it |
| F12, review may not remediate on request | No | Yes | Research says it needs a ruling, not a fix (Theme 5, Open Question 4) |
| Seed-research convention | No. Step 1 names only the hve-review.md:38 sentence from that bullet | Yes | No later sequence step names it |
| Implementation-validator Glob and Grep (Open Question 1) | No | Yes | Needs a live dispatch, which a planning phase cannot do. No later sequence step names it |
| F03, enforce the no-Bash rule | No | Yes | Decision D4 goes the other way and gives the reason (the rule is unenforceable and unfollowable) |

Three of the five have no carrier anywhere in sequence steps 2 to 7. Recorded as DR-006 (Minor).

## 3. Citation check

Every line cited by the plan and details was opened. All anchors hold at ba369fd.

| File | Lines cited | Result |
|---|---|---|
| .claude/commands/hve-research.md | :4, :49, :75, :77, :86, :96 | All hold. Each quoted anchor is unique in the file |
| .claude/commands/hve-review.md | :29, :38, :83, :95, :99 | All hold. `git diff --name-only <base>` appears at both :83 and :95; the details separate them by line and by sentence, which is enough |
| .claude/commands/hve-pr-review.md | :11-13, :30, :32, :34, :36, :147, :149-153 | All hold. :36 carries only the `main...HEAD` literal; the origin form there is prose, not a second command |
| .claude/commands/hve-implement.md | :42, :111 | Hold |
| .claude/agents/hve-rpi-validator.md | :83 | Holds. `## Findings` is at :81, two lines above, not "the line above" as details 2.5 says. Harmless |
| .claude/agents/hve-pr-reviewer.md | :94 | Holds (`### FC-001 [SEVERITY]`) |
| .claude/agents/hve-phase-implementor.md | :19, :31, :42, :132 | Hold. "for the language being implemented" is unique to :31 |
| .claude/agents/hve-researcher.md | :30 | Holds |
| CLAUDE.md | :103, :202, :286, :321, :330, :375-376 | Hold. "these two rules" is at :382, not "near :379-381" as details 4.3 says (DD-024) |
| install.sh | :239-240, :265-266 | Hold |
| README.md | :146, :238-239 | Hold. :146 is in the Cross-cutting flags table, which is the wrong target (DD-018) |
| docs/installation.md | :85-86, :157, :187-188 | Hold |
| docs/reference.md | :33 | Holds (closing fence of the tree) |
| tests/run-drift-tests.sh | :466, :576 | Hold |
| tests/run-install-tests.sh | :183, :226 | Hold |
| tests/run-prompt-new-install.sh | :147 | Holds |
| .claude/prompts/pull-request.md | :32 | Holds (`--compact` bullet, inside `## Options`) |
| .gitignore | :3, :5 | Hold |

Ambiguous or missing targets (not wrong anchors): "the review report's scope line" in details 3.3 does not exist in the template at hve-pr-review.md:47-65; "after step 5" is used for two different insertions in details 3.3 and 3.5 (DD-019).

The eleven unchanged instruction-path carriers listed in details 4.2 were checked against a Grep for `.claude/instructions/` under .claude/. The list is complete for read instructions. The remaining hits (hve-doc-ops.md:26, hve-prompt-builder.md:28, :89, hve-prompt-analyze.md:27, hve-prompt-updater.md:64, prompts/doc-ops.md:21, prompts/prompt-build.md:9) name the folder as a location or artifact type, not as a file to read.

## 4. Missed carriers and guard lists

Step 1.8 list: complete. Grep for `never add Bash|read-only by design|Do not add Bash` outside the tracking folder returns exactly four hits: CLAUDE.md:202, hve-researcher.md:30, hve-research.md:49, hve-research.md:75. After Phase 1 the two expected survivors remain. No doc under docs/, README.md, or CONTRIBUTING.md states that research has no Bash. hve.md:65-71 runs the research protocol by reference and has Bash in its tool list, so it does not disagree.

Step 4.6 list: complete for the literal pattern. Grep for `\*\*/subagents/` outside the tracking folder returns the same 11 hits the plan lists. The pattern cannot see prose copies, and there are three: README.md:42-44, docs/installation.md:24-26, tests/run-prompt-new-install.sh:91-93 (DR-003, Major). Two untracked blog drafts at the repo root carry the same prose and are not product files.

Other carriers checked:

| Rule changed | Other copies | Result |
|---|---|---|
| `/hve-pr-review` flag set | hve-pr-review.md:3 argument-hint; CLAUDE.md:47; README.md:134; README.md:183-185; pull-request.md:25-34 | argument-hint missed (DD-011, Major). README.md:134 missed in favour of the wrong table (DD-018). CLAUDE.md:47 skipped on purpose (DD-004) |
| Tracking tree | CLAUDE.md:78-103; docs/reference.md:8-33 | Both covered by Step 5.3. No third copy found |
| Hook example | CLAUDE.md:330 only | No other copy of `CLAUDE_TOOL_INPUT_FILE_PATH` in the repo |
| Hardcoded severity in a findings template | hve-implementation-validator.md:120, :123 | Sibling of the :83 defect, not named by research (DD-028) |
| "Wait for" sentences | hve.md:69; hve-plan.md:139; hve-implement.md:114; hve-review.md:97, :136; hve-prompt-builder.md:75 | Left to inherit from CLAUDE.md, recorded in DD-006 |
| Changed-file list description | hve-rpi-validator.md:23 | Goes stale after Step 3.7 (DD-015) |
| Count words for the tracking rules | CLAUDE.md:382 "these two rules" | Present; details hedge the edit (DD-024) |
| Coverage rule for reviewers | hve-pr-review.md:164 | Conflicts with details 2.4 (DD-016) |
| Tally-integrity rule | hve-review.md:97, :149 | Conflicts with details 1.5 when a re-check falsifies a finding (DD-017) |

## 5. Test impact (from the test source, not run)

### tests/run-drift-tests.sh

No existing assertion fails after the planned edits. Checked test by test:

| Test | Why it still passes |
|---|---|
| 5 | The `--subagent-model` lines are not touched |
| 7 | No Response Format section is edited |
| 8 | The regex at :466 needs `NAME.md` after the folder; the new CLAUDE.md text names the folder only, so no row is added. The plan's [MEDIUM] assumption at Step 4.1 holds |
| 9, 12 | The only new backticked `hve-*` token in a command is `hve-researcher`, which hve-research.md already carries. `.claude-hve-tracking` strings are not preceded by a backtick, so they do not match |
| 10, existing rows | Details 1.2 writes "shell stays in the parent" without bold, so the `shell_stays_in_parent` count stays 1. Details 3.6 does not reproduce the `security_checklist` prefix |
| 10, new row | Format `'dispatch_async|1|identical|**Dispatch is asynchronous.**'` matches the spec at :553 and the sibling at :576. It passes while the pointer sentences omit the period inside the bold (DD-027) |
| 13 | The new bullet in pull-request.md sits in `## Options`, yields token `--working-tree`, and resolves through the code span that details 3.2 adds to the command body (:890-899). The plan's [MEDIUM] assumption at Step 3.8 holds |
| 14 | New pointers name `Subagent Dispatch Discipline` and `Severity Grading`, both real headings and both already in the distinct set |
| 15 | hve-review.md:25 and :32 are untouched |
| 16 | The new `add_ignore` line and the new echo line both contain `claude-hve-tracking` and are filtered out at :1171 and :1181 |

Count: Step 6.1 expects 251. A count-1 identical row records two passes (:620, :638), and Test 13 gains one token. Static expectation is 253 (DD-014).

### tests/run-install-tests.sh

No existing assertion fails. `assert_contains` uses `grep -qF` (tests/lib/assert.sh:58), so the `**` in the new rule is matched literally and an assertion in the same shape as :181-184 will work. test5 does not assert the printed rules (:404-405 only), so the plan's conditional in Step 4.5 resolves to no change and the new echo line is unguarded (DD-026). test6 counts exact credential lines and is unaffected by a rule appended after them.

### tests/run-prompt-new-install.sh and tests/run-prompt-upgrade.sh

Both are semi-manual and clone a remote branch. The new-install script would gain an assertion at :147 that its own pasted prompt at :91-93 does not ask for (DR-003). The upgrade script has no .gitignore assertion and no rules list, so Step 4.5 changes nothing there.

## 6. Evidence rules

Unearned verification claims (DD-022): the baseline line at plan:120 and the planning-time checks in the log give results without the commands. Both are low exposure.

Assumptions verified here that the plan marks [MEDIUM]: Step 2.2 (holds, but adds two passes), Step 3.8 (holds), Step 4.1 (holds).

Assumptions with no marker: eight, listed in DD-023.

No instruction-like text addressed to an agent was found in any file read. Nothing to report under the Untrusted Input rule.

## 7. Internal consistency

- Dependencies versus shared files: DD-010 (Major).
- Criteria that can pass without the change: DD-011 (cannot pass at all as written), DD-020, DD-021.
- Replacement text against other replacement text: details 3.2 against 3.4 (DD-012); details:7 against 3.8 on em-dashes (DD-018).
- Replacement text against untouched neighbours: details 2.4 against hve-pr-review.md:164 (DD-016); details 1.5 against hve-review.md:97 and :149 (DD-017); Step 3.8 against README.md:141 (DD-018); details 4.4 against CLAUDE.md:382 (DD-024); details 3.3 against the review template (DD-019).
- Phase completeness: every phase has success criteria and a testable output. Underspecified steps are collected in DD-019, DD-020, and DD-025.

## Findings index

| ID | Severity | Title |
|---|---|---|
| DR-003 | Major | F10 fix misses the three prose copies of the tracking rules |
| DD-010 | Major | Phase dependencies leave four same-file pairs free to run in parallel |
| DD-011 | Major | `--working-tree` success criterion cannot pass; argument-hint not updated |
| DD-012 | Major | Working-tree mode routed only through the empty-diff guard |
| DD-013 | Major | Security-floor step for the excluded folder has three holes |
| DR-004 | Minor | D1 consequence (annotate the HiVE brief) has no step |
| DR-005 | Minor | D4 "one pass" bound not carried into the text |
| DR-006 | Minor | Three DD-008 exclusions have no later carrier |
| DD-014 | Minor | Step 6.1 expected drift count is 253, not 251 |
| DD-015 | Minor | Untracked list in `/hve-review` includes the task's own artifacts |
| DD-016 | Minor | Details 2.4 conflicts with the Coverage rule; "complete" undefined |
| DD-017 | Minor | F14 re-check rules name no outcome |
| DD-018 | Minor | README row targets the wrong table; flag decision unrecorded |
| DD-019 | Minor | Phase 3 insertion points underspecified |
| DD-020 | Minor | Step 3.1 fixture fails for an unrelated reason; criterion tests the prototype |
| DD-021 | Minor | Success criteria that pass without the change |
| DD-022 | Minor | Verification claims without commands |
| DD-023 | Minor | Assumptions with no confidence marker |
| DD-024 | Minor | Details 4.1 wording; hedged edit at CLAUDE.md:382 |
| DD-025 | Minor | Hook date changes from local to UTC; Step 5.2 fixture incomplete |
| DD-026 | Minor | Ignore-rule upgrade path and global printout not fully covered |
| DD-027 | Minor | Pointer outside the Test 14 construction; no branch when Bash is denied |
| DD-028 | Minor | Sibling carriers left as they are |

Full text of each entry, with recommendation, is in the planning log's Discrepancies section.

Severity notes. DD-011 is graded Major because a phase gate that cannot pass forces an unplanned edit to the frontmatter of an installed command; the fix is one token. DD-015 is graded Minor because the effect is repeated false "unlisted change" entries, not a changed verdict; it would move to Major if validators grade those entries above Minor. DD-016 is graded Minor because a reviewer file is normally written in one call, so a partial file is rare.

## Not verified this session

- Neither suite was run. The 253 figure and the "no existing assertion fails" result are static readings.
- The working-tree recipe was not executed under bash, with newline filenames, or with binary untracked files (the log already lists these as unchecked).
- Live behaviour of hook delivery, subagent Glob and Grep restoration, and `allowed-tools` semantics remains [MEDIUM] as the plan states.
- Whether a non-interactive caller can answer the Bash prompt that DD-002 accepts.
- Anchors must be re-located after PR #4 merges (DD-009).
