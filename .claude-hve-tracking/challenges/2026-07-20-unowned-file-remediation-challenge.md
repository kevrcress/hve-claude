# Challenge: Unowned-File Convention Remediation
Date: 2026-07-20
Artifacts reviewed:
- .claude-hve-tracking/research/2026-07-20/unowned-file-remediation.md
- .claude-hve-tracking/plans/2026-07-20/unowned-file-remediation-plan.md
- .claude-hve-tracking/plans/logs/2026-07-20/unowned-file-remediation-log.md
- .claude-hve-tracking/changes/2026-07-20/unowned-file-remediation-changes.md
- .claude-hve-tracking/reviews/rpi/2026-07-20/unowned-file-remediation-review.md

## Identified Challenge Areas

1. **Four files unaccounted for in the audit scope.** The research states twenty-two
   files under `.claude/` appeared in no phase's ownership map
   (research line 10), then audits 14 and excludes 4 as out of scope (lines 18-20).
   14 + 4 = 18. The remaining four files are never named, audited, or excluded.
   A task named "unowned-file remediation" may itself have left files unowned.

2. **Round 2 was never reviewed.** The `/hve-review` verdict was ⚠️ Needs Rework.
   Phases 7-10 remediated the findings, but no second review pass validated them.
   The parent independently re-verified RV-101's fix (Mutation B re-run), but Phases 8
   and 9 received no validator at all, and the final "Complete" status is
   self-certified by the implementing session. The framework's core thesis is that
   implementors do not grade their own work.

3. **The root cause has no guard.** Research line 14 identifies the root cause: the
   friction-log remediation's ownership map simply omitted 22 files, so nobody
   inspected them. The remediation fixed the 21 resulting defects and added Tests 12
   and 13, but nothing was added to check that a future plan's ownership map covers
   the full file inventory. The originating failure mode can recur unchanged.

4. **Complete was declared with the lint gate open and the fix already shipped
   globally.** ShellCheck never ran against ~169 new bash lines (flagged three
   times: Phase 5, Phase 6, Step 10.3), yet status is Complete and
   `./install.sh --global` has synced the unlinted, round-2-unreviewed state to
   `~/.claude`, where it governs every project. Installing shellcheck on macOS is a
   one-line brew command; "not installed in this environment" was accepted as a
   terminal state rather than an actionable one.

5. **Test 13's coverage boundary is narrower than the defect class it advertises.**
   Extraction is scoped to `## (Arguments|Options|Modes)` sections. A prompt
   promising phantom behavior in prose (the M-08/M-09/M-11 form — three of the
   twelve Majors) or under any other heading is invisible to it. DD-005 records
   this as accepted, but the acceptance predates RV-101 proving that "partially
   covered by design" can quietly become "not covered at all."

## Question Log

### Q1 — Audit scope arithmetic (Area 1)
**Q:** The research says twenty-two files under `.claude/` appeared in no phase's
ownership map, then accounts for eighteen: fourteen audited, four excluded as out of
scope. What happened to the other four files — what are they, who decided their
disposition, and where is that decision recorded?

**A:** (Kevin, 2026-07-20) The gap is acknowledged as real and unresolved: the four
files may need their own /hve-plan or research iteration. No disposition for them is
recorded in any existing artifact; identifying which four files they are is itself
part of the follow-on work.

**Challenger note:** the answer confirms Area 1 as an open scope gap, not a
recording oversight. Until that iteration runs, the class the task was named for
still contains unexamined members, and no current test would surface a defect in
them. Recommended follow-on recorded below.

### Q2 — Round-2 self-certification (Area 2)
**Q:** The review verdict was ⚠️ Needs Rework, and the framework's stated thesis is
that implementors do not grade their own work. Round 2 (Phases 7-10) then fixed the
three Majors, declared Complete, and re-synced `~/.claude` globally — all within the
implementing session, with no second `/hve-review` pass and no validators on Phases
8 and 9. Help me understand what closes the review loop on round 2: what, other than
the implementing session's own checks, establishes that the rework met the bar the
review set, and why was shipping it globally before that check acceptable?

**A:** (Kevin, 2026-07-20) Confirmed as an actual gap that needs to be addressed so
this doesn't happen in the future. Nothing outside the implementing session
currently establishes that round 2 met the review's bar; the Complete status and
the global re-sync were both self-certified.

**Challenger note:** the gap is procedural, not just historical. The `/hve-review`
command has no re-entry rule after a Needs Rework verdict — nothing tells the
workflow "rework must return to review before Complete," and nothing sequences
`install.sh --global` behind a green verdict. Both defects live in the process
definition, so a future task will repeat them by default. Follow-ons recorded.

### Q3 — Unguarded root cause (Area 3)
**Q:** The research names the root cause precisely: the prior task's file→phase
ownership map omitted 22 files, so no implementor edited them and no validator
inspected them. This task fixed the 21 resulting defects and added Tests 12 and 13 —
but both new tests check file *content*, not map *coverage*. What prevents the next
plan's ownership map from silently omitting files the same way, and how would anyone
find out before the defects ship?

**A:** (Kevin, 2026-07-20) Confirmed: nothing currently guards ownership-map
coverage; this is something additional to build into the process.

**Challenger note:** the natural shape is a completeness gate at plan time and/or
implement time: the ownership map must partition a stated file inventory (e.g. every
file matched by the task's scope glob is either assigned to a phase or explicitly
excluded with a reason), and the plan validator checks the partition — set
arithmetic, well within a haiku-pinned mechanical checker's reach. Q1's four missing
files would have been caught by exactly this check at plan time. Follow-on recorded.

