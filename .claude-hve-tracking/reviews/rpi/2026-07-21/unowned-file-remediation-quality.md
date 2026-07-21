# Implementation Validation: Unowned-File Convention Remediation — Round 2 (Phases 7-10)
Date: 2026-07-21
Scope: full-quality (all 11 dimensions), re-review after 2026-07-20 review's 3 Major findings (RV-101, Q-201, Q-202)
Files Reviewed: 5 (round-2 scope) — `tests/run-drift-tests.sh`, `.claude/agents/hve-rpi-validator.md`, `.claude/commands/hve-prompt-builder.md`, `docs/internals.md`, `.claude-hve-tracking/details/2026-07-20/unowned-file-remediation-details.md`. Round-1 files (11 more, all `.claude/` prompt/command/agent markdown) touched by the same uncommitted diff were not re-litigated except where round 2 shares lines.

## Summary
Critical: 0 | Major: 1 | Minor: 3

## Verification performed

- Re-ran `bash tests/run-drift-tests.sh` independently: **211 passed, 0 failed**, matching the parent's and the changes log's claim exactly.
- Read the full text of Test 13's rebuilt helpers (`prompt_option_tokens`, `code_span_contents`, `option_resolves`, `tests/run-drift-tests.sh:826-875`) and traced the section-scoping anchor, the three accepted option shapes, and the even-index backtick-splitting logic by hand against representative input.
- Confirmed the memory-store sentence is byte-identical at `.claude/commands/hve-memory.md:87` and `.claude/prompts/checkpoint.md:25`, and that `canonical_block_corpus()` now globs `PROMPTS_DIR` (`tests/run-drift-tests.sh:567`) with the `memory_store_scope` spec registered (`tests/run-drift-tests.sh:561`).
- Confirmed Q-202's rewording (`.claude/agents/hve-rpi-validator.md:50`) explicitly says "against the entire changes log — every `### Phase N:` section in the document, not only this phase's section," which is unambiguous.
- Confirmed the DRY collapse (`.claude/agents/hve-rpi-validator.md:34-35`) leaves exactly one occurrence of the research-absent sentence in the file, and that the shared sentence is byte-identical to `.claude/agents/hve-plan-validator.md:34`'s copy of the same canonical text (details doc `.claude-hve-tracking/details/2026-07-20/unowned-file-remediation-details.md:66-68`).
- Grepped all 5 round-2 files for secret patterns (`PRIVATE KEY|api_key\s*=|password\s*=|Bearer |-----BEGIN|AKIA`) and checked `.gitignore` for `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`.
- Grepped living docs outside `.claude-hve-tracking/` (`docs/internals.md`, `docs/workflow.md`, `docs/reference.md`, `README.md`, `CLAUDE.md`) for citations of the modified files' basenames and checked cited symbols still resolve.
- Did not independently re-run the byte-level mutation test (re-inserting the original `continue`/`suggest`/`Continue` defect lines) since the changes log records it done twice independently (Phase 7 implementor and Phase 10 parent, from separate backups, both producing the expected `[FAIL]` output with the `suggest`-in-prose case specifically proving the resolution rule — not just the extraction anchor — is load-bearing). Traced the code path by hand instead and found it consistent with the recorded output.

## Findings

### IV-001 [TEST-COVERAGE] [MAJOR]
Description: The research-absent branch sentence is explicitly tracked as shared "Canonical wording" across two files (`.claude/agents/hve-rpi-validator.md` and `.claude/agents/hve-plan-validator.md`), byte-identical today, but is not registered in `CANONICAL_BLOCK_SPECS`. This is the same unprotected-duplicate pattern Phase 7 (Q-201) fixed for the memory-store sentence, left open for this pair.
Evidence: `tests/run-drift-tests.sh:550-561` (CANONICAL_BLOCK_SPECS array has no entry for this text); `.claude-hve-tracking/details/2026-07-20/unowned-file-remediation-details.md:66-68` (labeled "Canonical wording... Steps 1.3 and 1.4, both validators"); `.claude/agents/hve-rpi-validator.md:35`; `.claude/agents/hve-plan-validator.md:34`.
Impact: A future edit to either agent's research-absent sentence can silently diverge with no automated check catching it — precisely the recurrence risk Phase 5/7's test infrastructure exists to close.
Recommendation: Add a `research_absent_branch|2|identical|If the parent reports research as absent` entry to `CANONICAL_BLOCK_SPECS` (mode=identical is safe here since the shared core sentence is verified byte-identical today).

### IV-002 [REFACTORING] [MINOR]
Description: `frontmatter_value()`'s key-strip regex (`^[a-z]+:`) cannot parse hyphenated keys. Two independent local workarounds now exist rather than a shared fix.
Evidence: `tests/run-drift-tests.sh:104-116` (regex); `tests/run-drift-tests.sh:717-730` (Test 12's inline awk block for `allowed-tools:`); `tests/run-drift-tests.sh:866-870` (Test 13's `option_resolves()` string-strip for `argument-hint:`).
Impact: A third caller needing a hyphenated-key lookup will likely reinvent a third variant; a future frontmatter format change requires three independent updates instead of one.
Recommendation: Add a `frontmatter_value_hyphenated()` helper (or relax the shared regex to `^[a-z][a-z-]*:`) and have both call sites use it. Already flagged in the changes log as an accepted, documented carry-forward — not a merge blocker, but worth a follow-up ticket rather than a third ad hoc workaround next time.

