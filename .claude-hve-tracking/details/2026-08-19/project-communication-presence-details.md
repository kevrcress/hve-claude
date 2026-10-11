# Implementation Details: Project Communication and Visual Presence (Thread A)
Date: 2026-08-19
Task slug: project-communication-presence
Plan: .claude-hve-tracking/plans/2026-08-19/project-communication-presence-plan.md

## Validated mermaid RPI diagram

This source compiled cleanly during planning. Command and result:

```
$ npx -y @mermaid-js/mermaid-cli@11 -i rpi-loop4.mmd -o rpi-loop4.png -w 1100 -b white
Generating single mermaid chart
$ ls -la rpi-loop4.png
-rw-r--r--@ 1 kevin  wheel  103103 Aug 19 12:05 rpi-loop4.png
```

mermaid-cli reported version 11.16.0. The rendered PNG was viewed by the parent and judged
legible: linear 1-2-3-4 spine, side-by-side subagent fan-out, artifacts as cylinders, rework as a
dashed back-edge.

Source to paste into README.md inside a ```mermaid fence:

```
flowchart TB
    T["/hve task"] --> D{"Difficulty?"}
    D -->|"Simple"| I
    D -->|"Medium and up"| R

    R["1 - Research"] --> R1["hve-researcher"] & R2["hve-researcher"] & R3["hve-researcher"]
    R1 & R2 & R3 --> RA[("research/topic.md")]

    RA --> P["2 - Plan"] --> P1["hve-plan-validator"] --> PA[("plans/task-plan.md")]

    PA --> I["3 - Implement"] --> I1["hve-phase-implementor"] & I2["hve-phase-implementor"]
    I1 & I2 --> IA[("changes/task-changes.md")]

    IA --> V["4 - Review"] --> V1["hve-rpi-validator"] & V2["hve-implementation-validator"]
    V1 & V2 --> VA[("reviews/rpi/task-review.md")]

    VA --> Q{"Verdict"}
    Q -->|"Complete"| DONE(["Done"])
    Q -.->|"Needs Rework"| I

    classDef phase fill:#fff4d6,stroke:#c9992e,color:#4a3a08
    classDef art fill:#eef7ff,stroke:#5b8db8,color:#1b3a52
    classDef term fill:#e8f6ec,stroke:#4a8f5f,color:#1e4029
    class R,P,I,V phase
    class RA,PA,IA,VA art
    class DONE term
