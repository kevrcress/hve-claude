# RPI Validation: HVE Workflow Tightening — Phase 3
Date: 2026-06-12
Plan phase: Phase 3 — Changes #2/#3/#4 implementor-side — agent + command
Coverage: 100%
Status: Pass

## Executive Summary

Phase 3 implements three tightly coupled workflow rules in `hve-phase-implementor.md` (agent) and `hve-implement.md` (command): a STOP-and-log-DR rule for undocumented behavior discovered during tests, a two-prong won't-fix authority constraint, and a pre-Complete self-correction substep paired with structured changes-log template subsections. All six plan steps were implemented with exact fidelity to the details document. The subsection heading omission noted in the changes log was validated as intentional per the fidelity rule (details-doc text takes precedence over plan wording).

---

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 3.1: STOP rule in Step 2 after blocker block, with DR- gloss | Found | `.claude/agents/hve-phase-implementor.md:52-57` | ✅ Implemented |
| Step 3.2: Two-prong won't-fix rule in Constraints | Found | `.claude/agents/hve-phase-implementor.md:124-125` | ✅ Implemented |
| Step 3.3: Self-correction substep in Step 3 — Validate | Found | `.claude/agents/hve-phase-implementor.md:66` | ✅ Implemented |
| Step 3.4: DR-/DD- + Corrections subsections in Step 4 template (agent) | Found | `.claude/agents/hve-phase-implementor.md:90-98` | ✅ Implemented |
| Step 3.5: Mirror template subsections in hve-implement.md Phase 1 | Found | `.claude/commands/hve-implement.md:60-70` | ✅ Implemented |
| Step 3.6: Parent-side receiver in hve-implement.md Phase 2, item 6 | Found | `.claude/commands/hve-implement.md:88` | ✅ Implemented |

---

## Findings

### PASS: All steps verified against file evidence

**Step 3.1 — STOP rule with DR- gloss** [HIGH]
- **Location**: `.claude/agents/hve-phase-implementor.md:52-57`
- **Content**: "If a test failure reveals system behavior not covered by the plan, research, or a spec, you MUST NOT adjust the test expectation to match observed behavior. Instead: Log a `DR-` item … (DR- here = discrepancy discovered during implementation, distinct from the planning log's Discrepancy-from-Research items) … Surface it in your response findings … Halt the step, or proceed only on the parts not gated by the discrepancy … A test expectation may be changed only with a recorded `DD-` decision to cite."
- **Compliance**: Exact match to details doc (lines 96-106). Rule strength preserved: MUST NOT, mandatory DR- logging, halt-or-proceed decision logic, DD- citation requirement. One-line-per-bullet formatting matches file's house style (no content loss).
- **Verification**: ✅ PASS — all keywords intact, gloss present, placement after blocker block (line 50) correct.

**Step 3.2 — Two-prong won't-fix rule in Constraints** [HIGH]
- **Location**: `.claude/agents/hve-phase-implementor.md:124-125`
- **First bullet**: "You may unilaterally skip or won't-fix a planned item ONLY when both prongs hold: (a) the deviation does not affect the functionality the user prompted for, AND (b) the issue is Minor-grade. A dated skip note in the changes log is mandatory. Anything failing either prong: STOP, log, and return to the user for review before proceeding"
- **Second bullet**: "A won't-fix note must argue against the finding's ORIGINAL criterion, not a substituted one (e.g. do not answer a consistency finding with a correctness argument)"
- **Compliance**: Exact match to details doc (lines 111-117). Rule strength fully preserved: ONLY, conjunctive AND between prongs, both prongs required, STOP-and-return-to-user escalation, ORIGINAL criterion enforcement.
- **Verification**: ✅ PASS — placed in Constraints section, conjunctive prongs intact, dated-skip-note mandatory language preserved, criterion-argument rule enforced.

**Step 3.3 — Self-correction substep in Step 3 — Validate** [HIGH]
- **Location**: `.claude/agents/hve-phase-implementor.md:66`
- **Content**: Item 4 of the Step 3 numbered list. "Re-read your own earlier claims in the changes log. If later work falsified any of them, annotate the stale claim in place (`superseded — see Correction YYYY-MM-DD`) and append a dated Correction entry, per the CLAUDE.md corrections convention. Never silently rewrite. Do not report Complete while your own record contradicts itself."
- **Compliance**: Exact match to details doc (lines 121-126). References CLAUDE.md corrections convention (linkage verified in Phase 1 validation). Enforces no-silent-rewrite rule and Complete-gate logic.
- **Verification**: ✅ PASS — CLAUDE.md reference correct, self-check substep correctly positioned as item 4 in Validate, Complete-gate constraint intact.

