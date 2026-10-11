# Implementation Details: CLAUDE.md Lean Restructure

Date: 2026-08-19
Task slug: claude-md-lean-restructure
Plan: .claude-hve-tracking/plans/2026-08-19/claude-md-lean-restructure-plan.md

## The payload contract, stated once

`install.sh:171`:

```bash
HVE_BLOCK="$(awk '/^## Your Project/{exit} {print}' "$SOURCE/CLAUDE.md")"
```

Consequences, all verified by reading `install.sh:167-200`:

1. The cut is the HEADING, not the placeholder comment. The HTML comment at CLAUDE.md:390-399 is never
   read by the installer; fresh installs get a hardcoded one-line placeholder written at
   `install.sh:190-193` (`## Your Project` in project mode, `## Your Global Context` in global mode).
   Editing or replacing this repo's placeholder comment cannot affect any install.
2. The match is an unanchored-at-the-right regex on `^## Your Project`. Any earlier line starting with
   that string truncates the payload silently. A fenced code block containing the heading at column 1
   would do it.
3. `awk` prints up to but not including the matched line, so the payload's last line is whatever precedes
   the heading. Today that is the `---` separator at CLAUDE.md:387. That stays true after the
   restructure; no change required.
4. The block is then wrapped in `<!-- HVE:START - managed by hve-claude, do not edit between markers -->`
   / `<!-- HVE:END -->` at `install.sh:180-183` and merged. The repo file itself carries no markers.

## Exact edit map for CLAUDE.md

Line numbers are the pre-edit file (399 lines). Apply top-down edits bottom-up, or re-locate anchors
after each edit, since every deletion shifts what follows.

| Region | Pre-edit lines | Action | Destination |
|---|---|---|---|
| Pitch paragraph | 3 | Rewrite to one operational framing line | in place |
| MIT attribution | 5 | Keep verbatim | in place |
| RPI narrative paragraph | 11 | Delete (plus trailing blank) | dropped; README.md:11-22 keeps it |
| Command Reference rows | 42-55 | Rewrite: purpose + when-to-use, no flags | in place |
| Command Reference pointer | after 55 | New line: flags live in `.claude/commands/<name>.md` | in place |
| Hooks section | 317-339 | Delete | `docs/reference.md`, new `## Hooks for automatic change logging` |
| Installing section | 341-366 | Delete | `docs/installation.md`, merged (diff first) |
| Tracking policy subsection | 368-380 | Move up under `## Tracking Folder Structure` | in place, as `###` child |
| Credential-patterns installer paragraph | 382-385 | Delete | `docs/installation.md` |
| Tracking Folder Structure intro | 76 | Drop the markdown link, keep the sentence | in place |
| `## Your Project` heading | 388 | Keep byte-exact | in place |
| Placeholder comment | 390-399 | Replace with repo-local context | in place |

## Command Reference: before and after shape

Before (CLAUDE.md:44, 233 characters):

```text
| `/hve-plan` | Plan phase only. `--mode` overrides the inferred planning complexity: `lightweight` writes the plan directly, `standard` adds the Plan Validator, `full` uses parallel validation. Accepts `--think` for extended reasoning. | After research exists; reads latest research artifact |
```

After (shape, not final wording):

```text
| `/hve-plan` | Plan phase only. Converts research into a validated implementation plan. | After research exists; reads the latest research artifact |
```

Then, once under the table:

```text
Flags and options for each command live in that command's file, `.claude/commands/<name>.md`. The
command files are the ground truth; this table is a map, not a specification.
```

Rows that lose the most: CLAUDE.md:42 (393 chars), :47 (377), :45 (294), :46 (288), :43 (274), :44 (233).
Rows :48-55 are already short (98-192 chars) and mostly need no change.

### Flags leaving the table, and where they already live

Verified by `grep -c` per flag per command file at plan time. Presence is [HIGH]; the guard at plan
Step 3.1 covers semantic equivalence, which token counts do not prove.

| Flag | Rows that describe it | Command files that document it |
|---|---|---|
| `--mode` | `/hve`, `/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review` | hve.md, hve-research.md, hve-plan.md, hve-implement.md, hve-review.md |
| `--think` | `/hve`, `/hve-plan`, `/hve-review` | hve.md, hve-plan.md, hve-review.md |
| `--dimension` | `/hve-pr-review` | hve-pr-review.md |
| `--compact` | `/hve-pr-review` | hve-pr-review.md |
| `--scope` | `/hve-doc-ops` | hve-doc-ops.md |

Flags NOT in the Command Reference table and therefore untouched: `--subagent-model` (documented in
`## Model Selection`, frozen by test 3), `--friction-log` (documented in `## Friction Capture`, a
sole-copy canonical block), `--effort xhigh` (documented in `## The RPI Methodology`).

## Test surfaces this change touches, and the exact assertion each makes

| Test | File:line | What it parses | How this change could break it |
|---|---|---|---|
| 3 | tests/run-drift-tests.sh:243 | body of `## Model Selection` | only if that heading is renamed or the section is edited; it is not |
| 4 | tests/run-drift-tests.sh (gitignore) | repo `.gitignore` vs the CLAUDE.md checklist | only if the Security Hygiene bullet changes; it does not |
| 8 | tests/run-drift-tests.sh:459 | every `.claude/instructions/*.md` path anywhere in CLAUDE.md | new prose in `## Your Project` naming a nonexistent instruction file |
| 10 | tests/run-drift-tests.sh:569-584 | 5 sole-copy prefixes across commands/agents/prompts/CLAUDE.md | rewording a canonical block, or copying one into a second carrier |
| 14 | tests/run-drift-tests.sh:972 | CLAUDE.md heading list vs 14 pointers under `.claude/` | renaming, deleting, or demoting any of the 14 headings |
| 15 | tests/run-drift-tests.sh:1044 | discovery pointer presence in 5 commands | unaffected; no command file loses a pointer |
| 16 | tests/run-drift-tests.sh:1128 | credential set from the `.gitignore hygiene` bullet vs install.sh, the install suite array, README.md, docs/installation.md | dropping a pattern from `docs/installation.md` while moving the Installing prose |

