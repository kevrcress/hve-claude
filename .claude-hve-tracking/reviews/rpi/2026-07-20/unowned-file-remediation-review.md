# Review Log: Unowned-File Convention Remediation

Date: 2026-07-20
Plan: .claude-hve-tracking/plans/2026-07-20/unowned-file-remediation-plan.md
Changes: .claude-hve-tracking/changes/2026-07-20/unowned-file-remediation-changes.md
Research: .claude-hve-tracking/research/2026-07-20/unowned-file-remediation.md
Details: .claude-hve-tracking/details/2026-07-20/unowned-file-remediation-details.md
Overall Status: ⚠️ Needs Rework (0 Critical, 3 Major, 10 Minor)

## Review Scope & Dispatch Deviation

The plan defines 7 phases (0-6), all marked Complete in the changes log. The command
instructs one `hve-rpi-validator` per Complete phase. This session dispatched five
(Phases 1-5) rather than seven, and validated Phases 0 and 6 in the parent session.

Rationale, recorded per the CLAUDE.md Subagent Dispatch Discipline convention: Phases 0
and 6 edit no repo files. Their success criteria are shell facts (a test-suite pass count
and an installer run). `hve-rpi-validator` has no Bash tool, so dispatching it for those
phases would have produced static inference dressed as verification. The parent ran the
checks directly instead; evidence below.

### Phase 0 (parent-verified)

Success criterion: full drift suite green before edits. The changes log records
169 passed / 0 failed at 2026-07-21T04:55:10Z. This is a historical claim about the
pre-edit tree and is not re-runnable now that Phases 1-5 have landed. Accepted on the
strength of the planning-session run recorded in the plan (plan line 14, same 169/0
figure, independently obtained the day before). Status: **Verified consistent**, not
independently re-executed — noted rather than overstated.

### Phase 6 (parent-verified)

Success criteria: full suite green, and `./install.sh --global` completes.

- Suite re-run by the parent at 2026-07-21T05:09:26Z: **207 passed, 0 failed**, exit 0.
  Matches the changes log claim exactly. The +38 delta over baseline is Tests 12 and 13.
- Installer effect verified by direct comparison rather than by trusting the recorded
  output summary. Sampled four files across all four synced categories:
  `.claude/commands/hve-doc-ops.md`, `.claude/commands/hve-memory.md`,
  `.claude/agents/hve-rpi-validator.md`, `.claude/prompts/rpi.md` — each byte-identical
  to its `~/.claude/` counterpart. The global install genuinely carries this task's edits.

Status: **Verified**.

## Phase Reviews

All five dispatched validators returned **Pass**. Per-phase detail:

| Phase | Validator verdict | Critical | Major | Minor | Output file |
|---|---|---|---|---|---|
| 1 | Pass | 0 | 0 | 0 | `unowned-file-remediation-phase-001-validation.md` |
| 2 | Pass | 0 | 0 | 1 | `unowned-file-remediation-phase-002-validation.md` |
| 3 | Pass | 0 | 0 | 1* | `unowned-file-remediation-phase-003-validation.md` |
| 4 | Pass | 0 | 0 | 1 | `unowned-file-remediation-phase-004-validation.md` |
| 5 | Pass | 0 | 0 | 2 | `unowned-file-remediation-phase-005-validation.md` |

\* Phase 3's validator tagged its RV-001 `[MAJOR]`. **Parent reclassified to Minor
(informational).** Rationale, recorded per the contested-severity rule: the finding's own
body concludes DD-004 is sound, the m-01 defect is fixed, and "no remediation needed." A
finding that confirms correct behavior and requests no change is not a Major defect. The
disagreement is recorded here rather than silently dropped.

**Step coverage: 100%.** Every plan step across Phases 1-5 was verified present in the
actual files. Canonical wording from the details doc matched verbatim in every case the
validators checked (Phase 1: 4 blocks; Phase 2: 2 blocks; Phase 3: 2 blocks; Phase 4: 2
blocks).

**Discarded validator claim.** Phase 2's validator recommended investigating "why Phase 1's
claimed hve-review.md edits don't appear in parent's git diff." The claim is false:
`.claude/commands/hve-review.md` is present in the parent-supplied changed-file list, and
Phase 1's validator independently confirmed the edits at lines 83 and 93. Not propagated.

### RV-101 (Major, parent-raised) — Test 13 does not cover the defect class it was built for

**This is the most consequential finding in the review and no validator escalated it.**

Plan Step 5.2 states Test 13 "catches the M-07/M-10 phantom-feature class mechanically."
That claim is false. Test 13 extracts flags with `grep -ohE '^- \`--[a-z-]+'`
(`tests/run-drift-tests.sh:824-825`). The original defects took these forms:

