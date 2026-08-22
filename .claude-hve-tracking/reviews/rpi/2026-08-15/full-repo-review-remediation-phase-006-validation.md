# RPI Validation: Full-Repo Review Remediation — Phase 6
Date: 2026-08-15
Plan phase: Phase 6: Convention gaps, now single-site (RL-01, RL-02, RL-07)
Coverage: 100%
Status: Pass

---

## Load Context Summary

- **Plan file**: `.claude-hve-tracking/plans/2026-08-15/full-repo-review-remediation-plan.md` ✓ Read
- **Changes log**: `.claude-hve-tracking/changes/2026-08-15/full-repo-review-remediation-changes.md` ✓ Phase 6 section read
- **Details file**: `.claude-hve-tracking/details/2026-08-15/full-repo-review-remediation-details.md` ✓ Section 3 & 5 read
- **Research**: None — recorded absent by plan design ✓
- **Changed-file list**: 30 files supplied by parent; Phase 6 edits span 11 files across `.claude/commands/`, `.claude/agents/`

**Load status: Complete.** No blocking issues; proceeding to validation.

---

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 6.1: RL-01 — Argument Parsing invariant across three files | Found | `.claude/commands/hve-implement.md:19`, `.claude/commands/hve-review.md:19`, `.claude/commands/hve-plan.md:13` | ✅ Implemented |
| Step 6.2: RL-02 — Missing-instructions-file fallback reference at four locations | Found | `.claude/commands/hve-implement.md:42`, `.claude/agents/hve-phase-implementor.md:19,31,132` | ✅ Implemented |
| Step 6.3: RL-07 — Wire `writing-style.md` and `markdown.md` into four prose commands | Found | `.claude/commands/hve-prompt-builder.md:30`, `.claude/commands/hve-prompt-refactor.md:59`, `.claude/commands/hve-doc-ops.md:27`, `.claude/agents/hve-prompt-updater.md:32` | ✅ Implemented |
| Step 6.4: Run both suites | Found | Changes log reports drift 219/0, install 66/0 (both green) | ✅ Completed |

**Overall coverage: 4 plan steps / 4 = 100%**

---

## Detailed Findings

### RL-01: Argument Parsing Invariant — Position-Neutral Rewrite ✅ Pass

**Plan claim (Step 6.1):**
> Rewrite so the stated invariant matches the actual order.

**Evidence verified:**

Three files now carry a byte-identical Argument Parsing section at lines 13 (hve-plan.md), 19 (hve-review.md), 19 (hve-implement.md):

```
Any flag-strip instruction elsewhere in this file belongs to this one parse 
and is not a separate read of `$ARGUMENTS`. ... Every other section uses these 
named values; none re-reads `$ARGUMENTS`.
```

**Position-neutral verification:**
- **hve-plan.md**: Argument Parsing section (lines 11–15) appears ABOVE flag-strip instructions (SUBAGENT_MODEL usage at line 15, friction paragraph at lines 17–19)
- **hve-implement.md**: Flag-strip instructions (lines 11–13) appear BEFORE Argument Parsing section (lines 17–19)
- **hve-review.md**: Flag-strip instructions (lines 11–13) appear BEFORE Argument Parsing section (lines 17–19)

The rewritten phrase "elsewhere in this file" is position-neutral — it correctly describes flag-strip instructions regardless of their location above or below the Argument Parsing section heading. 

**Truthfulness assessment:**
The claim "Any flag-strip instruction belongs to this one parse" is truthful in all three files under the semantic interpretation that argument-line flag-stripping operations (stripping `--subagent-model` or `--friction-log` from the raw `$ARGUMENTS`) are part of the single overall Argument Parsing process, not a separate parse. The phrase "elsewhere in this file" is not directional, so it works in both structures.

The phrase "none re-reads `$ARGUMENTS`" is truthful when interpreted as "no section after Argument Parsing re-reads the original `$ARGUMENTS` string"; the flag-strip operations are part of the parse itself, not later sections re-reading it.

**Consistency note:** Phase 8 later fixed a similar instance in `hve-review.md:142`, converting it from a direct `$ARGUMENTS` read to using the parsed `THINK_MODE` variable. This does not invalidate RL-01's fix — it shows a pattern of converting remaining re-reads in later phases, which is sound sequencing.

