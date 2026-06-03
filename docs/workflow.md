# Workflow in depth

This document walks through what each phase actually does, how subagents run in
parallel, what to do with the follow-on items a review surfaces, and a full FAQ.
For a high-level overview, see [How it works](../README.md#how-it-works) in the
README.

> **Note:** "Add OAuth2 authentication to the API" is used as an example task
> throughout, substitute your own.

## Subagent parallelism

Within each phase, subagents run in parallel where possible:

```
Phase 1 - Research
  ├── hve-researcher (auth middleware)  ─┐
  ├── hve-researcher (OAuth2 libraries)  ├── parallel
  └── hve-researcher (session handling) ─┘

Phase 2 - Plan
  └── hve-plan-validator                    (after plan is drafted)

Phase 3 - Implement
  ├── hve-phase-implementor (phase 1) ─┐
  ├── hve-phase-implementor (phase 3)  ├── parallel (where independent)
  └── hve-phase-implementor (phase 5) ─┘

Phase 4 - Review
  ├── hve-rpi-validator (phase 1) ─┐
  ├── hve-rpi-validator (phase 2)  ├── parallel
  ├── hve-rpi-validator (phase 3)  │
  └── hve-implementation-validator ─┘
```

## Phase-by-phase walkthrough

Here's what happens when you run `/hve add OAuth2 to the API`:

**Phase 1: Research**

Three researcher subagents run in parallel:
- One maps the existing auth middleware
- One surveys the OAuth2 library landscape for this stack
- One checks for existing session handling and token storage

Each subagent writes its findings to
`.claude-hve-tracking/research/subagents/2026-05-29/`. The orchestrator
consolidates them into
`.claude-hve-tracking/research/2026-05-29/add-oauth2-api.md`. You see a summary and
are asked: *"Research complete. Shall I proceed to planning?"*

**Phase 2: Plan**

A plan is created with phases like:
1. Add OAuth2 dependencies
2. Implement the authorization code flow
3. Wire up the callback route
4. Add session persistence
5. Update existing tests

A `hve-plan-validator` subagent checks the plan against the research for gaps or
contradictions. You see the phase list and are asked: *"Does this plan look right?
Proceed to implementation?"*

**Phase 3: Implement**

Independent phases run in parallel (phases 1 and 5 can run simultaneously). Each
`hve-phase-implementor` subagent reads `.claude/instructions/` for the relevant
language before writing any code, then updates the changes log. You see a summary
of files changed and are asked: *"Implementation complete. Shall I run the
review?"*

**Phase 4: Review**

Two things run in parallel:
- `hve-rpi-validator` subagents verify each plan phase was actually implemented
  correctly
- `hve-implementation-validator` runs a 10-dimension quality check including
  automated security hygiene

You get a final report with a severity-graded finding list and overall status.

## After an RPI loop: what to do with follow-on items

Every review surfaces a short list of follow-on items: adjacent work, technical
debt, test gaps, documentation holes. Don't ignore them, but don't feel obligated
to act on all of them immediately either.

**Your options:**

- **Act now**: if the item is small and clearly related to the task you just
  finished, run `/hve <follow-on task>` while the context is fresh.
- **Save for later**: run `/hve-memory` before ending the session. It writes a
  structured memory entry to `.claude-hve-tracking/memory/` that any future
  conversation can load. Use this for items you intend to do soon but not right
  now.
- **Open a GitHub issue**: for non-trivial items that need team visibility,
  backlog tracking, or a future milestone.

**Warning: don't leave follow-on items only in the chat transcript.** Chat sessions
are ephemeral. Transcripts are not searchable, not shared, and vanish when you
close the window. An item that only exists in chat history is an item that will be
forgotten. Write it down somewhere durable.

## FAQ

**`/hve` vs standalone phase commands, which should I use?**

`/hve` runs all four phases in one conversation, which is convenient for most
tasks. The tradeoff is that context accumulates across phases: by the time you
reach Review, the conversation window includes Research, Plan, and Implement
output. For large or multi-day tasks, run each phase command in a fresh
conversation instead:

```
# New conversation per phase keeps context lean
/hve-research add OAuth2 to the API
# [start new conversation]
/hve-plan
# [start new conversation]
/hve-implement
# [start new conversation]
/hve-review
```

Each command auto-discovers the previous phase's artifact from
`.claude-hve-tracking/`, nothing is lost between sessions.

**How do I resume a task in a new conversation?**

Just run the next phase command. It finds the most recent artifact for its phase
automatically, no file paths, no manual attachment. If you're between phases, the
handoff block at the end of each phase command tells you exactly which command to
run next.

**Can I use HVE for small tasks?**

Yes. HVE classifies difficulty before starting. Simple tasks (< 50 lines, single
file, zero ambiguity) skip subagents entirely and implement directly, no
overhead. You can also just ask: `/hve fix the typo in the error message` and it
will handle it appropriately without spinning up a research team.

**Can I use HVE for non-code tasks?**

Yes, HVE is a research and structured output framework, not a coding tool. It
works for any task where you want to investigate before acting, plan before
writing, and validate the result. Examples:

- **Writing and research**: drafting guides, blog posts, reports, documentation
- **Architecture decisions**: researching trade-offs, drafting an ADR, reviewing
  it against requirements
- **Requirements analysis**: researching stakeholder needs, drafting a PRD or BRD,
  validating coverage
- **Configuration and audits**: researching current state, planning changes,
  reviewing for correctness
- **Content strategy**: researching a topic, outlining, drafting, reviewing for
  clarity

**Example 1: writing a beginner's vegetable garden guide (non-technical):**

```
/hve Research and write a guide to starting a home vegetable garden, cover soil prep, what to plant by season, watering, and common beginner mistakes.
```

- **Research:** Two subagents run in parallel: one researches soil preparation and
  planting schedules by season, one surveys common beginner mistakes and watering
  best practices. Sources are drawn from the model's training knowledge; you can
  also specify URLs to fetch (e.g. `reference almanac.com for planting schedules`)
  and the researcher will pull from those directly.
- **Plan:** A structured outline is proposed: intro, soil prep, seasonal planting
  guide, watering, common mistakes, quick-start checklist. You review and approve:
  *"Does this plan look right? Proceed to writing?"*
- **Implement:** Each section is written against the outline, grounded in the
  research findings.
- **Review:** Checked for accuracy against the research, completeness against the
  outline, and clarity for a beginner audience.

**Example 2: writing a technical blog post (tech-adjacent, no code):**

```
/hve Research and write a blog post explaining how React Server Components work and when to use them, aimed at developers who know React but haven't used RSCs yet.
```

This uses the same four phases, but research looks different: subagents fetch the
official React docs, scan the codebase for any existing RSC usage to ground
examples in reality, and survey common misconceptions. The plan produces a
narrative outline rather than implementation phases. Review checks technical
accuracy against the docs, not code correctness.

The difficulty classification still applies: a one-paragraph edit is Simple and
skips subagents; a full multi-section guide warrants parallel researchers and a
review pass.

**Does HVE only work with the languages listed in the instruction files?**

No, HVE works with any language or tech stack. The `.claude/instructions/` files
are optional style guides that give the implementor subagent pre-loaded
conventions (naming, formatting, test patterns) for specific languages. If your
language isn't listed, HVE will still research, plan, implement, and review; it
just won't have a dedicated convention file to reference. You can add your own by
creating a file in `.claude/instructions/` and referencing it in `CLAUDE.md`.

**What if I want to skip a phase?**

Run the standalone phase commands directly. If you already know what needs to be
done, skip research and go straight to `/hve-plan` with your own brief. If you've
already written the plan, run `/hve-implement`. Each command reads from whatever
artifact exists on disk.

**How do I update HVE in my project?**

Use the [update prompt](installation.md#updating-an-existing-install), follow the
Option B manual steps again, or re-run `install.sh` (bash users), all three paths
are idempotent. They overwrite the command and agent files but preserve your
`## Your Project` section in `CLAUDE.md`.

**How do I extend or customize HVE?**

Add your own language instruction files to `.claude/instructions/` and reference
them in `CLAUDE.md`. Add prompts to `prompts/`. Modify agent definitions in
`.claude/agents/`, or use `/hve-prompt-builder` to iteratively develop new ones
with an automated test-evaluate-update loop.
