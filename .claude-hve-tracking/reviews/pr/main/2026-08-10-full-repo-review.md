# Senior Review — hve-claude @ main (commit 1c2e53e, 2026-08-06)

**Reviewed as:** full-repo state-of-main review (no PR diff — the whole tree treated as one change under review)
**Scope:** `.claude/commands/*.md`, `.claude/agents/*.md`, `.claude/instructions/*.md`, `CLAUDE.md`, `tests/*.sh`, `install.sh` (plus `docs/*.md` and `README.md` for the Documentation dimension)
**Reviewer method:** 6 parallel dimension reviewers (2 dimensions each, one dimension solo where volume warranted), each required to quote source text; a sample of ~10 findings spanning every dimension was independently re-verified against the file content before inclusion below.

Findings excluded per the review brief (already tracked elsewhere): the `hve-pr-review.md --dimension` security-skip, `hve-review.md:19`'s dead `--mode` flag, the implementation-validator's dimension-scope contradiction, the HANDOFF box-drawing render issue, anything on unmerged branches, and the missing `hve-challenge --all` flag.

## Summary tally

| Severity | Count |
|---|---|
| Critical | 0 |
| Major | 22 |
| Minor | 17 |
| **Total** | **39** |

## Verdict: ⚠️ Request Changes

Per this repo's own verdict rule (Block on any security Critical or data-integrity risk; Request Changes on any Critical or >2 Major; otherwise Approve): zero Critical findings and no security Critical, so this does not Block — but 22 Major findings is far past the >2 threshold, so this Requests Changes. None of the Major findings are individually blocking; several (RL-01 through RL-04) share one root cause and one fix.

---

## Functional Correctness (FC)

### FC-01 — Major
**File:** `.claude/commands/hve-implement.md:27`
**Summary:** Plan discovery in `hve-implement.md` omits the branch-tiebreak / ask-on-ambiguity rule that its three sibling commands carry verbatim.

`hve-plan.md:25`, `hve-review.md:25`, and `hve-challenge.md:25` all carry the identical sentence: *"Discover inputs per the Artifact Discovery & Relevance convention in CLAUDE.md: slug argument first, else recent distinct slugs (ask on ambiguity, never silently pick between same-day slugs)..."* `hve-implement.md:27` instead reads: *"find the most recent `.claude-hve-tracking/plans/*/TASK-SLUG-plan.md` (latest date, or matching `$ARGUMENTS` slug)"* — no branch tiebreak, no ask-on-ambiguity. The file does invoke the convention by name at line 31, but only inside the cold-start (no-plan-found) branch, not for the multiple-same-day-candidates case. Since the plan is the single unreconstructible input to this phase, two same-day plan slugs would cause a silent pick with undefined tiebreak behavior — exactly what CLAUDE.md's Artifact Discovery & Relevance section forbids.

### FC-02 — Major
**File:** `.claude/commands/hve-implement.md:3,19`
**Summary:** `hve-implement.md` advertises and parses `--mode` and `--think` flags that are never referenced again anywhere in the file — a second, independent instance of the same dead-flag defect already tracked for `hve-review.md:19`.

Line 3's argument-hint advertises `[--mode lightweight|standard|full]`; line 19 parses `$ARGUMENTS` into `MODE (`--mode` value if present)` and `THINK_MODE (`--think` present)`. Neither `THINK_MODE` nor `MODE` (`--think` isn't even in the argument-hint) appears anywhere else in the file — confirmed by grep: the string `MODE` occurs exactly once, at line 19 itself. The only complexity gate actually used is the "Simple carve-out" driven by the plan's own difficulty grade, not by the parsed flag. A user passing `--mode lightweight` to `/hve-implement` gets no behavior change. *(Cross-reference: `hve-implement.md`'s Command Reference row also omits this flag entirely — see DO-01 below; both are symptoms of the same underlying bug and are not double-counted in the tally.)*

---

## Design and Architecture (DA)

