# Planning Log: Phase-Ending Clarity (Thread B)
Date: 2026-08-19
Plan: .claude-hve-tracking/plans/2026-08-19/phase-close-clarity-plan.md

## Discrepancies

### DR-001: Research cited stale test counts
Source: Research A3 cites the 2026-08-15 review's figures, drift 248/0 and install 66/0.
Resolution: The parent re-ran both suites during planning on 2026-08-19 and measured drift 255
passed / 0 failed and install 69 passed / 0 failed (superseded, see Correction 2026-10-10: 253 and 72 at the BASE). The plan uses the measured figures as its
baseline. The research figures were never wrong, they were a snapshot of a dated artifact.
Status: Resolved

### DR-002: Research left the HANDOFF field-name divergence unresolved
Source: Research B4 lists seven different artifact field names across commands (Artifact, Plan,
Changes, Review, Session, File, Sandbox) and proposes collapsing to a single `artifact` key, but
does not say what happens to commands that legitimately reference two artifacts.
Resolution: The plan adds an optional-extra-keys rule (Step 1.6): three required keys in fixed
order, then any number of optional lowercase `key: value` lines. hve-plan carries `details:`,
hve-implement carries `plan:`. A fixed-key parser reads the first three and ignores the rest.
Status: Resolved

### DR-003: hve-review emits its close only on Complete
Source: hve-review.md:161 gates the Handoff Block on Complete status. Research B4 wants a
machine-readable `status:` covering blocked and needs-rework, which that gate makes unreachable.
Resolution: Step 2.5 changes the gate so the close is emitted on every verdict, with `next:`
varying per the existing routing at hve-review.md:152-155. A status field that only ever emits
`done` carries no information.
Status: Resolved

### DR-004: Research open question 5 cannot be closed during planning
Source: Research B3 marks the root-cause hypothesis [MEDIUM] and says confirmation needs one live
run capturing raw assistant output.
Resolution: Not closed, and deliberately so. The plan does not assert the hypothesis is confirmed.
Step 6.3 is an explicit live-run verification step in the implementation phase. The chosen fix
(labeled lines) is robust to the hypothesis being wrong, because a format with no `|` characters
cannot table-parse regardless of why the old one did.
Status: Open by design, guarded by Step 6.3

## Design decisions

### DD-001: All 15 commands, not the 8 from the 2026-08-15 memory
Source: Research open question 4 flagged the scope delta; Kevin chose all 15 on 2026-08-19.
Assumption: The four previously-unstructured commands (git-setup, git-commit, git-merge,
prompt-refactor) benefit from the same close even though three of them produce no tracking
artifact.
Risk: Those three need the `artifact: none - <reason>` branch, which is a template blank that
would otherwise be unfillable. Step 1.5 defines the branch before Phase 4 needs it.

### DD-002: Fix 2 (drop box-drawing) over Fix 1 (mandate the fence)
Source: Research B3 evaluates both and recommends Fix 2; Kevin confirmed on 2026-08-19.
Assumption: Losing the visual box costs less than leaving correctness to prompt discipline, which
is the failure mode already observed.
Risk: The close becomes visually flatter. Mitigated by the three bold headers carrying the visual
structure. Step 1.7 keeps the fence instruction anyway, so the belt-and-braces half of Fix 1 is
retained at zero cost.

### DD-003: Centralize in CLAUDE.md rather than duplicate per command
Source: Research B1 recommends this carrier and marks it [MEDIUM].
Assumption: One CLAUDE.md section plus a per-command pointer is better than 15 byte-identical
copies plus a test-10 row.
Risk: None found. Upgraded from the research's [MEDIUM] to [HIGH] after the parent verified the
test-14 mechanism directly (tests/run-drift-tests.sh:959, :965; superseded, see Correction 2026-10-10: :962 and :968 at the BASE): the pointer form
``per CLAUDE.md's `Completion Summary` section`` resolves against any `##`-level heading with no
test edit.

### DD-004: Enum alternatives live in prose, never in the template
Source: Not in the research. Found during planning by reading the live templates.
Assumption: A template line containing `|` will be copied verbatim into emitted output.
Risk: This is the bug being fixed, reintroduced through the back door. hve-pr-review.md:189-190
(superseded, see Correction 2026-10-10: the lines were :188-189 when written and are :221-222 at the BASE)
are the live examples: two box rows with bare ASCII `|` separating alternatives. Step 1.4 forbids
the pattern and Step 5.5 greps for the regression.

