# Research: Friction Log Remediation — What to Change in the HVE Claude Process
Date: 2026-07-17
Task slug: friction-log-remediation
Confidence: HIGH overall

## Summary

Nine ad hoc friction logs written 2026-07-12/13 across four repos (Fieldnotes, privy-mvp, Krava-Standup, hve-claude) contain 61 distinct issues (14 Fieldnotes F-IDs + 47 other-repo O-IDs after dedup). The overwhelming majority are genuine, verifiable defects in the HVE prompt/doc definition — not one-off task problems (only O-18 is one-off; only O-06 is partly a platform limitation). All friction was generated against the **current** process definition: the three consumer repos run the global `~/.claude` install, which matches repo main, and every landed improvement (workflow tightening 2026-06-17, model retiering and `--global` 2026-07-06) predates the complaints. None of the logs' suggested fixes have been applied as of today.

## Key Findings

### Meta-findings (context for remediation)

- None of the suggested fixes have landed: hve-review.md:24 hard-stop, hve-plan.md:19 fuzzy discovery, hve-implement.md:47 timestamp field, hve-implement.md:78 unconditional spawn all still carry the criticized text. [HIGH]
- Friction was NOT caused by stale installs. Fieldnotes/privy-mvp/Krava-Standup have no local `.claude/` HVE files; the global install matches repo main. Fixes belong in this repo, then `./install.sh --global` re-sync. [HIGH]
- No friction-log mechanism exists in any command or agent (zero grep hits for friction/feedback). The 9 logs were ad hoc; three sessions invented three different homes for them (O-43). A capture step + canonical home is net-new work. [HIGH]
- Direct proof that logging without patching does not prevent recurrence: the timestamp fabrication (F-06) reproduced in a fresh subagent hours after the fix was first proposed. [HIGH]
- Do-not-break constraints (worked as designed, per hve-claude log :82-87): Subagent Response Protocol scaling, handoff-by-disk discovery, self-enforcing confidence markers. [HIGH]

### Cluster A — Missing/irrelevant artifact gates at phase entry (highest-consensus systemic defect)

Issues: F-01, F-02, O-14, O-19, O-20, O-21, O-29 (+O-18 downstream). 8+ entries across 5 logs, 3 repos.

- /hve-plan attaches the topically irrelevant "most recent" research doc as the plan's evidence base; no branch for "no relevant research exists" (hve-plan.md:19). [HIGH]
- /hve-review hard-stops on missing research/details even for deliberately-skipped, user-approved lightweight runs (hve-review.md:24) — "process theater" that tempts after-the-fact fabrication. [HIGH]
- /hve-implement has no cold-start branch when no plan file exists (K-IMP entry 1). [HIGH]
- The details file is a required review input that no phase actually reads (O-20) — a tripwire with no payoff. [HIGH]
- "Most recent" is underdetermined when two same-day tasks exist (O-21) — silent wrong-task review risk. [HIGH]
- Remediation shape: one shared "artifact discovery + relevance + recorded-skip" convention (slug/topic match; `Research: none` + DD- entry legitimizes skips; hard stop only for unreconstructible inputs, i.e. plan/changes log; tie-break same-day slugs by completeness then branch name, else ask). Files: hve-plan.md, hve-implement.md, hve-review.md, hve-challenge.md, CLAUDE.md.

### Cluster B — Simple-task carve-outs vs unconditional subagent dispatch

Issues: F-03, F-04, F-05, O-15, O-02. 5+ entries across 4 logs; quantified waste ~160K/~154K/~57K tokens on <15-line changes.

- Command text unconditionally spawns implementors/validators, directly contradicting CLAUDE.md's "Simple: skip subagents" (hve-implement.md:78; hve-review.md per-phase validator dispatch). [HIGH]
- /hve-research Inputs default ("standard, 2–3") conflicts with Phase 0 difficulty table counts; both claim the no-flag case (O-02, hit in 2 repos). [HIGH]
- "1–3 steps" ambiguity (phases vs checklist bullets, F-04) and no risk/blast-radius axis in the difficulty table (F-05). [MEDIUM]
- Remediation shape: Simple carve-out in implement (direct implementation, changes log still written) and review (one consolidated validator pass); `--mode` line applies only when the flag is passed; footnote defining "steps"; risk-override clause ("consumed outside this repo → at least Medium"). Files: hve-implement.md, hve-review.md, hve-research.md, CLAUDE.md.

