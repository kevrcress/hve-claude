# Memory: Deferred Feature Candidates from Unowned-File Remediation

Date: 2026-07-20
Task slug: unowned-file-remediation (source task; these are follow-on candidates)
Origin: DD-003 in .claude-hve-tracking/plans/logs/2026-07-20/unowned-file-remediation-log.md

## Context

The unowned-file audit found prompt files promising two features their commands never implemented. The remediation plan aligns the prompts down to actual behavior (drift fix, not feature work). Kevin confirmed on 2026-07-20 that both features are worth building later as separately planned tasks, each through its own RPI loop.

## Candidate 1: PR-description generation in /hve-pr-review

- What was promised: after a review, generate a PR description template on request ("Generate a PR description based on this review").
- Where the promise lived: .claude/prompts/pull-request.md:33-35 (removed by the remediation, Phase 4 Step 4.2).
- What exists today: hve-pr-review.md Phase 4 is finalize-only (consolidate findings, emit verdict).
- Shape of the work: new phase or post-verdict step in hve-pr-review.md that drafts a PR description from the review's findings and the diff summary; prompt file re-documents it once real.
- Suggested slug: pr-description-generation

## Candidate 2: Update mode for /hve-memory

- What was promised: a mid-session "Update" mode refreshing the current memory file with new state (alongside Save and a selectable Continue).
- Where the promise lived: .claude/prompts/checkpoint.md:6-9 (aligned down by the remediation, Phase 4 Step 4.3).
- What exists today: hve-memory.md takes [topic-slug] only; Save is the sole operation; Continue is a printed next-session instruction.
- Shape of the work: detect an existing same-slug memory file for today and update it in place rather than overwriting; decide whether Continue should become a real mode while in there.
- Suggested slug: hve-memory-update-mode

## Next steps (ordered)

1. Finish the unowned-file-remediation implementation first; these candidates assume the aligned-down prompts as the starting state.
2. When picking either up: run /hve-research <candidate>, treating this file as prior context, then plan as normal.
3. Re-add prompt-file documentation only after the command implements the feature (Test 13 will enforce the flag subset of this automatically once Phase 5 lands).

## Key file locations

- .claude/commands/hve-pr-review.md (candidate 1 target)
- .claude/commands/hve-memory.md (candidate 2 target)
- .claude/prompts/pull-request.md, .claude/prompts/checkpoint.md (re-document after implementation)
- .claude-hve-tracking/plans/2026-07-20/unowned-file-remediation-plan.md (Phase 4 removes the promises)