### DD-005: The section heading stays `Handoff Block Format` unless the reference sweep lands with it
Source: Design decision during planning.
Assumption: Renaming the heading would be cleaner (the thing is no longer a block, and no longer a
box), but every existing pointer resolves against the current text and drift test 14 fails loudly
on a mismatch.
Risk: The section name outlives the format it names. Accepted for now; Step 1.4 permits the rename
only if Phase 5's sweep happens in the same change.

### DD-006: Thread B sequenced before the CLAUDE.md lean restructure
Source: Research open question 7; Kevin chose Thread B first on 2026-08-19.
Assumption: Thread B's CLAUDE.md footprint (one new section, one rewritten section, one clause on
line 19) is small and additive enough that the restructure can rebase onto it.
Risk: If the restructure deletes or relocates the `Handoff Block Format` section, Thread B's
pointers break. Drift test 14 catches it. Also note the rpi-output-quality-regression plan adds its
own CLAUDE.md section and a drift test 17; three plans now queue edits to CLAUDE.md.

Update (2026-08-19, after the sibling plan appeared mid-session): the
`claude-md-lean-restructure` plan was written concurrently at 12:06 and read by the parent at
12:12. Checked directly: `grep -n 'Handoff Block|Lean turns|principle 5|Completion Summary'` over
that plan returns no matches, so it does not edit either section Thread B targets, and it commits
to keeping every frozen heading and sole-copy canonical block byte-intact. Two residual tensions
remain and are Kevin's call, not resolvable from the files:

1. Intent, not line numbers. The restructure exists to SHRINK the CLAUDE.md payload that
   `install.sh:171` ships into every consuming project. Thread B ADDS a new `## Completion Summary`
   section to that same payload. The two plans pull in opposite directions on payload size even
   though they touch disjoint text.
2. The restructure trims preamble narrative. Principle 5 lives in the preamble at CLAUDE.md:19,
   which is exactly the line Thread B Step 1.3 amends.

Neither is a merge conflict; both are worth a decision before the second plan runs.

Resolved by Kevin, 2026-08-19: tension 1 is not a conflict. Shrinking the shipped CLAUDE.md
payload and adding a Completion Summary section to it are both wanted. The restructure removes
adopter-facing bulk; Thread B adds a small operating-format section. Thread B proceeds without
waiting, and the restructure treats the new section as content to preserve, not to relocate.

### DD-007: Research open question 6 resolved during planning, not deferred
Source: Research asked whether hve-review's verdicts map cleanly onto the status enum.
Assumption: None needed. The parent read hve-review.md:153-155 and confirmed exactly three
verdicts mapping 1:1 and totally onto done / needs-rework / blocked.
Risk: None. Recorded in the details file as a table.

