# Session Memory: Hive orchestrator/IDE — project brief for a new repo

Date: 2026-08-08
Session type: planning (pre-research interview, conducted in chat)
Task slug: hive-orchestrator-project-brief

## Purpose of this file

This is a self-contained task brief, not a decision log to be read alongside chat history.
It should be usable on its own as the `<task>` argument to `/hve-research` in a **new**,
separate repo once that repo exists — a fresh session with no memory of this conversation
should be able to pick it up and run.

## Working name

**HiVE** — finalized 2026-08-08. Plays on the HVE acronym directly: drop the lowercase "i" and
H_VE is right there in the word, while it still reads phonetically as "Hive" — evokes many agents
working parallel cells of a task. Naming convention: **HiVE** is the display/brand name
(README, UI, wordmark); technical identifiers (repo slug, npm package, bundle ID) should be
plain lowercase/kebab-case (e.g. `hive`) per normal convention, decided when the repo is actually
created. Alternates considered and rejected: Conductor (collides with Netflix's own workflow
orchestrator, same domain), Relay/Loom (both heavily claimed — Meta's GraphQL client and the
video tool, respectively), Waypoint/Atrium/Skein (fresher, less collision, but didn't have the
HVE wordplay).

**Domain note**: "Hive"/"Hyve" as a naming root is heavily saturated in exactly this product
category — HiveFlow (hiveflow.ai) is a live "AI Agents Workflow Orchestration Platform," Hyve
Labs is "a studio for autonomous workflows," Hivecell, HiveForge, Hive AI (thehive.ai, a funded
content-moderation company) all collide to varying degrees. Checked 2026-08-08; no domain was
purchased. This is fine for now — the project has no public presence yet, so it's not costing
anything to defer. **Before any public launch**, do a real registrar WHOIS check (not just a web
search) and a quick trademark sanity check against Hive AI specifically, and be ready to rename
if needed. `hivegraph` and `gethive` looked least-collided of what was checked, if a domain
becomes worth revisiting.

## Problem statement

Today, using the HVE RPI methodology (research → plan → implement → review) means starting a
new Claude Code chat per phase and running slash commands by hand. Durable artifacts are
correctly kept on disk (`.claude-hve-tracking/`), which is good, but the *state of what's in
flight* — which tasks exist, what phase each is at, which branch/worktree it's parked on — is
not tracked anywhere. It's implicit in branch names and file locations. The result: work gets
80% done, the user switches tasks or gets distracted, and reconstructing "what's outstanding"
later requires manual branch-by-branch archaeology (this happened in the conversation that
produced this brief — see hve-claude's own git history from 2026-08-08 for a live example of
exactly the problem this project exists to solve).

## Goals

- A desktop app that lets the user manage HVE RPI tasks across multiple projects/repos without
  losing track of state across branches, chats, or time.
- Support both a fully autonomous "kick it off and walk away" mode and a human-checkpointed mode,
  as a per-task setting — not two different products.
- Preserve HVE's existing quality guarantees (writer/checker separation: validators and
  reviewers stay independent agents) even when the human isn't watching between phases.
- Reuse the RPI prompt engineering that already exists in hve-claude's `.claude/commands/` and
  `.claude/agents/` rather than reimplementing research/plan/implement/review logic natively.

## Non-goals for v1

- Working Codex CLI or Copilot CLI backends (see Backend scope below — architecture only, not
  implementation).
