# RPI Validation: Installer test suite — Phase 6
Date: 2026-06-02
Plan phase: Update README with development and testing section
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 6.1: Add ## Development section to README.md with branch strategy paragraph | Found | `README.md:380-384` | ✅ Implemented |
| Step 6.1: Automated test instructions (./tests/run-install-tests.sh, no network note, 5 scenarios described) | Found | `README.md:386-394` | ✅ Implemented |
| Step 6.1: Prompt test instructions (both scripts, prerequisites, pause-and-assert workflow) | Found | `README.md:396-410` | ✅ Implemented |
| Step 6.1: Prompt script maintenance note | Found | `README.md:412-414` | ✅ Implemented |
| Step 6.1: Section placed after Installation, before other sections | Found | `README.md:380` (after line 378 divider, before "Workflow walkthrough") | ✅ Implemented |

## Findings

### Detailed Verification

**Branch Strategy Paragraph [HIGH]**
- Location: `README.md:382-384`
- Content: "Work happens on `feature/` branches, which merge into `dev`. Once all tests pass on `dev`, it merges into `main`. Nothing goes directly to `main` — all changes are tested before they land."
- Status: ✅ Matches plan requirement — clear, concise, explains the flow without requiring conversation context
- Coverage: Meets "one short paragraph" target

**Automated Test Instructions [HIGH]**
- Location: `README.md:386-394`
- Heading: "### Running the automated tests"
- Content verified:
  - Notes no network required: "No network connection required. Run from the repo root:" ✅
  - Command: `./tests/run-install-tests.sh` ✅
  - 5 scenarios described: "Covers 5 install.sh scenarios: new install, prepend case, clean upgrade, old em-dash marker upgrade, and diverged upgrade." ✅
  - Success criterion: "All tests should print `[ OK ]`." ✅
- Status: ✅ All required elements present

**Prompt Test Instructions [HIGH]**
- Location: `README.md:396-410`
- Heading: "### Running the prompt tests"
- Content verified:
  - Prerequisites listed:
    1. "The `dev` branch pushed to GitHub (the scripts clone `dev`)" ✅
    2. "Claude Code available in your terminal" ✅
  - Both scripts mentioned with comments:
    - `./tests/run-prompt-new-install.sh   # tests Option A install prompt` ✅
    - `./tests/run-prompt-upgrade.sh       # tests the update prompt` ✅
  - Pause-and-assert workflow described: "Open Claude Code in the directory shown, paste the prompt, then press Enter when Claude finishes. The script asserts the expected outcome and prints a pass/fail summary." ✅
  - Each script runs separately: "Run each script separately — each seeds a temp project, prints the exact prompt to paste, and waits:" ✅
- Status: ✅ All required elements present

**Prompt Script Maintenance Note [HIGH]**
- Location: `README.md:412-414`
- Heading: "### Prompt script maintenance"
- Content: "The prompt scripts embed the Option A and update prompts verbatim, with the clone URL pointing to the `dev` branch. If those prompts change in a future release, update the corresponding script to match."
- Status: ✅ Present and matches plan requirement

**Section Placement [HIGH]**
- Location: Starts at line 380
- Verified sequence in README.md:
  - Line 378: `---` (divider after "Tracking folder and version control" section)
  - Line 380: `## Development` (start of new section)
  - Line 378-379: Section ends, new section begins cleanly
  - Line 418: `## Workflow walkthrough` (next major section)
  - Placement confirmed: After Installation section (ends ~line 293), before Workflow walkthrough
- Status: ✅ Placed correctly

**Line Count [MEDIUM]**
- Requirement: "~35 lines"
- Counted content between `## Development` (line 380) and `---` divider before "## Workflow walkthrough" (line 416)
- Actual line count: 36 lines (lines 380-415 inclusive of subsections and whitespace)
- Status: ✅ Meets target (35±5 lines is reasonable tolerance)

**Readability — Cold Context [HIGH]**
- Verified: A reader with no conversation context can:
  - Understand the branch strategy from the paragraph alone ✅
  - Know how to run automated tests with the exact command ✅
  - Know prerequisites and workflow for prompt tests ✅
  - Know about test scripts without opening a code file ✅
  - Understand why scripts need the `dev` branch to be pushed ✅
- Status: ✅ All information is self-contained and followable

## Unlisted Changes

No unlisted changes found. Changes log accurately captures the Phase 6 modification:
- `README.md:380` — Inserted `## Development` section (38 lines) after the Installation section

The changes log notes the section contains 38 lines, while manual count shows 36 content lines (difference due to counting boundaries and divider; immaterial).

## Research Coverage

No prior research document exists for this task (plan was derived from direct audit). Phase 6 requirements were derived from the plan's success criteria:

- ✅ README has a `## Development` section — confirmed at line 380
- ✅ Section explains branch strategy — confirmed at line 382-384
- ✅ Section explains how to run all 7 tests (5 automated + 2 prompt) — confirmed
- ✅ A reader can follow it cold without this conversation — confirmed by walkthrough above
- ✅ Section placed appropriately in README hierarchy — confirmed after Installation, before Workflow

## Summary

Phase 6 is **100% complete and correct**. All four required subsections are present with their full content:

1. Branch strategy paragraph — clear, concise, requires no context
2. Automated test runner instructions — command, prerequisites, 5 scenarios, success criteria
3. Prompt test instructions — both scripts, prerequisites, workflow, pause-and-assert pattern
4. Prompt script maintenance note — documents update responsibility

Section is placed correctly (after Installation, before Workflow), is self-contained for cold reading, and matches the plan's specification exactly.
