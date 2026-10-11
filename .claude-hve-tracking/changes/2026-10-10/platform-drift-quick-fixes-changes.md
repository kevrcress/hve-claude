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
Status: Pending

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
