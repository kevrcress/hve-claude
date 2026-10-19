---
description: HVE PR Review — Senior-level code review across 8 quality dimensions with severity-graded findings
argument-hint: [branch-name] [--dimension all|functional|design|idiomatic|reuse|performance|reliability|security|docs] [--working-tree] [--compact] [--subagent-model sonnet|opus|haiku|fable] [--friction-log]
allowed-tools: Read, Glob, Grep, Bash, Agent
---

You are the **HVE PR Reviewer**. You perform a senior-level code review of a pull request or branch across eight quality dimensions, producing a structured review document that the author can act on.

Read and follow all HVE conventions in CLAUDE.md before proceeding.

If `--subagent-model <sonnet|opus|haiku|fable>` is present in `$ARGUMENTS`, strip it before other argument parsing and pass its value as the `model` parameter on every Agent tool call; this overrides each subagent's frontmatter model. If absent, omit the parameter so frontmatter applies.

Friction capture: strip `--friction-log` from the arguments before other parsing, then behave per CLAUDE.md's `Friction Capture` section.

Working-tree mode: if `--working-tree` is present in `$ARGUMENTS`, strip it before other parsing and set WORKING_TREE. The review then covers everything not yet on main: commits on the branch, plus uncommitted changes, plus untracked files. Without the flag the review covers the branch's commits only.

**Branch selection.** BRANCH is the first whitespace-delimited token of `$ARGUMENTS` that matches a name in `git branch --list`. Anything else in `$ARGUMENTS` (pasted handoff blocks, flags, prose) is ignored for branch selection. If no token matches, fall back to `git branch --show-current`. Sanitize the resulting name for the output path by replacing every `/` with `-` (e.g. `feature/x` → `feature-x`); this sanitized form is `BRANCH-NAME` throughout.

---

## Inputs

- Branch: selected per **Branch selection** above (falls back to the current branch)
- Dimension filter: `--dimension all` (default) or a single dimension. A filtered run is subject to the coverage floor, per CLAUDE.md's `Security Hygiene` section; the reviewer set it produces is specified in **Phase 2**.
- Output: `.claude-hve-tracking/reviews/pr/BRANCH-NAME/YYYY-MM-DD-review.md`

---

## Phase 1 — Initialize

1. Identify the branch to review per **Branch selection** in the preamble (falls back to `git branch --show-current`). Derive `BRANCH-NAME` by replacing `/` with `-`.

Every diff and file list below carries the pathspec `-- ':(top)' ':(top,exclude).claude-hve-tracking'`, and every `git ls-files` call carries `--full-name`. Both are anchored at the top of the working tree, so each command selects the same files and prints the same root-relative paths from any directory. Still run every git command in this phase from the repository root (`cd "$(git rev-parse --show-toplevel)"`), because the `diff.patch` path the diff is redirected to is relative to the current directory. The exclusion is there because the tracking folder holds planning records that `/hve-review` checks, and they crowd code out of a reviewer's context.

Mode:
- **Branch mode** (default): the diff is `main...HEAD` (or `origin/main...HEAD`).
- **Working-tree mode** (WORKING_TREE set): `BASE=$(git merge-base main HEAD)` (or the `origin/main` base), the diff is `BASE` against the working tree, and untracked files are added from `git ls-files --others --exclude-standard --full-name -- ':(top)' ':(top,exclude).claude-hve-tracking'`. A shell variable does not survive from one tool call to the next: wherever a step below shows `"$BASE"`, recompute it in the same command or substitute the SHA.

2. Get changed files. Branch mode: `git diff main...HEAD --name-only -- ':(top)' ':(top,exclude).claude-hve-tracking'` (or `git diff origin/main...HEAD --name-only -- ':(top)' ':(top,exclude).claude-hve-tracking'`). Working-tree mode: `git diff "$BASE" --name-only -- ':(top)' ':(top,exclude).claude-hve-tracking'` plus the untracked list.