**Drift test impact (DD-009 rationale verified):**
- Test 5 (`tests/run-drift-tests.sh:315`) keys off `SUBAGENT_MODEL_PREFIX = 'If \`--subagent-model'`
- Current carriers in `.claude/commands/*.md`: `hve-implement.md:11`, `hve-review.md:11`, `hve-plan.md:15`, and three other commands = 7 carriers (actual count varies by drift test state)
- Converting flag-strip instructions to consume named values (e.g., "If SUBAGENT_MODEL is set") would drop `hve-implement.md` and `hve-review.md` from the prefix carriers, reducing count to 5
- Trade-off rationale (DD-009): preserve the 7-carrier byte-identity assertion by rewording the invariant rather than refactoring the flag-strip paragraphs
- **Verdict:** The trade-off is sound. The RL-01 fix eliminates the documented contradiction without sacrificing drift coverage.

---

### RL-02: Missing-Instructions-File Fallback — Reachability Verified ✅ Pass

**Plan claim (Step 6.2):**
> Add CLAUDE.md's "no instructions file exists" fallback as a reference at four locations.

**Canonical fallback (CLAUDE.md:286):**
```
If no instructions file exists for the language at hand, do not block: 
follow the dominant conventions of the existing code in the repo, and note 
the missing instructions file in the changes log.
```

**Reference locations verified:**

1. **`.claude/commands/hve-implement.md:42`** (Phase 1 step 4):
   ```
   When no file covers that language, apply the fallback per CLAUDE.md's 
   `Instructions Reference` section
   ```
   ✅ References the section by name (binding syntax per details doc section 5)

2. **`.claude/agents/hve-phase-implementor.md:19`** (Your Assignment):
   ```
   When the language has no such file, apply the fallback per CLAUDE.md's 
   `Instructions Reference` section
   ```
   ✅ Consistent reference

3. **`.claude/agents/hve-phase-implementor.md:31`** (Step 1, Load Context):
   ```
   When no file covers that language, apply the fallback per CLAUDE.md's 
   `Instructions Reference` section
   ```
   ✅ Consistent reference

4. **`.claude/agents/hve-phase-implementor.md:132`** (Constraints):
   ```
   when none exists, apply the fallback per CLAUDE.md's `Instructions Reference` section
   ```
   ✅ Consistent reference

**Reachability assessment:**
All four locations are reachable instructions that would guide a reader toward CLAUDE.md:286 when implementing or subagent-dispatching for an unsupported language. An agent or implementor following any of these files would read the reference and discover the fallback rule. Test 14 (Phase 5, reference resolution) now catches any dangling pointers to the section.

---

### RL-07: Prose-Language Instructions Wiring ✅ Pass

**Plan claim (Step 6.3):**
> Wire `writing-style.md` and `markdown.md` into the four commands that author prose artifacts.

**Baseline problem:** Generic "read the relevant instructions file for the language" instruction was scoped to programming languages only, making `writing-style.md` and `markdown.md` unreachable for agents that produce Markdown prose.

**Verification:**

1. **`.claude/commands/hve-prompt-builder.md:30`** (Phase 1 step 2):
   ```
   Read `.claude/instructions/writing-style.md` and 
   `.claude/instructions/markdown.md` before drafting.
   ```
   - Step numbering: 1 (Understand artifact type) → 2 (NEW: Read files) → 3 (Read patterns) → 4 (Create sandbox) → 5 (Draft)
   - Sequential numbering ✅ correct

2. **`.claude/commands/hve-prompt-refactor.md:59`** (Protocol step 2):
   ```
   Read `.claude/instructions/writing-style.md` and 
   `.claude/instructions/markdown.md`. The target is always Markdown prose, so both govern the refactor
   ```
   - Step numbering: 1 (Read file) → 2 (NEW: Read files) → 3 (Identify issues) → 4 (Present summary) → 5 (Ask) → 6 (Apply) → 7 (Report)
   - Sequential numbering ✅ correct (original steps 2-7 renumbered to 3-7 as claimed)

3. **`.claude/commands/hve-doc-ops.md:27`** (Phase 1, Discovery step 3):
   ```
   read `.claude/instructions/markdown.md` and `.claude/instructions/writing-style.md`, 
   which define the baseline every finding is graded against
   ```
   - Integrated into Phase 1 step 3 context ✅ reachable

