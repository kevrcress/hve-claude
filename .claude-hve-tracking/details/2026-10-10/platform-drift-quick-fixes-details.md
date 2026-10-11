# Implementation Details: Platform-Drift and Friction Quick Fixes

Date: 2026-10-10
Task slug: platform-drift-quick-fixes
Plan: .claude-hve-tracking/plans/2026-10-10/platform-drift-quick-fixes-plan.md
Revision: v2 (2026-10-10), matching plan v2. Section numbers follow plan step numbers.

Replacement text for each plan step. Line numbers are as of commit ba369fd; re-locate by the quoted anchor text if they have shifted. The "Replace with" blocks are the intended wording. The implementor may fix a typo or a line wrap, but not the meaning, and must not change the punctuation of any phrase a test matches (called out where it applies). New prose uses no em-dashes; existing em-dashes in untouched text stay.

## Phase 1

### 1.1 hve-research.md:49 (orientation step)

Anchor: `2. Use Glob and Grep to do a quick orientation of the codebase`

Replace the whole step with:

```
2. Do a quick orientation of the codebase (entry points, relevant modules, config files). Use Glob and Grep when the session exposes them. Current Claude Code may omit both from the parent session; when it does, run one read-only shell pass instead: `ls`, `find`, `grep -n`, `wc`, `git log`, `git blame`, `git show`, `git diff --stat`. No writes, no installs, no network, no test or build runs. When neither search tools nor shell are available (for example a shell call is denied), orient with targeted Read calls on known paths. Record what you ran on the research document's `Method:` line.
```

### 1.2 hve-research.md:75 (Tool boundary)

Anchor: `**Tool boundary.** This command's allowed-tools are`

Replace the whole paragraph with:

```
**Tool boundary.** The research phase is read-only. The parent may run read-only shell commands in two places only: the Phase 1 orientation pass, which may include git-history evidence a research question needs (blame, log, diff across commits), and the Phase 3 re-check of existence and negative claims. Shell stays in the parent, per CLAUDE.md's `Subagent Dispatch Discipline` section: the `hve-researcher` subagent has no Bash, so never delegate a shell-dependent question to it; run the command in the parent and pass the result into the subagent prompt as a short excerpt, count, or file list. Anything that needs a write, an install, a build, or a test run is flagged as an open question for a later phase. Every shell command the parent ran is listed on the research document's `Method:` line.
```

### 1.3 hve-research.md:96 (header template)

Anchor: `Confidence: [HIGH/MEDIUM/LOW] overall`

Insert one line directly after it, inside the template. The line must start at column 0 with `Method: [` (a success criterion greps for it):

```
Method: [N researcher subagent(s); each parent shell command run, or "no parent shell"]
```

### 1.4 hve-research.md:86 (trust rule, F14)

Anchor: `2. Apply **context discipline** to the layer BELOW them`

Append to the same list item:

```
 Exception: an existence or negative claim ("no X exists", "file Y is absent", "nothing references Z") and any claim on which two subagent artifacts disagree. Re-check each of those against the working tree yourself, with one Read or one read-only listing, before it enters the consolidated document, and note the re-check on the `Method:` line.
```

### 1.5 hve-review.md:99 (trust sentence, F14)

Anchor: `do not re-open the source files those validations cite; trust their`

Append after that sentence, same paragraph:

```
 Exception: a finding that rests on an existence or negative claim ("the file is missing", "no test covers this"), and any finding on which two validators disagree. Re-check those against the working tree before they enter the review log. A finding the re-check falsifies is not deleted: keep it in the log with the evidence, handle it under the **Contested severity** rule in Phase 4, and leave it out of the tally.
```

### 1.6 hve-review.md:29 and :38 (Research header)

At :29, anchor `3. **Research** (optional): most recent`. Append:

```
 When the plan's `Research:` header names a path, read that file instead of globbing by slug; one research document can feed several plans.
```

At :38, anchor `1. Read the plan and changes log (required); read the research and details documents if present.` Insert after that first sentence:

```
 Take the research path from the plan's `Research:` line when it gives one.
```

(The two sentences are worded differently on purpose so `grep -c "header names a path"` counts one.)

## Phase 2

### 2.1 CLAUDE.md, Subagent Dispatch Discipline

Anchor: the paragraph starting `**Shell stays in the parent.**` (:202). Insert a new paragraph after it, before `If you dispatch an agent type not in the HVE roster`. The opening `**Dispatch is asynchronous.**` must be exact, period inside the bold (Test 10 row):

