# Prompt Build Reference

> Create or improve HVE artifacts with `/hve-prompt-builder <description>`.

## What it builds

- Slash commands (`.claude/commands/`)
- Agent definitions (`.claude/agents/`)
- Instruction files (`.claude/instructions/`)
- Reusable prompts (`.claude/prompts/`)

## Process

1. Draft the artifact based on the description
2. Test against 2–3 representative scenarios (via `hve-prompt-tester`)
3. Evaluate test results against quality criteria (via `hve-prompt-evaluator`)
4. Update based on findings (via `hve-prompt-updater`)
5. Repeat for N iterations (default: 3) or until no Critical/Major issues remain
6. Present final draft to user for approval
7. Write to final location on confirmation

## Options

- `--iterations N` — number of test-evaluate-update cycles (default: 3)
- `--subagent-model sonnet|opus|haiku` — override each subagent's frontmatter model

## Output

Drafts and test execution logs live in the sandbox: `.claude-hve-tracking/sandbox/YYYY-MM-DD-topic-run-N/`. The final artifact is written to its `.claude/` destination only after user approval.

## Related commands

- `/hve-prompt-analyze <file>` — evaluate an existing artifact without rebuilding
- `/hve-prompt-refactor <file>` — clean up an existing artifact
