# Installation

The fastest way to install HVE is the paste-to-install prompt in the
[README Quick start](../README.md#quick-start). This document covers the manual
steps, the bash installer, and how to update an existing install.

## Option A: Paste to install (recommended)

Paste this into Claude Code from inside your project directory. Claude will clone
the repo, copy all the files, merge the HVE block into your CLAUDE.md wrapped in
update markers, add the .gitignore rules, and clean up, no shell scripts needed.

```
Please install the HVE Claude Code workflow into this project. Clone
https://github.com/kevrcress/hve-claude into a temporary directory, then
copy its hve-* commands and agents into my .claude/ folder, copy its
.claude/instructions/ and .claude/prompts/ files in, and merge everything above the
'## Your Project' heading in its CLAUDE.md into mine wrapped in these markers:
<!-- HVE:START - managed by hve-claude, do not edit between markers -->
...HVE content...
<!-- HVE:END -->
If my CLAUDE.md already has those markers, replace the content between them.
If it has no markers, prepend the wrapped block before my existing content.
Never touch anything outside the markers or below '## Your Project'. Add the
.claude-hve-tracking subagents and sandbox paths to my .gitignore, then
delete the temp clone and show me what changed.
```

Works on any OS. Claude uses its own file tools, no shell execution required.

## Option B: Manual steps

Follow these steps on any OS (Mac, Windows, Linux):

1. Clone or download the repo to a temporary directory:
   ```bash
   git clone https://github.com/kevrcress/hve-claude /tmp/hve-claude
   ```
   Or download a ZIP from GitHub and unzip to any temp directory.

2. Copy commands into your project (create the directory if needed):
   ```
   Source:  hve-claude/.claude/commands/hve*.md
   Target:  <your-project>/.claude/commands/
   ```

3. Copy agents:
   ```
   Source:  hve-claude/.claude/agents/hve*.md
   Target:  <your-project>/.claude/agents/
   ```

4. Copy instruction files:
   ```
   Source:  hve-claude/.claude/instructions/*.md
   Target:  <your-project>/.claude/instructions/
   ```

5. Copy prompt files:
   ```
   Source:  hve-claude/.claude/prompts/*.md
   Target:  <your-project>/.claude/prompts/
   ```

6. Merge the HVE block into your `CLAUDE.md`. Open `hve-claude/CLAUDE.md` and copy
   everything above the `## Your Project` heading. Wrap it in these markers:
   ```
   <!-- HVE:START - managed by hve-claude, do not edit between markers -->
   ...pasted HVE block...
   <!-- HVE:END -->
   ```
   Then apply the case that matches your project:
   - **No CLAUDE.md yet:** Create one. Paste the wrapped block, then add
     `## Your Project` and your project context below it.
   - **CLAUDE.md exists with the markers:** Replace everything between the markers.
     Leave all content outside the markers untouched.
   - **CLAUDE.md exists without the markers:** Prepend the wrapped block to the top
     of the file. Leave your existing content below it.

7. Add these lines to your `.gitignore` (create if needed). Skip any lines already
   present:
   ```
   # HVE tracking: commit durable artifacts, ignore regenerable noise
   .claude-hve-tracking/**/subagents/
   .claude-hve-tracking/sandbox/
   ```

Re-installing to get updates: repeat steps 1–7, all steps are idempotent.

**Upgrading from an older install?** Two top-level folders have moved:

- Prior versions placed instruction files at `<your-project>/instructions/`. The new location is `<your-project>/.claude/instructions/`.
- Prior versions placed prompt files at `<your-project>/prompts/`. The new location is `<your-project>/.claude/prompts/`.

For each old folder: copy any files that don't already exist in the new location, then for each file in the old folder, if it matches the installed version byte-for-byte, delete it; if it differs (local customization), leave it and migrate manually. Remove the old folder with `rmdir` once empty, never `rm -rf`.

HVE instruction files: `bash.md`, `csharp.md`, `csharp-tests.md`, `python.md`, `python-tests.md`, `python-uv.md`, `rust.md`, `rust-tests.md`, `terraform.md`, `markdown.md`, `git-commit-messages.md`, `writing-style.md`.

HVE prompt files: `checkpoint.md`, `doc-ops.md`, `prompt-build.md`, `pull-request.md`, `rpi.md`, `task-challenge.md`.

## Terminal / bash users (optional)

A bash installer is available for Mac, Linux, WSL, or Git Bash on Windows:

```bash
# From inside your project
/path/to/hve-claude/install.sh

# Or targeting a specific project
./install.sh /path/to/your/project
```

The script runs the same steps as Option B above and is idempotent, safe to
re-run to pull in updates. On upgrade it automatically migrates any old top-level
`instructions/` and `prompts/` folders: identical files are removed silently;
customized files are left in place with a warning.

## Global install (all projects on this machine)

Claude Code loads user-level commands and agents from `~/.claude/` and global
instructions from `~/.claude/CLAUDE.md`, so HVE can be installed once and used
in every project. On Windows, `~` means your user profile folder: the same
paths are `%USERPROFILE%\.claude` (e.g. `C:\Users\you\.claude`). The tracking
folder is unaffected by this choice: `.claude-hve-tracking/` is created inside
whichever project you first run an HVE command in, exactly as with a project
install.

### Paste to install globally (any OS)

Paste this into Claude Code running anywhere on the machine:

```
Please install the HVE Claude Code workflow globally for all my projects.
Clone https://github.com/kevrcress/hve-claude into a temporary directory,
then copy files into my user-level Claude folder (~/.claude on Mac/Linux,
%USERPROFILE%\.claude on Windows): its hve-* commands into commands/, its
hve-* agents into agents/, and its .claude/instructions/ and .claude/prompts/
files into instructions/ and prompts/ there. Merge everything above the
'## Your Project' heading in its CLAUDE.md into the CLAUDE.md in that same
user-level folder, wrapped in these markers:
<!-- HVE:START - managed by hve-claude, do not edit between markers -->
...HVE content...
<!-- HVE:END -->
If that CLAUDE.md already has those markers, replace the content between
them. If it has no markers, prepend the wrapped block before the existing
content. If it does not exist, create it with the block followed by a
'## Your Global Context' heading. Do not modify any .gitignore, but remind
me to add .claude-hve-tracking/**/subagents/ and .claude-hve-tracking/sandbox/
to the .gitignore of each project where I use HVE. Delete the temp clone and
show me what changed.
```

Re-paste the same prompt later to update; the markers keep it idempotent.

### Bash users (Mac, Linux, WSL, Git Bash on Windows)

```bash
/path/to/hve-claude/install.sh --global
```

The script installs to `$HOME/.claude`. In Git Bash, `$HOME` is your Windows
user profile, which is where Claude Code on Windows looks, so the result is the
same as the paste prompt. In WSL it installs to your WSL home, which is correct
for Claude Code running inside WSL (but invisible to a Windows-native Claude
Code; use the paste prompt for that).

What differs from a project install:

- Files go to `~/.claude/commands/`, `~/.claude/agents/`, `~/.claude/instructions/`,
  and `~/.claude/prompts/`.
- The HVE block merges into `~/.claude/CLAUDE.md` (wrapped in the same update
  markers), not into a project `CLAUDE.md`.
- **No `.gitignore` changes are made** (those are per-project). Add these lines to
  the `.gitignore` of each project where you use HVE:
  ```
  # HVE tracking: commit durable artifacts, ignore regenerable noise
  .claude-hve-tracking/**/subagents/
  .claude-hve-tracking/sandbox/
  ```

Manual alternative: follow the Option B manual steps, substituting `~/.claude/`
(Windows: `%USERPROFILE%\.claude\`) for `<your-project>/.claude/` in steps 2–5,
merging the block into the `CLAUDE.md` in that folder in step 6, and skipping
step 7.

**Pick one mode per project.** If a project has its own copies of the hve-*
commands and agents, they shadow the global ones and each command shows up twice
in the command list. To switch an already-installed project over to the global
install, delete the project's `.claude/commands/hve*.md` and
`.claude/agents/hve*.md` and remove the HVE marker block from its `CLAUDE.md`.

Updating a global install: re-run `./install.sh --global` from an updated clone,
or re-paste the global install prompt. Both are idempotent, same as project mode.

## Updating an existing install

Paste this into Claude Code from inside your project directory. It overwrites
commands, agents, instruction files, and prompts with the latest versions,
refreshes the HVE block in your `CLAUDE.md` without touching your `## Your Project`
content, and migrates any old top-level `instructions/` folder to
`.claude/instructions/` (identical files removed silently; customized files left
with a warning).

```
Please update the HVE Claude Code workflow in this project. Clone
https://github.com/kevrcress/hve-claude into a temporary directory, then
overwrite the hve-* files in .claude/commands/ and .claude/agents/, overwrite
all files in .claude/instructions/ and .claude/prompts/ with the latest versions, and
update the HVE block in my CLAUDE.md with the new content from the cloned
repo (everything above its '## Your Project' heading), wrapped in these
markers:
<!-- HVE:START - managed by hve-claude, do not edit between markers -->
...HVE content...
<!-- HVE:END -->
If my CLAUDE.md already has those markers, replace the content between them.
If it has no markers, find the existing HVE block (it begins with the HVE
heading and ends just before my project-specific content), replace it with the
new content wrapped in the markers above. Never touch anything outside the
markers or my project-specific content. If an instructions/ folder exists at
the project root from a prior install, move any file that matches the installed
version byte-for-byte to .claude/instructions/ and remove the folder once it
is empty. If a prompts/ folder exists at the project root from a prior install,
do the same: move matching files to .claude/prompts/ and remove the folder once
empty. Delete the temp clone and show me what changed.
```

Other update paths: follow the Option B manual steps again, or re-run `install.sh`
(bash users). All three are idempotent, they overwrite the command and agent
files but preserve your `## Your Project` section in `CLAUDE.md`.
