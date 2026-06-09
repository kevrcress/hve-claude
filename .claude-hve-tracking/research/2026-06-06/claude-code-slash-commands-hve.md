# Research: Claude Code Slash Commands and Features for HVE Integration
Date: 2026-06-06
Task slug: claude-code-slash-commands-hve
Confidence: HIGH overall

## Summary

Claude Code provides several built-in slash commands and configuration features that HVE does not yet leverage. The highest-value gaps are: `/think` (extended thinking) for reasoning-heavy phases, `--effort` level exposure to users, and `--compact`-style dimension batching in `hve-pr-review`. Additionally, HVE's own command corpus has structural redundancies and a tool-restriction bug in `hve-challenge` that should be addressed alongside any new integrations.

---

## Key Findings

### Built-In Slash Commands

- **`/think`** — Enables extended thinking (chain-of-thought reasoning). Currently not used in any HVE command or agent. Best candidates: `hve-plan` Phase 2 (risk assessment, step synthesis), `hve` Phase 0 (difficulty assessment), `hve-review` Phase 4 (severity tally and verdict). [MEDIUM]
- **`/compact`** — Summarizes conversation context to reclaim window space. Not directly scriptable but relevant for long multi-phase `hve` orchestrator runs. [MEDIUM]
- **`/fast`** — Low-latency fast mode. Documented but no mechanism to encode in command frontmatter; user-toggle only. Not actionable for HVE commands directly. [LOW]
- **`/batch`** — Bundled skill that splits one large change into 5–30 worktree-isolated subagents, each opening a PR. Could complement HVE for mass refactoring tasks outside the RPI loop. Not integrated yet. [MEDIUM]
- **`/workflows`** — Lists and manages dynamic workflow runs. Dynamic workflows (experimental) could parallelize 10+ independent research topics without inline subagent dispatch. Currently unused in HVE. [LOW]

### Configuration Features Not Exposed in HVE

- **`--effort` flag / `effortLevel` setting** — CLI flag and settings key (`effortLevel: low|medium|high|xhigh`) control reasoning depth and cost. Not mentioned in CLAUDE.md or any HVE command. High-value surface for Challenging-difficulty tasks. [MEDIUM]
- **`alwaysThinkingEnabled`** — Settings key to enable extended thinking globally or per-agent config. No HVE agent uses this. [MEDIUM]
- **`model:` frontmatter in agents** — `hve-researcher` correctly uses `model: haiku`, `hve-phase-implementor` uses `model: inherit`. This is well-designed. No commands expose a model override flag. [HIGH - already good]

### Frontmatter Capabilities Summary

Commands (`.claude/commands/*.md`) support: `description`, `argument-hint`, `allowed-tools`.
Agents (`.claude/agents/*.md`) support: `name`, `description`, `model`, `color`, `tools`.
No `subagent_type` frontmatter exists; agent type is selected via `Agent tool` calls in the prompt body.

### HVE Internal Gaps Identified

- **`hve-challenge` Write capability missing** — Command declares `allowed-tools: Read, Glob, Grep` only, but must create a `.claude-hve-tracking/challenges/*.md` artifact. Write is required; current declaration is a bug. [MEDIUM - needs fix]
- **Artifact discovery boilerplate repeated** — `hve-plan`, `hve-implement`, `hve-review` each contain independent glob patterns to locate the prior phase's artifact. No shared utility. [MEDIUM]
- **Response format boilerplate repeated 8+ times** — All subagent agents repeat identical 50-line format block (status, 7 findings, 5 checklist, 3 questions, full-detail pointer). Extracting to a shared reference block would reduce prompt file size. [MINOR]
- **`hve-pr-review` spawns 8 parallel subagents without batching** — For large PRs (100+ files) this could stress context. A `--compact` flag that groups related dimensions (security+reliability, architecture+design, etc.) from 8 down to 4 subagents would help. [MEDIUM]
- **`hve-prompt-builder` tester + evaluator run sequentially** — Both read the draft independently; running them in parallel would save one subagent call per iteration. [MINOR]
- **Bash in `hve-research` allowed-tools rarely used** — Grep and Glob cover file operations; Bash adds token overhead without clear research value. [MINOR]

---

## Codebase References

.claude/commands/hve.md
.claude/commands/hve-research.md
.claude/commands/hve-plan.md
.claude/commands/hve-implement.md
.claude/commands/hve-review.md
.claude/commands/hve-challenge.md
.claude/commands/hve-pr-review.md
.claude/commands/hve-prompt-builder.md
.claude/agents/hve-researcher.md
.claude/agents/hve-phase-implementor.md
.claude/agents/hve-implementation-validator.md
.claude/agents/hve-rpi-validator.md
.claude/agents/hve-plan-validator.md
.claude/agents/hve-prompt-evaluator.md

---

## External References

- https://code.claude.com/docs/en/slash-commands
- https://code.claude.com/docs/en/agents
- https://code.claude.com/docs/en/settings

---

## Prioritized Recommendations

### High value — do these
1. **Add `--think` flag to `hve-plan` and `hve` orchestrator** — Gate extended thinking behind a flag so it's opt-in for Challenging tasks. Most impactful phase: `hve-plan` Phase 2 and `hve-review` Phase 4 verdict.
2. **Document `--effort` in CLAUDE.md difficulty-adaptive section** — Instruct users to set `effortLevel: xhigh` (or pass `--effort xhigh`) for Challenging-classification tasks. Zero code change; pure documentation.
3. **Fix `hve-challenge` Write permission** — Add `Write` to `allowed-tools` so the command can create its challenge artifact.

### Medium value — worth doing
4. **Add `--compact` option to `hve-pr-review`** — Group related review dimensions (8 subagents → 4) for large PRs.
5. **Parallelize tester + evaluator in `hve-prompt-builder`** — Both steps read the same draft; no dependency between them.
6. **Remove Bash from `hve-research` allowed-tools** — Tighten tool restriction to Read, Write, Glob, Grep, Agent.

### Lower value — exploratory
7. **Extract shared subagent response format block** — Single shared instruction block reduces duplication across 8+ agent files.
8. **Document `/batch` in CLAUDE.md** — Note it as a complement to HVE for mass PR-splitting workflows outside the RPI loop.
9. **Pilot `alwaysThinkingEnabled` for hve-plan-validator** — Judgment-call-heavy; thinking may improve discrepancy detection quality.

---

## Open Questions

1. Should `--think` be a per-command flag or a session-level setting in `.claude/settings.json` (`alwaysThinkingEnabled`)? Per-command is more controlled; session setting risks cost blowup on simple tasks.
2. Does `hve-challenge` currently delegate artifact writes to an undocumented subagent, or is the Write omission simply a bug?
3. Is `/batch` mature enough to document as a peer workflow to HVE's RPI loop, or is it still experimental enough to leave out of CLAUDE.md?

## Recommended Research Follow-On

- [ ] Test `--think` on `hve-plan` with a Challenging-class task; compare plan quality vs. baseline
- [ ] Audit `hve-challenge` command body to confirm how artifact creation works and whether Write is truly missing
- [ ] Read `.claude/commands/hve-challenge.md` line-by-line to resolve the Write capability ambiguity
- [ ] Evaluate whether `/batch` skill's worktree-per-PR model overlaps or complements `hve-implement`'s phase-implementor dispatch
