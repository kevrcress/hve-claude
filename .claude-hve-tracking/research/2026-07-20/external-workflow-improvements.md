# Research: Integrating 11 Externally-Sourced Workflow Improvements

Date: 2026-07-20
Task slug: external-workflow-improvements
Confidence: HIGH overall
Source of the 11 items: synthesis of a 10-article review (O'Reilly operational-groundwork, adamhjk token-spend guide, Photoroom Insights Factory, Harness Handbook, Replit self-driving-company, armank.dev observability; four articles rated not relevant)
Method: 4 parallel hve-researcher subagents (behavior-map, artifact-formats, scripts-dispatch, install-tests); raw findings under research/subagents/2026-07-20/. Parent-session verification of two conflicting subagent claims used Bash (grep + one suite run) outside this command's declared read-only toolset — a recorded deviation, made because the claims were load-bearing and contradictory.

## Summary

All 11 items are implementable, but four shrink substantially on contact with evidence: token metrics are not obtainable in-session (item 4 reduces to wall time + finding counts), item 9 has no remaining hard instance to catch (the test becomes pure regression protection), item 8 is mostly formalizing a convention that already exists in three places, and item 3's discovery script collides with deliberate tool boundaries. The dominant structural finding: the drift suite already maintains three hand-built carrier lists that item 1's behavior-map manifest should subsume rather than join. Hard sequencing constraint: nearly everything edits files the uncommitted `feature/friction-log-remediation` working tree also touches, so this improvement set must land as a new branch after that merges; the drift baseline is now 211/0, not 169/0.

## Corrections (2026-07-20, recorded at consolidation time)

Two subagents (behavior-map Finding 2; artifact-formats checklist item 5) reported that Test 13 is a silent no-op: `main()` allegedly calls `test13_prompt_flag_sync` while the function is named `test13_prompt_option_sync`, and the body allegedly never calls its section-scoped helpers. **Both claims are falsified by parent-session verification**: the definition (tests/run-drift-tests.sh:877) and the call (tests/run-drift-tests.sh:959) share the name `test13_prompt_option_sync`; the helpers are invoked at tests/run-drift-tests.sh:899 and :908; the full suite runs 211 passed, 0 failed, with Test 13 OK. The subagent raw files retain the stale claims; treat this section as authoritative. Consequence: no pre-work fix is needed, and the in-flight plan's Phase 7 repair appears complete in the working tree.

## Key Findings

### Behavior ownership map (item 1)

- The drift suite uses three unshared carrier-discovery idioms: explicit lists (`FULL_PROTOCOL_AGENTS` tests/run-drift-tests.sh:59-61, `CANONICAL_BLOCK_SPECS` :549-561, `PROMPT_COMMAND_MAP` :816-823), count-free grep (Test 5, :317), and frontmatter-derived sets (Test 12). The manifest should subsume the explicit lists and pin the count-free ones, not become a fourth list. [HIGH]
- Manifest home: `tests/lib/behavior-map.sh`, following the sourceable data-array precedent of tests/lib/instruction-files.sh (sync-enforced by Test 11 at :658-695). It must be readable as plain data because /hve-prompt-analyze has only `Read, Glob` (.claude/commands/hve-prompt-analyze.md:4). [HIGH]
- A 20-row guarantee → implementing-files table exists in the behavior-map subagent file. Six guarantees have zero mechanical coverage today: review-refusal without changes log, handoff block format, Mid-Flow Scope Changes, corrections convention, shell-stays-in-parent attribution, severity/finding-ID formats. [HIGH]
- Mid-Flow Scope Changes is a convention with NO implementing file: grep for "Requirements added"/"Mid-Flow"/"scope change" across .claude/ returns zero hits; it exists only in CLAUDE.md. Either phase commands gain the read step or the manifest marks it CLAUDE.md-only by design. [HIGH]
- /hve-prompt-analyze insertion point: a sixth dimension ("Convention Carrier Integrity") after Format Compliance in Phase 2 (:33-59) with a matching Quality Summary row (:79-85). [HIGH]
- Bonus drift found: hve-plan.md implements `--subagent-model` (arg-hint :3, parse :13) but lacks the canonical paragraph; Test 5's count-free discovery cannot see the asymmetry. Exactly the class a carrier-pinning manifest closes. [HIGH]

### Tool-list enforcement drift test (item 9)

- No remaining hard M-01-class instance: the rpi-validator fix is already applied in the working tree (hve-rpi-validator.md:23, :50 attribute git facts to the parent). hve-pr-reviewer.md:43 is borderline but attribution-covered (:23, :119). The test is regression protection, landing green. [HIGH]
- Greppable signal: agent-body lines matching `[Rr]un \`` or backticked git commands, where frontmatter `tools:` exists and excludes Bash, and the line lacks an attribution marker ("run by the parent", "parent-supplied", etc.). Nuance: hve-phase-implementor, hve-prompt-tester, hve-prompt-updater declare NO `tools:` key and therefore inherit Bash; the test must treat a missing tools line as Bash-present. [HIGH]

### Machine-readable artifact headers (item 2)

- No tracking artifact uses YAML frontmatter (zero leading-`---` files in .claude-hve-tracking/). The existing pattern is pseudo-frontmatter: plain `Key: value` lines after the H1 (plan header at hve-plan.md:58-62; changes log at hve-implement.md:49-51; review log at hve-review.md:51-55). [HIGH]
- hve-plan.md:35 already phantom-references "the research doc frontmatter" — item 2 would make an existing instruction true. [HIGH]
- Discovery today is filename+date globbing only. Structured-header discovery would touch the 3 byte-identical discovery-stub carriers (hve-plan.md:25, hve-review.md:25, hve-challenge.md:25; spec `discovery_stub|3|identical` at run-drift-tests.sh:550), hve-implement.md's non-stub variant (:25-31), hve.md, the CLAUDE.md convention, and Test 10 specs. The `frontmatter_value()` awk helper (:103-116) is the parsing precedent; its key regex misses hyphenated keys. [HIGH]
- Decision required (open question): true YAML frontmatter vs formalizing the existing pseudo-header. Pseudo-header is lower-churn (no carrier or installer changes for reading order); YAML matches the agent/command file precedent and external tooling. Either parses with the same awk approach. [MEDIUM]

### Per-phase metrics (item 4)

- Token counts: NOT OBTAINABLE. No repo mechanism exposes session token usage, and hve-implement.md:125 / hve-phase-implementor.md:110 forbid writing counts not observed in output. A `Tokens:` field would be a permanently-N/A template blank; recommend dropping it from the item. [HIGH]
- Wall time: obtainable-with-N/A-branch via the drift-protected `Started:`/`Completed:` `date -u` precedent (hve-implement.md:57-58, hve-phase-implementor.md:79-80; specs run-drift-tests.sh:552-553). Research phases are date-only (hve-research.md:4 has no Bash; :73 forbids adding it). [HIGH]
- Severity finding counts and DR-/DD- counts: obtainable phase-locally (hve-review.md:71, :136-138; hve-plan.md:111-125; hve-implement.md:70-72). Writing review-derived counts back into earlier artifacts requires a new cross-phase write-back rule; today only the corrections convention licenses editing an earlier phase's artifact. [HIGH]

### Decision frame / kill criteria (item 6)

- Single-file change: insert the section between Summary and Key Findings in the consolidated template (hve-research.md:96-99). The per-theme hve-researcher template stays unchanged (raw evidence, not synthesis); hve.md does not duplicate the template; no canonical block covers it, so the edit is drift-safe. Optionally point hve-plan.md Phase 1 (:34-37) at the new section as a consumer. [HIGH]

### Ambient friction field (item 7)

- The friction line must live INSIDE each `### Phase N:` changes-log section (next to Started:/Completed:), never top-level: the concurrent-writes rule (4 byte-identical carriers; spec run-drift-tests.sh:551) restricts parallel implementors to their own phase section. [HIGH]
- Template is duplicated in hve-implement.md:55-77 and hve-phase-implementor.md:76-100; a new `Friction:` line needs a `CANONICAL_BLOCK_SPECS` entry with count 2. Do not touch the test6-protected `--friction-log` paragraph (byte-identical across 6 commands, run-drift-tests.sh:350-387). [HIGH]

### Deterministic helper scripts (item 3)

- Tool-boundary conflict: discovery-stub carrier hve-challenge.md and restater hve-memory.md have no Bash; hve-research.md:73 explicitly forbids adding Bash. A discovery script can only be mandatory for the Bash-holding commands (hve, hve-plan, hve-implement, hve-review, hve-pr-review, hve-doc-ops). Options: parent-Bash-only script with prose remaining authoritative for Bash-less commands, or grant Bash to challenge/memory (contradicts the read-only design direction), or drop the discovery script and keep prose. [HIGH]
- Installer constraint: install.sh copies only `hve*.md` from commands/agents plus the instructions/prompts arrays (install.sh:77-87); no script directory ships. A `.claude/scripts/` dir requires edits at install.sh:61-62 (completeness check) and :77-87 (copy), plus count assertions in run-install-tests.sh (per-project and --global paths). An uninstalled script breaks installed commands — this is the binding constraint. [HIGH]
- Security greps are the easier scriptification target: the executor hve-implementation-validator already has Bash (frontmatter :6; patterns at :67-72). Minor drift found: the agent lists `*.pfx`, CLAUDE.md:293 does not; a script would become the single source. [HIGH]

### Subagent failure policy (item 5)

- Nearly absent today: only hve-implement.md:104 (DR-/STOP triage) and :126-129 (test-failure Blocked path). No occurrence of retry, re-dispatch, or halt-after-N-failures anywhere in .claude/commands/ or hve.md; research/review/pr-review just wait and read. Net-new convention. [HIGH]
- Cheap placement idiom: CLAUDE.md master section + byte-identical stub in the dispatching commands + one `CANONICAL_BLOCK_SPECS` line (`label|count|mode|prefix`, run-drift-tests.sh:550-562), mirroring the discovery-stub pattern. Carrier count decision: 6 dispatching commands or 7 with hve.md. [HIGH]

### Risk-scaled review (item 11)

- Current dispatch is fixed: one rpi-validator per Complete phase (hve-review.md:85), a Simple carve-out collapse (:79), and always exactly one full-quality implementation-validator (:103). The only intensity dial is Simple-vs-not. [HIGH]
- No machine-parseable risk signal exists: the plan template's `## Risk Log` (hve-plan.md:83-86) is unstructured prose; the risk-override precedent is free text (plans/2026-07-20/unowned-file-remediation-plan.md:12). Item 11 fully depends on item 2 defining a structured risk field (e.g. `Risk flags: external-consumers, no-test-coverage` header line). [HIGH]

### Installer provenance and --verify (item 10)

- Merge anatomy: block wrapped in `<!-- HVE:START - managed by hve-claude... -->` / `<!-- HVE:END -->` (install.sh:180-181); re-runs replace in place via awk prefix match on `<!-- HVE:START` (:196-214). Safest stamp: a second managed line inside the markers (e.g. `<!-- HVE:SOURCE commit <hash> installed <date> -->`) built into WRAPPED at :183 — regenerated free on every re-run, all three merge branches handle it, no fixture edits needed. [HIGH, placement inference MEDIUM]
- Hash acquisition needs a fallback (`git -C "$SOURCE" rev-parse --short HEAD 2>/dev/null || echo unknown`): install.sh resolves its checkout via BASH_SOURCE (:29) but nothing guarantees a git checkout. [HIGH]
- --verify shape: glob source `hve*.md` dirs + the two explicit arrays, `cmp -s` per file (idiom already used at install.sh:109, :148); report missing/diverged/extra; nonzero exit on drift. Prerequisite gap: `HVE_PROMPT_FILES` (install.sh:135-137 vs tests/lib/prompt-files.sh) has NO sync test — extend Test 11 or add a sibling before building --verify on that array. [HIGH]
- Stamp interacts with exactly-one-`HVE:START` assertions (run-install-tests.sh:216-222, :407-416); the inside-block placement avoids fixture changes. New tests fit run-install-tests.sh's existing harness (verify-clean, verify-drift cases). [HIGH]

### Friction findings as standing regressions (item 8)

- The practice already exists un-named: Test 12's header cites its motivating defect ("the M-02 defect", run-drift-tests.sh:703); IV-006 and IV-007 are standing regressions as Test 10 present-mode specs (:559-560). Item 8 reduces to an `# Origin: <finding-ID> (<review path>)` comment convention per group/spec, back-filling groups 10-13, plus a drift-suite paragraph in CONTRIBUTING.md (which currently omits the drift suite entirely; long-open follow-up from the 2026-07-06 memory). [HIGH]
- New-group recipe (3 edit sites): testN function, header index comment (run-drift-tests.sh:10-40), main() registration (:936-959), plus the preflight loop if a new dir is read. Next free group: Test 14. [HIGH]

## Cross-Item Dependencies and Groupings

Dependencies:
- Item 11 consumes item 2's structured risk field — item 2 must land first.
- Item 9's test and item 1's manifest both extend the drift suite; the manifest's carrier-list shape should exist before or with the new tests so they register in it.
- Item 10's --verify depends on closing the HVE_PROMPT_FILES sync gap.
- Item 3 (discovery script) is weakened by the tool-boundary conflict; if pursued, it should consume item 2's structured headers (parsing headers beats reimplementing glob heuristics).

Suggested implementation groupings (for the plan phase):
1. **Manifest core** (items 1 + 9 + hve-plan.md paragraph drift): behavior-map.sh subsuming the three lists, Test 14 tool-list check, prompt-analyze sixth dimension.
2. **Structured headers** (item 2 + risk field): decide YAML-vs-pseudo-header, formalize across templates, first consumers (hve-plan.md:35, discovery).
3. **Template additions** (items 6 + 7 + reduced 4): decision-frame section, per-phase Friction: line with canonical spec, Started/Completed + finding-count fields where obtainable.
4. **Circuit breaker** (item 5): CLAUDE.md master + command stub + spec line.
5. **Risk-scaled review** (item 11): after group 2; hve-review dispatch reads risk flags.
6. **Installer provenance** (item 10): stamp + --verify + prompt-files sync test; zero file overlap with groups 1-5, parallelizable.
7. **Origin convention** (item 8): comment back-fill + CONTRIBUTING.md drift-suite section; trivially small, can ride with group 1.

Sequencing constraint (hard): all groups except 6 edit files the uncommitted `feature/friction-log-remediation` tree also touches (run-drift-tests.sh, command/agent files). Land this improvement set on a fresh branch after that branch merges. Drift baseline for the new plan: 211 passed, 0 failed [HIGH — suite run 2026-07-20 during consolidation].

## Codebase References

tests/run-drift-tests.sh — drift suite, 13 groups, carrier lists, canonical specs
tests/lib/instruction-files.sh, tests/lib/prompt-files.sh, tests/lib/assert.sh — sourceable-array and assertion precedent
install.sh — copy list, marker merge, arrays
tests/run-install-tests.sh — marker assertions, per-dir count assertions
.claude/commands/hve-plan.md, hve-review.md, hve-challenge.md — discovery-stub carriers
.claude/commands/hve-implement.md, .claude/agents/hve-phase-implementor.md — changes-log template pair
.claude/commands/hve-research.md, .claude/agents/hve-researcher.md — research templates
.claude/commands/hve-prompt-analyze.md — behavior-map consumer
.claude/agents/hve-implementation-validator.md — security-grep executor (has Bash)
.claude/agents/hve-rpi-validator.md, hve-pr-reviewer.md — attribution precedent for item 9
CLAUDE.md — master conventions (discovery :239-251, security :288-296)
CONTRIBUTING.md — missing drift-suite section
.claude-hve-tracking/plans/2026-07-20/unowned-file-remediation-plan.md — in-flight plan (sequencing)
.claude-hve-tracking/research/subagents/2026-07-20/external-workflow-improvements-{behavior-map,artifact-formats,scripts-dispatch,install-tests}.md — raw findings incl. the 20-row guarantee table

## External References

The 10 source articles were fetched and assessed in the preceding conversation session (synthesis recorded in this file's header); no external fetches during this research phase.

## Open Questions

1. Header format: true YAML frontmatter vs formalizing the existing `Key: value` pseudo-header? (Affects carrier churn, test parsing, external tooling; both parse with the same awk.)
2. Discovery script scope: parent-Bash-only helper with prose fallback, grant Bash to challenge/memory, or keep discovery prose-only and scriptify only the security greps?
3. Mid-Flow Scope Changes (guarantee table row 12): add the read step to phase commands, or record as CLAUDE.md-only by design in the manifest?
4. Cross-phase write-back: may review write finding counts into the plan/changes headers, or do metrics stay phase-local (with the review artifact as the single tally source)?
5. hve-plan.md's missing `--subagent-model` canonical paragraph: drift to fix, or intentional because its flag section predates the boilerplate?
6. Circuit-breaker carrier count: the 6 dispatching commands only, or 7 including hve.md's internal transitions?

## Recommended Research Follow-On

- [ ] Confirm merge timing of feature/friction-log-remediation; re-run the drift suite on the merged tree to fix the plan baseline (211 expected)
- [ ] Decide open questions 1-3 before planning groups 1-2 (they gate the manifest record shape and header format)
- [ ] Prototype the item-9 grep and mutation-test it by temporarily reverting hve-rpi-validator.md:23
- [ ] Prototype the HVE:SOURCE stamp against all three merge branches and re-run run-install-tests.sh
- [ ] Verify hve-plan.md paragraph drift (open question 5) with git history once in a Bash-capable phase