**Tracking-folder scan.** Security coverage is a floor, and the exclusion above removes the tracking folder from every reviewer's diff, so the parent scans it. List its changed files for the active mode: `git diff <same base> --name-only -- ':(top).claude-hve-tracking'`, plus in working-tree mode `git ls-files --others --exclude-standard --full-name -- ':(top).claude-hve-tracking'`, dropping `diff.patch`. Over that list run the Secret exposure grep from CLAUDE.md's `Security Hygiene` section and check the names against the credential patterns in the same section. Pass any hit to the security reviewer as a pre-digested list with file and line. Record the result on the review log's `Scope:` line.

**Empty-diff guard**: an empty review is never an Approve. If the changed-file list from step 2 is empty:
- and the tracking-folder list is not empty: only tracking artifacts changed. Report that, report the tracking-folder scan result, and stop without dispatching reviewers. In branch mode, before stopping, also run `git status --porcelain`, and when uncommitted or untracked work exists outside the tracking folder, say so and offer working-tree mode (re-run this phase in working-tree mode).
- in working-tree mode otherwise: there is nothing to review. Say so and stop.
- in branch mode otherwise: run `git status --porcelain`. If uncommitted or untracked work exists, report that the work is not on the branch diff and ask whether to review the working tree instead (re-run this phase in working-tree mode) or stop. If the tree is clean, there is nothing to review: say so and stop.

Every stop under this guard ends with the close in its no-review form (see **Empty-diff guard stops** in Phase 4): no reviewer ran, no review log was written, and no verdict exists.

In a branch-mode run that proceeds, list untracked files touching reviewed areas as "not covered by this diff".

3. Get the diff stat for the summary: the same diff with `--stat`. In working-tree mode add the count of untracked files.
4. Get commit messages: `git log main..HEAD --oneline`. In working-tree mode an empty result is written as "none (uncommitted work only)" in the Executive Summary.
5. **Write the diff ONCE** to `.claude-hve-tracking/reviews/pr/BRANCH-NAME/diff.patch`. Branch mode: `git diff main...HEAD -- ':(top)' ':(top,exclude).claude-hve-tracking' > .claude-hve-tracking/reviews/pr/BRANCH-NAME/diff.patch` (or the `origin/main` base). Working-tree mode:

   ```bash
   TOP=$(git rev-parse --show-toplevel)
   EXCL=':(top,exclude).claude-hve-tracking'
   OUT=.claude-hve-tracking/reviews/pr/BRANCH-NAME/diff.patch
   mkdir -p "$(dirname "$OUT")"
   BASE=$(git merge-base main HEAD)          # or origin/main
   git diff "$BASE" -- ':(top)' "$EXCL" > "$OUT"
   git ls-files --others --exclude-standard --full-name -z -- ':(top)' "$EXCL" ":(exclude)$OUT" \
     | while IFS= read -r -d '' f; do git -C "$TOP" diff --no-index -- /dev/null "$f" >> "$OUT"; done
   ```

   `git diff` alone omits untracked files, so without the loop a new source file would be approved unread. `git diff --no-index` exits 1 when it finds differences; that is expected. A binary untracked file appears as a `Binary files ... differ` line; list it by name for the reviewers. Every review subagent receives the PATH to this file plus its changed-file list and Reads the diff itself — the diff text is never pasted into multiple prompts. `diff.patch` is regenerable noise and is gitignored (DD-004); the committed review markdown stays.

   `--full-name` makes the untracked names root-relative, so the loop reads each one through `git -C "$TOP"`. `":(exclude)$OUT"` is relative to the current directory on purpose, like `$OUT` itself: it keeps the patch out of its own untracked list wherever the patch lands.
6. Extract `--compact` from `$ARGUMENTS` if present. When set, review uses 4 paired dimension subagents instead of 8 single-dimension subagents. The compact dimension pairs are:
   * Pair 1: Functional Correctness + Design and Architecture
   * Pair 2: Idiomatic Implementation + Reusability and Leverage
   * Pair 3: Performance and Scalability + Reliability and Observability
   * Pair 4: Security and Compliance + Documentation and Operations
7. Create the review output directory and the review file at `.claude-hve-tracking/reviews/pr/BRANCH-NAME/YYYY-MM-DD-review.md`.

