# Prompt Analysis: hve-implementation-validator.md
Date: 2026-06-12
Context: Pre-change assessment before applying Change #5 from 2026-06-12-hve-workflow-tightening-writeup.md
(living-doc citation-rot check — documentation dimension)
Target: `.claude/agents/hve-implementation-validator.md`
Type: agent

---

## Key Finding: No Documentation Dimension Exists

Change #5 targets the "documentation dimension" of this agent, but no such dimension exists.
The agent defines 10 dimensions; "documentation omission" appears only as a Minor-severity
example (line 96), not as a first-class check. The citation-rot rule needs a new dimension
created, not an edit to existing text.

---

## Findings

### PA-001 [COMPLETENESS] [MAJOR] — Change #5 has no host dimension

Issue: The writeup says to extend the "documentation dimension," but no such dimension exists.
The ten dimensions cover architecture through overall quality; documentation is never a
first-class check. The citation-rot rule cannot "slot in" without a structural addition.

Evidence:
- Line 25: `## The Ten Validation Dimensions`
- Line 96: `Minor: Style gap; improvement opportunity; documentation omission` — only mention;
  it is an example of a severity grade, not a check.

Fix: Add dimension 11 **Documentation Integrity** and update the dimension count headers.
Suggested text:
```
### 11. Documentation Integrity
- When a changed file is referenced by a living doc (contributor guide, README,
  architecture note — not a dated `.claude-hve-tracking/` artifact), Grep the doc
  for citations into that file and verify the cited **symbols** (Class.Method,
  function names) still exist. Flag dead/renamed references as **Minor**.
- Prefer pointing reviewers at covering tests as compile-checked living examples.
```

---

### PA-002 [COMPLETENESS] [MAJOR] — Scope enum omits dimension 10 and any doc token

Issue: The `Validation scope` enum (line 20) lists 9 dimension tokens + `full-quality`,
but dimension 10 (Overall Quality) has no token — and Change #5's documentation check will
have none either. A parent dispatching a targeted scope has nothing to pass.

Evidence: Line 20:
`architecture | design-principles | dry-analysis | api-usage | version-consistency | refactoring | error-handling | test-coverage | security | full-quality`

Fix: Add `overall-quality` and `documentation` to the enum. Document that `full-quality`
runs all dimensions including documentation.

---

### PA-003 [COMPLETENESS] [MAJOR] — Convention belongs in CLAUDE.md, not only here

Issue: Change #5 has two halves: (a) a convention ("file:line for dated snapshots; living
docs anchor to symbols") and (b) a check (validator greps cited symbols). The convention is
project-wide and currently contradicts CLAUDE.md's Citation Format section, which mandates
`file:line` universally with no snapshot/living-doc distinction. If only this agent learns
the rule, authors writing living docs never see it.

Evidence: CLAUDE.md "Citation Format" requires `file:line` with no living-doc carve-out.
The agent's own `file:line` finding format is correct (findings ARE dated snapshots) and
should not change.

Fix: Put the convention in CLAUDE.md (extend Citation Format with a snapshots-vs-living-docs
note). Keep only the *check* in this agent. This is a separate file from the agent.

---

### PA-004 [ACTIONABILITY] [MINOR] — "Living doc" is undefined; the check isn't executable

Issue: The proposed check hinges on distinguishing a "living doc" from a "dated artifact"
and on locating which docs cite a changed file. Without a heuristic the validator cannot act
deterministically.

Evidence: N/A — gap; nothing in the current file defines doc discovery.

Fix: In the new dimension 11, specify the procedure:
"Living doc = any tracked `.md` outside `.claude-hve-tracking/`. For each changed file,
`Grep -rl` its basename/path across those docs; for each hit, extract cited symbols and
`Grep` the changed file to confirm they still exist."
This makes the check runnable with the Grep tool already granted to this agent.

---

### PA-005 [FORMAT] [MINOR] — Hardcoded "ten" count will drift

Issue: "Ten validation dimensions" is stated twice. Adding dimension 11 requires updating
both references; the current text will immediately be wrong after the change lands.

Evidence:
- Line 9: `across ten validation dimensions`
- Line 25: `## The Ten Validation Dimensions`

Fix: Update both to "eleven" when PA-001 lands, or soften to "across all validation
dimensions" to avoid future drift.

---

### PA-006 [CLARITY] [MINOR] — Acceptance criterion requires visible mention; no slot reserved

Issue: The writeup's acceptance test is "validator output mentions the citation check when
cited files change." The current output template's Coverage Notes section is only for
dimensions NOT fully checked. There's no place to confirm the check ran clean.

Evidence:
- Lines 121–122: `## Coverage Notes / [Dimensions not fully checked and why]`
- Writeup acceptance: "validator output mentions the citation check when cited files change"

Fix: Add a one-liner to the output template instructing the validator to note the
citation-check result in Coverage Notes even when no dead references are found, so the
acceptance criterion is verifiable.

---

## Summary

| ID | Dimension | Severity | Target File |
|----|-----------|----------|-------------|
| PA-001 | COMPLETENESS | MAJOR | hve-implementation-validator.md |
| PA-002 | COMPLETENESS | MAJOR | hve-implementation-validator.md |
| PA-003 | COMPLETENESS | MAJOR | CLAUDE.md (separate edit) |
| PA-004 | ACTIONABILITY | MINOR | hve-implementation-validator.md |
| PA-005 | FORMAT | MINOR | hve-implementation-validator.md |
| PA-006 | CLARITY | MINOR | hve-implementation-validator.md |

Overall: 0 critical, 3 major, 3 minor

---

## Recommended Apply Order

1. CLAUDE.md — extend Citation Format (PA-003); this is a prerequisite for consistent
   messaging before the agent learns the check.
2. hve-implementation-validator.md — add dimension 11 text with living-doc definition
   (PA-001 + PA-004), scope enum tokens (PA-002), count update (PA-005), Coverage Notes
   note (PA-006).

Full-detail re-read: `.claude-hve-tracking/reviews/2026-06-12-hve-implementation-validator-prompt-analysis.md`