```
**Dispatch is asynchronous.** Subagents may run in the background and report by notification. Wait for every dispatched subagent to finish before consolidating. A completion notification proves only that the agent stopped: read its artifact for the result, and never report a test or gate outcome from the notification alone. A subagent that died, timed out, or returned nothing may still have written its artifact, so check the output path before re-dispatching. An artifact is complete when every section of that agent's output template is present; re-dispatch a read-only agent only when its file is missing or incomplete. For an implementor, never re-dispatch blind: read its changes-log section and resume from the first step not recorded as done.
```

This text is inside the HVE block that `install.sh` merges into consumer CLAUDE.md files.

### 2.3 hve-research.md:77

Replace `Wait for all subagents to complete.` with (no bold, no period after "asynchronous"):

```
Wait for all subagents to complete, per CLAUDE.md's `Subagent Dispatch Discipline` section (the Dispatch is asynchronous rule).
```

### 2.4 hve-pr-review.md:147-153 and :164

Replace :147 with the same sentence as 2.3.

In the **Blocked reviewers** paragraph, replace from `A reviewer that returned \`Blocked\`, returned nothing, or` through `Re-dispatch it once.` with:

```
A reviewer that returned nothing may still have written its output file: check the output path first. When the file is present and complete (every section of `hve-pr-reviewer.md`'s Output File template is there), the reviewer ran; record it as file-verified. A reviewer that returned `Blocked`, or whose output file is missing or incomplete, **did not cover its dimension**, and dispatching it is not evidence that it ran. Re-dispatch it once.
```

Keep the rest of the paragraph unchanged.

At :164, anchor `4. Fill the \`Coverage:\` header line from the reviewers that **returned \`Complete\`**`. Insert after `**returned \`Complete\`**`:

```
 or were file-verified per **Blocked reviewers** above
```

### 2.5 Validator finding templates

`.claude/agents/hve-rpi-validator.md:83`: replace `### RV-001 [CRITICAL]` with `### RV-001 [SEVERITY]`. Under the `## Findings` heading inside the same template, add:

```
[One block per finding. SEVERITY is CRITICAL, MAJOR, or MINOR per CLAUDE.md's `Severity Grading` section, graded on that finding's own evidence. Write "No findings." when there are none.]
```

`.claude/agents/hve-implementation-validator.md:120-123`: replace the two example headings and their `...` bodies

```
### IV-001 [ARCHITECTURE] [MAJOR]
...

### IV-002 [SECURITY] [CRITICAL]
...
```

with

```
[One block per finding. DIMENSION is the dimension name; SEVERITY is CRITICAL, MAJOR, or MINOR per CLAUDE.md's `Severity Grading` section, graded on that finding's own evidence. Write "No findings." when there are none.]

### IV-001 [DIMENSION] [SEVERITY]
...
```

Before editing, read ten lines either side in that file; if a later section refers to `IV-002` by number, keep a second generic block.

## Phase 3

### 3.1 The diff recipe (prototype first)

All Phase 1 git commands of `/hve-pr-review` run from the repository root. The recipe never stages anything, so a user's staged changes are untouched.

```bash
cd "$(git rev-parse --show-toplevel)"
EXCL=':(exclude).claude-hve-tracking'
OUT=.claude-hve-tracking/reviews/pr/BRANCH-NAME/diff.patch
mkdir -p "$(dirname "$OUT")"
BASE=$(git merge-base main HEAD)          # or origin/main
git diff "$BASE" -- . "$EXCL" > "$OUT"
git ls-files --others --exclude-standard -z -- . "$EXCL" \
  | while IFS= read -r -d '' f; do git diff --no-index -- /dev/null "$f" >> "$OUT"; done
```

`git diff --no-index` exits 1 when it finds differences; that is expected. A binary untracked file appears as a `Binary files ... differ` line; list it by name for the reviewers.

### 3.2 Frontmatter and argument parsing

At :3, insert `[--working-tree] ` into `argument-hint` before `[--compact]`.

Insert after the friction-capture line (:13):

```
Working-tree mode: if `--working-tree` is present in `$ARGUMENTS`, strip it before other parsing and set WORKING_TREE. The review then covers everything not yet on main: commits on the branch, plus uncommitted changes, plus untracked files. Without the flag the review covers the branch's commits only.
```

### 3.3 Phase 1 steps 2 to 5, rewritten once for both modes

Replace steps 2 to 5 and the guard between them (:30-36) with the following, keeping step numbering and the existing sentence about every subagent reading the PATH. `MAIN` stands for `main` or `origin/main` as today.

