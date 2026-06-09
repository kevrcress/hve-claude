# Research: Claude Code Commands Integration with HVE (Round 2)
Date: 2026-06-06
Task slug: claude-code-commands-hve-round2
Confidence: HIGH overall

## Summary

Seven newly-documented Claude Code commands have meaningful integration potential with HVE. The highest value are `/goal` (condition-driven multi-turn loops, directly applicable to `hve-implement`), `/btw` (side questions that deliberately skip history, ideal for HVE's context discipline), and `/rewind` (roll back code and conversation as a safety net for failed implement phases). `/simplify` complements `hve-review` as a cleanup-only pass. `/fork`, `/ultraplan`, and `/background` require a design decision about whether HVE documents cloud/async primitives at all.

---

## Key Findings

### /goal -- Condition-Driven Multi-Turn Loops

- Evaluator fires after every turn: sends condition + full conversation transcript to Haiku; returns yes/no + reason; "no" gives Claude guidance for next turn [HIGH] -- https://code.claude.com/docs/en/goal
- Evaluator sees transcript only, not files -- conditions must demand Claude prove success via tool output in the transcript, not just claim it [HIGH] -- https://code.claude.com/docs/en/goal ("does not call tools")
- Hard requirements: Claude Code v2.1.139+, trust dialog accepted, hooks not disabled (`disableAllHooks` or `allowManagedHooksOnly` break it) [HIGH] -- https://code.claude.com/docs/en/goal ("Requirements")
- Best HVE fit: `hve-implement` -- run `/goal all phases complete and tests pass and security check reports no issues` before starting implement; loop exits when condition is met [MEDIUM]
- Dangerous misuse: using `/goal` to loop back into code-fixing without a review phase violates HVE's separation-of-concerns (Implementor and Reviewer are distinct roles) [MEDIUM] -- .claude/commands/hve-implement.md, hve-review.md
- Runaway mitigation: always include "or stop after N turns" clause; ambiguous conditions loop indefinitely [HIGH] -- https://code.claude.com/docs/en/goal ("turn or time clause")
- Complements auto mode: auto mode removes per-tool prompts within a turn; `/goal` removes per-turn prompts between turns; together they enable unattended work [HIGH]
- Non-interactive: `claude -p "/goal CONDITION"` runs the loop to completion in a single CLI invocation; goals resume with `--resume` [HIGH]
- Example HVE conditions:
  1. `all implementation phases complete and npm test exits 0 and security check passes or stop after 20 turns`
  2. `review log status is Complete and no Critical findings and no Major findings or stop after 25 turns`
  3. `all hve-research subagents complete and consolidated findings doc written or stop after 10 turns`

### /btw -- Side Questions Without History Bloat

- `/btw <question>` asks a side question that explicitly does not add to conversation history [HIGH] -- https://code.claude.com/docs/en/commands
- Direct fit for HVE's context discipline principle: mid-session clarifying questions during a long orchestrator run won't contaminate the context that subagents inherit [HIGH]
- Recommended CLAUDE.md placement: Context Management section ("Use `/btw` for quick clarifying questions during a session -- they don't affect subagent context") [MEDIUM]

### /rewind -- Code and Conversation Rollback

- Rolls back both code on disk and conversation to a prior checkpoint; also supports summarizing from a selected message [HIGH] -- https://code.claude.com/docs/en/commands ("Rewind the conversation and/or code to a previous point")
- Viable safety net if `hve-implement` corrupts files or a phase goes wrong -- user can `/rewind` to before the phase started [HIGH]
- Recommended CLAUDE.md placement: either a "Recovery" subsection in Context Management, or a note after the `hve-implement` command row in the Command Reference [MEDIUM]

### /simplify -- Cleanup-Only Review (No Bug Hunting)

- Runs 4 parallel cleanup agents (reuse of existing helpers, simplification, efficiency, abstraction level); applies fixes automatically [HIGH] -- https://code.claude.com/docs/en/commands
- As of v2.1.154, explicitly does NOT hunt for correctness bugs; that is `/code-review`'s job [HIGH]
- Orthogonal to `hve-review`: `hve-review` validates plan adherence and finds bugs; `/simplify` is a post-review cleanup pass [HIGH]
- Recommended usage pattern: run `/simplify` after `hve-review` passes, before committing; not a replacement for `hve-review` [MEDIUM]
- Recommended CLAUDE.md placement: note alongside `hve-review` in the Command Reference ("After review passes, run `/simplify` for automated cleanup") [MEDIUM]

### /fork -- Conversation-Inheriting Subagent

- Spawns a background subagent that inherits the full conversation context; result returns to parent conversation when done [HIGH] -- https://code.claude.com/docs/en/commands (v2.1.161+)
- Fundamentally different from HVE's Agent tool subagents, which receive only what you explicitly pass -- forks are cheaper for context-continuation tasks [HIGH]
- Cannot nest: a forked subagent cannot spawn further forks [HIGH]
- HVE use case: forking a side investigation (e.g., "research this one corner case while I continue the main plan") without interrupting the main session [MEDIUM]
- Design question: whether to document as a power-user complement or leave out of CLAUDE.md entirely [LOW]

### /ultraplan -- Browser-Based Planning

- Drafts a plan in a browser-based ultraplan session with richer review UI (inline comments, reactions); plan can be teleported back to terminal or executed remotely [HIGH] -- https://code.claude.com/docs/en/commands
- Complementary to `hve-plan`, not a replacement: ultraplan is better for collaborative review (multiple stakeholders); `hve-plan` is better for artifact-producing solo RPI loops [MEDIUM]
- Requires Anthropic cloud; not available on Bedrock/Vertex [HIGH]
- Design question: whether HVE should document cloud-dependent tools at all [LOW]

### /background -- Session Detachment

- Detaches the current session to run as a background agent, freeing the terminal; session persists and can be reattached with `claude agents` [HIGH] -- https://code.claude.com/docs/en/commands
- Could free the terminal during a long `hve-implement` run; user can check progress asynchronously [MEDIUM]
- Subagents spawned before detaching do not transfer; new ones spawn in the background session [HIGH]
- Lower HVE value: `hve-implement` already manages phases via subagents and waits at checkpoints; background mode adds complexity without clear gain for typical use [MEDIUM]

---

## Codebase References

.claude/commands/hve.md
.claude/commands/hve-implement.md
.claude/commands/hve-review.md
CLAUDE.md

---

## External References

- https://code.claude.com/docs/en/goal
- https://code.claude.com/docs/en/commands

---

## Prioritized Recommendations

### High value -- do these
1. **Document `/goal` in CLAUDE.md** with HVE-specific example conditions and the transcript-only evaluator caveat. Add to the Context Management section and note the "or stop after N turns" requirement. Do not integrate into command frontmatter -- document as a user pattern.
2. **Document `/btw` in CLAUDE.md** Context Management section as the recommended way to ask clarifying questions without contaminating subagent context.
3. **Document `/rewind` in CLAUDE.md** as a recovery mechanism for failed `hve-implement` phases.

### Medium value -- worth doing
4. **Document `/simplify` alongside `hve-review`** in the Command Reference as a post-review cleanup step. Distinguish it from `hve-review` (cleanup vs. validation).

### Lower value -- design decision required
5. **`/fork`**: document as a power-user complement if HVE embraces Claude Code's async ecosystem; skip if HVE stays purely RPI-focused.
6. **`/ultraplan`**: mention in CLAUDE.md only if cloud/collaborative workflows are in scope.
7. **`/background`**: probably not worth documenting; adds complexity without clear HVE gain.

---

## Open Questions

1. Should `/goal` integrate INTO `hve-implement` as an optional flag (e.g., the command instructs the user to set a goal before starting), or is it better documented as a standalone user pattern in CLAUDE.md?
2. Does HVE's design scope include cloud/async primitives (`/ultraplan`, `/background`, `/fork`), or should CLAUDE.md stay focused on the pure RPI methodology?
3. Where does `/rewind` go structurally in CLAUDE.md -- a note after the Command Reference table, a new "Recovery" subsection, or inline with the implement row?

## Recommended Research Follow-On

- [ ] Verify `/btw` behavior: confirm the side question is truly invisible to subsequent Agent subagent prompts (not just soft-excluded)
- [ ] Test `/rewind` with a real `hve-implement` run to confirm it restores files correctly, not just conversation
- [ ] Decide HVE scope question (Open Question 2) before planning -- it gates items 5-7 above
