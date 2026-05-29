# Implementation Plan: CLAUDE.md Review and Cleanup
Date: 2026-05-29
Research: .claude-hve-tracking/research/2026-05-29/claude-md-cleanup.md

## Summary

Eight targeted edits to CLAUDE.md, organized by severity. All edits are in-place text fixes — no structural reorganization, no new sections added (except inline definitions). Estimated lines changed: ~15.

---

## Phase 1 — Critical Fixes (3 edits)

### Step 1.1 — Fix HVE expansion in title
**File:** `CLAUDE.md:1`
**Change:** `Human-Value Engineering` → `Hypervelocity Engineering`
**Rationale:** The upstream microsoft/hve-core README explicitly defines HVE as "Hypervelocity Engineering." The current text is factually wrong.
**Success criterion:** Line 1 reads `# HVE Claude — Hypervelocity Engineering for Claude Code`

### Step 1.2 — Fix gitignore contradiction
**File:** `CLAUDE.md:58`
**Change:** Remove `(gitignored)` from "All runtime artifacts live in `.claude-hve-tracking/` (gitignored)."
**Replace with:** "All runtime artifacts live in `.claude-hve-tracking/`. Durable artifacts are committed; only regenerable output is gitignored — see [Tracking folder & version control](#tracking-folder--version-control) below."
**Rationale:** "(gitignored)" directly contradicts the later section which correctly states artifacts ARE committed. A forward reference prevents the contradiction.
**Success criterion:** No reader can conclude the whole folder is gitignored from line 58.

### Step 1.3 — Fix dimension number in Security Hygiene
**File:** `CLAUDE.md:204`
**Change:** `dimension 10` → `dimension 9`
**Rationale:** The `hve-implementation-validator` agent defines Security Posture as dimension 9 and Overall Quality as dimension 10. The listed security checks (secret exposure, gitignore hygiene, committed secrets, new dependencies) belong to dimension 9.
**Success criterion:** Line 204 reads "via the `hve-implementation-validator` subagent, dimension 9"

---

## Phase 2 — Major Fix (1 edit)

### Step 2.1 — Expand Instructions Reference table
**File:** `CLAUDE.md:188–196`
**Change:** Add 5 missing rows to the table for:
- `instructions/csharp-tests.md` → `C# Tests`
- `instructions/python-tests.md` → `Python Tests`
- `instructions/python-uv.md` → `Python (uv)`
- `instructions/rust-tests.md` → `Rust Tests`
- `instructions/writing-style.md` → `Writing Style`
**Rationale:** All 5 files exist in the repo and are relevant to implementation work.
**Success criterion:** Table lists all 12 instruction files.

---

## Phase 3 — Medium Fixes (4 edits)

### Step 3.1 — Define DR-, DD-, IV- prefixes
**File:** `CLAUDE.md:67` (folder structure comment) and `CLAUDE.md:112` (Finding ID format)
**Changes:**
- Line 67 comment: append `— DR = Discrepancy from Research; DD = Design Decision`
- Line 112: append `— IV = Implementation Validation`
**Rationale:** DR- is explicitly defined in hve-plan-validator ("Discrepancy from Research"). DD- is inferred from hve-plan.md ("Design decision made without full information"). IV- is the finding format used by hve-implementation-validator and hve-pr-review.
**Success criterion:** All three abbreviations are defined inline where they first appear.

### Step 3.2 — Fix `/clear equivalent` wording
**File:** `CLAUDE.md:180`
**Change:** `No manual file attachment or /clear equivalent is needed` → `No manual file attachment or context management is needed`
**Rationale:** `/clear` is not a standard Claude Code command; the reference confuses rather than clarifies.
**Success criterion:** Line 180 contains no reference to `/clear`.

### Step 3.3 — Replace "de-Copilot" jargon
**File:** `CLAUDE.md:47`
**Change:** `Clean up and de-Copilot an existing artifact` → `Remove low-quality or AI-generated boilerplate from an existing artifact`
**Rationale:** "de-Copilot" is undefined jargon opaque to new users.
**Success criterion:** Line 47 contains no jargon undefined elsewhere in the document.

### Step 3.4 — Clarify status values
**File:** `CLAUDE.md:147`
**Change:** `One line: status (Pass / Fail / Complete / Blocked)` → `One line: status — validators use Pass / Fail; other agents use Complete / Blocked`
**Rationale:** Mixing all four values without context implies they're interchangeable. Pass/Fail apply to hve-plan-validator, hve-rpi-validator, hve-implementation-validator; Complete/Blocked apply to researchers and implementors.
**Success criterion:** Line 147 distinguishes which status values apply to which agent types.

---

## Dependencies

All edits are independent — no ordering constraints between steps. Phases 1–3 can be executed in any order.

---

## Out of Scope

- Adding subagent inventory table
- Expanding `## Your Project` placeholder
- README.md (does not expand HVE acronym — separate work item)
- Spelling out `deps` in tree diagram (conventional abbreviation in code comments)

---

## Discrepancy Log

### DR-001: Step 1.1 Not Supported by Research
Source: Research document F-01 through F-07; no mention of "Human-Value Engineering" vs "Hypervelocity Engineering" title
Gap: Plan proposes changing CLAUDE.md:1 from "Human-Value Engineering" to "Hypervelocity Engineering" with rationale citing "upstream microsoft/hve-core README," but research document makes no finding about this. The research audited CLAUDE.md accuracy but never flagged the title expansion.
Severity: Major
Recommendation: Remove Step 1.1 from the plan, or escalate to research to verify if this finding was intentionally deferred. As-is, the step violates the principle that all plan steps must address a research finding.
Status: Open

### DD-001: Step 1.2 Replacement String May Not Match Current File
Source: Plan text at Step 1.2; CLAUDE.md:58 current state
Assumption: Current line 58 reads "All runtime artifacts live in `.claude-hve-tracking/` (gitignored)." and the plan's proposed replacement string is exact.
Risk: If the file has been edited since research was written (e.g., whitespace, comment changes), the Edit command will fail. The plan does not show the exact old_string parameter needed.
Severity: Minor
Recommendation: Implementor should verify the exact current text at CLAUDE.md:58 before attempting the replacement. Consider providing the old_string as a backup if the primary string fails to match.
Status: Open
