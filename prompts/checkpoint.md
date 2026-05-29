# Checkpoint / Memory Reference

> Invoke with `/hve-memory [topic-slug]` to save session context for future conversations.

## Modes

- **Save** (default): Captures current state, decisions, open questions, and next steps
- **Continue**: Read `.claude-hve-tracking/memory/YYYY-MM-DD/topic.md` to resume from a previous session
- **Update**: Refresh the current memory file mid-session with new state

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

## To resume

In the next conversation: "Read `.claude-hve-tracking/memory/YYYY-MM-DD/topic-slug.md` and continue from the next steps."
