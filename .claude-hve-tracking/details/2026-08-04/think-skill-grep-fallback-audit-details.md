# Implementation Details: think-skill-grep-fallback-audit
Date: 2026-08-04

This task has no data flow, schema, or API surface — both bugs are single-line wording fixes in markdown prompt/agent files. No expanded technical detail beyond what the plan checklist already contains.

## Source of truth for exact replacement text

Both fixes were sourced from directly diffing this machine's installed `~/.claude` copies against the repo copies during planning, rather than being re-authored:

```
diff ~/.claude/commands/hve.md .claude/commands/hve.md
diff ~/.claude/commands/hve-plan.md .claude/commands/hve-plan.md
diff ~/.claude/commands/hve-research.md .claude/commands/hve-research.md
diff ~/.claude/agents/hve-researcher.md .claude/agents/hve-researcher.md
```

Each produced exactly one differing line, quoted verbatim in the plan's Phase 1/Phase 2 steps. This confirms the `~/.claude` copies contain no other undiscovered drift beyond the two bugs already known from research — if there were additional differences, the diff output would have shown more than one changed line per file.

## Why no separate fallback note in `hve.md`

`.claude/commands/hve.md` Phase 1 ("Research") reads, in full, as of this plan's writing:

```
### Phase 1 — Research

Execute the research protocol from `/hve-research` inline (do not call the slash command — follow the same steps):

1. Define research questions (3–7 specific unknowns)
2. Spawn `hve-researcher` subagents in parallel (one per research theme), passing each an output path under `.claude-hve-tracking/research/subagents/YYYY-MM-DD/TASK-SLUG-THEME.md`
3. Wait for all to complete
4. Read each subagent's file from `subagents/YYYY-MM-DD/`
5. Consolidate findings to `.claude-hve-tracking/research/YYYY-MM-DD/TASK-SLUG.md`
```

There is no "Use Glob and Grep" orientation instruction here to attach a fallback clause to — the orchestrator delegates that step to the spawned `hve-researcher` subagent, which Phase 2 Step 2.2 already fixes. Adding a fallback note to `hve.md` itself would be dead text with nothing to modify.

## Rollback

Each edit is a single-line string replacement with no dependent changes elsewhere (confirmed: no test pins the old wording, no other doc cites these line numbers). Reverting is a plain `git revert` of the implementation commit; no migration or cleanup required.
