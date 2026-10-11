# Research: CLAUDE.md Lean Restructure

Date: 2026-08-19
Task slug: claude-md-lean-restructure
Confidence: HIGH overall

Scope: /Users/kevin/GitHub/hve-claude/CLAUDE.md (project file) only. ~/.claude/CLAUDE.md was touched once as an out-of-scope comparison point (staleness observation, Finding 2 under "Dual role"). No changes are proposed to it or to any other project's CLAUDE.md.

Note: the three per-theme subagent artifacts under research/subagents/2026-08-19/ are gitignored; this document carries everything durable.

## Summary

CLAUDE.md is simultaneously this repo's session context and the literal install payload: install.sh extracts everything above `## Your Project` and merges it into every consuming project (install.sh:171). Roughly 80 of its 399 lines are non-operational for a session (preamble narrative, Hooks docs, Installing docs), while 15 headings and 5 canonical text blocks are frozen by the drift-test suite and cannot be renamed or moved carelessly. The lean restructure is therefore a product change under the risk override (CLAUDE.md:30): remove ~65 lines to docs/, slim the Command Reference rows, fill the empty `## Your Project` with this repo's own context (payload-safe below the sentinel), and document the producer-side payload contract that currently lives only in install.sh comments.

## Hypothesis Verdicts

