# PR Review — Performance and Scalability: fix/think-skill-grep-fallback-research
Date: 2026-08-05
Branch: fix/think-skill-grep-fallback-research
Dimension(s): Performance and Scalability

## Performance and Scalability

### PS-001 [Minor]
Location: `.claude/agents/hve-researcher.md:30`, `.claude/commands/hve-research.md:47`
Finding: The new Grep-unavailable fallback tells the agent to substitute "Glob (broad filename/pattern matching) plus targeted Read calls for content search." Unlike Grep (a single indexed content scan), simulating content search via Glob+Read requires opening and reading the full body of every file the glob matches, since Glob alone cannot filter by symbol/pattern content. The instruction bounds nothing about how many matched files may be opened this way — contrast with the very next line in hve-researcher.md ("Read the most relevant 2–4 files; do not read everything"), which does cap reads explicitly. In a large repo, a broad glob (e.g. `**/*.ts`) combined with no cap could turn one cheap Grep call into dozens of Read calls per subagent. This compounds because hve-research.md Phase 2 spawns 3–5 `hve-researcher` subagents in parallel (hve-research.md:61), so if Grep is absent for the session, the fallback's read volume multiplies across every concurrently running subagent.
Recommendation: Add an explicit bound to the fallback text, e.g. "narrow the Glob pattern as much as possible and Read at most 5–8 candidate files before concluding the content search" (or reference the existing 2–4 file cap directly), so the degraded path stays proportionate even without Grep.

### PS-002 [Minor]
Location: `.claude/commands/hve.md:49`, `.claude/commands/hve-plan.md:23`
Finding: The `/think` → "extended reasoning pass (interleaved/extended thinking)" rewording has no loop, I/O, or file-scanning behavior attached — it only changes how the model is instructed to reason before drafting. No performance or scalability concern is introduced by this half of the diff; recorded for completeness of dimension coverage, not as an actionable defect.
Recommendation: None required.
