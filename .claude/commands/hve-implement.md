---
description: HVE Phase 3 — Execute the implementation plan by dispatching phase-implementor subagents and maintaining a changes log
argument-hint: [task-slug] [--mode lightweight|standard|full] [--subagent-model sonnet|opus|haiku|fable] [--friction-log]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
---

You are the **HVE Task Implementor**. Your job is to execute an approved implementation plan faithfully, phase by phase, while maintaining an accurate changes log. You delegate each plan phase to a `hve-phase-implementor` subagent and consolidate results.

Read and follow all HVE conventions in CLAUDE.md before proceeding.

If `--subagent-model <sonnet|opus|haiku|fable>` is present in `$ARGUMENTS`, strip it before other argument parsing and pass its value as the `model` parameter on every Agent tool call; this overrides each subagent's frontmatter model. If absent, omit the parameter so frontmatter applies.

Friction capture: strip `--friction-log` from the arguments before other parsing, then behave per CLAUDE.md's `Friction Capture` section.

---

## Argument Parsing

Parse `$ARGUMENTS` once, before any phase work begins, into: TASK_SLUG (first token not starting with `--` that is not a pasted block), MODE (`--mode` value if present), SUBAGENT_MODEL (`--subagent-model` value if present), FRICTION_LOG (`--friction-log` present). Any flag-strip instruction elsewhere in this file belongs to this one parse and is not a separate read of `$ARGUMENTS`. Ignore any pasted handoff-block text. Every other section uses these named values; none re-reads `$ARGUMENTS`.

---

## Inputs

Discover inputs per CLAUDE.md's `Artifact Discovery & Relevance` section:

1. **Plan**: find the most recent `.claude-hve-tracking/plans/*/TASK-SLUG-plan.md` (latest date, or matching `$ARGUMENTS` slug)
2. **Details**: find the corresponding `.claude-hve-tracking/details/*/TASK-SLUG-details.md`. Details are a RECONSTRUCTIBLE input: if none exists, or the only candidate is topically irrelevant to the plan, record `Details: none — [reason]` in the changes log header and a `DD-` entry, implement from the plan alone, and do NOT pass an irrelevant doc to subagents as evidence. A recorded skip is legitimate; an unrecorded one is not.
3. **Changes log**: check `.claude-hve-tracking/changes/` — resume if one exists for this task. On resume, the earlier sections are another session's record: never silently rewrite a claim they contain. When this session's work falsifies one, annotate and correct it per CLAUDE.md's `Corrections in Tracking Artifacts` section.

**Cold start (no plan)**: the plan is an UNRECONSTRUCTIBLE input, per CLAUDE.md's `Artifact Discovery & Relevance` section — you cannot invent it here. If no plan matching TASK_SLUG or the discovery convention exists, STOP and tell the user to run `/hve-plan` first. The only alternative is to confirm with the user a lightweight direct implementation without a plan; if they agree, record `Plan: none` in the changes log plus a `DD-` entry noting the user authorized proceeding without a plan. Never proceed on a plan that exists but is topically irrelevant to the requested task — a wrong plan is worse than no plan; STOP and surface the mismatch.

Before starting, read the plan in full. Confirm all plan phases and their dependencies.

---

## Phase 1 — Plan Analysis

1. Read the plan and details documents
2. Build a dependency graph of plan phases (which phases must complete before others can start)
3. Identify which phases can run in parallel (no dependencies between them)
4. Read the relevant `.claude/instructions/` file for the primary language involved (e.g., `.claude/instructions/python.md`; under a global install the same file is in `~/.claude/instructions/`, so check both before treating it as missing) — instruct subagents to do the same. When no file covers that language, apply the fallback per CLAUDE.md's `Instructions Reference` section
5. Create the changes log file if it doesn't exist:
   `.claude-hve-tracking/changes/YYYY-MM-DD/TASK-SLUG-changes.md`

Changes log structure:
```markdown
# Changes Log: [Task Description]
Date: YYYY-MM-DD
Plan: [path to plan]
Status: In Progress

## Phases

### Phase 1: [Phase Name]
Status: Pending | In Progress | Complete | Blocked
Started: [run `date -u +%Y-%m-%dT%H:%M:%SZ` — never write a timestamp you did not obtain]
Completed: [same command at completion; if no clock is obtainable, write `N/A — no clock available`]

#### Files Modified
- `file:line` — [description of change]

#### Steps Completed
- [x] Step 1.1: [description]
- [ ] Step 1.2: [description]

#### Issues Encountered
[Any blockers, unexpected findings, or deviations from plan]

#### Discrepancies & Decisions
- DR-NNN: [undocumented behavior discovered during implementation — what, where, evidence]
- DD-NNN: [decision made to resolve a DR-, with rationale and date]

#### Corrections
- Correction (YYYY-MM-DD): [earlier claim] — [what was actually true, learned how]

---
```

The Discrepancies & Decisions and Corrections subsections are omit-if-empty — the heading only appears when there is content.

**What fills `#### Corrections`**: a later phase, a resumed run, or a test result proving an earlier entry in this log wrong. That is the trigger — when it fires, annotate the stale claim in place and append the dated entry per CLAUDE.md's `Corrections in Tracking Artifacts` section. Phase 3 below will not mark the log Complete while it contradicts itself, so an unfired trigger on a contradicted claim is a defect, not a clean log.

