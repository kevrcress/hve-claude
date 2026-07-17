# Session Memory: Subagent model retier + global install support
Date: 2026-07-06
Session type: implementation | review
Task slugs: docs-drift-test-gitignore, global-install-support

## Decisions Made
- Subagent model tiering: mechanical checkers (plan validator, RPI validator) stay `haiku`; judgment-graded reviewers (implementation validator, prompt evaluator) pinned `sonnet`; researcher moved to `inherit`. Chosen over blanket inherit to keep frequent mechanical validation cheap; chosen over pinning researcher to a tier so it follows custom model IDs set via /model.
- Docs that restate agent frontmatter are now test-enforced (`tests/run-drift-tests.sh`) rather than convention-enforced: the drift bit twice in one day (README + docs/internals.md missed during the retier).
- `--global` install mode targets `~/.claude/` and merges `~/.claude/CLAUDE.md`; skips .gitignore (per-project) and old-folder migrations (`~/instructions` may be the user's own). An any-OS paste prompt in docs/installation.md is the path for Windows without Git Bash.
- Bundled the retier and drift test in one commit (9b610f7) since the test exists because the retier review caught doc drift.
- Local `--no-ff` merges, no PRs, per user preference for this repo.

## Failed Approaches
- Case-sensitive grep for "haiku" as a consistency check: missed capitalized "Haiku" in README prose and the docs/internals.md table. Always sweep case-insensitively; better, run `tests/run-drift-tests.sh`.
- First install.sh draft used `${CLAUDE_DIR#$HOME/~}` for display paths (nonsense expansion); replaced with explicit `*_LABEL` variables.

## Open Questions
- [ ] Blog drafts (4 files) and 2026-06-12 writeup at repo root: consolidate, move, or delete? User said they are context, not part of the project.
- [ ] `.claude-hve-tracking/research/2026-06-16/claire-hackathon-blog-research.md` untracked; belongs to the blog work, deliberately not committed.
- [ ] `dev` branch is behind `main` with nothing unmerged; old feature branches (`feature/instructions-move-and-tests`, `feature/readme-restructure`) look stale. Delete?

## Next Steps
- [ ] Deferred review Minors: rewrap CLAUDE.md global paragraph (IV-003); reject unrecognized `--` flags in install.sh before target-dir parsing (IV-004); add comment on the prompts-migration guard (IV-005). See global-install-support-quality.md.
- [ ] Run shellcheck on tests/run-drift-tests.sh once installed (brew install shellcheck).
- [ ] Mention tests/run-drift-tests.sh in CONTRIBUTING.md alongside the install suite.
- [ ] `/hve-challenge --all` flag remains the top backlog feature (planned 2026-06-02, branch never created).

## Key Files
- `install.sh:32` — --global flag parsing; `install.sh:171` — CLAUDE.md merge target switch
- `tests/run-drift-tests.sh` — docs-vs-frontmatter drift suite (33 assertions)
- `tests/run-install-tests.sh:367,444` — test5 (global install) and test5b (global upgrade); suite total 48
- `docs/installation.md:118` — Global install section incl. any-OS paste prompt

## Tracking Artifacts
- Plans: .claude-hve-tracking/plans/2026-07-06/docs-drift-test-gitignore-plan.md, .claude-hve-tracking/plans/2026-07-06/global-install-support-plan.md
- Changes: .claude-hve-tracking/changes/2026-07-06/ (both slugs)
- Reviews: .claude-hve-tracking/reviews/rpi/2026-07-06/ (subagent-model-tuning-quality.md, global-install-support-review.md + 4 phase validations + quality)

## Context Notes
Everything from this session is merged to main and pushed (bcacb62). Kevin's laptop global install at ~/.claude was migrated from an unmarked manual install to marker-managed: his ~/.claude/CLAUDE.md now has the HVE:START/END markers, so future updates are just `./install.sh --global` from a pulled repo. The hve-claude repo itself keeps project-level copies that shadow the global ones (intentional: the repo is the source; this is why hve skills appear twice in sessions here). Review verdicts: both tasks ✅ Complete; the global-install review's one Major (untested global upgrade paths) was remediated in-session with test5b.
