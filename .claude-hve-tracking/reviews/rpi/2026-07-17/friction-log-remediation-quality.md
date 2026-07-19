# Implementation Validation: Friction Log Remediation
Date: 2026-07-17
Scope: full-quality (all 11 dimensions)
Files Reviewed: 15 modified + 2 new files (17 total)

## Summary
Critical: 0 | Major: 1 | Minor: 4

## Findings

### IV-001 [TEST-COVERAGE] [MAJOR]
Description: Phase 8's drift-test suite (`tests/run-drift-tests.sh`) protects only 2 of at least 6 canonical text blocks that this remediation deliberately duplicated across multiple files. Four additional byte-identical blocks currently agree by luck, not by test:
- The "Discover inputs per the Artifact Discovery & Relevance convention..." stub, duplicated in three command files
- The `**Concurrent writes**:` rule, duplicated in CLAUDE.md + the implement command + the phase-implementor agent
- The `Started: [run \`date -u ...\`]` timestamp template, duplicated in the implement command + the phase-implementor agent
- The `Tests: X passed, Y failed` / N/A / not-run template, duplicated in the same two files
Evidence: `.claude/commands/hve-plan.md:25`, `.claude/commands/hve-challenge.md:25`, `.claude/commands/hve-review.md:25` (identical stub, confirmed via grep); `CLAUDE.md:319`, `.claude/commands/hve-implement.md:109`, `.claude/agents/hve-phase-implementor.md:48` (concurrent-writes rule); `.claude/commands/hve-implement.md:57`, `.claude/agents/hve-phase-implementor.md:79` (timestamp); `.claude/commands/hve-implement.md:122`, `.claude/agents/hve-phase-implementor.md:107` (test-count). `tests/run-drift-tests.sh` Test 5/6 only cover the `--subagent-model` and `--friction-log` paragraphs (lines 285, 329).
Impact: A future edit to any of these four blocks in one carrier file (e.g. fixing a typo in the timestamp instruction) will silently diverge from its sibling copies with no test catching it — the exact self-referential O-12 failure mode (documented in this task's own Risk Log) that Phase 8 exists to prevent.
Recommendation: Add drift-test coverage for these four blocks using the same `extract_line`-and-compare technique already built for Test 5/6, or explicitly record the residual risk in the plan/details doc if intentionally out of scope.

### IV-002 [DRY / TEST-COVERAGE] [MINOR]
Description: `install.sh:92-96` and `tests/lib/instruction-files.sh:5-20` hand-duplicate the `HVE_INSTRUCTION_FILES` array (same 14 filenames, different formatting) with no automated check that the two stay in sync.
Evidence: `install.sh:92` vs `tests/lib/instruction-files.sh:5` — `diff` shows only whitespace/line-wrap differences today, but nothing enforces continued agreement. Same pattern for `HVE_PROMPT_FILES` (`install.sh:135` vs `tests/lib/prompt-files.sh:5`).
Impact: A future instruction or prompt file addition that updates one array but not the other would pass silently until a real install drifted.
Recommendation: Add a Test 10 to `run-drift-tests.sh` comparing the sorted contents of both arrays. Already flagged by the implementor as a deferred follow-up (changes log, "Deferred / Out-of-Scope Follow-ups" item 3) — recorded, not hidden, but still open.

### IV-003 [DOCUMENTATION] [MINOR] [pre-existing]
Description: `docs/internals.md:49` states "The quality validator always runs these 10 checks" and enumerates 10 items, omitting dimension 11 (Documentation Integrity), which `.claude/agents/hve-implementation-validator.md` defines (its own header reads "The Eleven Validation Dimensions") and which `hve-review.md` Phase 3 explicitly lists as dimension 11.
Evidence: `docs/internals.md:49-64`; `.claude/agents/hve-implementation-validator.md:8` ("eleven validation dimensions"); `.claude/commands/hve-review.md:118` ("11. Documentation integrity"). `git diff HEAD -- docs/internals.md` shows this task's only edit to the file was adding the `hve-pr-reviewer` table row — the dimension-count staleness predates this remediation.
Impact: A contributor reading internals.md would not know the validator (this agent) checks documentation-citation rot; low impact since CLAUDE.md and the agent file are both correct, but internals.md is the one place a new contributor is pointed to for "the quality-validator dimensions."
Recommendation: Update the list to 11 items, or replace the restated count with a pointer to the agent file's own header (avoids future drift on this exact number).

### IV-004 [DOCUMENTATION] [MINOR] [pre-existing]
Description: `.claude/prompts/pull-request.md:26-27` still documents `--dimension security` / `--dimension all` as the only two examples, while `hve-pr-review.md`'s Phase 2 body implements `--dimension all` (all 8) and `--compact` (4 pairs) but has no branch handling a single non-"all" dimension value.
Evidence: `.claude/prompts/pull-request.md:26-27`; `.claude/commands/hve-pr-review.md:87-113` (only "Default mode" and "Compact mode" are implemented).
Impact: Low — a user passing `--dimension security` alone would get undefined behavior, but this predates the current diff (confirmed via `git diff HEAD -- .claude/commands/hve-pr-review.md`: the prior version had the identical gap) and is already recorded by the implementor as DR-901's related follow-up and in the "Deferred / Out-of-Scope Follow-ups" section.
Recommendation: No action needed this session; tracked correctly already. Surfacing here only so the deferred item is visible in the quality gate, not to duplicate the tracking.

### IV-005 [ARCHITECTURE] [MINOR] [pre-existing]
Description: `hve-pr-review.md`'s frontmatter `allowed-tools: Read, Glob, Grep, Bash, Agent` omits `Write`, despite the command needing to create `diff.patch` and the review markdown file (Phase 1 steps 5, 7).
Evidence: `.claude/commands/hve-pr-review.md:4`. Confirmed unchanged by this diff via `git show HEAD:.claude/commands/hve-pr-review.md` (identical line before Phase 6's edits).
Impact: Likely non-blocking in practice — the command can create both files via Bash redirection (`git diff ... > diff.patch`, heredoc for the review file) without needing the dedicated Write tool — but it is inconsistent with `hve-review.md`'s frontmatter, which explicitly lists `Write`. Phase 6 touched this file's tool-boundary language (the parent-shell rule, Block 9) without auditing its own tool list.
Recommendation: Add `Write` to the frontmatter for consistency with sibling review commands, or note explicitly that file creation is Bash-only by design.

## Coverage Notes

- **Documentation citation check (Dimension 11) — ran clean for the two new files.** `.claude/instructions/javascript.md` and `.claude/instructions/typescript.md` contain no `file:line` citations or symbol anchors (none needed — they are style-rule references, not living docs describing other code), so there is nothing to rot. `docs/internals.md`'s only new content (the `hve-pr-reviewer` table row) is correct and matches the new agent file. The one documentation-integrity gap found (IV-003) is pre-existing staleness in a section this diff did not touch.
- **Security (Dimension 9) — ran clean.** Grepped all changed/new files for `PRIVATE KEY|api_key\s*=|password\s*=|-----BEGIN|Bearer |AKIA`: no matches. `.gitignore` carries `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`. `git diff HEAD --name-only` contains no credential-like filenames. No new dependencies introduced (confirmed: no package.json/requirements.txt changes).
- **API usage / version consistency (Dimensions 4–5) — not applicable.** This change set is documentation/prompt/bash-test only; no library APIs or dependency versions are touched.
- **Test coverage (Dimension 8) — verified live.** Re-ran both suites: `tests/run-drift-tests.sh` → 125 passed, 0 failed; `tests/run-install-tests.sh` → 48 passed, 0 failed. Confirmed all 5 new Phase 8 test groups (5–9) genuinely assert non-trivial conditions (carrier counts, byte-identity, bidirectional table sync, agent-roster resolution) rather than trivially passing — see IV-001 for the gap in what they *don't* yet cover.
- **DRY (Dimension 3) — intentional duplication respected.** Did not flag the deliberately duplicated canonical blocks (per task instructions); instead audited which ones lack drift-test protection (IV-001, IV-002).
- **Refactoring opportunities (Dimension 6) — minor style note only, not written up as a separate finding:** `tests/run-drift-tests.sh`'s `FULL_PROTOCOL_AGENTS` is a space-delimited string iterated with unquoted word-splitting (`for stem in ${FULL_PROTOCOL_AGENTS}`) rather than a bash array like `carriers` elsewhere in the same file; consistent but non-idiomatic given the array pattern used two functions later.
