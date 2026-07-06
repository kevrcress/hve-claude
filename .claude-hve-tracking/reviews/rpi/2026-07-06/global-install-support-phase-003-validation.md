# RPI Validation: Global install support — Phase 3 (Documentation)
Date: 2026-07-06
Plan phase: Phase 3: Documentation
Coverage: 100%
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Phase 3.1: docs/installation.md new "Global install" section | Found | `docs/installation.md:118-158` | ✅ Implemented |
| Phase 3.2: README.md Installation pointer paragraph | Found | `README.md:197` | ✅ Implemented |
| Phase 3.3: CLAUDE.md install section --global usage line and paragraph | Found | `CLAUDE.md:271-283` | ✅ Implemented |

## Findings

### IV-001 [MINOR]
**Finding type:** Line range accuracy
**Claim:** Changes log lists `docs/installation.md:118-158` for the Global install section.
**Evidence:** Heading "## Global install" at line 118; section continues through line 193 (through the Windows path manual alternative and shadowing caveat). Closing line 194 begins "## Updating an existing install".
**Status:** Claimed range is conservative (ends at 158, actual section extends to 193). No content is missing or falsified; the section spans lines 118-193, so line 158 is within bounds but incomplete. This is a record-consistency minor finding.
**Impact:** Changes log underspecifies the section boundaries; the full extent of the Phase 3 documentation work is not fully captured in the cited range.
**Recommendation:** Update changes log to cite `docs/installation.md:118-193` for accuracy, or confirm that lines 159-193 are Phase 4 (Windows compatibility) additions.

## Verification Details

### docs/installation.md
- **Heading present at line 118:** "## Global install (all projects on this machine)" ✅
- **Windows path equivalence:** Line 122-123 documents `%USERPROFILE%\.claude` on Windows ✅
- **Paste prompt at lines 128-153:** Includes any-OS global install instructions ✅
- **Bash flag documentation at lines 155-159:** Shows `./install.sh --global` ✅
- **Per-project .gitignore rules at lines 173-179:** Proper documentation of per-project requirement ✅
- **Shadowing caveat at lines 186-190:** States "Pick one mode per project. If a project has its own copies... they shadow the global ones" ✅
- **Update path documented at lines 192-193:** "Updating a global install: re-run `./install.sh --global`..." ✅
- **Em-dash check:** No em-dashes detected in Phase 3 additions ✅

### README.md
- **Line 197 pointer paragraph present:** Yes ✅
- **Paragraph content:** "Prefer HVE in every project on your machine? Install it once globally: commands and agents go to your user-level `~/.claude/` folder (`%USERPROFILE%\.claude` on Windows) and work everywhere, while each project still gets its own `.claude-hve-tracking/` folder on first use. Use `./install.sh --global` (Mac/Linux/WSL/Git Bash) or the any-OS paste prompt in [Global install](docs/installation.md#global-install-all-projects-on-this-machine)." ✅
- **Anchor link target:** `docs/installation.md#global-install-all-projects-on-this-machine` correctly maps to heading at line 118: "## Global install (all projects on this machine)" (markdown anchor: `#global-install-all-projects-on-this-machine`) ✅
- **Windows path inclusion:** Yes, `%USERPROFILE%\.claude` mentioned ✅
- **Both install paths offered:** Yes, `./install.sh --global` and paste prompt both referenced ✅

### CLAUDE.md
- **Section location:** "Installing HVE in Your Project" heading at line 267 ✅
- **--global usage line at line 273:** `./install.sh --global                # or install once for every project (~/.claude)` ✅
- **Windows path at lines 280-281:** "With `--global`, files go to `~/.claude/` (`%USERPROFILE%\.claude` on Windows)..." ✅
- **Paragraph at lines 280-285:** Comprehensive summary of global mode behavior, .gitignore skipping, shadowing caveat ✅
- **Windows users guidance at line 282-283:** "Windows users without bash: use the global paste-to-install prompt in docs/installation.md instead." ✅
- **Per-project .gitignore reminder at lines 283-284:** "Global mode skips `.gitignore`: add the tracking rules below to each project where you use HVE" ✅
- **Em-dash check:** No em-dashes in CLAUDE.md Phase 3 additions ✅

## Cross-Document Consistency Check

| Aspect | docs/installation.md | README.md | CLAUDE.md | Match |
|---|---|---|---|---|
| Global path on Mac/Linux | `~/.claude/` | `~/.claude/` | `~/.claude/` | ✅ |
| Global path on Windows | `%USERPROFILE%\.claude` | `%USERPROFILE%\.claude` | `%USERPROFILE%\.claude` | ✅ |
| Bash flag format | `./install.sh --global` | `./install.sh --global` | `./install.sh --global` | ✅ |
| Per-project .gitignore required | Documented (lines 173-179) | Implied in pointer | Documented (lines 283-284) | ✅ |
| Shadowing caveat present | Yes (lines 186-190) | Not required in README | Yes (lines 284-285) | ✅ |
| Update path documented | Yes (lines 192-193) | Not required in README | Not explicit but implied | ✅ |

## Research Coverage

Plan header stated: "Research: none (plan authored inline; motivated by a working manual global install at ~/.claude discovered in session, with no installer or docs support for it)."

Verification confirms:
- Documentation thoroughly covers the `~/.claude/` global path pattern ✅
- Windows compatibility (`%USERPROFILE%\.claude`) documented in all three files ✅
- Per-project .gitignore rules clearly stated ✅
- Shadowing/double-install caveat prominently placed ✅
- Update paths documented for both bash and paste prompts ✅

## Unlisted Changes

No files modified outside of those listed in the changes log for Phase 3 (docs/installation.md, README.md, CLAUDE.md).

## Summary

All Phase 3 plan items implemented:
- docs/installation.md new section: implemented with all required elements (bash flag, manual variant, per-project rules, shadowing caveat, update path)
- README.md pointer: implemented with accurate anchor link matching the heading in docs/installation.md
- CLAUDE.md install section: implemented with --global usage line and summary paragraph

Line range inconsistency (IV-001) is a minor record-accuracy issue that does not affect the actual completeness or correctness of the implementation. All content required by the plan is present and internally consistent across the three documents.

No em-dashes detected; em-dash compliance met.
