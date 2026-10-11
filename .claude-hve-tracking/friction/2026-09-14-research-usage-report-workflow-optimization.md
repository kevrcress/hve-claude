# Friction Log: /hve-research usage-report-workflow-optimization

Date: 2026-09-14
Phase: research
Slug: usage-report-workflow-optimization

## 2026-09-14 — No Glob or Grep tool in the harness; command forbids the Bash fallback

- What the text said: `.claude/commands/hve-research.md` Phase 1 step 2: "If no standalone Grep tool is available in this session, fall back to Glob plus targeted Read calls — never add Bash to route around this."
- What happened: this session exposed neither Glob nor Grep (only Read, Write, Edit, Bash, Agent). Read on a directory returns an error, so the prescribed fallback could not list `.claude/commands/`, `.claude/agents/`, or the plans folder at all. The parent ran one read-only `ls`/`grep -n`/`wc`/`git log` orientation call through Bash and recorded the deviation here and in the research artifact's Method line.
- Smallest fix: extend the fallback sentence to cover the no-Glob case: "if neither Grep nor Glob is available, a single read-only shell listing (`ls`, `grep -n`, `wc`) is permitted for orientation; record it in the artifact's Method line." Alternatively, have the parent delegate orientation to an `hve-researcher` (which carries Glob/Grep) before defining themes, at the cost of one extra dispatch.

## 2026-09-14 — Seed research is a parent-written artifact at the same slug the command will write to

- What the text said: Phase 3 writes the consolidated document to `.claude-hve-tracking/research/YYYY-MM-DD/TASK-SLUG.md`. The seed artifact already occupies exactly that path and its Method line says it is the INPUT to this pass.
- What happened: overwriting the seed would destroy the claims being checked; writing a second file under a different slug breaks `/hve-plan` slug discovery (which is also the seed's Open Question 6). The parent chose to rewrite the file in place as the verified successor, preserving the seed's claim numbering and marking each claim confirmed, corrected, or extended, with a Corrections section per CLAUDE.md rather than silent rewrites.
- Smallest fix: document a "seed research" convention in hve-research.md: when a same-slug research file already exists and declares itself an input, the pass rewrites it in place with a `Supersedes:` header line and keeps a Corrections section; never creates a sibling slug.

## 2026-09-14 — One research artifact feeds three bundle plans, but discovery is slug-keyed

- What the text said: CLAUDE.md `Artifact Discovery & Relevance` step 1, "A task slug given in arguments wins"; hve-plan.md:27 locates research "preferring TASK_SLUG when set"; hve-plan.md:35 derives the plan slug from the research doc; hve-review.md:29 re-globs research by `*/TASK-SLUG.md`.
- What happened: the seed's Scope Split recommends three plan/implement/review cycles (bundles A, B, C) from this one research file. Each bundle plan needs its own slug, so the plan slug cannot be derived from the research doc, and a review run under a bundle slug will not rediscover the shared research. The stalled-plans researcher found the same situation was handled once before (project-communication-presence log DD-007: two plans, distinct slugs, one research doc) by passing the slug explicitly and relying on the free-text `Research:` header. That works for plan and implement but leaves review's optional research input empty.
- Smallest fix: add one sentence to hve-review.md Phase 1 (around :38): "When the plan's `Research:` header names a path, read that file rather than re-globbing by slug." Optionally accept `--research <path>` on hve-plan so the header is set deterministically instead of by the planner remembering to write it.
