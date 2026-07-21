# Planning Log: Friction Log Remediation

## Discrepancies

### DR-001: Research says review consolidation "covers Critical/Major only" but the fix must not fabricate Minor tallies
Source: research Cluster C (O-23) — Summary tallies Minors and routing has a Minor-only branch while consolidation instructions cover Critical/Major only
Resolution: Plan Step 5.3 keeps full-text consolidation for Critical/Major and adds count-plus-titles copying for Minors, sourced from validator output files; forbids any tally number not traceable to a validation file
Status: Resolved

### DR-002: Research recommends "grant constrained read-only git OR document parent-digest routing" for O-05; session decisions lock Option B only
Source: research Cluster G line 79 offers both options; memory decision 2026-07-17 locks Option B (parent runs shell, subagents stay read-only)
Resolution: Plan follows the locked decision everywhere (Steps 1.4, 2.3, 5.6; Block 9). No agent gains Bash
Status: Resolved

### DR-003: hve-research.md parent itself has no Bash, so "parent runs git" cannot happen inside /hve-research
Source: hve-research.md:4 allowed-tools = Read, Write, Glob, Grep, Agent (no Bash), vs. the parent-runs-shell rule
Resolution: Step 2.3 words the routing note honestly: within /hve-research, git-history evidence is limited to Glob/Grep-obtainable facts or flagged as an open question; other phases (which have Bash) supply digests. Adding Bash to hve-research.md was rejected to keep the research phase read-only
Status: Resolved

## Design Decisions

### DD-001: Friction artifact home and flag name
Source: Open question 1 (research :111) and memory open item "decide at plan time"
Assumption: `.claude-hve-tracking/friction/YYYY-MM-DD-phase-slug.md` (flat folder, date-prefixed filename) with flag `--friction-log` on all six dispatching commands
Risk: Flat folder diverges from the tree's date-subfolder pattern used elsewhere; accepted for grep-ability of a small file population

### DD-002: Timestamp fix uses `date -u` instruction rather than removing the fields
Source: F-06; hve-implement.md has Bash and hve-phase-implementor has all tools, so the value IS obtainable — the defect was the template never saying how
Assumption: instructing the exact command plus an explicit `N/A — no clock available` branch removes the fabrication incentive [HIGH]
Risk: An agent may still skip the command and invent a value; drift-test cannot catch runtime behavior — consumer-repo end-to-end check (Phase 9 follow-up) is the verification

### DD-003: Static consistency suite lands in this plan (Phase 8), not a follow-on
Source: memory open item 2 ("same plan or follow-on")
Assumption: drift tests are the locked protection mechanism for shipping fixes before dedup; deferring them would leave the 9-way/8-way copies unprotected during the highest-churn window
Risk: Adds scope; mitigated by reusing tests/lib/assert.sh patterns from commit 9b610f7

### DD-004: PR-review diff passed as a written diff.patch file, not pasted into prompts
Source: O-42 (diff duplicated verbatim into 8 prompts) + locked read-only-subagents decision
Assumption: subagents can Read the patch file; one write, eight reads [HIGH]
Risk: diff.patch is regenerable noise in a committed folder; implementation decides gitignore treatment and logs a DD- in the changes log (flagged in Step 6.4)

### DD-005: hve-pr-reviewer tools = Read, Write, Glob, Grep (no Bash)
Source: Block 9 parent-shell rule; parent supplies diff and git facts
Assumption: no PR-review dimension requires executing code; all eight are static-analysis dimensions [HIGH]
Risk: A dimension (e.g. functional correctness) might benefit from running tests; accepted — test execution stays in /hve-review's parent flow

### DD-006: Dimension ID prefixes replace IV-NNN in PR review only
Source: O-38; IV- collision across 8 parallel reviewers
Assumption: /hve-review keeps IV- (single-validator context, no collision); only hve-pr-review adopts FC-/DA-/II-/RL-/PS-/RO-/SC-/DO- [HIGH]
Risk: Two ID schemes coexist; mitigated by the CLAUDE.md Finding ID note staying authoritative for IV- scope

### DD-007: `--friction-log` boilerplate is the fourth drift-tested copy set
Source: New duplicated block introduced by this very plan (6 copies)
Assumption: without a test it would drift exactly like the copies this remediation fixes
Risk: none beyond test maintenance

## Validation

(hve-plan-validator findings appended below by the validator)

### DR-004: WebFetch guidance does not fully address O-06 platform limitation
Source: Research Cluster G line 80 (O-06 "partly platform limitation") and Step 2.4 WebFetch guidance
Gap: Plan acknowledges O-06 is a platform limitation but only adds guidance; the underlying limitation (3-URL cap, raw-URL discovery) remains unresolved at the platform level
Severity: Minor
Recommendation: Step 2.4 is correct — fix the guidance (what we control) and document the limitation (what we cannot). This is already done via Block 22 and Step 2.4 wording.
Status: Resolved (plan correctly addresses the guidance-fixable portion)

### DD-008: Template-blank principle enforcement in /hve-prompt-builder deferred to follow-on
Source: Memory decision line 15 ("add to prompt-authoring conventions so /hve-prompt-builder enforces it")
Assumption: Step 1.3 adds the principle to CLAUDE.md conventions and notes it as a check the tool should enforce; actual modification of /hve-prompt-builder to implement enforcement is out of scope for this remediation task [MEDIUM]
Risk: The principle exists in conventions but the prompt-builder tool is not updated to check it in THIS task. However, the principle is now a standing convention that future tool updates can reference. Consumer-repo follow-up (Phase 9 Step 9.3) will surface any drift.
Severity: Minor
Status: Open (acceptable as deferred; convention is locked, enforcement is future work)

### DD-009: Assumption about internals.md table pre-existence not independently verified
Source: Step 6.8 assumption "internals.md lists agents in a table with a Model column" [HIGH]
Assumption: The file docs/internals.md exists and already has an agents roster table; Step 6.8 will add hve-pr-reviewer to this existing table [HIGH]
Risk: If internals.md does not exist or lacks the expected table, Step 6.8 will need to create it; still achievable but requires implementation decision. Drift test group 2 will surface the mismatch.
Severity: Minor
Status: Resolved — parent verified post-validation: docs/internals.md has the agent table with a Model column (rows at docs/internals.md:20-27, checked via `grep -n "hve-" docs/internals.md` on 2026-07-17); Step 6.8 adds a row to an existing table
