# Research: Upstream HVE-Core Drift + Judgment-Layer Sections
Date: 2026-07-12
Task slug: upstream-drift-judgment-layer
Confidence: HIGH overall (all four themes converged; June 2026 upstream commit window pending follow-up — see Key Findings §1)

## Summary

The port (initial commit 2026-05-29) has drifted from an upstream that grew sideways, not forward: microsoft/hve-core added whole subsystems (collections, skills, evals, VS Code extension) that are out of the port's documented scope, while the core RPI methodology changed only marginally. The real drift is semantic and small — five concrete adoption candidates. On the judgment layer, both upstream and the port are thin: the four requested topics (phase-skip criteria, plan-completeness bar, re-plan triggers, ceremony scaling) are mostly unauthored anywhere, so deliverable 2 is original writing constrained by the port's own 2026-06-12 rule/enforcer conventions, not a port of upstream text. Patch placement is constrained by install.sh: docs/ never propagates to installed projects, so judgment rules must land in CLAUDE.md or command/agent files.

## Key Findings

### 1. Upstream state and drift window

- Drift window is 2026-05-29 → 2026-07-12; upstream active through 2026-07-11. [HIGH]
- Upstream reorganized around collections/ (10 domain bundles, maturity tiers), .github/skills/, evals/, plugins/, and a VS Code extension — none exist in the port, and the port's README already declares domain bundles out of scope. [HIGH]
- Latest stable release v3.2.2 (2026-03-23); 3.3.x pre-release train through 3.3.101 (2026-04-25); CHANGELOG.md tracks stable only. Pin drift comparisons to a commit SHA, not the changelog. [HIGH]
- Direct drift in the source agents this port derives from: 2026-07-04 (#2382) task-reviewer H1 alignment + task-researcher handoff `send: true`. Copilot-specific frontmatter mechanics; no Claude Code analogue. [HIGH]
- June 2026 commit window: follow-up round narrowed the observed window to 2026-07-02..07-11 but June itself remains unverified (GitHub commit pages truncate; the 5-week date-bounded fetch returned only Jul 2–3 commits — a weak [LOW] signal June was quiet). Recovered Jul 2–3 commits: template-injection gate (#2344, Medium relevance to the port's security-hygiene checks), VEX gate hardening, CI cleanup. Observed July commits overall are dominated by CI/provenance/security work with low port relevance. [HIGH on what was observed; June absence is [LOW]]
- Pinning caveat: `compare/v3.2.2...main` 404s — the stable tag string is not literally `v3.2.2` (release titles read "hve-core 3.2.2"); resolve the exact tag before pinning drift comparisons. [HIGH]

### 2. Per-phase RPI drift, with adoption verdicts

Verdicts: **Adopt** (port it), **Adapt** (the idea, not the mechanism), **Reject** (judged not worth it — with reason).

- **Adopt** — Research template gaps: upstream mandates "Scope and success criteria" and a "Recommended approach with rationale — ONE approach per technical scenario" in every research doc. The port's template (hve-research.md:82-115) has neither; port research hands off findings without a committed recommendation. Cheap to add, directly improves plan-phase quality. [HIGH]
- **Adopt** — Review runs validation commands: upstream reviewer "runs validation commands (lint, build, test)"; the port's review phase only inspects (tests execute in implement phase only; hve-implementation-validator's test dimension is coverage-inspection). A review verdict that never executes anything can grade ✅ on a broken build. [HIGH]
- **Adapt** — Escalate-back-to-planning: upstream why-rpi has the one judgment idea the port dropped: "When findings reveal gaps, the workflow escalates back to research or planning" and "start with rpi-agent and escalate if the task reveals hidden complexity." The port's every escalation terminates at "surface to user and wait" (hve-implement.md:88). This is the seed for the re-plan-triggers section, but must be reconciled with the port's wait-for-user convention (design decision for Plan phase). [HIGH]
- **Adapt** — Stop-cadence knob: upstream's phaseStop/taskStop ("select cadence based on risk tolerance") is its only ceremony mechanism. The port's /hve already checkpoints per phase; task-level stops would fight the subagent architecture. Fold the risk-tolerance idea into the ceremony-scaling section instead of porting the knobs. [MEDIUM]
- **Reject** — Line-range traceability chain (Plan → Details Lines X-Y → Research Lines A-B): the port's own 2026-06-12 history shows file:line citations rotting twice in one day inside tracking artifacts; a cross-artifact line-number web multiplies that rot. The port's file:line-to-code + plan validator is the deliberate replacement. [HIGH]
- **Reject** — Added/Modified/Removed changes manifest: the port's per-phase narrative changes log (steps, issues, DR-/DD-, corrections) is a superset; converting would lose information for schema compatibility nobody consumes. [HIGH]
- **Reject** — Collections/skills/evals/extension subsystems: explicitly out of the port's documented scope (README scope note). Revisit only if the port's goals change. Upstream's eval framework is the one to watch longer-term (the port's checker-fixture debt is real; see §4 constraint 7). [MEDIUM]
- **Reject** — #2382 handoff `send: true` and H1 alignment: Copilot chatmode mechanics with no Claude Code equivalent. [HIGH]
- Note: upstream brands the methodology 3-phase "Research-Plan-Implement" with review as a role, not a phase; the port's 4-phase framing is a divergence of description, not behavior. No action. [MEDIUM]

