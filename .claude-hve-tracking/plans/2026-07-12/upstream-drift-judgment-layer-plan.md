# Implementation Plan: Upstream Drift Adoption + Judgment-Layer Sections
Date: 2026-07-12
Task slug: upstream-drift-judgment-layer
Research: .claude-hve-tracking/research/2026-07-12/upstream-drift-judgment-layer.md
Difficulty: Medium-Hard (cross-cutting, multiple modules; persisted here per DD-002)
Status: Validated (plan-validator Pass, 2026-07-12, no Critical/Major); Phases 1-5 executable now, Phase 6 steps 6.6/6.7 gated on DD-003/DD-004 (user decisions pending)

## Execution Notes (read first in a future session)

- Intended executor: an Opus-tier session. Run `/hve-implement` with the session model set to opus (implementor subagents are `model: inherit`), or pass `--subagent-model opus`.
- Two steps are BLOCKED on user decisions logged as DD-003 and DD-004 in the planning log. Implement everything else; when reaching a blocked step, surface it and wait (per hve-implement.md step 6). Do not guess the answers.
- All line citations below were re-verified against the working tree on 2026-07-12 via targeted `sed -n` reads; they are snapshots and may drift after any edit to the cited file.
- Constraint recap from research §4 (binding on every phase): (1) every author-side rule gets a checker-side pair; (2) integrate into existing tables/steps, never append parallel doctrine; (3) one canonical home per rule, cross-reference elsewhere; (4) new rules must live in CLAUDE.md or .claude/ files because docs/ does not propagate on install (install.sh:79-86,170); (5) triggers key on observable facts, never the acting agent's own severity opinion; (6) escalation endpoint is recommend-to-user (DD-001); (7) new checker rules ship with behavioral fixtures.

## Overview

Adopt the two upstream drift items judged worth porting (research template gaps, review-phase validation execution), then author the four judgment-layer sections (phase-skip criteria, plan-completeness bar, re-plan triggers, ceremony scaling) as original writing grounded in the research's §3 silence points and §4 constraints. Fold in the §5 consistency fixes. Foundation step: persist difficulty classification into artifact frontmatter, which ceremony scaling and standalone-command behavior depend on.

## Phases

### Phase 1: Research Template Upgrade (drift Adopt #1)
Dependencies: none
Estimated scope: 2 files, ~40 lines (.claude/commands/hve-research.md, .claude/agents/hve-plan-validator.md) + 1 fixture
Success criteria: consolidated research template contains "Scope and Success Criteria" and "Recommended Approach" sections; plan validator flags research inputs missing them; fixture exercises the new check.