### DD-008: Citation error in Step 1.4 annotation
Source: Plan Step 1.4 states: "The enum-in-prose rule exists because the current template
embeds alternatives with `|` characters (hve-pr-review.md:189 and hve-review.md:172 are the
live examples). A template whose sample line contains `|` reintroduces exactly the table-parse
class of bug this phase removes [HIGH: the two cited lines do contain bare `|`]"
Unearned claim: hve-review.md:172 contains bare `|` characters separating alternatives
Evidence contradicting the claim: Details document line 81 explicitly enumerates:
`hve-review.md:172      (box row, single value, no pipe)`
Correct examples: hve-pr-review.md:189 (line 80 of details) and hve-pr-review.md:190
(line 82 of details) are the two actual examples with bare pipes
Risk: Minor; the rule and plan logic are sound, but one citation is factually wrong. Does not
undermine the plan's validity since labeled-line format is robust regardless.
Severity: Minor
Recommendation: Change Step 1.4 annotation to cite "hve-pr-review.md:189 and hve-pr-review.md:190
are the live examples" (both in the same file), and update the [HIGH] marker text if needed.
Status: Open (superseded, see Correction 2026-10-10: resolved; Step 1.4 already carried the corrected
enumeration, and this entry's own recommended lines, :189 and :190, were themselves off by one)

## Refresh (2026-10-10)

Purpose: re-verify the plan set against today's code so it can be approved. Nothing shipped was edited.
BASE: `origin/fix/platform-drift-quick-fixes` @ 0661d621cb4904bf38d9fff8893c2196899e7c3d (head of draft PR #6,
not merged; `main` is f96e34f0859387d0ba871bf4163e5b88159f931a). The plan was written against e78e21c
(2026-08-19), identified as the newest commit where every line citation in the plan resolves as written
[HIGH: `## Handoff Block Format` is at CLAUDE.md:214 and `PR REVIEW COMPLETE` at hve-pr-review.md:185 there].
Method: one read-only shell pass in a worktree of the BASE. Every row in the tables below was produced by
printing the cited lines, not by applying an offset.

### Gate baseline at the BASE

| Command (run from the worktree root) | Result |
|---|---|
| `./tests/run-drift-tests.sh` | 253 passed, 0 failed, rc=0 |
| `./tests/run-install-tests.sh` | 72 passed, 0 failed, rc=0 |
| `tests/run-prompt-new-install.sh` | NOT RUN (semi-manual) |
| `tests/run-prompt-upgrade.sh` | NOT RUN (semi-manual) |

How the counts moved since the plan's 255 and 69, taken from the committed changes logs rather than re-run:
drift 255 to 250 in `validators-inherit-model` (changes/2026-08-23/validators-inherit-model-changes.md:14-15,
an intended drop), then 250 to 252 to 253 in `platform-drift-quick-fixes`
(changes/2026-10-10/platform-drift-quick-fixes-changes.md:127, :226); install 69 to 72 in the same change
(:621). All intended [MEDIUM: read from those logs, intermediate commits not re-run here].

### Citation table (acceptance A1)

"Anchor" is the text the step quotes or describes. "Where" is P for the plan, D for the details, L for this log.

| Citation as written | Where | Location at BASE | Anchor text checked | Status |
|---|---|---|---|---|
| CLAUDE.md:214 | P 1.1 | CLAUDE.md:218 | yes: `## Handoff Block Format` | moved |
| CLAUDE.md:19 | P 1.3, L DD-006 | CLAUDE.md:19 | yes: `5. **Lean turns**` | unchanged |
| CLAUDE.md:216-228 | P 1.4 | CLAUDE.md:220-232 | yes: emission sentence :220, box :222-230, orchestrator exemption :232 | moved |
| CLAUDE.md:228 | P 4.1 | CLAUDE.md:232 | yes: "The `/hve` orchestrator omits this block" | moved |
| CLAUDE.md:225 | D | CLAUDE.md:229 | yes: line ends in `╝` | moved |
| tests/run-drift-tests.sh:965 | P 1.1, D, L DD-003 | :968 | yes: `claude_md_headings() {` | moved |
| tests/run-drift-tests.sh:959 | P 1.1, D, L DD-003 | :962 | yes: `readonly REFERENCE_PATTERN=` | moved |
| tests/run-drift-tests.sh "around 940" | P 6.2 | :571 | yes: `readonly -a CANONICAL_BLOCK_SPECS=(` | anchor present; the cite was wrong when written (it was :569 at e78e21c) |
| hve-doc-ops.md:112 | P 1.4, D | :112 | yes: `Findings : N critical \| N major \| N minor` | unchanged |
| hve-pr-review.md:188, :189 | P 1.4, P 3.1, D | :221, :222 | yes: `Verdict  :` row and `Critical :` row, both with bare pipes | moved |
| hve-pr-review.md:189-190 | L DD-004, L DD-008 | :221-222 | yes | moved, and off by one when written |
| hve-research.md:140-153 | P 2.1 | :141-154 | yes: `## Handoff Block` :141, closing fence :154 | moved |
| hve-research.md:152 | P 2.1, D | :153 | yes: line ends in `╝` | moved |
| hve-plan.md:161-174 | P 2.2 | :161-174 | yes: heading :161, closing fence :174 | unchanged |
| hve-implement.md:168-181 | P 2.3 | :168-181 | yes: heading :168, closing fence :181 | unchanged |
| hve-review.md:165-175 | P 2.4 | :165-175 | yes: `## Handoff Block (on Complete status)` :165 | unchanged |
| hve-review.md:153-155 | P 2.4, D, L DD-007 | :153-155 | yes: the three verdict names | unchanged |
| hve-review.md:152-155 | P 2.5, L DR-003 | :152-155 | yes: "Determine overall status" and the three verdicts; the routing list itself is :157-160 | unchanged |
| hve-review.md:161 | P 2.5, L DR-003 | :161 | yes: "If status is ✅ Complete, emit the Handoff Block" | unchanged |
| hve-review.md:172 | D (2026-08-19 Correction), L DD-008 | :172 | yes: `Status   : ✅ Complete`, zero bare pipes | unchanged |
| hve-pr-review.md:183-191 | P 3.1 | :216-224 | yes: fence :216, `PR REVIEW COMPLETE` :218, fence :224 | moved |
| hve-doc-ops.md:107-114 | P 3.2 | :107-114 | yes: `DOC-OPS COMPLETE` :109 | unchanged |
| hve-memory.md:93-101 | P 3.3 | :93-101 | yes: `MEMORY SAVED` :95 | unchanged |
| hve-prompt-builder.md:92-100 | P 3.4 | :92-100 | yes: `PROMPT BUILDER COMPLETE` :94 | unchanged |
| hve.md:133-143 | P 4.1 | :133-143 | yes: fenced `RPI Complete` block | unchanged |
| hve.md:145-155 | P 4.1 | :145-155 | yes: routing sentence :145, `Follow-On Items` heading :147, end of file :155 | unchanged |
| hve-challenge.md:95-102 | P 4.2 | :95-102 | yes: `## Output` and the per-exchange reminder | unchanged |
| hve-prompt-analyze.md:88-90 | P 4.3 | :88-90 | yes: "If no issues" and the offer line | unchanged |
| hve-git-commit.md:56-60 | P 4.4 | :56-60 | yes: `## Step 5` post-commit report | unchanged |
| hve-git-merge.md:62-69 | P 4.5 | :62-69 | yes: `## Step 4` completion, "No automatic push" :69 | unchanged |
| hve-git-setup.md:71-77 | P 4.6, D | :71-77 | yes: `## Critical Constraints`, end of file :77 | unchanged |
| hve-prompt-refactor.md:64 | P 4.7 | :64 | yes: "7. Report what was changed" | unchanged |
| hve-prompt-refactor.md:50 | P 5.2 | :50 | yes: "Handoff Block for phase commands" | unchanged |
| hve-prompt-updater.md:55 | P 5.1 | :55 | yes: "Handoff Block present at the end (for phase commands)" | unchanged |
| .claude/prompts/rpi.md:23 | P 5.3 | :23 | yes: "previous session's Handoff Block" | unchanged |
| docs/internals.md:9 | P 5.4 | :9 | yes: "handoff block format" | unchanged |
| docs/workflow.md:134 | P 5.4 | :134 | yes: "handoff block at the end of each phase command" | unchanged |
| install.sh:171 | L DD-006 | :171 | yes: `HVE_BLOCK="$(awk '/^## Your Project/{exit} {print}'` | unchanged |

Result: 38 rows. 26 unchanged, 11 moved with the anchor text intact, 1 where the anchor is present but the
original cite was wrong. None gone, none with changed anchor text.

### Correction (2026-10-10)

1. Line updates, anchor text unchanged (one consolidated entry). Old to new: CLAUDE.md:214 to :218;
   CLAUDE.md:216-228 to :220-232; CLAUDE.md:228 to :232; CLAUDE.md:225 to :229; tests/run-drift-tests.sh:965
   to :968 and :959 to :962; hve-pr-review.md:188-189 to :221-222 and :183-191 to :216-224;
   hve-research.md:140-153 to :141-154 and :152 to :153. Causes: CLAUDE.md gained four lines above the section
   (the companion-folders paragraph and the "Dispatch is asynchronous" paragraph); hve-pr-review.md gained 33
   lines (working-tree mode, tracking-folder scan, blocked-reviewer handling); hve-research.md gained one.
   The plan and details now carry the new numbers.
2. Plan Step 6.2 cited `CANONICAL_BLOCK_SPECS` as "around 940". It was :569 when written and is :571 now. It
   should have said :569.
3. Baselines. The plan said drift 255/0 and install 69/0. At the BASE they are 253/0 and 72/0, both rc=0.
   Five places in the plan carried the old figures; each is annotated in place.
4. Phase 5's success criterion and Step 5.5 expected a box-drawing grep to return nothing outside the tracking
   folder. That was never reachable: tree diagrams in CLAUDE.md, docs/reference.md, docs/workflow.md,
   docs/internals.md and .claude/instructions/terraform.md use `│ ├ └ ─`, and they predate the plan. The
   criterion should have named the close-box corners only. Replaced with a corner-only command and a list of
   recorded exclusions.
5. Step 1.3 quoted a `grep -rn 'a|b|c'` with no `-E` as proof that nothing restates principle 5. Without `-E`
   the pattern is one literal string, so the command proved nothing. Re-run with `-E` over `.claude`,
   README.md, docs and CONTRIBUTING.md: no matches. The conclusion was right; the evidence was not.
6. The details file said the `╝` corner defect is in CLAUDE.md and hve-research.md. It is in four files:
   CLAUDE.md:229, hve-research.md:153, hve-plan.md:173, hve-implement.md:180. All four are removed by
   deletion in Phases 1 and 2, so no step changes.
7. Two sentences justified the design by HiVE (plan Overview; details, status enum section). Under cross-repo
   D1 hve-claude takes no dependency on HiVE or hve-orchestrator. They should have said the labeled block
   serves any non-human caller, which cross-repo D2 puts in scope. Annotated in place; no step changes.
8. Step 6.5 said to coordinate with Thread A "in the same window". Thread A is now last in the recommended
   sequence. Annotated.
9. DD-004 cited hve-pr-review.md:189-190 and DD-008 recommended the same pair. The lines were :188-189 at the
   time. DD-008 is closed: Step 1.4 already carried the enumerated, correct list.
10. Header status. "Validated (2026-08-19)" described a validation against e78e21c. It is kept as "Prior
    status" and the Status line now names the refresh, the BASE and the new validation result.

Format note: CLAUDE.md's `Corrections in Tracking Artifacts` section writes the in-place marker with an
em-dash. This refresh writes it with a comma, "(superseded, see Correction 2026-10-10)", because the project
rule against em-dashes also applies; the cross-repo review of the same date uses the comma form too.

### Conflict analysis, per shipped file changed since the plan was written (acceptance A2)

Command: `git diff --stat e78e21c..0661d62 -- .claude CLAUDE.md README.md CONTRIBUTING.md docs install.sh tests`
returns 28 files, 156 insertions, 87 deletions. Of those, 17 changed in step 1
(`git diff --stat f96e34f..0661d62 -- . ':!.claude-hve-tracking'`) and the rest only in the 2026-08-23
`inherit` and `fable` commits (bbec0d9, 01c0e85).

| File | Touched by a plan step | What changed | Effect on the plan |
|---|---|---|---|
| CLAUDE.md | 1.1 to 1.7, 4.1 | Model Selection rewritten; companion-folders paragraph; "Dispatch is asynchronous" paragraph; instructions-path note; hooks example; third ignore rule | Lines moved by 4 (Correction 1). The async rule says a gate outcome is never reported from a notification alone, which agrees with the summary's "numbers obtained by execution" rule. No step text conflicts [HIGH] |
| .claude/commands/hve-pr-review.md | 3.1, 3.5 | `--working-tree`; tracking-folder exclusion and scan; early exits at :44-46; `Coverage:` line and covered-set suffix on the verdict (:212-213); blocked-reviewer rule | CONFLICT with Step 3.1 as written: "emit one concrete value" must keep the covered-set suffix; early exits emit no close. Step 3.1 amended, Step 1.9 added, decisions O1 and O2 raised |
| .claude/commands/hve-research.md | 2.1, 2.6 | Read-only parent shell pass; negative-claim re-check; async wait pointer | Lines moved by 1. The new text names neither the box nor the close. :40 and :135 name the Handoff Block outside the replaced section and predate step 1; Step 2.7 added |
| .claude/commands/hve-review.md | 2.4, 2.5 | `fable` tier; `Research:` header path rule; untracked-file note; contested-severity wording | Verdict lines :153-155 and gate :161 unchanged. No conflict |
| .claude/commands/hve-implement.md | 2.3 | `fable` tier; one implementor line | Close section unchanged. No conflict |
| .claude/commands/hve-plan.md | 2.2 | `fable` tier in the argument hint | No conflict |
| .claude/commands/hve.md | 4.1 | `fable` tier, two lines | Close unchanged. The bare pipes at :141-142 predate the plan and were missed; Step 4.1 amended |
| .claude/commands/hve-doc-ops.md | 3.2 | `fable` tier, two lines | No conflict |
| .claude/commands/hve-prompt-builder.md | 3.4 | `fable` tier, two lines | No conflict |
| .claude/commands/hve-prompt-refactor.md | 4.7, 5.2 | Model frontmatter guidance at :41 | :50 and :64 unchanged. No conflict |
| .claude/prompts/rpi.md | 5.3 | `fable` tier at :10 | :23 unchanged. No conflict |
| docs/internals.md | 5.4 | Agent table model column | :9 unchanged. No conflict |
| tests/run-drift-tests.sh | 6.1, 6.2 | Tier set; `dispatch_async` spec row | Cited lines moved by 3 and 2. The new spec row pins a CLAUDE.md paragraph this plan does not edit. No conflict |
| tests/run-install-tests.sh | 6.1 | Three new assertions for the diff.patch rule | Baseline 69 to 72. No conflict |
| README.md | 6.5 | Model wording; ignore-rule text | Contains no box and no mention of the handoff block. No conflict |
| docs/installation.md, docs/reference.md | none | Ignore rules; reserved folders | No conflict |
| install.sh | none (6.4 runs it) | diff.patch ignore rule | :171 unchanged. No conflict |
| tests/run-prompt-new-install.sh | none | Ignore-rule check text | Not a gate; NOT RUN. Its banner boxes are a recorded exclusion |
| .claude/agents/hve-implementation-validator.md, hve-phase-implementor.md, hve-plan-validator.md, hve-pr-reviewer.md, hve-prompt-evaluator.md, hve-rpi-validator.md | none | Model frontmatter; severity unpinning; scan-result input | None names the close or the box. No conflict |
| .claude/prompts/doc-ops.md, prompt-build.md, pull-request.md | none | Tier set; one pull-request line | No conflict |

Text added by step 1 that carries an old-format close or names the HANDOFF block: none. Command:
`git diff -U0 f96e34f..0661d62 -- . ':!.claude-hve-tracking' | grep -E '^\+' | grep -iE 'handoff|╭|│|COMPLETE'`
returns six lines, all matching only on the word "complete" in unrelated sentences (the async-dispatch wait
and the blocked-reviewer rule); the four lines that say "handoff-block" (hve-plan.md:13,
hve-implement.md:19, hve-review.md:19, hve-pr-review.md:17) are unchanged since e78e21c [HIGH].

Counts re-derived at the BASE:

| Claim in the plan | Command | Result |
|---|---|---|
| 15 commands | `ls .claude/commands/*.md \| wc -l` | 15 |
| four true-HANDOFF commands plus four sibling boxes plus the CLAUDE.md template | `grep -rlE '[╭╮╰╯╝]' .claude CLAUDE.md README.md CONTRIBUTING.md docs \| wc -l` | 9 files: CLAUDE.md, hve-research, hve-plan, hve-implement, hve-review, hve-pr-review, hve-doc-ops, hve-memory, hve-prompt-builder |
| exactly three box rows with a bare pipe | `grep -rn '│.*\|' .claude/commands/*.md` | 3 lines: hve-doc-ops.md:112, hve-pr-review.md:221, :222 |
| seven commands in Phase 4 | 15 minus the 8 box files | 7: hve, hve-challenge, hve-prompt-analyze, hve-git-commit, hve-git-merge, hve-git-setup, hve-prompt-refactor |
| five files in Phase 5 | Steps 5.1 to 5.4 | 5: hve-prompt-updater.md, hve-prompt-refactor.md, prompts/rpi.md, docs/internals.md, docs/workflow.md |
| no pointer to either section exists yet | grep for the two pointer strings under `.claude` | 0 |
| drift and install baselines | see the gate table above | 253/0 and 72/0, not 255/0 and 69/0 |

### Carrier enumeration at the BASE (acceptance A3)

Commands:
`grep -rnE '[╭╮╰╯╔╗╚╝┌┐└┘]' .claude CLAUDE.md README.md CONTRIBUTING.md docs tests install.sh` and
`grep -rniE 'handoff' .claude CLAUDE.md README.md CONTRIBUTING.md docs tests install.sh` and
`grep -rnE 'MEMORY SAVED|REVIEW COMPLETE|DOC-OPS COMPLETE|BUILDER COMPLETE|RPI Complete|copyable' .claude README.md docs CONTRIBUTING.md CLAUDE.md tests`.

| Carrier | Location at BASE | Named by the plan | Disposition |
|---|---|---|---|
| Canonical HANDOFF box and emission sentence | CLAUDE.md:220-232 | yes, Step 1.4 | in plan |
| HANDOFF box | hve-research.md:141-154 | yes, 2.1 | in plan |
| HANDOFF box | hve-plan.md:161-174 | yes, 2.2 | in plan |
| HANDOFF box | hve-implement.md:168-181 | yes, 2.3 | in plan |
| HANDOFF box | hve-review.md:165-175 | yes, 2.4 | in plan |
| `PR REVIEW COMPLETE` box | hve-pr-review.md:216-224 | yes, 3.1 | in plan |
| `DOC-OPS COMPLETE` box | hve-doc-ops.md:107-114 | yes, 3.2 | in plan |
| `MEMORY SAVED` box | hve-memory.md:93-101 | yes, 3.3 | in plan |
| `PROMPT BUILDER COMPLETE` box | hve-prompt-builder.md:92-100 | yes, 3.4 | in plan |
| Second close path, Simple direct path | hve.md:44 | no | Finding from validation, Step 4.1 note |
| Fenced `RPI Complete` block | hve.md:133-143 | yes, 4.1 | in plan; its bare pipes at :141-142 were NOT named. Finding, now in Step 4.1 |
| Prose that names the block inside a converted file | hve-research.md:40, :135; hve-plan.md:153, :157; hve-implement.md:164; hve-review.md:165 heading qualifier | no | Finding, new Step 2.7 |
| Emit gate | hve-review.md:161 | yes, 2.5 | in plan |
| Convention checklists | hve-prompt-updater.md:55; hve-prompt-refactor.md:50 | yes, 5.1, 5.2 | in plan |
| Resume instruction | .claude/prompts/rpi.md:23 | yes, 5.3 | in plan |
| Living docs | docs/internals.md:9; docs/workflow.md:134 | yes, 5.4 | in plan |
| Report template with bare-pipe lines | hve-prompt-analyze.md:79-83, :85 | no | Finding, Step 4.3 note, decision O3 |
| Early exits that end a command with no close | hve-pr-review.md:44-46 and the other stop lines (12 lines in 8 command files by a case-sensitive grep, plus hve-git-setup.md:67) | no | Finding, new Step 1.9, decision O1 |
| Argument-parsing sentence "pasted handoff-block text" | hve-plan.md:13; hve-implement.md:19; hve-review.md:19; hve-pr-review.md:17 | no | Recorded exclusion, Step 5.6 |
| Generic uses of the word | CLAUDE.md:3, :58, :76, :150, :263 | no | Recorded exclusion, Step 5.6 |
| Directory-tree diagrams using box-drawing characters | CLAUDE.md:80-102; docs/reference.md:10-32; docs/workflow.md:17-33; docs/internals.md:40; .claude/instructions/terraform.md:13 | no | Recorded exclusion, Step 5.5 |
| Terminal banner boxes | tests/run-prompt-upgrade.sh:33-35, :80-82, :91-93; tests/run-prompt-new-install.sh:50-52, :63-66, :75-77 | no | Recorded exclusion, Step 5.5 |
| README.md, CONTRIBUTING.md, install.sh, tests/run-drift-tests.sh, tests/run-install-tests.sh | none found | n/a | no carrier: no box corner and no "handoff" in any of them |

Four findings (hve.md pipes, in-file prose, hve-prompt-analyze pipe line, early exits) and four exclusion
groups. No carrier the plan named has disappeared.

### Fit with the cross-repo decisions (D1 to D5 of 2026-10-10)

- Cross-repo D1 (no dependency on HiVE or hve-orchestrator): fits after Correction 7. No step reads, writes
  or references either project; two justifying sentences were annotated [HIGH].
- Cross-repo D2 (non-human callers are supported): fits and is strengthened by it. The fixed-key block is the
  part a seat or script reads. D2 is also what makes the early-exit gap (O1) and the unmapped pr-review
  status (O2) matter [HIGH].
- Cross-repo D3 (`model: inherit`): unrelated; no step touches model selection [HIGH].
- Cross-repo D4 (research may run one read-only parent shell pass): unrelated to the close. It added the
  line that moved hve-research.md by one [HIGH].
- Cross-repo D5 (Path 2, shrink re-planned after the bundles): consistent with plan D3 and DD-006. The
  restructure follows this plan in either reading [HIGH].
- Sequence: this is step 2. Bundle B (step 4) will revisit the hve-implement.md:164 acknowledgment wait; it
  rebases onto Step 2.7's wording [MEDIUM: Bundle B is unplanned].

### Owner decisions open before approval

- O1: Do early stops emit the close? Recommended yes, as one centralized rule in CLAUDE.md (Step 1.9), with
  `blocked` for a stop that needs something first and `done` for a clean stop. If no, delete Step 1.9 and
  give hve-review's hard stop (hve-review.md:32) its own status line in Step 2.5, since nothing else covers it.
- O2: What `status:` does hve-pr-review emit? Recommended: map verdicts as hve-review does (Approve `done`,
  Request Changes `needs-rework`, Block `blocked`) plus an optional `verdict:` line that keeps the
  covered-set suffix. The same answer settles the default for the other commands: `done` at a normal end.
- O3: Are the bare-pipe lines in the hve-prompt-analyze report template in scope (:85, and :79-83 found by
  the validator, six lines in all)? Recommended yes.
- O4: Who runs Step 6.3 (live render check) and Step 6.4 (`./install.sh --global`)? Recommended: the owner,
  after implementation and after merge respectively; an unattended implementor records both as NOT RUN.
- O5 (from validation, blocks Phase 2): is the close emitted once per command, or once per stopping turn?
  Recommended: once per stopping turn, so hve-plan and hve-implement emit it at their approval gate with
  `awaiting-approval` and again after approval with `done`. The alternative is a single close after approval,
  which drops `awaiting-approval` from the enum.

### Validation of the refreshed plan (2026-10-10)

Agent: `hve-plan-validator`, dispatched once. Artifact:
.claude-hve-tracking/reviews/rpi/2026-10-10/phase-close-clarity-plan-validation.md. Result: Fail, 0 Critical,
1 Major, 15 Minor. It read 55 citations and 54 resolved. The validator has no shell: the baselines and diff
figures it relied on are the ones recorded above. Its DR- and DD- entries stay in its own file; the table
below is the parent's check of each against the files.

| Finding | Severity | Parent check | Outcome |
|---|---|---|---|
| DD-009 once-per-command against the approval gates | Major | Confirmed: hve-plan.md:153 and :157, hve-implement.md:164, plan Steps 1.2, 2.2, 2.3 | Not resolvable from the files. Raised as O5, noted at Step 1.2 |
| DR-005 fourth review outcome, the plan-absent stop | Minor | Confirmed: research open question 6; hve-review.md:32 | Noted at Step 1.9; O1 reworded |
| DD-010 no status value for most commands | Minor | Confirmed by reading Phases 3 and 4 | Recommended default noted at Step 1.4, folded into O2 |
| DD-011 every early stop marked blocked | Minor | Confirmed: hve-pr-review.md:45, hve-git-setup.md:67 | Step 1.9 note |
| DD-012 O3 is six lines | Minor | Confirmed: hve-prompt-analyze.md:79-83, :85 | O3 and Step 4.3 reworded |
| DD-013 report path cannot exist | Minor | Confirmed: hve-prompt-analyze.md:4 | Step 4.3 note |
| DD-014 second close path in hve.md | Minor | Confirmed: hve.md:44; tests/run-drift-tests.sh:584 | Step 4.1 note, carrier row added |
| DD-015 pipe guard has no command | Minor | Confirmed | Command added at Step 5.5 |
| DD-016 moved line numbers replaced without a marker | Minor | CONTESTED: anchor text is unchanged for all of them, the header says citations were refreshed, and Correction item 1 lists every old and new value | No change |
| DD-018 two generic lines missing from exclusions | Minor | Confirmed: CLAUDE.md:3, :76 | Added to Step 5.6 |
| DD-019 small stale statements | Minor | Confirmed for the routing cite and the two log lines | Annotated in place |
| DR-006, DD-017, DD-020, DD-021, DD-022 | Minor | Not re-opened by the parent | Left open in the validator's file for implement time; none blocks approval |
