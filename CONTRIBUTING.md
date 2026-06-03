# Contributing to hve-claude

Thanks for your interest in improving hve-claude. This document covers the branch
workflow and how to test changes locally before they land.

## Branch strategy

Work happens on `feature/` branches, which merge into `dev`. Once all tests pass
on `dev`, it merges into `main`. Nothing goes directly to `main`; all changes are
tested before they land.

```
feature/your-change  →  dev  →  main
```

## Running the automated tests

No network connection required. Run from the repo root:

```bash
./tests/run-install-tests.sh
```

Covers 5 `install.sh` scenarios: new install, prepend case, clean upgrade, old
em-dash marker upgrade, and diverged upgrade. All tests should print `[ OK ]`.

## Running the prompt tests

These test the natural-language install and update prompts from the README. They
require:

1. The `dev` branch pushed to GitHub (the scripts clone `dev`)
2. Claude Code available in your terminal

Run each script separately; each seeds a temp project, prints the exact prompt to
paste, and waits:

```bash
./tests/run-prompt-new-install.sh   # tests the Option A install prompt
./tests/run-prompt-upgrade.sh       # tests the update prompt
```

Open Claude Code in the directory shown, paste the prompt, then press Enter when
Claude finishes. The script asserts the expected outcome and prints a pass/fail
summary.

### Prompt script maintenance

The prompt scripts embed the Option A and update prompts verbatim, with the clone
URL pointing to the `dev` branch. If those prompts change in a future release,
update the corresponding script to match.

## Manual install.sh checks

The automated suite covers these, but if you want to verify the install and update
paths by hand, run all commands below from the root of this repo.

### Idempotent upgrade

Run against a throwaway copy of an existing HVE project:

```bash
cp -r /path/to/existing-hve-project /tmp/hve-upgrade-test
./install.sh /tmp/hve-upgrade-test
```

Expected: `✓ updated CLAUDE.md HVE block` (not `created`). Diff `CLAUDE.md` to
confirm only the content between the `HVE:START` / `HVE:END` markers changed and
your `## Your Project` section is untouched.

### Migration from old instructions/ layout

Simulate a pre-migration install on the same copy, then run the installer:

```bash
mkdir /tmp/hve-upgrade-test/instructions
cp /tmp/hve-upgrade-test/.claude/instructions/*.md /tmp/hve-upgrade-test/instructions/
./install.sh /tmp/hve-upgrade-test
```

Expected: `✓ migrated instructions/ to .claude/instructions/`. To exercise the
"differs" warning path, modify one file before running:

```bash
echo "# local customization" >> /tmp/hve-upgrade-test/instructions/python.md
./install.sh /tmp/hve-upgrade-test
# python.md should be warned and kept; all other files removed; instructions/ left non-empty
```

### Fresh install

Run against a project that doesn't have HVE yet:

```bash
./install.sh /path/to/project-without-hve
```

Expected: `✓ created CLAUDE.md` (or `✓ prepended HVE block` if the project already
has a CLAUDE.md without markers). Confirm `.claude/commands/`, `.claude/agents/`,
`.claude/instructions/`, and `prompts/` were all created.

Reset between test runs with `rm -rf /tmp/hve-upgrade-test`.

### Natural language update prompt

Open a new Claude Code session inside an existing HVE project and paste the update
prompt from [docs/installation.md](docs/installation.md#updating-an-existing-install).
Verify:

1. The temp clone is deleted when Claude finishes
2. Commands, agents, instructions, and prompts were overwritten
3. Only the content between `HVE:START` / `HVE:END` in `CLAUDE.md` changed;
   `## Your Project` is untouched
