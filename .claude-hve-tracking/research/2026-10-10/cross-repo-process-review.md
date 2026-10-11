# Research: Cross-Repo Process Review (what hve-claude needs to change)
Date: 2026-10-10
Task slug: cross-repo-process-review
Confidence: HIGH on repo-state claims (each spot-checked by the parent with shell at HEAD 01c0e85); MEDIUM on design recommendations; platform claims are from the official docs as read 2026-10-10 and carry the caveats listed in Theme 3.
Method: parent-led sweep, not a formal `/hve-research` run. Three `hve-researcher` subagents (friction-logs, orchestrator-overlap, consumer-signals) plus one non-roster `claude-code-guide` agent, used because the question "what changed in the Claude Code platform" needs WebFetch against the docs and changelog and no roster agent is scoped for that. Parent ran all shell (git state, both test suites, spot-checks of every Major subagent claim). Subagent artifacts: `.claude-hve-tracking/research/subagents/2026-10-10/cross-repo-process-review-*.md`.
Builds on: `.claude-hve-tracking/research/2026-09-14/usage-report-workflow-optimization.md` (not superseded; its nine proposed changes and three bundles are still the carrier for Themes 1 and 2, and its citations are still exact because HEAD has not moved since).

## Summary

Between August and October the way HVE gets used changed underneath it. Direct `/hve-*` sessions were replaced by orchestrator seats (the `hve-orchestrator` repo and per-project playbooks), and HVE was never updated to serve that caller, so the orchestrator now carries "never run this HVE command here" rules and seats hand-write changes logs. Separately, the Claude Code platform moved (no Glob or Grep in the parent session by default, background subagent dispatch, new frontmatter fields), which makes two HVE instructions unfollowable and one shipped example broken. Ten friction entries from other repos are open and unplanned. Inside this repo, one finished branch is live in the global install but was never pushed or merged, four August plans and one September research pass are stalled, and about 60 tracking files are uncommitted.

Nothing found is a new architecture problem. The work is: land what is already designed, add one small-defect bundle, and make four policy decisions.

## Part 1: Work in progress in this repo

| # | Item | State | Evidence |
|---|---|---|---|
| W1 | Branch `feature/validators-inherit-model` (2 commits: all subagents `model: inherit`; `fable` added to `--subagent-model`) | Complete, never pushed, no upstream, no PR, no `/hve-review`. The global install at `~/.claude` has been running this branch since 2026-08-23. Drift suite 250/250, install suite 69/69 on 2026-10-10. | `git rev-list --count main..HEAD` = 2; `diff -rq .claude/{commands,agents,instructions,prompts} ~/.claude/...` empty; 14 files differ between `main` and `~/.claude` |
| W2 | Uncommitted tracking artifacts | 2026-08-19 research (3), plans (4), logs (4), details (5), one plan-validation review; 2026-09-14 research and friction log; today's research | `git status --short` |
| W3 | Four 2026-08-19 plans | None implemented, no changes logs. phase-close-clarity: Validated. project-communication-presence: Validated, Phase 0 done via PR #3. rpi-output-quality-regression: v2 Validated, needs a one-line `fable` amendment (Steps 3.1-3.2) and a rationale fix (Step 6.1). claude-md-lean-restructure: Draft. | plan headers; 2026-09-14 research Theme 9 |
| W4 | 2026-09-14 research: nine proposed changes in three bundles | No plan written. The 2026-09-21 usage report (360 sessions, up from 200) repeats the same top two friction classes. | `~/.claude/usage-data/report-2026-09-21-144524.html` |
| W5 | HiVE brief, 103 uncommitted lines added 2026-10-08 | Tail never mentions hve-orchestrator; model-tiering section (brief:190-213) is false at HEAD and unannotated; "new session per phase" (brief:140-156) opposes hve-orchestrator docs/method.md:29-38 | `.claude-hve-tracking/memory/2026-08-08/hive-orchestrator-project-brief.md` |
| W6 | Branch `feature/hve-interview-command` | 1 commit (a deferred-spec memory file), local only, unmerged | `git log main..feature/hve-interview-command` |
| W7 | Root-level untracked drafts | Four blog drafts and one writeup from June; not process material | `git status --short` |
| W8 | Seven local branches already merged to main | Cleanup only | `git branch --merged main` |
| W9 | Deferred backlog recorded in memory | Still open: hve-rpi-validator.md:83 hardcoded `[CRITICAL]` (verified today); HANDOFF block formatting and completion summary (both covered by phase-close-clarity); standalone review command; hve-plan parallel validation; `/hve-challenge --all`; `/hve-interview`; PR-description generation; `/hve-memory` update mode | `.claude/agents/hve-rpi-validator.md:83`; `.claude-hve-tracking/memory/2026-07-20/deferred-feature-candidates.md` |

