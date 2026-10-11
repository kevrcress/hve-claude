# Implementation Plan: Project Communication and Visual Presence (Thread A)
Date: 2026-08-19
Task slug: project-communication-presence
Research: .claude-hve-tracking/research/2026-08-19/project-communication-phase-close.md (Thread A)
Sibling plan: .claude-hve-tracking/plans/2026-08-19/phase-close-clarity-plan.md (Thread B, runs first)
Status: Validated (2026-08-19) - awaiting user approval

## Overview

Rebuild how the repo explains itself: replace the asserted RPI thesis with the three committed
evidence anchors that already exist on disk, add a natively-rendered mermaid RPI diagram, promote
the dogfood-artifact table above the command reference, set the eight repo topics, and add two
visual assets (a Fieldnotes swimlane screenshot after a polish pass, and an asciinema recording of
a real `/hve` run). Phase 0 merges the remediation branch first, because all three evidence
anchors live there and would 404 from main until it lands.

## Decisions locked before planning (user, 2026-08-19)

- D1: WHY case is rebuilt from the three existing committed artifacts, with short verbatim quotes
  and links. No new vanilla-vs-HVE measurement run.
- D2: Merge fix/full-repo-review-remediation to main first, then branch fresh for this work.
- D3: Visual scope is all four: mermaid diagram, promoted dogfood table, the eight repo topics,
  and an asciinema recording.
- D4: Fieldnotes gets a visual-polish pass before it is screenshotted.
- D5: Thread B runs first; this plan rebases onto its CLAUDE.md and README changes.

## Phases

### Phase 0: Merge the remediation branch and branch fresh
Dependencies: none (but Thread B should land first per D5)
Estimated scope: no file edits, git operations only
Success criteria: `git log main --oneline -1` shows the remediation work merged; the three
evidence-anchor paths resolve on main; a new working branch exists off main.

Steps:
- [ ] Step 0.1: Merge PR #3 (`fix: remediate full-repo review findings`, branch
  `fix/full-repo-review-remediation`, open as of 2026-08-19, 3 commits ahead of main, 0 behind,
  62 files changed). Verified by the parent during planning via `gh pr list --state open` and
  `git rev-list --count main..HEAD` [HIGH]
- [ ] Step 0.2: After merge, confirm all three evidence-anchor paths resolve on main:
  `reviews/rpi/2026-08-15/full-repo-review-remediation-review.md`,
  `changes/2026-08-15/full-repo-review-remediation-changes.md`,
  `plans/2026-08-15/full-repo-review-remediation-plan.md`. This is the guard that makes every
  README link in Phase 2 non-404. Do not skip it: research open question 3 exists precisely
  because these links are branch-local today.
- [ ] Step 0.3: Branch fresh off main for this work, per the fresh-branch practice recorded in
  auto-memory. Do not stack on the remediation branch.

### Phase 1: Mermaid RPI diagram
Dependencies: Phase 0
Estimated scope: 1 modified file (README.md), roughly 30 replaced lines
Success criteria: the diagram renders on github.com in the pushed branch view (checked visually,
not inferred); `docs/workflow.md:15-34` ASCII art either stays as the detail view or is replaced
consistently; the README no longer oversells a "full parallelism diagram" that resolves to ASCII.