```

### Layout attempts that were compiled and rejected

Recorded so the implementor does not rediscover them. All three compiled without syntax error;
they were rejected on legibility.

1. `flowchart TD` with four subgraphs and a `LW --> IA` cross edge. Result: Review rendered
   top-left, the spine snaked, extremely tall. The cross edge and the two back-edges forced the
   wrap.
2. `flowchart LR` with subgraphs and `direction TB` inside each. Result: correct left-to-right
   spine but the graph wrapped into two rows at 1600px wide, and Review still landed top-left.
3. `flowchart TB` with subgraphs and `direction LR` inside each. Result: correct spine and
   ordering, but the researchers stacked vertically instead of side by side.

### The trap, verified

`direction LR` inside a subgraph is overridden when that subgraph has edges crossing its boundary.
Attempt 3 above is the direct observation: the subgraph declared `direction LR` and rendered its
three children stacked vertically anyway, because the subgraph had both an inbound and an outbound
edge.

Side-by-side fan-out therefore requires the chaining form, not subgraphs:

```
R["1 - Research"] --> R1["a"] & R2["b"] & R3["c"]
R1 & R2 & R3 --> RA[("artifact")]
```

### Renderer caveat

mermaid-cli 11.16.0 is not GitHub's renderer. The `&` chaining operator and `classDef`/`class` are
long-standing mermaid features, so acceptance is likely, but it is unverified until the branch is
pushed and the README is opened on github.com (plan Step 1.2).

Degradation order if GitHub rejects something:

1. Drop `classDef` and `class` lines. Costs colour, keeps structure.
2. Replace `&` chaining with one edge per line. Costs the side-by-side layout, keeps content.

## Evidence anchors: exact citations

All three are on branch `fix/full-repo-review-remediation` (PR #3, open as of 2026-08-19) and
resolve on main only after plan Phase 0 merges it.

| Rank | Claim it supports | Path and lines |
|---|---|---|
| 1 | Review re-runs the test suites itself before trusting a finding | `reviews/rpi/2026-08-15/full-repo-review-remediation-review.md:20-31` |
| 2 | A fabricated timestamp was retracted in writing with a dated Correction | `changes/2026-08-15/full-repo-review-remediation-changes.md:341-343`, cited by `review.md:212-214` |
| 3 | 7 raw Critical and 1 Major adjudicated to 0 and 0 with per-finding verification | `review.md:52-89` and `review.md:163-193` |

Strong alternates if one of the above does not quote well:

- Test 14 caught the session's own edit defect on first run: `changes.md:332`.
- An 11-phase plan with explicit per-phase Dependencies lines and sequencing rationale:
  `plans/2026-08-15/full-repo-review-remediation-plan.md:71-260`, `:315`.

Framing constraint for anchor 3: present it as "the workflow catches its own tools' mistakes",
never "validators are always right". Validator severity mislabeling is a known, recorded weakness.

## Repo metadata, current state

Verified during planning via `gh repo view kevrcress/hve-claude --json repositoryTopics,homepageUrl,description`:

```
description : set (Hypervelocity Engineering for Claude Code: ...)
homepageUrl : "" (empty)
repositoryTopics : null
```

`gh` is version 2.94.0, authenticated as kevrcress, and `gh repo edit --help` confirms both
`--add-topic` and `--remove-topic` accept comma-separated strings.

Command to run at plan Step 3.3:

```
gh repo edit kevrcress/hve-claude --add-topic claude-code,claude,anthropic,ai-agents,agentic-workflow,developer-tools,prompt-engineering,workflow
```

Optional low-priority additions, not in the eight: `slash-commands`, `code-review`.

## Fieldnotes: verified state

Verified during planning at `/Users/kevin/GitHub/Fieldnotes`:

- Static dashboard. `index.html` 99619 bytes, `parse.js` 48049 bytes, Node stdlib only, no build
  step, no dependencies.
- Two views: project list and swimlanes.
- Custom icons (`icon-black.svg`, `icon-white.svg`) and a UI spec (`fieldnotes-ui-spec.html`).
- `manifest.json` regenerated 2026-08-19 at 11:58, covering six projects: Claire, Osprey,
  RuleGraph, Skynet, harrier, hve-claude.
- Usage: `node parse.js ~/github` then `open index.html`.

Constraint that caps the polish pass: Fieldnotes' README declares a frozen consumer contract on
the `stable` branch, embedded by the Krava Standup Electron app, which points at a pinned clone
and renders `index.html` directly. Presentation changes are safe; CLI output, manifest schema, and
the `index.html` entry point are not.

## Do not name HiVE publicly

Research A5. The brief records the HiVE repo as not yet created, with no public presence, and a
provisional name carrying documented collision and trademark risk plus explicit "ready to rename"
guidance. Honest substitutes if a forward-looking line is wanted:

1. Nameless: "a companion desktop app is in design".
2. Fully factual and stronger: HVE phase commands run headlessly via `claude -p` with
   slash-command expansion confirmed by direct test
   (`memory/2026-08-08/hive-orchestrator-project-brief.md:230-242`).

## Duplication surfaces to respect

From research A2. Any install-wording change must touch all three copies:

- `README.md:31-46`
- `docs/installation.md:13-28`
- the copy embedded in `tests/run-prompt-new-install.sh` (per `CONTRIBUTING.md:72-74`)

The credential-pattern block appears three times inside `docs/installation.md` alone (`:89-95`,
`:156-159`, `:186-197`); drift test 16 enforces agreement across README, docs/installation.md,
install.sh and run-install-tests.sh.