### 3. Judgment-layer topics: what exists, what's silent

- **(a) Phase-skip:** binary today — full loop or lightweight whole-loop skip (hve.md:29,38,42); one FAQ answer (docs/workflow.md:204-209) says standalone commands allow skipping but gives no safety criteria. Upstream's only rule is whole-workflow (RPI vs "Quick Edits: typos, log statements, refactors < 50 lines"); intra-loop "no phase-skipping is permitted." Both are silent on when skipping *one* phase is safe. [HIGH]
- **(b) Plan-completeness:** defined only negatively. Checker-side exists (hve-plan-validator.md:26-53: coverage, success criteria, underspecified-steps bullet); implicit bar = no open Critical/Major DR- (hve-plan.md:129); user approval is the actual gate. No author-side sufficiency test ("could the implementor execute this without asking questions?"), no validator-loop bound, no over-planning cap. Upstream is thinner: three reviewer questions, no rubric. [HIGH]
- **(c) Re-plan triggers:** clearest gap. "Re-plan" appears nowhere in .claude/, docs/, or CLAUDE.md; all existing rules stop-and-surface (hve-phase-implementor.md:48-57,124; hve-implement.md:88); the only plan-re-entry hints are post-review routing (hve-review.md:119-122, hve.md:139) and "resume/update existing plan" (hve-plan.md:20). No threshold separates "log the deviation" from "the plan is invalid." Nobody may edit the plan artifact after handoff. Upstream has the escalation *language* (§2 Adapt) but no triggers either. [HIGH]
- **(d) Ceremony scaling:** best-covered topic but entry-only: difficulty is decided in /hve Phase 0, then written nowhere (not persisted into any artifact), so standalone commands and later sessions can't see it; no mid-task reclassification rule; no borderline-classification tie-breaks. [HIGH]
- Observed failure evidence for (b) and (c) is documented in the repo's own history: wrong-predicate "confirmed" plan broke a build; implementor silently edited a failing test's expectation; improvised won't-fix authority (2026-06-12-hve-workflow-tightening-writeup.md:6-64). The root pattern is named there: "judgment without rules." The four sections are the direct answer to that named pattern. [HIGH]

### 4. Constraints any new judgment section must satisfy

1. Rule/enforcer pairing — every author-side rule needs a checker-side acceptance check (2026-06-12 convention). [HIGH]
2. Integrate, don't append — extend the existing difficulty table / Phase 0 / validator steps; no parallel doctrine. [HIGH]
3. Multi-surface sync — ceremony story is quadruplicated (CLAUDE.md, hve.md, README.md, docs/workflow.md) plus per-command Phase 0 blocks; pick one canonical home and cross-reference. [HIGH]
4. Installer propagation — CLAUDE.md block and command/agent files ship to installed projects; docs/ does not (install.sh:79-86,170). New rules must be project-agnostic. [HIGH]
5. No self-graded authority — triggers must key on observable facts (failing test, Critical DR- from a validator, broken dependency), not the acting agent's own severity opinion (known loophole: challenges/2026-06-12:33-35). [HIGH]
6. Escalation endpoint — agent-initiated re-plan vs recommend-to-user must be decided explicitly; upstream's auto-escalation conflicts with the port's wait-for-user convention. [HIGH]
7. Fixture debt — new checker rules enlarge the unverified-checker pile unless behavioral fixtures accompany them (challenge:55-69). [MEDIUM]

### 5. Internal inconsistencies found in passing (patch candidates for deliverable 3)

- Dead flag: hve-implement.md:3 advertises `--mode` but the body never parses it; hve-plan.md:35 honors `--mode` but with mismatched vocabulary (lightweight/standard/full vs simple/standard/complex, mapping never stated). [HIGH]
- Dead zone: Medium-Hard's "extra plan validation" (hve.md:31, CLAUDE.md:27) is implemented nowhere. [HIGH]
- Dead differentiation: full mode's "parallel implementors" (hve.md:40) is already the universal default (hve-implement.md:91). [HIGH]
- Stale doc: docs/internals.md:48 says "10 checks"; the validator defines 11 dimensions and three other docs say 11. [HIGH]
- Difficulty classification is never persisted into tracking artifacts. [HIGH]

## Codebase References