## Part 2: Process changes needed

### Theme 1: HVE's main caller is now an orchestrator seat, and HVE stalls on it [HIGH]

- Usage moved. krava-core tracking artifacts by date folder: Aug 323, Sep 209, Oct 0 on any ref (`git log --since=2026-10-01 --all -- .claude-hve-tracking` returns nothing). PodcastCurator's October changes logs open with "HVE skill: none (the brief is the plan)" (PodcastCurator/.claude-hve-tracking/changes/2026-10-07/suggest-pinned-only-changes.md:4).
- The orchestrator encodes HVE's stalls as rules: "Never `/hve-implement` without a plan (it stops) and never `/hve` in a seat (its phase checkpoints wait on a human)" (hve-orchestrator/skills/orchestrator/templates/BRIEF-TEMPLATE.md:9-12); "do not tell it to run `/hve-review` when there is no plan + changes log" (hve-orchestrator/skills/orchestrator/SKILL.md:176-178); the peer-seat skill forbids cold-start artifact discovery.
- Unhandled on both sides: `.claude/commands/hve-implement.md:164` waits for user acknowledgment even under `--mode lightweight`, which is the exact run the brief template prescribes for seats. [HIGH on the texts, MEDIUM that it stalls in practice; untested]
- Seats are told not to dispatch `hve-phase-implementor` at all (`~/Documents/krava-orchestrator/SEAT-RULES.md:17`); the consumer sweep found 16 implementor runs cost 26.1M tokens. [MEDIUM on the figure; taken from a krava-core artifact]
- Carrier already designed: 2026-09-14 Bundle B (items 5 `--plan <path>`, 7 `--yes`, 8 acceptance register and review `--register`). Two items that research lacks: a bounded review loop (one review plus one fix pass, per hve-orchestrator/docs/method.md:60-65), and the `:164` wait.

### Theme 2: Gates can report false green, and review trusts the claim [HIGH]

- Unchanged from 2026-09-14 Themes 1, 2, 4: `.claude/commands/hve-implement.md:133` instructs `| head -100`, which replaces the runner's exit code; nothing in review re-reads a gate. The 2026-09-21 report names the same class as the top friction and adds "never claim a gate passed from a background-task notification".
- Consumer sweep adds: Bash-less validators grade items "Unverifiable" or fall back to in-seat checks in 5 repos (example: krava-core/.claude-hve-tracking/reviews/rpi/2026-08-27/phase-4-chunk-4a-review.md:18-28).
- Carrier: 2026-09-14 Bundle A (items 1, 2, 4, 6).

### Theme 3: The Claude Code platform moved under HVE [HIGH unless marked]

