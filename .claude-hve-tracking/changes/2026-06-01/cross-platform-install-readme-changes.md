# Changes Log: Make HVE installation cross-platform and script-free in the README
Date: 2026-06-01
Plan: .claude-hve-tracking/plans/2026-06-01/cross-platform-install-readme-plan.md
Status: Complete

## Phases

### Phase 1: Rewrite the Quick Start section
Status: Complete
Started: 2026-06-01T00:00:00Z
Completed: 2026-06-01T00:00:00Z

#### Files Modified
- `README.md:30–45` — Quick Start step 1 prompt and callout updated

#### Steps Completed
- [x] Step 1.1: Replace Step 1 paste prompt with exact Option A prompt — `README.md:30–33`
- [x] Step 1.2: Update "Prefer the terminal?" callout to link Installation section — `README.md:45`

#### Issues Encountered
None

---

### Phase 2: Rewrite the Installation section
Status: Complete
Started: 2026-06-01T00:00:00Z
Completed: 2026-06-01T00:00:00Z

#### Files Modified
- `README.md:210–300` — Installation section rewritten (Option A + Option B + bash optional callout); "Step 2: Add your project context" renamed to "Add your project context"

#### Steps Completed
- [x] Step 2.1: Add Option A subsection — `README.md:210`
- [x] Step 2.2: Add Option B subsection (7 manual steps with 3 CLAUDE.md merge cases) — `README.md:228`
- [x] Step 2.3: Add Terminal/bash optional callout (demoted install.sh to optional, bash-only) — `README.md:284`
- [x] Step 2.4: Keep existing "Add your project context" and "Tracking folder and version control" sections intact; renamed "Step 2: Add your project context" to drop "Step 2:" prefix — `README.md:300`

#### Issues Encountered
None

---

### Phase 3: Update FAQ "How do I update HVE"
Status: Complete
Started: 2026-06-01T00:00:00Z
Completed: 2026-06-01T00:00:00Z

#### Files Modified
- `README.md:588` — FAQ "How do I update HVE in my project?" answer updated to list all three update paths

#### Steps Completed
- [x] Step 3.1: Update FAQ answer to list all three update paths — `README.md:588`

#### Issues Encountered
None

---

## Security Hygiene Check
- Modified files: `README.md` only — documentation, no secrets, no credentials
- Secret pattern scan (PRIVATE KEY, api_key=, password=, Bearer, -----BEGIN): **0 hits**
- Credential-like filenames in diff: none
- .gitignore: `.env`, `*.pem`, `*.key` not applicable to this change
- Status: **PASS**
