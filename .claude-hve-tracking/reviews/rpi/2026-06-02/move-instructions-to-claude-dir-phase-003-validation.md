# RPI Validation: Move instruction files to .claude/instructions/ — Phase 3
Date: 2026-06-02
Plan phase: Phase 3 — Update references in CLAUDE.md and prompts
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 3.1: Update Instructions Reference table (12 rows) | Found | `CLAUDE.md:190-201` | ✅ Implemented |
| Step 3.2: Update installer description paragraph | Found | `CLAUDE.md:248` | ✅ Implemented |
| Step 3.3: Update prompts/doc-ops.md excludes list | Found | `prompts/doc-ops.md:20` | ✅ Implemented |
| Step 3.4: Update prompts/prompt-build.md artifact type list | Found | `prompts/prompt-build.md:9` | ✅ Implemented |

## Findings

### Evidence Summary

**CLAUDE.md Instructions Reference Table (lines 190-201):** All 12 rows correctly use `.claude/instructions/` paths:
- Bash, Python, Python (uv), Python Tests
- C#, C# Tests, Rust, Rust Tests
- Terraform, Markdown, Git commits, Writing Style

**CLAUDE.md Installer Description (line 248):** States "The installer copies `.claude/commands/`, `.claude/agents/`, `.claude/instructions/`, and `prompts/`" — correctly references `.claude/instructions/`.

**prompts/doc-ops.md Excludes (line 20):** "Prompt engineering artifacts (`.claude/commands/`, `.claude/agents/`, `.claude/instructions/`, `prompts/`)" — correctly updated.

**prompts/prompt-build.md Artifact Types (line 9):** "- Instruction files (`.claude/instructions/`)" — correctly updated.

**Grep verification:** No bare `instructions/` paths (without `.claude/` prefix) remain in CLAUDE.md or prompts/ files.

**File inventory:** All 12 instruction files exist at `.claude/instructions/`:
- bash.md, csharp.md, csharp-tests.md, git-commit-messages.md
- markdown.md, python.md, python-tests.md, python-uv.md
- rust.md, rust-tests.md, terraform.md, writing-style.md

## Unlisted Changes

None. All claimed changes match evidence in the codebase.

## Research Coverage

No research document was provided for this task. Plan was derived from source audit. All Phase 3 objectives (reference updates in CLAUDE.md and prompts/) have been verified and implemented.

## Assessment

**All Phase 3 plan items implemented successfully.** Each of the 4 steps is verified in the actual files:
1. Instructions Reference table: all 12 rows ✅
2. Installer description: updated ✅
3. doc-ops.md excludes: updated ✅
4. prompt-build.md artifact types: updated ✅

No bare `instructions/` references remain in scope files.