- **M-07** (`.claude/prompts/rpi.md`, pre-task state via `git show HEAD`):
  `` - `continue`: Mention "continue" to resume... `` and `` - `suggest`: ... `` — bare
  tokens with no `--` prefix.
- **M-10** (`.claude/prompts/checkpoint.md`, pre-task state): a `## Modes` section listing
  `- **Save**`, `- **Continue**`, `- **Update**` — bold mode names, not option lines at all.

Neither form matches the extraction anchor. Verified empirically: feeding the exact
original defect lines through Test 13's extraction pipeline yields only `--think`;
`continue` and `suggest` are invisible. Consequently the `checkpoint.md → hve-memory.md`
mapping matches zero lines and reports `no --flag option lines to check` — a **vacuous
pass**. One of Test 13's six mappings asserts nothing.

The implementor came within one inference of this. The Step 5.3 mutation protocol
specified re-adding `` - `continue` `` and observing a failure; that mutation could not be
made to fail, which is precisely the signal that the test does not cover M-07. The
implementor correctly diagnosed the mechanism ("`continue` has no `--` prefix"), then
substituted an invented `--resume` flag and recorded the whole thing as a protocol
footnote. The substituted mutation proves Test 13 *can* fail; it does not prove Test 13
catches the regression class it exists to catch. The mutation check worked exactly as
designed — the finding was filed in the wrong place.

Severity Major, not Critical: the 21 underlying defects were all fixed correctly, the
suite is green, and nothing is broken today. What is missing is durable protection against
recurrence — which was Phase 5's entire purpose. A future edit re-introducing
`- **Continue**:` to `checkpoint.md` would pass the suite silently.

Remediation: extend Test 13's extraction to cover bare-token and bold-token option lines
(or add a companion assertion for `## Modes`-style sections), then re-run the original
Mutation B from the details doc unmodified and confirm it fails.

## Quality Findings

Source: `unowned-file-remediation-quality.md` — Pass, 0 Critical, 2 Major, 3 Minor.
Security re-run independently by the validator; suite reproduced at 207/0.

### Q-201 (Major) — canonical-block drift coverage excludes `.claude/prompts/`

The per-project memory sentence is duplicated byte-identically at
`.claude/commands/hve-memory.md:87` and `.claude/prompts/checkpoint.md:25`. Test 10's
canonical-block corpus globs only `COMMANDS_DIR` and `AGENTS_DIR`
(`tests/run-drift-tests.sh:560`), never `PROMPTS_DIR`. **Parent-verified.** The command
copy is protected; the prompt copy is not, so the two can silently diverge.

This is the same drift class the task exists to eliminate, reintroduced by the task's own
remediation. Remediation: add `PROMPTS_DIR` to the corpus at line 560 and register the
memory-store sentence in `CANONICAL_BLOCK_SPECS`.

### Q-202 (Major) — `hve-rpi-validator.md:50` unlisted-changes scope is ambiguous

The instruction reads "Compare the parent-supplied changed-file list against the changes
log." A per-phase validator must resolve whether "the changes log" means the whole
document or only its own `### Phase N:` section. Under the phase-scoped reading, every
sibling phase's files appear "unlisted" and get false-flagged.

**Parent-verified as latent, not active.** Read in context
(`.claude/agents/hve-rpi-validator.md:44-51`), Step 2 is explicitly per-phase, which is
what creates the ambiguity — but none of the five validators in this run misfired on it.
Severity kept at Major because it would produce spurious Critical findings on the next
multi-phase `/hve-review`, and this task's own 5-phase log is a reproducing case.

Remediation: disambiguate to "against the entire changes log, not only this phase's
section."

### Minor quality findings (3, titles traceable to the quality output file)

- DRY: `.claude/agents/hve-rpi-validator.md:34-35` states the research-absent rule twice
  (paraphrase plus verbatim restatement) with no test keeping the pair in sync.
- Overall quality: `.claude/commands/hve-prompt-builder.md:61` retains stale "After both
  subagents complete" wording left over from the pre-fix parallel design — a residue of
  the exact sequencing defect Step 2.1 fixed.
- Documentation: `docs/internals.md:25` describes hve-prompt-evaluator's criteria without
  the Template Integrity criterion added at `.claude/agents/hve-prompt-evaluator.md:56-59`.

## Security Findings

**None.** Independently re-run by the quality validator and cross-checked against the
implementor's own Phase 6 record:

- No secret patterns (`PRIVATE KEY|api_key\s*=|password\s*=|-----BEGIN|Bearer `) across
  all 16 changed files.