| Change (docs as of v2.1.296) | Effect on HVE | Fix |
|---|---|---|
| Glob and Grep are absent from the parent session by default on macOS/Linux; they return only for a subagent that lists them and omits Bash | `.claude/commands/hve-research.md:49` ("fall back to Glob... never add Bash") cannot be followed by the parent. Hit by this repo's own 2026-09-14 friction log and three cross-repo logs (F13). | Decide research-phase shell policy once (Decision D4) |
| A command's `allowed-tools` is a pre-approval list; it "does not restrict which tools are available" | The "no Bash by design" claims at hve-research.md:75 are unenforced prose. Friction F03 and F13 ask for opposite fixes. | Same decision |
| `hve-implementation-validator` lists `Glob, Grep, Bash` | Because it lists Bash, Glob/Grep may not be restored, while :148 limits Bash to git commands, so it may have no way to search. [MEDIUM; needs a live test] | Test, then either drop Bash or widen :148 to read-only commands |
| Hook commands receive JSON on stdin; `CLAUDE_TOOL_INPUT_FILE_PATH` is not a documented variable | The shipped auto-log example at CLAUDE.md:330 is broken as written. Resolves 2026-09-14 Open Question 8. | Read `tool_input.file_path` from stdin with `jq` |
| Subagents run in the background by default; completion arrives as a notification | HVE commands are written as if dispatch returns inline. No wording covers "wait for every notification before consolidating". | One sentence in each dispatching command |
| New subagent frontmatter: `omitClaudeMd` (v2.1.271), `effort`, `maxTurns`, `isolation: worktree`; per-dispatch `effort` on the Agent tool (v2.1.292) | Options, not breakage. `omitClaudeMd` would stop every subagent from loading the 23.5 KB HVE block; `isolation: worktree` fits parallel implementors; per-dispatch `effort` fits `--think`. | Evaluate in the lean-restructure plan |
| `Workflow` tool for deterministic multi-agent scripts | Candidate engine for `--mode full`. Whether a command body may call it is unconfirmed in the docs. | Research item, not scheduled |
| Commands are merged into skills; `.claude/commands/` still works with no deprecation | No migration required. | None |
| No documented way for a command prompt to detect headless mode | Confirms 2026-09-14's choice of an explicit `--yes` flag. | None |

### Theme 4: Global-install defects [HIGH]

- Instruction files are looked up repo-relative (`.claude/commands/hve-implement.md:42`, `.claude/agents/hve-phase-implementor.md:19`, `:31`, `:132`). Under a global install they live in `~/.claude/instructions/`, so sessions declare them missing: krava-core 5 times, PodcastCurator twice.
- "`diff.patch` is... gitignored" (`.claude/commands/hve-pr-review.md:36`) is true only in this repo (`.gitignore:5`). `install.sh:239-240` ships two rules and neither covers it (F10).
- The HVE CLAUDE.md block is 23,565 characters on every request in every project, and loads twice in this repo. The Draft claude-md-lean-restructure plan is the carrier.

### Theme 5: Review blind spots from cross-repo friction [HIGH]

Ten of 15 friction entries logged since 2026-08-01 are open and no existing plan covers them. The ones not already listed above:

- F09: `/hve-pr-review` diffs `main...HEAD`, which omits untracked files (hve-pr-review.md:36); `/hve-review` has the same gap (hve-review.md:95).
- F11: no exclusion of `.claude-hve-tracking/` from the reviewed diff (hve-pr-review.md:30, :36).
- F08: the empty-diff guard has no pre-authorized branch, so it always stops to ask (hve-pr-review.md:32).
- F14: "do not re-open the source files... trust their citations" (hve-research.md:86, same idea at hve-review.md:99) has no exception for existence or negative claims.
- F04: no check-disk-before-re-dispatch rule after a subagent failure (hve-research.md:77). F05: date folder splits when a phase crosses midnight (CLAUDE.md:117).
- From this repo's 2026-09-14 friction log: seed-research convention; one research doc feeding several plans (smallest fix is one sentence at hve-review.md:38).
- F12 (hve-review.md:7, :43) is arguably working as intended; needs a ruling, not a fix.

### Theme 6: Validator verdicts get overridden by parents [HIGH]

