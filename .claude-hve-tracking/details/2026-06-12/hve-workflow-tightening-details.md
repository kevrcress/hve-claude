# Implementation Details: HVE Workflow Tightening
Date: 2026-06-12
Plan: .claude-hve-tracking/plans/2026-06-12/hve-workflow-tightening-plan.md

Exact rule text per step. Source texts are the writeup (authoritative wording) and the five
prompt-analyze reports (insertion points + adapted phrasing). Implementors may smooth phrasing to
match each file's voice but must not weaken a rule (MUST stays MUST; both prongs stay conjunctive).

---

## Phase 1 — CLAUDE.md

### Step 1.1 — Citation Format extension
Append to the `## Citation Format` section (after "No markdown hyperlinks in findings."):

```markdown
**Snapshots vs. living docs:** `file:line` citations are for dated tracking artifacts
(`.claude-hve-tracking/` — snapshots that age with their date). Living docs (any tracked
markdown outside `.claude-hve-tracking/`, e.g. contributor guides, READMEs, architecture
notes) anchor to symbols instead (`Class.Method`, function names), optionally with a dated
line hint ("as of YYYY-MM-DD"), and prefer pointing at tests as compile-checked living
examples. Line numbers in living docs rot silently after the first edit to the cited file.
```

### Step 1.2 — Corrections convention
New section between `## Confidence Markers` and `## Citation Format`:

```markdown
## Corrections in Tracking Artifacts

Falsified statements in tracking artifacts are never silently rewritten. When later work
proves an earlier claim wrong:

1. Annotate the stale claim in place: `(superseded — see Correction YYYY-MM-DD)`
2. Append a dated `Correction (YYYY-MM-DD):` entry in the owning phase's section explaining
   what was learned and what the claim should have said

The phase that learns the corrected information owns writing the correction. A changes log
that contradicts itself without correction annotations cannot be graded ✅ Complete in review.
```

(Last sentence pre-announces the Phase 4 gate so the convention and the gate cite each other.)

---

## Phase 2 — hve-plan.md + hve-plan-validator.md

### Step 2.1 — Plan-Step Evidence Rules (hve-plan.md, after plan template, before Artifact 2)

```markdown
### Plan-Step Evidence Rules

These rules govern what may be written into plan steps:

- The words "confirmed" / "verified" are forbidden in a plan unless immediately accompanied
  by the evidence that produced them: the exact command run, or `file:line` citations. The
  check must be one that could have failed — a compile, a test run, or a grep whose predicate
  targets the claim itself. "Compiles without X" can only be confirmed by compiling without X.
  Citing a location is not the same as confirming an outcome.
- Every key assumption in a plan step MUST carry a confidence marker (`[HIGH]`/`[MEDIUM]`/`[LOW]`)
  per CLAUDE.md.
- When plan-time verification is impossible (no build environment, etc.), mark the assumption
  `[MEDIUM]`/`[LOW]` AND emit an explicit guard step into the implementation phase ("toggle,
  compile, revert if broken") rather than asserting the outcome.
```

### Step 2.2 — step example (hve-plan.md:67)
`- [ ] Step 1.1: [Specific action] — \`file:line\` reference if applicable` →
`- [ ] Step 1.1: [Specific action] — \`file:line\` reference if applicable`
  `  - Assumption: [what is assumed about the environment or existing state] [MEDIUM]`

### Step 2.3 — validator instruction (hve-plan.md:118)
Extend the bullet `Instruction to update the Discrepancy Log section only (DR-/DD- items)` with:
`, including flagging any "confirmed"/"verified" claim not adjacent to the command or citation that produced it, and any plan-step assumption missing a confidence marker`

### Step 2.4 — validator Step 2 bullets (hve-plan-validator.md, after "Dependency errors")

```markdown
- **Unearned verification claims**: any "confirmed"/"verified" not immediately adjacent to the
  evidence that produced it (the exact command run, or `file:line` citation). The cited check
  must be one that could have failed — a compile, a test run, or a grep whose predicate targets
  the claim itself. Emit as `DD-` with severity scaled to what the unverified claim gates.
- **Missing confidence markers**: every key assumption in a plan step MUST carry
  `[HIGH]`/`[MEDIUM]`/`[LOW]` (CLAUDE.md). Flag each assumption lacking a marker as a `DD-` item.
```

### Step 2.5 — DD- template widening (hve-plan-validator.md:69)
`Source: [Plan step that makes an unverified assumption]` →
`Source: [Plan step with an unverified assumption or unearned verification claim]`

---

## Phase 3 — hve-phase-implementor.md + hve-implement.md

### Step 3.1 — STOP rule (hve-phase-implementor.md, new paragraph after the blocker block)

```markdown
If a test failure reveals system behavior not covered by the plan, research, or a spec, you
MUST NOT adjust the test expectation to match observed behavior. Instead:
- Log a `DR-` item in the changes log describing the undocumented behavior (DR- here =
  discrepancy discovered during implementation, distinct from the planning log's
  Discrepancy-from-Research items)
- Surface it in your response findings
- Halt the step, or proceed only on the parts not gated by the discrepancy

A test expectation may be changed only with a recorded `DD-` decision to cite.
```

### Step 3.2 — two-prong won't-fix (hve-phase-implementor.md Constraints, new bullets)

