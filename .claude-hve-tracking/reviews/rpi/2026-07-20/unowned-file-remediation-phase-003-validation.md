# RPI Validation: Unowned-File Convention Remediation — Phase 3
Date: 2026-07-21
Plan phase: Phase 3 — Command-body gaps in doc-ops and memory (M-02, M-11, M-12, m-01, m-02)
Coverage: 100%
Status: Pass

---

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 3.1: Name roster agent in hve-doc-ops dispatch | Found | `.claude/commands/hve-doc-ops.md:49-50` | ✅ Implemented |
| Step 3.2: Add exclusion for four `.claude/` directories in doc-ops Discovery | Found | `.claude/commands/hve-doc-ops.md:26` | ✅ Implemented |
| Step 3.3: Fix hve-doc-ops argument-hint path/flags independence | Found (with DD-004) | `.claude/commands/hve-doc-ops.md:3` | ✅ Implemented (flag dropped by design) |
| Step 3.4: Add artifact-discovery subsection to hve-memory | Found | `.claude/commands/hve-memory.md:35-45` | ✅ Implemented |
| Step 3.5: Correct hve-memory per-project native memory wording | Found | `.claude/commands/hve-memory.md:87` | ✅ Implemented |

---

## Findings

### RV-001 [MAJOR]
**Plan item:** Step 3.3 (m-01) — argument-hint rewritten verbatim including `[--friction-log]`
**Evidence:** Plan file line 61 specifies the verbatim string: `[path-to-docs] [--scope all|compliance|accuracy|gaps] [--subagent-model sonnet|opus|haiku] [--friction-log]`. Changes log line 79 confirms implementor wrote it verbatim. However, `.claude/commands/hve-doc-ops.md:3` reads: `argument-hint: [path-to-docs] [--scope all|compliance|accuracy|gaps] [--subagent-model sonnet|opus|haiku]` — missing `[--friction-log]`.
**DD-004 reasoning:** Parent session (2026-07-21) removed `[--friction-log]` after review, with documented justification (changes log lines 98-99): the flag is newly invented (not pre-existing), no command body implements it (m-01 defect was only about path/flags independence), and adding it violates the align-down rule (DD-003) and CLAUDE.md's six-command friction roster. The actual m-01 defect (path and flags as independent bracketed groups) IS fixed.
**Assessment:** DD-004's reasoning is sound and adequately recorded. The deviation from plan-verbatim is justified by a higher-level principle (align-down, no phantom features). The original m-01 defect is resolved. No action needed; phase passes.

---

## Critical Checks — Detailed

### Check 1: Owned files verified; cited locations contain claimed edits

**hve-doc-ops.md:**
- Line 3 — argument-hint: path and flags ARE independent bracketed groups ✅
- Line 26 — excludes `.claude/commands/`, `.claude/agents/`, `.claude/instructions/`, `.claude/prompts/` ✅
- Line 49 — backticked `hve-researcher` agent name present ✅
- Line 50 — roster-deviation fallback sentence present ✅

**hve-memory.md:**
- Lines 35–45 — complete `## Locating tracking artifacts` section with all four discovery steps ✅
- Line 87 — per-project native memory wording with canonical path placeholder ✅

### Check 2: DD-004 reasoning on `[--friction-log]` removal

**Criteria for soundness:**
1. **Was the flag newly invented?** Yes. Changes log line 99 cites pre-task hint as `[path-to-docs | --scope all|compliance|accuracy|gaps] [--subagent-model sonnet|opus|haiku]`; `[--friction-log]` does not appear.
2. **Is the flag implemented in the command body?** No. Line 11 mentions passing `--subagent-model` to Agent tool calls; no friction-log mechanics exist.
3. **Does align-down rule (DD-003) apply?** Yes, per plan line 68: "All prompt edits align the prompt DOWN to actual command behavior; no new command features (DD-003)."
4. **Is friction-log in the six-command CLAUDE.md roster?** No. CLAUDE.md Friction Capture section lists `/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review`, `/hve-pr-review`, `/hve-challenge` — doc-ops not present.
5. **Is the original m-01 defect fixed?** Yes. The defect was path and flags wrongly alternated inside one bracket (`[path-to-docs | --scope ...]`); final state has independent brackets.

