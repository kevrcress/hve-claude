# PR Review — Functional Correctness: fix/full-repo-review-remediation
Date: 2026-08-15
Branch: fix/full-repo-review-remediation
Dimension(s): Functional Correctness (FC-)

## Scope note

This PR's "code" is almost entirely prompt/instruction markdown (slash commands, subagent
definitions) plus two bash test scripts and `install.sh`. "Functional correctness" here means:
do the written procedures actually do what the commit claims, are the caps/tables/behaviors
internally consistent, and are `install.sh`/tests logically sound. All findings below were
verified against the actual files on disk in the repo (not just the diff hunks), per the task
instructions.

An untrusted-input note found in `diff.patch` itself: none of the diff content attempted to
address the reviewing agent directly or claim authority over this review — no embedded-directive
finding to report for this dimension.

## Functional Correctness

### FC-001 [MAJOR]
Location: `.claude/commands/hve-research.md:20` vs. `.claude/commands/hve-research.md:38`
Finding: The file contradicts itself about what `--mode` caps for subagent dispatch. The
`## Inputs` section (line 20, untouched by this diff) states `` `--mode` overrides the difficulty
assessment when explicitly passed (`lightweight` = 1 subagent, `standard` = 2–3, `full` = 3–5) ``
— i.e. ranges. The `## Phase 0` section (line 38, added by this diff's PS-01 remediation) states
"When `--mode` was passed, its own cap applies instead: `lightweight` 1, `standard` 3, `full` 5"
— i.e. fixed hard caps, no range. `CLAUDE.md:43` and `README.md:123` (both edited by this same
diff) agree with the newer fixed-cap wording (`standard` 3, `full` 5), not with line 20. This is
exactly the class of drift this PR's own remediation (PS-01, and the whole RL-cluster) exists to
close, and it was introduced/left standing by the same diff that added the corrected text three
lines away from the stale one.
Recommendation: Rewrite `hve-research.md:20` to state the fixed caps (`lightweight` 1, `standard`
3, `full` 5) matching line 38 and `CLAUDE.md:43`, or delete the redundant restatement in `##
Inputs` and point it at Phase 0 instead.

### FC-002 [MAJOR]
Location: `CLAUDE.md:44`, `README.md:124` vs. `.claude/commands/hve-plan.md:129-141`
Finding: This diff added the claim "`full` uses parallel validation" for `/hve-plan` to both
`CLAUDE.md`'s Command Reference row and README's matching row (new text in this diff, part of the
DO-02 remediation). `hve-plan.md`'s actual `## Phase 3 — Validation` section, unchanged by this
diff, reads: "For **standard** and **complex** plans: spawn **one** `hve-plan-validator` subagent
via the Agent tool." There is no code path anywhere in the file that spawns more than one plan
validator, for any `--mode` value including `full`. The only place "parallel validation" appears
is a pre-existing, un-implemented phrase in the Phase 1 difficulty table (`hve-plan.md:41`, "full
planning with parallel validation"), which this diff propagated into two additional canonical
surfaces without checking it against the implementation it purports to describe. Contrast with
`hve-review.md` and `hve-implement.md` in this same diff, both of which added an explicit
MODE-keyed dispatch-gate table with real parallel-vs-sequential branching — `hve-plan.md` has no
equivalent, so the new doc claim is unsupported by any behavior in the file.
Recommendation: Either implement real parallel dispatch for complex/`full` plan validation in
`hve-plan.md` Phase 3 (e.g., splitting validation by plan section), or correct `CLAUDE.md:44` and
`README.md:124` to say `full` still dispatches a single validator (matching `standard`), removing
the "parallel validation" claim.

### FC-003 [MAJOR]
Location: `README.md:139-146` vs. `.claude/commands/hve-challenge.md:1-5` and
`.claude/commands/hve-memory.md:1-5`
Finding: The new `### Flags every dispatching command accepts` subsection (added by this diff's
"Post-Review Remediation" item 3) is titled and introduced as universal ("Two flags are not listed
per-command above because they work the same way everywhere") and places `--subagent-model` in
that table with no per-command carve-out. But `/hve-challenge` (`allowed-tools: Read, Write, Edit,
Glob, Grep` — no `Agent`; `argument-hint` has no `--subagent-model`) and `/hve-memory`
(`allowed-tools: Read, Write, Glob` — no `Agent`; `argument-hint: [topic-slug]` only) never
dispatch subagents and never accept `--subagent-model`. Both commands are listed in the two tables
directly above this new subsection, so a reader following the section's own framing would
reasonably believe `/hve-challenge --subagent-model sonnet` or `/hve-memory --subagent-model
sonnet` does something; it is silently ignored (the commands don't parse it and have no Agent
tool call to apply it to). The `--friction-log` row in the same table correctly scopes itself to
the six commands that actually accept it — the `--subagent-model` row should do the same but
doesn't.
Recommendation: Scope the `--subagent-model` row the same way as `--friction-log`: "Accepted by
`/hve`, `/hve-research`, `/hve-plan`, `/hve-implement`, `/hve-review`, `/hve-pr-review`, and
`/hve-doc-ops`" (the seven commands whose `allowed-tools` includes `Agent`), or drop the
"everywhere" framing from the section intro.

### FC-004 [MINOR]
Location: `tests/run-install-tests.sh:548-549`
Finding: The comment above `test6_gitignore_credentials`'s Case 3 reads: "a target that already
lists `.env` and `*.key` gains only the three missing patterns". `credential_rules` (line 515) now
holds six patterns (`.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`) after the post-review
`*.pfx` widening documented in the changes log. With `.env` and `*.key` pre-seeded, the installer
adds **four** missing patterns (`.env.*`, `*.pem`, `*.p12`, `*.pfx`), not three. The assertions
themselves are correct (they loop over all six and check exactly-one-occurrence each), so the test
still passes — only the comment is stale, left over from the five-pattern version of this test
before the widening.
Recommendation: Update the comment to say "gains only the four missing patterns".

## Follow-on checklist

- [ ] Reconcile `hve-research.md:20` with `hve-research.md:38` (FC-001)
- [ ] Either implement or retract the "`full` uses parallel validation" claim for `/hve-plan`
      (FC-002)
- [ ] Scope the `--subagent-model` row in README's new flags table to the commands that actually
      accept it (FC-003)
- [ ] Fix the stale "three missing patterns" comment in `tests/run-install-tests.sh` (FC-004)
- [ ] Consider whether `hve-plan.md`'s Simple/Standard/Complex tier names should be spelled out as
      mapping 1:1 to `--mode lightweight/standard/full`, since `hve-implement.md` and
      `hve-review.md` both now state that mapping explicitly in a table and `hve-plan.md` doesn't
