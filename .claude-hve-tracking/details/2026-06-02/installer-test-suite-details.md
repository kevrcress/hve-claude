# Implementation Details: Installer test suite
Date: 2026-06-02
Task slug: installer-test-suite

## Fixture file content specifications

### tests/fixtures/claude-md-no-hve.md
A minimal CLAUDE.md that represents a project with existing project-specific content but no HVE. The installer's "prepend" branch fires for this case.

```markdown
# My Project

This is my project's CLAUDE.md with some existing content.

## Guidelines

- Follow existing patterns
- Write tests
```

### tests/fixtures/claude-md-old-marker.md
Represents a project with an older HVE install that used the em-dash marker. The `## Your Project` section must contain a unique sentinel string (`SENTINEL_YOUR_PROJECT_CONTENT`) so assertions can verify it survived the upgrade untouched.

```markdown
<!-- HVE:START — managed by install.sh, do not edit between markers -->
# HVE Claude — Old Version

This is stub old HVE content.
<!-- HVE:END -->

## Your Project
SENTINEL_YOUR_PROJECT_CONTENT
My project-specific context goes here.
```

Note: the em-dash (—) is U+2014, a 3-byte UTF-8 sequence. The grep pattern in install.sh is `<!-- HVE:START` which matches both variants since it stops before the dash character.

### tests/fixtures/claude-md-current-marker.md
Represents a project with the current marker format but older HVE content — used for clean upgrade and diverged upgrade tests.

```markdown
<!-- HVE:START - managed by install.sh, do not edit between markers -->
# HVE Claude — Older Version

This is stub older HVE content that should be replaced.
<!-- HVE:END -->

## Your Project
SENTINEL_YOUR_PROJECT_CONTENT
My project-specific context goes here.
```

## Assertion library design

### Counter pattern
```bash
PASS=0
FAIL=0

_ok()   { echo "    [pass] $1"; PASS=$((PASS+1)); }
_fail() { echo "    [FAIL] $1"; FAIL=$((FAIL+1)); }
```

### Subshell isolation in run_test
Each test body runs in a subshell so `set -e` failures don't abort the runner:

```bash
run_test() {
  local name="$1"; local body="$2"
  echo "[ TEST ] $name"
  (eval "$body") && echo "[  OK  ] $name" || echo "[ FAIL ] $name"
}
```

Wait — this won't work cleanly with the PASS/FAIL counters since subshells don't share variables. Instead, use a function-based approach where assertions write to a temp file:

```bash
ASSERT_LOG="$(mktemp)"

assert_exists() {
  if [ -e "$1" ]; then
    echo "PASS: exists: $1" >> "$ASSERT_LOG"
  else
    echo "FAIL: missing: $1" >> "$ASSERT_LOG"
  fi
}

finish() {
  PASS=$(grep -c '^PASS' "$ASSERT_LOG" || true)
  FAIL=$(grep -c '^FAIL' "$ASSERT_LOG" || true)
  echo "$PASS passed, $FAIL failed"
  [ "$FAIL" -eq 0 ]
}
```

This way the log file accumulates across the whole run and `finish` tallies at the end.

## The 12 HVE instruction filenames

Used in Test 3 (seeding `instructions/`) and Test 4 (seeding + diverging):

```
bash.md csharp.md csharp-tests.md python.md python-tests.md python-uv.md
rust.md rust-tests.md terraform.md markdown.md git-commit-messages.md writing-style.md
```

These match `HVE_INSTRUCTION_FILES` in `install.sh:57-60`.

## Seeding instructions/ for upgrade tests

```bash
seed_old_instructions() {
  local target="$1"
  local source="$REPO_ROOT/.claude/instructions"
  mkdir -p "$target/instructions"
  for fname in bash.md csharp.md csharp-tests.md python.md python-tests.md python-uv.md \
               rust.md rust-tests.md terraform.md markdown.md git-commit-messages.md writing-style.md; do
    cp "$source/$fname" "$target/instructions/$fname"
  done
}
```

## assert-prompt-install.sh --upgrade flag

```bash
UPGRADE=0
for arg in "$@"; do
  [ "$arg" = "--upgrade" ] && UPGRADE=1
done
TARGET="${1:-}"
[ -z "$TARGET" ] && { echo "Usage: $0 <target-dir> [--upgrade]"; exit 1; }
```
