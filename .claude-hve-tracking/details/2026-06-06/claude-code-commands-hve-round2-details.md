# Implementation Details: Claude Code Commands Integration with HVE (Round 2)
Date: 2026-06-06
Task slug: claude-code-commands-hve-round2
Plan: .claude-hve-tracking/plans/2026-06-06/claude-code-commands-hve-round2-plan.md

---

## Phase 1 Details

### Step 1.1 -- /goal entry in CLAUDE.md Context Management

Find the "Context Management Between Phases" section in CLAUDE.md. After the existing bullet list, add a new subsection or paragraph. Target prose (adapt to fit surrounding style):

```
**Unattended execution with `/goal`:** For Challenging tasks, set a completion condition before starting `hve-implement` so Claude keeps working across turns without prompting:

/goal all implementation phases complete and npm test exits 0 and security check passes or stop after 20 turns

The evaluator runs on Haiku after every turn and judges from the conversation transcript only -- it cannot read files. Make the condition provable via tool output (test exit codes, status lines) rather than file state. Always include "or stop after N turns" to prevent runaway loops.
```

The entry must include the transcript-only caveat with a concrete explanation. The evaluator is Haiku running after each turn -- it reads the conversation transcript only, and cannot open files or run commands. This means:

* Good condition: "npm test exits 0" -- Claude runs `npm test` and the output appears in chat; Haiku reads it.
* Bad condition: "all linting issues resolved" -- if Claude doesn't show linter output in chat, Haiku cannot verify it and may declare success incorrectly.

Include this explanation in the CLAUDE.md entry (not just in these details). Suggested phrasing:

> The evaluator reads the conversation transcript only -- it cannot open files or run commands itself. Write conditions that require Claude to show proof in the transcript (test output, exit codes, status lines). A condition like "tests pass" only works if Claude actually runs the tests and the output appears in the conversation.

Important notes for implementor:
- No em-dashes; use colons or commas
- The `/goal ...` line should be in a fenced code block so it reads as copy-pasteable
- Place AFTER the existing bullet list in Context Management, BEFORE the Handoff Block section
- Keep under 15 lines including the caveat

### Step 1.2 -- /btw tip in CLAUDE.md Context Management

In the same "Context Management Between Phases" section, add a bullet to the existing bullet list (or immediately after it if the list has ended):

```
* Use `/btw` for quick clarifying questions during a session -- they are not added to conversation history and do not affect subagent context.
```

Place this BEFORE the `/goal` paragraph added in Step 1.1.

### Step 1.3 -- /simplify row in Command Reference table

Find the Command Reference table in CLAUDE.md. Add a new row after the `/hve-review` row (or at the end of the table if ordering by purpose):

| `/simplify` | Automated cleanup pass: reuse, simplification, efficiency, abstraction level -- 4 parallel agents, no bug hunting | After `hve-review` passes, before committing |

Note: the table has three columns: Command, Purpose, When to use. Match that format exactly.

### Step 1.4 -- /rewind row in Command Reference table

Add a new row to the Command Reference table, logically near `/hve-implement`:

| `/rewind` | Roll back code on disk and conversation to a prior checkpoint | Recovery if an `hve-implement` phase corrupts files or a phase goes wrong |

---

## Phase 2 Details

### Step 2.1 -- /goal suggestion block in hve-implement.md

Read `.claude/commands/hve-implement.md` in full first.

Find the Phase 1 (Plan Analysis) section. After the step that reads the plan and builds the dependency graph (before "Create the changes log file"), add a new callout block:

```markdown
**Optional: unattended execution.** If you want Claude to keep working without per-turn prompts, suggest the user set a `/goal` condition now, before the first subagent is spawned:

```
/goal all implementation phases complete and tests pass and security check clean or stop after 20 turns
```

Replace "tests pass" with the project's actual test command result. Once the user sets the goal (or confirms they don't want it), proceed with subagent dispatch.
```

Important notes:
- This is a suggestion to relay to the user, not an action Claude takes autonomously
- Keep it clearly optional ("If you want...")
- Place it AFTER reading the plan but BEFORE spawning any subagents
- No em-dashes

### Step 2.2 -- Transcript-legible phase completion in hve-implement.md

Find the Phase 3 (Consolidation) section in `hve-implement.md`. Look for the step that asks Claude to "Present a summary to the user."

Ensure that summary instruction explicitly lists:
- "Phases completed: N/N" (literal string so Haiku evaluator can detect it)
- Test results summary: "Tests: X passed, Y failed" or "Tests: all pass"
- Security check result: "Security: clean" or "Security: N issues found"

If the current instruction already includes these strings, no change needed (note that in the changes log). If they are vague or absent, add explicit instruction:

"When presenting the summary, begin with the following status line exactly as shown so automated goal evaluators can detect completion: `Implementation complete. Phases: N/N. Tests: [result]. Security: [result].`"

---

## Open Questions Resolved

**Q1: Should /goal integrate into hve-implement as a flag, or as a user-pattern in CLAUDE.md?**
Decision: both. Add a `/goal` suggestion block inside `hve-implement.md` (so the command proactively informs users about the option) AND document it in CLAUDE.md Context Management (so it appears in the reference). The command doesn't parse a flag -- it simply surfaces the suggestion.

**Q2: /fork, /ultraplan, /background -- in scope?**
Decision: out of scope. Not documented in this plan.

**Q3: /rewind placement in CLAUDE.md?**
Decision: Command Reference table as a separate row, near `hve-implement`. Separate row keeps the table consistent and scannable.
