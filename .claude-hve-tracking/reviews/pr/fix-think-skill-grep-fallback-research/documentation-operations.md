# PR Review — Documentation and Operations: fix/think-skill-grep-fallback-research
Date: 2026-08-05
Branch: fix/think-skill-grep-fallback-research
Dimension(s): Documentation and Operations

## Documentation and Operations

### DO-001 [Minor]
Location: `.claude-hve-tracking/plans/2026-08-04/think-skill-grep-fallback-audit-plan.md:57` (Risk Log); `.claude-hve-tracking/reviews/rpi/2026-08-05/think-skill-grep-fallback-audit-quality.md:41-42` (IV-001, echoes the same gap)
Finding: The root cause of this PR — the repo's `.claude/commands/{hve.md,hve-plan.md,hve-research.md}` and `.claude/agents/hve-researcher.md` silently drifting out of sync with the already-fixed, live `~/.claude` global install — is acknowledged twice (plan Risk Log, RPI quality review IV-001) but neither mention converts it into a trackable follow-up. It lives only inside two dated, easy-to-miss artifacts. Nothing in this diff adds a regression check (e.g., a new `tests/run-drift-tests.sh` group, per that script's own stated purpose of "docs-vs-frontmatter drift" checks) or a durable backlog/memory entry, so the same class of silent repo-vs-install drift can recur and would again require ad-hoc `diff ~/.claude ...` discovery during a future planning session.
Recommendation: Add a one-line TODO to `tests/run-drift-tests.sh`'s header comment (or a `.claude-hve-tracking/memory/` entry) naming this as a candidate future test group ("repo prompt files vs. `~/.claude` install — no automated check yet"), so the risk is discoverable outside a single dated plan file.

### DO-002 [Minor]
Location: `CLAUDE.md:` "Installing HVE in Your Project" section (both `~/.claude/CLAUDE.md` and this repo's `CLAUDE.md`, byte-identical prose); `.claude-hve-tracking/plans/2026-08-04/think-skill-grep-fallback-audit-plan.md:8` ("already fixed and live-validated in the user's globally-installed `~/.claude` copy but never landed back into this repo")
Finding: This PR's plan states plainly that the fix originated as a live hand-patch applied directly to the global `~/.claude` copy and was only backported to the repo now, after the fact. CLAUDE.md's installation docs describe the forward sync direction (`./install.sh --global` copies repo → global, "idempotent — re-run it to pull updates") but say nothing about the reverse case — an in-session hotfix applied straight to `~/.claude` needs to be manually diffed back into the repo, or it silently becomes stale/divergent exactly as happened here. This PR is direct evidence the gap is not hypothetical.
Recommendation: Add one sentence to CLAUDE.md's "Installing HVE in Your Project" section noting that ad hoc edits made directly to an installed `~/.claude` copy should be backported to the repo (and diffed) rather than left to drift, since `install.sh` only pushes repo → global, never the reverse.

## Notes (non-blocking, for context)
- Confirmed no other repo doc needs updating: `README.md`, `.claude/instructions/*.md`, and both `CLAUDE.md` files were grepped for `/think` and stray "Grep tool" references — no matches outside the four intentionally-edited files (cross-checked independently; matches the plan's own Out-of-Scope sweep at plan.md:51).
- `.claude/commands/hve.md` carries unrelated pre-existing drift from `~/.claude` at lines ~131-149 (a Step 3a/3b/3c compile-check block present in the global copy but not the repo), discovered and correctly recorded as out-of-scope in `.claude-hve-tracking/changes/2026-08-05/think-skill-grep-fallback-audit-changes.md:84` rather than silently left uncommented. This is good practice, not a defect — flagged here only as supporting evidence for DO-001's broader pattern.
