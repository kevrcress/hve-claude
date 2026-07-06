# Implementation Validation: Retier HVE subagent models by judgment requirements
Date: 2026-07-06
Scope: full-quality (all 11 dimensions)
Files Reviewed: 6 (+2 additional living-doc files found stale during citation check: docs/internals.md, README.md)

## Context Note
This is an ad hoc change with no RPI plan/research artifacts. Plan-conformance checks are
skipped; findings are validated against the stated intent provided by the parent:

- `hve-researcher`: `model: haiku` → `inherit`
- `hve-implementation-validator`: `model: haiku` → `sonnet`
- `hve-prompt-evaluator`: `model: haiku` → `sonnet`
- `hve-plan-validator` / `hve-rpi-validator`: unchanged (`haiku`, mechanical checks)
- CLAUDE.md Model Selection, README.md cost-comparison row, `hve-prompt-refactor.md` porting
  rule updated to describe the new split

## Summary
Critical: 0 | Major: 2 | Minor: 1

## Findings

### IV-001 [DOCUMENTATION] [MAJOR]
Description: `docs/internals.md` contains a "Subagents reference" table that lists the model
tier for every agent. Three rows are now stale relative to the updated frontmatter values,
and this file was not in the modified-files list for this change.
Evidence:
- `docs/internals.md:20` — `| hve-researcher | ... | Haiku |` (actual: `inherit`, per `.claude/agents/hve-researcher.md:4`)
- `docs/internals.md:24` — `| hve-implementation-validator | ... | Haiku |` (actual: `sonnet`, per `.claude/agents/hve-implementation-validator.md:4`)
- `docs/internals.md:25` — `| hve-prompt-evaluator | ... | Haiku |` (actual: `sonnet`, per `.claude/agents/hve-prompt-evaluator.md:4`)
Impact: A contributor reading the internals doc (explicitly aimed at "contributors, prompt
engineers, and anyone who wants to understand the machinery") will get an incorrect mental
model of which agents are cost-optimized vs. judgment-graded, undermining the exact rationale
this change is trying to communicate.
Recommendation: Update the three table rows to `Inherit`, `Sonnet`, `Sonnet` respectively to
match current frontmatter. Since this is a living doc, prefer anchoring the table cells to the
frontmatter file rather than hardcoding — or add a footnote directing readers to the
frontmatter as the source of truth to avoid future drift.

### IV-002 [DOCUMENTATION] [MAJOR]
Description: `README.md` has two additional stale model claims beyond the cost-comparison row
that was updated. Both describe the old "Haiku for research/validation" split that this change
explicitly retires.
Evidence:
- `README.md:22` — "lower cost (Haiku for research/validation, Sonnet/Opus only for
  implementation)" — no longer accurate; researcher is now `inherit`, two validators are now
  `sonnet`.
- `README.md:65` — "**Haiku** used automatically for research and validation subagents (cost
  optimization, no configuration needed)" under "Requirements" — same stale claim; also implies
  ALL validation subagents use Haiku, which is now false for `hve-implementation-validator` and
  `hve-prompt-evaluator`.
Impact: A new user reading the README's "Why this exists" and "Requirements" sections gets
directly contradictory information from the cost-comparison table two sections later
(README.md:246, which the change did update correctly). Self-contradicting living docs erode
trust in the whole document.
Recommendation: Update both lines to reflect the new split, e.g. "Haiku for mechanical
validation, Sonnet for judgment-graded review, session model (inherit) for research and
implementation" — consistent phrasing with the already-updated README.md:246 row.

### IV-003 [DOCUMENTATION] [MINOR]
Description: `docs/internals.md` embeds bare model-name strings in a table with no anchor back
to the frontmatter files that are the actual source of truth, so this class of drift (three
stale rows found in this session) is likely to recur on the next retiering pass.
Evidence: `docs/internals.md:18-27` — table hardcodes model tier per agent as plain text with
no citation to `.claude/agents/*.md` frontmatter.
Impact: Low-severity but recurring maintenance cost; every future frontmatter model change
requires remembering to grep this specific table.
Recommendation: Add a one-line note above the table: "Model column mirrors each agent's
frontmatter `model:` field (see `.claude/agents/<name>.md`) — verify there if this table looks
stale." This won't stop drift but gives the next editor a pointer, consistent with the
CLAUDE.md guidance to prefer symbol/file anchors over restating facts that live elsewhere.

## Dimension-by-Dimension Notes

1. **Architecture Conformance** — N/A for this change; no code layering affected. Frontmatter
   `model:` field changes and prose edits only. Pass.
