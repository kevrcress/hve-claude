# Prompt Analysis: hve-review.md + hve-rpi-validator.md
Date: 2026-06-12
Source: /hve-prompt-analyze pass
Context: Baseline before applying Change #4 (record-consistency gate) from
  2026-06-12-hve-workflow-tightening-writeup.md

## Files Analyzed
- `.claude/commands/hve-review.md`
- `.claude/agents/hve-rpi-validator.md`

---

## Structural Finding: Where Verdict Criteria and the Gate Belong

The ✅/⚠️/🚫 task verdict is decided in exactly one place:
`hve-review.md:108-111` (Phase 4, step 2). The `hve-rpi-validator` emits only a
per-phase `Pass | Fail` (`hve-rpi-validator.md:68, 100-102`) scoped to a single
phase number — it cannot see cross-phase contradictions.

The Change #4 gate clause ("cannot be graded ✅ Complete while the changes log
self-contradicts") **must** land in `hve-review.md` Phase 4, because that is the
only artifact that owns the ✅ Complete grade.

Detection is cross-phase in shape (writeup evidence spans Phase 2 revert + Phase 3
"no build env" + later "49 passed"). The parent already reads the full log in Phase
1 (`hve-review.md:30`). The validator is phase-scoped and cannot own cross-phase
detection, but can flag intra-phase contradictions found during Step 2 file
verification. Weight: ~80% command, ~20% validator.

---

## Findings

### PA-001 COMPLETENESS [MAJOR]
**Issue:** The ✅ Complete gate has no record-consistency precondition. A
self-contradicting changes log currently passes.
**Evidence:** `hve-review.md:109`
  `**✅ Complete** — no Critical, ≤ 2 Major findings, all plan phases validated`
**Fix:** Add a fourth conjunct:
  `…, all plan phases validated, and the changes log is internally consistent
  (no un-annotated contradictions; any falsified earlier claim carries a dated
  Correction appendix per the CLAUDE.md correction convention).`
  Failure path: contradictions without corrections → ⚠️ Needs Rework, not ✅ Complete.

### PA-002 COMPLETENESS [MAJOR]
**Issue:** No step actually scans for contradictions. The gate in PA-001 is
unenforceable without a producing step. Phase 2 validators are phase-scoped; Phase
3's 10 dimensions (`hve-review.md:87-97`) are all code-quality, none is record
meta-consistency.
**Evidence:** `hve-review.md:61-101` — Phase 2 and Phase 3 both absent a
consistency scan.
**Fix:** Add to Phase 1 (after reading the full log at line 30), or as a dedicated
"Phase 3.5 — Record Consistency" block:
  "Re-read the full changes log end-to-end. Flag any claim contradicted by a later
  claim (e.g. 'no build environment' vs. an executed test count) that is not already
  annotated 'superseded — see Correction YYYY-MM-DD'. Record each as a Minor finding."
Feed its output into the PA-001 gate.

### PA-003 FORMAT [MINOR]
**Issue:** The review-log template has no record-consistency section or summary
field. The writeup's acceptance criterion ("Reviews list record-consistency as a
checked dimension") is unmet even if PA-002 runs.
**Evidence:** `hve-review.md:45-56` — template sections are Phase Reviews / Quality
Findings / Security Findings / Summary only.
**Fix:** Add `## Record Consistency` section to the template and a summary line:
  `Record consistency: ✅ Consistent | ⚠️ Contradictions (correction appendix required)`

### PA-004 COMPLETENESS [MINOR]
**Issue:** The validator reads the changes log in full but is never asked to flag
intra-phase contradictions or consistency issues — only "missing evidence" framing
exists for cases where file evidence contradicts the log.
**Evidence:** `hve-rpi-validator.md:35-47` — Steps 1/2 compare plan↔log↔file but
have no "log contradicts itself within this phase" branch.
**Fix:** Add one bullet to Step 2:
  "Flag any changes-log claim for this phase that contradicts another claim in the
  same phase, or that is falsified by the file evidence, as a Minor 'record
  consistency' finding (RV-). Cross-phase synthesis is the parent reviewer's
  responsibility."

### PA-005 ACTIONABILITY [MINOR] (pre-existing, not part of Change #4)
**Issue:** Phase 4 says "invoke `/think`" but no such command exists; the mechanism
is the `--think` flag.
**Evidence:** `hve-review.md:105` vs. `argument-hint: … [--think]` at line 3.
**Fix:** Reword to match the flag/extended-reasoning phrasing used elsewhere.

---

## Quality Summary
- Clarity: ✅ Pass
- Completeness: ❌ Fail (PA-001, PA-002, PA-004)
- Actionability: ⚠️ (PA-005, minor pre-existing)
- Format compliance: ⚠️ (PA-003 — template missing the dimension)
- No Copilot-isms: ✅ Pass

Overall: ⚠️ 5 findings (0 critical, 2 major, 3 minor)

---

## Recommended Edit Order (when applying)
1. `hve-review.md` → add whole-log scan step in Phase 1 or Phase 3.5 (PA-002, load-bearing)
2. `hve-review.md` Phase 4 gate → add consistency conjunct (PA-001)
3. `hve-review.md` template + Summary → add the dimension field (PA-003)
4. `hve-rpi-validator.md` Step 2 → add intra-phase consistency flag (PA-004, scoped)
5. `hve-review.md:105` → fix `/think` wording (PA-005, opportunistic)
