# Implementation Details: Claude Code Slash Commands and Features for HVE Integration
Date: 2026-06-06
Task slug: claude-code-slash-commands-hve
Plan: .claude-hve-tracking/plans/2026-06-06/claude-code-slash-commands-hve-plan.md

---

## Phase 1 Details

### Step 1.1 — hve-challenge Write fix

Current line 4 of `.claude/commands/hve-challenge.md`:
```
allowed-tools: Read, Glob, Grep
```

Target:
```
allowed-tools: Read, Write, Glob, Grep
```

The command body (Phase 2) explicitly creates `.claude-hve-tracking/challenges/YYYY-MM-DD-TOPIC-challenge.md` and updates it each turn. `Write` is required for initial creation; subsequent updates also require `Write` (or `Edit`). Adding `Write` resolves the mismatch.

Note: `Edit` is not listed either. If the command uses Edit to append Q&A turns, `Edit` should also be added. The implementor should check the Phase 4 update step and add `Edit` if needed.

### Step 1.2 — hve-research Bash removal

Current line 4 of `.claude/commands/hve-research.md`:
```
allowed-tools: Read, Write, Glob, Grep, Bash, Agent
```

Target:
```
allowed-tools: Read, Write, Glob, Grep, Agent
```

Rationale: `hve-research` dispatches file searches via Glob and Grep, and spawns `hve-researcher` subagents via Agent. The Bash tool is not used in any documented step. Removing it tightens the permission surface without losing functionality. If the command body contains any Bash calls, those should be converted to Glob/Grep equivalents first — implementor should scan for `Bash` usage in the file body.

---

## Phase 2 Details

### Step 2.1 — CLAUDE.md effort documentation

Target location: under the "Difficulty classifications" table, add a paragraph:

```markdown
**Effort level:** For Challenging-difficulty tasks, increase reasoning depth by passing `--effort xhigh` on the CLI or setting `effortLevel: xhigh` in `.claude/settings.json`. This extends the model's internal reasoning budget, improving plan quality and review thoroughness at higher token cost.
```

### Step 2.2 — CLAUDE.md /batch entry

Target location: Command Reference table. Add row after `/hve-challenge`:

| `/batch` | Split a large change into 5–30 worktree-isolated subagents, each opening a PR | Mass refactoring outside the RPI loop |

---

## Phase 3 Details

### --think flag behavior

`/think` is a Claude Code built-in that triggers extended thinking (chain-of-thought). It is prepended as a prose instruction at the start of the targeted reasoning step — not as a frontmatter key.

**Pattern for hve-plan Phase 2:**
Add at the top of the Phase 2 "Planning" section body:
```
If `--think` was passed in `$ARGUMENTS`, begin Phase 2 by invoking `/think` to reason through the task complexity, risk surface, and phase ordering before drafting the plan artifacts.
```

**Pattern for hve orchestrator:**
In Phase 0 difficulty assessment, add:
```
If `--think` was passed in `$ARGUMENTS`, set THINK_MODE=true and pass `--think` when invoking the plan phase for Challenging tasks (or unconditionally if the user explicitly requested it).
```

**Pattern for hve-review Phase 4:**
Add before the verdict synthesis step:
```
If `--think` was passed (or if Critical findings exist), invoke `/think` to reason through severity weights, conflict between dimensions, and the final pass/fail verdict before writing the verdict block.
```

### Argument parsing note

Commands receive `$ARGUMENTS` as a raw string. Flag parsing is done in prose: "strip `--think` from `$ARGUMENTS` before using it as the task slug, and set THINK_MODE accordingly." The implementor should follow the same pattern as the existing `--mode` flag parsing in `hve.md` and `hve-research.md`.

---

## Phase 4 Details

### --compact dimension groupings

Default (8 subagents, unchanged):
1. Functional correctness
2. Design quality
3. Idiomatic style
4. Code reuse / simplification
5. Performance
6. Reliability / error handling
7. Security
8. Documentation

Compact (4 paired subagents):
1. **Functional + Design** — "Review for functional correctness AND design quality"
2. **Idiomatic + Reuse** — "Review for idiomatic style AND code reuse / simplification opportunities"
3. **Performance + Reliability** — "Review for performance AND reliability / error handling"
4. **Security + Docs** — "Review for security vulnerabilities AND documentation gaps"

Each compact subagent prompt includes both dimension descriptions and instructions to report findings per-dimension within its output.

### Flag parsing pattern

Add to Phase 1 of `hve-pr-review.md`:
```
Compact mode: extract `--compact` from `$ARGUMENTS`. If present, use 4 paired subagents (see below). Otherwise use 8 single-dimension subagents.
```

---

## Phase 5 Details

### Parallelization pattern

Current behavior (sequential):
```
1. Spawn Tester agent → wait → read log
2. Spawn Evaluator agent → wait → read log
3. Spawn Updater agent → wait
```

Target behavior (parallel):
```
1. Spawn Tester agent AND Evaluator agent simultaneously (both read the draft; no write conflict)
   → wait for both
   → read both logs
2. Spawn Updater agent → wait
```

In prose form for the command:
```
Spawn the Tester and Evaluator subagents in parallel (two Agent calls in one response). Wait for both to complete. Then read both logs and pass the combined findings to the Updater.
```

The Updater still runs sequentially after both because it needs both sets of findings.

---

## Open Questions Resolved

**Q1: `--think` flag vs. session-level setting?**
Decision: per-command flag. Session-level `alwaysThinkingEnabled` risks cost blowup on simple tasks. Per-command `--think` is explicit and user-controlled.

**Q2: Is hve-challenge Write omission a bug?**
Decision: confirmed bug. The command body (Phase 2) explicitly creates a challenge artifact. Write is required and missing.

**Q3: Is /batch mature enough to document?**
Decision: document as a complementary tool in the Command Reference table with a note that it operates outside the RPI loop. Do not claim deep integration; simply surface awareness.
