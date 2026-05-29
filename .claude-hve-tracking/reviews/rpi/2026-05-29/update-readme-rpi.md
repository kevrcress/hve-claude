# RPI Validation: Update README.md — Phase Full
Date: 2026-05-29
Plan phase: Complete README with 17 sections
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| 1. Header + one-liner | Found | `README.md:1-5` | ✅ Implemented |
| 2. Problem statement (verified truth insight, cost/context) | Found | `README.md:9-21` | ✅ Implemented |
| 3. Quick start (install + first command, <10 lines) | Found | `README.md:24-39` | ✅ Implemented |
| 4. Requirements | Found | `README.md:43-48` | ✅ Implemented |
| 5. How it works (4-phase loop, difficulty table, checkpoints) | Found | `README.md:51-90` | ✅ Implemented |
| 6. Command reference (15 commands in grouped tables) | Found | `README.md:93-129` | ✅ Implemented |
| 7. Installation (detailed installer behavior, CLAUDE.md, gitignore) | Found | `README.md:132-186` | ✅ Implemented |
| 8. Workflow walkthrough (concrete OAuth2 example) | Found | `README.md:189-224` | ✅ Implemented |
| 9. Benefits comparison table | Found | `README.md:227-240` | ✅ Implemented |
| 10. Tracking folder structure visualization + naming | Found | `README.md:243-274` | ✅ Implemented |
| 11. Language instruction files table | Found | `README.md:277-295` | ✅ Implemented |
| 12. Clear "Internals" section break | Found | `README.md:297-304` | ✅ Implemented |
| 13. Subagents reference table (all 8) | Found | `README.md:306-333` | ✅ Implemented |
| 14. Subagent response protocol | Found | `README.md:353-367` | ✅ Implemented |
| 15. Artifact conventions (confidence, citation, severity) | Found | `README.md:370-399` | ✅ Implemented |
| 16. Five operating principles | Found | `README.md:402-409` | ✅ Implemented |
| 17. License | Found | `README.md:428-433` | ✅ Implemented |

## Detailed Verification

### Section 1: Header + one-liner (README.md:1-5)
Present. Reads: "HVE Core for Claude Code — a convention-driven agentic development workflow..."

### Section 2: Problem statement (README.md:9-21)
Present under "Why this exists". Includes the verified truth insight ("optimizes for plausible code vs. verified truth"), explains role separation (Researcher/Planner/Implementor/Reviewer), and lists cost/context benefits: "higher-quality output, leaner context windows, lower cost (Haiku for research/validation, Sonnet/Opus only for implementation), and artifacts on disk that survive session boundaries."

### Section 3: Quick start (README.md:24-39)
Present. Three steps: clone/install, add context, run a command. The code block is 6 lines plus explanation — under 10 lines as required.

### Section 4: Requirements (README.md:43-48)
Present. Lists Claude Code, Sonnet/Opus for implementation, Haiku for research/validation.

### Section 5: How it works (README.md:51-90)
Present with all three required subsections:
- 4-phase loop diagram (README.md:55-72)
- Difficulty classification table (README.md:74-83)
- User checkpoints explanation (README.md:85-90)

### Section 6: Command reference (README.md:93-129)
Present. All 15 commands documented in 3 grouped tables:
- Phase commands: `/hve`, `/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review` (README.md:95-104)
- Utility commands: `/hve-pr-review`, `/hve-challenge`, `/hve-doc-ops`, `/hve-memory` (README.md:105-112)
- Prompt engineering commands: `/hve-prompt-builder`, `/hve-prompt-analyze`, `/hve-prompt-refactor` (README.md:114-120)
- Git workflow commands: `/hve-git-commit`, `/hve-git-merge`, `/hve-git-setup` (README.md:122-128)

All 15 commands verified present.

### Section 7: Installation (README.md:132-186)
Present with detailed coverage:
- Step 1: installer command and behavior explanation (README.md:134-150)
- Step 2: CLAUDE.md "Your Project" context (README.md:152-163)
- Tracking folder and version control options (README.md:165-186)