- `.gitignore` hygiene intact: `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` all present.
- No new dependencies.
- Changed-file set matches the details-doc ownership map exactly — no unlisted changes in
  any phase.

Status: **Pass**.

## Record Consistency

Two un-annotated contradictions found in the changes log. Both are record-only defects
(the underlying implementation is correct in each case); per the command's record-only
corrections rule, the reviewer appends the dated Corrections rather than routing the task
back to `/hve-implement`.

### RC-001 (Minor) — Phase 4 note falsified by sibling phase, not annotated

`.claude-hve-tracking/changes/2026-07-20/unowned-file-remediation-changes.md:127` states:
"hve-memory.md:74 still says 'persists across projects' until sibling Phase 3 Step 3.5
lands its fix."

That claim was true when Phase 4 wrote it (Phases 3 and 4 ran concurrently) but is false
against the final tree. `.claude/commands/hve-memory.md:87` now carries the per-project
canonical wording. Phase 3 did land its fix. The claim was left standing without the
`superseded — see Correction YYYY-MM-DD` annotation the CLAUDE.md corrections convention
requires. Correction appended by this review.

### RC-002 (Minor) — Phase attribution error in Phase 5 mutation evidence

`.claude-hve-tracking/changes/2026-07-20/unowned-file-remediation-changes.md:208-209`
states: "Phase 1 had already replaced the original `continue`/`suggest` option lines in
`.claude/prompts/rpi.md`".

Phase 1 does not own `.claude/prompts/rpi.md`. The details-doc ownership map assigns that
file to Phase 4 (details doc line 22), and plan Step 4.1 is the step that deleted the
`continue`/`suggest` lines. The substantive reasoning in that passage is sound; only the
phase number is wrong. Correction appended by this review.

## Summary

Status: ⚠️ **Needs Rework**
Critical: 0 | Major: 3 | Minor: 10
Record consistency: ⚠️ Contradictions found — corrections appended by this review (resolved)

### Tally traceability

Every number traces to a validation output file or to a parent-verified finding in this log.

| Source | Critical | Major | Minor |
|---|---|---|---|
| Phase 1 validation | 0 | 0 | 0 |
| Phase 2 validation | 0 | 0 | 1 |
| Phase 3 validation | 0 | 0 | 1 (reclassified from Major) |
| Phase 4 validation | 0 | 0 | 1 |
| Phase 5 validation | 0 | 0 | 2 |
| Quality validation | 0 | 2 | 3 |
| Parent (this log) | 0 | 1 (RV-101) | 2 (RC-001, RC-002) |
| **Total** | **0** | **3** | **10** |

### Verdict rationale

Three Major findings exceeds the ≤ 2 threshold for ✅ Complete, so the verdict is
⚠️ Needs Rework. This should not be read as a poor implementation. The remediation work
itself is strong: all 21 targeted defects (12 Major, 9 Minor) were fixed, every plan step
verified present, canonical wording reproduced verbatim across five parallel implementors
with no cross-file drift, the suite moved 169 → 207 green, security clean, and the parent
caught and correctly reversed one plan-specified defect (DD-004) rather than implementing
it obediently.

What earns the rework verdict is narrower and specific: **the new test infrastructure does
not yet protect the classes it was built to protect.** Two of the three Majors (RV-101,
Q-201) are coverage gaps in Phase 5's own deliverable, and the third (Q-202) is an
ambiguity that would misfire on the next multi-phase review. The task's stated purpose was
to close drift gaps permanently; leaving these open would mean the same defect classes can
recur silently.

### Routing

Route to `/hve-implement` with these three remediations (all in scope, none requiring a
new plan):

1. **RV-101** — extend Test 13 to catch bare-token and bold-token phantom options; then run
   the details-doc Mutation B unmodified and confirm it fails.
2. **Q-201** — add `PROMPTS_DIR` to the canonical-block corpus (`tests/run-drift-tests.sh:560`)
   and register the memory-store sentence in `CANONICAL_BLOCK_SPECS`.
3. **Q-202** — disambiguate `.claude/agents/hve-rpi-validator.md:50` to name the whole
   changes log rather than the phase section.

Minor findings may be folded into the same pass or deferred. Two carry-forwards worth
resolving before merge regardless:

- **ShellCheck never ran** against the ~169 new bash lines (not installed in this
  environment). Flagged by both the Phase 5 validator and the implementor.
- **`./install.sh --global` already ran** (plan Step 6.2), so `~/.claude` currently carries
  the unreviewed state. Re-run it after remediation to re-sync.
