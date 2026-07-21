# Pull Request Reference

> Senior-level PR code review with `/hve-pr-review [branch]`: 8 quality dimensions, severity-graded findings.

## What it does

Analyzes the diff between the current branch and `main` (or a specified base) across 8 quality dimensions:

1. Functional Correctness
2. Design & Architecture
3. Idiomatic Implementation
4. Reusability & Leverage
5. Performance & Scalability
6. Reliability & Observability
7. Security & Compliance
8. Documentation & Operations

## Output

- Review log: `.claude-hve-tracking/reviews/pr/BRANCH-NAME/YYYY-MM-DD-review.md`
- Verdict: ✅ Approve | ⚠️ Request Changes | 🚫 Block
- Findings organized by severity: Critical → Major → Minor

## Options

- `--dimension all` — all 8 dimensions (default). Narrow to one with
  `functional`, `design`, `idiomatic`, `reuse`, `performance`, `reliability`,
  `security`, or `docs`
- `--compact` — 4 paired dimension subagents instead of 8 single-dimension ones
- `--subagent-model sonnet|opus|haiku` — override each subagent's frontmatter model
- `--friction-log` — record process friction encountered during the review
