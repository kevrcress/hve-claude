# Implementation Details: Friction Log Remediation
Date: 2026-07-17
Task slug: friction-log-remediation
Plan: .claude-hve-tracking/plans/2026-07-17/friction-log-remediation-plan.md

Canonical wording lives HERE. Implementors paste these blocks verbatim; per-file improvisation is what the drift tests exist to catch.

## Block 1: Artifact Discovery & Relevance convention (CLAUDE.md master; commands reference it)

```markdown
## Artifact Discovery & Relevance

Phase commands discover their input artifacts from `.claude-hve-tracking/` deterministically:

1. A task slug given in arguments wins.
2. Otherwise collect the distinct slugs from artifacts dated within the last 7 days. A single candidate wins.
3. Multiple candidates: prefer the slug matching the current git branch name; otherwise list the candidates and ask. Never silently pick between same-day slugs.
4. Whatever is chosen, check topic relevance against the task before using it. An artifact about a different task is treated as absent, not as evidence.

When a normally-expected input is absent or irrelevant:

- **Reconstructible inputs** (research, details): record the skip and proceed. The plan file header records `Research: none — [reason]` and the planning log gets a DD- entry. A recorded skip is legitimate; an unrecorded one is not.
- **Unreconstructible inputs** (plan file for implement, changes log for review): stop and tell the user which phase to run first.
```

Command-file stub (paste into each Inputs section, adapted only for which inputs are reconstructible):

```markdown
Discover inputs per the Artifact Discovery & Relevance convention in CLAUDE.md: slug argument first, else recent distinct slugs (ask on ambiguity, never silently pick between same-day slugs), and always relevance-check the chosen artifact before treating it as evidence.
```

## Block 2: `--friction-log` flag (identical in all six commands; drift-tested)

```markdown
If `--friction-log` is present in the arguments, strip it before other parsing and enable friction capture for this session: whenever the process definition itself causes friction (an instruction that cannot be followed literally, a template blank with no obtainable value, a contradiction between files, wasted dispatch), append a dated entry to `.claude-hve-tracking/friction/YYYY-MM-DD-PHASE-SLUG.md` at the moment it happens (create the file on first entry). Entries record: what the text said, what happened, and the smallest fix. Friction capture never blocks the phase; if absent, no friction file is created.
```

Frontmatter: add `[--friction-log]` to each command's `argument-hint`.

Friction file template:

```markdown
# Friction Log: [phase] — [task slug]
Date: YYYY-MM-DD
Command: /hve-[phase]

## FL-001: [one-line title]
Observed: [what the process text said vs. what happened]
Cost: [tokens/time/wrong-output, if estimable]
Smallest fix: [one sentence]
```

## Block 3: Argument-parsing preamble (plan/implement/review/pr-review)

```markdown
## Argument Parsing

Parse `$ARGUMENTS` exactly once, before anything else, into: TASK_SLUG (first token not starting with `--` that is not a pasted block), MODE (`--mode` value if present), THINK_MODE (`--think` present), SUBAGENT_MODEL (`--subagent-model` value if present), FRICTION_LOG (`--friction-log` present). Ignore any pasted handoff-block text. All later sections reference these named values; none re-reads `$ARGUMENTS`.
```

(hve-pr-review variant: BRANCH = first whitespace-delimited token matching a name in `git branch --list`; no match → `git branch --show-current`.)

## Block 4: Timestamp fields (hve-implement.md template + hve-phase-implementor.md report)

Replace `Started: [timestamp]` / `Completed: [timestamp]` with:

```markdown
Started: [run `date -u +%Y-%m-%dT%H:%M:%SZ` — never write a timestamp you did not obtain]
Completed: [same command at completion; if no clock is obtainable, write `N/A — no clock available`]
```

## Block 5: Test reporting (hve-implement.md Testing + agent report)