```
Run every git command in this phase from the repository root (`cd "$(git rev-parse --show-toplevel)"`). Every diff below carries the pathspec `-- . ':(exclude).claude-hve-tracking'`, written here as EXCL: the tracking folder holds planning records that `/hve-review` checks, and they crowd code out of a reviewer's context.

Mode:
- **Branch mode** (default): the diff is `MAIN...HEAD`.
- **Working-tree mode** (WORKING_TREE set): `BASE=$(git merge-base MAIN HEAD)`, the diff is `BASE` against the working tree, and untracked files are added from `git ls-files --others --exclude-standard EXCL`.

2. Get changed files. Branch mode: `git diff MAIN...HEAD --name-only EXCL`. Working-tree mode: `git diff "$BASE" --name-only EXCL` plus the untracked list.

[security-floor step from 3.4 goes here, then the empty-diff guard from 3.5]

3. Get the diff stat for the summary: the same diff with `--stat`. In working-tree mode add the count of untracked files.
4. Get commit messages: `git log MAIN..HEAD --oneline`. In working-tree mode an empty result is written as "none (uncommitted work only)".
5. **Write the diff ONCE** to `.claude-hve-tracking/reviews/pr/BRANCH-NAME/diff.patch`. Branch mode: `git diff MAIN...HEAD EXCL > [that path]`. Working-tree mode:
[the bash block from 3.1, without its first line]
`git diff` alone omits untracked files, so without the loop a new source file would be approved unread. [existing sentences about subagents receiving the PATH, and the gitignore note, unchanged]
```

When writing the real text, spell the pathspec out in each command instead of the placeholder `EXCL` (the success criterion counts at least four occurrences of `exclude).claude-hve-tracking`), and place the pathspec before the `>` redirect.

### 3.4 Security floor for the excluded folder

Insert after step 2, before the guard:

```
**Tracking-folder scan.** Security coverage is a floor, and the exclusion above removes the tracking folder from every reviewer's diff, so the parent scans it. List its changed files for the active mode: `git diff <same base> --name-only -- .claude-hve-tracking`, plus in working-tree mode `git ls-files --others --exclude-standard -- .claude-hve-tracking`, dropping `diff.patch`. Over that list run the Secret exposure grep from CLAUDE.md's `Security Hygiene` section and check the names against the credential patterns in the same section. Pass any hit to the security reviewer as a pre-digested list with file and line. Record the result on the review log's `Scope:` line.
```

### 3.5 Empty-diff guard (F08)

Replace the paragraph at :32 with:

```
**Empty-diff guard**: an empty review is never an Approve. If the changed-file list from step 2 is empty:
- and the tracking-folder list is not empty: only tracking artifacts changed. Report that, report the tracking-folder scan result, and stop without dispatching reviewers.
- in working-tree mode otherwise: there is nothing to review. Say so and stop.
- in branch mode otherwise: run `git status --porcelain`. If uncommitted or untracked work exists, report that the work is not on the branch diff and ask whether to review the working tree instead (re-run this phase in working-tree mode) or stop.
In a branch-mode run that proceeds, list untracked files touching reviewed areas as "not covered by this diff".
```

### 3.6 Review log template

In the template at :47-55, replace `Base: main` with `Base: [main, or the merge-base SHA in working-tree mode]`, and insert after it:

```
Scope: [branch commits | branch commits + working tree]; tracking folder excluded; tracking-folder scan: [clean | N hit(s) passed to security reviewer]
```

Leave `Commits: N` and add nothing else; step 4's "none (uncommitted work only)" wording goes in the Executive Summary when it applies.

### 3.7 hve-review.md:83, :95 and hve-rpi-validator.md:23

At hve-review.md:83, append to the sentence:

```
 When the base is `HEAD` (uncommitted work), `git diff` omits untracked files: also run `git ls-files --others --exclude-standard -- . ':(exclude).claude-hve-tracking'` from the repository root and append its output, leaving out any file you can see predates this task.
```

At :95, change the parenthetical to end: `or \`HEAD\` for uncommitted work, with untracked files appended per the step above)`.

At `.claude/agents/hve-rpi-validator.md:23`, read the changed-file-list input description and add the clause `(for uncommitted work it includes untracked files outside the tracking folder)`.

### 3.8 Flag documentation

`.claude/prompts/pull-request.md`, after the `--compact` bullet (:32). Use a colon; do not copy the neighbouring bullets' em-dash:

```
- `--working-tree`: review everything not yet on main, including uncommitted and untracked work
```