### Cluster C — Self-contradictory or fabrication-inducing template text

Issues: O-01, F-06, F-07, O-23. O-01 ranked #1 in both logs that hit it.

- /hve-research Phase 3 step 1 ("read each subagent output file") vs step 2 ("do not paste large file contents — summary lines only") forbid each other; literal reading produces hollow consolidated docs (O-01). Both logs converge on the same fix: read subagent artifacts in full (they are already condensed); don't re-open the sources they cite. [HIGH]
- Changes-log `Started:/Completed: [timestamp]` invites fabricated timestamps (no clock tool); `2026-07-13T00:00:00Z` observed live, twice (F-06). Fix in BOTH hve-implement.md:47 template and hve-phase-implementor.md. [HIGH]
- "Record `Tests: X passed, Y failed`" with no branch for repos without a test runner invites invented counts (F-07). [HIGH]
- Review consolidation covers Critical/Major only, but the Summary tallies Minors and routing has a Minor-only branch — fabricated-tally trap on the common happy path (O-23). [HIGH]

### Cluster D — Verdict integrity (review + PR review)

Issues: O-22, O-26, O-31, O-35, O-36, O-38, O-30, O-28, F-09, F-10.

- O-31: empty base diff (all work uncommitted) yields a silent "0 files changed → Approve" in /hve-pr-review — worst wrong-verdict path. Guard: never verdict an empty diff; check git status; ask. [HIGH]
- O-22: three-way conflict — "contradictions without corrections → Needs Rework" + "you do not implement" + "learning phase owns the correction" forces a full rework loop for a trivially-fixable Minor. Fix: review writes record-only corrections itself. [HIGH]
- Severity machinery gaps that move Approve/Request-Changes outcomes: no dedup severity-reconciliation rule (O-35), pre-existing-defect counting undefined (O-36), IV-NNN IDs collide across 8 parallel reviewers — need dimension prefixes (O-38). [HIGH]
- Evidence Rules: an unverified grep citation passed as a [HIGH] exhaustiveness claim (live failure, F-09); plan-time vs post-action verification semantics undefined (F-10). One edit to hve-plan.md's Evidence Rules covers both. [HIGH]

### Cluster E — /hve-pr-review mechanical defects

Issues: O-32, O-33, O-34, O-37, O-39, O-40, O-41, O-42.

- Path drift: command says `pr/review/`, CLAUDE.md says `reviews/pr/` (O-32) — artifacts fork, auto-discovery breaks. [HIGH]
- `$ARGUMENTS` blob (62-line pasted handoff block) read literally as the branch name (O-33); no designated PR-review subagent type (O-34); no resume semantics after interruption (O-37); slash-containing branch names break the folder layout (O-40); diff duplicated verbatim into 8 prompts and untracked files uncovered (O-42). [HIGH/MEDIUM]

### Cluster F — Cross-phase structural gaps

Issues: O-09, O-12, O-11, O-17, O-10, O-08.

- Standing instructions and mid-flow scope changes are guaranteed lost at phase handoffs (disk-only handoff by design); proven live twice in one session; the "Requirements added after <phase>" appendix convention is already user-ratified and awaits doc promotion (O-09). [HIGH]
- Parallel phase implementors sharing one changes log = silent concurrent-write data loss; forbid whole-file Write, one `### Phase N` section per agent via targeted Edit (O-12). [HIGH]
- Test gate assumes a clean baseline (O-11: pre-existing failures make the gate unusable) and cannot distinguish regression from intentionally-obsoleted contract (O-17). Fix: Phase-1 `## Test Baseline`, gate on net-new failures, license test rewrites when the plan changes the contract. [HIGH]
- DR- stop rule halts on plan-pre-authorized adaptations (O-10): stop only when unresolved, functionality-affecting, or beyond granted latitude. [HIGH]

### Cluster G — Subagent tooling and delegation mismatches

Issues: F-11, O-05, O-06, O-07, O-03.

- Parent delegated shell verification to hve-rpi-validator, which has no Bash — silent downgrade to static inference (F-11). Rule: shell verification happens in the parent; check tool lists before delegating. [HIGH]
- hve-researcher has no Bash → git-history questions cannot be delegated; parent orientation doesn't authorize git either (O-05, 2 repos). Document the parent-digest routing or grant constrained read-only git. [HIGH]
- WebFetch: no raw-URL guidance for GitHub (O-06), 3-URL cap miscalibrated when the subject IS an external repo (O-07). No bounded follow-up round for flagged evidence gaps (O-03). [MEDIUM]