`docs/` is not in test 10's corpus (`canonical_block_corpus()`, tests/run-drift-tests.sh:587-596), so
relocating text into `docs/reference.md` or `docs/installation.md` cannot raise a carrier count. That is
what makes the Phase 1 moves safe.

## The 14 frozen heading strings, verbatim

Any of these renamed fails test 14 immediately. Copy from here, do not retype.

```text
The RPI Methodology
Friction Capture
Artifact Naming Conventions        (not pointer-referenced, but slug rules are a sole copy)
Severity Grading
Confidence Markers
Corrections in Tracking Artifacts
Citation Format
Subagent Response Protocol
Subagent Dispatch Discipline
Template Blanks
Artifact Discovery & Relevance
Instructions Reference
Security Hygiene
Untrusted Input
Concurrent Changes-Log Writes
```

The pointer-referenced set is 14 of these; `Artifact Naming Conventions` is listed because its slug
derivation rules are a sole copy with no pointer and no test, same profile as Mid-Flow Scope Changes.

## Proposed post-restructure heading list (level 2+)

Simulated against all 14 pointers at plan time; all resolve.

```text
The RPI Methodology
Command Reference
Model Selection
Tracking Folder Structure
  Tracking folder & version control      (### child, preserves the existing anchor slug)
Friction Capture
Artifact Naming Conventions
Severity Grading
Confidence Markers
Corrections in Tracking Artifacts
Citation Format
Subagent Response Protocol
Subagent Dispatch Discipline
Template Blanks
Handoff Block Format
Context Management Between Phases
Artifact Discovery & Relevance
Mid-Flow Scope Changes
Instructions Reference
Security Hygiene
Untrusted Input
Concurrent Changes-Log Writes
Your Project
```

Two headings disappear relative to today: `Optional Power-User: Hooks for Automatic Change Logging` and
`Installing HVE in Your Project`. Neither is pointer-referenced (`grep -rn` for both returns only their
own definitions plus an unrelated `echo "Installing HVE"` at install.sh:67).

## Draft content for `## Your Project`

Wording is a draft; the counts in the stack line are re-derived at implement time per plan Step 5.2.

```markdown
## Your Project

This section is repo-local. Everything ABOVE this heading is the install payload: `install.sh:171`
extracts it and merges it into every consuming project's CLAUDE.md, so editing above the line edits
every future install. Installed projects get their own equivalent section, written by the installer.

- Stack: the product is markdown prompt artifacts. N commands (`.claude/commands/`), N agents
  (`.claude/agents/`), N instruction files, N prompts, plus `install.sh` and the bash test suites in
  `tests/`. No package manager, no CI, no Makefile.
- Product boundary: CLAUDE.md and `.claude/` are consumed outside this repo, so the risk override
  applies and changes to them classify at least Medium.
- Tests: run `./tests/run-install-tests.sh` and `./tests/run-drift-tests.sh` from the repo root after
  any edit to `.claude/`, `CLAUDE.md`, `README.md`, `docs/`, or `install.sh`. Both are offline and take
  seconds. A change in the passing count is either intentional or a regression; decide which
  (CONTRIBUTING.md).
- The interactive prompt tests (`tests/run-prompt-new-install.sh`, `tests/run-prompt-upgrade.sh`) need
  `dev` pushed to GitHub plus a Claude Code session. They are not part of the routine gate.
- Branch flow: `feature/*` into `dev`, `dev` into `main`.
- Deliberate duplication: canonical blocks are byte-identical across their carriers and drift-tested.
  Never reword one copy alone. Renaming a CLAUDE.md heading means updating every
  ``per CLAUDE.md's `...` section`` pointer under `.claude/`.
- `.claude-hve-tracking/` is committed by design; only `subagents/` and `sandbox/` are gitignored.
```

Constraint check on this draft: no line begins with `## Your Project`; no `.claude/instructions/<file>.md`
path is named (only the directory, which test 8's regex requires a filename to match); the six credential
patterns are not restated, so test 16's canonical parse is untouched.

## Authoring conventions for the rewrite

From `.claude/instructions/markdown.md` and `.claude/instructions/writing-style.md`:

- ATX headings at column 1, one space after the hashes, blank line above and below, no trailing
  punctuation, under 80 characters.
- Blank lines around code blocks, lists, and tables. Never two consecutive blank lines.
- Tables: aligned pipe style with leading and trailing pipes and a header separator row.
- Fenced code blocks carry a language tag; use `text` when unhighlighted.
- File ends with exactly one newline.
- Direct second person, no hedging, no filler.
- No em-dashes in new or rewritten prose (user preference). Existing em-dashes in lines this task does
  not touch are left alone: churning them would rewrite most of the file for no functional gain, and
  `install.sh:198-199` already shows that shipped-punctuation churn is a tested concern.
- Keep `-` list markers throughout, diverging from `.claude/instructions/markdown.md:16`, which mandates
  `*`. Locked decision 5; recorded as DD-002.
