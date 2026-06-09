# Pull Request Reference

> Generate a PR description with `/hve-pr-review [branch]`.

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

- Review log: `.claude-hve-tracking/pr/review/BRANCH-NAME/YYYY-MM-DD-review.md`
- Verdict: ✅ Approve | ⚠️ Request Changes | 🚫 Block
- Findings organized by severity: Critical → Major → Minor

## Options

- `--dimension security` — review only the security dimension
- `--dimension all` — all 8 dimensions (default)

## PR Description

After review, Claude can also generate a PR description template. Ask: "Generate a PR description based on this review."
