# Research: Project Communication (Thread A) and Phase-Ending Clarity (Thread B)
Date: 2026-08-19
Task slug: project-communication-phase-close
Confidence: HIGH overall (repo-state claims verified by four parallel researchers; editorial and design recommendations are MEDIUM where marked)

Scope note: Thread A covers how the project explains itself to newcomers (README, docs/, GitHub presence, visuals). Thread B covers how command phases close for a daily user (locked completion-summary format, HANDOFF rendering bug, machine-parseable status). Secondary asks bundled in this task are listed inline; the slug names the primary deliverable per the naming convention.

Note: the four per-theme subagent artifacts under research/subagents/2026-08-19/ (project-comms-readme-docs.md, project-comms-evidence-artifacts.md, project-comms-external-pages.md, phase-close-scope-handoff.md) are gitignored; this document carries everything durable.

## Summary

Thread A: the README asserts the RPI thesis but never evidences it, and the repo is confirmed text-only, yet the strongest evidence already exists on disk: three committed 2026-08-15 artifacts show the review re-running test suites itself, a fabricated timestamp retracted in writing, and 7 raw Critical findings adjudicated to 0 with per-finding verification. Recommended presence moves: invest in the README (no GitHub Pages yet), add a native-rendering mermaid RPI diagram, set 8 repo topics, keep homepage null, and do not name HiVE publicly. Thread B: only 4 of 15 commands emit the true HANDOFF box, 4 more use sibling boxes, and 4 close with little or no structure (hve-git-setup has none at all); no test pins the box format, so it is free to change. The rendering bug's strongest-supported root cause is that the fence exists only around the source example, so the model regenerates the block bare with ASCII pipes that table-parse; the recommended fix is a labeled-line format that doubles as the fixed-key machine-readable carrier (status/artifact/next) HiVE will need, applying the brief's cheap-now/expensive-later logic.

## Planning recommendation: one plan or two

