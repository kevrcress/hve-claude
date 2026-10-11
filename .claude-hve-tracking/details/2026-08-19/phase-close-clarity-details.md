# Implementation Details: Phase-Ending Clarity (Thread B)
Date: 2026-08-19
Task slug: phase-close-clarity
Plan: .claude-hve-tracking/plans/2026-08-19/phase-close-clarity-plan.md

## The two formats, specified

### Format 1: Completion Summary (locked by Kevin 2026-08-15, confirmed 2026-08-19)

Three bold headers, fixed order, emitted once at command close.

```
**What I did**

- Step 1.2: <outcome>, `path/to/file.md`
- Step 1.3: <outcome>, `path/to/other.md`
- Tests: 255 passed / 0 failed before, 258 passed / 0 failed after

**What I need from you**

Nothing blocking.

1. <thing to be aware of>
2. <deferred decision and its consequence>

**Next step**

`/hve-implement` (or `/hve-plan` again if the phase ordering needs rework)
```

Content rules:

- Outcomes are one line each, leading with the step or finding ID and a file path.
- Test evidence is one line with before/after numbers obtained by execution, never estimated.
  If no test runner applies, the N/A branch from CLAUDE.md's `Template Blanks` section governs.
- Notable verification work (a negative control, a bug caught in the session's own output) gets
  one clause, not a paragraph.
- `**What I need from you**` says "Nothing blocking" explicitly when true. This is where deferred
  decisions and their consequences go, and where uncommitted state is stated plainly.
- `**Next step**` is one concrete command plus the realistic alternative if there is one.
- The whole block fits on one screen. The failure mode is it growing into a second findings
  report; the CLAUDE.md section text must say "concise" in a way that binds.

### Format 2: Labeled-line close block (replaces the box)

Emitted inside a fenced code block, immediately after the three headers.

```
status  : done
artifact: .claude-hve-tracking/plans/2026-08-19/task-slug-plan.md
next    : /hve-implement
```

Contract:

- Exactly three required keys, always present, always in this order: `status`, `artifact`, `next`.
- Additional optional `key: value` lines may follow (lowercase key, colon, value). Used for
  secondary artifacts: `details:` for hve-plan, `plan:` for hve-implement, `findings:` for
  hve-pr-review, `sandbox:` for hve-prompt-builder.
- Status enum: `done`, `awaiting-approval`, `blocked`, `needs-rework`.
- The enum is documented in PROSE above the template. It never appears inside the template with
  `|` separators. The template always shows one concrete value.
- No-artifact branch: `artifact: none - <reason>`.
- `next:` may be prose when the next action is not a slash command (example: hve-git-commit,
  where the realistic next action is `git push`).

## Why the labeled-line format cannot table-parse

A GitHub-flavored markdown table needs a row containing `|` plus a delimiter row of dashes and
pipes. The box-drawing block supplies both shapes: every row is wrapped in verticals, and the
long horizontal rules read as a delimiter row. When the model regenerates the block as bare chat
text it drifts the Unicode verticals to ASCII `|`, at which point the shape parses. The
labeled-line format contains no `|` character anywhere, so no table can form, with or without a
surviving fence.

The residual risk is not the format, it is templates that embed alternatives with `|`. Two live
examples today:

Enumerated exhaustively over `.claude/commands/` via `grep -rn '│.*|' .claude/commands/*.md`,
which returns exactly three lines:

```
hve-doc-ops.md:112    │  Findings : N critical | N major | N minor          │
hve-pr-review.md:188  │  Verdict  : ✅ Approve | ⚠️ Request Changes | 🚫 Block │
hve-pr-review.md:189  │  Critical : N | Major: N | Minor: N                 │
```

All three must move their alternatives into prose.

Correction (2026-08-19): an earlier draft of this file listed the two hve-pr-review lines as :189
and :190, and an earlier draft of the plan cited `hve-review.md:172` as a third offender. Both
were wrong. `hve-review.md:172` contains zero bare ASCII pipes (`sed -n '172p' | tr -cd '|' | wc -c`
returns 0); it is a single-value box row. The corrected list above is an enumeration rather than a
sample, so it is exhaustive over `.claude/commands/` rather than merely existence-proving.

## Status enum mapping (research open question 6, resolved)

Verified against `.claude/commands/hve-review.md:153-155`, which defines exactly three verdicts.
The mapping is 1:1 and total:

| hve-review verdict | emitted status | source |
|---|---|---|
| ✅ Complete | `done` | hve-review.md:153 |
| ⚠️ Needs Rework | `needs-rework` | hve-review.md:154 |
| 🚫 Blocked | `blocked` | hve-review.md:155 |

`awaiting-approval` is emitted by commands that pause for user approval before handing off
(hve-plan at its Phase 4 checkpoint, hve-implement at its acknowledgment gate). The
orchestrator-side `pending` and `running` states from the HiVE brief are never emitted by a
command; they belong to the orchestrator.

## Drift-test mechanics the carrier depends on

Verified by the parent during planning by reading `tests/run-drift-tests.sh`:

- `claude_md_headings()` at :965 extracts every `^##+ ` heading, heading text only.
- `REFERENCE_PATTERN` at :959 is ``per CLAUDE\.md's \`[^\`]+\` section``.
- Test 14 fails if any such pointer under `.claude/commands`, `.claude/agents` or `.claude/prompts`
  names a section that is not a CLAUDE.md heading.

Consequence: adding `## Completion Summary` to CLAUDE.md and writing the pointer
``per CLAUDE.md's `Completion Summary` section`` in each command file yields enforcement with no
test edit. Centralizing also avoids a test-10 row, because `CANONICAL_BLOCK_SPECS` only needs an
entry when the same block text is duplicated across two or more carrier files.

## Full close-shape inventory (from research B1, for phase grouping)

| Group | Files | Current shape | Phase |
|---|---|---|---|
| True HANDOFF box | hve-research, hve-plan, hve-implement, hve-review | box | 2 |
| Sibling box | hve-pr-review, hve-doc-ops, hve-memory, hve-prompt-builder | box | 3 |
| Structured non-box | hve, hve-prompt-analyze, hve-challenge | fenced or partial | 4 |
| Unstructured | hve-git-commit, hve-git-merge, hve-git-setup, hve-prompt-refactor | prose or none | 4 |

hve-git-setup is the only file with no close at all: it ends at `## Critical Constraints`
(hve-git-setup.md:71-77) and needs a new section rather than a replacement.

## Known cosmetic defect removed by deletion

CLAUDE.md:225 and hve-research.md:152 close their box with `╝` (double-line corner) while opening
with `╭` (single-line round corner). Dropping box-drawing entirely removes this without a separate
fix step.
