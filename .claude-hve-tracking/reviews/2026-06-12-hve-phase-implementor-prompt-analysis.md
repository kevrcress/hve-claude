# Prompt Analysis: hve-phase-implementor
Date: 2026-06-12
Target: `.claude/agents/hve-phase-implementor.md`
Type: agent
Context: Pre-implementation baseline for Changes #2, #3, and implementor-half of #4 from
`2026-06-12-hve-workflow-tightening-writeup.md`.

---

## Scoped Assessment

### Where deviation/discrepancy handling lives today

Current handling is thin and has no DR-/DD- vocabulary:

- **Lines 48–50** — the only "something went wrong" path. Framed purely as *blockers*
  (`missing file, conflicting pattern, ambiguous requirement`). A failing test that reveals
  undocumented behavior is not in this taxonomy. The instruction "Try to resolve it using
  existing code context" is what leads an implementor to edit an expectation until green.
- **Lines 79–80** — free-text `Issues Encountered` field. This is where deviations land,
  but there is no authority gate and no DR-/DD- structure.
- **Lines 100–106 (Constraints)** — scope discipline only (`Do not exceed the scope...`).
  No definition of when skipping a planned item is permitted.

DR-/DD- as a concept does not exist in this agent file.

### Text that currently licenses "fix the test" or self-ratified skips

No explicit license exists — the problem is the **absence of a prohibition** combined with
green-seeking pressure:

- **Line 49** — `Try to resolve it using existing code context` is the load-bearing
  license. Confronted with a failing test exposing undocumented behavior, this instruction
  reads as "make things consistent with what the code does" → adjust the expectation.
- **Lines 56–57** — `Verify each criterion is met... Are there obvious bugs?` orients
  the agent toward making things pass, with no carve-out that "a test passing because you
  rewrote its expectation" is not a met criterion.
- **Line 80** — `[Any blockers, deviations from plan, or unexpected findings]` lets a
  self-declared won't-fix be logged with zero authority test.

### Recommended insertion points

| Change | Primary insertion | Secondary |
|---|---|---|
| **#2 STOP-and-log-DR** | New rule block in Step 2, immediately after line 50 (parallel to blocker handling) | DR-/DD- subsection in Step 4 template (after line 78); one line in Constraints |
| **#3 two-prong won't-fix** | Constraints block (lines 100–106) as a hard rule | Step 4 template: require dated two-prong skip note in Issues Encountered |
| **#4 self-correction pass** | Step 3 — Validate, new substep after line 57 (before Step 4 Report) | Reference CLAUDE.md "superseded — see Correction YYYY-MM-DD" convention |

---

## Findings

### PA-001 [COMPLETENESS] [Major]
Issue: No rule prohibiting the implementor from adjusting a test expectation to match
observed-but-undocumented behavior (Change #2 gap). The blocker taxonomy omits this case.
Evidence: Lines 48–50 — `If you encounter an unexpected blocker (missing file, conflicting
pattern, ambiguous requirement): Try to resolve it using existing code context`
Fix: Insert after line 50 — "If a test failure reveals system behavior not covered by the
plan, research, or a spec, you MUST NOT edit the expectation to match observed behavior.
Log a DR- item in the changes log describing the undocumented behavior, surface it in
your response findings, and halt the step (or proceed only on parts not gated by the
discrepancy). Change an expectation only by citing a recorded DD- decision."

### PA-002 [ACTIONABILITY] [Major]
Issue: Implementor can self-ratify a skip/won't-fix with no authority criteria —
"deviations from plan" is a free log field (Change #3 gap).
Evidence: Line 80 `[Any blockers, deviations from plan, or unexpected findings]`;
Constraints (100–106) gate scope but never define when skipping a planned item is
permitted.
Fix: Add to Constraints — "You may unilaterally skip/won't-fix a planned item ONLY when
BOTH hold: (a) the deviation does not affect the functionality the user prompted for, AND
(b) the issue is Minor-grade. A dated skip note is mandatory. Anything failing either
prong: STOP, log, and return to the user. A won't-fix note must argue against the
finding's ORIGINAL criterion, not a substituted one."

### PA-003 [COMPLETENESS] [Major]
Issue: Step 3 Validate never re-reads the agent's own earlier changes-log claims, so a
self-contradicting record reaches Complete (Change #4 implementor-half gap).
Evidence: Lines 52–58 — validation scope is `Re-read the phase success criteria / Verify
each criterion / does the code follow existing patterns?`. No self-claim audit.
Fix: Add a Step 3 substep — "Before reporting Complete, re-read your own earlier claims
in the changes log and append a dated Correction for any falsified by later work (annotate
the stale claim in place: 'superseded — see Correction YYYY-MM-DD'). Do not silently
rewrite."

### PA-004 [COMPLETENESS] [Minor]
Issue: The Step 4 changes-log template has no structured home for DR-/DD- items or
Correction entries — inserting #2/#3/#4 content will push it into the catch-all
`Issues Encountered`.
Evidence: Lines 64–81 template has only `Files Modified`, `Steps Completed`,
`Issues Encountered`.
Fix: Add a `#### Discrepancies & Decisions (DR-/DD-)` subsection and a
`#### Corrections` subsection to the template.

### PA-005 [CLARITY] [Minor]
Issue: Terminology collision. CLAUDE.md defines `DR = Discrepancy from Research` (in plan
logs), but Change #2's DR- is for behavior discovered at implement time. Reusing the
prefix without a local definition will confuse reviewers.
Evidence: CLAUDE.md — `plans/logs/... (DR-/DD- items; DR = Discrepancy from Research,
DD = Design Decision)`. The writeup (lines 46–51) uses DR- for runtime-discovered
undocumented behavior.
Fix: When inserting #2, add a one-line gloss defining DR- in the implementor's context
(e.g., "DR- = discrepancy discovered during implementation"), or confirm with author that
the prefix is intentionally shared across both contexts.

---

## Quality Summary
Clarity: ✅ Pass (existing text is clear; PA-005 is a forward-looking naming caveat)
Completeness: ❌ Fail — PA-001, PA-002, PA-003
Actionability: ⚠️ — present instructions are executable; PA-002 lets agent improvise authority
Format compliance: ✅ Pass — frontmatter correct; 6-part response protocol matches CLAUDE.md
No Copilot-isms: ✅ Pass

Overall: ⚠️ 5 findings (0 critical, 3 major, 2 minor)

---

## Coordination Note
The writeup names `hve-phase-implementor` agent + `/hve-implement` command as joint targets
for Changes #2 and #3. This analysis covers the agent only. The command-side guidance (how
the parent handles a returned DR-, what it tells the implementor) must be updated in the same
pass, or the agent's new STOP behavior will have no parent-side receiver.