### DA-01 — Minor
**File:** `.claude/commands/hve-review.md:4,43`
**Summary:** The reviewer is instructed to *append* a Correction entry to the changes log, but its `allowed-tools` frontmatter (line 4: `Read, Write, Glob, Grep, Bash, Agent`) grants no `Edit`.

Line 43 states "the reviewer appends the dated `Correction (YYYY-MM-DD):` entry itself per the CLAUDE.md corrections convention." Without Edit, an "append" can only be done via a full read-then-overwrite `Write` call — the exact whole-file-clobber risk CLAUDE.md's concurrent-writes guidance (CLAUDE.md:319) warns against for the changes log, applied here to the review-time correction path instead.

---

## Idiomatic Implementation (II)

*No violations found for Citation Format (no markdown-link citations anywhere in scope) or Confidence Markers (research/plan commands and their agents consistently use `[HIGH]`/`[MEDIUM]`/`[LOW]`). All findings below concern the Subagent Response Protocol.*

### II-01 — Major
**File:** `.claude/agents/hve-prompt-updater.md:100-106`
**Summary:** Response Format replaces the mandated status line and follow-on checklist and drops clarifying questions entirely.

Specifies: (1) `Written: [path] (run N)`, (2) `Fixes applied: N critical, N major, N minor`, (3) up to 7 changes made, (4) up to 3 deferred findings, (5) `Full detail: ...`. CLAUDE.md's protocol requires part 2 to be Pass/Fail or Complete/Blocked (this is neither), part 4 to be a checklist of up to **5** follow-ons (this caps at 3 and repurposes it), and mandates a part-5 "up to 3 clarifying questions — only if blocking" section that is missing outright. 6 required parts collapse into 5 different ones.

### II-02 — Major
**File:** `.claude/agents/hve-prompt-tester.md:89-95`
**Summary:** Response Format omits clarifying questions and never offers a Blocked status.

Specifies only 5 parts, ending at "Full detail." CLAUDE.md's part 5 ("up to 3 clarifying questions — only if blocking") is absent. The status line is hardcoded to `Status: Complete` with no Blocked variant documented anywhere in the file, contradicting "other agents use Complete / Blocked."

### II-03 — Major
**File:** `.claude/agents/hve-prompt-evaluator.md:91-97`
**Summary:** Response Format uses a non-standard status vocabulary and omits clarifying questions.

Part 2's value is `Verdict: No issues remaining: Yes` / `No: N critical, N major` — matching neither "Pass/Fail" nor "Complete/Blocked." The clarifying-questions part is missing; only 5 of 6 mandated parts are present.

### II-04 — Major
**File:** `.claude/agents/hve-prompt-evaluator.md:43-46`
**Summary:** The evaluator's own compliance checklist describes the response protocol incompletely, so the one QA mechanism meant to catch II-01/II-02 is structurally blind to the specific parts they're missing.

The criterion reads: *"Does it follow the HVE subagent response format (7-finding max, checklist, full-detail pointer)?"* — three items, omitting the status line and the clarifying-questions section. Since `hve-prompt-builder`'s evaluate step uses exactly this criterion to grade drafts (including `hve-prompt-tester.md` and `hve-prompt-updater.md` themselves), the defects in II-01/II-02 would not be caught by the tool designed to catch them.

### II-05 — Minor
**File:** `.claude/commands/hve-prompt-analyze.md:53`
Same incomplete three-part protocol description used as an evaluation criterion: *"Follows HVE subagent response format (for agents: 7-finding cap, checklist, full-detail pointer)."* A `/hve-prompt-analyze` run against a non-compliant agent would not flag a missing status line or missing clarifying-questions section.

### II-06 — Minor
**File:** `.claude/commands/hve-prompt-refactor.md:47`
Same incomplete three-part protocol description under "Enforce HVE Conventions" — a refactor pass driven by this checklist would leave a missing status line or clarifying-questions section unfixed.

