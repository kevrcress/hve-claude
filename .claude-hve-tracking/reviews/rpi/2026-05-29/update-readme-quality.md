# Documentation Validation: Update README.md

Date: 2026-05-29
Scope: Accuracy, Completeness, Clarity, Broken References, Consistency
Files Reviewed: 1 (README.md cross-checked against CLAUDE.md, install.sh, .claude/commands/, .claude/agents/, instructions/)

## Summary

Critical: 0 | Major: 2 | Minor: 2

---

## Findings

### IV-001 [ACCURACY] [MAJOR]

**Description:** README section on `hve-implementation-validator` dimensions lists incorrect dimension names and counts that do not match the actual agent implementation.

**Evidence:**
- README.md:338-349 lists: "Architecture conformance, Design quality, DRY / reuse, API usage correctness, Security (automated), Test coverage, Error handling, Performance, Documentation, Security hygiene"
- Actual agent `.claude/agents/hve-implementation-validator.md` defines: "Architecture Conformance, Design Principles, DRY Compliance, API Usage, Version Consistency, Refactoring Opportunities, Error Handling, Test Coverage, Security Posture, Overall Quality"

The actual agent uses **10 different dimension names** — dimensions 5, 6, 8, and 10 differ significantly. "Performance" and "Documentation" are not separate dimensions in the validator; "Version Consistency," "Refactoring Opportunities," and "Overall Quality" are.

**Impact:** Users reading README about what the validator checks will be misinformed about actual coverage. Documentation authors or tool builders relying on README will build against wrong assumptions.

**Recommendation:** Update README.md lines 340–349 to match the actual hve-implementation-validator.md dimension list. Replace "Security (automated — see below)" with "Security Posture" and align all other dimension names and definitions.

---

### IV-002 [BROKEN REFERENCES] [MAJOR]

**Description:** README references a `prompts/` directory in the installer section (line 146) and later installation flow, but this directory is never verified to exist.

**Evidence:**
- README.md:146 states: "Copies `instructions/` (language conventions) and `prompts/` (reusable task prompts)"
- README.md:173 references checking commitment of "challenges/ memory/ doc-ops/" but no explicit mention of `prompts/` subdirectories
- install.sh:46 does copy from `$SOURCE/prompts/` but no validation that this directory exists or contains content

**Impact:** Users running the installer may encounter errors or silent failures if `prompts/` is missing or empty. If `prompts/` is essential, users won't know it wasn't installed.

**Recommendation:** Either (a) verify `prompts/` directory exists with content and document what's inside, or (b) remove the reference if prompts are optional. Add a note in README if prompts are optional ("if available").

---

### IV-003 [ACCURACY] [MINOR]

**Description:** Command count in README section reference may be slightly misleading due to organization.

**Evidence:**
- README lists 15 commands: `/hve`, `/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review`, `/hve-pr-review`, `/hve-challenge`, `/hve-doc-ops`, `/hve-memory`, `/hve-prompt-builder`, `/hve-prompt-analyze`, `/hve-prompt-refactor`, `/hve-git-commit`, `/hve-git-merge`, `/hve-git-setup`
- Count is correct: 15 commands verified in `.claude/commands/` directory

**Evidence:** No issue — count is accurate. [RESOLVED — not a finding]

---

### IV-004 [COMPLETENESS] [MINOR]

**Description:** README's "Internals" section lists 8 subagents but does not document what makes them different from the commands — the relationship could be clearer for new contributors.

**Evidence:**
- README.md:310–320 lists 8 subagents: `hve-researcher`, `hve-plan-validator`, `hve-phase-implementor`, `hve-rpi-validator`, `hve-implementation-validator`, `hve-prompt-evaluator`, `hve-prompt-tester`, `hve-prompt-updater`
- README.md:332 states "No agent has the Agent tool" but does not explain why this constraint matters or how it prevents runaway spawning

**Impact:** New agent contributors may not understand the constraint's purpose and could accidentally violate it. Documentation is correct but lacks pedagogical depth.

**Recommendation:** Add one sentence after line 332 explaining the benefit: "This prevents subagents from spawning unlimited child subagents, keeping resource usage bounded and debugging tractable."

---

### IV-005 [CONSISTENCY] [MINOR]

**Description:** README uses "hve-rpi-validator" (singular) in the orchestrator tree (line 328) but should clarify it spawns **N instances** (one per completed phase), consistent with the description in line 220.

**Evidence:**
- README.md:220: "`hve-rpi-validator` subagents" — plural, implying multiple
- README.md:328: "hve-rpi-validator × N" — correctly shows multiplicity but the textual reference at line 220 should match this notation

**Impact:** Minor — not a breaking issue, but consistency improves scannability.

**Recommendation:** Line 220 is already correct ("subagents" plural). No change needed; the orchestrator tree at line 328 correctly uses `× N`.  [RESOLVED — no change needed]

---

## Coverage Notes

✓ **Accuracy:** Verified command count (15), agent count (8), instruction file count (12)
✓ **Installer description:** Confirmed against install.sh — accurate
✓ **Tracking folder structure:** Compared README.md:245–267 against CLAUDE.md:56–83 — perfect match
✓ **Broken references:** Checked all file paths, commands, and features
✓ **Completeness:** Reviewed CLAUDE.md for items missing from README — no major omissions detected

**Not fully covered:**
- Security hygiene claims (line 236) in benefits table not spot-checked against actual validator code — requires reading validator implementation in detail (out of scope for documentation validation)
- Example walkthrough (lines 191–223) relies on the plan/phase structure being accurate — not audited against actual subagent behavior

---

## Recommendations for Next Session

1. Correct the `hve-implementation-validator` dimensions list to match actual agent
2. Verify and document the `prompts/` directory requirement or mark as optional
3. Add clarification on "No agent has the Agent tool" constraint's purpose
4. (Optional) Deepen documentation on how subagent multiplicity (`× N`) affects parallelism and cost