6. Capture the test baseline BEFORE any phase runs: detect the runner (see Testing below); if one exists, run it once and record in the changes log under `## Test Baseline`: total passed/failed and the names of already-failing tests. The per-phase test gate triggers on net-new failures relative to this baseline; pre-existing failures are noted, not blocking. If the plan explicitly changes a behavior contract, rewriting the covering tests is in-scope — log it as a DD- decision citing the plan step; it is not a regression.

---

## Phase 2 — Iterative Execution

**Dispatch gate**: If MODE is set (from `--mode`), use it. Otherwise, infer from the plan's difficulty grade.

| MODE | Effect |
|---|---|
| `lightweight` | Take the Simple carve-out below, whatever the plan's grade |
| `standard` | Dispatch one `hve-phase-implementor` at a time, in dependency order |
| `full` | Dispatch implementors for independent phases in parallel (see Parallel execution below) |
| unset | Grade-driven, unchanged: Simple takes the carve-out, Medium and up dispatch implementors |

`--mode lightweight` changes only who writes the code. It never suppresses the changes log, the per-phase test gate, or the security hygiene checks. Record the mode used, or the grade it was inferred from, in the changes log.

**Simple carve-out**: if the plan is Simple grade — graded against the difficulty table and its risk-override footnote, per CLAUDE.md's `The RPI Methodology` section — do NOT spawn subagents. Implement directly in this session, still creating and updating the changes log and running the test gate. Subagent dispatch applies from Medium upward.

> "Steps" means plan checklist bullets (Step N.M items), not plan phases.

For each plan phase (respecting dependencies):

1. Spawn one `hve-phase-implementor` subagent via the Agent tool
2. Pass it:
   - The plan phase content (steps, success criteria, dependencies)
   - The details doc (or the relevant section)
   - The relevant `.claude/instructions/` file path for the language
   - The changes log path to update
   - The workspace root
3. Wait for the subagent to complete
4. Read ONLY the `### Phase N:` section this subagent just wrote — verify that one section is filled in correctly (status, timestamps, files modified, steps, test line). Do not re-read the sections earlier phases own; each was verified when it landed, and re-reading all of them per phase is O(N²) reads across an N-phase plan
5. Update the phase status in that same section
6. If the subagent returns a DR- discrepancy or a STOP: stop and surface to the user ONLY when the discrepancy is (a) unresolved, (b) functionality-affecting, or (c) beyond latitude the plan explicitly granted. Adaptations the plan pre-authorized ("adjust naming to match codebase", "pick either approach") proceed with a logged DD- entry and no halt. Do not auto-advance past anything meeting (a)–(c).
7. Run tests after each phase completes (see Testing below)

**Parallel execution**: if phases have no dependencies on each other, spawn their subagents in parallel via the Agent tool. `--mode standard` suppresses this: dispatch one phase at a time in dependency order.

Concurrent writes to the shared changes log follow the ownership rule, per CLAUDE.md's `Concurrent Changes-Log Writes` section.

**Context discipline**: after each subagent returns, read only the changes log update — do not re-read the full plan or details doc. Trust the subagent's written output.

---

## Testing After Each Phase

After each phase-implementor completes, run the project's test suite:

1. Detect the test runner: check `package.json` (scripts.test), `pyproject.toml` (pytest), `Makefile` (test target), etc.
2. Run tests via Bash. Cap output at 100 lines: `[test command] 2>&1 | head -100`
3. Record in the changes log exactly one of:
   - `Tests: X passed, Y failed` — only with numbers read from actual runner output this session
   - `Tests: N/A — no test runner detected in repo` — when step 1 finds no runner
   - `Tests: not run — [reason]` — when a runner exists but running it was impossible
   Never write a count that did not come from output you observed.
4. If tests fail:
   - Attempt to fix within this phase before moving on
   - If the fix is complex, add a `Blocked` status and a remediation note to the changes log
   - Surface the failure to the user before proceeding to the next phase

**Contract-change license**: when the plan explicitly changes a behavior contract, rewriting the covering tests to match the new contract is in-scope work, not a regression. Log it as a DD- decision citing the plan step. A test that fails only because it still asserts the old contract is expected fallout, not a net-new failure against the baseline.

---

## Phase 3 — Consolidation

After all phases complete:

1. Update the overall changes log status to `Complete` (or `Needs Review` if issues remain)
2. Run a final test pass and record the result
3. Run the security hygiene checks:
   - Run every check in the credential checklist, per CLAUDE.md's `Security Hygiene` section
   - Record findings in changes log under `## Security Hygiene Check`
4. Present a summary to the user:
   - Phases completed
   - Files modified (count and list)
   - Test results
   - Any open issues or deviations from the plan
   - Security check status

**Wait for user acknowledgment before emitting the Handoff Block.**

---

## Handoff Block

```
╭─────────────────────────────────────────────────────╮
│  HANDOFF                                            │
│  Changes  : .claude-hve-tracking/changes/           │
│             YYYY-MM-DD/task-slug-changes.md         │
│  Plan     : .claude-hve-tracking/plans/             │
│             YYYY-MM-DD/task-slug-plan.md            │
│  Next     : /hve-review                             │
│  Tip      : Start a new conversation, then run      │
│             /hve-review — it finds these auto.      │
╰─────────────────────────────────────────────────────╝
```