- gh-rpi-tracker/.claude-hve-tracking reviews: a parent moved a validator's Fail to Pass and 1 Critical plus 5 Major to 0 (gh-tracker-skill-review.md:87-108). Similar in krava-core phase7-console-review.md:122-125. Matches the standing feedback memory that validator severity tags are often wrong.
- The hardcoded `### RV-001 [CRITICAL]` template line at `.claude/agents/hve-rpi-validator.md:83` is a plausible contributor and is still unfixed.
- A krava-core review dated 2026-09-18 says the implementation validator has no Bash; it has had Bash since 2026-05-29 (commit 3881c1f). That is a consumer-side misreading, not a defect here.

### Theme 7: hve-orchestrator depends on hve-claude with no contract [HIGH]

- It writes paths the tracking tree does not declare: `consults/` (hve-orchestrator/agents/orch-consultant.md:13) and `gh-sync/` (skills/gh-tracker/SKILL.md:68). `orch-grader-lite.md:15` writes `reviews/rpi/<date>/<slug>-review.md`, the same filename `/hve-review` writes.
- gh-tracker parses plan and changes-log fields and RV-/IV- finding IDs (skills/gh-tracker/SKILL.md:120-247). A format change here breaks it silently; no drift test guards those fields.
- Briefs and registers have no home: krava-core uses `consults/`, WhatRemains `orchestration/`, kevincress `sandbox/orchestrator/` (gitignored), PodcastCurator `~/Documents`.
- No hve-claude living doc mentions hve-orchestrator or gh-tracker (grep of README.md, CLAUDE.md, CONTRIBUTING.md, docs/ returns nothing).

### Theme 8: Policy contradictions between the two repos [HIGH]

