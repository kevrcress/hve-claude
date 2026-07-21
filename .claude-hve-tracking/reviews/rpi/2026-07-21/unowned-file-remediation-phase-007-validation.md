# RPI Validation: Unowned-File Remediation — Phase 7
Date: 2026-07-21
Plan phase: Phase 7 — Test 13 coverage repair and canonical-corpus extension (RV-101, Q-201)
Coverage: 100% (3/3 steps)
Status: Pass

## Plan Item Comparison

| Plan Step | Changes Log Status | Evidence File | Status |
|---|---|---|---|
| Step 7.1: Repair Test 13 extraction to section-scoped blocks accepting three token shapes | Found | `tests/run-drift-tests.sh:830-875` | ✅ Implemented |
| Step 7.1: Repair Test 13 resolution to argument-hint or backticked body code spans (never prose/headings) | Found | `tests/run-drift-tests.sh:862-875` | ✅ Implemented |
| Step 7.1: Verify all 17 tokens currently present resolve (zero false positives) | Found | Changes log verification evidence (lines 305-316) | ✅ Implemented |
| Step 7.1: Verify `continue`, `suggest`, checkpoint modes fail to resolve | Found | Mutation B output (lines 331, 439-441) | ✅ Implemented |
| Step 7.2: Add PROMPTS_DIR to canonical-block corpus | Found | `tests/run-drift-tests.sh:561,567` | ✅ Implemented |
| Step 7.2: Register memory_store_scope spec with count=2, mode=identical | Found | `tests/run-drift-tests.sh:561` | ✅ Implemented |
| Step 7.3: Apply Mutation B, verify suite fails, restore cleanly | Found | Changes log lines 319-350 | ✅ Implemented |

## Findings

### Test 13 Implementation Details — Verified

**RV-101 fix execution:**

The three-shape extraction (Step 7.1) is implemented in `tests/run-drift-tests.sh:830-846`:
- Backticked flags: `^- \`[^`]+\`` via `match($0, /^- `[^`]+`/)`
- Backticked bare tokens: `^- \`bare\`` via same pattern (token extracted via substr)
- Bold tokens: `^- \*\*BoldToken\*\*` via `match($0, /^- \*\*[^*]+\*\*/)`
- Section scoping: `in_section` flag set only when `^## (Arguments|Options|Modes)` matched; explicitly reset on any other `^## ` line (line 833)

This directly addresses the M-07/M-10 defect classes:
- M-07 bare tokens (`` - `continue`: ``) now extracted and required to resolve
- M-10 bold mode names (`` - **Continue**: ``) now extracted and required to resolve
- The pre-fix naive extraction `^- \`--` would have missed both

Resolution rule (Step 7.1, implemented lines 862-875):
- `frontmatter_value()` returns the `argument-hint:` value from the command's frontmatter (with workaround for hyphenated key at line 870)
- Fallback: `code_span_contents()` extracts only backtick-delimited text (split per line, line 856), which excludes prose and headings
- Prose false-positive example correctly excluded: `suggest` in `hve.md:155` is not inside backticks (verified in mutation output, line 441: caught as unimplemented)
- Heading false-positive example correctly excluded: `## Phase 3 — Continue` in `hve-memory.md:91` is not inside backticks (would have resolved in pre-fix whole-file grep)

**Verification evidence (Step 7.1, zero false positives):**

Changes log lines 305-312 show extraction run on the fixed tree:
```
-- .claude/prompts/checkpoint.md        (none — no Arguments/Options/Modes section)
-- .claude/prompts/doc-ops.md           --scope, --subagent-model
-- .claude/prompts/prompt-build.md      --iterations, --subagent-model
-- .claude/prompts/pull-request.md      --compact, --dimension, --friction-log, --subagent-model
-- .claude/prompts/rpi.md               --mode, --subagent-model, --think, task
-- .claude/prompts/task-challenge.md    --focus, --friction-log
```

Cross-referenced with actual prompt files:
- `rpi.md:7-10` contains these exact tokens; `task` is a bare token at line 7 (`` - `task`: ``)
- `doc-ops.md:13-17` contains `--scope` (line 13-16) and `--subagent-model` (line 17)
- `checkpoint.md` has no Arguments/Options/Modes section; test passes with zero tokens (line 901-904)
- Bold lines in `doc-ops.md:7-9` under `## What it checks` are correctly excluded (not in Arguments/Options/Modes)

All extracted tokens resolve in their mapped commands:
- `task`: appears in `hve.md:3` argument-hint
- `--mode`: appears in `hve.md:3` argument-hint
- `--think`: appears in `hve.md:3` argument-hint
- `--subagent-model`: appears in all command hints that support it
- `--scope`: appears in `hve-doc-ops.md:3` argument-hint
- `--iterations`: appears in `hve-prompt-builder.md:3` argument-hint
- `--compact`: appears in `hve-pr-review.md` body (backticked)
- `--dimension`: appears in `hve-pr-review.md` body (backticked)
- `--focus`: appears in `hve-challenge.md:3` argument-hint
- `--friction-log`: appears in five command hints (hve.md, hve-review.md, hve-pr-review.md, hve-challenge.md) and one prompt (task-challenge.md)

Zero false positives confirmed by parent-independent mutation test (line 439-441): when Mutation B re-adds `continue` and `suggest`, suite fails with:
```
[FAIL] test13: rpi.md continue: rpi.md documents continue but hve.md implements no such option
[FAIL] test13: rpi.md suggest: rpi.md documents suggest but hve.md implements no such option
```

**Mutation B failure proof (Step 7.3):**

Original Mutation B text (line 322) inserted into `.claude/prompts/rpi.md` Arguments section:
```
- `continue`: Mention "continue" to resume from the most recent tracking artifacts
```

