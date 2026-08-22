# Implementation Details: Remediate the 2026-08-10 full-repo senior review

Date: 2026-08-15
Task slug: full-repo-review-remediation
Plan: `.claude-hve-tracking/plans/2026-08-15/full-repo-review-remediation-plan.md`

Expanded technical detail for the steps where the plan checklist is not self-sufficient.

---

## 1. Phase 1: the exact `install.sh` change (verified)

Anchor: `install.sh:239-240`, inside the `if [ "$GLOBAL" -eq 0 ]` branch.

Current:
```sh
  add_ignore '.claude-hve-tracking/**/subagents/'
  add_ignore '.claude-hve-tracking/sandbox/'
```

Target (this exact text was executed against three scratch targets during planning):
```sh
  add_ignore '.claude-hve-tracking/**/subagents/'
  add_ignore '.claude-hve-tracking/sandbox/'
  if ! grep -qF "# HVE security hygiene" "$GITIGNORE" 2>/dev/null; then
    printf '\n# HVE security hygiene: never commit credentials\n' >> "$GITIGNORE"
  fi
  add_ignore '.env'
  add_ignore '.env.*'
  add_ignore '*.pem'
  add_ignore '*.key'
  add_ignore '*.p12'
```

Why the header needs its own guard: `add_ignore` already guards each rule with `grep -qxF`, but the comment line is written by `printf` outside that helper. Without the `grep -qF` guard the header duplicates on every re-run.

Why `$GLOBAL -eq 0` placement matters: global mode has no project `.gitignore` to write. The existing else-branch prints the skip message. Credential patterns are per-project for the same reason the tracking rules are, so they belong in the same branch.

Observed output, fresh target:
```
# HVE tracking: commit durable artifacts, ignore regenerable noise
.claude-hve-tracking/**/subagents/
.claude-hve-tracking/sandbox/

# HVE security hygiene: never commit credentials
.env
.env.*
*.pem
*.key
*.p12
```

Observed output, target that already had `node_modules/`, `.env`, `*.key`: the installer appended only `.env.*`, `*.pem`, `*.p12`, leaving the user's existing two lines untouched and unduplicated.

### Install-suite test shape (Step 1.2)

Follow the existing harness conventions in `tests/run-install-tests.sh` (`assert_contains`, `_ok_inline`, `_fail_inline`, per-test temp dirs under a suite-level `mktemp -d`). Three assertions:

1. Fresh install: for each of the five patterns, the target `.gitignore` contains it as a whole line.
2. Idempotency: after a second install, `grep -cxF` each pattern returns exactly 1, and the header comment returns exactly 1.
3. Pre-populated: a target seeded with `.env` and `*.key` ends with exactly one of each and gains the three missing patterns.

Case 3 is the one that would catch a naive `printf`-append implementation, so it is not optional.

---

## 2. Phase 5: mechanics of the drift-test changes

### Test 6 (`tests/run-drift-tests.sh:346-390`)

Two constants drive it:
```sh
readonly FRICTION_FLAG_PREFIX='If `--friction-log`'
readonly FRICTION_EXPECTED_COUNT=6
```

Carrier discovery is `grep -qF -- "${FRICTION_FLAG_PREFIX}"` across `${COMMANDS_DIR}/*.md`. Two consequences for Step 5.1:

- The replacement reference line **must not start with** `` If `--friction-log` ``. If it does, the carrier count stays at 6 and the dedup is invisible to the test. Suggested replacement opener: "Friction capture: see CLAUDE.md's Friction Capture section." Wording is free as long as it avoids the prefix.
- `FRICTION_EXPECTED_COUNT` changes to 1 and the corpus must widen to include `CLAUDE.md`, since the canonical copy lives there and `${COMMANDS_DIR}/*.md` alone would then find zero carriers. Simplest path: retire `test6_friction_flag_boilerplate` as a bespoke function and fold the friction block into `CANONICAL_BLOCK_SPECS`, whose corpus (`canonical_block_corpus()`) already includes `CLAUDE.md`.

Folding test 6 into the spec table is the recommended implementation: it removes ~45 lines of near-duplicate test code, and the spec table already supports exactly this assertion shape. Note the irony worth recording in the changes log: test 6 is itself duplicated logic of test 10.

### Test 10 (`tests/run-drift-tests.sh:550-561`)

Spec format is `label|expected_carrier_count|mode|fixed-string line prefix`. Entries affected:

| Spec | Now | After Phase 5 | Driven by |
|---|---|---|---|
| `discovery_stub` | `3\|identical` | `1\|identical` | RL-08 removes the `hve-memory` copy; Step 5.7 adds a *reference* (not a copy) to `hve-implement`, so the count drops rather than rising |
| `concurrent_writes` | `4\|identical` | `1\|identical` | RL-06 |
| friction block (new entry) | n/a | `1\|identical` | RL-03, folded in from test 6 |

The security-hygiene checklist (RL-04) and "Shell stays in the parent" (RL-05) have **no** current spec entry. Add them as `1|identical` entries so the same uniqueness guarantee covers them going forward. This is net-new coverage.

Note the short-circuit behavior already built in (`tests/run-drift-tests.sh:581-600`): a carrier-count mismatch skips the identity diff, because "a block that vanished from a file is the signal, not the identity diff." That is the correct behavior for the inverted assertion too, no harness change needed.

### New test 14: reference resolution

Purpose: catch the failure mode dedup introduces. A pointer like "see CLAUDE.md's Friction Capture section" rots silently when the section is renamed.

Shape, following test 9 and test 12:
1. Grep `.claude/commands/*.md`, `.claude/agents/*.md`, `.claude/prompts/*.md` for the reference construction.
2. Extract the section name.
3. Assert a matching `^##+ ` heading exists in `CLAUDE.md`.

