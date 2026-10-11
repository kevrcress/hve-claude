# Planning Log: CLAUDE.md Lean Restructure

Date: 2026-08-19
Task slug: claude-md-lean-restructure
Research: .claude-hve-tracking/research/2026-08-19/claude-md-lean-restructure.md
Plan: .claude-hve-tracking/plans/2026-08-19/claude-md-lean-restructure-plan.md

## Discrepancies

### DR-001: Research line estimate is optimistic

Source: research RQ5, "payload shrinks from 386 to roughly 300-310 lines".
Detail: recounting the removals against the actual file gives Hooks 23 lines (317-339 including the
separator), Installing 26 (341-366), tracking-policy relocation net about -9 (382-385 leaves, 368-380
moves rather than leaves), preamble about -4. That is roughly -62 from a measured baseline of 387
payload lines, landing near 325, not 300-310. The Command Reference change is character-level, not
line-level: rows shrink from 393/377/294/288/274/233 characters but stay one line each.
Resolution: the plan states the target as a bound (at most 340 payload lines, at least 3,000 characters
smaller than the measured 23,106) rather than a point estimate, and Phase 7 measures rather than asserts.
Status: Resolved

### DR-002: "Payload shrinks from 386 lines" vs the measured 387

Source: research RQ5 size outcome.
Detail: `awk '/^## Your Project/{exit} {print}' CLAUDE.md | wc -l` prints 387, not 386. The off-by-one
is the `---` separator at CLAUDE.md:387 that awk prints before hitting the heading at 388.
Resolution: the plan records 387 / 23,106 characters as the measured baseline, with the command that
produced it. Immaterial to any decision, recorded so Phase 7's delta arithmetic starts from a real
number.
Status: Resolved

### DR-003: The tracking-tree duplication was never verified

Source: research follow-on, "Verify docs/reference.md's tracking tree matches CLAUDE.md:78-103 before
declaring either copy canonical".
Detail: compared at plan time. The trees are structurally identical; `docs/reference.md:6-33` adds
`(gitignored)` annotations on `subagents/` and `sandbox/`, a "Prompt builder runs" note, and slightly
different column alignment. Neither is stale relative to the other.
Resolution: both copies are kept and the plan lists deduplication as out of scope. CLAUDE.md's copy is
operational (agents write to these paths); `docs/reference.md`'s is the human-browsed one.
Status: Resolved

## Design decisions

### DD-001: The false "full = parallel validation" claim is knowingly retained

Source: locked decision 3 (user, 2026-08-19), resolving research Open Question 3.
Assumption: `.claude/commands/hve-plan.md:41` says a complex plan gets "full planning with parallel
validation", and `README.md:124` restates it, while `.claude/commands/hve-plan.md:131` dispatches
exactly one `hve-plan-validator` subagent sequentially. The claim is false today; the parallel-validation
feature was deferred by the user on 2026-08-15.
Decision: leave both files unchanged until the feature lands. Slimming the Command Reference (Phase 3)
removes the same false clause from CLAUDE.md:44 as a side effect, so after this task the claim survives
only in `.claude/commands/hve-plan.md:41` and `README.md:124`.
Risk: CLAUDE.md stops carrying the claim, which could read as the discrepancy having been fixed. The
user's condition was that it stay durably documented; it is recorded here, in the research doc's PA-004
verdict, and in session memory (`feature-hve-plan-parallel-validation`).
Status: Accepted, deliberate

### DD-002: `-` bullets retained against markdown.md:16

Source: locked decision 5 (user, 2026-08-19), resolving research Open Question 4.
Assumption: `.claude/instructions/markdown.md:16` mandates `*` for unordered lists; CLAUDE.md uses `-`
throughout, as does most of the repo's markdown.
Decision: keep `-`. Converting would rewrite every list line in the file for zero functional gain and
would bury the substantive diff.
Risk: a future doc-ops or PR review flags the divergence as a finding. Mitigated by recording it here
and in the details file's authoring-conventions section.
Status: Accepted, deliberate

### DD-003: The global install is ahead of the repo, observed but not addressed