**Verdict:** DD-004 is sound. Removal was correct per align-down rule and friction roster. Recording is adequate (changes log lines 97–99).

### Check 3: Canonical wording verbatim match (artifact-discovery subsection + per-project memory)

**Artifact-discovery section (hve-memory.md:35–45 vs. details doc:86–94):**
- One cosmetic difference: blank line added before "Record `none`..." (hve-memory.md:44 is blank; details doc:94 is not)
- Changes log line 95 explains: per `.claude/instructions/markdown.md` (blank lines surrounding lists) for proper rendering
- All 34 words in the four numbered steps match verbatim ✅
- "Record `none`..." sentence matches verbatim ✅
- Formatting deviation is Minor and explained; no words changed ✅

**Per-project native memory wording (hve-memory.md:87 vs. details doc:76–77):**
- Exact verbatim match: "Also write the most non-obvious decisions and patterns to the Claude Code native memory store for this project (`~/.claude/projects/<project-slug>/memory/`). The store is per-project, not global: entries written here surface only in future sessions on this same project." ✅

### Check 4: M-11 exclusion coverage

**Line 26 text:** "Prompt-engineering artifacts are excluded from the inventory: skip `.claude/commands/`, `.claude/agents/`, `.claude/instructions/`, and `.claude/prompts/` — those files are evaluated with `/hve-prompt-analyze`, not doc-ops"

**Coverage check:**
- `.claude/commands/` — ✅ listed
- `.claude/agents/` — ✅ listed
- `.claude/instructions/` — ✅ listed
- `.claude/prompts/` — ✅ listed (with "and" before it)
- `/hve-prompt-analyze` reference — ✅ present and accurate

### Check 5: Success criterion `grep -c "exclud"` and prose naturalness

**Criterion requirement:** `grep -c "exclud" .claude/commands/hve-doc-ops.md` > 0

**Line 26 text:** "Prompt-engineering artifacts are **excluded** from the inventory"

**Wording evolution (per changes log line 93):** "first wording used 'Exclude' (capital E) and `grep -c "exclud"` returned 0; reworded to 'are excluded' so the literal criterion passes"

**Assessment:** Final wording "are excluded" is natural English prose; no contortion evident. Flows naturally as part of the exclusion statement. Success criterion is met with natural language. ✅

---

## Unlisted Changes

All files modified per the parent-supplied changed-file list are accounted for in the changes log:
- `.claude/commands/hve-doc-ops.md` — 5 modifications across lines 3, 26, 49–50 (all Phase 3)
- `.claude/commands/hve-memory.md` — 2 modifications across lines 35–45, 87 (all Phase 3)

No files on the changed-file list are absent from the changes log. ✅

---

## Research Coverage

Research document identified five Major defects for Phase 3:
- **M-02** — hve-doc-ops names nonexistent agent → Fixed by Step 3.1; backticked `hve-researcher` now present and resolvable ✅
- **M-11** — doc-ops.md promises exclusion rule command lacks → Fixed by Step 3.2; all four directory exclusions present, `/hve-prompt-analyze` reference added ✅
- **M-12** — hve-memory has no artifact-discovery procedure → Fixed by Step 3.4; complete subsection with slug-first rule, 7-day window, branch tiebreak, relevance check added ✅

Plus two Minor defects:
- **m-01** — argument-hint path/flags alternation → Fixed by Step 3.3; brackets now independent (flag token issue handled by DD-004) ✅
- **m-02** — native memory wording wrong (cross-project claim) → Fixed by Step 3.5; per-project language with path placeholder now correct ✅

All research requirements met. ✅

---

## Summary

**Coverage:** 5 of 5 plan steps implemented — 100%

**Quality:**
- All five Phase 3 plan steps executed and verified in actual files
- Owned file set (2 files) complete and accesses match line citations
- One parent-decision (DD-004) superceded the plan-verbatim requirement for Step 3.3; reasoning documented and sound; underlying defect fixed
- Canonical wording verified verbatim with one documented cosmetic formatting note
- M-11 exclusion fully specified with all four directories and correct reference
- Success criterion naturally met without prose contortion
- Research coverage 100%: all five research findings (M-02, M-11, M-12, m-01, m-02) addressed

**Verdict:** Phase 3 passes validation.
