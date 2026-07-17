# Planning Log: Upstream Drift Adoption + Judgment-Layer Sections
Date: 2026-07-12
Task slug: upstream-drift-judgment-layer

## Discrepancies

### DR-001: June 2026 upstream window unverified
Source: Research §1 (June commit window could not be closed; weak [LOW] signal June was quiet; exact stable tag string unresolved, compare view 404s)
Resolution: Plan proceeds on observed drift only. Follow-on item (research follow-on #1) resolves the tag and fetches the compare view before the next drift review. If June held methodology changes, the Adopt list may grow; that becomes a new task, not an amendment to this plan.
Status: Open (accepted risk)

### DD-001: Re-plan escalation endpoint is recommend-to-user
Source: Research Open Question 4 and constraint 6 (upstream auto-escalation conflicts with the port's wait-for-user convention)
Assumption: The user prefers keeping every routing decision at the user checkpoint, consistent with hve-implement.md step 6 and the self-graded-authority constraint.
Risk: Slower loop on genuinely invalid plans (one extra user touch). If the user prefers agent-initiated re-planning, Phase 5 Steps 5.2-5.3 need rewording before implementation.
Status: Resolved (design decision; flag to user at checkpoint for confirmation)

### DD-002: Difficulty classification persists into artifact frontmatter
Source: Research Open Question 3 (research recommendation: yes; precondition for enforceable ceremony scaling)
Assumption: A one-line `Difficulty:` frontmatter field with decided/inferred provenance is sufficient; no schema change to any consumer.
Risk: Template edits touch 4-5 files; installer propagation covers all of them (.claude/ paths), so no install-time gap expected.
Status: Resolved (adopted research recommendation)

### DD-003: `--mode` semantics on /hve-plan and /hve-implement undecided
Source: Research Open Question 1 (hve-implement.md:3 advertises `--mode` but the body never parses it; hve-plan.md:35 honors it with mismatched vocabulary)
Assumption: None made. User said "not sure yet, will review later" (2026-07-12 session).
Risk: Step 6.6 cannot be implemented in either direction without the decision. Blocked step is isolated so the rest of Phase 6 proceeds.
Status: Open (BLOCKS plan Step 6.6; surface to user during implementation)

### DD-004: Medium-Hard "extra plan validation" undefined
Source: Research Open Question 2 (hve.md:31 and the CLAUDE.md difficulty table promise it; implemented nowhere)
Assumption: None made. User said "not sure yet, will review later" (2026-07-12 session).
Risk: Step 6.7 cannot be implemented (define vs delete) without the decision. Blocked step is isolated.
Status: Open (BLOCKS plan Step 6.7; surface to user during implementation)

### DD-005: Ceremony canonical home is hve.md Phase 0
Source: Research follow-on #3 (decide canonical home before drafting) and patch-target map row (d)
Assumption: hve.md Phase 0 is where classification is actually executed, so rules live there; CLAUDE.md, README.md, docs/workflow.md become short cross-references. CLAUDE.md keeps the difficulty table itself (it propagates on install and other surfaces already point at it).
Risk: CLAUDE.md is the only doc surface guaranteed to propagate with full text; if a cross-reference is too thin for installed projects, the implementor should widen the CLAUDE.md text, not duplicate the rules.
Status: Resolved (adopted research recommendation)