### II-07 — Minor
**File:** `.claude/agents/hve-prompt-updater.md:58`
The updater's own "Verify Conventions" step for agent definitions uses the same incomplete description — explaining why its own Response Format (II-01) never got the missing parts added.

---

## Reusability and Leverage (RL)

*RL-03 through RL-06 below are four instances of one systemic pattern — CLAUDE.md convention text copy-pasted into command/agent files verbatim instead of referenced by name (the way `hve-plan.md:25` and `hve-pr-reviewer.md:43` correctly do it elsewhere in this same repo). One fix — replace each copy with a one-line reference — closes all four.*

### RL-01 — Major
**File:** `.claude/commands/hve-implement.md:11-19` (also `hve-review.md:11-19`, `hve-plan.md:11-19`)
**Summary:** The "parse `$ARGUMENTS` exactly once" instruction is contradicted by two flag-stripping instructions that precede it and act on `$ARGUMENTS` directly.

Line 11 strips `--subagent-model` "before other argument parsing"; line 13 strips `--friction-log` "before other parsing" — both against `$ARGUMENTS` directly. Line 19's Argument Parsing section then claims: *"Parse `$ARGUMENTS` exactly once, before anything else... none re-reads `$ARGUMENTS`"* — already false by the time it's stated. The identical structure repeats in `hve-review.md:11-19`, and in reversed order in `hve-plan.md:11-19`.

### RL-02 — Major
**File:** `.claude/commands/hve-implement.md:42`, `.claude/agents/hve-phase-implementor.md:19,31,132`
**Summary:** Neither the command nor its subagent implements CLAUDE.md's "no instructions file exists" fallback.

CLAUDE.md:284 requires: *"do not block: follow the dominant conventions of the existing code in the repo, and note the missing instructions file in the changes log."* `hve-implement.md:42` only says "Read the relevant `.claude/instructions/` file for the primary language involved... instruct subagents to do the same," with no fallback branch; `hve-phase-implementor.md` repeats the unconditional instruction at three separate points with the same gap. A language with no instructions file (Go, Ruby, etc.) has no documented path forward.

### RL-03 — Major
**File:** `.claude/commands/hve-research.md:13` (identically in `hve-plan.md:19`, `hve-implement.md:13`, `hve-review.md:13`, `hve-pr-review.md:13`, `hve-challenge.md:13`)
**Summary:** The full Friction Capture paragraph is duplicated verbatim across six command files instead of referencing CLAUDE.md:107-109, which already documents it.

### RL-04 — Major
**File:** `CLAUDE.md:292-295` vs. `.claude/agents/hve-implementation-validator.md:68-71` vs. `.claude/commands/hve-implement.md:142-144`
**Summary:** The Security Hygiene grep-pattern checklist is re-typed near-verbatim in two other files instead of referenced, on a security-relevant list where drift is costly. `hve-pr-reviewer.md:43` shows the alternative already works in this repo ("Run the full security checklist from CLAUDE.md").

### RL-05 — Minor
**File:** `.claude/commands/hve-review.md:81`
The "Shell stays in the parent" paragraph (CLAUDE.md:200) is copied verbatim rather than referenced, unlike the same file's own line 25 which correctly points back to CLAUDE.md by name.

### RL-06 — Minor
**File:** `CLAUDE.md:319`, `.claude/commands/hve.md:107`, `.claude/commands/hve-implement.md:109`, `.claude/agents/hve-phase-implementor.md:48`
The "Concurrent writes" rule (own exactly one `### Phase N:` section; no whole-file Write once multiple agents may hold it) is duplicated identically across four files instead of one canonical source.

### RL-07 — Minor
**File:** `CLAUDE.md:276,280`
`writing-style.md` and `markdown.md` are listed in the Instructions Reference table but never referenced by name from any command or agent (confirmed via grep across all 24 command/agent files). Every language instructions file is reachable via the generic "read the relevant `.claude/instructions/` file for the language" instruction, but that instruction is scoped to programming languages — the commands that actually author prose/markdown artifacts (`hve-prompt-builder.md`, `hve-prompt-refactor.md`, `hve-doc-ops.md`, `hve-prompt-updater.md`) never mention either file.

