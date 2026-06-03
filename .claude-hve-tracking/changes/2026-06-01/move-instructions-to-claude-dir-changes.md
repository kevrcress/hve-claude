# Changes Log: Move instruction files from instructions/ to .claude/instructions/
Date: 2026-06-01
Plan: .claude-hve-tracking/plans/2026-06-01/move-instructions-to-claude-dir-plan.md
Status: Complete

## Phases

### Phase 1: Move instruction files
Status: Complete

#### Files Modified
- `instructions/*.md` (11 files) → `.claude/instructions/*.md` via `git mv`

#### Steps Completed
- [x] Step 1.1: `git mv` all 11 instruction files to `.claude/instructions/`
- [x] Step 1.2: `instructions/` directory removed from index

#### Issues Encountered
None

---

### Phase 2: Update internal references in agents and commands
Status: Complete

#### Files Modified
- `.claude/agents/hve-phase-implementor.md` — 4 occurrences updated
- `.claude/agents/hve-prompt-updater.md` — 1 occurrence updated
- `.claude/commands/hve-implement.md` — 2 occurrences updated
- `.claude/commands/hve-git-commit.md` — 2 occurrences updated
- `.claude/commands/hve-git-merge.md` — 1 occurrence updated
- `.claude/commands/hve-prompt-analyze.md` — 1 occurrence updated
- `.claude/commands/hve-prompt-builder.md` — 2 occurrences updated

#### Steps Completed
- [x] Step 2.1: Replace all bare `instructions/` references with `.claude/instructions/` across 7 agent/command files

#### Issues Encountered
None

---

### Phase 3: Update references in CLAUDE.md and prompts
Status: Complete

#### Files Modified
- `CLAUDE.md` — 12 table rows + 1 installer description paragraph updated
- `prompts/doc-ops.md` — 1 excludes list entry updated
- `prompts/prompt-build.md` — 1 artifact type list entry updated

#### Steps Completed
- [x] Step 3.1: Updated Instructions Reference table in `CLAUDE.md` (12 rows)
- [x] Step 3.2: Updated installer description paragraph in `CLAUDE.md`
- [x] Step 3.3: Updated `prompts/doc-ops.md` excludes list
- [x] Step 3.4: Updated `prompts/prompt-build.md` artifact type list

#### Issues Encountered
None

---

### Phase 4: Update README.md
Status: Complete

#### Files Modified
- `README.md` — Option B step 4, upgrade callout, Terminal section description, new "Updating an existing install" subsection, FAQ update answer

#### Steps Completed
- [x] Step 4.1: Updated Option B step 4 source/target paths
- [x] Step 4.2: Rewrote "Upgrading from an older install?" callout with migration instructions
- [x] Step 4.3: Updated Terminal/bash description to mention auto-migration
- [x] Step 4.4: Added "Updating an existing install" subsection with natural language update prompt
- [x] Step 4.5: Updated FAQ "How do I update HVE?" to reference the new update prompt

#### Issues Encountered
None

---

### Phase 5: Update install.sh
Status: Complete

#### Files Modified
- `install.sh` — `mkdir -p` line, `cp` source path, migration block added (~40 lines)

#### Steps Completed
- [x] Step 5.1: Updated `mkdir -p` to create `$TARGET/.claude/instructions/`; removed `$TARGET/instructions` target
- [x] Step 5.2: Updated `cp` source to `$SOURCE/.claude/instructions/*.md`
- [x] Step 5.3: Added migration block with `cmp -s` check per known HVE filename; warns on diverged files; `rmdir` old dir when empty

#### Issues Encountered
None

---

### Minor Finding Remediation (2026-06-02)
Status: Complete

#### Files Modified
- `install.sh` — added source structure guard after SOURCE/TARGET validation
- `README.md` — added 12-filename list to "Upgrading from an older install?" callout

#### Steps Completed
- [x] IV-001: Added `[ -d "$SOURCE/.claude/commands" ] || [ -d "$SOURCE/.claude/instructions" ]` guard with explicit error message — `install.sh:31–35`
- [x] IV-002: Added enumerated list of 12 HVE instruction filenames to Option B upgrade callout — `README.md`

---

## Security Hygiene Check
- Modified files: source/agent/command/prompt/script files only — no credentials, no env files
- Secret pattern scan (PRIVATE KEY, api_key=, password=, Bearer, -----BEGIN): **0 hits**
- Credential-like filenames in diff: none
- Status: **PASS**
