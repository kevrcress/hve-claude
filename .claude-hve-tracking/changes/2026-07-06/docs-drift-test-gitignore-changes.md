# Changes Log: Docs-vs-frontmatter drift test + .gitignore security hygiene
Date: 2026-07-06
Plan: .claude-hve-tracking/plans/2026-07-06/docs-drift-test-gitignore-plan.md
Status: Complete

## Phases

### Phase 1: .gitignore security hygiene entries
Status: Complete
Started: 2026-07-06T19:55:00Z
Completed: 2026-07-06T19:58:26Z

#### Files Modified
- `.gitignore:19-25` — Appended commented credential-file block: `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`

#### Steps Completed
- [x] Step 1.1: Read existing root `.gitignore` (17 lines; no credential patterns present) — `.gitignore:1`
- [x] Step 1.2: Appended commented credential-pattern block with all six patterns — `.gitignore:19-25`
- [x] Step 1.3: Verified no tracked file becomes newly ignored: `git ls-files -i -c --exclude-standard` returned empty; `git check-ignore -v` confirmed all six patterns match their targets (`.gitignore:20-25`); `git status --short` shows only the `.gitignore` modification beyond pre-existing staged changes; installer suite `tests/run-install-tests.sh` still passes 31/31

#### Issues Encountered
None. Note: `*.pfx` is in the plan's pattern set but not in the CLAUDE.md Security Hygiene checklist minimum (`.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`); it is a superset addition per plan step 1.2, not a deviation.

### Phase 2: Drift test script
Status: Complete
Started: 2026-07-06T19:58:30Z
Completed: 2026-07-06T20:01:43Z

#### Files Modified
- `tests/run-drift-tests.sh:1-281` — New executable test script (chmod +x), modeled on `tests/run-install-tests.sh`: `set -euo pipefail`, sources `tests/lib/assert.sh`, `run_test` wrapper with per-test OK/FAIL banners, `finish` tally, exit 0 only on all pass. Four test groups: frontmatter validity (`tests/run-drift-tests.sh:123`), internals.md table sync (`tests/run-drift-tests.sh:154`), CLAUDE.md prose sync (`tests/run-drift-tests.sh:193`), .gitignore hygiene (`tests/run-drift-tests.sh:246`)

#### Steps Completed
- [x] Step 2.1: Read `.claude/instructions/bash.md`; script follows its conventions (shebang, strict mode, `[[ ]]`, `(( ))`, two-space indent, braced+quoted variables, `readonly` constants, `err()`, `main()` at end)
- [x] Step 2.2: Created `tests/run-drift-tests.sh` on the existing harness idiom — `tests/run-drift-tests.sh:20-33` (strict mode, sourcing), `tests/run-drift-tests.sh:89-121` (`run_test`), `tests/run-drift-tests.sh:278` (`finish`)
- [x] Step 2.3a: Frontmatter validity — every `.claude/agents/*.md` has `model:` in {haiku, sonnet, opus, inherit} and `name:` equal to filename stem; frontmatter parsed via awk between `---` delimiters (`tests/run-drift-tests.sh:69-87`)
- [x] Step 2.3b: internals.md table sync — for each agent, the last cell of its `docs/internals.md` table row (Model column) must equal frontmatter `model:` case-insensitively; missing row is a failure (`tests/run-drift-tests.sh:154-186`)
- [x] Step 2.3c: CLAUDE.md Model Selection sync, implemented narrowly per plan: for each agent pinned haiku or sonnet, derive the human name (strip `hve-`, hyphens to spaces, e.g. "plan validator"), split the Model Selection section into clauses on `;`, and fail if a clause naming the agent contains a tier word (haiku/sonnet/opus/inherit) different from frontmatter. Agent not named in prose = pass (no contradiction possible). No DD- needed — the narrow check proved implementable, all 4 pinned agents matched by name in prose (`tests/run-drift-tests.sh:193-239`)
- [x] Step 2.3d: .gitignore hygiene — `assert_contains` for `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12` (`tests/run-drift-tests.sh:246-252`)
- [x] Step 2.4: Ran `tests/run-drift-tests.sh` — Tests: 33 passed, 0 failed, exit 0
- [x] Step 2.5: Ran `tests/run-install-tests.sh` — Tests: 31 passed, 0 failed (31/31, unaffected)

Mutation check (plan success criterion): temporarily changed `hve-plan-validator.md` frontmatter `model: haiku` → `model: opus`; suite failed as expected (test2 caught the internals.md mismatch; Results: 31 passed, 1 failed, exit 1). Reverted exactly; `git diff .claude/agents/hve-plan-validator.md` empty; suite green again (33/33). Note: test3 skips agents pinned `opus` by design — the plan scopes the prose check to agents pinned haiku or sonnet, and test2 covers the observed drift class for all agents.

#### Issues Encountered
- ShellCheck is not installed on this machine, so the bash.md "pass ShellCheck validation" quality item could not be executed. Skip note (2026-07-06): Minor grade, does not affect the prompted functionality (drift detection verified by execution and mutation test); the script mirrors the idioms of the already-reviewed `tests/run-install-tests.sh` and carries a `# shellcheck source=` directive for the sourced library.
- Portability: avoided bash-4-only `${var,,}` lowercasing (macOS ships bash 3.2) in favor of `tr` (`tests/run-drift-tests.sh:62-64`).

## Final Test Pass (2026-07-06, consolidation)

- `tests/run-drift-tests.sh`: 33 passed, 0 failed
- `tests/run-install-tests.sh`: 31 passed, 0 failed

## Security Hygiene Check

- `git diff HEAD --name-only`: no credential-like filenames
- Secret-pattern grep on new/changed files (`tests/run-drift-tests.sh`, `.gitignore`): no matches
- `.gitignore` credential entries: present as of this task (`.gitignore:19-25`) — this check now also runs automatically in `tests/run-drift-tests.sh:246`