### Q4 — Coverage boundary of the phantom-feature defense (Area 5)
**Q:** Three of the twelve Majors (M-08, M-09, M-11) were phantom promises living in
prose — "Claude can also generate a PR description template," a mischaracterized
header, an unenforced exclusion rule. Test 13 by design sees only tokens under
`## Arguments/Options/Modes` headings, so that entire form remains undetectable, and
DD-005 accepts this by deferring to "judgment-based audit." What ensures that audit
ever actually happens again — what trigger, cadence, or owner does the deferred
judgment-based defense have, given that this defect class only surfaced last time
because two shipped bugs prompted a one-off audit?

**A:** (Kevin, 2026-07-20) Unsure — no trigger, cadence, or owner currently exists;
this needs to be designed.

**Challenger note:** candidate designs, cheapest first: (a) a recurring
`/hve-prompt-analyze` sweep over `.claude/prompts/` on some cadence or before each
release/merge to main; (b) a standing checklist item in `/hve-pr-review` when the
diff touches `.claude/` prompt files ("does any prose promise behavior the mapped
command lacks?"); (c) extending `/hve-doc-ops` scope to cover promise-vs-behavior
checks for prompt files — though DD-002/M-11 just excluded prompt artifacts from
doc-ops, so (c) would partially reverse a decision made this task. The design should
name an owner command, not just a wish. Follow-on recorded.

### Q5 — What "Complete" means with a stated gate open (Area 4)
**Q:** The ShellCheck gate was flagged as skipped three separate times (Phase 5,
Phase 6, Step 10.3), the review said "resolve before merge regardless," and
Step 10.3's own wording — "record the skip rather than claiming the check passed" —
treats absence as terminal. Installing ShellCheck on this Mac is one brew command.
How did "the linter isn't installed" come to be treated as an environmental fact to
record rather than a blocker to fix, and what does the Complete status actually
assert about the ~169 unlinted bash lines now live in `~/.claude`?

**A:** (Kevin, 2026-07-20) Agreed the gap is real, with a refinement: the fix was
never the agent's to make unilaterally. Installing software is a human-approval
action. The correct behavior was to raise the missing linter to the user as an
approval request ("ShellCheck is required by the bash instructions and not
installed — approve installing it?"), install after approval, and run the gate —
not to record the skip and proceed to Complete.

**Challenger note:** this defines the missing process rule precisely. Recording a
skip is the right floor (never claim a pass), but it is not the ceiling: when a
stated gate depends on absent tooling, the process should escalate an install
request to the human and hold the Complete grade until the gate runs or the human
explicitly waives it. Three phases recorded the skip; none escalated. Follow-on
recorded.

### Q6 — ShellCheck exposure scope (Kevin-raised, extends Q5)
**Q:** (Kevin) Would a new user pulling hve-claude get ShellCheck automatically, or
does this resurface per person — or is it contributor-only once the shell code is
linted?

**A:** (Challenger, verified against install.sh and bash.md) Split answer.
The pending lint target `tests/run-drift-tests.sh` is contributor-only: install.sh
copies only `commands/`, `agents/`, `instructions/`, `prompts/` markdown (install.sh:79-86),
never the test suite. But `instructions/bash.md:47` ("Pass ShellCheck validation")
DOES ship to every user, and nothing installs, checks for, or documents ShellCheck
as a prerequisite — so any user doing bash work through HVE resurfaces the Q5
pattern in their own environment. Fix is layered: lint here now (contributor
blocker); embed the Q5 escalation rule in bash.md itself so shipped behavior asks
for install approval instead of skipping; optionally have install.sh warn about
absent optional tooling at install time.

## Challenge Summary

All five identified challenge areas were interrogated; every one was confirmed by
the author as a real gap rather than explained away. The pattern across all five is
consistent: this task's *content* work was strong (defects fixed, wording canonical,
mutations proven), but the *process* has no machinery for its own boundary
conditions — scope completeness, rework re-review, root-cause guards, deferred-risk
triggers, and gate escalation are all currently held by session judgment rather
than by the workflow definition. The follow-ons below are the concrete design work
the interrogation produced.

## Recommended Follow-ons

- [ ] Research/plan iteration for the four unaccounted files: enumerate the original
      22-file unowned set, diff against the 18 dispositioned (14 audited + 4
      excluded), audit the remainder (from Q1)
- [ ] Add a re-review rule to the review/implement cycle: a ⚠️ Needs Rework verdict
      routes rework back through `/hve-review` (or a scoped re-validation) before
      the task may be graded Complete (from Q2)
- [ ] Sequence `./install.sh --global` behind a green review verdict — the global
      re-sync should not ship self-certified state (from Q2)
- [ ] Build an ownership-map completeness gate into the process: the plan's
      file→phase map must partition an explicit file inventory (every in-scope file
      assigned or excluded-with-reason), checked mechanically by the plan validator
      (from Q3)
- [ ] Design a recurring defense for the prose phantom-promise class (M-08/M-09/M-11
      form): pick an owner command and a trigger — e.g. `/hve-prompt-analyze` sweep
      before merge, or a `/hve-pr-review` checklist item when the diff touches
      `.claude/` prompt files (from Q4)
- [ ] Add a gate-escalation rule: when a stated quality gate depends on tooling
      absent from the environment, raise an install-approval request to the human
      and hold Complete until the gate runs or is explicitly waived — recording a
      skip is the floor, not the ceiling (from Q5)
- [ ] Immediate: get human approval to install ShellCheck, then lint
      tests/run-drift-tests.sh before merge (from Q5; the review already requires
      this before merge)
- [ ] Embed the gate-escalation rule in the shipped `.claude/instructions/bash.md`
      (ask install approval when ShellCheck is absent; skip only on decline) — the
      instruction ships to every user but the tooling does not (from Q6)
- [ ] Consider an optional-tooling prerequisite warning in install.sh or
      docs/installation.md (from Q6)

