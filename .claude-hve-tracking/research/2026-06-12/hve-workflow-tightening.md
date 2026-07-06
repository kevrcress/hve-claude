# Research: HVE Workflow Tightening — Apply 5 Prompt Changes
Date: 2026-06-12
Task slug: hve-workflow-tightening
Sources:
- Requirements: `2026-06-12-hve-workflow-tightening-writeup.md` (repo root) [HIGH]
- Analysis: `.claude-hve-tracking/reviews/2026-06-12-hve-plan-prompt-analysis.md` [HIGH]
- Analysis: `.claude-hve-tracking/reviews/2026-06-12-hve-plan-validator-prompt-analysis.md` [HIGH]
- Analysis: `.claude-hve-tracking/reviews/2026-06-12-hve-phase-implementor-prompt-analysis.md` [HIGH]
- Analysis: `.claude-hve-tracking/reviews/2026-06-12-hve-review-rpi-validator-prompt-analysis.md` [HIGH]
- Analysis: `.claude-hve-tracking/reviews/2026-06-12-hve-implementation-validator-prompt-analysis.md` [HIGH]

## Summary

Five workflow-prompt defects, all "rules without enforcement" gaps. The five `/hve-prompt-analyze`
reports already baselined each target file and gave exact insertion points + rule text. This research
consolidates them into a single per-file edit map. No re-investigation needed — the analysis IS the
research. The governing constraint from the task: **every added rule must carry a validator-side
acceptance check** (rules that aren't checked get ignored), and edits must **integrate, not append
redundant sections** (no bloat).

## Cross-cutting principle [HIGH]

Each of the 5 changes is an author-side rule paired with a checker-side enforcer. The pairing must be
preserved or the rule is decorative:

| Change | Author-side rule lives in | Checker-side acceptance lives in |
|---|---|---|
| #1 earned "confirmed" + markers | hve-plan.md (command) | hve-plan-validator.md (Step 2 bullets) |
| #2 STOP on undocumented behavior | hve-phase-implementor.md + hve-implement.md | hve-rpi-validator / changes-log inspection |
| #3 two-prong won't-fix | hve-phase-implementor.md + hve-implement.md | hve-review record-consistency + rpi-validator |
| #4 dated corrections | hve-phase-implementor.md + CLAUDE.md convention | hve-review.md Phase 4 gate + hve-rpi-validator Step 2 |
| #5 living-doc citation rot | CLAUDE.md Citation Format convention | hve-implementation-validator.md new dimension 11 |

## Per-file edit map

### CLAUDE.md (conventions — Changes #4 and #5) [HIGH]
- **Citation Format** (lines 142-152): add snapshots-vs-living-docs distinction. `file:line` = dated
  tracking artifacts (snapshots); living docs (anything tracked outside `.claude-hve-tracking/`) anchor
  to SYMBOLS (`Class.Method`), optional dated line hints ("as of YYYY-MM-DD"), prefer pointing at tests.
  Source: writeup #5; impl-validator report PA-003 (convention must be project-wide, not agent-local).
- **New convention block** for dated corrections (near Citation Format / Confidence Markers): falsified
  tracking-artifact statements are never silently rewritten — annotate in place ("superseded — see
  Correction YYYY-MM-DD") + append dated Correction in the owning phase's section; the phase that learns
  the corrected info owns the correction. Source: writeup #4.

### hve-plan.md (command — Change #1) [HIGH]
- Insert `### Plan-Step Evidence Rules` after the Implementation Plan template closes (after line 81),
  before `### Artifact 2` (line 83). Rules: "confirmed"/"verified" forbidden unless adjacent to the
  falsifying check (exact command or `file:line` whose predicate targets the claim); every key step
  assumption carries `[HIGH]/[MEDIUM]/[LOW]`; when verification impossible, mark `[MEDIUM]/[LOW]` + emit
  an explicit implementation-phase guard step. Source: plan report PA-001/002/003/004, insertion point.
- Update step example line 67 to model a confidence marker.
- Extend Phase 3 validator instruction line 118 to also flag unearned claims + missing markers (PA-005).

### hve-plan-validator.md (agent — Change #1 acceptance) [HIGH]
- Step 2 "Discrepancy Validation" (lines 36-41): add two bullets — **Missing confidence markers** (flag
  any plan-step assumption lacking `[HIGH]/[MEDIUM]/[LOW]`, emit DD-) and **Unearned verification claims**
  (flag "confirmed"/"verified" not adjacent to command/`file:line`, emit DD-). Source: validator report
  PA-001/002.
- Widen DD- output template (lines 68-73) wording from "unverified assumption" to "unverified assumption
  or unearned verification claim" (PA-003).

### hve-phase-implementor.md (agent — Changes #2, #3, #4 implementor-half) [HIGH]
- #2: after line 50 (blocker handling), add STOP rule — if a test failure reveals behavior not in
  plan/research/spec, MUST NOT edit expectation to match; log a DR- in changes log, surface in findings,
  halt or proceed only on ungated parts; change expectation only by citing a recorded DD-. Add a one-line
  DR- gloss (impl-time discrepancy) to avoid collision with CLAUDE.md's "DR = Discrepancy from Research"
  (report PA-005).
- #3: Constraints (lines 100-106) add two-prong won't-fix rule — skip only when (a) does not affect
  prompted-for functionality AND (b) Minor-grade; dated skip note mandatory; either prong fails → STOP +
  return to user; won't-fix note must argue the finding's ORIGINAL criterion.
- #4: Step 3 Validate (after line 57) add substep — before reporting Complete, re-read own earlier
  changes-log claims, append dated Correction for any falsified by later work ("superseded — see
  Correction YYYY-MM-DD"); never silently rewrite.
- Add `#### Discrepancies & Decisions (DR-/DD-)` and `#### Corrections` subsections to the Step 4 changes-
  log template (report PA-004) so the above content has a structured home.

### hve-implement.md (command — Changes #2, #3 parent-side receiver) [HIGH]
- Parent must receive returned DR-/STOP and two-prong skips. The phase-implementor report's coordination
  note: agent STOP behavior needs a parent-side receiver. Add to Phase 2: when a subagent returns a DR-
  or a STOP (functional or Major+ deviation), surface to user before continuing; do not auto-advance. Add
  to changes-log template the DR-/DD- + Corrections subsections to match the agent.

### hve-review.md (command — Change #4 gate) [HIGH]
- Phase 1 (after line 30) or new "Phase 3.5 — Record Consistency": re-read full changes log end-to-end;
  flag any claim contradicted by a later claim not annotated "superseded — see Correction YYYY-MM-DD" as
  Minor. (Load-bearing producing step — report PA-002.)
- Phase 4 gate line 109: add conjunct to ✅ Complete — "and the changes log is internally consistent (no
  un-annotated contradictions; any falsified earlier claim carries a dated Correction)." Failure →
  ⚠️ Needs Rework (PA-001).
- Template (lines 45-56): add `## Record Consistency` section + summary line (PA-003).
- Opportunistic: fix `/think` wording at line 105 to match the `--think` flag (PA-005); update "all 10
  dimensions" list (lines 87-97) since impl-validator gains dimension 11.

### hve-rpi-validator.md (agent — Change #4 scoped) [HIGH]
- Step 2 "Verify File Evidence" (lines 42-48): add a bullet — flag any changes-log claim for this phase
  that contradicts another claim in the same phase, or is falsified by file evidence, as a Minor RV-
  "record consistency" finding; cross-phase synthesis is the parent reviewer's job (report PA-004).

### hve-implementation-validator.md (agent — Change #5) [HIGH]
- Add **Dimension 11 — Documentation Integrity**: when a changed file is referenced by a living doc
  (tracked `.md` outside `.claude-hve-tracking/`), Grep the doc for citations into that file and verify
  cited SYMBOLS still exist; flag dead/renamed refs as Minor; prefer pointing at covering tests. Include
  the runnable procedure (report PA-004): for each changed file, `Grep -rl` basename across living docs;
  for each hit, confirm cited symbols still exist.
- Scope enum line 20: add `documentation` (and `overall-quality`) tokens (PA-002).
- Update "ten"/"Ten" counts (lines 9, 25) → "eleven"/"Eleven" (PA-005).
- Coverage Notes (lines 121-122): instruct validator to note the citation-check result even when no dead
  refs found, so the acceptance criterion ("validator output mentions the citation check") is verifiable
  (PA-006).
- Update hve-review.md dimension list to include #11 (keep the two in sync).

## Risks [HIGH]
- DR- prefix collision (plan-log "Discrepancy from Research" vs impl-time discrepancy). Mitigate with a
  local gloss in the implementor file. [MEDIUM] that reviewers still conflate — acceptable.
- Bloat risk: integrate into existing blocks/templates, do not append parallel sections. The acceptance
  for "no bloat" is qualitative; verify in review.
- hve-review's "all 10 dimensions" list and the validator's count must stay in sync — easy to miss one.

## Open questions for planning
- None blocking. All insertion points and rule text are specified by the reports. Proceed to plan.
