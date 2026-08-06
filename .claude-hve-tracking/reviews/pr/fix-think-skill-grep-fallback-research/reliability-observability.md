# PR Review — Reliability and Observability: fix/think-skill-grep-fallback-research
Date: 2026-08-05
Branch: fix/think-skill-grep-fallback-research
Dimension(s): Reliability and Observability

## Reliability and Observability

### RO-001 [Major]
Location: `.claude/agents/hve-researcher.md:30`, `.claude/commands/hve-research.md:47`
Finding: The fix correctly converts a hard block (no Grep available → phase cannot proceed) into a degraded-but-functional path (Glob+Read fallback). However, neither carrier instructs the agent to *record* that the fallback was used. Concretely:
- The researcher subagent's confidence scheme (`hve-researcher.md:38-41`, `[HIGH]/[MEDIUM]/[LOW]`) grades individual findings by how directly they were observed, not by search *coverage*. A finding read directly in one of the 2-4 files picked via Glob is still `[HIGH]` even though the broader Grep sweep that would normally surface competing/contradicting evidence never ran.
- `hve-research.md` Phase 3 (Consolidate Findings, lines 79-121) has no step asking subagents whether they hit the fallback, so the parent orchestrator and the downstream Plan phase have no way to know evidence coverage was reduced for a given theme.
- The subagent's own friction-capture mechanism does not exist at all in `hve-researcher.md` (only the parent `hve-research.md` command wires up `--friction-log`, and that flag is off by default) — so even the opt-in instrumentation path never reaches the place where the degraded condition actually occurs.
Net effect: the PR trades a loud failure (block) for a silent one (quality degradation with no signal), which is the exact anti-pattern this dimension flags ("fail silently ... rather than degrade gracefully"). Graceful degradation requires both the fallback behavior *and* a signal that it happened; only the former was added.
Recommendation: Add one clause to both fallback sentences (or to the subagent's Step 4 template) instructing the agent to note fallback use — e.g., append an `## Open Questions` or dedicated note: "Grep was unavailable this session; findings from Glob+Read fallback may have reduced coverage versus a full-repo symbol search." Optionally also surface it in the one-line `Status:` response so the parent consolidator can flag reduced-confidence themes in the consolidated doc.

### RO-002 [Minor]
Location: `.claude/agents/hve-researcher.md:30`, `.claude/commands/hve-research.md:47`
Finding: The trigger condition is worded as "If no standalone Grep tool is available in this session" — this covers the case where Grep is absent from the tool list, but not the case where Grep is listed/available yet a call to it fails or errors at runtime (e.g. the underlying harness bug this fix originates from, per `.claude-hve-tracking/research/2026-08-04/think-skill-grep-fallback-audit.md:26-27`, was itself framed generically as a "Grep-tool outage" without distinguishing the two). As written, an agent that sees Grep offered, calls it, and gets an error has no explicit instruction to treat that as the trigger for falling back — it could plausibly retry indefinitely or stall waiting on a tool that keeps failing.
Recommendation: Broaden the trigger clause to cover both cases, e.g.: "If no standalone Grep tool is available in this session, or a Grep call errors/fails to return, fall back to Glob plus targeted Read calls..."

### RO-003 [Minor]
Location: `.claude/commands/hve-plan.md:49`, `.claude/commands/hve.md:85`
Finding: The `/think` fix is sound (matches the already-correct precedent in `hve-review.md`, confirmed by prior research at `think-skill-grep-fallback-audit.md:16,20`) and removes the previous runtime failure mode (invoking a nonexistent slash command). No new failure mode is introduced — extended thinking is a model capability, not a tool call, so there is nothing to "fail" if unsupported; the agent simply reasons in prose. No action needed; noted for completeness since this dimension covers both changed concerns.

## Not Flagged (considered and dismissed)

- Scope of the Grep-fallback fix (limited to `hve-research.md` and `hve-researcher.md`, not the 4-5 other agents whose frontmatter also lists `Grep` without `Bash`, e.g. `hve-pr-reviewer.md`, `hve-plan-validator.md`, `hve-rpi-validator.md`, `hve-prompt-evaluator.md`): checked those files' bodies — none contain a body-level "Use Grep to ..." mandatory-step instruction (Grep only appears in their `tools:` frontmatter), so the specific blocking failure mode this PR targets does not reproduce there today. Also, the planning log's `DD-002` and the research doc's open question at line 29 already considered and consciously deferred wider scope. Not re-raised here.
- `hve.md`'s own Grep-based orientation: confirmed at `hve.md:63-73` that Phase 1 delegates orientation entirely to spawned `hve-researcher` subagents and has no inline "Use Glob and Grep" step of its own to attach a fallback note to; this matches `DD-002` in the planning log (`plans/logs/2026-08-04/think-skill-grep-fallback-audit-log.md:11-15`), which is a reasonable, already-documented decision.