This requires a consistent reference syntax across all Phase 5 edits. **Pick one form and use it verbatim everywhere**, for example: ``per CLAUDE.md's `Friction Capture` section``. Backticks around the section name make extraction a simple `sed`/`grep -o` rather than prose parsing. Every step in Phases 5, 6, and 10 that writes a reference must use this form, or test 14 will not see it.

Fallback if extraction proves brittle (recorded as the DD-004 guard): assert the literal section name string appears as a heading line in `CLAUDE.md`, which is the same guarantee with a looser matcher.

### New test 15: behavioral presence

Purpose: RO-03's actual complaint. Two assertions:
1. Every command that discovers tracking artifacts (`hve-plan`, `hve-implement`, `hve-review`, `hve-challenge`, `hve-memory`) carries a discovery reference. Carrier count is a **floor**, not an equality, so adding a sixth discovering command does not fail the suite spuriously.
2. Every consumer of a reconstructible input (research, details) carries a record-skip branch. After Phase 9 this covers `hve-plan.md`, `hve-review.md`, and `hve-implement.md`.

Assertion 2 will fail until Step 9.1 lands. Write test 15 in Phase 5 with assertion 1 active and assertion 2 added in Phase 9, or the Phase 5 boundary gate cannot go green. Recorded here because it is the one cross-phase test dependency in the plan.

---

## 3. Phase 7: what "wire `--mode`" means concretely

The pattern to copy is `hve-plan.md:43`, one line:
```
If MODE is set (from `--mode`), use it. Otherwise, infer from complexity.
```

### `hve-review.md` (Step 7.1, closes DEFECT 2 + PS-05)

Phase 3 of that file currently spawns exactly one `hve-implementation-validator` unconditionally. Target behavior, aligned to `hve.md`'s existing mode table:

| `--mode` | Review Phase 3 dispatch |
|---|---|
| `lightweight` | Single validator (current behavior) |
| `standard` | Single validator |
| `full` | Parallel RPI + quality validators, which is what `hve.md:40` already promises |

Unset: infer from the task's difficulty grade, mirroring the Phase 2 Simple carve-out at `hve-review.md:79`. This is the branch PS-05 found missing.

### `hve-implement.md` (Step 7.2, closes FC-02)

The branches already exist and only need `MODE` to feed them:

| `--mode` | Effect | Existing anchor |
|---|---|---|
| `lightweight` | Force the Simple carve-out: no subagents, implement directly, still writing the changes log and running the test gate | `hve-implement.md:88` |
| `standard` | Dispatch phase implementors sequentially | current default |
| `full` | Dispatch independent phases in parallel | `hve-implement.md:107` |

Unset: current behavior, grade-driven, unchanged.

Important: `--mode lightweight` must **not** suppress the changes log or the test gate. Line 88's existing wording already guarantees this ("still creating and updating the changes log and running the test gate"), and it is protected by the `simple_carveout_guarantee` spec in `CANONICAL_BLOCK_SPECS`. Do not weaken that sentence while wiring the flag.

### `--think` removal (Step 7.3)

Delete `THINK_MODE (\`--think\` present), ` from the parse sentence at `hve-implement.md:19` only. Do not touch the identical sentence in `hve-review.md:19` or `hve-plan.md`, where `--think` is advertised and used. This makes the three sentences non-identical, which is fine: no `CANONICAL_BLOCK_SPECS` entry covers the Argument Parsing sentence. Verified against the spec list.

---

## 4. Phase 3: security floor mechanics

`hve-pr-review.md` structure today: `--dimension` declared at `:3` and `:22`, Phase 2 dispatch specified only for the `all` case at `:89`, verdict rules at `:145-148`.

Target dispatch rule:
```
--dimension all         -> 8 reviewers (or 4 paired under --compact), unchanged
--dimension <x>         -> reviewer for <x> PLUS the security reviewer
--dimension security    -> security reviewer only (no duplicate dispatch)
```

Target verdict-rule change: the report header gains a coverage line naming the dimensions that ran and those that did not. The security-Critical block rule stays unconditional, which is now truthful because security always runs. The `>2 Major` Request-Changes threshold applies to the dimensions that ran, and the report must say so rather than implying a full-repo verdict.

The `--dimension security` special case matters: without it, a user asking only for security gets the security reviewer dispatched twice.

### DEFECT 3, the agent side

`hve-implementation-validator.md:20` lists selectable single-dimension scopes; `:152` says "Always run the security dimension checks - never skip them." Resolution: make the scope parameter additive rather than exclusive, so any scope selection implies security. This mirrors the command-side floor exactly, which is why the two are one phase.

---

## 5. Reference syntax contract

Because test 14 depends on it, every reference written in Phases 2, 3, 5, 6, and 10 uses this exact construction:

```
per CLAUDE.md's `Section Name` section
```

Rules:
- Section name in backticks, matching the `CLAUDE.md` heading text exactly.
- No markdown links, per the Citation Format convention.
- The canonical text stays in `CLAUDE.md` and is never restated alongside the reference, not even as a summary. A one-line paraphrase is what created the RL cluster.

Sections referenced by this remediation: `Friction Capture`, `Security Hygiene`, `Subagent Dispatch Discipline`, `Artifact Discovery & Relevance`, `Subagent Response Protocol`, `Corrections in Tracking Artifacts`, `Instructions Reference`, and the new `Untrusted Input`.

Each must exist as a literal heading in `CLAUDE.md` before test 14 can pass. `Untrusted Input` is created in Step 2.1; the rest already exist. Confirm the exact heading strings when writing Step 5.9, since the reference text must match them character for character.