Suite output (lines 328-334):
```
[FAIL] test13: rpi.md continue: rpi.md documents continue but hve.md implements no such option
```

The catch is load-bearing because `continue` appears only in prose at `hve.md:155`, which the code-span extraction does NOT pick up (verified line 856-859: `split($0, parts, "`")` pairs backticks per line, so prose between spans cannot false-resolve).

Restoration (line 341-345):
- Byte-level backup diff: no output (byte-identical)
- SHA256: matches pre-mutation hash
- Residual grep confirms restore: `` `hve-researcher` `` still present in hve-doc-ops.md, `--resume` removed from rpi.md

Supplementary mutation (M-10 defect class, bold modes, lines 352-361):
```
[FAIL] test13: checkpoint.md Continue: checkpoint.md documents Continue but hve-memory.md implements no such option
[FAIL] test13: checkpoint.md Save: checkpoint.md documents Save but hve-memory.md implements no such option
[FAIL] test13: checkpoint.md Update: checkpoint.md documents Update but hve-memory.md implements no such option
```

All three caught (Save, Continue, Update are not options in hve-memory.md:3 argument-hint), proving bold-token extraction works.

### Canonical Corpus Extension — Verified (Step 7.2)

`memory_store_scope` spec registered at `tests/run-drift-tests.sh:561`:
```bash
'memory_store_scope|2|identical|Also write the most non-obvious decisions and patterns to the Claude Code native memory store'
```

Carrier count = 2 (expected):
- `hve-memory.md:87` — full sentence ending with "entries written here surface only in future sessions on this same project"
- `checkpoint.md:25` — byte-identical sentence

`canonical_block_corpus()` now includes PROMPTS_DIR (line 567):
```bash
for file in "${COMMANDS_DIR}"/*.md "${AGENTS_DIR}"/*.md "${PROMPTS_DIR}"/*.md; do
```

This addition ensures the prompt file copies of the memory-store sentence stay synchronized with the command file, preventing the silent divergence that M-12 and m-09 were designed to catch.

### Test Output and Success Criteria

Phase 7 entered with baseline 207 passed, 0 failed (post-review gate at line 274).

Final suite: 211 passed, 0 failed (line 421).

The +4 delta comprises:
- Two new canonical-block assertions from Step 7.2 (memory_store_scope carriers and identity checks)
- Two new resolution checks from widened Test 13 extraction (checkpoint.md zero-token pass + one additional prompt token)

Success criteria (plan line 110-111):
- Mutation B run unmodified makes suite fail ✅ (shown lines 328-334)
- Fixed tree stays green ✅ (211 passed, 0 failed)
- PROMPTS_DIR in canonical corpus ✅ (line 567)
- memory_store_scope registered ✅ (line 561)

## Unlisted Changes

The parent-supplied changed-file list (git diff --name-only HEAD, spanning uncommitted Rounds 1–2 of all 10 phases) includes `tests/run-drift-tests.sh`. Phase 7's sole file modification is to this file, which is on the list.

Files on the parent's list are accounted for by their owning phases:
- Phases 1–4: `.claude/agents/` and `.claude/commands/` and `.claude/prompts/` files
- Phase 5: `tests/run-drift-tests.sh` (Tests 12–13 added; Phase 7 extends Test 13)
- Phases 8–9: `.claude/agents/hve-rpi-validator.md`, `.claude/commands/hve-prompt-builder.md`, `docs/internals.md`

No files on the parent's list are absent from the changes log.

## Research Coverage

Research document (section "Major findings" and "Minor findings") identified RV-101 and Q-201:

**RV-101** (research section "Major findings" implicit in IV-004 and the Test 13 mutation evidence): The original Phase 5 Test 13 used naive `^- \`--` extraction and whole-file grep resolution, missing:
- M-07 bare-token phantom options (`` - `continue`: ``)
- M-10 bold-mode phantom options (`` - **Continue**: ``)

**Fix validation:** 
- Step 7.1 narrowed extraction to Arguments/Options/Modes sections and three token shapes; both defect classes now extracted
- Step 7.1 narrowed resolution to frontmatter or backticked code spans; prose (where `suggest` lurked) and headings (where `Continue` lurked) now correctly excluded
- Mutation evidence confirms both defect classes now caught (lines 331, 355-358)

[HIGH] Both narrowings are load-bearing and verified by mutation failure+restoration.

**Q-201** (research section "Minor findings" m-09): `checkpoint.md:19-25` Output list omits the native-memory write at `hve-memory.md:74` (now line 87 post-Phase 3 fix).

**Fix validation:**
- Step 7.2 adds `PROMPTS_DIR` to canonical corpus, bringing prompt files into byte-identity sync checks
- Step 7.2 registers `memory_store_scope` spec with count=2 and mode=identical
- Both `hve-memory.md:87` and `checkpoint.md:25` now carry the sentence and are tracked as a canonical block
- Drift test 10 now enforces byte-identical copies (Test 10 runs at main() lines 948-952)

[HIGH] Both carriers verified to contain identical text; test 10 registration ensures divergence is caught on any future edit.

## Summary

Phase 7 successfully addressed two Major findings from the post-review validation feedback (RV-101 and Q-201). All three plan steps (7.1, 7.2, 7.3) are complete and verified:

1. **Test 13 is repaired**: extraction is section-scoped and three-shape-aware; resolution is code-span-aware and prose-proof. Both M-07 and M-10 defect classes are caught.
2. **Canonical corpus is extended**: PROMPTS_DIR included; memory_store_scope spec registered with byte-identity enforcement.
3. **Mutations prove the fix**: both defect classes fail when reintroduced; suite returns to green on restore.

No Critical or Major findings. No contradictions between claims and file evidence.
