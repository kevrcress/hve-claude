# Implementation Plan: Docs-vs-frontmatter drift test + .gitignore security hygiene
Date: 2026-07-06
Research: none (plan authored inline during /hve-implement; scope derived from
.claude-hve-tracking/reviews/rpi/2026-07-06/subagent-model-tuning-quality.md follow-on items)
Details: embedded below (task is Medium; no separate details doc)

## Motivation

The 2026-07-06 quality review of the subagent model retier found:
1. Docs that restate agent `model:` frontmatter (docs/internals.md table, README claims) drifted
   silently when frontmatter changed — caught twice in one session [HIGH].
2. The repo's own `.gitignore` lacks the credential-file entries that HVE's security hygiene
   checklist (CLAUDE.md, Security Hygiene section) prescribes: `.env`, `.env.*`, `*.pem`,
   `*.key`, `*.p12` [HIGH — verified via grep of .gitignore].

## Phase 1: .gitignore security hygiene entries

**Dependencies:** none

**Steps:**
1.1 Read the existing `.gitignore` (root of repo).
1.2 Append a commented block with credential-file patterns: `.env`, `.env.*`, `*.pem`, `*.key`,
    `*.p12`, `*.pfx`.
1.3 Verify no currently tracked file becomes ignored (`git status` unchanged for tracked files;
    `git check-ignore` spot checks).

**Success criteria:** all six patterns present in `.gitignore`; `git status` shows only the
`.gitignore` modification; installer tests still pass (installer merges tracking rules into
target .gitignore — confirm no interaction).

## Phase 2: Drift test script

**Dependencies:** Phase 1 (the script's hygiene assertions expect the new entries to exist)

**Steps:**
2.1 Read `.claude/instructions/bash.md` and follow it.
2.2 Create `tests/run-drift-tests.sh`, modeled on `tests/run-install-tests.sh` (set -euo pipefail,
    source `tests/lib/assert.sh`, per-test labels, `finish` tally, exit 0 only on all pass).
2.3 Assertions to implement:
    a. **Frontmatter validity** — every `.claude/agents/*.md` has a `model:` value in
       {haiku, sonnet, opus, inherit} and a `name:` matching its filename stem.
    b. **docs/internals.md table sync** — for each agent, the Model column value
       (case-insensitive) equals the agent's frontmatter `model:` value.
    c. **CLAUDE.md Model Selection sync** — the CLAUDE.md sentence naming pinned tiers must not
       contradict frontmatter. Implement narrowly: for each agent pinned `haiku` or `sonnet` in
       frontmatter, CLAUDE.md's Model Selection section must not claim a different tier for that
       agent by name; if prose parsing proves too brittle, record a DD- and cover only the
       internals.md table (the drift class actually observed).
    d. **.gitignore hygiene** — `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` present (the
       CLAUDE.md security checklist set).
2.4 Run the new script; all assertions pass.
2.5 Run `tests/run-install-tests.sh`; still 31/31.

**Success criteria:** new script passes; deliberately breaking a frontmatter value locally makes
it fail (verify once, then revert); install suite unaffected.

## Out of scope

- Wiring into CI (no CI config exists in this repo yet)
- README prose claims (too free-form to assert mechanically; internals table is the canonical
  restatement and now carries a source-of-truth note)