### RL-08 — Minor
**File:** `.claude/commands/hve-memory.md:37-42`
Restates the 4-step Artifact Discovery & Relevance algorithm near-verbatim instead of the one-line reference other commands use (compare `hve-plan.md:25`).

---

## Performance and Scalability (PS)

### PS-01 — Major
**File:** `.claude/commands/hve-research.md:29-34,48-49,61`
**Summary:** The Phase 0 difficulty table's "Subagent count" column (Medium: "1–2") never gates actual dispatch — Phase 1 instructs "List 3–7 specific research questions," groups them by theme, and Phase 2 spawns "one subagent per research theme" unconditionally, with nothing tying theme count back to the classification tier. A Medium task can legally produce up to 7 parallel researchers under a literal reading.

### PS-02 — Major
**File:** `.claude/commands/hve.md:34-40,67-68`
**Summary:** The orchestrator inlines the same research steps ("follow the same steps as hve-research.md") and inherits the identical ungated dispatch mechanic from PS-01, with no corrective wiring back to its own Phase 0 classification table.

### PS-03 — Major
**File:** `.claude/commands/hve-review.md:95,97`
**Summary:** Two directly conflicting instructions for how much of each validator's output to load.

Line 95: *"Read each output file. Consolidate Critical and Major findings in full text into the review log..."* Line 97, two lines later: *"**Context discipline**: read only the status line and top findings from each subagent response. Re-read the validation file only if you need full detail."* These can't both be followed for a multi-phase plan; the instructions don't say which wins. Verified directly — both lines quoted exactly as they appear in the file.

### PS-04 — Major
**File:** `.claude/commands/hve-implement.md:100,111`
**Summary:** Post-subagent verification ("Read the changes log — verify the subagent updated it correctly") is not scoped to the newly-added phase section; the changes log is one continuously-growing file. The later context-discipline note (line 111) exempts only the plan/details docs from full re-reads, not the changes log itself. Read literally, phase K's verification re-reads all K prior phase sections — O(N²) total reads across an N-phase plan.

### PS-05 — Major
**File:** `.claude/commands/hve.md:40` vs. `.claude/commands/hve-review.md:103`
**Summary:** `--mode full` promises "parallel RPI + quality validators in review," but `hve-review.md`'s Phase 3 always spawns exactly one `hve-implementation-validator` with no mode or difficulty branch anywhere in that phase (unlike Phase 2's Simple carve-out at line 79). A Challenging task gets the identical single-validator dispatch as a Simple one.

### PS-06 — Major
**File:** `.claude/commands/hve-doc-ops.md:49,51`
**Summary:** For any doc set ≥10 files, the command spawns "one `hve-researcher` subagent... per section or doc type" with no upper bound or batching strategy — unlike `hve-pr-review`'s explicitly capped 8/4-subagent design. A large `/docs` tree could trigger tens of concurrent dispatches in one pass.