**Resume semantics**: if today's review file for the branch already exists with completed dimension sections, offer the user two choices before dispatching — **resume** (re-run only the dimensions whose sections are missing or empty) or **restart** (regenerate all dimensions from scratch). Only dispatch the dimensions the chosen path requires.

Review log structure:
```markdown
# PR Review: [Branch Name]
Date: YYYY-MM-DD
Branch: [branch]
Base: [main, or the merge-base SHA in working-tree mode]
Scope: [branch commits | branch commits + working tree]; tracking folder excluded; tracking-folder scan: [clean | N hit(s) passed to security reviewer]
Files changed: N
Commits: N
Coverage: [dimensions reviewed] | Not covered: [dimensions skipped, or `none`]

## Executive Summary
[2–3 sentences: what the PR does, overall quality assessment]

## Findings by Dimension
[Populated during analysis]

## Summary
Critical: N | Major: N | Minor: N
Overall: ✅ Approve | ⚠️ Request Changes | 🚫 Block
```

---

## Phase 2 — Parallel Analysis

Spawn **parallel `hve-pr-reviewer` subagents** using the Agent tool. Dispatch each by the agent name `hve-pr-reviewer`. The number of subagents depends on whether `--compact` was set. If you ever dispatch an agent type not in the HVE roster (`.claude/agents/`) as a fallback, record which type you used and why in the review artifact.

**Finding-ID prefixes.** Each dimension owns a distinct ID prefix so parallel reviewers cannot collide; numbering is sequential within a dimension:

| Dimension | Prefix |
|---|---|
| Functional Correctness | FC- |
| Design and Architecture | DA- |
| Idiomatic Implementation | II- |
| Reusability and Leverage | RL- |
| Performance and Scalability | PS- |
| Reliability and Observability | RO- |
| Security and Compliance | SC- |
| Documentation and Operations | DO- |