- A mobile client (see UI below — architecture should not block it, but it's not being built).
- Matching or extending the user's earlier "fieldnotes" app's feature set — some of its
  artifact-rendering logic may be reusable, but its UI was minimal/functional, not the target;
  see UI below for the actual visual bar.

## Requirements locked in this conversation

### Repo & scope
New standalone repo, separate from `hve-claude`. `hve-claude` remains the prompt-engineering
framework repo; this new project is a consumer of it (and, eventually, of sibling frameworks
`hve-codex` and `hve-copilot`, which the user has mentioned but says are "not as built out" —
treat their existence as directional context, not something to integrate against yet).

### Backend scope (v1: Claude Code only, adapter-ready)
Build the phase driver behind an abstraction (e.g. an `AgentBackend` interface: run a phase,
report status, locate artifacts) with the Claude Code CLI as the only concrete implementation
in v1. Do not hardcode Claude-specific assumptions into the task index or UI where avoidable.
Full Codex/Copilot backend support is explicitly deferred — research should not attempt to
design their artifact formats now, since those tools' HVE ports aren't built out enough to
know what to adapt to. A cross-tool artifact standard is a stated future direction; note it as
a constraint on naming/shape decisions (don't paint into a Claude-only corner) but don't design
it in full now.

### Task index / state model
A shared, cross-project index that lives **outside any git repo/branch** (so it survives branch
switches and doesn't require a commit to update), separate from the durable artifacts that
correctly stay git-tracked inside each project's `.claude-hve-tracking/`. The index is a
*pointer*, not a duplicate of content.

Sketch (not finalized — research/plan should validate feasibility and pick the real shape):
- One markdown file per task, YAML frontmatter + body, mirroring the existing per-file
  memory convention already used both by HVE's own `.claude-hve-tracking/memory/` and by
  Claude Code's own assistant-memory system.
- Draft location: `~/.claude/hive-tasks/<project-slug>/<task-slug>.md`. Fields at minimum:
  task slug, project path, current phase, status (pending/running/awaiting-approval/blocked/
  done), branch or worktree path, autonomy mode, and links to the actual artifact paths inside
  the project repo (not their content).
- **Required for v1**: when a project is added to the app, it must scan that project's
  `.claude-hve-tracking/` tree (including content sitting on unmerged/uncommitted branches it
  can discover) and backfill task-index entries for anything found without one yet. This is the
  feature that directly targets the problem statement above — not a stretch goal.

### Concurrency
True parallel multi-task execution **within a single project**, via isolated git worktrees per
task (create/cleanup/conflict handling as part of task lifecycle). Not just cross-project
parallelism — the user explicitly wants multiple tasks advancing simultaneously in the same repo.

### Task creation UX
Two-stage: an **optional** structured form (goal, constraints, acceptance criteria, non-goals —
fields the user may skip) that seeds a **chat-style interview**. The interview conversationally
resolves whatever the form left unanswered or ambiguous, and locks a spec before any phase
starts — modeled on how this brief itself was produced. This maps directly onto a deferred spec
already sitting on `hve-claude`'s `feature/hve-interview-command` branch (commit `aa0689d`,
2026-07-21): a pre-research interview phase that separates user-only unknowns (scope,
constraints, acceptance criteria, non-goals) from codebase unknowns, which research owns. Read
that branch's memory doc (`.claude-hve-tracking/memory/2026-07-21/hve-interview-command.md` in
hve-claude) as a design input during research.

### Autonomy
Each task carries an autonomy setting, not a global app mode:
- **Autonomous**: research → plan → (existing) plan validation → implement → review run
  straight through with no human gate between them. It stops and surfaces to the user only when
  an existing HVE stop condition fires — a validator returns Fail, a review finds a Critical
  finding, or a subagent raises a genuinely blocking clarifying question (all three are already
  defined categories in HVE's subagent response protocol; reuse them rather than inventing new
  stop conditions).
- **Checkpointed**: today's per-phase pause/approve behavior.
- In both modes, per-phase artifacts stay visible/inspectable in the UI as they're produced.
- The writer/checker separation (independent validator and reviewer subagents) must not be
  weakened by autonomous mode — autonomy removes the human from the loop, not the checker.

### Driving mechanism & context isolation across phases (hard requirement)
The orchestrator should invoke the existing `.claude/commands/hve-*.md` slash commands via
headless/non-interactive Claude Code CLI runs (or the Claude Agent SDK's `query()`) per phase,
rather than reimplementing RPI logic inside the orchestrator itself — so the prompt files already
built in hve-claude stay the single source of truth.

**Each RPI phase must run in a genuinely fresh context.** The mechanism the user enforces by hand
today is literally starting a new chat per phase, and that guarantee must survive automation as a
structural property, not degrade into "soft" isolation that depends on prompt discipline inside
one long-lived orchestrator session. The only channel between phases is disk —
`.claude-hve-tracking/` artifacts in, artifacts out. No phase may receive a prior phase's
conversation/reasoning as context, only what's written to disk.

Concretely: each phase is driven as its own new Claude Code *session* (SDK `query()` with no
`resume`, or a fresh `claude -p` process), bound to the project's working directory or worktree —
not dispatched as an Agent-tool subagent from within one persistent orchestrator conversation.
The subagent-dispatch route can be made to work if the parent only ever forwards a task
slug/project path and nothing else into each call, but that makes isolation a property of the
orchestrator's prompt hygiene rather than the session boundary itself — one careless prompt
breaks it silently, with nothing to signal that it happened. Prefer the structural (new-session)
version. This is also the same primitive the concurrency requirement above already needs
(isolated, cwd-bound sessions per parallel worktree task) — not a separate thing to design, the
same mechanism applied at the phase level too.

**Needs verification in research**: confirm whether custom slash commands expand correctly when
passed as the initial prompt to a headless (`-p`) or SDK-driven session with no prior interactive
expansion step, and what output-capture/exit-status contract is available. If slash-command
expansion doesn't work outside an interactive session, the fallback is for the orchestrator to
read the command file itself, perform its `$ARGUMENTS`-style substitution, and pass the expanded
text as the session's first message — treating the command file as a template rather than
depending on live slash-command parsing. Also confirm phase commands' disk-based artifact
discovery (per hve-claude's CLAUDE.md) resolves correctly when invoked this way rather than
interactively.

### UI
Electron desktop app. Visual bar: closer to VS Code / Claude Code's own aesthetic — clean,
minimal, task-focused — explicitly *not* the user's earlier "fieldnotes" app, which the user
describes as functional artifact-dumping rather than good UI (though its artifact-rendering
logic may be worth reusing). Minimum views: project list, per-project task list with phase/
status, per-phase artifact viewer, approval/gate controls for checkpointed tasks, live status
for autonomous tasks.

Two forward-looking constraints, both cheap to satisfy now and expensive to retrofit. **Provenance
note**: the goals below are Kevin's, explicitly stated; the specific mechanisms are Claude's
proposed way to satisfy them, not something Kevin reviewed or picked between — plan should
validate the mechanism, not just inherit it as a locked requirement.
1. **Mobile-readiness** (goal: Kevin wants a mobile port eventually, confirmed; mechanism:
   Claude's proposal, unreviewed): keep core orchestration logic (task index, phase driver,
   artifact API) behind a local service boundary (HTTP/IPC) separate from the Electron shell, so
   a future mobile client can be a thin client against the same API instead of a rewrite. Mobile
   itself is explicitly not in v1.
2. **Restyling-readiness** (goal: Kevin plans to screenshot the finished v1 UI, run it through a
   design tool for a visual polish pass, and reapply the result — confirmed; mechanism: Claude's
   proposal, unreviewed): keep styling centralized (theme/tokens) rather than deeply inline, so
   that pass is a targeted swap, not a rewrite.

## Model tiering for running this brief

Verified 2026-08-08 against this repo's actual agent frontmatter (not assumed): `hve-researcher`
and `hve-phase-implementor` are pinned `model: inherit` (follow whatever model the session
running the phase command was started with); `hve-plan-validator` and `hve-rpi-validator` are
pinned `model: haiku`; `hve-implementation-validator` is pinned `model: sonnet`. The fixed pins
apply regardless of session model — validators are already cheap/appropriately-tiered by design.

**Gotcha**: because `hve-phase-implementor` inherits, staying on a high-reasoning session model
(Opus/Fable) straight through `/hve-implement` makes implementation run at that expensive tier
too, not Sonnet — it does not downgrade on its own.

Since each phase already runs as its own fresh session (see Driving mechanism above), per-phase
model tiering falls out of that for free — just set the session model per phase invocation, using
the CLI's confirmed `--model <model>` flag:
```bash
claude -p "/hve-research <task>" --model opus   # or fable — high-reasoning tier
claude -p "/hve-plan" --model opus              # or fable
claude -p "/hve-implement" --model sonnet       # pulls hve-phase-implementor down with it
claude -p "/hve-review" --model sonnet
```
Alternative if a single session must span multiple phases: use each command's own
`--subagent-model <sonnet|opus|haiku>` flag (e.g. `/hve-implement --subagent-model sonnet`) to
override subagent dispatch for that one command without changing the session's own model.

## Open items not yet resolved

- [ ] Final project name (currently "Hive," working title only)
- [ ] Exact task-index file location and schema (sketch above; needs research/plan validation)
- [ ] Whether artifact interaction in checkpointed mode is approve/reject only, or also inline
      edit-before-advance (not asked yet; default to approve/reject + comment unless research
      surfaces a strong reason otherwise)
- [ ] Whether slash commands expand correctly under headless/SDK-driven sessions with no prior
      interactive step (see Driving mechanism & context isolation above); this decides whether
      the driver can hand `/hve-<phase> ...` straight to a new session or must template-expand
      the command file itself

## Next step

In a new chat, in the new (not-yet-created) repo:
0. **Pre-phase spike — DONE (2026-08-08), confirmed**: tested whether a custom slash command
   expands correctly under headless invocation with no prior interactive step. Created a throwaway
   `.claude/commands/spike-test.md` in a scratch dir whose body wrote `$ARGUMENTS` to `result.txt`,
   then ran `claude -p "/spike-test SPIKE_OK_12345" --dangerously-skip-permissions` from that dir.
   Result: `result.txt` contained exactly `SPIKE_OK_12345` — the command was correctly discovered
   from `.claude/commands/`, expanded, and `$ARGUMENTS` was substituted, all with zero prior
   interactive session. **[HIGH — directly observed, not inferred]**. The orchestrator can hand
   `/hve-<phase> ...` directly to a headless/SDK session; the template-expansion fallback described
   above is not needed.
   One new fact this surfaced: the run required `--dangerously-skip-permissions` to write the file
   without hanging on an interactive permission prompt. The orchestrator needs a deliberate, scoped
   permission story for unattended phases (not necessarily "skip everything") — flag this for
   research/plan rather than defaulting to blanket skip-permissions without considering it.
1. Scaffold the repo and install HVE (`./install.sh` from hve-claude, pointed at the new repo,
   or `--global` if not already global). **If relying on an existing global install** (skips
   the `.gitignore` step by design), manually add these two lines to the new repo's `.gitignore`
   before committing anything, or `.claude-hve-tracking/**/subagents/` and `sandbox/` output
   will get committed as noise:
   ```
   .claude-hve-tracking/**/subagents/
   .claude-hve-tracking/sandbox/
   ```
2. Run `/hve-research` with this file's content (or a pointer to it) as the task description,
   including the Step 0 spike result as a cited finding.

## Context Notes

This brief was produced via a manual interview in chat (the user explicitly asked for
additional clarifying questions before research, and this file's "Requirements locked" section
is the result). The user was explicit: **do not start research, planning, or any autonomous
build in this conversation** — this file is the handoff artifact for a separate chat to act on.
