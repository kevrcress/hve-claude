# Planning Log: Project Communication and Visual Presence (Thread A)
Date: 2026-08-19
Plan: .claude-hve-tracking/plans/2026-08-19/project-communication-presence-plan.md

## Discrepancies

### DR-001: Research open question 1 was answerable from disk
Source: Research A5 says Fieldnotes is "insufficient to judge reusability" and raises it as an
open question rather than guessing.
Resolution: The parent inspected /Users/kevin/GitHub/Fieldnotes during planning. It runs: static
dashboard, two views, custom icons, a UI spec, Node stdlib only, and a manifest regenerated
2026-08-19 at 11:58 across six projects. The research was correct not to guess, but the question
was cheaper to answer than it looked. Whether it is screenshot-worthy remains Kevin's judgment,
which is why Step 4.1 assesses before Step 4.2 scopes.
Status: Resolved

### DR-002: Research treated the mermaid diagram as a low-risk drop-in
Source: Research A4 ranks the mermaid diagram first and notes GitHub renders ```mermaid natively,
implying the work is authoring plus paste.
Resolution: The parent compiled four candidate diagrams during planning. All four were
syntactically valid; three were rejected on legibility. The naive subgraph-based version renders
Review top-left with a snaking spine. The plan therefore ships a validated source in the details
file rather than an instruction to author one, and records the `direction LR` override trap that
caused two of the three failures.
Status: Resolved

### DR-003: Research cited stale test counts
Source: Research A3 cites drift 248/0 and install 66/0 from the 2026-08-15 review.
Resolution: Re-measured during planning: drift 255/0, install 69/0. Both plans use the measured
figures. Relevant here because drift test 16 reads README.md, so Thread A's README edits can break
the suite.
Status: Resolved

### DR-004: Evidence-anchor quotes were not re-verified during planning
Source: Research A3 gives exact line ranges for three evidence anchors.
Resolution: Not verified this session. The plan carries the citations from the research doc and
Step 2.3 requires re-verifying each quote against the source file before publishing. Marked
[MEDIUM] in the plan rather than asserted. A misquoted evidence anchor in a README whose thesis is
"evidence over assertion" is worse than no anchor.
Status: Open by design, guarded by Step 2.3

### DD-002: Mermaid layout attempts count mismatch
Source: Plan Step 1.1 states "Two earlier layout attempts were compiled and rejected on legibility,
not syntax: a TB version with subgraphs placed Review top-left and snaked the spine, and an LR
version wrapped into two rows."
Assumption: The plan's summary count of "Two" earlier attempts is correct.
Evidence mismatch: The details file (project-communication-presence-details.md:52-64) lists three
rejected attempts, not two: (1) TD with subgraphs (top-left snaking), (2) LR with direction TB
inside (wrapped), (3) TB with direction LR inside (vertical stacking). The plan mentions all three
but only counts two in the summary. The parent's pretest results confirm "All four compiled...
rejected the first three on legibility." The plan does describe the third attempt in the next
bullet under the "direction LR" mermaid behavior trap, but the "Two earlier" count is wrong.
Risk: Off-by-one in the summary could mislead the implementor, though the full text does cover all
three rejected attempts. Minor clarity issue, no blocking risk.
Severity: Minor
Recommendation: Change Step 1.1 second bullet from "Two earlier layout attempts" to "Three earlier
layout attempts" to match the details file and pretest evidence.
Status: Open

## Design decisions

### DD-001: WHY case rebuilt from existing artifacts, no new measurement run
Source: Research A1 and open question 2; Kevin chose the artifact-quoting option on 2026-08-19.
Assumption: Three committed artifacts showing verification discipline are more persuasive, and far
cheaper, than a vanilla-vs-HVE token comparison of unknown cost.
Risk: The Benefits table's comparative claims still have no measurement behind them. Step 2.2 cuts
or hedges rather than leaving them asserted, so the README does not keep claiming what it cannot
show.

### DD-002: Merge the remediation branch before anything else
Source: Research open question 3; Kevin chose merge-first on 2026-08-19.
Assumption: PR #3 is mergeable as-is (3 commits ahead of main, 0 behind, verified during planning).
Risk: If review of PR #3 turns up blockers, all of Thread A stalls, since every evidence link
depends on it. Phase 0 is deliberately its own phase so this is visible rather than buried.

### DD-003: Fieldnotes gets a polish pass before being screenshotted
Source: Research open question 1; Kevin chose polish-then-screenshot on 2026-08-19.
Assumption: The polish pass is presentation-only and small.
Risk: This is the highest scope-creep risk in the plan, because it is work in a second repo with
an external consumer. Step 4.2 caps it explicitly and names the frozen contract (the Krava Standup
Electron app pins the `stable` branch and renders index.html directly). If Step 4.1 shows the
polish is not small, that is a stop-and-ask moment, not a quiet expansion.

### DD-004: asciinema recording is scheduled last
Source: Research A4 ranks it second by impact but flags the highest refresh cost; Kevin included
it on 2026-08-19.
Assumption: Thread B is about to change how every command closes, so any recording made before
Thread B lands is stale on arrival.
Risk: The recording is the most likely phase to be dropped for cost. Acceptable: Phases 1 through 4
stand alone without it. asciinema is not currently installed (verified during planning), so Step
5.1 is a real prerequisite rather than an assumption.

### DD-005: No GitHub Pages, homepage stays null
Source: Research A4 recommends option (a), README-as-homepage.
Assumption: The README covers pitch through evidence, and Pages is cheap to add later with nothing
wasted.
Risk: None material at current audience size (1 star, 0 forks, verified 2026-08-19). Noted because
docs/workflow.md:5 links ../README.md, which would 404 on a docs/-scoped Pages site, so enabling
Pages later is not zero-work.

### DD-006: HiVE is not named publicly
Source: Research A5, marked [MEDIUM].
Assumption: An unreleased repo with a provisional name carrying documented collision and trademark
risk should not be announced in a README.
Risk: None. Two honest substitutes are recorded in the details file if a forward-looking line is
wanted.

### DD-007: Two plans, one per thread, with distinct slugs
Source: Research planning recommendation, marked [HIGH]; Kevin chose both-as-two-plans.
Assumption: Distinct slugs (`phase-close-clarity`, `project-communication-presence`) are correct
even though both derive from one research doc, because artifact discovery keys on slug.
Risk: `/hve-implement` will find two candidate slugs and ask which to use rather than picking
silently. That is the desired behavior: Thread B runs first by DD-006 in the sibling log.
