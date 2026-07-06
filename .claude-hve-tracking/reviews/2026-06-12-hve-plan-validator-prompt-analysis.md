# Prompt Analysis: .claude/agents/hve-plan-validator.md

Date: 2026-06-12
Type: agent
Context: Change #1's acceptance check from the HVE workflow tightening writeup
(`2026-06-12-hve-workflow-tightening-writeup.md`, repo root) lands in this agent:
flag any "confirmed/verified" in a plan not adjacent to a command or file:line
citation, and flag plan-step assumptions missing confidence markers.
Status: DOCUMENTED ONLY. Not yet fixed.

---

## Where validation dimensions are enumerated

The agent's checks live in one place: the `## Validation Protocol` section, split
into three ordered steps:

- **Step 1: Requirements Coverage** (research-to-plan coverage; emits `DR-`)
- **Step 2: Discrepancy Validation**, a bulleted checklist: Scope gaps, Scope creep,
  Assumption risk, Dependency errors (emits `DR-`/`DD-`)
- **Step 3: Completeness Check** (success criteria, testable output, no
  underspecified steps)

Step 2's bullet list is the canonical enumeration point for "things the validator
inspects in the plan itself." Both of Change #1's checks belong there as two new
bullets beside the existing four. Not Step 1 (research coverage) and not Step 3
(phase success criteria).

---

## Findings

### PA-001 COMPLETENESS [MAJOR]
Issue: Change #1's second check ("flag any plan-step assumption missing a confidence
marker") has no enforcement, even though CLAUDE.md already requires the marker.
Step 2's "Assumption risk" bullet only tells the validator to mark its own `DD-`
entry `[LOW]`; it never instructs it to flag plan steps lacking a
`[HIGH]/[MEDIUM]/[LOW]` marker. The writeup calls this out: "CLAUDE.md already
requires this; the plan command does not enforce it."
Evidence (line 39): `**Assumption risk**: plan steps that assume things not verified in research (mark [LOW] confidence)`
Fix: Add a distinct bullet to Step 2: "**Missing confidence markers**: every key
assumption in a plan step MUST carry `[HIGH]/[MEDIUM]/[LOW]` (CLAUDE.md). Flag any
plan-step assumption lacking a marker as a `DD-` item." Keep "Assumption risk"
separate; it grades the risk, this new bullet checks the marker's presence.

### PA-002 COMPLETENESS [MAJOR]
Issue: Change #1's first check ("flag any 'confirmed'/'verified' not adjacent to a
command or file:line citation") has no home anywhere in the protocol. This is the
check that would have caught the build-breaking Step 2.1 ("...confirmed from
[TestBase.cs]..." on a 3-of-9 sample). Genuinely new behavior, not a
refinement of an existing bullet.
Evidence: No string `confirm`, `verif`, or "earned claim" appears anywhere in the
agent file.
Fix: Add a bullet to Step 2: "**Unearned verification claims**: flag any
'confirmed'/'verified' in a plan not immediately adjacent to the evidence that
produced it (the exact command run, or file:line citation). The cited check must be
one that could have failed: a compile, a test run, or a grep whose predicate targets
the claim itself. Emit as a `DD-` item with Severity scaled to what the unverified
claim gates."

### PA-003 CLARITY [MINOR]
Issue: The `DR-`/`DD-` output taxonomy (lines 60-74) doesn't cleanly absorb either
new finding. `DR-` is "Discrepancy from Research" and `DD-` is keyed on
`Source: [Plan step that makes an unverified assumption]` with `Assumption:`/`Risk:`
fields. An unearned "confirmed" claim isn't strictly an unverified assumption; it's
an unsupported assertion, so PA-002 findings get shoehorned into a `DD-` template
that doesn't quite fit.
Evidence (lines 68-73): `### DD-001: [Title]` / `Source: [Plan step that makes an unverified assumption]` / `Assumption:` / `Risk:`
Fix: Either (a) explicitly state both new checks emit as `DD-` items and broaden the
`DD-` template wording from "unverified assumption" to "unverified assumption or
unearned verification claim," or (b) add a one-line note that PA-002 findings reuse
`DD-` with the offending sentence quoted in `Assumption:`. Option (a) is cleaner and
keeps the two-type taxonomy intact.

### PA-004 ACTIONABILITY [MINOR]
Issue: The 7-finding response cap and the new checks interact unstated. With two new
dimensions feeding `DD-` items, a marker-heavy plan could generate many findings;
the agent should prioritize PA-002-style findings (unearned claims gating
functionality) over bulk marker-omission noise when trimming.
Evidence (line 84): `3. Up to 7 bullet-point findings (<= 240 chars each; lead with Critical items)`
Fix: No new text strictly required ("lead with Critical items" covers it), but
consider noting that unearned claims gating build/test outcomes outrank cosmetic
missing-marker findings when both are Minor.

---

## Quality Summary

Clarity: warning (PA-003), taxonomy ambiguity for the new finding types
Completeness: fail (PA-001, PA-002), both Change #1 checks absent or under-enforced
Actionability: pass (PA-004 is a nicety, not a blocker)
Format compliance: pass (frontmatter, response protocol, severity grading all correct)
No Copilot-isms: pass

Overall: 4 findings (0 critical, 2 major, 2 minor)

---

## Landing plan (when ready to fix)

Both checks land in **Step 2: Discrepancy Validation** as two new bullets beside the
existing four. The missing-marker check (PA-001) is a sibling of the existing
"Assumption risk" bullet; the unearned-claim check (PA-002) is net-new. Both emit
`DD-` items, which means the `DD-` output template (PA-003) needs a one-line
widening so the entries have a clean slot. No changes belong in Step 1 or Step 3.

Fix path: `/hve-prompt-builder .claude/agents/hve-plan-validator.md` for an
iterative fix cycle, or apply directly as part of the Change 1-5 batch via `/hve`.
