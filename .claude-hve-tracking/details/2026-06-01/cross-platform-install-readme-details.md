# Implementation Details: Make HVE installation cross-platform and script-free in the README
Date: 2026-06-01
Task slug: cross-platform-install-readme

## Exact Option A prompt (must be verbatim)

```
Please install the HVE Claude Code workflow into this project. Clone
https://github.com/kevrcress/hve-claude into a temporary directory, then
copy its hve-* commands and agents into my .claude/ folder, copy its
instructions/ and prompts/ files in, and merge everything above the
'## Your Project' heading in its CLAUDE.md into mine without disturbing my
own content. Add the .claude-hve-tracking subagents and sandbox paths to
my .gitignore, then delete the temp clone and show me what changed.
```

Note: the requirement says "Use this exact prompt for consistency with the blog post." Do not paraphrase or reformat.

## Option B manual steps — exact content

Derived from install.sh:36–99.

**Step 1** — Clone or download the repo:
```bash
git clone https://github.com/kevrcress/hve-claude /tmp/hve-claude
```
Or download a ZIP from GitHub and unzip to any temp directory.

**Step 2** — Copy commands (create target dir if needed):
```
Source:  hve-claude/.claude/commands/hve*.md
Target:  <your-project>/.claude/commands/
```

**Step 3** — Copy agents:
```
Source:  hve-claude/.claude/agents/hve*.md
Target:  <your-project>/.claude/agents/
```

**Step 4** — Copy instructions:
```
Source:  hve-claude/instructions/*.md
Target:  <your-project>/instructions/
```

**Step 5** — Copy prompts:
```
Source:  hve-claude/prompts/*.md
Target:  <your-project>/prompts/
```

**Step 6** — Merge CLAUDE.md (three cases):

Open `hve-claude/CLAUDE.md` and copy everything above the `## Your Project` heading. This is the HVE block.

Wrap it in these markers:
```
<!-- HVE:START — managed by install.sh, do not edit between markers -->
...pasted HVE block...
<!-- HVE:END -->
```

Then apply the appropriate case for your project:

- **No CLAUDE.md yet:** Create it. Paste the wrapped block, then add `## Your Project\n\n<!-- Add your project-specific context below this line. -->` below it.
- **CLAUDE.md exists WITH the markers:** Replace everything between the markers with the new HVE block content. Leave all content outside the markers untouched.
- **CLAUDE.md exists WITHOUT the markers:** Prepend the wrapped block to the top of the file. Leave your existing content below it.

**Step 7** — Add .gitignore rules:

Add these lines to `<your-project>/.gitignore` (create if needed). Add only lines not already present:
```
# HVE tracking — commit durable artifacts, ignore regenerable noise
.claude-hve-tracking/**/subagents/
.claude-hve-tracking/sandbox/
```

**Step 8** — Delete temp clone (optional):
```bash
rm -rf /tmp/hve-claude
```

## Quick Start section — target state

### Before (README.md:30–45):
```
1. Paste this into Claude Code in your project directory to install HVE:
\`\`\`
Please install HVE into this project: clone https://github.com/kevrcress/hve-claude to a temporary directory, run install.sh targeting the current directory, then clean up the temp clone.
\`\`\`
...
> **Prefer the terminal?** Clone the repo anywhere outside your project and run `./hve-claude/install.sh /path/to/your/project` manually.
```

### After:
Step 1 uses the exact Option A prompt verbatim (no install.sh mention).
Callout: "Prefer the terminal or bash?" → "See the [Installation](#installation) section for manual steps and the bash installer option."

## Installation section — target structure

```
## Installation

### Option A — Paste to install (recommended)
[one-sentence description]
[code block with exact Option A prompt]
[one-sentence note: Claude clones, copies, merges, cleans up]

### Option B — Manual steps
[numbered 1–7 derived from steps above]

### Terminal / bash users (optional)
[2–3 sentences: install.sh is available for Mac/Linux/WSL/Git Bash, usage lines]

### Add your project context
[unchanged: CLAUDE.md ## Your Project instructions]

### Tracking folder and version control
[unchanged]
```

## FAQ "How do I update HVE" — target state

Before: "Pull the latest from this repo and re-run `install.sh` — it's idempotent."
After: Mention all three update paths: Option A (re-paste), Option B (re-copy), bash (re-run install.sh). All are idempotent.

## Files changed

| File | Change |
|---|---|
| `README.md` | Quick Start step 1, Quick Start callout, Installation section rewrite, FAQ update |

No other files change. `install.sh` is NOT deleted or modified.
