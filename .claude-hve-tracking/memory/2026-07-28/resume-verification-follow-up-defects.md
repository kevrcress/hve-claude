# Session Memory: Follow-up defects from resume-claim verification
Date: 2026-07-28
Session type: review
Task slug: resume-verification-follow-up-defects

## Decisions Made
- Verified the resume description of this repo claim-by-claim against the code; most claims held. Both test suites were executed and passed fully (drift and install).
- The resume wording was revised in-session to fix three overstatements: security is default-on but skippable via a PR-review dimension filter, the correction protocol is supersede-and-correct rather than append-only, and section-ownership rules forbid rather than mechanically prevent silent overwrites. The friction-flag causality was also corrected: ad hoc logs drove the remediation, and the flag was built as an output of that remediation.

## Failed Approaches
- None. This was a verification session, not implementation.

## Open Questions
- [ ] Should `/hve-pr-review --dimension <x>` force a security floor (always run the security dimension alongside the requested one), or is a single-dimension run intentionally scoped and the verdict rules should instead note the partial coverage?
- [ ] Is the `--mode` flag on `/hve-review` meant to do anything, or should it be removed from parsing and the argument-hint?

## Next Steps
- [ ] Fix DEFECT 1: `/hve-pr-review --dimension <non-security>` runs a severity-graded review with zero security coverage. The flag is declared at `.claude/commands/hve-pr-review.md:3` and `:22`, but Phase 2 only specifies dispatch for the `all` case (`:89`), and the verdict rules at `:145-148` (including the security-Critical block rule) apply to the partial review with no guard. Decide on a security floor or an explicit partial-coverage annotation.
- [ ] Fix DEFECT 2: dead flag. `/hve-review` parses `--mode` at `.claude/commands/hve-review.md:19` (also in the argument-hint at `:3`) but never references MODE again anywhere in the file. The Simple carve-out at `:79` keys off task grade, not the flag. Either wire the flag up or remove it.
- [ ] Fix DEFECT 3: internal contradiction in `hve-implementation-validator`. `.claude/agents/hve-implementation-validator.md:20` offers single-dimension scopes (architecture, design-principles, ...) that a caller could set to a non-security scope, contradicting `:152` "Always run the security dimension checks - never skip them". No command currently invokes it that way, but the agent contract permits it.
- [ ] Optional DEFECT 4 (design gap, lower priority): the changes-log section-ownership rule (four verbatim carriers: `.claude/commands/hve-implement.md:109`, `.claude/agents/hve-phase-implementor.md:48`, `.claude/commands/hve.md:107`, `CLAUDE.md:320`) has no enforcement hook. Neither `hve-rpi-validator` nor `hve-implementation-validator` checks for ownership violations. Consider adding a review-side check for cross-section edits or whole-file writes of the changes log.
- [ ] When fixing 1-3, keep the drift tests in mind: test 6 asserts the friction block across exactly six commands and test 13 asserts prompt-file options resolve to command options, so argument-hint edits ripple into `tests/run-drift-tests.sh` expectations and `.claude/prompts/` twins.

## Key Files
- `.claude/commands/hve-pr-review.md:3` - `--dimension` flag declaration (DEFECT 1)
- `.claude/commands/hve-pr-review.md:89` - dispatch specified only for `--dimension all` (DEFECT 1)
- `.claude/commands/hve-pr-review.md:145` - verdict rules that assume full coverage (DEFECT 1)
- `.claude/commands/hve-review.md:19` - `--mode` parsed, never used (DEFECT 2)
- `.claude/commands/hve-review.md:79` - Simple carve-out keyed off task grade, not the flag (DEFECT 2)
- `.claude/agents/hve-implementation-validator.md:20` - single-dimension scope option (DEFECT 3)
- `.claude/agents/hve-implementation-validator.md:152` - "never skip" security constraint it contradicts (DEFECT 3)
- `tests/run-drift-tests.sh` - drift suite; flag or prompt edits must not break tests 6 and 13

## Tracking Artifacts
- Research: none - verification session; findings live in this memory file, not a research artifact
- Plan: none
- Changes: none

## Context Notes
This session verified resume-description claims for the repo (branch `feature/hve-interview-command`, though the work was read-only and branch-independent). All claims were checked with file:line evidence; both test suites pass as of 2026-07-28 (drift and install, zero failures). The three numbered defects above were found in passing during that verification and are not yet on any branch or plan. DEFECT 1 is the most substantive because it silently weakens a documented guarantee (the mandatory security dimension in PR reviews). Per Kevin's standing branch-discipline rule, fix these on a new branch, not on a branch he is actively testing.
