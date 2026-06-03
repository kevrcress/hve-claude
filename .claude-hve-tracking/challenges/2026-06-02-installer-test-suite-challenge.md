# Challenge: Installer test suite
Date: 2026-06-02
Artifacts reviewed:
- .claude-hve-tracking/plans/2026-06-02/installer-test-suite-plan.md
- .claude-hve-tracking/details/2026-06-02/installer-test-suite-details.md
- .claude-hve-tracking/plans/logs/2026-06-02/installer-test-suite-log.md

## Identified Challenge Areas

1. **Per-test isolation vs. global assertion log** — The details file describes `ASSERT_LOG` as a single temp file that accumulates across the entire run. But the plan also describes a `run_test` helper that prints `[ OK ]` or `[ FAIL ]` per test. It's unclear how a global log produces meaningful per-test results — all assertion pass/fail lines from all tests pile into one file, and `finish` tallies the total. If Test 2 fails, does the output clearly identify that it was Test 2 that failed, or just "1 failed" across the whole run?

2. **Prompt test directory enforcement** — The prompt scripts seed a temp dir and tell the user to open Claude Code there. But there's no mechanism to ensure the user actually opens Claude in that directory rather than their regular project. If they open it in the wrong place, Claude installs there, the assertions run against the temp dir, and everything fails — with no helpful error message explaining what went wrong.

3. **"Older version" instruction files not modeled** — Test 3 (clean upgrade) seeds `instructions/` by copying directly from the current source. `cmp -s` in install.sh will always find these identical. But a real user's older install might have files from a previous HVE version — different from the current source but not locally modified. install.sh would warn on these as "diverged" even though the user never touched them. This scenario is not tested.

4. **Prompt script sync with README** — The plan says prompt scripts print the Option A and update prompts "verbatim but with the clone URL amended." If the README prompts change in a future release, the scripts will silently drift. The plan has no mechanism to detect or flag this.

5. **Test 2 (prepend case) assertion gap** — The test asserts `CLAUDE.md` contains `<!-- HVE:START` "before the original content" — but this is a prose description, not an implementable assertion. `grep` can confirm presence; confirming ordering requires either `awk` line-number comparison or reading the file. The plan doesn't specify the mechanism.

## Question Log

### Q1
**What happens in the output when a single assertion fails mid-run — how does a developer identify which test it came from?**

**Response:** Deferred to implementation. Plan success criteria ("prints per-test pass/fail") are sufficient. Implementor decides exact output format. User expects overall pass/fail is clearly communicated; per-test granularity is an implementation detail.

### Q2
**If a user runs run-prompt-new-install.sh and opens Claude Code in the wrong directory by mistake, the assertions will fail against the temp dir with no explanation. How should the script communicate to the user that they must open Claude specifically in the printed directory?**

**Response:** Deferred to implementation — the implementor should make the printed path prominent (e.g. a bordered block, repeated before and after the pause) and add a note to the assertion failure output suggesting "wrong directory?" as a possible cause.

### Q3
**A real user upgrading from an older HVE version may have instruction files that differ from the current source not because they customized them, but because they were installed from an older release. How does the test suite distinguish between "user-modified" and "version-drift" divergence — and is that distinction actually tested?**

**Response:** Deferred — user moved to next challenge.

### Q4
**The prompt scripts embed the Option A and update prompts verbatim (with only the clone URL amended). If those prompts change in a future release, the scripts will silently diverge from the README. What is the maintenance strategy for keeping the embedded prompts in sync — and how would a contributor making a README change know they also need to update the test scripts?**

(awaiting response)

## Future Enhancement: --all flag for hve-challenge

Noted during this session: the one-question-at-a-time Socratic loop is intentional per the prompt design, but adds friction when the user just wants all gaps surfaced quickly. Future feature branch should add a `--all` flag to `/hve-challenge` that dumps all identified challenge areas at once without the interactive Q&A loop.

Candidate branch name: `feature/hve-challenge-all-flag`
