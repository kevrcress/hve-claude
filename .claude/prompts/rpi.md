# RPI Workflow Reference

> Invoke the full Research → Plan → Implement → Review loop with `/hve <task-description>`.

## Arguments

- `task`: The primary task description
- `--mode lightweight|standard|full`: Override difficulty-adaptive routing
- `--think`: Activate extended reasoning during planning (auto-enabled for Challenging tasks and `--mode full`)
- `--subagent-model sonnet|opus|haiku`: Override each subagent's frontmatter model for this run

## Phases

1. **Research** → `.claude-hve-tracking/research/YYYY-MM-DD/task-slug.md`
2. **Plan** → `.claude-hve-tracking/plans/YYYY-MM-DD/task-slug-plan.md`
3. **Implement** → `.claude-hve-tracking/changes/YYYY-MM-DD/task-slug-changes.md`
4. **Review** → `.claude-hve-tracking/reviews/rpi/YYYY-MM-DD/task-slug-review.md`
5. **Discover** → 3–5 follow-on items suggested at the end

## Resuming

To resume mid-task in a new conversation:
1. Note the handoff artifact path from the previous session's Handoff Block
2. Run the appropriate standalone phase command (`/hve-plan`, `/hve-implement`, `/hve-review`)
3. The command will discover the existing artifacts automatically

## See also

- `/hve-research` — Phase 1 standalone
- `/hve-plan` — Phase 2 standalone
- `/hve-implement` — Phase 3 standalone
- `/hve-review` — Phase 4 standalone
- `/hve-memory` — Save session context for resumption