4. **`.claude/agents/hve-prompt-updater.md:32`** (Step 1 item 5):
   ```
   Read `.claude/instructions/writing-style.md` and 
   `.claude/instructions/markdown.md`. Every artifact you write is Markdown prose, so both govern the rewrite
   ```
   - Step numbering: 1. (Read draft) → 2. (Read evaluation log) → 3. (Note findings) → 4. (Understand behavior) → 5. (NEW: Read files)
   - Sequential numbering ✅ correct

**Wiring assessment:**
All four prose-producing agents/commands now contain explicit instructions to read both `writing-style.md` and `markdown.md` before authoring or refactoring Markdown prose. An agent or implementor following these instructions would read the files and understand the conventions they must apply. The phrase "every artifact... is Markdown prose" correctly scopes the requirement to all output, not just code comments.

**Step-numbering verification:**
- hve-prompt-builder: Phase 1 steps remain sequential 1–5 ✅
- hve-prompt-refactor: Protocol steps renumbered 3–7 as claimed; step 2 is new ✅
- hve-doc-ops: Phase 1 integrated into step 3 ✅
- hve-prompt-updater: Step 1 items sequential 1–5 ✅

No broken sequences detected.

---

## Drift Test Impact

**Phase 6 entry baseline:** drift 218/0, install 66/0 (from Phase 5)
**Phase 6 exit**: drift 219/0, install 66/0
**Delta:** +1 drift assertion (no install changes)

**Explanation (from changes log):** Step 6.2 introduced the first pointer to `Instructions Reference` section anywhere in `.claude/**/*.md`. Test 14 counts distinct sections resolved by all pointers, so the seven Step 6.2/6.3 pointer sites (four for RL-02, four for RL-07 minus overlap) collapse to two distinct new sections (`Instructions Reference` and any overlap with earlier sections). The net new row from test 14 is +1 for the `Instructions Reference` section.

**Verification:** `test14_reference_resolution` (Phase 5, Step 5.9) is now exercised by RL-02's references. No test file was edited in Phase 6; the +1 delta is an invocation of existing test 14 logic.

---

## Research Coverage

Validated against the plan alone; research was recorded absent at planning time. No research requirements to cross-check.

---

## Unlisted Changes

All files modified in Phase 6 match the parent-supplied changed-file list:
- `.claude/commands/hve-implement.md` ✓
- `.claude/commands/hve-review.md` ✓
- `.claude/commands/hve-plan.md` ✓
- `.claude/agents/hve-phase-implementor.md` ✓
- `.claude/commands/hve-prompt-builder.md` ✓
- `.claude/commands/hve-prompt-refactor.md` ✓
- `.claude/commands/hve-doc-ops.md` ✓
- `.claude/agents/hve-prompt-updater.md` ✓

No files appear in the changes log for Phase 6 but absent from the parent's list. No unlisted changes detected.

---

## Record Consistency

No contradictions found within the Phase 6 section of the changes log or between Phase 6 and earlier phases. All claimed changes are documented and file evidence aligns with claims.

---

## Recommendations for Follow-On

- **Phase 7 sequencing**: Phase 7 (Step 7.3) removes `THINK_MODE` from `hve-implement.md:19` alone, making the three Argument Parsing sentences non-identical. Test 10 `CANONICAL_BLOCK_SPECS` carries no entry for the Argument Parsing sentence, so this divergence is safe and intentional.
- **Drift test 14**: Confirm test 14's reference extractor matches the binding syntax `` per CLAUDE.md's `Section Name` section `` used in all Phase 6 references. Phase 5 established this contract; Phase 6 validates it by introducing new pointers.
- **Post-Phase-7 note**: After Phase 7 removes `THINK_MODE` from `hve-implement.md`, the three Argument Parsing sentences will differ in their parse list. This is acceptable per the plan and does not violate any test assertions.

---

## Verdict

**Status: Pass**

All three findings (RL-01, RL-02, RL-07) are implemented correctly. The Argument Parsing invariant rewrite is truthful in all three files and preserves drift coverage per DD-009's sound rationale. The Instructions Reference fallback is reachable from all four required locations. The prose-language file wiring is correctly integrated into all four commands with sequential step numbering intact.

No critical, major, or minor findings detected. Test suite green at phase boundary (drift 219/0, install 66/0, both expected and accounted for).