### PS-07 — Minor
**File:** `.claude/commands/hve-git-merge.md:55`
Conflict handling loops over every conflicted file and dumps its full `git diff FILENAME` unconditionally, with no cap analogous to the `head -100` output cap used elsewhere in this repo (e.g. `hve-implement.md`'s test-output handling).

---

## Reliability and Observability (RO)

### RO-01 — Major
**File:** `.claude/commands/hve-implement.md:28`
**Summary:** No fallback for a missing Details doc, despite CLAUDE.md explicitly classifying "details" as reconstructible.

CLAUDE.md's Artifact Discovery & Relevance section lists reconstructible inputs as "(research, details)," rule: "record the skip and proceed." `hve-plan.md:27` and `hve-review.md:32` both correctly apply this. `hve-implement.md:28` simply reads: *"**Details**: find the corresponding `.claude-hve-tracking/details/*/TASK-SLUG-details.md`"* — no record-skip branch, no continue-without-it branch. This is exactly the class of gap the Template Blanks rule warns produces "a fabricated value or a stalled phase."

### RO-02 — Major
**File:** `.claude/commands/hve-implement.md:29`, `.claude/commands/hve-plan.md:28`
**Summary:** The two commands most likely to resume and overwrite a previously-written artifact never invoke the Corrections protocol themselves at resume time — only `hve-review.md` enforces it, and only retroactively.

`hve-implement.md:29` ("resume if one exists") and `hve-plan.md:28` ("resume/update it rather than starting over") both permit updating prior artifacts, but neither instructs the annotate-in-place-plus-dated-Correction-entry protocol during that resume — the changes-log template even carries an empty `#### Corrections` stub (`hve-implement.md:74-76`) with no trigger tied to it. A stale claim silently rewritten mid-implementation has no protocol enforcement until (and unless) `/hve-review` later runs.

### RO-03 — Minor
**File:** `tests/run-drift-tests.sh:551`
**Summary:** The canonical-block drift check for the discovery stub hardcodes an expected carrier count of 3 (`discovery_stub|3|identical|...`), which already excludes `hve-implement.md` from its baseline rather than catching that FC-01's carrier is missing it. Combined with the absence of any test touching slug-ambiguity resolution, template-blank fillability, or the Corrections protocol (confirmed via grep across all four test files), the suite verifies textual consistency of duplicated boilerplate, not that the discovery/correction behaviors it documents are implemented everywhere they should be.

---

## Security and Compliance (SC)

### SC-01 — Major
**File:** `install.sh:227-241`
**Summary:** `install.sh`'s `.gitignore`-writing logic omits the credential-file patterns CLAUDE.md's own Security Hygiene checklist declares mandatory.

CLAUDE.md:293 states `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` "must be listed" — and this exact text ships into every target project's `CLAUDE.md` via the HVE block. But the actual `.gitignore`-writing code (`add_ignore` calls at lines 239-240) only adds `.claude-hve-tracking/**/subagents/` and `.claude-hve-tracking/sandbox/` — never the credential patterns. This repo's own `.gitignore:20-26` correctly lists them (verified), so only the propagation-to-new-projects path is broken: a freshly-installed project gets a `CLAUDE.md` asserting rules the installer that just ran did nothing to satisfy.

### SC-02 — Major
**File:** `.claude/agents/hve-prompt-tester.md:1-6`
**Summary:** No `tools:` frontmatter restriction — defaults to unrestricted access (Bash, WebFetch, WebSearch, Agent) despite CLAUDE.md's "read-only by design" framing.

Confirmed via frontmatter comparison across all 9 agents: 7 of 9 declare a `tools:` line; `hve-prompt-tester.md` and `hve-phase-implementor.md` do not. Unlike `hve-phase-implementor` (which legitimately needs broad tools for implementation work), `hve-prompt-tester`'s job — simulate a draft against 2-3 scenarios, write a log to sandbox — matches the scoping already given to its sibling `hve-prompt-evaluator` (`Read, Write, Glob, Grep`). No stated need for Bash, network, or further Agent dispatch.

### SC-03 — Major
**File:** `.claude/agents/hve-prompt-updater.md:1-6`
**Summary:** Same gap as SC-02. Job is to read a draft + evaluation log and write an updated draft/log to sandbox — matches `hve-plan-validator`'s scoping (`Read, Write, Edit, Glob, Grep`) — but has no `tools:` line at all.

### SC-04 — Major
**File:** `.claude/agents/hve-pr-reviewer.md:18,23`
**Summary:** Reads an externally-sourced `diff.patch` with no instruction to treat its content as untrusted data rather than executable directives.

Line 18: *"Read this file yourself"* (the diff, which for a real PR can contain an external contributor's arbitrary comment/string text). No language in this file or in `hve-pr-review.md` instructs treating diff/file content as data rather than instructions. A repo-wide grep for guard language (`untrusted`, `prompt injection`, `treat as data`) returns zero hits anywhere in `.claude/` or `CLAUDE.md`. This is the agent most exposed to attacker-controlled input of the 9 in the roster and currently has the least protection against it.

### SC-05 — Minor
**File:** `.claude/agents/hve-researcher.md:43-49`
Same missing-guard class as SC-04 for its WebFetch step, but with limited blast radius: this agent has no Bash/Edit and can only write inside `.claude-hve-tracking/research/subagents/`, so a successful injection could at worst corrupt a research finding a later phase would need to notice, not execute code or leak secrets directly.

---

## Documentation and Operations (DO)

### DO-01 — Minor (cross-reference, not separately tallied)
**File:** `CLAUDE.md:43-44`, `.claude/commands/hve-implement.md:3`
The Command Reference table doesn't mention that `hve-implement.md` accepts `--mode`/`--think` — consistent with FC-02's finding that the flags are dead code; documenting them would have made the dead-flag defect visible sooner. Counted once under FC-02.

### DO-02 — Minor
**File:** `CLAUDE.md:43-44`
Command Reference rows for `/hve-research` and `/hve-plan` omit `--mode`, even though `hve-research.md:19-20` ("`--mode` overrides the difficulty assessment... lightweight = 1 subagent, standard = 2-3, full = 3-5") and `hve-plan.md:43` both actually branch on it. Same omission recurs in `README.md:123-124`.

### DO-03 — Minor
**File:** `CLAUDE.md:47`
Row for `/hve-pr-review` documents `--compact` but omits `--dimension`, which `hve-pr-review.md:3,22,89` implements and `README.md:133,173` both document. Of all the places this review checked, `CLAUDE.md` is the one doc missing a flag its own reference table exists to enumerate.

### DO-04 — Minor
**File:** `CLAUDE.md:50`
Row for `/hve-doc-ops` lists no flags, omitting `--scope` (`hve-doc-ops.md:3,18`), which `README.md:135,177` documents with a usage example.

### DO-05 — Minor
**File:** `docs/reference.md:52-65`
The "Language instruction files" table is missing `javascript.md` and `typescript.md` — both exist in `.claude/instructions/`, are listed in `CLAUDE.md:277-278`, and are in `install.sh`'s instruction-files array. The same omission recurs in `docs/installation.md:97`'s manual-migration instructions.

### DO-06 — Minor
**File:** `docs/reference.md:6-31`
The tracking-folder structure diagram jumps from `doc-ops/` to `sandbox/` with no `friction/` entry, though `CLAUDE.md`'s identical tree includes it and six commands (`hve-research.md:13`, `hve-plan.md:19`, `hve-implement.md:13`, `hve-review.md:13`, `hve-pr-review.md:13`, `hve-challenge.md:13`) actively write to that path via `--friction-log`.

---

## What's solid

- No secret-exposure hits in the repo's own files; the repo's own `.gitignore` correctly lists all five credential patterns CLAUDE.md requires (only the *installer's* propagation of that rule to new projects is broken — SC-01).
- Citation format (plain `file:line`, no markdown links) and confidence markers (`[HIGH]`/`[MEDIUM]`/`[LOW]`) are applied consistently everywhere CLAUDE.md requires them.
- Phase-boundary discipline (research doesn't implement, plan doesn't edit source, review doesn't silently fix) holds throughout — no findings surfaced against it.
- `hve-pr-review.md`'s 8-dimension paired-subagent design (and `--compact` 4-pair mode) is explicitly bounded and was the comparison point that made PS-06's uncapped doc-ops fan-out and RL-04's "reference, don't duplicate" pattern (via `hve-pr-reviewer.md:43`) visible as the better precedent already present in this same repo.
