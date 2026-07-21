# Implementation Details: Unowned-File Convention Remediation

Date: 2026-07-20
Task slug: unowned-file-remediation
Plan: .claude-hve-tracking/plans/2026-07-20/unowned-file-remediation-plan.md

## File → phase ownership map

Every file this task may touch appears exactly once. Any file not listed here is out of scope for implementors; the parent session owns Phase 0 and Phase 6 (no repo edits).

| File | Phase |
|---|---|
| .claude/agents/hve-rpi-validator.md | 1 |
| .claude/agents/hve-plan-validator.md | 1 |
| .claude/commands/hve-review.md | 1 |
| .claude/commands/hve-plan.md | 1 |
| .claude/commands/hve-prompt-builder.md | 2 |
| .claude/agents/hve-prompt-evaluator.md | 2 |
| .claude/commands/hve-prompt-refactor.md | 2 |
| .claude/commands/hve-doc-ops.md | 3 |
| .claude/commands/hve-memory.md | 3 |
| .claude/prompts/rpi.md | 4 |
| .claude/prompts/pull-request.md | 4 |
| .claude/prompts/checkpoint.md | 4 |
| .claude/prompts/doc-ops.md | 4 |
| .claude/prompts/task-challenge.md | 4 |
| .claude/prompts/prompt-build.md | 4 |
| tests/run-drift-tests.sh | 5 |

CLAUDE.md is deliberately absent: M-03 is fixed by making the prompt-builder enforce what CLAUDE.md:208 already claims, not by weakening the claim.

## Canonical wording

Implementors paste these verbatim; never improvise per-file variants.

### Unlisted-changes check (Step 1.2, hve-rpi-validator.md)

Body instruction replacing line 48: (superseded — see Correction 2026-07-20)

> Compare the parent-supplied changed-file list against the changes log. Any file on the list but absent from the log is an unlisted change; grade per severity. If the parent supplied no list, do not infer one.

**Correction (2026-07-20, appended by `/hve-review` remediation Phase 10):** the wording above
proved ambiguous in practice and was revised by plan-addendum Step 8.1. Because the agent's
Step 2 is explicitly per-phase, "the changes log" could be read as only the agent's own
`### Phase N:` section, under which every sibling phase's files false-flag as unlisted
changes. The canonical text is now:

> Compare the parent-supplied changed-file list against the entire changes log — every `### Phase N:` section in the document, not only this phase's section. Any file on the list but absent from the log is an unlisted change; grade per severity. If the parent supplied no list, do not infer one.

Live carrier: `.claude/agents/hve-rpi-validator.md`, Step 2 item 4.

Template section:

```markdown
## Unlisted Changes
[Files on the parent-supplied changed-file list but absent from the changes log]
[N/A - no changed-file list supplied by parent]
```

### Parent-side changed-file digest (Step 1.1, hve-review.md)

Added to the dispatch-inputs list:

> - Changed-file list: output of `git diff --name-only <base>` run by the parent (the parent chooses `<base>`: the merge-base with main for branch review, or `HEAD` for uncommitted work)

### Research-absent branch (Steps 1.3 and 1.4, both validators)

> If the parent reports research as absent (plan header reads `Research: none — [reason]`), skip requirement extraction. Record in the output: "Validated against the plan alone; research was recorded absent at planning time." Do not manufacture requirements the research never stated.

### Template Integrity criterion (Steps 2.2 and 2.3)

For hve-prompt-builder.md quality-criteria list (one line):

> - Template integrity: every template blank is genuinely obtainable in-session or carries an explicit N/A branch (per CLAUDE.md Template Blanks)

For hve-prompt-evaluator.md (new criteria section):

```markdown
### Template Integrity
- Is every template blank fillable from information available in-session?
- Does every blank that might be unfillable carry an explicit N/A branch (example: `Tests: N/A - no test runner in repo`)?
- Flag as Major any blank that would force a fabricated value or stall the phase.
```

### Per-project native memory wording (Steps 3.5 and 4.3)

> Also write the most non-obvious decisions and patterns to the Claude Code native memory store for this project (`~/.claude/projects/<project-slug>/memory/`). The store is per-project, not global: entries written here surface only in future sessions on this same project.

### pull-request.md header (Step 4.2)

> Senior-level PR code review with `/hve-pr-review [branch]`: 8 quality dimensions, severity-graded findings.

### Artifact-discovery subsection for hve-memory.md (Step 3.4)

```markdown
## Locating tracking artifacts

Populate the Tracking Artifacts block via the CLAUDE.md Artifact Discovery & Relevance convention, never newest-match-wins:

1. A topic-slug argument wins.
2. Otherwise collect distinct slugs from artifacts dated within the last 7 days; a single candidate wins.
3. Multiple candidates: prefer the slug matching the current git branch; otherwise list them and ask.
4. Relevance-check the chosen artifacts against this session's actual work; an artifact about a different task is treated as absent.
Record `none` for any artifact type that has no relevant file.
```

## Phase 5 test contracts

### Test 12 — dispatching commands name a resolvable agent

- Scan: `.claude/commands/*.md` where the frontmatter `allowed-tools` line contains the standalone token `Agent`.
- Assert: file body contains >= 1 backticked `` `hve-[a-z-]+` `` token AND every such token resolves to `.claude/agents/<token>.md` (resolution itself is Test 9's job; Test 12 only adds the non-empty requirement).
- Known-good set after Phase 3: hve.md, hve-research.md, hve-plan.md, hve-implement.md, hve-review.md, hve-pr-review.md, hve-doc-ops.md, hve-prompt-builder.md. The implementor derives the actual set from frontmatter at write time rather than hardcoding this list.

### Test 13 — prompt-file flags exist in the mapped command

- Map (hardcode as a bash associative array or parallel arrays, matching the style of `FULL_PROTOCOL_AGENTS`):
  - rpi.md → hve.md
  - pull-request.md → hve-pr-review.md
  - checkpoint.md → hve-memory.md
  - doc-ops.md → hve-doc-ops.md
  - task-challenge.md → hve-challenge.md
  - prompt-build.md → hve-prompt-builder.md
- Extract: from each prompt file, tokens matching `--[a-z-]+` on option-list lines (lines beginning `- \`--`), to avoid prose false positives.
- Assert: each extracted token appears anywhere in the mapped command file.
- One-directional by design: command flags missing from the prompt are a docs gap, not a phantom feature; only prompt→command is enforced.

### Mutation protocol (Step 5.3)

1. `git stash` nothing; use targeted temporary edits.
2. Mutation A: remove the backticked `hve-researcher` token from hve-doc-ops.md:48; run Test 12; expect FAIL; restore the line.
3. Mutation B: re-add `- \`continue\`: resume from tracking artifacts` to rpi.md options; run Test 13; expect FAIL; restore.
4. Both failure outputs pasted into the changes log as evidence the tests can fail.

## Dispatch notes

- Phases 1-4: one `hve-phase-implementor` each; parallel dispatch is safe (disjoint file sets per the ownership map). Each implementor owns exactly one `### Phase N:` section of the changes log per the CLAUDE.md concurrent-write rule.
- Phase 5: single `hve-phase-implementor`; it has Bash (All tools) so it can run the mutation checks itself.
- Phase 0 and Phase 6: parent session only (shell stays in the parent; the installer writes outside the repo).