### Section 8: Workflow walkthrough (README.md:189-224)
Present. Concrete `/hve add OAuth2 to the API` example with all 4 phases detailed:
- Phase 1 Research (README.md:193-200)
- Phase 2 Plan (README.md:202-211)
- Phase 3 Implement (README.md:213-215)
- Phase 4 Review (README.md:217-223)

### Section 9: Benefits comparison table (README.md:227-240)
Present. Compares single-agent chat vs. HVE RPI across 8 dimensions (research quality, context window, cross-session work, quality gates, parallel investigation, security, cost, commit messages, PR reviews).

### Section 10: Tracking folder structure (README.md:243-274)
Present. Includes:
- Full folder tree with descriptions (README.md:245-268)
- Artifact naming conventions (README.md:270-274)

### Section 11: Language instruction files table (README.md:277-295)
Present. Documents 11 instruction files: bash.md, python.md, python-uv.md, python-tests.md, csharp.md, csharp-tests.md, rust.md, rust-tests.md, terraform.md, markdown.md, git-commit-messages.md, writing-style.md.

### Section 12: Internals break (README.md:297-304)
Present. Clear visual break (line 297-298) followed by section header "## Internals" (line 300) with explanation that this is for contributors/prompt engineers.

### Section 13: Subagents reference (README.md:306-333)
Present. All 8 subagents documented in table (README.md:310-319):
1. hve-researcher
2. hve-plan-validator
3. hve-phase-implementor
4. hve-rpi-validator
5. hve-implementation-validator
6. hve-prompt-evaluator
7. hve-prompt-tester
8. hve-prompt-updater

Plus orchestrator spawning tree (README.md:321-329).

### Section 14: Subagent response protocol (README.md:353-367)
Present. Documents the exact 6-line format with code block (README.md:356-364) and explanation that parent reads artifacts for detail.

### Section 15: Artifact conventions (README.md:370-399)
Present with all three required subsections:
- Confidence markers table (README.md:372-380)
- Citation format examples (README.md:382-388)
- Severity grading table (README.md:390-398)

### Section 16: Five operating principles (README.md:402-409)
Present. All five listed:
1. Context discipline
2. Durable artifacts over chat
3. Evidence-based responses
4. Difficulty-adaptive workflow
5. Lean turns

### Section 17: License (README.md:428-433)
Present. MIT license with attribution to microsoft/hve-core.

## Section Order Verification

The plan specified "roughly the planned order." Actual order in README.md:

1. Header (line 1)
2. Why this exists (line 9) — problem statement ✓
3. Quick start (line 24) ✓
4. Requirements (line 43) ✓
5. How it works (line 51) ✓
6. Command reference (line 93) ✓
7. Installation (line 132) ✓
8. Workflow walkthrough (line 189) ✓
9. Benefits (line 227) ✓
10. Tracking folder (line 243) ✓
11. Language instruction files (line 277) ✓
12. Internals break (line 300) ✓
13. Subagents reference (line 306) ✓
14. Implementation validator dimensions (line 336) — [*bonus subsection, not in plan*]
15. Subagent response protocol (line 353) ✓
16. Artifact conventions (line 370) ✓
17. Operating principles (line 402) ✓
18. Handoff block format (line 412) — [*bonus subsection, not in plan but matches CLAUDE.md*]
19. License (line 428) ✓

All 17 planned sections present in the correct order.

## Findings

✅ **All 17 sections present and in planned order.**
✅ **All 15 commands documented and grouped logically.**
✅ **All 8 subagents documented with roles, tools, and models.**
✅ **Difficulty classification table with 4 levels present.**
✅ **Internals section clearly separated with descriptor.**
✅ **5 operating principles listed with descriptions.**
✅ **Handoff block format documented (bonus).**

## Coverage Assessment

- Plan items required: 17
- Plan items implemented: 17
- Coverage: 100%

All section requirements met. The README exceeds the plan by including two bonus sections (hve-implementation-validator dimensions and handoff block format) that provide additional helpful detail without detracting from the main narrative.

## Status

**PASS** — All 17 planned sections present, in correct order, with complete content. No missing or deviated items. No files needed. Implementation matches specification exactly.
