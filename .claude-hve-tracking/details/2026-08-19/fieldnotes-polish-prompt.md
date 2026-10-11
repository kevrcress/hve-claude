# Cross-Repo Prompt: Fieldnotes Visual Polish

Paste the block below into a Claude Code session started in `/Users/kevin/GitHub/Fieldnotes`.
It is self-contained: it does not assume the Fieldnotes session can see anything from the
hve-claude session that produced it.

Corresponds to Phase 4, Steps 4.1 and 4.2 of
`.claude-hve-tracking/plans/2026-08-19/project-communication-presence-plan.md`.

---

## The prompt

```
Fieldnotes needs a presentation-only polish pass so that one screenshot of the swimlane view
can go in the README of a different project (kevrcress/hve-claude) as evidence that HVE
workflow artifacts accumulate into a real, browsable trail across projects.

Context you need:

- Fieldnotes is a static dashboard: `node parse.js ~/github` writes manifest.json, then
  `open index.html` renders it. Node stdlib only, no build step, no dependencies.
- The current manifest covers six projects: Claire, Osprey, RuleGraph, Skynet, harrier,
  hve-claude. Regenerate it if it looks stale.
- My own prior assessment of this app was "functional artifact-dumping rather than good UI".
  That is the gap to close, and only far enough to survive a screenshot.

HARD CONSTRAINT, read this before touching anything:

This repo's README declares a frozen consumer contract on the `stable` branch. The Krava
Standup Electron app pins a clone of `stable` and renders `index.html` directly. Therefore:

- DO NOT change parse.js output, the manifest.json schema, CLI arguments, or the index.html
  entry point.
- DO NOT rename or move index.html, parse.js, or the icon files.
- Presentation only: spacing, density, typography, colour, alignment, labels, empty states,
  truncation behaviour.
- Read the README's consumer-contract section yourself and confirm your planned changes sit
  outside it before you edit. If a change you want to make would touch the contract, stop and
  tell me instead of doing it.

What I want:

1. Open the swimlane view against the current manifest and tell me what specifically reads as
   "artifact dumping" rather than a dashboard. Be concrete and cite what you see, not
   generalities. I want your assessment before you change anything.
2. Propose a short list of presentation fixes ranked by how much each improves a single
   screenshot of the swimlane view. Screenshot legibility is the only success criterion here,
   not general UI quality. Wait for me to pick.
3. Implement only what I pick.
4. Tell me the exact browser window size and which projects to have in frame for the best
   screenshot, then let me take it.

Scope discipline: this is a small pass in service of one image. If your assessment in step 1
concludes that a screenshot-worthy swimlane view needs more than a presentation pass, say so
plainly and stop. That is a real answer and I would rather hear it than have this quietly turn
into a redesign.
```

---

## Why the constraints are worded this way

- The frozen-contract paragraph is stated as a hard constraint with an explicit stop-and-ask
  branch, because the failure mode is an agent making a reasonable-looking change to `parse.js`
  or the manifest shape and silently breaking an external consumer that is not in the repo.
- Step 1 asks for assessment before changes, because plan Step 4.1 needs Kevin's judgment call
  on whether the app is screenshot-worthy at all, and an agent that starts editing has already
  answered that question by itself.
- The last paragraph exists because Fieldnotes polish is the highest scope-creep risk in the
  Thread A plan: it is work in a second repo, with an external consumer, in service of one
  image. The prompt makes "this needs more than polish" an acceptable outcome so the agent is
  not pushed into a redesign to satisfy the request.
