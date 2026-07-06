# Implementation Plan: Global install support (--global)
Date: 2026-07-06
Research: none (plan authored inline; motivated by a working manual global install at
~/.claude discovered in session, with no installer or docs support for it)

## Motivation

Claude Code loads user-level commands/agents from `~/.claude/` and global instructions from
`~/.claude/CLAUDE.md`, so HVE works machine-wide when installed there [HIGH — verified on this
machine]. But install.sh only supported project targets: pointing it at `$HOME` would merge
into `~/CLAUDE.md` (wrong file) and pollute `~/.gitignore` [HIGH — from code, install.sh
pre-change]. Nothing documented the global option.

## Phase 1: install.sh --global mode

- Parse `--global` as the first argument; reject a trailing target-dir.
- Global mode: copy into `~/.claude/{commands,agents,instructions,prompts}`; merge the HVE
  block into `~/.claude/CLAUDE.md` (fresh file gets a `## Your Global Context` placeholder);
  skip the .gitignore step and print the per-project rules instead; skip old-folder
  migrations (project-only concern; `~/instructions` may be the user's own).
- Keep project mode byte-for-byte equivalent in behavior.

## Phase 2: Test coverage

- Add Test 5 to tests/run-install-tests.sh: isolated `$HOME`, assert files land under
  `~/.claude/`, CLAUDE.md merged at `~/.claude/CLAUDE.md` with markers and global placeholder,
  no `~/CLAUDE.md` or `~/.gitignore` created, skipped-gitignore message printed, idempotent
  re-run keeps one marker block, `--global <dir>` exits nonzero.

## Phase 3: Documentation

- docs/installation.md: new "Global install" section (bash flag, manual variant, per-project
  .gitignore rules, shadowing/double-install caveat, update path).
- README.md Installation: pointer paragraph to the new section.
- CLAUDE.md "Installing HVE in Your Project": `--global` usage line and a short paragraph
  (propagates to installed projects via the HVE block).

## Addendum (2026-07-06): Windows compatibility

User review flagged the global path as Mac-centric. Additional scope:
- docs: state that `~/.claude` is `%USERPROFILE%\.claude` on Windows; add an any-OS global
  paste-to-install prompt (the OS-agnostic path for Windows without Git Bash); clarify Git
  Bash vs WSL `$HOME` semantics.
- install.sh: explicit error when `$HOME` is unset in global mode.
- test: assertion that `env -u HOME install.sh --global` exits nonzero.

## Success criteria

- `HOME=<tmp> install.sh --global` produces the layout above; re-run idempotent.
- Full installer suite passes including new global assertions; drift suite unaffected.
- No em-dashes in newly written prose or comments.
