# RPI Validation: Unowned-File Convention Remediation — Phase 1
Date: 2026-07-20
Plan phase: Validator/parent contract fixes (M-01, M-05, M-06, placeholder Minor)
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 1.1 (M-01, parent): git diff dispatch input | Found | `.claude/commands/hve-review.md:83,93` | ✅ Implemented |
| Step 1.2 (M-01, agent): unlisted-changes check and N/A branch | Found | `.claude/agents/hve-rpi-validator.md:23,50,90-91` | ✅ Implemented |
| Step 1.3 (M-05): research-absent branch in both validators | Found | `.claude/agents/hve-plan-validator.md:18,34`; `.claude/commands/hve-plan.md:134` | ✅ Implemented |
| Step 1.4 (M-06): conditional research-absent Pre-requisite item 4 | Found | `.claude/agents/hve-rpi-validator.md:34-35` | ✅ Implemented |
| Step 1.5 (placeholder Minor): write-after-load Pre-requisite item 1 | Found | `.claude/agents/hve-rpi-validator.md:31` | ✅ Implemented |

## Findings

### Canonical Wording Verification

All required canonical wording was implemented exactly as specified in the details document:

**Unlisted-changes check** (`.claude/agents/hve-rpi-validator.md:50`):
Exact match to details doc line 39-40: "Compare the parent-supplied changed-file list against the changes log. Any file on the list but absent from the log is an unlisted change; grade per severity. If the parent supplied no list, do not infer one." [HIGH]

**Template N/A branch** (`.claude/agents/hve-rpi-validator.md:90-91`):
Exact match to details doc lines 44-47 structure with placeholder lines for both cases (parent-supplied list, no list supplied). [HIGH]

**Research-absent branch** (rpi-validator `.claude/agents/hve-rpi-validator.md:34-35`):
Exact match to details doc line 56-58: "If the parent reports research as absent (plan header reads `Research: none — [reason]`), skip requirement extraction. Record in the output: 'Validated against the plan alone; research was recorded absent at planning time.' Do not manufacture requirements the research never stated." [HIGH]

**Research-absent branch** (plan-validator `.claude/agents/hve-plan-validator.md:34`):
Canonical wording present with additional scope instructions for DR-/DD- log handling (appropriate for this agent). [HIGH]

**Parent-side changed-file digest** (`.claude/commands/hve-review.md:93`):
Exact match to details doc lines 52-54: "Changed-file list: output of `git diff --name-only <base>` run by the parent (the parent chooses `<base>`: the merge-base with main for branch review, or `HEAD` for uncommitted work)". Placed correctly in dispatch-inputs list at line 93. [HIGH]

### Success Criteria Verification

All three success criteria from the plan (line 31) are met:

1. **rpi-validator's unlisted-change check names a parent-supplied input**: Confirmed at `.claude/agents/hve-rpi-validator.md:23` (Your Assignment) and line 50 (instruction). [HIGH]

2. **Both validator bodies carry a research-absent branch**: Confirmed in rpi-validator at lines 34-35 and plan-validator at line 34. [HIGH]

3. **`git diff --name-only` hits in the dispatch-inputs block**: Confirmed at `.claude/commands/hve-review.md:93` within the "Each subagent receives:" section. [HIGH]

### Self-Validation Note

This validation document is produced by the `hve-rpi-validator` agent defined at `.claude/agents/hve-rpi-validator.md`. The file on disk carries all required changes at the cited lines. The agent body now includes the research-absent branch that was added in Step 1.4, enabling this validator to correctly handle tasks where research is absent.

## Unlisted Changes

The parent-supplied changed-file list contains these Phase 1-owned files (from git diff):
- .claude/agents/hve-plan-validator.md ✓
- .claude/agents/hve-rpi-validator.md ✓
- .claude/commands/hve-plan.md ✓
- .claude/commands/hve-review.md ✓

All four Phase 1-owned files appear in the changes log. No unlisted changes detected.

## Research Coverage

Research document path supplied: `.claude-hve-tracking/research/2026-07-20/unowned-file-remediation.md`

Key research findings addressed by Phase 1:

- **M-01** (rpi-validator emits false assurance on unlisted-change detection): Resolved by Steps 1.1–1.2. Parent now passes `git diff --name-only` output; agent instruction updated to compare parent-supplied list; template N/A branch added so absence of changes is no longer misread as "zero unlisted changes".

- **M-05 / M-06** (both validators hard-require research that CLAUDE.md permits to be absent): Resolved by Steps 1.3–1.4. Both validators now carry research-absent branches that allow validation to proceed when research is absent (recorded as "Validated against the plan alone").

- **Placeholder Minor** (rpi-validator creates placeholder before content): Resolved by Step 1.5. Pre-requisite item 1 now requires the validation document to be written only after Load Context succeeds, or with explicit `Status: Blocked` header if blocked mid-run.

All Phase 1 research findings are met [HIGH].

## Summary

**Coverage**: 5 implemented steps / 5 total steps = 100%

**Status**: **Pass** — all plan items implemented, canonical wording verified exactly, all success criteria confirmed, no contradictions or falsified claims detected, no unlisted changes for Phase 1.

All changes align with the research findings and successfully close three Major defects (M-01, M-05, M-06) and one Minor issue (placeholder-first).