```markdown
3. Record in the changes log exactly one of:
   - `Tests: X passed, Y failed` — only with numbers read from actual runner output this session
   - `Tests: N/A — no test runner detected in repo` — when step 1 finds no runner
   - `Tests: not run — [reason]` — when a runner exists but running it was impossible
   Never write a count that did not come from output you observed.
```

## Block 6: Test Baseline (hve-implement.md Phase 1 addition)

```markdown
6. Capture the test baseline BEFORE any phase runs: detect the runner (see Testing below); if one exists, run it once and record in the changes log under `## Test Baseline`: total passed/failed and the names of already-failing tests. The per-phase test gate triggers on net-new failures relative to this baseline; pre-existing failures are noted, not blocking. If the plan explicitly changes a behavior contract, rewriting the covering tests is in-scope — log it as a DD- decision citing the plan step; it is not a regression.
```

## Block 7: Simple carve-outs

hve-implement.md (insert before Phase 2 dispatch):

```markdown
**Simple carve-out**: if the plan is Simple grade (per the CLAUDE.md difficulty table including the risk-override footnote: < 50 lines, single file, clear requirements, no elevated-risk surface), do NOT spawn subagents. Implement directly in this session, still creating and updating the changes log and running the test gate. Subagent dispatch applies from Medium upward.
```

hve-review.md (insert before Phase 2 dispatch):

```markdown
**Simple carve-out**: for a Simple-grade task, do not spawn one validator per phase. Run a single `hve-rpi-validator` covering all phases in one pass (one output file). The quality validator (Phase 3) still runs but may be pointed at the consolidated scope. Record the carve-out in the review log.
```

Steps footnote (hve-plan.md complexity assessment + CLAUDE.md difficulty table):

```markdown
"Steps" means plan checklist bullets (Step N.M items), not plan phases.
```

## Block 8: Risk-override footnote (CLAUDE.md difficulty table)

```markdown
**Risk override:** classify at least Medium regardless of size when the change touches (a) code consumed outside this repo (published packages, installed prompts, APIs), (b) auth/security/crypto, (c) migrations or irreversible operations, (d) code paths with no test coverage.
```

## Block 9: Parent-runs-shell rule (CLAUDE.md + hve-review.md + hve-research.md notes)

```markdown
**Shell stays in the parent.** HVE subagents are read-only by design; most have no Bash. The parent session runs all git/shell commands and passes pre-digested results (short excerpts, counts, file lists) into subagent prompts. Never delegate a step requiring command execution to a subagent without checking its tool list; a validator without Bash will silently downgrade to static inference.
```

## Block 10: Verdict-integrity rules (hve-review.md Phase 4 / hve-pr-review.md Phase 3)

```markdown
- **Dedup severity**: when merging findings reported by multiple validators, keep the highest severity assigned and note the disagreement in the finding body.
- **Pre-existing defects**: a defect demonstrably present on the base and untouched by this change is recorded with a `[pre-existing]` tag and excluded from the verdict tally. When in doubt whether it is pre-existing, it counts.
- **Contested severity**: reclassification of a validator's severity is a judgment call — the parent makes it and records the rationale; never instruct a haiku-pinned validator to arbitrate severity disputes.
- **Tally integrity**: every number in the Summary tally must be traceable to a validation output file. Consolidate Critical and Major findings in full; for Minor findings copy each validator's count and one-line titles. Never write a tally from memory.
```

## Block 11: Record-only corrections (hve-review.md)

```markdown
**Record-only corrections**: "you do not implement" refers to product code. When the only defect is an un-annotated contradiction in the changes log (Minor, record-consistency), the reviewer appends the dated `Correction (YYYY-MM-DD):` entry itself per the CLAUDE.md corrections convention, notes the record-only edit in the review log, and does not route the task to Needs Rework for that alone.
```

## Block 12: Empty-diff guard (hve-pr-review.md Phase 1)

```markdown
**Empty-diff guard**: if the base diff has zero files, do NOT proceed — an empty review is never an Approve. Run `git status --porcelain`; if uncommitted or untracked work exists, report that the work is not on the diff and ask whether to review the working tree instead or stop. Always list untracked files touching reviewed areas as "not covered by this diff".
```

## Block 13: PR-review dimension ID prefixes (replaces IV-NNN in hve-pr-review.md + new agent)

| Dimension | Prefix |
|---|---|
| Functional Correctness | FC- |
| Design and Architecture | DA- |
| Idiomatic Implementation | II- |
| Reusability and Leverage | RL- |
| Performance and Scalability | PS- |
| Reliability and Observability | RO- |
| Security and Compliance | SC- |
| Documentation and Operations | DO- |

Format: `FC-001 [SEVERITY]` — numbering sequential within a dimension, so parallel reviewers cannot collide. `IV-` stays reserved for /hve-review implementation validation.

## Block 14: hve-pr-reviewer agent skeleton

```markdown
---
name: hve-pr-reviewer
description: Use this agent when an hve-pr-review command needs a senior-level review of a diff against one or two assigned quality dimensions, returning severity-graded findings with dimension-prefixed IDs.
model: sonnet
color: red
---
```

Body must include: assignment inputs (diff path to Read, changed-file list, dimension(s), output path under `.claude-hve-tracking/reviews/pr/BRANCH/`), instruction to Read the diff.patch rather than receive pasted diff, dimension definitions (copy from hve-pr-review.md Phase 2 list), severity grading per CLAUDE.md, dimension-prefixed ID format (Block 13), evidence rule (`file:line` citations, findings must cite the diff or the file), and the standard Subagent Response Protocol (artifact path, Pass/Fail→ use Complete/Blocked wording for reviewers? — use Complete/Blocked; verdict synthesis is the parent's job), 7-bullet cap, full-detail line.

Tools: Read, Write, Glob, Grep (no Bash; parent supplies the diff and any git facts, per Block 9).

docs/internals.md: add row `hve-pr-reviewer | sonnet | ...` matching the table's existing format. CLAUDE.md Model Selection prose: extend "judgment-graded reviewers ... pinned to sonnet" example list with the PR reviewer.

## Block 15: Roster-deviation line (CLAUDE.md + dispatching commands)

```markdown
If you dispatch an agent type not in the HVE roster (`.claude/agents/`), record in the phase artifact which type you used and why. Improvisation is allowed; invisible improvisation is not.
```

## Block 16: Requirements-appendix convention (CLAUDE.md)

```markdown
## Mid-Flow Scope Changes