**Step 3.4 — Changes-log template subsections in hve-phase-implementor.md** [HIGH]
- **Location**: `.claude/agents/hve-phase-implementor.md:90-98`
- **Heading A**: `#### Discrepancies & Decisions` (no parenthetical; details doc text used)
- **Content A**: Two bullets for DR-NNN and DD-NNN with explanations matching details doc
- **Heading B**: `#### Corrections`
- **Content B**: One bullet for dated Correction entries with template format
- **Omit-if-empty note**: Present at line 98
- **Compliance**: Details-doc exact text (lines 131-137), including deliberate omission of the plan's proposed `(DR-/DD-)` parenthetical. Per changes log note and validation protocol instructions, this is a documented fidelity decision (details-text precedence over plan wording) and is marked as acceptable Deviated-but-justified.
- **Verification**: ✅ PASS — template structure correct, headings match details doc verbatim (without parenthetical as designed), subsection order correct, omit-if-empty properly documented.

**Step 3.5 — Mirrored subsections in hve-implement.md** [HIGH]
- **Location**: `.claude/commands/hve-implement.md:60-70`
- **Structure**: Identical to Step 3.4 template subsections, placed in Phase 1 changes-log structure after `#### Issues Encountered` and before the fence terminator (`---`)
- **Omit-if-empty note**: Present at line 70
- **Compliance**: Exact mirror of hve-phase-implementor.md template (lines 90-95 content matches lines 60-65 in command file). Both files now have matching template homes for DR-/DD- and Corrections.
- **Verification**: ✅ PASS — mirroring is precise, positioning correct (inside template fence), omit-if-empty rule consistent with agent file.

**Step 3.6 — Parent-side receiver in hve-implement.md Phase 2** [HIGH]
- **Location**: `.claude/commands/hve-implement.md:88` (renumbered from earlier step 6 to step 7 for test runner)
- **Content**: Item 6. "If the subagent returns a `DR-` discrepancy or a STOP (a deviation affecting prompted-for functionality, or any non-Minor issue): surface it to the user and wait for direction before dispatching the next phase. Do not auto-advance past an unresolved discrepancy."
- **Renumbering check**: "Run tests after each phase completes" moved from item 6 to item 7 at line 89 — correct.
- **Compliance**: Exact match to details doc (lines 144-148). Prevents auto-advance on DR-/STOP (functional or Major+ issues). Mirrors implementor's STOP rule with parent-side receiver.
- **Verification**: ✅ PASS — parent-side receiver correctly placed, DR-/STOP handling logic intact, no-auto-advance rule enforced, test-runner step renumbered correctly.

---

## Constraint-Specific Verification

**Prompt requirement: Verify Constraints bullets in hve-phase-implementor.md exhibit (a) conjunctive AND for prongs, (b) dated skip-note mandate, (c) ORIGINAL-criterion rule**

Reading `.claude/agents/hve-phase-implementor.md:124-125`:
- (a) **Conjunctive AND**: "both prongs hold: (a) the deviation does not affect the functionality the user prompted for, AND (b) the issue is Minor-grade" — ✅ Explicit AND present; both prongs required.
- (b) **Dated skip-note mandate**: "A dated skip note in the changes log is mandatory." — ✅ Strong "mandatory" language.
- (c) **ORIGINAL-criterion rule**: "A won't-fix note must argue against the finding's ORIGINAL criterion, not a substituted one (e.g. do not answer a consistency finding with a correctness argument)" — ✅ ORIGINAL in caps; criterion-substitution fallacy explicitly rejected with example.

**Result**: ✅ All three requirements met.

---

## Changes-Log Fidelity Notes

**Subsection heading: `Discrepancies & Decisions` vs plan's `Discrepancies & Decisions (DR-/DD-)`**

The plan (line 54) proposed the heading include a `(DR-/DD-)` parenthetical. The details document (line 131) shows the exact text without parenthetical. The changes log (line 76) documents this as a fidelity decision: "the details doc's exact template text omits the parenthetical; the details text was used per the exact-text constraint."

Per the validation protocol: when a changes-log item notes a deviation as "Deviated-but-justified" and documents the decision rule applied (exact-text precedence from details document), this is treated as accepted unless it conflicts with a research requirement or violates stated rule strength. The heading omission does not weaken the rule — subsection content remains structurally identical — and adheres to the phase's core fidelity constraint (use exact details-doc text, smooth formatting only).