- Model: CLAUDE.md Model Selection says nothing is pinned; the orch agents pin `fable`, `opus`, `sonnet` (hve-orchestrator/agents/*.md:4).
- Shell: CLAUDE.md "Shell stays in the parent" versus orch-verifier and orch-grader-lite holding Bash.
- Two risk lists: CLAUDE.md Risk override versus hve-orchestrator/skills/orchestrator-dispatch/SKILL.md:18-19.

### Theme 9: Instruction coverage gaps [MEDIUM]

Consumer repos implemented in SQL, CSS, TSX, Astro/MDX, GitHub Actions YAML, and TOML with no conventions file. The fallback rule covers it, so this is Minor; most of the "missing instructions file" notes are really Theme 4's path defect.

## Recommended sequence

0. **Housekeeping (no plan needed).** Commit the untracked tracking artifacts. Push `feature/validators-inherit-model`, open a PR, merge. It is already what runs globally, so every later plan should cite a `main` that matches.
1. **Small-defect bundle (new plan, suggested slug `platform-drift-quick-fixes`).** Hook example (CLAUDE.md:330); hve-rpi-validator.md:83; `diff.patch` ignore rule in install.sh plus install tests; instruction path resolution under global install; research shell policy per D4; background-dispatch wait sentence; hve-review.md:38 sentence; F09, F11, F08, F14, F04; declare `consults/` and `gh-sync/` in the tracking tree.
2. **phase-close-clarity** (Validated; re-verify citations after steps 0 and 1).
3. **Bundle A, gate evidence** (2026-09-14 items 1, 2, 4, 6).
4. **Bundle B, seat caller** (items 5, 7, 8, plus the `:164` wait and the bounded review loop). Gated on D2.
5. **Bundle C, installer and hooks** (items 3, 9) with the lean-restructure decision D5 and the `omitClaudeMd` evaluation.
6. **External-consumer contract**: document the fields gh-tracker parses, add a drift test, add a README pointer to hve-orchestrator.
7. rpi-output-quality-regression after its `fable` amendment; project-communication-presence last.

## Decisions needed

- D1. Is HiVE still a separate product, or has hve-orchestrator replaced it? Decides whether to annotate or retire the brief.
- D2. Should hve-claude officially support non-human callers (brief as plan, `--yes`, acceptance register)? Recommendation: yes. It is where most usage now is, and the alternative is the orchestrator keeps bypassing HVE and artifacts keep being hand-written.
- D3. Model policy: keep pure `inherit`, or adopt a fixed small tier for mechanical measurement as the orch agents do? Recommendation: keep `inherit` here; the brief's own 2026-10-08 note (small models agreed with human judgment about 37% of the time) supports it. Leave orch-verifier's pin alone since it only returns numbers.
- D4. Research-phase shell policy. Recommendation: permit one read-only parent shell pass for orientation and git history, recorded in the artifact's Method line. The no-Bash rule is unenforceable (`allowed-tools` does not restrict) and unfollowable (no Glob or Grep in the parent), and CLAUDE.md already says the parent owns shell.
- D5. claude-md-lean-restructure: Path 1 (land Phases 1-5 first) or Path 2 (fold pieces into Bundles B and C), carried forward from 2026-09-14 Open Question 5.

## Decisions recorded (2026-10-10, Kevin, in chat)

- D1: HiVE and hve-orchestrator both stay separate from hve-claude and from each other. Which one persists is undecided. Consequence: hve-claude takes no dependency on either; the HiVE brief is kept, not retired, and still needs Corrections-rule annotations where it is false at HEAD.
- D2: Yes. HVE supports non-human callers. Bundle B is in scope.
- D3: Keep `model: inherit` for every subagent.
- D4: Accepted as recommended. Research may run one read-only parent shell pass, recorded in the artifact's Method line.
- D5: Answered "yes" to a two-path question, so the path is still unchosen. Confirm Path 1 or Path 2 before Bundle B or C is planned. It does not block housekeeping, the small-defect bundle, or phase-close-clarity. (superseded, see next line)
- D5, decided later on 2026-10-10: Path 2. The shrink does not run as a standalone plan now. Its hooks-relocation steps (1.1, 1.2, 2.1) fold into Bundle C and its Phase 6 folds into Bundle B; the rest of the shrink is re-planned once, after the bundles land, against the final CLAUDE.md text.
- Recommended sequence: approved as written.

## Open questions

1. Does `hve-implementation-validator` actually have Glob/Grep in the current harness? Needs one live dispatch.
2. Does hve-implement.md:164 stall a background seat in practice?
3. Can a command body invoke the `Workflow` tool? The docs do not say.
4. F12: defect or working as intended?
5. Was the plan-time compile check ("Step 3a") dropped on purpose? It is in neither the repo nor `~/.claude`; lean-restructure log DD-003 still reads "Open, deferred" about text that no longer exists.

## Codebase references

.claude/commands/hve-implement.md: instructions lookup :42, :111; piped gate :133; acknowledgment wait :164
.claude/commands/hve-research.md: Glob fallback :49; tool boundary :75; no-re-dispatch gap :77; trust-citations :86
.claude/commands/hve-pr-review.md: file list :30; empty-diff guard :32; diff write and gitignore claim :36
.claude/commands/hve-review.md: changed-file base :95; context discipline :99; research re-glob :38
.claude/agents/hve-rpi-validator.md: tools :6; hardcoded severity :83
.claude/agents/hve-implementation-validator.md: tools :6; Bash limit :148
.claude/agents/hve-phase-implementor.md: instructions lookup :19, :31, :132
CLAUDE.md: Risk override; Model Selection; Tracking Folder Structure; Subagent Dispatch Discipline; hooks example (search `CLAUDE_TOOL_INPUT_FILE_PATH`)
install.sh: gitignore rules :239-240
.gitignore: diff.patch rule :5

## External references

https://code.claude.com/docs/en/tools-reference (Glob and Grep availability)
https://code.claude.com/docs/en/sub-agents (frontmatter fields, background dispatch, model resolution)
https://code.claude.com/docs/en/hooks and /env-vars (hook input contract)
https://code.claude.com/docs/en/skills (commands merged into skills; `allowed-tools` semantics)
https://code.claude.com/docs/en/workflows and /headless
/Users/kevin/GitHub/hve-orchestrator (skills, agents, docs/method.md)
~/.claude/usage-data/report-2026-09-21-144524.html
~/Documents/krava-orchestrator/SEAT-RULES.md