### IV-003 [TEST-COVERAGE] [MINOR]
Description: `prompt_option_tokens()` strips everything after the first whitespace inside a bold-token match, which truncates multi-word bold labels (not just trailing description text).
Evidence: `tests/run-drift-tests.sh:839-844` — `sub(/[[:space:]].*/, "", token)` runs on the substring already extracted from `^- \*\*[^*]+\*\*`, so `- **Two Words**` would yield `Two`, not `Two Words`.
Impact: Currently dormant — no live prompt file has a multi-word bold mode label after M-10 removed checkpoint.md's `## Modes` section entirely. A future bold mode name with an internal space would silently truncate and could produce an incorrect resolve/no-resolve verdict.
Recommendation: Match `^- \*\*([^*]+)\*\*` and take the captured group verbatim, without a subsequent whitespace strip, for the bold-token shape specifically.

### IV-004 [OVERALL-QUALITY] [MINOR]
Description: `option_resolves()`'s resolution check is a plain substring test against the frontmatter hint and code-span contents, not boundary-anchored.
Evidence: `tests/run-drift-tests.sh:871` (`"${hint}" == *"${token}"*`) and `tests/run-drift-tests.sh:874` (`grep -qF -- "${token}"`).
Impact: A token that is a substring of a different, unrelated real option (e.g., a hypothetical `--think` resolving off a `--rethink` hint) would false-resolve. Not observed in the live six-file corpus — all 17 real tokens resolve correctly and the recorded mutation runs correctly fail on invented/original defect tokens — but the test would not catch this narrower false-positive class if introduced later.
Recommendation: Anchor resolution with word/token boundaries (split hint and code-span text on whitespace/backticks and compare exact tokens) to match the rigor already applied to `code_span_contents()`'s backtick-pairing fix.

## Security Findings

No Critical or Major security issues.

- Secret-pattern grep (`PRIVATE KEY|api_key\s*=|password\s*=|Bearer |-----BEGIN|AKIA`) across all 5 round-2 files: 2 hits, both in `docs/internals.md:59-60`, both pre-existing documentation of the scanner's own pattern list (`hve-implementation-validator`'s dimension 9 description), confirmed identical against `git show HEAD:docs/internals.md` and outside this task's diff to that file. Dismissed as pre-existing false positives, consistent with the changes log's own investigation.
- `.gitignore` hygiene: `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` all present (lines 21-25).
- No new dependencies introduced; no `npm install` / `pip install` additions.
- No SQL/XSS surface — this change is entirely markdown prompt/agent/command text plus bash test code with no network or database I/O.
- `git status --short`: no stray backup/temp files left in the repo from the mutation testing described in the changes log (backups were written to the session scratchpad, outside the repo).

Status: **Pass**.

## Coverage Notes

- **Architecture / Design Principles**: N/A-clean. New helpers (`prompt_option_tokens`, `code_span_contents`, `option_resolves`) each do one job, extend the existing Test 1-12 pattern in the same file without modifying it (Open/Closed respected), and are placed consistently with the file's established test-numbering convention.
- **API Usage / Version Consistency**: N/A — pure bash/awk, no external library calls, no dependency changes in this round.
- **Error Handling**: Checked — the zero-option case (`checkpoint.md`) is handled as an explicit pass with a distinct message rather than silently skipped or failing; missing mapped files fail loudly (`tests/run-drift-tests.sh:885-893`).
- **Documentation Integrity / living-doc citation check**: Ran clean. Grepped `docs/internals.md`, `docs/workflow.md`, `docs/reference.md`, `README.md`, `CLAUDE.md` for citations of `run-drift-tests.sh`, `hve-rpi-validator.md`, and `hve-prompt-builder.md`. `docs/internals.md:23,39` cites `hve-rpi-validator` by symbol (agent name), consistent with round-1 content, unaffected by round 2's line-50/34-35 edits since those are body-internal instructions, not symbols cited elsewhere. `docs/internals.md:25`'s round-2 edit (Template Integrity criterion) anchors to the criterion name and agent name, no bare `file:line` citation introduced — compliant with the living-docs convention. No dead or renamed references found; no new bare line-number citations added to any living doc.
- **DD-008 correction**: Verified present and correctly formatted at `.claude-hve-tracking/details/2026-07-20/unowned-file-remediation-details.md:38-50` — the stale canonical block is annotated `(superseded — see Correction 2026-07-20)` in place and a dated Correction entry explains the change, per the CLAUDE.md corrections convention. The ownership-respecting escalation (Phase 8 declining to edit a details doc it doesn't own; parent applying the correction in Phase 10) is exactly the desired behavior.
- **ShellCheck**: Not run — not installed in this environment (`command -v shellcheck` returns nothing). Recorded as a skip by the changes log, not claimed as a pass; consistent with what I could independently verify (I did not attempt to install it).
- **Round-1 files**: Not re-validated in this pass except where round 2 shares lines (`hve-rpi-validator.md`, `hve-prompt-builder.md`). No new findings raised against round-1-only content.