### Cluster H — Naming, taxonomy, formatting polish

Issues: O-43, O-44, F-12, O-45, O-46, O-16, F-08, O-13, F-13, F-14, O-24, O-25, O-27, O-41, O-47.

- No canonical home for friction/meta artifacts — 3 sessions invented 3 homes (O-43); slug derivation undefined for compound prompts (O-44); `$ARGUMENTS` re-substituted 4x in hve-plan.md (F-12). [HIGH]
- Missing instructions files for JavaScript and TypeScript, and no fallback rule for unlisted languages — a literal follower blocks at a numbered step (F-08 + O-13, 2 repos). [HIGH]
- Minor: parallelization ambiguities (F-13, O-24, O-25), fixed-width handoff box breaks on real paths (O-46), Response Format restated in 9 places and --subagent-model boilerplate in 8 (maintenance fan-out), global+dev-repo double context load (O-47).

## Codebase References

.claude/commands/hve-plan.md (Cluster A discovery :19, F-12 $ARGUMENTS :11/19/28/35, Evidence Rules :84-90, validator gating :121-131)
.claude/commands/hve-implement.md (discovery :19-21, changes-log template :36-68 incl. timestamp :47, spawn :78, STOP rule :88, testing :97-107)
.claude/commands/hve-review.md (discovery+stop :19-24, record consistency :33, parallel :68, status rules :114-117, routing :119-123)
.claude/commands/hve-research.md (mode counts :18/23-36, dispatch :57-69, Phase 3 contradiction, template :82-115)
.claude/commands/hve-pr-review.md (Cluster E: path drift, $ARGUMENTS, dispatch :60-90)
.claude/commands/hve-challenge.md (discovery :26)
.claude/agents/hve-phase-implementor.md (:43-66 log duty, :124 skip rule — timestamp fix needed here too)
.claude/agents/hve-rpi-validator.md, hve-plan-validator.md (no Bash — F-11 delegation rule)
.claude/agents/hve-researcher.md (:85-96 response format; O-05/O-06/O-07 tooling notes)
.claude/instructions/ (12 files; no javascript.md or typescript.md)
CLAUDE.md (difficulty table, severity grading, corrections, tracking tree, handoff block, naming)
Subagent inventories: .claude-hve-tracking/research/subagents/2026-07-17/friction-inventory-fieldnotes.md, friction-inventory-other-repos.md, hve-current-state.md

## External References

None consulted.

## Open Questions

1. Friction-capture step: should it become a permanent optional step (e.g. `--friction` flag or a standing rule in CLAUDE.md), and which phase owns it (hve-review Phase 4 vs hve-memory)? Canonical home for the artifact (O-43) must be picked at the same time.
2. O-05: grant hve-researcher constrained read-only Bash (git log/show only) or keep the no-Bash safety posture and document parent-side digest routing? (Same fork for F-11's validators.)
3. F-05 risk axis: full second classification axis, or just the one-sentence risk-override clause the log proposes?
4. Sequencing: deduplicate the 9-way Response Format and 8-way --subagent-model boilerplate first (touch-once), or accept double edits and ship the high-priority fixes immediately?
5. O-34: add a dedicated hve-pr-reviewer agent (new file, roster growth) or bless general-purpose + embedded protocol?

## Recommended Research Follow-On

- [ ] Draft the shared "artifact discovery, relevance check, recorded-skip" convention once; apply to plan/implement/review/challenge (Cluster A)
- [ ] Draft the Simple carve-out wording once; apply to implement + review; fix the research mode/table conflict (Cluster B)
- [ ] Apply the four one-edit template fixes: O-01 consolidation text, F-06 timestamp fields (2 files), F-07 no-runner branch, O-23 Minor consolidation
- [ ] Patch verdict-integrity set: O-31 empty-diff guard, O-22 record-only corrections, O-35/O-36/O-38 severity rules, F-09/F-10 Evidence Rules edit
- [ ] After edits land: run ./install.sh --global to re-sync ~/.claude, then re-run a Simple task end-to-end in a consumer repo to confirm the carve-outs fire