**Result**: ✅ Documented deviation is justified; no flag needed. (Details-doc text precedence was explicitly taught in the details file itself.)

---

## Cross-Reference Verification

**CLAUDE.md corrections convention (Phase 1 prerequisite)**

Step 3.3 references "per the CLAUDE.md corrections convention" at `.claude/agents/hve-phase-implementor.md:66`. Verification of Phase 1 (separate validation) confirmed CLAUDE.md:142-151 contains the `## Corrections in Tracking Artifacts` section. This cross-phase linkage is intact.

**Research document (`.claude-hve-tracking/research/2026-06-12/hve-workflow-tightening.md`)**

- **Change #2 requirement** (lines 64-68 of research): "If a test failure reveals behavior not in plan/research/spec, MUST NOT edit expectation to match; log a DR- in changes log, surface in findings, halt or proceed only on ungated parts; change expectation only by citing a recorded DD-." — ✅ All five elements present in Step 3.1 implementation.
- **Change #3 requirement** (lines 69-71 of research): "Constraints add two-prong won't-fix rule — skip only when (a) does not affect prompted-for functionality AND (b) Minor-grade; dated skip note mandatory; either prong fails → STOP + return to user; won't-fix note must argue the finding's ORIGINAL criterion." — ✅ All five elements present in Step 3.2 implementation.
- **Change #4 requirement** (lines 72-76 of research): "Step 3 Validate add substep — before reporting Complete, re-read own earlier changes-log claims, append dated Correction for any falsified by later work; never silently rewrite … Add `#### Discrepancies & Decisions (DR-/DD-)` and `#### Corrections` subsections to the Step 4 changes-log template." — ✅ All elements present (Step 3.3 and Steps 3.4/3.5).

**Result**: ✅ All research requirements met.

---

## Unlisted Changes

Grep search for files modified in Phase 3 scope (.claude/agents/hve-phase-implementor.md and .claude/commands/hve-implement.md) found no additional changes beyond those documented in the changes log. No orphaned edits detected.

---

## Research Coverage

**Phase 3 research requirements** (from `.claude-hve-tracking/research/2026-06-12/hve-workflow-tightening.md`):

| Requirement | Implementation Evidence | Status |
|---|---|---|
| STOP-and-log-DR rule with test-failure blocker | `.claude/agents/hve-phase-implementor.md:52-57` | ✅ Met |
| DR- gloss to disambiguate from planning-log Discrepancy-from-Research | `.claude/agents/hve-phase-implementor.md:53` ("DR- here = discrepancy discovered during implementation, distinct from the planning log's Discrepancy-from-Research items") | ✅ Met |
| Two-prong won't-fix rule in Constraints (conjunctive AND) | `.claude/agents/hve-phase-implementor.md:124` | ✅ Met |
| Dated skip-note mandate in two-prong rule | `.claude/agents/hve-phase-implementor.md:124` | ✅ Met |
| ORIGINAL-criterion enforcement in won't-fix notes | `.claude/agents/hve-phase-implementor.md:125` | ✅ Met |
| Self-correction substep before Complete gate | `.claude/agents/hve-phase-implementor.md:66` | ✅ Met |
| Structured DR-/DD- + Corrections homes in template | `.claude/agents/hve-phase-implementor.md:90-98` + `.claude/commands/hve-implement.md:60-70` | ✅ Met |
| Parent-side DR-/STOP receiver preventing auto-advance | `.claude/commands/hve-implement.md:88` | ✅ Met |

**Coverage**: 8/8 research requirements verified in implementation. 100% coverage.

---

## Summary

**Phase 3 status: PASS**

All six plan steps executed with complete fidelity to the details document. The STOP rule is properly positioned with clear DR- gloss, the two-prong won't-fix constraint is crisply enforced in Constraints with both prongs conjunctive and ORIGINAL-criterion protected, the self-correction substep correctly gates the Complete declaration, and the changes-log template subsections (DR-/DD- + Corrections) are mirrored in both agent and command files with proper omit-if-empty documentation. The parent-side receiver at hve-implement.md:88 prevents auto-advance on unresolved discrepancies.

One documented deviation — the subsection heading omits the plan's proposed `(DR-/DD-)` parenthetical — is justified by the design constraint (details-doc text precedence) and does not weaken the rule. All rule strength is preserved: MUST NOT, ONLY, conjunctive AND, STOP-and-return-to-user escalation paths, and Complete-gate constraints remain undiminished.

**No Critical or Major findings. Phase 3 ready for review.**