- PA-001 PARTIALLY CONFIRMED: CLAUDE.md:5 is verbatim README.md:5; CLAUDE.md:3 and :11 paraphrase README.md:3/:13. But "lines 1-11" overreaches: line 9 is the load-bearing `## The RPI Methodology` heading (pointer from .claude/commands/hve-implement.md:101) and operational content starts at line 13. Only lines 1-5 and 11 are relocatable narrative. [HIGH]
- PA-002 CONFIRMED AND STRENGTHENED: `## Installing HVE in Your Project` spans CLAUDE.md:341-386 (46 lines incl. subsection), duplicating README.md:205-248 and docs/installation.md:110-120. Because the section sits inside the payload, it costs context in every installed project, not just here. Relocation caveat: CLAUDE.md:76 anchors to `#tracking-folder--version-control` (target CLAUDE.md:368). [HIGH]
- PA-003 CONFIRMED WITH NUANCE: `## Your Project` (CLAUDE.md:388-399) is a placeholder HTML comment only. The Template Blanks rule (CLAUDE.md:208-210) targets unobtainable blanks; this blank is obtainable (tests documented at CONTRIBUTING.md:21, :33), so it is a spirit violation with real cost: sessions here are never told the test commands or key files. Filling below the heading never ships (install.sh:171 cuts before it). [HIGH]
- PA-004 CONFIRMED WITH LIVE DRIFT: the Command Reference table (CLAUDE.md:38-58) restates flag semantics that live in .claude/commands/*.md, no drift test covers the table (tests 1-16 enumerated at tests/run-drift-tests.sh:10-50 never check it), and one drift exists today: the /hve-plan row and hve-plan.md:41 promise "full = parallel validation" while hve-plan.md:131,139 dispatch one validator sequentially (matches the feature deferred 2026-08-15). All other flag rows currently agree, so the risk is structural, not widespread divergence. [HIGH]
- PA-005 CONFIRMED, REFINED: install.sh:171 extracts the payload via `awk '/^## Your Project/{exit} {print}'` and adds HVE:START/HVE:END markers at install time (install.sh:180-183); the repo file itself has no markers. The consumer-side merge is documented (CLAUDE.md:341-366, docs/installation.md:16-22), but the producer-side contract ("edit above the line and you edit every future install"; `## Your Project` is an awk sentinel whose rename breaks install.sh and the docs prompts) exists only in install.sh:167-170 comments. Nothing in CLAUDE.md documents the dual role. [HIGH]

## Key Findings

### Dual role governs the whole restructure

- Everything above CLAUDE.md:388 is shipped product; a restructure is consumed outside this repo, so the risk override applies (CLAUDE.md:30, README.md:36). [HIGH]
- The `## Your Project` heading is a load-bearing extraction sentinel (install.sh:171, docs/installation.md:16-22, tests/run-prompt-new-install.sh:84-91); it must remain the final heading, byte-exact. [HIGH]
- Installed copies drift until reinstall: the ~/.claude global copy observed this session (out-of-scope comparison only) is an older block lacking `*.pfx` in Security Hygiene and the Untrusted Input section. Every fact duplicated into the payload compounds this staleness cost. [HIGH]

### Test-enforced constraints (must survive any restructure)

- Heading freeze: every "per CLAUDE.md's `X` section" pointer must resolve to a real CLAUDE.md heading (test 14, tests/run-drift-tests.sh:960-1015). Referenced headings: The RPI Methodology, Friction Capture, Artifact Discovery & Relevance, Corrections in Tracking Artifacts, Subagent Dispatch Discipline, Subagent Response Protocol, Security Hygiene, Severity Grading, Concurrent Changes-Log Writes, Confidence Markers, Instructions Reference, Template Blanks, Untrusted Input, Citation Format, plus Model Selection via test 3 (tests/run-drift-tests.sh:233-249). [HIGH]
- Sole-copy blocks: five canonical blocks must appear exactly once in the corpus, and CLAUDE.md is that carrier: Artifact Discovery stub, Concurrent Changes-Log Writes, Friction Capture, Security Hygiene checklist, shell-stays-in-parent (test 10, tests/run-drift-tests.sh:569-584). Rewording or duplicating them fails the suite. [HIGH]
- Pinned literal: test 15 pins the exact string "per CLAUDE.md's `Artifact Discovery & Relevance` section" in artifact-discovering commands (tests/run-drift-tests.sh:1044). [HIGH]
- Machine-parsed content: the Instructions Reference table syncs bidirectionally with .claude/instructions/ (test 8, tests/run-drift-tests.sh:452-498); the Security Hygiene `.gitignore hygiene` bullet is parsed and its credential list must agree with README, docs/installation.md, and install.sh (test 16, tests/run-drift-tests.sh:1116-1126). [HIGH]
- Unprotected gap: Mid-Flow Scope Changes (CLAUDE.md:257-259) is a sole copy with zero pointers and zero test coverage; deletion would silently kill the "Requirements added after <phase>" behavior. Slug-derivation rules in Artifact Naming share this profile. [HIGH]

### Section inventory (RQ1)

Classification: (a) operational every session here; (b) narrative duplicated in README; (c) install docs for adopters; (d) human-browsed reference. Everything above line 388 is also payload.

| Section | Lines | ~LOC | Class | Notes |
|---|---|---|---|---|
| Preamble (title, pitch, attribution) | CLAUDE.md:1-7 | 7 | (b) | :5 verbatim = README.md:5; :3 paraphrases README.md:3 |
| The RPI Methodology | CLAUDE.md:9-36 | 28 | mixed | :11 is (b); :13-34 (principles, difficulty table, risk override, effort) are (a); heading frozen |
| Command Reference | CLAUDE.md:38-60 | 23 | mixed (a)/(d) | Rows at :42 and :47 run 400-500 chars; overlaps README.md:116-201; command files are ground truth (CONTRIBUTING.md:37-39) |
| Model Selection | CLAUDE.md:62-72 | 11 | (a) | Frozen by test 3; README.md:146 defers here |
| Tracking Folder Structure | CLAUDE.md:74-105 | 32 | (a) | Tree near-duplicated at docs/reference.md:6+; :76 anchors to :368 |
| Friction Capture | CLAUDE.md:107-113 | 7 | (a) | Frozen heading; sole-copy block |
| Artifact Naming Conventions | CLAUDE.md:115-130 | 16 | (a) | Slug rule is sole copy, unreferenced |
| Severity Grading | CLAUDE.md:132-144 | 13 | (a) | Frozen heading |
| Confidence Markers | CLAUDE.md:146-156 | 11 | (a) | Frozen heading |
| Corrections in Tracking Artifacts | CLAUDE.md:158-167 | 10 | (a) | Frozen heading |
| Citation Format | CLAUDE.md:169-183 | 15 | (a) | Frozen; living-docs rule is sole copy |
| Subagent Response Protocol | CLAUDE.md:185-198 | 14 | (a) | Frozen; also restated in all 9 agents (test 7) |
| Subagent Dispatch Discipline | CLAUDE.md:200-206 | 7 | (a) | Frozen; sole-copy block |
| Template Blanks | CLAUDE.md:208-212 | 5 | (a) | Frozen; the rule PA-003 invokes |
| Handoff Block Format | CLAUDE.md:214-230 | 17 | (a) | Boxes restated verbatim in 4 commands; no test pins them |
| Context Management Between Phases | CLAUDE.md:232-239 | 8 | (a) | Paraphrased at README.md:108-112 |
| Artifact Discovery & Relevance | CLAUDE.md:241-255 | 15 | (a) | Frozen; sole-copy stub; literal pointer pinned by test 15 |
| Mid-Flow Scope Changes | CLAUDE.md:257-261 | 5 | (a) | Sole copy, UNREFERENCED, untested |
| Instructions Reference | CLAUDE.md:263-288 | 26 | (a) | Frozen; table machine-parsed both directions (test 8) |
| Security Hygiene | CLAUDE.md:290-301 | 12 | (a) | Frozen; canonical credential list (test 16) |
| Untrusted Input | CLAUDE.md:303-311 | 9 | (a) | Frozen; sole copy of the rules |
| Concurrent Changes-Log Writes | CLAUDE.md:313-317 | 5 | (a) | Frozen; sole-copy block |
| Optional Power-User: Hooks | CLAUDE.md:319-339 | 21 | (d) | Zero references from .claude/; docs candidate |
| Installing HVE in Your Project | CLAUDE.md:341-366 | 26 | (c) | Duplicates README.md:205-209, docs/installation.md:110-120 |
| Tracking folder & version control | CLAUDE.md:368-386 | 19 | mixed (c)/(a) | Gitignore policy operational for consumers; anchor target of :76; artifacts-committed policy is deliberate |
| Your Project | CLAUDE.md:388-400 | 13 | (a) intended, empty | Placeholder comment; payload cut-off sentinel |

Net: ~80 of 399 lines are non-operational for sessions in this repo (preamble 1-5 and 11, Hooks 319-339, Installing 341-386 minus the gitignore policy worth keeping); ~320 lines are operational or load-bearing. [HIGH]

### Duplication matrix (RQ2)

| Content | CLAUDE.md | Other file | Form | Authoritative |
|---|---|---|---|---|
| MIT attribution | :5 | README.md:5 | verbatim | README.md; a one-line provenance note in the payload may be intentional [MEDIUM] |
| Pitch / RPI rationale | :3, :11 | README.md:3, 11-22 | paraphrase | README.md [MEDIUM] |
| Difficulty table | :23-28 | README.md:101-106 | paraphrase | CLAUDE.md (drives dispatch) [MEDIUM] |
| Command table + flag semantics | :38-58 | README.md:116-201; .claude/commands/*.md | mixed; :43 clause verbatim = README.md:123 | .claude/commands/*.md are ground truth (drift-tested); both tables are derived copies [HIGH] |
| Model selection | :62-70 | README.md:66, 146 | README defers | CLAUDE.md [HIGH] |
| Tracking folder tree | :78-103 | docs/reference.md:6+ | near-duplicate | CLAUDE.md operational; docs copy drift-prone, unverified match [MEDIUM] |
| Context management | :232-239 | README.md:108-112 | paraphrase | CLAUDE.md [MEDIUM] |
| Installer usage | :343-361 | README.md:205-209; docs/installation.md:110-120 | paraphrase | docs/installation.md (README already defers at README.md:58, 207) [HIGH] |
| Tracking gitignore block | :375-376 | README.md:238-239 | verbatim | Policy stays in payload wherever it lands; never recommend untracking the folder [MEDIUM] |
| Credential patterns | :295, 358-360 | README.md:44, 248; docs/installation.md:26, 89-94; install.sh | enforced agreement | CLAUDE.md Security Hygiene is canonical (test 16) [HIGH] |

CONTRIBUTING.md exists (156 lines), covers branch strategy and tests only, zero overlap with CLAUDE.md. [HIGH]

### RPI hard dependencies (RQ3)

- Blanket: every command and agent opens with "Read and follow all HVE conventions in CLAUDE.md" (e.g. .claude/commands/hve.md:9, .claude/agents/hve-researcher.md:11), so the file as a whole is load-bearing. [HIGH]
- Deletion-orphan risk concentrates in the pointer-only sole copies: Artifact Discovery & Relevance, Untrusted Input, Subagent Dispatch Discipline, Friction Capture, Concurrent Changes-Log Writes, Template Blanks, Security Hygiene checklist (all caught by tests 10/14/15 if broken), plus Mid-Flow Scope Changes and slug derivation (caught by nothing). [HIGH]
- Redundantly restated and safe to treat as spec-plus-copies: Subagent Response Protocol (all 9 agents, test 7), Handoff boxes (4 commands, untested), severity definitions (2 agents; hve-implementation-validator.md:99-101 carries an uncontrolled wording variant). [HIGH]
- .claude/instructions/*.md contain zero CLAUDE.md references. docs/internals.md:10-12 calls CLAUDE.md the single source for behavioral invariants. [HIGH]

### What is missing (RQ4): draft `## Your Project` content

All facts citable; the filled section is payload-safe below the sentinel. Draft (~15 lines):

- Stack: markdown prompt artifacts are the product: 15 commands (.claude/commands/), 9 agents (.claude/agents/), 14 instruction files, 6 prompts, plus install.sh (bash, 280 lines) and bash test suites (tests/, 2389 lines). No package manager, no CI, no Makefile. [HIGH]
- Product boundary: everything above `## Your Project` ships verbatim into consuming projects (install.sh:171); treat CLAUDE.md and .claude/ edits as externally consumed (risk override, classify at least Medium). [HIGH]
- Tests: `./tests/run-install-tests.sh` and `./tests/run-drift-tests.sh` from repo root, offline, seconds; run after any edit to .claude/, CLAUDE.md, README.md, docs/, or install.sh; count deltas are intentional-or-regression (CONTRIBUTING.md:21, :33, :45). [HIGH]
- Interactive prompt tests (tests/run-prompt-new-install.sh, tests/run-prompt-upgrade.sh) need dev pushed to GitHub plus Claude Code; not part of the routine gate (CONTRIBUTING.md:55, :62). [HIGH]
- Branch flow: feature/* -> dev -> main (CONTRIBUTING.md:8). [HIGH]
- Deliberate duplication: canonical blocks are byte-identical across carriers and drift-tested; never reword one copy alone; heading renames must update every "per CLAUDE.md's ..." pointer (tests/run-drift-tests.sh:15-33). [HIGH]
- Tracking folder committed by design; only subagents/ and sandbox/ gitignored (CLAUDE.md:370-376). [HIGH]

### Target structure proposal (RQ5)

Design rule derived from the evidence: the payload region should carry only what a consuming project's sessions need every turn; everything whose audience is a human on GitHub or an adopter running the installer moves to README/docs; everything whose audience is only THIS repo moves below the sentinel. [HIGH on the rule; dispositions individually marked]

| # | Section | Disposition |
|---|---|---|
| 1 | Preamble | Trim to 2-3 lines: one operational framing line, one MIT provenance line, plus a new 2-3 line producer-side payload note (everything above `## Your Project` ships via install.sh) [MEDIUM on wording, HIGH on adding the payload note] |
| 2 | The RPI Methodology | Keep; drop the :11 narrative paraphrase [HIGH] |
| 3 | Command Reference | Slim rows to purpose + when-to-use; move flag semantics to a pointer ("flags: see .claude/commands/<name>.md"), resolving PA-004 structurally. Alternative kept open: retain semantics and add a drift test shaped like test 13. [MEDIUM, needs user decision] |
| 4 | Model Selection | Keep unchanged (test 3) [HIGH] |
| 5 | Tracking Folder Structure | Keep; absorb the gitignore policy lines from :368-386 so the :76 forward anchor dies naturally [MEDIUM] |
| 6 | All convention sections (Friction Capture ... Concurrent Changes-Log Writes) | Keep verbatim, headings frozen; do not reword sole-copy blocks (tests 10/14/15) [HIGH] |
| 7 | Optional Power-User: Hooks | Move to docs/reference.md; zero machinery references [HIGH] |
| 8 | Installing HVE in Your Project | Move to docs/installation.md (already authoritative; README defers there). Consumers keep the tracking/gitignore policy via disposition 5. [HIGH on move, MEDIUM on exact merge shape] |
| 9 | Your Project | Fill with the RQ4 draft (~15 lines); heading stays byte-exact as the awk sentinel [HIGH] |
| 10 | Mid-Flow Scope Changes | Keep; additionally protect with a pointer from at least one phase command or a test row, so it cannot vanish silently [MEDIUM, adjacent scope] |

Size outcome: payload shrinks from 386 to roughly 300-310 lines (minus preamble narrative ~4, Hooks 21, Installing 46, plus gitignore policy re-absorbed ~8 and payload note ~3); whole file lands near 320-330 lines including the filled `## Your Project`. The larger per-session saving is character-level: Command Reference rows drop from 400-500 chars to under ~120. Every consuming project inherits the same reduction at next reinstall. [MEDIUM on exact numbers, HIGH on direction]

Authoring constraints for the rewrite: keep `-` bullets (markdown.md:16 mandates `*`, but strict compliance churns every list line; decide before writing) [MEDIUM]; ATX headings, line length, table style per .claude/instructions/markdown.md:7-49; direct second-person style per .claude/instructions/writing-style.md:7-24. No em-dashes in new prose (user preference; the legacy em-dash marker in install.sh:198-199 shows shipped-punctuation churn is already a tested concern). [HIGH]

## Codebase References

- CLAUDE.md (subject)
- README.md, CONTRIBUTING.md, docs/installation.md, docs/workflow.md, docs/reference.md, docs/internals.md (duplication surfaces)
- install.sh (payload extraction :167-183, merge branches :185-222)
- tests/run-drift-tests.sh (constraint inventory: tests 3, 7, 8, 10, 14, 15, 16), tests/run-install-tests.sh, tests/run-prompt-new-install.sh, tests/run-prompt-upgrade.sh, tests/lib/instruction-files.sh, tests/fixtures/claude-md-*.md
- .claude/commands/hve*.md, .claude/agents/hve-*.md, .claude/prompts/pull-request.md (pointer dependents)
- .claude/instructions/markdown.md, .claude/instructions/writing-style.md (rewrite conventions)

Prior related research (read at plan time, not re-read here):

- .claude-hve-tracking/research/2026-05-29/claude-md-cleanup.md (prior CLAUDE.md audit; avoid re-deciding settled questions)
- .claude-hve-tracking/research/2026-05-29/update-readme.md (likely origin of the CLAUDE.md/README overlap)
- .claude-hve-tracking/doc-ops/2026-06-02-session.md (only doc-ops session on record)

## External References

None; all questions answerable from the repo.

## Open Questions

1. Payload intent (user decision): consuming projects currently receive the Installing and Hooks sections inside their CLAUDE.md. Moving them to docs/ removes them from downstream installs too. Acceptable? Recommendation: yes, docs/installation.md already carries the content. [MEDIUM]
2. Command Reference shape (user decision): slim rows with pointers to command files, or keep full flag semantics and add a Command Reference drift test. Recommendation: slim rows; command files are already ground truth and one drift exists today. [MEDIUM]
3. The /hve-plan "full = parallel validation" claim is false today in both the table and hve-plan.md:41 (feature deferred 2026-08-15). Reword both now as part of this change, or leave until the feature lands? Touching hve-plan.md:41 is one line beyond strict CLAUDE.md scope. [MEDIUM]
4. Bullet-marker policy for the rewrite: keep `-` (no churn) or convert to `*` per markdown.md:16. Recommendation: keep `-`. [MEDIUM]
5. Where the producer-side payload note lives: visible prose near the top vs an HTML comment above `## Your Project`. A comment is invisible to sessions but zero-cost; visible prose costs ~3 payload lines everywhere. [LOW] (superseded — see Addendum 2026-08-19: anything above the heading ships to every install; only below-heading placement is repo-only)

## Decisions (2026-08-19, user-confirmed)

These resolve the Open Questions above; the plan phase treats them as fixed requirements.

1. Payload scope (resolves Q1): move BOTH the Installing section and the Hooks section out of CLAUDE.md into docs/ (Installing into docs/installation.md, Hooks into docs/reference.md). Downstream installs stop carrying them at their next update.
2. Command Reference (resolves Q2): slim rows to purpose plus when-to-use, with pointers to .claude/commands/*.md for flags. Flag semantics leave the table entirely.
3. /hve-plan parallel-validation claim (resolves Q3): leave hve-plan.md:41 and README.md:124 unchanged until the deferred feature lands. Condition from the user: the discrepancy must stay durably documented. It is recorded in session memory (feature-hve-plan-parallel-validation), in this doc's PA-004 verdict, and the plan phase MUST add a DD- entry to the planning log recording the claim as knowingly retained. Note the interaction with decision 2: slimming the table removes the false clause from CLAUDE.md as a side effect; the claim then survives only in hve-plan.md and README.md.
4. Payload-contract warning (resolves Q5): below the heading, as the opening lines of the filled `## Your Project` section; repo-only, ships nowhere. User expressed no preference; recommendation adopted.
5. Bullet policy (resolves Q4, default adopted): keep `-` bullets to avoid whole-file churn; the plan notes the markdown.md:16 divergence instead of converting.
6. Sentinel heading name (user-confirmed 2026-08-19): keep `## Your Project` as the source-side cut line; no rename. The consumer side already adapts per mode (project installs get `## Your Project`, global installs get `## Your Global Context`, install.sh:190-193), so the label is only ever read by editors of this repo. The filled section's opening lines disambiguate instead, e.g.: this section is repo-local; in installed projects install.sh creates the equivalent section. A rename remains possible later as a standalone change (updates key off HVE:START/END markers, not the heading) but would touch install.sh:171/:168-170/:278, docs/installation.md:16-22/:148-153, tests/run-prompt-new-install.sh:84-91, and README.md:36.

## Recommended Research Follow-On

- [ ] Read .claude-hve-tracking/research/2026-05-29/claude-md-cleanup.md before planning to avoid re-deciding settled questions
- [ ] Enumerate the exact canonical block prefix strings and pointer heading list from tests/run-drift-tests.sh groups 10/14/15 as a pre-flight checklist for the plan
- [ ] Verify docs/reference.md's tracking tree matches CLAUDE.md:78-103 before declaring either copy canonical
- [ ] Reconcile the severity wording variant at .claude/agents/hve-implementation-validator.md:99-101 with the Severity Grading table, or mark it deliberate specialization
- [ ] If the Installing section moves, plan the CLAUDE.md:76 anchor fix and a full ./tests/run-drift-tests.sh + ./tests/run-install-tests.sh run as acceptance gates

## Addendum (2026-08-19): prior cleanup doc and install.sh placeholder mechanics

Written after the parent session read install.sh in full and the prior audit at .claude-hve-tracking/research/2026-05-29/claude-md-cleanup.md.

### Prior research: claude-md-cleanup (2026-05-29)

- All seven findings from that audit (F-01..F-08: HVE acronym, gitignored parenthetical, dimension number, instructions table rows, DR-/DD- definitions, /clear wording, de-Copilot jargon, status-value split) are fixed in the current file; spot-checks confirm the corrected wording is present (e.g. "dimension 9" at CLAUDE.md:292, "No manual file attachment or context management" at CLAUDE.md:237). [HIGH]
- Settled decisions to respect: a subagent inventory table was deferred (still out of scope here). [HIGH]
- Deferred items now absorbed by this task: "README vs CLAUDE.md sync strategy" (that separate work item is this task's duplication question); "expanding the `## Your Project` placeholder with examples" was deferred as "template by design", but that referred to shipping example content to consumers. Our PA-003 fill is different: repo-local content below the sentinel, and the consumer placeholder is hardcoded in install.sh (below), so filling ours ships nothing. No conflict with the earlier decision. [HIGH]

### install.sh dependency on the Your Project placeholder (verified line by line)

- The extraction sentinel is the HEADING, not the comment: install.sh:171 runs `awk '/^## Your Project/{exit} {print}'` against the source CLAUDE.md. Constraints for any restructure: the heading stays byte-exact at line start; it remains the last `##` section; and no earlier payload line may begin with `## Your Project` (a code-block example starting a line with it would silently truncate the payload). Inline mentions like "the `## Your Project` heading" are safe. [HIGH]
- The placeholder HTML comment in this repo's CLAUDE.md:390-399 is NOT read by install.sh. Fresh installs get a hardcoded one-line placeholder from install.sh:190-193 (`## Your Project` + comment; global mode writes `## Your Global Context` instead at install.sh:190). Editing or replacing this repo's placeholder comment cannot affect installs. [HIGH]
- Payload-note placement consequence: any producer-side contract note placed ABOVE the heading ships into every install (it is payload); a note placed BELOW the heading (as the opening lines of the filled `## Your Project` section) is repo-only. This supersedes Open Question 5's zero-cost framing. [HIGH]
- Soft string dependencies on the heading text elsewhere: install.sh:168-170 (comment), install.sh:278 (next-steps message), docs/installation.md:16-22 and :148-153 (paste prompts), tests/run-prompt-new-install.sh:84-91. Renaming the heading is effectively forbidden; keep `## Your Project` verbatim. [HIGH]
