# Planning Log: Unowned-File Convention Remediation

Date: 2026-07-20
Task slug: unowned-file-remediation

## Discrepancies

### DR-001: Research [MEDIUM] findings upgraded after planning-session re-verification
Source: Research "Confidence and method notes" marked M-03 through M-12 and the Minors as auditor-reported, not independently re-checked, and told the plan phase to verify before acting.
Resolution: All were re-verified during planning by direct read or grep in the parent session: M-03 (grep for template-blank terms in builder + evaluator returned nothing), M-04 (parallel dispatch at hve-prompt-builder.md Phase 2; evaluator requires log path at :18), M-05/M-06 (both validator bodies read), M-08/M-09/M-10/M-11 (prompt files read; grep `exclud` on hve-doc-ops.md returned 0), M-12 (no discovery terms in hve-memory.md), m-01 through m-09 and the placeholder Minor (all read). The plan states findings as verified with the producing command or read noted.
Status: Resolved

### DR-002: Research suggested clustering by coupling; plan clusters by file
Source: Research "Suggested phase shape" groups findings into 6 coupling clusters (e.g. cluster 3 "Unenforced guarantee" spans CLAUDE.md + builder + evaluator; cluster 4 "Prompt drift" includes M-11's command-side exclusion).
Resolution: Coupling clusters overlap on files (hve-doc-ops.md would be touched by clusters 2, 4, and 5), which breaks the concurrent-write rule for parallel implementors. The plan re-clusters by file so Phases 1-4 are disjoint; every finding is still covered exactly once (mapping in the plan's step annotations).
Status: Resolved

### DD-001: M-02 fixed by naming `hve-researcher`, not by adding a roster-deviation record
Source: Research offered both fixes as alternatives.
Assumption: Read-only doc inventory fits hve-researcher's tool set (Read, Write, Glob, Grep, WebFetch) [HIGH - frontmatter in roster].
Risk: Doc-ops inventory may someday need web-free scoping the researcher prompt doesn't anticipate; acceptable, the agent takes instructions from the dispatch prompt.

### DD-002: M-11 fixed by adding the exclusion to the command, not deleting the promise from the prompt
Source: doc-ops.md prompt promises prompt-engineering artifacts are excluded; the command has no exclusion.
Assumption: The exclusion is the intended behavior: `/hve-prompt-analyze` exists precisely for those files, so scanning them in doc-ops duplicates tooling [HIGH - command exists in roster].
Risk: None identified; the exclusion narrows scope, it does not remove capability.

### DD-003: All Phase 4 prompt fixes align the prompt DOWN to actual command behavior
Source: M-08 (PR-description generation) and M-10 (Update mode) document features that could alternatively be implemented rather than deleted.
Assumption: The prompts drifted from the commands, not vice versa; the friction-log remediation deliberately shaped these commands and the prompts were never phase-owned [HIGH - research root-cause section].
Risk: A user may want the promised PR-description feature. Mitigation: deleting the promise is reversible; implementing the feature is new scope for a future task, not a drift fix.
Follow-up (2026-07-20): Kevin confirmed both features are wanted as future work. Candidates recorded in .claude-hve-tracking/memory/2026-07-20/deferred-feature-candidates.md with suggested slugs pr-description-generation and hve-memory-update-mode.

### DD-004: New tests numbered 12 and 13, extending the existing suite in place
Source: Research cluster 6 asked for coverage of the two escaped classes and to determine why Test 9 missed M-02.
Assumption: Test 9 missed M-02 because it validates only backticked tokens that exist; a dispatch with no backticked token produces zero matches and zero assertions [HIGH - extraction logic read at tests/run-drift-tests.sh:490-496]. Test 12 (non-empty requirement) plus Test 13 (prompt→command flag resolution) close both classes.
Risk: Test 13 extraction noise; guarded by option-list-line restriction and the Step 5.3 mutation check.

### DD-005: Unreachable-text class covered only partially, by design
Source: Research root cause: "text no code path reaches" cannot be caught by static comparison.
Assumption: Test 13 mechanizes the prompt-flag subset of the class; the general class (any prose promising unimplemented behavior) still requires judgment-based audit [HIGH - inherent limit of static tests].
Risk: Future phantom-feature drift outside flag syntax goes undetected until the next audit; accepted, recorded here so review does not grade it a gap.

### DD-006: Phase 2, Steps 2.2-2.3 assume criteria items will be enforced but lack explicit confidence markers
Source: Step 2.2 adds "Template integrity" to prompt-builder quality-criteria list; Step 2.3 adds corresponding section to prompt-evaluator criteria sections. Both steps assume these additions will be read and enforced by the tools, but neither explicitly marks the assumption with [HIGH]/[MEDIUM]/[LOW] confidence.
Assumption: Prompt-builder reads and enforces items in its quality-criteria list (Step 2.2). Prompt-evaluator reads and checks criteria sections, including newly-added ones (Step 2.3).
Risk: If the tools don't read the added items/sections, the fixes won't work. However, research confirms prompt-evaluator.md:25-54 has five existing criteria sections, establishing the evaluator does read criteria sections; prompt-builder likely follows this pattern.
Severity: Minor
Recommendation: Mark the assumptions explicitly in Steps 2.2-2.3, e.g., "(Assumption: prompt-builder/evaluator read and enforce criteria-list items [HIGH - evaluator has five existing criteria sections confirming this behavior)". This is a style issue only; the assumption is well-supported by existing evidence.
Status: Resolved (2026-07-20: confidence-marked assumption added under Step 2.3 in the plan)