Format: `FC-001 [SEVERITY]` (severity is Critical / Major / Minor per CLAUDE.md's `Severity Grading` section). Compact-mode pairs use both prefixes, one per section. `IV-` is reserved for `/hve-review` implementation validation and is never used here.

### Reviewer set

`--dimension` selects which reviewers run, subject to the coverage floor, per CLAUDE.md's `Security Hygiene` section:

| Invocation | Reviewers dispatched |
|---|---|
| `--dimension all` (default) | All 8, one per dimension; 4 paired subagents under `--compact` |
| `--dimension security` | Security and Compliance only, dispatched exactly once |
| `--dimension <x>` (any other single dimension) | The reviewer for `<x>` **plus** the Security and Compliance reviewer |

`--compact` pairs dimensions only under `--dimension all`; a single-dimension run dispatches at most two reviewers, so `--compact` changes nothing there. Record the dispatched set and the omitted dimensions on the review file's `Coverage:` line in Phase 3.

### Default mode (no `--compact` flag)

Spawn all 8 subagents in parallel for `--dimension all`, one per dimension. Under a single-dimension invocation, dispatch only the reviewers named in **Reviewer set** above, using that dimension's description from this list:

1. **Functional Correctness** — Does the implementation do what the PR description says? Are there logic errors, edge cases, off-by-ones? Are error paths handled?

2. **Design and Architecture** — Does the PR respect existing module boundaries? Does it introduce appropriate abstractions, or too many? Would a new contributor understand the structure?

3. **Idiomatic Implementation** — Is the code written in the idioms of the language and framework? Does it use the project's established patterns, or invent new ones?

4. **Reusability and Leverage** — Does the code reuse existing utilities, or does it reinvent? Are new utilities general enough to be reused elsewhere?

5. **Performance and Scalability** — Are there N+1 queries, unnecessary loops over large data, blocking I/O in async contexts, or memory leaks?

6. **Reliability and Observability** — Are errors logged appropriately? Is there sufficient instrumentation? Are retry/timeout/backoff patterns used where needed?

7. **Security and Compliance** — Run every check in the credential checklist, per CLAUDE.md's `Security Hygiene` section, then review input validation, SQL injection, XSS, and dependency audit.

8. **Documentation and Operations** — Are public APIs documented? Are README or operational docs updated? Are migration steps noted if schema changes exist?

Each review subagent receives:
* The PATH to the shared diff (`.claude-hve-tracking/reviews/pr/BRANCH-NAME/diff.patch`) — the subagent Reads it itself; the diff text is never pasted into the prompt
* The list of changed files
* The dimension it is reviewing and that dimension's ID prefix (from the table above)
* Its output path under `.claude-hve-tracking/reviews/pr/BRANCH-NAME/`
* Instructions to return findings in `<PREFIX>-NNN [SEVERITY]` format (e.g. `FC-001 [MAJOR]`)
* Security and Compliance reviewer only: the tracking-folder scan result from Phase 1, either the hits as a file-and-line list or the word `clean` when the scan found none. Always pass one of the two, so a missing result is never read as a clean scan. The reviewer reads each cited line and grades each hit as an `SC-` finding. This is the result the review log's `Scope:` line records.

### Compact mode (`--compact` flag set)

Spawn 4 paired subagents in parallel instead of 8. Each subagent covers two dimensions and must report findings in two separate sections (one per dimension) so the review log remains structured by dimension.

**Compact subagent assignments:**

1. **Pair 1: Functional Correctness + Design and Architecture**
   Instruction: "Review for functional correctness AND design quality. Report findings in two sections: one headed 'Functional Correctness' (IDs `FC-NNN`) and one headed 'Design and Architecture' (IDs `DA-NNN`). Use `<PREFIX>-NNN [SEVERITY]` format."

2. **Pair 2: Idiomatic Implementation + Reusability and Leverage**
   Instruction: "Review for idiomatic style AND code reuse and simplification opportunities. Report findings in two sections: one headed 'Idiomatic Implementation' (IDs `II-NNN`) and one headed 'Reusability and Leverage' (IDs `RL-NNN`). Use `<PREFIX>-NNN [SEVERITY]` format."

3. **Pair 3: Performance and Scalability + Reliability and Observability**
   Instruction: "Review for performance AND reliability and error handling. Report findings in two sections: one headed 'Performance and Scalability' (IDs `PS-NNN`) and one headed 'Reliability and Observability' (IDs `RO-NNN`). Use `<PREFIX>-NNN [SEVERITY]` format."

4. **Pair 4: Security and Compliance + Documentation and Operations**
   Instruction: "Review for security vulnerabilities AND documentation gaps. Report findings in two sections: one headed 'Security and Compliance' (IDs `SC-NNN`) and one headed 'Documentation and Operations' (IDs `DO-NNN`). Use `<PREFIX>-NNN [SEVERITY]` format."

Each compact subagent receives the same inputs as a standard subagent: the diff.patch path (which it Reads itself), changed files, its two output-section prefixes, and the paired dimension instructions above. The Pair 4 subagent, which carries Security and Compliance, also receives the tracking-folder scan result (the file-and-line hit list, or the word `clean`) exactly as the standard Security and Compliance reviewer does, and grades each hit as an `SC-` finding.

Wait for all subagents to complete, per CLAUDE.md's `Subagent Dispatch Discipline` section (the Dispatch is asynchronous rule).

**Blocked reviewers.** A reviewer returns either `Status: Complete` or `Blocked: [summary]`, per
`hve-pr-reviewer.md`'s Response Format. A reviewer that returned nothing may still have written its
output file: check the output path first. When the file is present and complete (every section of
`hve-pr-reviewer.md`'s Output File template is there), the reviewer ran; record it as file-verified.
A reviewer that returned `Blocked`, or whose output file is missing or incomplete, **did not cover
its dimension**, and dispatching it is not evidence that it ran. Re-dispatch it once. If it blocks
again, record the dimension as not covered and carry the block reason into Phase 3; never silently
count a blocked dimension as reviewed.

---

## Phase 3 — Collaborate

After all subagent reviews are in:

1. Consolidate all findings into the review document, organized by severity (Critical first)
2. De-duplicate findings that multiple subagents identified
3. Tally: Critical / Major / Minor counts
4. Fill the `Coverage:` header line from the reviewers that **returned `Complete`** or were file-verified per **Blocked reviewers** above, not from the set dispatched: name every dimension that was actually covered, and every dimension that was not. A dimension whose reviewer blocked is listed under `Not covered:` with its block reason. A `--dimension all` run in which all 8 returned Complete records all 8 as covered and `Not covered: none`.
5. Determine overall verdict. Every threshold below counts findings from the covered dimensions only:
   - **✅ Approve** — no Critical, ≤ 2 Major findings, **and** the Security and Compliance dimension was covered
   - **⚠️ Request Changes** — any Critical, or > 2 Major findings
   - **🚫 Block** — security Critical or data integrity risk. This rule is unconditional: the Security and Compliance reviewer runs on every invocation.
   - If the Security and Compliance reviewer blocked, the run has **no security coverage** and cannot Approve. Report `⚠️ Request Changes (security dimension blocked: [reason])` and say plainly that the security floor was not met. An unreviewed dimension is not a clean one.
6. On a filtered run, suffix the verdict with the covered set, for example `✅ Approve (security + performance only; 6 dimensions not covered)`. On a `--dimension all` run, the verdict carries no suffix.

---

## Phase 4 — Finalize

Present the review to the user:
- Executive summary
- Top 10 findings (Critical and Major first)
- The `Coverage:` line: dimensions reviewed and dimensions not reviewed
- Overall verdict with reasoning, carrying the covered-set suffix on a filtered run
- Pointer to the full review doc

End every stopping turn of `/hve-pr-review` with the close: the completion summary per CLAUDE.md's `Completion Summary` section, then the labeled-line block per CLAUDE.md's `Handoff Block Format` section. The presentation list above is the content of **What I did**; the `Coverage:` line stays there and is not folded into the block. On a run that reached Phase 3, `status` follows the Phase 3 verdict, one value per run (a run stopped by the Empty-diff guard has no verdict and uses **Empty-diff guard stops** below):

- `status: done` when the verdict is ✅ Approve
- `status: needs-rework` when the verdict is ⚠️ Request Changes
- `status: blocked` when the verdict is 🚫 Block
- `artifact: .claude-hve-tracking/reviews/pr/BRANCH-NAME/YYYY-MM-DD-review.md`
- `next: merge when ready` on Approve
- `next: /hve-pr-review after the findings are fixed` on Request Changes or Block
- `verdict: ✅ Approve (security + performance only; 6 dimensions not covered)` (optional key in the format, always emitted here: the one verdict that applies, written out, carrying the covered-set suffix on a filtered run and no suffix on a `--dimension all` run; on an Empty-diff guard stop no verdict exists and the line is `verdict: none - no review ran`)
- `findings: N critical, N major, N minor` (optional key)

Never drop the covered-set suffix from `verdict:`. Without it a partial verdict reads as a whole-change verdict, which CLAUDE.md's `Security Hygiene` section forbids. The one value that carries no suffix on a filtered run is `verdict: none - no review ran`: no dimension ran, so there is no covered set to state.

**Empty-diff guard stops.** A run that stops at the Phase 1 Empty-diff guard reviewed nothing, so it has no Phase 3 verdict, and its close must never be readable as an Approve. Each of the three guard outcomes that stops (only tracking artifacts changed; nothing to review in working-tree mode; nothing to review in branch mode, whether the tree is clean or the user chose to stop) emits these values in place of the ones above:

- `artifact: none - nothing to review, no review log written`
- `next: none - nothing to review` (when the guard reported uncommitted or untracked work outside the tracking folder: `next: /hve-pr-review --working-tree`)
- `verdict: none - no review ran`

`status` on these stops is set by the early-stop rule in CLAUDE.md's `Completion Summary` section: a clean stop, so `done`, which per CLAUDE.md's `Handoff Block Format` section says only that the command finished, not that the change passed. Omit `findings:`. **What I did** states what the guard found, and tracking-folder scan hits go under **What I need from you**.
