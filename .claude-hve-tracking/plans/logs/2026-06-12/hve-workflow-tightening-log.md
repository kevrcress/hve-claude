# Planning Log: HVE Workflow Tightening
Date: 2026-06-12
Plan: .claude-hve-tracking/plans/2026-06-12/hve-workflow-tightening-plan.md

## Discrepancies

### DD-001: Corrections convention placement in CLAUDE.md
Source: Writeup #4 says "Convention (CLAUDE.md)" without naming a section
Assumption: A new `## Corrections in Tracking Artifacts` section between Confidence Markers and
Citation Format is the right home (it is a tracking-artifact convention, peer to those two)
Risk: Low — placement is editorial; installer merges CLAUDE.md wholesale
Status: Open

### DD-002: hve-implement.md added as an 8th target file
Source: Implementor analysis coordination note — "the command-side guidance must be updated in
the same pass, or the agent's new STOP behavior will have no parent-side receiver"
Assumption: The user's "HVE command and agent files" scope includes hve-implement.md even though
the writeup's target list names only the agent + command jointly for #2/#3
Risk: Low — writeup itself names "/hve-implement command" as a joint target for #2 and #3
Status: Resolved (writeup text supports it)

### DD-003: /think wording fix is in scope
Source: Review report PA-005 marks it "pre-existing, not part of Change #4"
Assumption: Opportunistic one-line fix is within "apply the five changes" scope since we are
editing adjacent lines anyway
Risk: Low — single phrase; flagged here so the user can veto
Status: Open

### DD-004: Dimension 11 also flags new bare file:line citations in living docs
Source: Writeup #5 convention half; impl-validator report only requires the symbol-existence check
Assumption: Checking the convention's author-side half (no new bare line citations in living docs)
belongs in the same dimension — otherwise the CLAUDE.md convention has no enforcer
Risk: Low — Minor severity; aligns with the task constraint that every rule gets a check
Status: Open

### DR-001: Testing verification procedure unspecified for rule-presence checks
Source: Plan line 98: "every author-side rule confirmed to have its checker-side twin, and...
every author-side rule confirmed to have its checker-side twin" — stated in passive voice without
adjacent grep commands or file:line citations specifying WHICH rules will be grepped or WHERE
Gap: The Testing Approach (lines 95-100) asserts verification will occur ("grep for the rule
phrases") but does not name the exact rule text to search for, which files to search in, or
the runnable command. This makes the claim "confirmed to have its checker-side twin" unearned
(violates the new hve-plan.md rule from Change #1 that forbids "confirmed"/"verified" without
adjacent evidence of the producing check).
Recommendation: Either (a) replace "confirmed to have its checker-side twin" with a procedural
sentence: "Each of the 5 changes will be verified by running `Grep 'rule-phrase-1' .claude/agents/hve-plan-validator.md` and recording the output in the changes log (and similarly for rules 2–5)"; or (b) move the rule-pairing claim to the review phase (post-implementation) where actual verification commands can be recorded. The plan itself cannot assert outcomes before implementation.
Severity: Major
Status: Resolved 2026-06-12 — Testing Approach rewritten with five named per-pair grep commands
(each falsifiable by a no-match) and the rule-pairing claim deferred to the review log next to
recorded output.

### DD-005: Unearned "verified" claim in Testing Approach
Source: Plan line 100: "no 'verified' claims without the producing check"
Assumption: This is a principle statement describing the NEW rule (from Change #1) that will be
enforced by the plan-validator going forward, not a claim about the current plan
Risk: Medium — readers may interpret this as "this plan has no unverified claims," which is
contradicted by DR-001. The wording is ambiguous.
Recommendation: Rephrase to be unambiguously forward-looking: "After this change is applied, no
'verified' claims [in future plans] may be written without the producing check."
Severity: Minor
Status: Resolved 2026-06-12 — sentence removed in the Testing Approach rewrite; replaced by the
explicit command list, so there is no ambiguous principle statement left to misread.