.claude/commands/hve.md — orchestrator; Phase 0 difficulty + mode logic (ceremony canonical-home candidate)
.claude/commands/hve-research.md, hve-plan.md, hve-implement.md, hve-review.md — phase commands; patch targets
.claude/agents/hve-phase-implementor.md — STOP/escalation rules; re-plan trigger insertion point
.claude/agents/hve-plan-validator.md — checker-side pair for plan-completeness rules
.claude/agents/hve-implementation-validator.md — 11 dimensions; internals.md drift referent
CLAUDE.md — difficulty table + conventions; only doc surface that propagates on install
install.sh — propagation constraint (:79-86, :170)
docs/workflow.md, docs/internals.md, README.md — sync-burden surfaces
2026-06-12-hve-workflow-tightening-writeup.md, .claude-hve-tracking/research/2026-06-12/hve-workflow-tightening.md, .claude-hve-tracking/challenges/2026-06-12-hve-workflow-tightening-challenge.md — failure evidence + authoring constraints

Subagent artifacts (full detail):
.claude-hve-tracking/research/subagents/2026-07-12/upstream-drift-upstream-inventory.md
.claude-hve-tracking/research/subagents/2026-07-12/upstream-drift-rpi-deep-dive.md
.claude-hve-tracking/research/subagents/2026-07-12/upstream-drift-local-port-map.md
.claude-hve-tracking/research/subagents/2026-07-12/upstream-drift-judgment-gaps.md

## External References

https://github.com/microsoft/hve-core (+ /commits/main, /releases, raw CHANGELOG.md)
https://microsoft.github.io/hve-core/ (+ /docs/rpi/, /docs/rpi/task-researcher, task-planner, task-implementor, task-reviewer, why-rpi, /docs/hve-guide/roles/engineer)

## Patch-target map (for Plan phase)

| Deliverable | Primary target | Checker-side pair |
|---|---|---|
| Drift adoptions: research template (scope/success criteria + Recommended Approach) | .claude/commands/hve-research.md Phase 3 template | hve-plan-validator (research-input completeness) |
| Drift adoption: review executes lint/build/test | .claude/commands/hve-review.md | verdict gate (results recorded in review log) |
| (a) phase-skip criteria | .claude/commands/hve.md Phase 0 + CLAUDE.md near difficulty table | user-confirmation gate already exists (hve.md:42) |
| (b) plan-completeness bar | .claude/commands/hve-plan.md adjacent to Evidence Rules (:84-90) | hve-plan-validator.md Step 3 (:46-53) |
| (c) re-plan triggers | .claude/agents/hve-phase-implementor.md (:48-57,124) + hve-implement.md:88 receiver | hve-rpi-validator (trigger events must appear in changes log) |
| (d) ceremony scaling | .claude/commands/hve.md Phase 0 (canonical), CLAUDE.md prose cross-ref | — (entry-point guidance; enforce via persisted classification) |
| Consistency fixes (dead flag, dead zone, internals.md "10 checks") | per §5 | docs-drift test exists (tests/) per commit 9b610f7 |

## Open Questions

1. What is the intended semantics of `--mode` on /hve-plan and /hve-implement — functional (define the mapping to plan complexity) or vestigial (remove from argument-hints)?
2. What was "extra plan validation" for Medium-Hard meant to be? Define it or delete the phrase.
3. Should difficulty classification persist into artifact frontmatter so standalone commands, re-plan triggers, and later sessions can read it? (Research recommendation: yes — it is the precondition for enforceable ceremony scaling.)
4. Re-plan escalation endpoint: agent-recommends-re-plan (stays within wait-for-user convention) vs agent-initiates? Must be a DD- item in the Plan phase.
5. June 2026 upstream commits remain unverified after one follow-up round (commit-page truncation; weak signal June was quiet). Definitive closure path: resolve the exact stable tag name, then fetch the working compare view. If June held methodology changes, the §2 verdict list may grow.

## Recommendations (preliminary)

Section added beyond the standard template because the research questions were evaluative (see friction log entry 4). Adopt/Adapt/Reject verdicts inline in §2; net: 2 Adopt, 2 Adapt, 4 Reject. The judgment-layer sections (deliverable 2) should be authored from §3 silence points under §4 constraints — upstream has almost nothing to port there.

## Recommended Research Follow-On

- [ ] Definitively close June 2026: resolve upstream's exact stable tag string, fetch compare view tag...main (one follow-up round already spent; page truncation blocked full closure)
- [ ] Verify docs-site paraphrases against raw upstream agent files (raw.githubusercontent.com paths) before treating §2 upstream quotes as verbatim
- [ ] Decide canonical ceremony home (CLAUDE.md vs hve.md Phase 0) before drafting deliverable 2
- [ ] Resolve Open Questions 1–2 with the user (they shape the ceremony-scaling section)
- [ ] Confirm per-agent upstream name mappings (currently [MEDIUM], blog asserts 8-to-8 only)