Steps:
- [ ] Step 1.1: Replace the ASCII loop at README.md:76-93 with a ```mermaid fence. Start from the
  validated source in the details file rather than authoring fresh.
  - This exact diagram was compiled by the parent during planning:
    `npx -y @mermaid-js/mermaid-cli@11 -i rpi-loop4.mmd -o rpi-loop4.png -w 1100 -b white`
    exited 0 and produced a 103103-byte PNG, which the parent then viewed and judged legible.
    mermaid-cli reported version 11.16.0. The full validated source is recorded at
    `.claude-hve-tracking/details/2026-08-19/project-communication-presence-details.md` [HIGH]
  - Three earlier layout attempts were compiled and rejected on legibility, not syntax (count
    corrected 2026-08-19 during validation; the plan previously said two while the details file
    correctly listed three): a TD version with subgraphs that placed Review top-left and snaked
    the spine, an LR version that wrapped into two rows, and a TB version with `direction LR`
    inside each subgraph that stacked the researchers vertically anyway. All three are described
    in the details file so the implementor does not rediscover them [HIGH]
  - Verified mermaid behavior, recorded because it is the trap: `direction LR` inside a subgraph is
    overridden when that subgraph has external edges, so subgraph-based fan-out stacks vertically.
    Side-by-side fan-out requires the `A --> B & C & D` chaining form instead [HIGH, observed
    across the compiled attempts]
- [ ] Step 1.2: Push the branch and open the README on github.com to confirm GitHub's own mermaid
  renderer accepts it. This is a required guard step, not optional.
  - The parent validated against mermaid-cli 11.16.0, which is NOT GitHub's renderer. GitHub's
    supported mermaid version was not verified in this session. Both the `&` chaining operator and
    `classDef`/`class` are long-standing features, so the risk is low, but the claim
    "GitHub renders this diagram" is unverified until Step 1.2 runs [MEDIUM]
  - If GitHub rejects any construct, degrade in this order: drop `classDef`/`class` colouring
    first, then replace `&` chaining with explicit one-edge-per-line. Both degradations preserve
    the content.
- [ ] Step 1.3: Reconcile README.md:95, which currently points at a "full parallelism diagram"
  that resolves to ASCII art at docs/workflow.md:15-34 and oversells it (research A1). Either
  point it at the new mermaid diagram or reword the claim to match what docs/workflow.md actually
  shows.
- [ ] Step 1.4: Decide whether docs/workflow.md:15-34 keeps its ASCII art as the detailed view or
  is converted too. Recommendation: keep ASCII there, since it shows per-phase subagent detail the
  README diagram deliberately omits. Record the decision either way.

### Phase 2: Rebuild the WHY case on committed evidence
Dependencies: Phase 0
Estimated scope: 1 modified file (README.md), roughly 60 to 100 changed lines
Success criteria: every comparative claim in the Benefits region either cites a linked artifact or
is explicitly marked as a design bet; no unsupported measurement language ("lower cost",
"leaner context windows") survives without a citation or a hedge.

Steps:
- [ ] Step 2.1: Rewrite the `## Why this exists` section (README.md:11-22). The claim at
  README.md:22 ("higher-quality output, leaner context windows, lower cost") has no measurement
  behind it (research A1) and must either gain a citation or be restated as a design bet.
- [ ] Step 2.2: Replace or heavily cut the Benefits table (README.md:252-264), which is nine
  comparative rows with zero data. Rows that survive must link evidence.
- [ ] Step 2.3: Add the three evidence anchors as short quoted excerpts with links. Ranked by the
  research, strongest first:
  1. Independent test verification: the review re-ran both suites itself before accepting any
     validator finding (`reviews/rpi/2026-08-15/full-repo-review-remediation-review.md:20-31`),
     the one-screenshot proof of "verified, not trusted".
  2. Falsification discipline: a dated Correction retracting a fabricated `Completed:` timestamp,
     replaced with an actual `date -u` reading
     (`changes/2026-08-15/full-repo-review-remediation-changes.md:341-343`, cited independently by
     the review at :212-214).
  3. Writer/checker separation: raw validator output of 7 Critical and 1 Major adjudicated to 0
     and 0 with per-finding verification (`review.md:52-89`, `:163-193`).
  - Frame anchor 3 as "the workflow catches its own tools' mistakes", NOT "validators are always
    right". Validator severity mislabeling is a known weakness recorded in auto-memory, and the
    stronger framing would be false [HIGH on the framing constraint]
  - The counts in these citations were taken from the research doc, not re-read by the parent this
    session. Re-verify each quote against the file before publishing it, since a misquoted
    evidence anchor is worse than no anchor [MEDIUM]