Chat instructions do not survive phase handoffs — disk does. When the user adds or changes requirements after the plan is written, append them to the PLAN file under `## Requirements added after <phase>` with a date. Every later phase command must read that section as part of plan discovery and treat its entries as plan content. Standing instructions ("always do X for the rest of this task") are recorded the same way.
```

## Block 17: Instructions fallback rule (CLAUDE.md Instructions Reference)

```markdown
If no instructions file exists for the language at hand, do not block: follow the dominant conventions of the existing code in the repo, and note the missing instructions file in the changes log.
```

Table rows to add:

```markdown
| JavaScript | `.claude/instructions/javascript.md` |
| TypeScript | `.claude/instructions/typescript.md` |
```

## Block 18: Concurrent changes-log rule (CLAUDE.md + hve-implement.md + hve-phase-implementor.md)

```markdown
**Concurrent writes**: when phase implementors run in parallel, each agent owns exactly one `### Phase N:` section of the shared changes log and updates it only via targeted Edit calls anchored on its own heading. Whole-file Write of the changes log is forbidden once more than one agent may hold it — last-writer-wins destroys sibling sections silently.
```

## Block 19: Slug derivation (CLAUDE.md Artifact Naming Conventions)

```markdown
Slug derivation: derive the slug from the primary deliverable of the task description (3–6 kebab-case words). When one prompt bundles several asks, slug the primary deliverable and list the secondary asks in the artifact body; do not concatenate them into the slug.
```

## Block 20: O-01 consolidation rewrite (hve-research.md Phase 3, replaces steps 1–2)

```markdown
1. Read each subagent's output file from `.claude-hve-tracking/research/subagents/` IN FULL — these artifacts are already condensed; they are your evidence base, not noise to skim
2. Apply **context discipline** to the layer BELOW them: do not re-open the source files the subagent artifacts cite; trust their `file:line` citations
```

## Block 21: Research mode-conflict fix (hve-research.md Inputs)

```markdown
- Mode: `--mode` overrides the difficulty assessment when explicitly passed (`lightweight` = 1 subagent, `standard` = 2–3, `full` = 3–5). With no flag, the Phase 0 difficulty table alone decides the count.
```

## Block 22: WebFetch guidance (hve-research.md)

```markdown
For GitHub-hosted content fetch raw URLs (`raw.githubusercontent.com/...`), not the HTML UI. The default cap is 3 URLs per question; when the research SUBJECT is an external repo or documentation set, the cap applies per question, and the parent may dispatch ONE bounded follow-up round to close evidence gaps a subagent explicitly flagged. Follow-up rounds beyond one require asking the user.
```

## Block 23: Evidence Rules extension (hve-plan.md, appended to existing 3 bullets)

```markdown
- Verification timing: "verified" refers to a check that RAN during planning. Expected outcomes of future implementation work are written as steps with success criteria, never as verified claims.
- A grep/citation proves existence, never exhaustiveness. "All call sites updated" requires an enumerated list checked item-by-item (show the list), otherwise mark [MEDIUM] and add an implementation-phase guard step.
```

## Block 24: STOP-rule refinement (hve-implement.md step 6)

```markdown
6. If the subagent returns a DR- discrepancy or a STOP: stop and surface to the user ONLY when the discrepancy is (a) unresolved, (b) functionality-affecting, or (c) beyond latitude the plan explicitly granted. Adaptations the plan pre-authorized ("adjust naming to match codebase", "pick either approach") proceed with a logged DD- entry and no halt. Do not auto-advance past anything meeting (a)–(c).
```

## Drift-test specs (Phase 8)

New test groups (extend tests/run-drift-tests.sh or add run-boilerplate-drift.sh sourcing tests/lib/assert.sh):

1. `subagent_model_boilerplate`: extract the `--subagent-model` paragraph (line starting `If \`--subagent-model`) from every command carrying it; all occurrences byte-identical.
2. `friction_flag_boilerplate`: same technique for the `If \`--friction-log\`` paragraph across the six commands.
3. `response_protocol_structure`: for each agent file with a Response Format section, assert presence of: an artifact-path line, a status line, `7` bullet cap, `5` checklist cap, `3` question cap, a `Full detail` line (grep per file).
4. `instructions_table_sync`: parse CLAUDE.md Instructions Reference rows → each cited file exists; each `.claude/instructions/*.md` appears in the table.
5. `agent_roster_references`: every `hve-*` agent name mentioned in .claude/commands/*.md exists as .claude/agents/<name>.md.

## File → phase ownership map (concurrency guard)

| File | Sole owner |
|---|---|
| CLAUDE.md | Phase 1 (Phase 6 may touch ONLY the Model Selection prose; coordinate via sequential dispatch if both queued) |
| .claude/commands/hve-research.md | Phase 2 |
| .claude/commands/hve-plan.md, hve-challenge.md | Phase 3 |
| .claude/commands/hve-implement.md, .claude/agents/hve-phase-implementor.md | Phase 4 |
| .claude/commands/hve-review.md | Phase 5 |
| .claude/commands/hve-pr-review.md, .claude/agents/hve-pr-reviewer.md (new), docs/internals.md | Phase 6 |
| .claude/instructions/javascript.md, typescript.md (new) | Phase 7 |
| tests/** | Phase 8 |

CLAUDE.md conflict note: Phase 6 Step 6.8's CLAUDE.md prose touch overlaps Phase 1's file. Resolution: Phase 1 lands first (it is the dependency root); Phase 6 then edits only the Model Selection sentence via targeted Edit.
