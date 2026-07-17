# Implementation Details: Upstream Drift Adoption + Judgment-Layer Sections
Date: 2026-07-12
Task slug: upstream-drift-judgment-layer
Plan: .claude-hve-tracking/plans/2026-07-12/upstream-drift-judgment-layer-plan.md

Expanded specs for the plan's harder steps. Draft text below is a starting skeleton, not final copy: the implementor should adapt voice to the surrounding file and keep the repo's existing formatting conventions.

## Phase 1: research template additions (Steps 1.1-1.2)

Insert into the consolidated research template in hve-research.md, between `## Summary` and `## Key Findings`:

```markdown
## Scope and Success Criteria
In scope: [what this research covers]
Out of scope: [explicitly excluded areas]
Success looks like: [the condition under which the downstream plan can be judged sufficient]

## Recommended Approach
[Exactly ONE recommended approach per technical scenario, with rationale.
If alternatives were considered, name them and say why they lost.
The Plan phase may diverge only with a logged DR- explaining why.]
```

Checker wording for hve-plan-validator Step 1 (Step 1.3): add to the extraction list, "If the research document lacks a Scope and Success Criteria section or a Recommended Approach section, emit a DR- item: Major when the plan chooses an approach the research never recommended, Minor when the plan is otherwise consistent with findings."

## Phase 2: review validation execution (Steps 2.1-2.2)

New step in hve-review.md, before verdict synthesis:

- Detect runnable checks in priority order: project test runner scripts (tests/run-*.sh here), then lint/build/test entries in the project's own tooling (package.json scripts, Makefile targets, etc.).
- Run each; record in the review log a table of `command | exit code | one-line outcome`.
- Never fix failures during review; a failing check is a finding (Critical if it blocks the plan's success criteria, Major otherwise).

Verdict gate wording: "✅ Complete additionally requires the Validation Runs table to be present and all recorded checks passing, or a dated note that the project defines no runnable checks."

## Phase 3: difficulty persistence (Steps 3.1-3.3)

Frontmatter line format, identical across artifacts:

```
Difficulty: Simple | Medium | Medium-Hard | Challenging (decided YYYY-MM-DD by /hve Phase 0 | inferred by /hve-<phase>)
```

Read rule for standalone commands: discover the newest artifact for the task slug (same discovery walk they already do), read `Difficulty:`, carry it into the artifact they produce. If absent, infer from the existing complexity assessment and mark `(inferred)`. The `(decided ...)` vs `(inferred ...)` suffix is what makes provenance observable per constraint 5.

## Phase 4: plan-completeness bar (Step 4.1 skeleton)

```markdown
### Plan-Completeness Bar

A plan is complete when all four hold:
1. Executability: a separate implementor could execute every step without asking a question. Any step failing this is underspecified; fix it or split it.
2. No open Critical or Major DR- items in the planning log.
3. Every phase has a success criterion that a validator could check and find unmet.
4. Every research requirement (including the Recommended Approach) maps to at least one step, or carries a logged won't-cover decision.

Scale depth to the persisted Difficulty: Simple tasks get a single-phase plan;
do not add phases a smaller classification would not need.

Validation is bounded: at most 2 validator rounds. Critical/Major items still
open after round 2 go to the user, not a third round.
```

Checker mapping (Step 4.4): hve-plan-validator Step 3 gains one check per clause, graded: clause 1 violations Major, clause 2 is already the existing gate, clause 3 violations Major, clause 4 violations Critical when the unmapped requirement is functional.

## Phase 5: re-plan triggers (Steps 5.1-5.4 skeleton)

Trigger list (all observable facts, constraint 5):

```markdown
### Re-Plan Triggers

Recommend a re-plan (never initiate one) when any of these observable facts occurs:
- A build or test failure reveals behavior the plan, research, and specs do not cover
- A file, dependency, or interface the plan assumed present does not exist
- A validator raises a Critical or Major DR- against the plan itself
- A plan step cannot be executed as written (not merely inconveniently)

Threshold: one trigger contained inside the current phase = log the DR-, halt
the affected step, continue unaffected steps (existing behavior). A trigger that
invalidates a cross-phase dependency, or a second trigger against the same plan
phase, = STOP and recommend re-plan in your response.

The recommendation goes to the user via the parent command; the endpoint is
always the user (DD-001). Cite the triggering fact verbatim.
```

Plan immutability (Step 5.4): amendments only via /hve-plan, appended as `Amendment (YYYY-MM-DD): [what changed and which trigger caused it]` with the superseded step annotated in place, mirroring the CLAUDE.md corrections convention. Implementors and reviewers treat the plan file as read-only.

rpi-validator rule (Step 5.5): "For each STOP or re-plan recommendation in the implementor's chat response, verify a matching DR- entry exists in the changes log citing the same fact. For each Amendment in the plan, verify a matching trigger event exists in the changes log. Mismatch = Major finding."

## Phase 6: phase-skip and ceremony scaling (Steps 6.1-6.2 skeleton)

Phase-skip criteria (canonical in hve.md Phase 0):

```markdown
Skipping a single phase is safe only when ALL hold for that phase's input artifact:
- it exists for the same task slug
- it postdates the last change to the code it describes (compare artifact date to git log on the cited files)
- its Open Questions section contains nothing the skipped phase was supposed to resolve
Otherwise run the phase. Skipping is never chained: skipping two consecutive phases means the task should re-enter at the earlier one.
```

Ceremony scaling additions to Phase 0: borderline classification takes the higher ceremony; reclassification during a task moves upward only, is triggered by the Phase 5 trigger list, and is recorded in the changes log with the triggering fact; downward reclassification requires the user. Upstream's risk-tolerance idea lands as one sentence of guidance ("choose ceremony by blast radius, not effort estimate"), not as new mode knobs.

## Fixtures (Steps 1.4, 3.4, 4.5, 5.6)

Each fixture is a minimal artifact pair (input doc + expected findings) under tests/fixtures/, exercised by the existing runner pattern in tests/lib/. One fixture per new checker rule:
1. research doc missing Recommended Approach -> plan-validator emits DR-
2. plan missing Difficulty frontmatter -> plan-validator emits Minor DD-
3. plan with untestable success criterion -> plan-validator Step 3 emits Major
4. changes log missing the DR- for a claimed STOP -> rpi-validator emits Major

## DD-001 rationale (endpoint decision)

Upstream auto-escalates ("the workflow escalates back to research or planning"). The port's convention is wait-for-user at every discrepancy (hve-implement.md step 6). Auto-escalation would let an agent judge its own plan invalid and act on that judgment, which is exactly the self-graded-authority loophole constraint 5 closes. Decision: agents recommend, the user routes. Cost: one extra user touch per re-plan; acceptable given the port's checkpoint philosophy.