- [ ] Step 2.4: Give context compaction real explanation. Today it is one clause at README.md:257
  and it is the strongest concrete selling point (research A1). Explain the failure mode and why
  disk artifacts specifically survive it. Closest existing text is docs/workflow.md:110-115, which
  frames it as convenience rather than failure avoidance.
- [ ] Step 2.5: Leave the Limitations section (README.md:268-273) intact. It is the honest
  counter-evidence and its presence is part of what makes the rest credible.

### Phase 3: Promote the dogfood table and set repo topics
Dependencies: Phase 2
Estimated scope: 1 modified file (README.md) plus one gh command
Success criteria: the artifact table appears before the command reference; `gh repo view` shows
eight topics and a still-null homepage.

Steps:
- [ ] Step 3.1: Move the `## See it in action` table (README.md:276-291) above `## Command
  reference` (README.md:116), so evidence lands before the reference material. The table's four
  links point at 2026-05-29 artifacts already on main, so they are not gated on Phase 0.
- [ ] Step 3.2: Consider adding the three Phase 2 evidence anchors as rows in the same table, so
  there is one evidence surface rather than two.
- [ ] Step 3.3: Set the eight topics:
  `gh repo edit kevrcress/hve-claude --add-topic claude-code,claude,anthropic,ai-agents,agentic-workflow,developer-tools,prompt-engineering,workflow`
  - The `--add-topic` flag was verified present by the parent during planning via
    `gh repo edit --help`; gh is version 2.94.0 and authenticated as kevrcress. Current topics are
    null and homepage is empty, confirmed via `gh repo view --json repositoryTopics,homepageUrl`
    [HIGH]
  - The exact eight-topic set is the research recommendation and is a judgment call, not a verified
    fact [MEDIUM]
- [ ] Step 3.4: Leave the homepage null, per research A4. Set it only if GitHub Pages is enabled
  later, which this plan does not do.

### Phase 4: Fieldnotes polish pass and screenshot
Dependencies: Phase 3
Estimated scope: changes in a different repo (/Users/kevin/GitHub/Fieldnotes) plus 1 image added here
Success criteria: one swimlane screenshot that Kevin judges representative, committed to this repo
and referenced from the README.

Steps:
- [ ] Step 4.1: Open Fieldnotes and assess the current swimlane view against Kevin's own
  characterization ("functional artifact-dumping rather than good UI",
  `memory/2026-08-08/hive-orchestrator-project-brief.md:64-66`).
  - Verified by the parent during planning: Fieldnotes exists and is current. It is a static
    dashboard (`index.html` 99619 bytes, `parse.js` 48049 bytes, Node stdlib only, no build step),
    it has two views (project list and swimlanes), custom icons, and a UI spec. Its
    `manifest.json` was regenerated 2026-08-19 at 11:58 covering six projects (Claire, Osprey,
    RuleGraph, Skynet, harrier, hve-claude). Research open question 1 is answered: it runs [HIGH]
  - Whether its rendering is screenshot-worthy remains Kevin's judgment call, not a verifiable
    fact. The polish pass is scoped by what he says is wrong on seeing it [LOW until Step 4.1 runs]
- [ ] Step 4.2: Scope the polish pass from Step 4.1. Keep it to presentation only (spacing,
  density, colour, labels). Do not change `parse.js` output or the consumer contract: Fieldnotes'
  README records a frozen interface on the `stable` branch consumed by the Krava Standup Electron
  app, so a careless change there breaks an external consumer.
- [ ] Step 4.3: Capture one cropped swimlane screenshot showing multiple projects and their
  pipeline stages. Commit it under a new `docs/images/` directory in THIS repo.
  - The repo is currently text-only: a glob for image extensions returns zero files (research A1).
    This step is the first binary asset, so it also sets the convention for where images live
    [HIGH on the current state]