Source: noticed during plan-time verification of DD-001.
Assumption: `wc -l .claude/commands/hve-plan.md ~/.claude/commands/hve-plan.md` gives 174 and 201
respectively, and `grep -n "Step 3a\|Parent compiles"` matches only the global copy
(`~/.claude/commands/hve-plan.md:131, :156`). The globally-installed `/hve-plan` carries a "Step 3a, Parent compiles what the plan
specifies" section that this repo's source copy does not have.
Decision: out of scope for this task, which touches CLAUDE.md and `docs/` only. Recorded because it
contradicts the working assumption that `~/.claude` is a marker-managed mirror synced by
`./install.sh --global`: the mirror cannot be ahead of the source unless it was hand-edited or synced
from elsewhere.
Risk: if a future `./install.sh --global` runs, it overwrites the global copy with the repo's shorter
version and the Step 3a content is lost. Worth resolving before the next global sync, as its own task.
Status: Open, deferred

### DD-004: Mid-Flow Scope Changes protection is adjacent scope, included deliberately

Source: research RQ5 disposition 10, marked "[MEDIUM, adjacent scope]".
Assumption: `grep -rn "Requirements added after" .claude/ CLAUDE.md` returns exactly one hit,
CLAUDE.md:259, and `grep -rn "Mid-Flow" .claude/` returns nothing. The section is a sole copy that no
command implements and no test protects. Deleting it during a restructure would be silent, and no phase
command currently reads the `## Requirements added after <phase>` section the convention prescribes.
Decision: Phase 6 adds the ``per CLAUDE.md's `Mid-Flow Scope Changes` section`` pointer to
`.claude/commands/hve-implement.md` and `.claude/commands/hve-review.md`, which both implements the
behavior and brings the heading under test 14.
Risk: it grows the diff into `.claude/commands/` and changes the drift-test passing count from 255 to
256 or 257, an intentional delta that must be recorded in the changes log or a later reviewer reads it
as drift. Phase 6 is independent of Phases 1-5 and can be dropped whole if the user prefers a
CLAUDE.md-only diff.
Status: Accepted, drop-able

### DD-005: The tracking-policy subsection keeps its `###` heading rather than being folded into prose

Source: research RQ5 disposition 5, "absorb the gitignore policy lines from :368-386 so the :76 forward
anchor dies naturally".
Assumption: CLAUDE.md:76 links to `#tracking-folder--version-control`, whose target is the
`### Tracking folder & version control` heading at CLAUDE.md:368. `grep -rn "tracking-folder"
--include="*.md" .` outside the tracking folder returns only CLAUDE.md:76 and `docs/reference.md:40`,
and the latter links to README's anchor, not CLAUDE.md's.
Decision: move the subsection intact to sit directly under `## Tracking Folder Structure`, keeping the
`###` heading byte-identical so the anchor slug stays valid, and separately simplify CLAUDE.md:76 to
drop the now-pointless forward link. Folding the policy into flat prose would have destroyed the anchor
for no size gain.
Risk: low. The heading is not pointer-referenced by any test, so even a rename would not red the suite;
keeping it is the conservative choice.
Status: Accepted

### DD-006: Plan-time compile evidence is structural simulation, not a build

Source: the `/hve-plan` Step 3a requirement to compile every verbatim artifact the plan specifies.
Assumption: this repo has no compiler, package manager, or CI. The plan's "verbatim artifact" is the
restructured CLAUDE.md, and the tools that consume it are `install.sh` and the two bash suites.
Decision: rather than skip the step, the parent ran four real checks before dispatching the validator,
each recorded with its command and output in the plan and reproduced in the validator prompt: the two
suites at baseline, a simulation of test 14's pointer resolution against the proposed heading set, and a
simulation of `install.sh:171`'s awk extraction against a structural mock of the restructured file.
Risk: the mock carries headings and stub bodies, not final prose, so it proves the structure extracts
and the pointers resolve; it does not prove the final wording is correct. Phase 7 re-runs the real
suites against the real file, which is the check that could actually fail.
Status: Accepted
