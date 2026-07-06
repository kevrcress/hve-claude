# Challenge: HVE Workflow Tightening (5 Prompt Changes)
Date: 2026-06-12
Artifacts reviewed:
- .claude-hve-tracking/research/2026-06-12/hve-workflow-tightening.md
- .claude-hve-tracking/plans/2026-06-12/hve-workflow-tightening-plan.md
- .claude-hve-tracking/details/2026-06-12/hve-workflow-tightening-details.md
- .claude-hve-tracking/changes/2026-06-12/hve-workflow-tightening-changes.md
- .claude-hve-tracking/reviews/rpi/2026-06-12/hve-workflow-tightening-review.md (incl. re-review)
- .claude-hve-tracking/reviews/rpi/2026-06-12/hve-workflow-tightening-phase-002-validation.md

## Identified Challenge Areas

1. **Enforcement is asserted, never exercised.** The task's premise is "rules that aren't
   checked get ignored," and the fix is paired checker-side prompt text. But every
   verification recorded (the 5 greps, the rule-pairing cross-checks) confirms the *text
   exists*, not that a validator presented with a violating artifact actually flags it. The
   phase-002 revalidation explicitly lists "Functionality testing of validator behavior with
   actual plan violations" as out of scope. The checkers are themselves unchecked rules.

2. **The corrections convention generates churn it cannot prevent.** In a single day, the
   changes log's `file:line` citations rotted twice (Phase 1's gate cite, Phase 2's cites
   after IV-005), producing three Correction entries. CLAUDE.md's own new citation convention
   says `file:line` rots silently after the first edit — yet changes logs continue citing
   live files by line, with annotation-after-the-fact as the only remedy. Why not apply the
   snapshots-vs-symbols insight to the changes log itself?

3. **Severity is fixed by category, not by what the violation masks.** Record-consistency
   contradictions are always Minor (hve-review.md step 4, hve-rpi-validator.md item 5). But a
   contradiction like "no build environment available" vs. "executed 47 tests" could conceal
   a fabricated verification claim — Critical territory. No artifact justifies the categorical
   Minor grade.

4. **The two-prong won't-fix rule trusts the implementor's own severity grading.** Prong (b)
   requires the issue be "Minor-grade," graded by the same agent that wants to skip the work.
   No checker validates the grade; the rpi-validator checks consistency, not severity honesty.

5. **Dimension 11's procedure may not scale or even apply to this repo's "symbols."** The
   Grep procedure (basename sweep → symbol existence) assumes citing docs reference
   `Class.Method`-style symbols. This repo's living docs cite dimension counts and prose —
   the one real catch (IV-001, "10-dimension") was a *count* mismatch the procedure as
   written wouldn't obviously find. The validator's miss of docs/internals.md:24 (caught by
   the parent's grep instead) suggests the procedure underperformed on its first run.

## Question Log

### Q1 — Enforcement vs. presence (challenge area 1)

**Q:** How do you know the checker-side rules will change validator behavior when a real
violation appears, given that the only verification performed was confirming the rule text
exists — and what would falsify the claim that these checks are "enforced" rather than merely
written down?

**A (user):** Add test cases for this; not sure there is any other way to enforce.

**Discussion:** Agreed — behavioral fixtures are the only real enforcement, and the repo
already has the harness (hve-prompt-builder + hve-prompt-tester/evaluator, sandbox/). The
shape that falsifies the claim:

- One violation fixture per rule (unearned "verified" plan → expect DD-; un-annotated
  changes-log contradiction → expect RV- / gate refusal; renamed symbol cited by living doc
  → expect Minor IV-). Pass criterion = expected finding ID + severity pointing at the
  planted violation, not prose matching.
- Stochastic validators (haiku) → run each fixture N times with a pass threshold (e.g. 4/5);
  treat as an eval re-run on validator-prompt change, not a CI gate.
- Negative fixtures equally required: clean artifacts must NOT trip findings. IV-002 (the
  review's dismissed false positive) shows over-flagging is a live failure mode; a paranoid
  validator gets ignored as fast as a decorative rule.

**Status:** Open follow-on — fixture suite not yet built. The "enforced" claim remains
unfalsified until a violation fixture runs (and could fail).
