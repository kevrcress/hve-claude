# Planning Log: Phase-Ending Clarity (Thread B)
Date: 2026-08-19
Plan: .claude-hve-tracking/plans/2026-08-19/phase-close-clarity-plan.md

## Discrepancies

### DR-001: Research cited stale test counts
Source: Research A3 cites the 2026-08-15 review's figures, drift 248/0 and install 66/0.
Resolution: The parent re-ran both suites during planning on 2026-08-19 and measured drift 255
passed / 0 failed and install 69 passed / 0 failed. The plan uses the measured figures as its
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
test-14 mechanism directly (tests/run-drift-tests.sh:959, :965): the pointer form
``per CLAUDE.md's `Completion Summary` section`` resolves against any `##`-level heading with no
test edit.

### DD-004: Enum alternatives live in prose, never in the template
Source: Not in the research. Found during planning by reading the live templates.
Assumption: A template line containing `|` will be copied verbatim into emitted output.
Risk: This is the bug being fixed, reintroduced through the back door. hve-pr-review.md:189-190
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
Status: Open
