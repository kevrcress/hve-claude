# Planning Log: Make HVE installation cross-platform and script-free in the README
Date: 2026-06-01
Task slug: cross-platform-install-readme

## Discrepancies

### DD-001: No research document — plan derived from direct source audit
Source: No matching research artifact in `.claude-hve-tracking/research/` for this task
Resolution: Read `README.md` and `install.sh` directly; task requirements are fully specified in the prompt. Plan was derived from the source files rather than a prior research document.
Risk: If install.sh behavior differs from the task description's steps 1–6, the Option B manual steps may be incomplete.
Status: Resolved — install.sh:36–99 was read directly and matches the task description exactly. No divergence found.

### DD-002: Option B step count (7 vs 6)
Source: Task description says "steps 1–6" but the natural user flow has a step 8 (delete temp clone)
Resolution: Plan counts 7 content steps (matching install.sh operations) plus an optional step 8 (cleanup). The task description's "steps 1–6" refers to the six install operations, not user-visible numbered steps. Option B in the README will have 7 numbered steps with an optional cleanup note.
Risk: Low — the cleanup is optional and not part of the install proper.
Status: Resolved.

### DD-003: "Prefer the terminal?" callout in Quick Start
Source: Current README:45 says "Clone the repo anywhere outside your project and run `./hve-claude/install.sh /path/to/your/project` manually." This is a terminal-biased aside.
Resolution: Updated to point to the Installation section for all options, rather than prescribing install.sh specifically.
Risk: Low — the callout's current wording is a casual aside; updating it to a section link loses no critical information.
Status: Resolved.

### DR-001: FAQ "How do I update HVE" still references install.sh as the only path
Source: README:510–511 says "Pull the latest from this repo and re-run `install.sh`"
Resolution: Update to mention all three update paths: Option A (re-paste prompt), Option B (re-copy files manually), or install.sh for bash users.
Risk: Low — all three paths are idempotent. No behavioral change, only documentation parity.
Status: Open — tracked in Phase 3.

### DR-002: Current Quick Start paste prompt mentions install.sh (not the Option A prompt)
Source: README:32–33 currently says "run install.sh targeting the current directory" — this is not the required Option A prompt
Gap: Plan correctly identifies Phase 1.1 should replace this with the exact Option A prompt (which does NOT mention install.sh), but does not explicitly flag that the current prompt is outdated. Phase 1.1 will overwrite it, so coverage is complete; this is purely a clarity note.
Severity: Minor
Recommendation: No action needed — Phase 1.1 covers this. The plan is correct.
Status: Resolved by Phase 1.1 design.

### DD-004: Option B Step 6 (CLAUDE.md merge) requires understanding three distinct cases
Source: Plan Phase 2.2 mentions "three sub-cases from install.sh" (lines 60–84)
Assumption: The implementor will faithfully reproduce the three logic branches (no file exists, markers exist, neither)
Risk: Low — the details document clearly breaks down the three cases (details:64–68); implementor can follow them directly
Severity: Minor
Status: Resolved — details document provides exact case descriptions.
