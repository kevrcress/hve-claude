# Research: CLAUDE.md Review and Cleanup
Date: 2026-05-29
Task: review and clean up CLAUDE.md

## Summary

Three parallel subagents audited CLAUDE.md across accuracy, wording/consistency, and completeness dimensions. Seven actionable issues found ranging from a factual error (wrong dimension number) to missing table entries to unclear terminology.

---

## Findings

### Critical

**F-08** — HVE expansion wrong (`CLAUDE.md:1`)
CLAUDE.md line 1 says "Human-Value Engineering" but the upstream microsoft/hve-core README explicitly defines HVE as "Hypervelocity Engineering (HVE) Core." Discovered during post-research acronym verification against upstream source.
Fix: Change line 1 to `# HVE Claude — Hypervelocity Engineering for Claude Code`

**F-01** — Gitignore contradiction (`CLAUDE.md:58`)  
Line 58 says "All runtime artifacts live in `.claude-hve-tracking/` **(gitignored)**" but the "Tracking folder & version control" section (lines 253–264) correctly explains that durable artifacts ARE committed with only `subagents/` and `sandbox/` gitignored. The word "(gitignored)" in line 58 is the wrong shorthand and will confuse users installing HVE.
Fix: Remove "(gitignored)" and replace with "(partially gitignored — see below)" or just remove the parenthetical.

**F-02** — Wrong dimension number (`CLAUDE.md:204`)  
The Security Hygiene section says "dimension 10" but the `hve-implementation-validator` agent has Security as **dimension 9** and "Overall Quality" as dimension 10. The listed checks (secret exposure, gitignore hygiene, committed secrets, new dependencies) all belong to dimension 9.
Fix: Change "dimension 10" to "dimension 9".

### Major

**F-03** — Instructions Reference table incomplete (`CLAUDE.md:188–196`)  
The table lists 7 instruction files but the `instructions/` directory contains 12. Missing: `csharp-tests.md`, `python-tests.md`, `python-uv.md`, `rust-tests.md`, `writing-style.md`. All five exist and are relevant.
Fix: Add 5 rows to the table.

### Medium

**F-04** — DR-/DD- prefixes unexplained (`CLAUDE.md:67`)  
The folder structure diagram references "Planning discrepancy log (DR-/DD- items)" but neither abbreviation is defined anywhere in CLAUDE.md. From the `hve-plan-validator` agent: DR- = research requirement with no corresponding plan step; DD- = plan step that makes an unverified assumption.
Fix: Add a brief inline note or parenthetical.

**F-05** — `/clear` reference unclear (`CLAUDE.md:180`)  
"No manual file attachment or `/clear` equivalent is needed" — `/clear` is not a standard Claude Code command and the reference confuses more than it clarifies.
Fix: Rephrase to "No manual file attachment or context management is needed."

**F-06** — "de-Copilot" undefined jargon (`CLAUDE.md:47`)  
The `/hve-prompt-refactor` description says "Clean up and de-Copilot an existing artifact". "de-Copilot" is unexplained jargon that new users won't understand.
Fix: Replace with "Remove low-quality or AI-generated boilerplate from an existing artifact."

**F-07** — Status value list vague (`CLAUDE.md:147`)  
The Subagent Response Protocol lists "Pass / Fail / Complete / Blocked" without indicating which agents use which values. Pass/Fail apply to validators (plan, RPI, quality); Complete/Blocked apply to implementors and researchers. The mixing implies all four apply equally to all agents.
Fix: Add a brief clarifying note that Pass/Fail are used by validators, Complete/Blocked by other agents.

---

## Non-Issues (Investigated, No Change Needed)

- All 15 command files exist and match CLAUDE.md descriptions [HIGH]
- All 8 agent files exist [HIGH]
- Gitignore rules at lines 258–260 match `.gitignore` exactly [HIGH]
- `install.sh` copies match what CLAUDE.md claims [HIGH]
- Tracking folder structure diagram is prescriptive (not yet committed) — this is expected behavior, not an error [MEDIUM]
- Hook env var `$CLAUDE_TOOL_INPUT_FILE_PATH` — cannot verify from repo files; leave as-is [LOW]

---

## Out of Scope (Deferred)

- Adding a subagent inventory table (significant new content)
- Expanding the `## Your Project` placeholder with examples (template by design)
- README vs CLAUDE.md sync strategy (separate work item)
- Documenting the commands/agents distinction (README already covers this)