TWO separate plans [HIGH]. The threads touch almost entirely disjoint files (Thread A: README.md, docs/, repo settings, possibly new image/mermaid content; Thread B: .claude/commands/*.md, CLAUDE.md, tests/run-drift-tests.sh, propagated via install.sh --global). Thread B is decision-locked and mechanical enough to plan immediately; Thread A has an open editorial question (evidence vs assertion for the WHY case) and one clarifying question (Fieldnotes) that may reshape its visual scope. Sequencing constraint shared by both: the in-flight CLAUDE.md lean restructure (research/2026-08-19/claude-md-lean-restructure.md) also edits CLAUDE.md and README.md; whichever plan runs first should be coordinated with it to avoid conflicting edits to the same sections [HIGH].

---

# Thread A: Project communication and visual presence

## Key Findings

### A1. README makes the RPI case by assertion, not evidence

- README.md:13 states the plausible-code vs verified-truth claim as fact; README.md:22 claims "higher-quality output, leaner context windows, lower cost" with no measurement, example, or citation. The Benefits table (README.md:252-264) is nine comparative rows, all asserted, zero data. [HIGH]
- Context compaction, the strongest concrete selling point, gets one clause ("Grows unbounded; quality degrades in long sessions", README.md:257); nothing explains the failure mode or how disk artifacts specifically survive it. Closest supporting text is docs/workflow.md:110-115, framed as convenience rather than failure avoidance. [HIGH]
- The only evidence is indirect: the dogfood section (README.md:276-291) links four genuine artifacts but has no vanilla-vs-HVE baseline; the single concrete anecdote in the README is a failure story in Limitations (README.md:268-273), which is counter-evidence honesty, not a success example. [HIGH]
- Structure present: pitch (README.md:3), "Why this exists" hook (README.md:11-22), quickstart (README.md:26), ASCII loop (README.md:76-93), Limitations, dogfood links, Further reading (README.md:295-305). Missing: badges, table of contents, any screenshot/GIF/demo, any visual beyond ASCII. [HIGH]
- Repo is text-only, CONFIRMED: glob for *.png/*.svg/*.jpg/*.jpeg/*.gif/*.mmd returns zero files; no mermaid fences anywhere; "full parallelism diagram" at README.md:95 resolves to ASCII art at docs/workflow.md:15-34 and slightly oversells it. [HIGH]
- Upstream credibility (adapted from microsoft/hve-core) is used only as attribution (README.md:5, :7, :312), never leveraged as social proof. [MEDIUM]

### A2. Overlap map (flagged for reconciliation; CLAUDE.md-side resolution belongs to the in-flight restructure)

Already established by prior research, cited not re-derived: PA-001 (CLAUDE.md:5 verbatim README.md:5) and PA-002 (Installing section triplicated: CLAUDE.md:341-386, README.md:205-248, docs/installation.md:110-120), plus the duplication matrix at claude-md-lean-restructure.md:76-88. [HIGH]

New overlap found this session (docs-vs-README and docs-vs-docs):

- O-1: paste-to-install prompt is a maintained 3-way verbatim copy: README.md:31-46, docs/installation.md:13-28, and embedded in tests/run-prompt-new-install.sh per CONTRIBUTING.md:72-74. Any wording change must touch all three. [HIGH]
- O-2: four-phase loop described in complementary paraphrase at README.md:76-93 and docs/workflow.md:15-34, :36-83. [HIGH]
- O-4: credential-pattern block appears 3 times inside docs/installation.md alone (:89-95, :156-159, :186-197), one per install path; test 16 enforces agreement. [HIGH]
- O-5: idempotence statement paraphrased 3 times (docs/installation.md:97, :245-247; docs/workflow.md:211-216). [HIGH]
- O-7: tracking-folder tree near-duplicated (docs/reference.md:8-33 vs CLAUDE.md:74-105) with a two-way defer loop: reference.md:40 defers to README for commit policy while README carries no tree. [MEDIUM]
- O-8: docs/internals.md:31 names agent frontmatter as source of truth and asks for manual sync of its own roster table (drift-test candidate). [HIGH]
- Overall docs-vs-docs hygiene is healthy (deliberate defer links at docs/workflow.md:5, docs/installation.md:3-5, docs/reference.md:40, docs/internals.md:10-12); heavy verbatim duplication concentrates in install surfaces, partially frozen by test scripts. [HIGH]

### A3. Evidence artifacts that can anchor a README or landing page (ranked)

All from the committed 2026-08-15 full-repo-review remediation task; note they sit on branch fix/full-repo-review-remediation, not yet merged to main. [HIGH]

1. Independent test verification: the review re-ran both suites itself (drift 248/0, install 66/0) before accepting any validator finding, stating the implementation's headline claim was "verified, not trusted": .claude-hve-tracking/reviews/rpi/2026-08-15/full-repo-review-remediation-review.md:20-31. One-screenshot proof of "verified, not trusted"; short enough to quote. [HIGH]
2. Falsification discipline: the changes log carries a dated Correction retracting a fabricated `Completed:` timestamp, replaced with an actual `date -u` reading: .claude-hve-tracking/changes/2026-08-15/full-repo-review-remediation-changes.md:341-343, independently cited by the review at :212-214. Most tools would never admit this on the record; that is the differentiator. [HIGH]
3. Writer/checker separation: raw validator output of 7 Critical/1 Major adjudicated to 0/0 with per-finding file verification: review.md:52-89, :163-193. Frame as "the workflow catches its own tools' mistakes", not "validators are always right" (validator severity mislabeling is a known weakness). [HIGH, framing caveat MEDIUM]

Strong alternates: test 14 caught the session's own edit defect on first run (changes.md:332); the 11-phase plan with explicit per-phase Dependencies lines and sequencing rationale (plans/2026-08-15/full-repo-review-remediation-plan.md:71-260, :315). [HIGH]

### A4. GitHub presence: verified state and recommendations

- Live metadata verified (external, https://api.github.com/repos/kevrcress/hve-claude, fetched 2026-08-19): public, 1 star, 0 forks, description set, homepage null, topics empty, has_pages false, default branch main. Every parent belief confirmed. [HIGH]
- Pages recommendation: option (a), README-as-homepage, no Pages [HIGH]. The README already covers pitch through dogfood artifacts; zero-config Jekyll over docs/ is workable (jekyll-relative-links keeps intra-docs/ links; external, docs.github.com) but docs/workflow.md:5 links ../README.md which would 404 on a docs/-scoped site, docs/ has no index.md, and README.md:288-291 links into .claude-hve-tracking/ which resolves only on the github.com file UI. Pages is cheap to add later; nothing done for (a) is wasted. A hand-built page is not justified at current audience size. [HIGH]
- Visuals, ranked: (1) mermaid RPI-loop diagram with subagent fan-out and artifact nodes, replacing or beside README.md:76-93; GitHub renders ```mermaid fences natively (external, docs.github.com, fetched 2026-08-19); stays diffable text [HIGH]. (2) asciinema terminal recording of a real /hve run (Aider precedent leads with a screencast SVG in the first viewport; external); highest impact, highest refresh cost, do second [MEDIUM]. (3) Promote the existing dogfood-artifact table (README.md:276-291) higher; neither comparable inspected has an equivalent [MEDIUM]. Skip a README tracking-tree copy (redundant) and a before/after code pair (process quality is hard to show honestly in static snippets) [MEDIUM].
- Comparable data points (external): microsoft/hve-core uses zero diagrams (badges, tables, doc links); Aider-AI/aider leads with logo, tagline, screencast. hve-claude already exceeds upstream visually with its ASCII loop. [HIGH, external]
- Topics: set 8: claude-code, claude, anthropic, ai-agents, agentic-workflow, developer-tools, prompt-engineering, workflow (per-topic justifications in the ranked list; slash-commands and code-review are optional low-priority additions). [HIGH on setting topics, MEDIUM on the exact set]
- Homepage: leave null under (a); a self-link is noise and an upstream link misattributes. Set https://kevrcress.github.io/hve-claude/ only if Pages is later enabled. [HIGH]

### A5. Fieldnotes and HiVE in public communication

- Fieldnotes: the repo contains characterization only, no description of its rendering, output, stack, or runnable state: .claude-hve-tracking/memory/2026-08-08/hive-orchestrator-project-brief.md:64-66, :168-174 ("functional artifact-dumping rather than good UI... artifact-rendering logic may be worth reusing"). Its local path is /Users/kevin/GitHub/Fieldnotes (per research/subagents/2026-07-17/friction-inventory-fieldnotes.md:8-10, gitignored). Insufficient to judge reusability; raised as an open question rather than guessed. Kevin's own characterization argues against raw Fieldnotes screenshots as the visual story. [HIGH on what the repo says; nothing verified about the app]
- HiVE: do not name it publicly [MEDIUM]. The brief records the repo as not-yet-created (brief:16, :229), no public presence, name provisional with documented collision/trademark risk and "ready to rename" guidance (brief:26-34). Honest substitutes: (1) nameless "a companion desktop app is in design"; (2) stronger and fully factual: the verified headless-invocation spike, "HVE phase commands run headlessly (claude -p) with slash-command expansion confirmed by direct test" (brief:230-242). [HIGH that the spike claim is supported; MEDIUM that it belongs on the page]

---

# Thread B: Phase-ending clarity (format locked; scope, bug, and forward-compatibility only)

## Key Findings

### B1. Closing-structure inventory (all 15 commands)

- True HANDOFF box (4): hve-research.md:144-153, hve-plan.md:163-174, hve-implement.md:170-181, hve-review.md:167-175 (conditional on ✅ Complete, hve-review.md:161). [HIGH]
- Sibling boxes, same rendering risk (4): hve-pr-review.md:183-191 ("PR REVIEW COMPLETE"; its lines 188-189 contain bare ASCII | inside rows, the worst table-parse trigger), hve-doc-ops.md:107-114, hve-memory.md:93-101, hve-prompt-builder.md:92-100. [HIGH]
- Structured non-box closes: hve.md:133-143 (fenced labeled-line "RPI Complete" summary; CLAUDE.md:228 exempts the orchestrator from the box by design), hve-prompt-analyze.md:67-86 (full fenced report template), hve-challenge.md:99-102 (partial, per-question reminder only). [HIGH]
- Little or no structure (4, flagged): hve-git-setup.md ends at Critical Constraints with NO close at all (hve-git-setup.md:71-77); hve-git-commit.md:58, hve-git-merge.md:62-69, hve-prompt-refactor.md:64 close on one-line prose directives. [HIGH]
- Correction to auto-memory (project-completion-summary-block.md): "/hve and /hve-pr-review omit it entirely, so they close with no structure at all" is true only of the HANDOFF block specifically; both define structured closes (hve.md:133-143, hve-pr-review.md:183-191). The genuinely unstructured commands are git-setup, git-commit, git-merge, prompt-refactor. [HIGH]
- Canonical definition: CLAUDE.md:214-228 (heading "Handoff Block Format" at :214, template :218-226); ships globally via install.sh merge. Cosmetic defect: mismatched double-line corner ╝ instead of ╯ at CLAUDE.md:225 and hve-research.md:152. [HIGH]
- Tests: NO drift test pins the HANDOFF box or box-drawing characters (zero grep matches across tests/); the format is free to change without test edits. Two tests shape the completion-summary carrier: test 10 (canonical blocks byte-identical across carriers, tests/run-drift-tests.sh:31-33) and test 14 (CLAUDE.md section-pointer resolution, tests/run-drift-tests.sh:42-43). Recommended carrier: one new CLAUDE.md "Completion Summary" section plus a one-line pointer per command (test-14 enforced for free, avoids 15 byte-identical copies needing a test-10 row). [HIGH on mechanics, MEDIUM on carrier choice]
- Handoff-block references needing a sanity pass on rename/format change: .claude/agents/hve-prompt-updater.md:55, .claude/commands/hve-prompt-refactor.md:50, .claude/prompts/rpi.md:23. [HIGH]

### B2. Definitive file-change lists

Item A, completion-summary block insertion (locked three-header format):
1. CLAUDE.md: new canonical "Completion Summary" section (propagates globally via ./install.sh --global)
2. .claude/commands/hve.md:131-143 (integrate with the RPI Complete summary)
3. .claude/commands/hve-research.md:127-136
4. .claude/commands/hve-plan.md:145-157
5. .claude/commands/hve-implement.md:157-164
6. .claude/commands/hve-review.md:151-161
7. .claude/commands/hve-pr-review.md:174-181
8. .claude/commands/hve-challenge.md:95-102 (fires at session end, not per question)
9. .claude/commands/hve-doc-ops.md:100-114
10. .claude/commands/hve-memory.md:86-101
11. .claude/commands/hve-git-commit.md:56-60 (currently unstructured)
12. .claude/commands/hve-git-merge.md:62-69 (currently unstructured)
13. .claude/commands/hve-git-setup.md:71-77 (no close exists; needs a new completion section)
14. .claude/commands/hve-prompt-builder.md:81-100
15. .claude/commands/hve-prompt-analyze.md:88-90
16. .claude/commands/hve-prompt-refactor.md:64 (currently one prose line)
17. tests/run-drift-tests.sh: new test-10 row only if the block text is duplicated instead of centralized
18. CLAUDE.md:19 (Lean turns clarifying clause, see B5)

Item B, HANDOFF format fix:
1. CLAUDE.md:214-228 (canonical template)
2. .claude/commands/hve-research.md:140-153 (includes the ╝ defect at :152 if any box survives)
3. .claude/commands/hve-plan.md:161-174
4. .claude/commands/hve-implement.md:168-181
5. .claude/commands/hve-review.md:165-175
6. Sibling boxes, same sweep recommended: hve-doc-ops.md:107-114, hve-pr-review.md:183-191, hve-memory.md:93-101, hve-prompt-builder.md:92-100
7. Reference sanity-check only: hve-prompt-updater.md:55, hve-prompt-refactor.md:50, .claude/prompts/rpi.md:23
8. Tests: none to change. [HIGH]

### B3. HANDOFF rendering bug: root cause

- Every source template IS fenced, but no emission instruction binds the emitted output to a fence: "End every research session with this exact block (fill in actual values):" (hve-research.md:142), "emit the Handoff Block" (hve-plan.md:157), "Every standalone phase command ends with this copyable block:" (CLAUDE.md:216); four sibling boxes have no emission sentence at all. "This exact block" and "emit" are satisfiable by bare text. [HIGH]
- No captured emitted output exists in the tracking tree or repo-root writeups. The auto-memory note (project-handoff-block-formatting.md, outside this repo) records that Kevin's screenshot showed ASCII | characters, not the source's Unicode │, in the broken table. [HIGH that the note says this]
- Strongest supported hypothesis (live rendering not observable from disk): the model regenerates the block as bare chat text, drifting glyphs to ASCII |/-; bare lines containing | are parsed as markdown table rows. The ASCII-pipe drift is the tell: a verbatim copy would contain │; a fence-preserving copy would not table-parse at all. Confirmation: one live run of a HANDOFF-emitting command capturing raw assistant output. [MEDIUM]
- Fix evaluation: Fix 1 (mandate the fence in the emission instruction) addresses the cause but leaves failure to prompt discipline, the exact failure mode already observed [MEDIUM]. Fix 2 (drop box-drawing for a plain labeled-line format, the style hve.md:133-143 already uses) is immune to table parsing with or without a fence, survives copy/paste and glyph drift, and composes cleanly under the completion-summary block (three prose headers plus a short labeled-line block reads as one close). Recommendation: Fix 2 [HIGH that it eliminates the parse failure; MEDIUM on aesthetics]; if any box is retained anywhere, add Fix 1 as belt-and-braces [MEDIUM].

### B4. Machine-parseable companion (HiVE forward-compatibility)

- Brief citations: task-index status enum pending/running/awaiting-approval/blocked/done (hive-orchestrator-project-brief.md:96-99); autonomous stop conditions reuse HVE's existing subagent-protocol categories, validator Fail, Critical finding, blocking clarifying question (brief:123-128); cheap-now/expensive-later logic stated at brief:176 and applied to mobile-readiness (:180-184) and restyling-readiness (:185-188); phases driven headlessly with outcome detection from output/disk (brief:134-166). [HIGH]
- The same logic applies [HIGH]: today a consumer could only reliably parse `Next :` (consistent across the four HANDOFF boxes); the artifact field name differs per command (Artifact/Plan/Changes/Review/Session/File/Sandbox: hve-research.md:147, hve-plan.md:166, hve-implement.md:173, hve-review.md:170, hve-doc-ops.md:110, hve-memory.md:96, hve-prompt-builder.md:95) and only hve-review carries Status (hve-review.md:172). Nothing signals awaiting-approval or blocked machine-legibly. Retrofitting a parser onto that is exactly the expensive-later case.
- Minimal addition, does not alter the locked prose format [MEDIUM]: make the HANDOFF successor itself the fixed-key carrier, emitted once per command close after the three bold headers:

```
status  : done | awaiting-approval | blocked | needs-rework
artifact: .claude-hve-tracking/<path>
next    : /hve-<command>
```

done/awaiting-approval/blocked map 1:1 onto HiVE's enum (pending/running are orchestrator-side, never emitted); needs-rework covers hve-review's ⚠️ verdict. The three stop-condition categories stay in the Subagent Response Protocol as the brief specifies. One format decision now vs a parser retrofit plus re-editing 9+ command files later. [MEDIUM]

### B5. Lean turns tension and day-to-day clarity evidence

- Distinct, not contradictory [HIGH]: CLAUDE.md:19 (principle 5, reinforced by :15 principle 1) governs the parent's mid-phase turns, one per subagent return; the completion summary is emitted once at command close, the turn where the user must decide and route. Disjoint turn types.
- Clarifying edit needed [MEDIUM]: "after subagent work" at CLAUDE.md:19 can be read to cover the final turn (the last event before close is often a subagent return, e.g. hve-review.md:136). Smallest fix: append a clause exempting command close, and have the new Completion Summary section state the converse guard ("once per command, at close; does not license verbose mid-phase turns", which also prevents the block growing into a second findings report). CLAUDE.md-only edit; no command restates principle 5. [HIGH]
- Friction evidence: .claude-hve-tracking/friction/ does not exist, zero friction logs despite the feature shipping 2026-07-17; the flag is opt-in default-off, so phase-ending pain never got captured in-band. [HIGH]
- The HANDOFF render issue was deliberately deferred twice: reviews/pr/main/2026-08-10-full-repo-review.md:7 (excluded as already tracked) and plans/2026-08-15/full-repo-review-remediation-plan.md:303 (explicitly out of scope). No rpi/pr review finding grades human-facing output clarity; the pain lives only in auto-memory. Recurring theme across both memory notes: command endings state where things are, never what the human must decide. [HIGH]

## Codebase References

README.md (front door; pitch, quickstart, benefits, dogfood links)
docs/installation.md, docs/workflow.md, docs/reference.md, docs/internals.md (doc set; sizes and purposes verified)
CONTRIBUTING.md (branch strategy, four test suites)
CLAUDE.md (RPI explanation, Handoff Block Format :214-228, Lean turns :19)
.claude/commands/*.md (all 15; closing-structure inventory above)
.claude/agents/hve-prompt-updater.md, .claude/prompts/rpi.md (handoff references)
tests/run-drift-tests.sh (test 10 :31-33, test 14 :42-43; no HANDOFF pin)
install.sh (global propagation path)
.claude-hve-tracking/reviews/rpi/2026-08-15/full-repo-review-remediation-review.md (evidence anchors)
.claude-hve-tracking/changes/2026-08-15/full-repo-review-remediation-changes.md (Correction example)
.claude-hve-tracking/plans/2026-08-15/full-repo-review-remediation-plan.md (dependency phasing; HANDOFF deferral :303)
.claude-hve-tracking/memory/2026-08-08/hive-orchestrator-project-brief.md (HiVE/Fieldnotes source)
.claude-hve-tracking/research/2026-08-19/claude-md-lean-restructure.md (in-flight sibling research; PA-001/PA-002, duplication matrix)
.claude-hve-tracking/reviews/pr/main/2026-08-10-full-repo-review.md (HANDOFF deferral :7)

## External References

https://api.github.com/repos/kevrcress/hve-claude (fetched 2026-08-19)
https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site (fetched 2026-08-19)
https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll (fetched 2026-08-19)
https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams (fetched 2026-08-19)
https://raw.githubusercontent.com/microsoft/hve-core/main/README.md (fetched 2026-08-19)
https://raw.githubusercontent.com/Aider-AI/aider/main/README.md (fetched 2026-08-19)

## Open Questions

1. (Thread A, blocks only the visual-reuse decision) Does Fieldnotes (/Users/kevin/GitHub/Fieldnotes) still run, and is its artifact rendering worth screenshotting or extracting, or should the visual story be built fresh from raw markdown artifacts?
2. (Thread A) Does the WHY case get real evidence (a worked before/after example, cost/token numbers from a real run) or stay an honest assertion? The dogfood section is the natural home for a baseline comparison.
3. (Thread A) The three evidence anchors live on fix/full-repo-review-remediation; confirm the branch merges to main before any page links them.
4. (Thread B) Scope delta to confirm with Kevin: the locked context says every command close (15 files) while the 2026-08-15 memory scoped 8; git-setup/commit/merge and prompt-refactor are the delta.
5. (Thread B) Confirm the rendering hypothesis with one live run of a HANDOFF-emitting command, capturing raw assistant output (requires a live session; not obtainable in this read-only phase).
6. (Thread B) Verify hve-review's four-way verdict (Complete / Needs Rework / Blocked / plan-absent stop) maps cleanly onto the status enum before freezing sentinel field values.
7. (Both) Sequencing with the in-flight CLAUDE.md lean restructure: which plan edits CLAUDE.md first?

## Recommended Research Follow-On

- [ ] Draft the mermaid RPI-loop diagram and verify against GitHub's supported mermaid version
- [ ] Set the 8 recommended topics (needs shell/gh in a later phase: `gh repo edit --add-topic`)
- [ ] Prototype an asciinema recording of a real /hve run to gauge production cost
- [ ] Decide the completion-summary carrier definitively (CLAUDE.md section + pointers, recommended, vs duplicated block + test-10 row)
- [ ] Reproduce the headless-invocation spike as a committed in-repo test if that proof point is used publicly
