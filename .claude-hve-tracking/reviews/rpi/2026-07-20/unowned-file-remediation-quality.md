# Implementation Validation: Unowned-File Convention Remediation
Date: 2026-07-20
Scope: full-quality (all 11 dimensions)
Files Reviewed: 16

## Summary
Critical: 0 | Major: 2 | Minor: 3

## Findings

### IV-001 [TEST-COVERAGE] [MAJOR]
Description: This task introduced a new byte-identical canonical wording block duplicated across two files in different directories (the per-project native-memory sentence, Steps 3.5/4.3 in the plan), but did not register it in Test 10's `CANONICAL_BLOCK_SPECS`, and Test 10's corpus function cannot see one of the two carriers even if it were registered.
Evidence: `.claude/commands/hve-memory.md:87` and `.claude/prompts/checkpoint.md:25` carry the identical sentence "Also write the most non-obvious decisions and patterns to the Claude Code native memory store for this project (`~/.claude/projects/<project-slug>/memory/`). The store is per-project, not global: entries written here surface only in future sessions on this same project." `tests/run-drift-tests.sh:544-555` (`CANONICAL_BLOCK_SPECS`) has no entry for this text, and `canonical_block_corpus()` at `tests/run-drift-tests.sh:558-564` only globs `${COMMANDS_DIR}/*.md` and `${AGENTS_DIR}/*.md` — `.claude/prompts/` is never in the corpus, confirmed by `grep -n PROMPTS_DIR tests/run-drift-tests.sh` showing only Test 13 and the preflight check use it.
Impact: A future edit to either copy (e.g. correcting the memory-store path again) will silently desync the other, reproducing the exact class of drift Test 10 exists to prevent — and this exact task is the one that spent Phase 5 explicitly closing two other escaped drift classes (M-02, M-07/M-10). The gap is invisible until the next `/hve-doc-ops` or manual audit catches it.
Recommendation: Add a `memory_store_wording|2|identical|Also write the most non-obvious decisions` entry to `CANONICAL_BLOCK_SPECS`, and extend `canonical_block_corpus()` to also glob `${PROMPTS_DIR}/*.md` (or add a second corpus function) so cross-directory canonical blocks are actually checkable.

### IV-002 [ERROR-HANDLING] [MAJOR]
Description: The new "unlisted changes" check does not scope the parent-supplied changed-file list to the phase being validated, and the changes log it is compared against is ambiguous between "the whole document" and "the phase-extracted subset" — for a multi-phase task like this one's own changes log (disjoint per-phase file sets), the phase-scoped reading produces false positives on every sibling phase's legitimately-owned files.
Evidence: `.claude/agents/hve-rpi-validator.md:33` ("extract all changes claimed for the specified phase") sets up phase-scoped working data; `.claude/agents/hve-rpi-validator.md:50` ("Compare the parent-supplied changed-file list against the changes log...") never states whether "the changes log" means the full multi-phase document or the phase-scoped extraction from line 33, while `.claude/commands/hve-review.md:83,93` confirms the changed-file list itself is always the full, un-scoped `git diff --name-only <base>` output shared identically across every parallel per-phase dispatch.
Impact: Run against this task's own changes log (16 files across Phases 1-5, disjoint per phase), a phase-scoped reading of line 50 would cause the Phase 1 validator to flag Phase 2-5's 12 files as "unlisted changes" (and vice versa for each other phase), inflating Critical/Major counts that `hve-review.md:95` then copies "in full text" into the consolidated review log without a documented dedup step.
Recommendation: Reword `hve-rpi-validator.md:50` to state explicitly: "against the full changes log across all phases, not just the phase being validated" — and add a parent-side dedup note in `hve-review.md`'s Phase 2 consolidation step for when multiple phase validators report the same globally-unlisted file.

### IV-003 [DRY] [MINOR]
Description: Pre-requisite item 4 in `hve-rpi-validator.md` states the research-absent rule twice in immediate succession — once as the main numbered item, once as a verbatim indented restatement of the plan's canonical wording underneath it.
Evidence: `.claude/agents/hve-rpi-validator.md:34-35` — line 34 paraphrases the rule ("skip requirement extraction and record that the phase was validated against the plan alone"), line 35 repeats the full canonical sentence verbatim as a sub-bullet.
Impact: Low — both statements agree, so no behavioral risk, but the redundant restatement adds noise and is a plausible future drift point if one copy is edited and the other isn't (there is no test coverage for this pair either, compounding IV-001's pattern).
Recommendation: Collapse to one statement — keep the canonical-wording sub-bullet and shorten line 34 to a plain step label, or vice versa.