2. **Design Principles** — N/A; no functions/classes touched.
3. **DRY Compliance** — Checked whether the new tiering rationale is now duplicated
   inconsistently across files (see IV-001, IV-002). The `.claude/commands/hve-prompt-refactor.md:41`
   phrasing and `CLAUDE.md:63` phrasing are consistent with each other and with the actual
   frontmatter. Pass, apart from stale docs above.
4. **API Usage** — Verified `inherit`, `sonnet`, `haiku` are all pre-existing, already-used
   values in this repo's agent frontmatter (`.claude/agents/hve-phase-implementor.md:4`,
   `.claude/agents/hve-plan-validator.md:4`, `.claude/agents/hve-rpi-validator.md:4` all
   predate this change and use these same literals), so no new/invalid frontmatter values were
   introduced. Pass.
5. **Version Consistency** — N/A; no dependency changes.
6. **Refactoring Opportunities** — See IV-003 (anchor table to frontmatter instead of
   duplicating literal values).
7. **Error Handling** — N/A; no executable logic changed.
8. **Test Coverage** — N/A; this repo has no automated test suite for prompt/frontmatter files;
   nothing to newly cover.
9. **Security Posture** — Ran the full grep suite required by CLAUDE.md against
   `git diff --cached` on all 6 changed files: no matches for `PRIVATE KEY`, `api_key\s*=`,
   `password\s*=`, `Bearer `, `-----BEGIN`, `AKIA[0-9A-Z]{16}`, or GCP key patterns. Checked
   `git diff HEAD --name-only` — all 6 changed paths are plain `.md` files, no credential-like
   filenames. `.gitignore` does not currently list `.env`/`*.pem`/`*.key`/`*.p12`/`*.pfx`, but
   this is a pre-existing repo-wide gap unrelated to this change (docs+frontmatter only, no new
   secret-bearing files introduced) — noted for awareness, not scored against this change. No
   new dependencies introduced. Pass.
10. **Overall Quality** — Prose changes are clear, consistent in tone with surrounding
    CLAUDE.md/README.md sections, and the new tiering rationale (mechanical vs. judgment-graded
    vs. inherit) is easy to follow. `CLAUDE.md:63` and `.claude/commands/hve-prompt-refactor.md:41`
    read well together. Pass.
11. **Documentation Integrity (citation check)** — Ran `grep -rl` for "haiku", "sonnet",
    "inherit", "model" across all tracked living docs (README.md, CLAUDE.md, docs/*.md,
    .claude/commands/*.md, .claude/agents/*.md). Found and reported two stale living-doc
    references not included in the original file list: `docs/internals.md` (3 stale table
    rows, IV-001) and `README.md` (2 additional stale lines beyond the row that was updated,
    IV-002). All `--subagent-model` argument-hint references across `.claude/commands/*.md`
    remain correct (they document the override flag, not per-agent frontmatter defaults, and
    are unaffected by this retiering). No new bare `file:line` citations were added to living
    docs by this change — the diffed lines use prose/symbol references consistent with
    convention. `docs/installation.md`, `docs/reference.md`, `docs/workflow.md` contain no
    model-tier claims and are unaffected. Ran clean apart from the two files flagged above.

## Coverage Notes
- Plan-conformance validation was skipped per parent instruction (no RPI plan/research
  artifacts exist for this ad hoc change); findings are validated against the stated intent
  only.
- Test coverage and error-handling dimensions are not applicable — this change touches only
  markdown/frontmatter, no executable code paths.
- `.gitignore` secret-hygiene gap (missing `.env`, `*.pem`, `*.key`, `*.p12`, `*.pfx` entries)
  was observed but is pre-existing and out of scope for this change; flagged here only as an
  awareness note, not counted in the Critical/Major/Minor totals above.
- Documentation citation-check (dimension 11) executed in full across all tracked living docs;
  results are reported above (2 files found stale: docs/internals.md, README.md).

---

## Remediation (2026-07-06)

Both Major findings and the Minor were addressed in the same session, before commit:

- README.md:22 and README.md:65 updated to the haiku/sonnet/inherit split (Major, fixed)
- docs/internals.md model table rows for hve-researcher (Inherit), hve-implementation-validator (Sonnet), hve-prompt-evaluator (Sonnet) updated (Major, fixed)
- docs/internals.md table now carries a source-of-truth note pointing at `.claude/agents/` frontmatter (Minor, fixed)

Post-fix verification: case-insensitive repo-wide grep for "haiku" shows only intentional references (pinned plan/RPI validators, --subagent-model flag syntax, Copilot porting examples). Revised status: Pass.
