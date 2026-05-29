# hve-claude

The **HVE Core** workflow, adapted natively for [Claude Code](https://claude.ai/code).

HVE (Human-Value Engineering) is a convention-driven agentic development workflow that enforces a Research → Plan → Implement → Review discipline. By separating phases, each agent optimizes for its role rather than trying to do everything at once.

Adapted from [microsoft/hve-core](https://github.com/microsoft/hve-core) under the MIT License.

---

## What's included

- **10 slash commands** — `/hve` (full loop), `/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review`, `/hve-pr-review`, `/hve-memory`, `/hve-challenge`, `/hve-doc-ops`, `/hve-prompt-builder`
- **8 subagents** — specialized agents spawned in parallel by the phase commands (researcher, plan-validator, implementation-validator, rpi-validator, phase-implementor, prompt-tester, prompt-evaluator, prompt-updater)
- **Coding instructions** — language-specific conventions in `instructions/`
- **Reusable prompts** — task-specific prompts in `prompts/`

---

## Install

Run the installer, pointing it at the project you want the workflow in:

```bash
# From this repo root
./install.sh /your/project    # or run with no argument from inside the target
```

It copies `.claude/commands/`, `.claude/agents/`, `instructions/`, and `prompts/`,
merges the HVE block into the target's `CLAUDE.md`, and adds the tracking `.gitignore`
rules. It is idempotent — re-run it to pull updates.

Then open `CLAUDE.md` and add your project-specific context below the `## Your Project` heading.

### Tracking folder & version control

The durable HVE artifacts (`research/`, `plans/`, `details/`, `changes/`, `reviews/`,
`challenges/`, `memory/`, `doc-ops/`) **are committed by default** — they are the shared
history and rationale behind your work. Only the regenerable noise is gitignored:

```
.claude-hve-tracking/**/subagents/
.claude-hve-tracking/sandbox/
```

To keep the whole folder private instead, replace those rules with `.claude-hve-tracking/`.

---

## Usage

```
/hve add OAuth2 authentication to the API
```

This runs the full Research → Plan → Implement → Review loop with user checkpoints between phases.

Or run phases individually:

```
/hve-research investigate existing auth middleware
/hve-plan
/hve-implement
/hve-review
```

Each phase command discovers the previous phase's output automatically. No manual file attachment needed. To resume in a new conversation, just run the next phase command.

---

## Requirements

- [Claude Code](https://claude.ai/code) (desktop app, VS Code extension, or CLI)
- Claude Sonnet or Opus model recommended for implementation phases
- Haiku model used automatically for research and validation subagents (cost optimization)

---

## License

MIT — see [LICENSE](LICENSE)

Adapted from [microsoft/hve-core](https://github.com/microsoft/hve-core), also MIT.