`README.md:134`, append to the `/hve-pr-review` row's description: ` Pass \`--working-tree\` to include uncommitted and untracked work.`

`README.md`, after the `--compact` example line (:184), matching its column alignment:

```
/hve-pr-review --working-tree           # include uncommitted and untracked work
```

Do not touch the cross-cutting flags table at README.md:141-147.

## Phase 4

### 4.1 CLAUDE.md Instructions Reference

Insert above the table (after `Before implementing in a specific language or tool, read the relevant conventions file:`):

```
The paths below are relative to the project root for a project install. Under a global install the same files are in `~/.claude/instructions/`. Look in the project first, then there.
```

Replace the fallback sentence (:286) with:

```
If no instructions file exists for the language at hand in either location, do not block: follow the dominant conventions of the existing code in the repo, and note the missing instructions file in the changes log. A file is missing only after both the project path and `~/.claude/instructions/` have been checked.
```

### 4.2 Primary carriers

`.claude/commands/hve-implement.md:42`, after `(e.g., \`.claude/instructions/python.md\`)`, and `.claude/agents/hve-phase-implementor.md:31`, after `for the language being implemented`: insert

```
 (under a global install the same file is in `~/.claude/instructions/`; check both before treating it as missing)
```

Carriers left unchanged (list for the changes log): hve-implement.md:111; hve-phase-implementor.md:19, :42, :132; hve-git-commit.md:9, :36; hve-git-merge.md:9; hve-prompt-builder.md:30; hve-prompt-refactor.md:59; hve-doc-ops.md:27; hve-prompt-updater.md:32.

### 4.3 to 4.5 The ignore rule

Rule string, identical everywhere: `.claude-hve-tracking/reviews/pr/**/diff.patch`

This repo's own `.gitignore:5` already has it; no change there.

Literal copies: add the rule as a third line beside the two existing rules (inside the fence where they are fenced, as a third `echo` in install.sh's printout, in the comma list at docs/installation.md:157).

Prose copies (three paste-to-install prompts): each says `Add the .claude-hve-tracking subagents and sandbox paths to my .gitignore`. Reword to:

```
Add the .claude-hve-tracking subagents and sandbox paths and the reviews/pr diff.patch rule to my .gitignore
```

keeping each file's own line wrapping and the rest of its sentence. `tests/run-prompt-new-install.sh:91-93` is a heredoc: edit it in the same step as the assertion beside :147, or the test pastes a prompt that asks for two rules and asserts three.

`CLAUDE.md:382`: change `Alongside these two rules` to `Alongside these rules`.

Test 5 (global printout): add `assert_output_contains "${output}" ".claude-hve-tracking/reviews/pr/**/diff.patch" "test5: output lists the diff.patch rule"` beside the existing assertion at :404, matching the surrounding quoting style.

## Phase 5

### 5.1 Hook example

Replace the `"command"` value at CLAUDE.md:330 with (JSON-escaped, one line):

```
"command": "jq -r '\"\\(now | strflocaltime(\"%Y-%m-%d\")) - Modified: \\(.tool_input.file_path)\"' >> \"$CLAUDE_PROJECT_DIR\"/.claude-hve-tracking/changes/auto-log.md"
```

Decoded, the shell command is:

```
jq -r '"\(now | strflocaltime("%Y-%m-%d")) - Modified: \(.tool_input.file_path)"' >> "$CLAUDE_PROJECT_DIR"/.claude-hve-tracking/changes/auto-log.md
```

`strflocaltime` keeps the date local, matching the `date +%Y-%m-%d` it replaces; plain `strftime` would write the UTC date.

Add one sentence after the intro line (:321): `Hooks receive the tool call as JSON on stdin, so the example reads the edited path with \`jq\` (which must be installed).`

### 5.3 Reserved-names note

After the closing fence of the tracking tree in CLAUDE.md and in docs/reference.md:

```
Companion tooling may add its own folders here; `consults/` and `gh-sync/` are reserved for that use. HVE commands neither write nor discover them, and artifact discovery ignores any folder not shown above.
```

## Environment

- The parent shell is zsh on macOS; the suites and install.sh are bash. `$PIPESTATUS` is bash-only, which is one more reason guard steps redirect to a log and read `$?`.
- `jq` 1.8.1 is at /opt/homebrew/bin/jq (`which jq`, `jq --version`, 2026-10-10). `strflocaltime` needs jq 1.6 or later.
- Instructions to read before editing: `.claude/instructions/markdown.md`, `.claude/instructions/writing-style.md`, `.claude/instructions/bash.md` (install.sh and the test scripts).