- [ ] Step 4.4: Reference the screenshot from the README near the dogfood table, captioned as what
  it is: a companion local dashboard reading HVE artifacts, not part of HVE itself. Do not name
  HiVE (research A5): the brief records that repo as not yet created, with a provisional name
  carrying documented collision and trademark risk.

### Phase 5: asciinema recording
Dependencies: Phase 4
Estimated scope: 1 recording asset plus README reference
Success criteria: a recording of a real `/hve` run, embedded or linked, that plays from the README.

Steps:
- [ ] Step 5.1: Install asciinema.
  - Verified absent by the parent during planning: `which asciinema` returned not found [HIGH].
    This is a genuine prerequisite, not an assumption.
- [ ] Step 5.2: Record a real `/hve` run on a small genuine task. Do not stage a fake run: the
  entire Thread A thesis is evidence over assertion, and a staged recording would contradict it.
- [ ] Step 5.3: Decide the embedding mechanism. asciinema.org hosting gives a clickable SVG badge
  (the Aider precedent, research A4) but puts an external dependency in the README; a committed SVG
  is self-contained but larger. Record the choice.
- [ ] Step 5.4: Note the refresh cost in CONTRIBUTING.md or a comment: the recording goes stale
  whenever command output format changes, and Thread B is about to change exactly that. This is why
  Phase 5 is last.

### Phase 6: Verify
Dependencies: Phases 1 through 5
Estimated scope: test runs plus a link check
Success criteria: both suites pass at or above baseline; every README link resolves on main.

Steps:
- [ ] Step 6.1: Run `tests/run-drift-tests.sh` and `tests/run-install-tests.sh`. Baseline measured
  by the parent during planning on 2026-08-19: drift 255 passed 0 failed, install 69 passed 0
  failed. Several drift tests read README.md (test 16 asserts README names all six credential
  patterns), so README edits can break the suite.
- [ ] Step 6.2: Check every link added or moved in Phases 1 through 5 resolves on main after merge.
  The `.claude-hve-tracking/` links resolve only in the github.com file UI, which is acceptable but
  should be a conscious choice.
- [ ] Step 6.3: Re-check the three paste-to-install copies stay in sync if any install wording
  changed: README.md:31-46, docs/installation.md:13-28, and the copy embedded in
  `tests/run-prompt-new-install.sh` (research O-1, three-way verbatim duplication).

## Risk Log

| Risk | Likelihood | Mitigation |
|---|---|---|
| GitHub's mermaid renderer rejects a construct mermaid-cli accepted | Low | Step 1.2 is a mandatory visual check on github.com with a documented two-step degradation path |
| Evidence-anchor quotes are misquoted from the research doc rather than the source | Medium | Step 2.3 requires re-verifying each quote against the file before publishing |
| Evidence links 404 because the remediation branch never merges | Medium | Phase 0 blocks everything; Step 0.2 is an explicit path-resolution guard |
| Fieldnotes polish scope-creeps into a second project | High | Step 4.2 caps it to presentation only and names the frozen consumer contract that must not move |
| asciinema recording goes stale immediately | High | Phase 5 runs last, after Thread B has changed command output; Step 5.4 records the refresh cost |
| README edits break drift test 16 or the three-way install-prompt duplication | Medium | Steps 6.1 and 6.3 check both explicitly |
| Overclaiming returns via the new evidence framing | Medium | Step 2.3 fixes the framing for anchor 3 in advance; Step 2.5 keeps Limitations intact |

## Testing Approach

Both suites before and after each phase (baseline drift 255/0, install 69/0 as of 2026-08-19),
since README.md is read by drift test 16 and by the install-prompt duplication checks. The mermaid
diagram is verified twice: locally via mermaid-cli (already done during planning) and on github.com
via Step 1.2, because those are different renderers. Link resolution is checked post-merge at Step
6.2 rather than assumed. The recording and screenshot have no automated test and rest on Kevin's
visual judgment at Steps 4.3 and 5.2.