Steps:
- [ ] Step 1.1: Add a "Scope and Success Criteria" section to the consolidated research template in .claude/commands/hve-research.md (template block spans hve-research.md:84-115; verified by direct read 2026-07-12) [HIGH]
- [ ] Step 1.2: Add a "Recommended Approach" section to the same template: exactly one recommended approach per technical scenario, with rationale, per upstream mandate (research §2 Adopt #1)
  - Assumption: upstream wording was taken from the docs site, not raw agent files; treat as paraphrase, write native text rather than quoting [MEDIUM]
- [ ] Step 1.3: Checker pair: extend hve-plan-validator.md Step 1 (hve-plan-validator.md:26-32) to check research-input completeness; missing scope/success-criteria or recommended-approach sections emit a DR- item (Major if the plan diverges from an absent recommendation, Minor otherwise)
- [ ] Step 1.4: Add a behavioral fixture under tests/fixtures/ covering the new validator rule and wire it into the existing drift/behavior test runner (tests/run-drift-tests.sh exists; verified by ls 2026-07-12) [HIGH]
- [ ] Step 1.5: Sync surfaces that restate the research template (docs/workflow.md research section, if it reproduces the template) [MEDIUM]

### Phase 2: Review Phase Executes Validation Commands (drift Adopt #2)
Dependencies: none
Estimated scope: 1-2 files, ~30 lines (.claude/commands/hve-review.md; docs sync)
Success criteria: /hve-review runs project lint/build/test commands when they exist, records commands and outcomes in the review log, and the ✅ Complete verdict is unreachable without recorded results or an explicit no-runnable-checks note.

Steps:
- [ ] Step 2.1: Add a validation-execution step to hve-review.md: detect and run the project's lint/build/test commands, record each command and its outcome verbatim in the review log
- [ ] Step 2.2: Gate the verdict: extend the ✅ Complete criteria (hve-review.md:115-117; verified by direct read 2026-07-12) to require recorded validation results, or a dated "no runnable checks defined for this project" note [HIGH]
- [ ] Step 2.3: Sync docs that describe review as inspection-only (docs/workflow.md, docs/internals.md) [MEDIUM]

### Phase 3: Persist Difficulty Classification (foundation; DD-002)
Dependencies: none
Estimated scope: 4-5 files, ~40 lines (hve.md, hve-research.md, hve-plan.md, hve-implement.md or hve-phase-implementor.md templates)
Success criteria: difficulty classification decided in /hve Phase 0 is written into artifact frontmatter (`Difficulty:` line); standalone phase commands read it from the latest artifact when present; a checker flags its absence.

Steps:
- [ ] Step 3.1: Add a `Difficulty:` frontmatter line to the research, plan, and changes-log templates (research template hve-research.md:84-115; plan template in hve-plan.md Phase 2 section) [HIGH]
- [ ] Step 3.2: hve.md Phase 0 (classification table at hve.md:25-42; verified by direct read 2026-07-12) writes the decided classification into the first artifact it creates [HIGH]
- [ ] Step 3.3: Standalone phase commands read `Difficulty:` from the discovered upstream artifact and carry it forward; when absent, infer per existing behavior and note the inference
- [ ] Step 3.4: Checker pair: hve-plan-validator flags a plan missing `Difficulty:` as a Minor DD- item; add fixture per constraint 7. Research and changes-log artifacts rely on template self-enforcement only (validator ruling 2026-07-12: the plan is the load-bearing handoff; do not add runtime checkers for the other two)

### Phase 4: Plan-Completeness Bar (judgment section b)
Dependencies: Phase 1 (bar references the Recommended Approach section), Phase 3 (bar scales with difficulty)
Estimated scope: 2 files, ~50 lines (.claude/commands/hve-plan.md, .claude/agents/hve-plan-validator.md) + 1 fixture
Success criteria: hve-plan.md states an author-side sufficiency bar; hve-plan-validator Step 3 grades against the same bar; validation loop is bounded.

Steps:
- [ ] Step 4.1: Author the bar in hve-plan.md adjacent to Plan-Step Evidence Rules (hve-plan.md:84-90; verified by direct read 2026-07-12): a plan is complete when (a) a separate implementor could execute it without asking questions, (b) no open Critical/Major DR- items, (c) every phase has a testable success criterion, (d) every research requirement maps to at least one step or a logged won't-cover decision [HIGH]
- [ ] Step 4.2: Add the over-planning cap: planning depth scales with the persisted Difficulty; Simple tasks cap at a single-phase plan (integrates with existing Phase 1 complexity assessment, not a new parallel table)
- [ ] Step 4.3: Bound the validator loop: at most 2 validation rounds; unresolved Critical/Major after round 2 surfaces to the user rather than iterating
- [ ] Step 4.4: Checker pair: extend hve-plan-validator.md Step 3 (hve-plan-validator.md:46-53; verified by direct read 2026-07-12) to grade each bar clause explicitly [HIGH]
- [ ] Step 4.5: Fixture for the new Step 3 clauses per constraint 7

### Phase 5: Re-Plan Triggers (judgment section c; DD-001 governs endpoint)
Dependencies: Phase 3 (reclassification hooks read persisted difficulty)
Estimated scope: 3 files, ~60 lines (.claude/agents/hve-phase-implementor.md, .claude/commands/hve-implement.md, .claude/agents/hve-rpi-validator.md) + 1 fixture
Success criteria: an enumerated, observable-fact trigger list separates "log the deviation and continue" from "the plan is invalid"; the endpoint is recommend-to-user; plan amendments after handoff are dated and owned by /hve-plan; the RPI validator checks trigger events appear in the changes log.

Steps:
- [ ] Step 5.1: Add the trigger list to hve-phase-implementor.md within the existing blocker/STOP rules (hve-phase-implementor.md:48-57; verified by direct read 2026-07-12). Triggers must be observable facts per constraint 5: a failing build, a test failure revealing behavior the plan does not cover, a missing file/dependency the plan assumed present, a Critical or Major DR- raised by a validator, a plan step impossible to execute as written [HIGH]
- [ ] Step 5.2: State the threshold: one trigger inside a single phase's scope = log DR- and halt the step (existing behavior); a trigger that invalidates a dependency between phases, or 2+ triggers against the same plan phase, = recommend re-plan
- [ ] Step 5.3: Receiver in hve-implement.md step 6 (hve-implement.md:88; verified by direct read 2026-07-12): on a re-plan recommendation, surface to the user with explicit routing to /hve-plan resume/update (hve-plan.md:20) [HIGH]
  - Assumption: endpoint is recommend-to-user, never agent-initiated re-planning, per DD-001 [HIGH]
- [ ] Step 5.4: Plan immutability rule: after handoff, only a /hve-plan session may amend the plan artifact, via dated `Amendment (YYYY-MM-DD):` entries mirroring the CLAUDE.md corrections convention; implementors never edit the plan
- [ ] Step 5.5: Checker pair: hve-rpi-validator verifies every trigger event claimed in chat appears in the changes log, and every re-plan recommendation cites its triggering fact
- [ ] Step 5.6: Fixture for the new rpi-validator rule per constraint 7

### Phase 6: Phase-Skip Criteria + Ceremony Scaling + Consistency Fixes (judgment sections a and d)
Dependencies: Phase 3 (persisted classification), Phase 5 (reclassification reuses trigger list). Steps 6.6 and 6.7 additionally BLOCKED on DD-003/DD-004.
Estimated scope: 5-6 files, ~80 lines (hve.md, CLAUDE.md, README.md, docs/workflow.md, docs/internals.md, hve-plan.md/hve-implement.md if DD-003 resolves functional)
Success criteria: hve.md Phase 0 is the canonical home for phase-skip and ceremony-scaling rules (DD-005); CLAUDE.md cross-references rather than duplicates; §5 consistency fixes landed; drift tests pass.

Steps:
- [ ] Step 6.1: Author phase-skip criteria in hve.md Phase 0: skipping a single phase is safe only when its input artifact already exists, is for the same task slug, and postdates the last change to the code it describes; otherwise run the phase. Cross-reference from CLAUDE.md near the difficulty table and from the docs/workflow.md FAQ (docs/workflow.md:204-209 per research; not re-verified this session) [MEDIUM]
- [ ] Step 6.2: Author ceremony scaling in hve.md Phase 0 (canonical per DD-005): borderline classifications take the higher ceremony; mid-task reclassification moves upward only, triggered by the Phase 5 trigger list, and is recorded in the changes log; fold in upstream's risk-tolerance framing as prose guidance, not new knobs (research §2 Adapt #2)
- [ ] Step 6.3: Multi-surface sync per constraint 3: CLAUDE.md, README.md, docs/workflow.md restate ceremony only as short cross-references to hve.md Phase 0
- [ ] Step 6.4: Consistency fix: docs/internals.md:48 says "10 checks"; the validator defines 11 dimensions (stale text re-verified by direct read 2026-07-12). Update to 11 and re-run the docs-drift test [HIGH]
- [ ] Step 6.5: Consistency fix: reword the full-mode row (hve.md:40) so parallel implementors are not presented as full-mode-only, since they are the universal default (hve-implement.md:91; both verified by direct read 2026-07-12) [HIGH]
- [ ] Step 6.6: BLOCKED on DD-003: make `--mode` on /hve-plan and /hve-implement functional with a stated vocabulary mapping, or remove it from argument-hints (hve-implement.md:3 advertises it, body never parses it; verified by direct read 2026-07-12). Surface to user; do not implement either branch without the decision [HIGH]
- [ ] Step 6.7: BLOCKED on DD-004: define Medium-Hard "extra plan validation" (hve.md:31, CLAUDE.md difficulty table) or delete the phrase from both surfaces. Surface to user; do not implement either branch without the decision [HIGH]
- [ ] Step 6.8: Run tests/run-drift-tests.sh and tests/run-install-tests.sh; all green before the phase is marked complete

## Risk Log
| Risk | Likelihood | Mitigation |
|---|---|---|
| June 2026 upstream commits held methodology changes that would grow the Adopt list (window unverified, DR-001) | Low | Proceed on observed drift; follow-on item to resolve the exact stable tag and fetch the compare view before the next drift review |
| Multi-surface drift: ceremony story lives in 4+ places and new text creates a 5th | Medium | Constraint 2/3 discipline: hve.md Phase 0 canonical, everything else cross-references; docs-drift test run in Step 6.8 |
| Blocked steps 6.6/6.7 stall Phase 6 indefinitely | Medium | Steps 6.1-6.5 and 6.8 are executable without them; implementor surfaces the two DD items and completes the rest |
| New checker rules enlarge unverified-checker debt | Medium | Constraint 7: every new checker rule (Steps 1.4, 3.4, 4.5, 5.6) ships with a fixture in the same phase |
| Plan-time line citations rot before a future session implements | Medium | Each citation is dated; implementor treats them as hints and re-greps the anchor text before editing |

## Testing Approach

- Behavioral fixtures accompany each new checker rule (Steps 1.4, 3.4, 4.5, 5.6) and run via the existing tests/ runners.
- tests/run-drift-tests.sh guards docs/spec agreement (dimension counts, command tables) and runs after Phases 2, 3, and 6.
- tests/run-install-tests.sh confirms the installer still propagates edited command/agent files and the CLAUDE.md merge block after Phase 6.
- Manual spot-check: grep each rule's canonical phrase across CLAUDE.md, README.md, docs/ to confirm single-home + cross-reference structure (constraint 3).
