# Checkpoint / Memory Reference

> Invoke with `/hve-memory [topic-slug]` to save session context for future conversations.

## What it does

Save is the only operation: the command captures current state, decisions, open questions, and next steps to a memory file. It then prints the exact instruction to paste into the next session to resume — continuing is that printed instruction, not a selectable mode. There is no update path; re-running the command writes a fresh memory file.

## When to use

- Ending a session before the task is complete
- After a significant architectural decision
- When context in the conversation would be expensive to re-derive next session

## Output

`.claude-hve-tracking/memory/YYYY-MM-DD/topic-slug.md` containing:
- Decisions made and why
- Failed approaches (do not retry)
- Open questions
- Next steps (ordered)
- Key file locations
- Tracking artifact paths

Also write the most non-obvious decisions and patterns to the Claude Code native memory store for this project (`~/.claude/projects/<project-slug>/memory/`). The store is per-project, not global: entries written here surface only in future sessions on this same project.

## To resume

In the next conversation: "Read `.claude-hve-tracking/memory/YYYY-MM-DD/topic-slug.md` and continue from the next steps."