```markdown
- You may unilaterally skip or won't-fix a planned item ONLY when both prongs hold:
  (a) the deviation does not affect the functionality the user prompted for, AND (b) the
  issue is Minor-grade. A dated skip note in the changes log is mandatory. Anything failing
  either prong: STOP, log, and return to the user for review before proceeding.
- A won't-fix note must argue against the finding's ORIGINAL criterion, not a substituted one
  (e.g. do not answer a consistency finding with a correctness argument).
```

### Step 3.3 — self-correction substep (hve-phase-implementor.md Step 3, new item 4)

```markdown
4. Re-read your own earlier claims in the changes log. If later work falsified any of them,
   annotate the stale claim in place (`superseded — see Correction YYYY-MM-DD`) and append a
   dated Correction entry, per the CLAUDE.md corrections convention. Never silently rewrite.
   Do not report Complete while your own record contradicts itself.
```

### Step 3.4 / 3.5 — changes-log template subsections (both files, after `#### Issues Encountered`)

```markdown
#### Discrepancies & Decisions
- DR-NNN: [undocumented behavior discovered during implementation — what, where, evidence]
- DD-NNN: [decision made to resolve a DR-, with rationale and date]

#### Corrections
- Correction (YYYY-MM-DD): [earlier claim] — [what was actually true, learned how]
```

(Omit-if-empty is fine; the heading only appears when there is content.)

### Step 3.6 — parent-side receiver (hve-implement.md Phase 2, after step 5)
Add to the numbered list (renumber "Run tests" to 7):

```markdown
6. If the subagent returns a `DR-` discrepancy or a STOP (a deviation affecting prompted-for
   functionality, or any non-Minor issue): surface it to the user and wait for direction
   before dispatching the next phase. Do not auto-advance past an unresolved discrepancy.
```

---

## Phase 4 — hve-review.md + hve-rpi-validator.md

### Step 4.1 — record-consistency scan (hve-review.md Phase 1, new step after step 3)

```markdown
4. **Record consistency scan**: re-read the changes log end-to-end. Flag any claim
   contradicted by a later claim (e.g. "no build environment available" vs. an executed test
   count) that is not annotated `superseded — see Correction YYYY-MM-DD` per the CLAUDE.md
   corrections convention. Record each un-annotated contradiction as a Minor finding for the
   review log's Record Consistency section.
```

(Renumber the create-review-log step to 5.)

### Step 4.2 — template section (hve-review.md template, after `## Security Findings`)

```markdown
## Record Consistency
[un-annotated contradictions found in the changes log; populated in Phase 1]
```

And in `## Summary` add the line:
`Record consistency: ✅ Consistent | ⚠️ Contradictions (correction appendix required)`

### Step 4.3 — gate conjunct (hve-review.md:109)
`**✅ Complete** — no Critical, ≤ 2 Major findings, all plan phases validated` →
`**✅ Complete** — no Critical, ≤ 2 Major findings, all plan phases validated, and the changes
log is internally consistent (no un-annotated contradictions; any falsified earlier claim
carries a dated Correction per the CLAUDE.md corrections convention). Contradictions without
corrections → ⚠️ Needs Rework.`

### Step 4.4 — /think wording (hve-review.md:105)
Replace `invoke \`/think\` to reason through` with `use extended reasoning to think through`
(keep the --think flag trigger condition unchanged).

### Step 4.5 — rpi-validator bullet (hve-rpi-validator.md Step 2, new item 5)

```markdown
5. Flag any changes-log claim for this phase that contradicts another claim in the same
   phase, or that is falsified by the file evidence, as a Minor `RV-` record-consistency
   finding — unless annotated `superseded — see Correction YYYY-MM-DD`. Cross-phase
   contradiction synthesis is the parent reviewer's responsibility.
```

---

## Phase 5 — hve-implementation-validator.md + hve-review.md sync

### Step 5.1 — Dimension 11 (after `### 10. Overall Quality`)

```markdown
### 11. Documentation Integrity
- Living doc = any tracked `.md` outside `.claude-hve-tracking/` (contributor guides, READMEs,
  architecture notes). Dated tracking artifacts are snapshots and are exempt.
- For each modified file, `Grep -rl` its basename/path across living docs. For each citing
  doc, extract the cited symbols (`Class.Method`, function names) and Grep the modified file
  to confirm they still exist. Flag dead or renamed references as **Minor**.
- Per the CLAUDE.md citation convention, living docs should anchor to symbols, not bare line
  numbers; flag new bare `file:line` citations added to living docs as **Minor**.
- Prefer pointing reviewers at covering tests as compile-checked living examples.
```

### Step 5.2 — scope enum (line 20)
`... | security | full-quality` → `... | security | overall-quality | documentation | full-quality`
Add after the line: `\`full-quality\` runs all dimensions, including documentation integrity.`

### Step 5.3 — counts
Line 9 `across ten validation dimensions` → `across eleven validation dimensions`;
line 25 `## The Ten Validation Dimensions` → `## The Eleven Validation Dimensions`.

### Step 5.4 — Coverage Notes
`[Dimensions not fully checked and why]` →
`[Dimensions not fully checked and why. Always note the documentation citation-check result
here — including when it ran clean — so reviewers can see it executed.]`

### Step 5.5 — hve-review.md Phase 3 list
`The implementation validator checks all 10 dimensions:` → `...all 11 dimensions:` and append
`11. Documentation integrity (living-doc citation rot)` to the numbered list.