### IV-004 [OVERALL-QUALITY] [MINOR]
Description: `hve-prompt-builder.md`'s Phase 2 loop retains a leftover "After both subagents complete" sentence from the pre-fix parallel-dispatch design, immediately after Step B already says "After the tester completes, spawn the evaluator" — the sequencing is now stated three times with slightly different framing across Steps A, B, and the closing sentence.
Evidence: `.claude/commands/hve-prompt-builder.md:42` ("wait for it to complete before evaluating"), `:52` ("After the tester completes, spawn the ... evaluator"), `:61` ("After both subagents complete, read both output logs").
Impact: Purely readability — a new contributor reading `:61` in isolation could momentarily wonder if Step B is still parallel with something, since "both ... complete" reads as a parallel-join idiom.
Recommendation: Reword `:61` to "After the evaluator completes, read both output logs" to match the sequential framing established at `:52`.

### IV-005 [DOCUMENTATION] [MINOR]
Description: `docs/internals.md`'s subagent-roster table description of `hve-prompt-evaluator` is now incomplete: it lists the pre-existing four criteria but omits the new Template Integrity criterion this task added.
Evidence: `docs/internals.md:25` — "Rates draft prompts against clarity / completeness / format / no-Copilot criteria" versus `.claude/agents/hve-prompt-evaluator.md:56-59` which adds a fifth criteria section (`### Template Integrity`) and `.claude/agents/hve-prompt-evaluator.md:76,84` which add the `TEMPLATE` tag and `Template integrity: Pass/Fail` line to the output template.
Impact: Low — this is a living-doc prose summary, not a symbol citation, so no test currently guards it and none is expected to; a contributor reading `docs/internals.md` alone would not know the evaluator also checks template blanks.
Recommendation: Append "/ template-integrity" to the `docs/internals.md:25` cell description.

## Coverage Notes

- **Architecture / Design Principles**: Pass. File-set ownership matches the details-doc map exactly (`git diff HEAD --name-only` diffed byte-for-byte against the 16-file ownership list — no drift). Subagent Dispatch Discipline, citation format, and Template Blanks conventions are all respected in the edits reviewed.
- **DRY**: One redundancy found (IV-003); the three deliberately-shared canonical wording blocks (research-absent, per-project memory, pull-request header) were checked and are byte-identical or consistent-with-intended-variance across all carriers.
- **API Usage**: N/A in the traditional sense — no external library calls were touched. Frontmatter `allowed-tools` values and `hve-*` agent-name references in the diffed files all resolve; confirmed live via `bash tests/run-drift-tests.sh` (Test 9 and the new Test 12 both green).
- **Version Consistency**: No dependency files touched; not applicable to this change set.
- **Refactoring Opportunities**: IV-004 is the only finding.
- **Error Handling**: IV-002 is the substantive finding. The research-absent branches (Steps 1.3/1.4) and the doc-ops argument-hint independence fix (Step 3.3) were checked and correctly cover their stated failure cases.
- **Test Coverage**: `bash tests/run-drift-tests.sh` reproduced independently: 207 passed, 0 failed, matching the parent's 2026-07-21T05:09Z observation and the changes log's Phase 6 record. Mutation evidence in the changes log (Mutation A/B) was read and is consistent with the test code at `tests/run-drift-tests.sh:710-844`. IV-001 is the one coverage gap found; it is a gap in the new test file itself, not in application code.
- **Security**: Pass, independently re-run. Secret-pattern grep across all 16 changed files: no matches. `.gitignore` carries `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`. `git diff HEAD --name-only` shows only the expected 16 markdown/bash files — no credential-like filenames. No new dependencies added.
- **Overall Quality**: Generally clear, consistent naming, appropriately scoped edits. IV-004 is the only readability nit.
- **Documentation Integrity (dimension 11)**: Ran the citation check across tracked living docs (`README.md`, `CLAUDE.md`, `docs/internals.md`, `docs/workflow.md`) for every basename among the 16 modified files. No new bare `file:line` citations were introduced into any living doc by this task's diff (`git diff HEAD -- <all 16 files> | grep -E '^\+' | grep -E '\.md:[0-9]'` returned nothing). One stale prose description found and flagged (IV-005); all other citing references (symbol/behavior mentions in `docs/workflow.md`, `docs/internals.md`, `README.md`, `CLAUDE.md`) were checked against the current file bodies and still resolve correctly — the `continue`/`suggest` removal from `rpi.md`, the PR-description removal from `pull-request.md`, and the checkpoint Modes rewrite have no dangling references elsewhere in living docs (checked via targeted grep for each removed term). Untracked root-level blog/writeup `.md` files (`blog-*.md`, `2026-06-12-*.md`, per `git status`) were excluded from this check per CLAUDE.md's "tracked" qualifier — flagging for awareness only, not as a finding.
