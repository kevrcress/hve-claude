# Changes Log: Platform-Drift and Friction Quick Fixes
Date: 2026-10-10
Plan: .claude-hve-tracking/plans/2026-10-10/platform-drift-quick-fixes-plan.md
Details: .claude-hve-tracking/details/2026-10-10/platform-drift-quick-fixes-details.md
Branch: fix/platform-drift-quick-fixes (cut from main at f96e34f, after PR #4 merged)
Mode: standard (from `--mode standard`; the plan header requires it because phases share files)
Status: In Progress

Note on dates: the folder date is the local date (2026-10-10, US Pacific). Timestamps below are UTC and read 2026-10-11.

## Test Baseline

Captured 2026-10-11T00:50:30Z at commit 42fb86a, before any phase ran. Suites were redirected to log files and the exit code read from `$?`, not piped.

- `bash tests/run-drift-tests.sh > <scratchpad>/drift-baseline.log 2>&1; echo "drift rc=$?"`: rc=0, `Results: 250 passed, 0 failed`
- `bash tests/run-install-tests.sh > <scratchpad>/install-baseline.log 2>&1; echo "install rc=$?"`: rc=0, `Results: 69 passed, 0 failed`
- Already-failing tests: none.

## Phases

### Phase 1: Research-phase shell policy and consolidation rules
Status: Complete
Started: 2026-10-11T00:50:58Z
Completed: 2026-10-11T00:51:48Z

#### Files Modified
- `.claude/commands/hve-research.md:49`: orientation step rewritten. Glob and Grep when exposed, otherwise one read-only shell pass, otherwise targeted Read; commands recorded on the `Method:` line (details 1.1)
- `.claude/commands/hve-research.md:75`: **Tool boundary** paragraph rewritten. Parent read-only shell in two places only (Phase 1 orientation, Phase 3 re-check); `hve-researcher` still has no Bash (details 1.2, Decision D4)
- `.claude/commands/hve-research.md:86`: trust rule extended with the existence, negative-claim, and disagreement exception (details 1.4, F14)
- `.claude/commands/hve-research.md:97`: new `Method:` line in the consolidated-document header template, at column 0, after `Confidence:` (details 1.3)
- `.claude/commands/hve-review.md:29`: Inputs item 3 now reads the path named by the plan's `Research:` header instead of globbing by slug (details 1.6)
- `.claude/commands/hve-review.md:38`: Phase 1 step 1 takes the research path from the plan's `Research:` line (details 1.6)
- `.claude/commands/hve-review.md:99`: **Context discipline** paragraph gains the exception for existence or negative claims and validator disagreement; a falsified finding stays in the log under **Contested severity** and out of the tally (details 1.5, F14)

`git diff --stat -- .claude/` after the edits: 2 files changed, 7 insertions(+), 6 deletions(-). No other tracked file changed.

#### Steps Completed
- [x] Step 1.1: Orientation step rewritten per details 1.1, at `.claude/commands/hve-research.md:49`. Frontmatter `allowed-tools` at :4 left unchanged, per the plan's assumption.
- [x] Step 1.2: **Tool boundary** paragraph rewritten per details 1.2, at `.claude/commands/hve-research.md:75`
- [x] Step 1.3: `Method: [` template line added after `Confidence:`, at `.claude/commands/hve-research.md:97`
- [x] Step 1.4: Trust rule extended with the exception, at `.claude/commands/hve-research.md:86`
- [x] Step 1.5: Exception appended to the last sentence of the Context discipline paragraph, at `.claude/commands/hve-review.md:99`
- [x] Step 1.6: `Research:` header rule added in both places, at `.claude/commands/hve-review.md:29` and `.claude/commands/hve-review.md:38`
- [x] Step 1.7: Recorded no-change. `.claude/agents/hve-researcher.md:30` reviewed and left as is. Reason: the agent's frontmatter (`.claude/agents/hve-researcher.md:6`) lists `tools: Read, Write, Glob, Grep, WebFetch`, so it has no Bash to fall back to, and its Glob-plus-Read fallback stays correct. The shell policy this phase adds applies to the parent only. `git diff --stat -- .claude/agents/` printed nothing. The plan's assumption that a subagent listing Glob and Grep receives both stays [MEDIUM]; it was not tested in this phase.
- [x] Step 1.8 (guard): carrier grep run as written; two survivors, both expected. Output below.
- [x] Step 1.9 (guard): drift suite rc=0, `Results: 250 passed, 0 failed`. Detail below.

#### Guard Step 1.8 output

Command: `grep -rnE "never add Bash|read-only by design|Do not add Bash" .claude/ docs/ README.md CLAUDE.md CONTRIBUTING.md` (grep rc=0)

```text
.claude/agents/hve-researcher.md:30:2. Use Grep to search for key symbols, function names, or patterns relevant to the question. If no standalone Grep tool is available in this session, fall back to Glob (broad filename/pattern matching) plus targeted Read calls for content search — do not reach for Bash to work around this; this agent stays read-only by design regardless of what the harness happens to expose.
CLAUDE.md:202:**Shell stays in the parent.** HVE subagents are read-only by design; most have no Bash. The parent session runs all git/shell commands and passes pre-digested results (short excerpts, counts, file lists) into subagent prompts. Never delegate a step requiring command execution to a subagent without checking its tool list; a validator without Bash will silently downgrade to static inference.
```

Survivors are exactly the two the plan expects (`.claude/agents/hve-researcher.md:30`, `CLAUDE.md:202`). The same grep before the edits returned four hits; the two extra were `.claude/commands/hve-research.md:49` and `:75`, both rewritten by Steps 1.1 and 1.2. No missed carrier.

#### Guard Step 1.9 output

```text
$ bash tests/run-drift-tests.sh > "$TMPDIR/drift-p1.log" 2>&1; echo "rc=$?"
rc=0
$ tail -3 "$TMPDIR/drift-p1.log"
[  OK  ] Test 16: credential-pattern surfaces agree with CLAUDE.md

Results: 250 passed, 0 failed
```

Log path: `/var/folders/t2/lgmxzs012z19716my6ky1hdh0000gn/T//drift-p1.log` (`$TMPDIR/drift-p1.log`). `grep -c "FAIL"` on the log printed 0. Matches the baseline (rc=0, 250 passed, 0 failed).

Tests: 250 passed, 0 failed

#### Success Criteria

```text
$ grep -c "never add Bash" .claude/commands/hve-research.md
0
$ grep -c "Do not add Bash" .claude/commands/hve-research.md
0
$ grep -c "^Method: \[" .claude/commands/hve-research.md
1
$ grep -c "Exception:" .claude/commands/hve-research.md
1
$ grep -c "Exception:" .claude/commands/hve-review.md
1
$ grep -c "header names a path" .claude/commands/hve-review.md
1
```

Drift suite exits 0: see Guard Step 1.9 output above. All six criteria met. Before the edits the last four greps printed 0.

#### Issues Encountered
- No blocker. Every anchor in details 1.1 to 1.6 was found once, at the line numbers the plan cites.
- Wording: the replacement text from the details file was used verbatim. Two joins needed a period that the details text does not show, because the anchored list items ended without one: `.claude/commands/hve-research.md:86` (`...citations. Exception:`) and `.claude/commands/hve-review.md:29` (`...TASK-SLUG.md`. When the plan's...`). Punctuation only; meaning unchanged.
- Em-dashes: `git diff -U0` on the two files, filtered to added lines, shows one em-dash, at `.claude/commands/hve-review.md:99`. It is in the paragraph's existing text (after `Read every validation output file in full`), carried on the same line as the appended sentences. The appended prose contains none.
- Process note: the six text edits (Steps 1.1 to 1.6) were applied in one batch and logged together afterwards, not logged one step at a time. The guard steps ran after all six.
- Not verified here: that Bash is reachable from `/hve-research` while the frontmatter `allowed-tools` omits it. The plan carries this as [MEDIUM]; no live `/hve-research` run was made in this phase. Step 1.1's third branch (targeted Read) covers the case where the shell call is denied.
- Instructions files read before editing: `.claude/instructions/markdown.md`, `.claude/instructions/writing-style.md`.

---

### Phase 2: Subagent dispatch and validator template fixes
Status: Complete
Started: 2026-10-11T00:54:22Z
Completed: 2026-10-11T00:55:45Z

#### Files Modified
- `CLAUDE.md:204`: new **Dispatch is asynchronous.** paragraph in `Subagent Dispatch Discipline`, between the "Shell stays in the parent" paragraph (:202) and the "If you dispatch an agent type" paragraph (now :206). Text verbatim from details 2.1
- `tests/run-drift-tests.sh:577`: new `CANONICAL_BLOCK_SPECS` row `'dispatch_async|1|identical|**Dispatch is asynchronous.**'`, after the `shell_stays_in_parent` row (:576), same two-space indent and single quotes
- `.claude/commands/hve-research.md:77`: `Wait for all subagents to complete.` replaced with the pointer sentence (details 2.3)
- `.claude/commands/hve-pr-review.md:147`: same pointer sentence (details 2.4)
- `.claude/commands/hve-pr-review.md:149-156`: **Blocked reviewers** paragraph reworded. A reviewer that returned nothing gets its output path checked first; a present and complete file is recorded as file-verified; `Blocked`, or a missing or incomplete file, means the dimension was not covered (details 2.4, F04)
- `.claude/commands/hve-pr-review.md:167`: Coverage rule (Phase 3 item 4) now counts reviewers that returned `Complete` or were file-verified (details 2.4)
- `.claude/agents/hve-rpi-validator.md:82`: grading line added under the template's `## Findings` heading (details 2.5)
- `.claude/agents/hve-rpi-validator.md:84`: `### RV-001 [CRITICAL]` is now `### RV-001 [SEVERITY]`
- `.claude/agents/hve-implementation-validator.md:120-123`: the two hardcoded example headings (`IV-001 [ARCHITECTURE] [MAJOR]`, `IV-002 [SECURITY] [CRITICAL]`) replaced by the grading line and one generic `### IV-001 [DIMENSION] [SEVERITY]` block (details 2.5)

`git diff --stat -- . ':!.claude-hve-tracking'` after the edits: 6 files changed, 17 insertions(+), 11 deletions(-). Those six are the files the phase names; no other tracked file outside the tracking folder changed. `~/.claude/CLAUDE.md` was not edited (`grep -c "Dispatch is asynchronous" ~/.claude/CLAUDE.md` prints 0).

#### Steps Completed
- [x] Step 2.1: **Dispatch is asynchronous.** paragraph added, at `CLAUDE.md:204`. Opens with the exact bold form, period inside the bold.
- [x] Step 2.2: `dispatch_async` row added to `CANONICAL_BLOCK_SPECS`, at `tests/run-drift-tests.sh:577`. `bash -n tests/run-drift-tests.sh` rc=0.
- [x] Step 2.3: pointer sentence in place, at `.claude/commands/hve-research.md:77`. Plain words, no bold form.
- [x] Step 2.4: three edits in `.claude/commands/hve-pr-review.md`: pointer sentence at :147, **Blocked reviewers** reworded at :149-156, Coverage rule extended at :167.
- [x] Step 2.5: `[SEVERITY]` placeholder and grading line at `.claude/agents/hve-rpi-validator.md:82` and :84; generic block at `.claude/agents/hve-implementation-validator.md:120-123`. The IV-002 check came back clean (see Issues Encountered), so one generic block was kept, not two.
- [x] Step 2.6 (guard): drift suite rc=0, `Results: 252 passed, 0 failed`. Detail below.

#### Guard Step 2.6 output

```text
$ bash tests/run-drift-tests.sh > "$TMPDIR/drift-p2.log" 2>&1; echo "rc=$?"
rc=0
$ tail -3 "$TMPDIR/drift-p2.log"
[  OK  ] Test 16: credential-pattern surfaces agree with CLAUDE.md

Results: 252 passed, 0 failed
$ grep -n "dispatch_async\|FAIL" "$TMPDIR/drift-p2.log"
172:    [pass] test10: dispatch_async carrier count: 1 file(s) carry the block (expected 1)
173:    [pass] test10: dispatch_async CLAUDE is canonical: reference occurrence
```

Log path: `/var/folders/t2/lgmxzs012z19716my6ky1hdh0000gn/T//drift-p2.log` (`$TMPDIR/drift-p2.log`). `grep -c "FAIL"` on the log printed 0. The count rose from the baseline 250 to 252: the new row adds two assertions (carrier count, canonical reference). The suite was run twice, once after the edits and once more after a line re-wrap in `.claude/commands/hve-pr-review.md`; both runs gave rc=0 and 252 passed, 0 failed. The output above is from the second run, which is the state on disk.

Tests: 252 passed, 0 failed

#### Success Criteria

```text
$ grep -c "Dispatch is asynchronous" CLAUDE.md
1
$ grep -c "Dispatch is asynchronous rule" .claude/commands/hve-research.md
1
$ grep -c "Dispatch is asynchronous rule" .claude/commands/hve-pr-review.md
1
$ grep -cE "\[(CRITICAL|MAJOR)\]" .claude/agents/hve-rpi-validator.md .claude/agents/hve-implementation-validator.md
.claude/agents/hve-implementation-validator.md:0
.claude/agents/hve-rpi-validator.md:0
```

Drift suite exits 0 with the `dispatch_async` row passing: see Guard Step 2.6 output above. All four criteria met.

Extra check for the Test 10 constraint, not in the plan's list:

```text
$ grep -c '\*\*Dispatch is asynchronous\.\*\*' .claude/commands/hve-research.md .claude/commands/hve-pr-review.md CLAUDE.md
.claude/commands/hve-research.md:0
.claude/commands/hve-pr-review.md:0
CLAUDE.md:1
```

#### Issues Encountered
- No blocker. Every anchor in details 2.1, 2.3, 2.4, and 2.5 was found once. Line numbers matched the plan except `.claude/commands/hve-pr-review.md`, where the Coverage rule moved from :164 to :167 because this phase's own rewording of the paragraph above it added three lines.
- IV-002 check (Step 2.5): `grep -n "IV-00"` on `.claude/agents/hve-implementation-validator.md` before the edit returned :91, :120, :123 only. Nothing after the template refers to `IV-002` by number, so one generic block replaced both examples. `CLAUDE.md:142` still names `IV-002` in the Finding ID format line; that describes the numbering sequence, not this template, and was left alone.
- Wording: replacement text from the details file was used verbatim. The only liberty is line wrapping: the **Blocked reviewers** paragraph in `.claude/commands/hve-pr-review.md` is hard-wrapped at about 100 columns, so the new sentences were wrapped to match and the unchanged tail of the paragraph (`If it blocks again ... as reviewed.`) was re-flowed across the line breaks. Its words are unchanged.
- Placement of the grading line in `.claude/agents/hve-rpi-validator.md`: directly under `## Findings` with no blank line between, matching how the same template writes `## Unlisted Changes` followed by its bracketed note.
- Em-dashes: `git diff -U0` outside the tracking folder, filtered to added lines, contains zero em-dashes.
- Observed, not changed (outside this phase's anchors): `.claude/agents/hve-implementation-validator.md:91` (the Finding Structure block) writes the heading as `IV-001 [CATEGORY] [SEVERITY]`, while the Output File template now reads `[DIMENSION] [SEVERITY]` as the details file specifies. Two names for the same slot in one file. Minor; a later phase or sweep can align them.
- Observed, not changed (outside this phase's file list): `.claude/commands/hve.md:69` (`Wait for all to complete`) and `.claude/commands/hve-review.md:97` (`Wait for all validators to complete.`) carry no pointer to the new rule. They are still covered by it through CLAUDE.md, per the plan's Step 2.1 assumption, which stays [MEDIUM]: this phase did not enumerate the opening line of all nine dispatching commands.
- Not verified here: `~/.claude/CLAUDE.md` does not carry the new paragraph until `./install.sh --global` is re-run. This phase edits the repo-root `CLAUDE.md` only, as instructed.
- ShellCheck was not run on `tests/run-drift-tests.sh`; the change is one array row copied from its neighbour's shape, and `bash -n` passed.
- Instructions files read before editing: `.claude/instructions/markdown.md`, `.claude/instructions/writing-style.md`, `.claude/instructions/bash.md`.

#### Discrepancies & Decisions
- DR-001: the details file (2.5) named the template slot `[DIMENSION]`, but `.claude/agents/hve-implementation-validator.md:91` already calls the same slot `[CATEGORY]`. The implementor applied the details text as written and flagged the mismatch.
- DD-001 (2026-10-10, parent): renamed the new template heading and grading line to `[CATEGORY]` so the file uses one name. Two-word edit in the same file, made by the parent after the implementor returned; drift suite re-run by the parent afterwards (see the parent test line below).

Parent re-run after DD-001: `bash tests/run-drift-tests.sh > <scratchpad>/drift-p2-parent.log 2>&1`, rc=0, `Results: 252 passed, 0 failed`

---

### Phase 3: PR-review diff correctness (F08, F09, F11) and review file list
Status: Pending

---

### Phase 4: Global-install correctness (instruction paths, ignore rule)
Status: Pending

---

### Phase 5: Shipped examples and tracking-tree note
Status: Pending

---

### Phase 6: Full verification
Status: Pending

---
