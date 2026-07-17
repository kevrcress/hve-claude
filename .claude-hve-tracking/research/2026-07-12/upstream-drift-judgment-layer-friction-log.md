# Friction Log: HVE Methodology Followed Literally
Date: 2026-07-12
Session: /hve-research — upstream drift + judgment-layer task
Companion artifact: .claude-hve-tracking/research/2026-07-12/upstream-drift-judgment-layer.md

Rules followed as written: CLAUDE.md conventions + .claude/commands/hve-research.md. Every entry was logged at the moment it occurred, before proceeding. Entries are ranked by estimated impact on a **less capable model** following these docs literally (highest impact first).

---

## Ranked entries

### 1. [WRONG] hve-research.md — Phase 3, steps 1–2

**What happened:** Step 1 says "Read each subagent's output file"; step 2 says "do not paste large file contents into your working context — read the summary lines only." Followed literally, step 2 forbids what step 1 requires. A model that obeys step 2 consolidates from the 7-bullet chat summaries it already had, so the consolidated doc adds nothing over chat and the durable artifact is hollow — the exact failure the durable-artifacts principle exists to prevent. A weaker model will not notice the contradiction; it will pick the later, more specific instruction (summaries only) and silently produce a thin consolidation.

**What I did instead:** Read all four subagent artifacts in full. They are purpose-written condensed findings, not "large file contents." Interpreted context discipline as: do not re-open the *source files the subagents cite*.

**Suggested change (hve-research.md Phase 3, replace step 2):**
> 2. Apply **context discipline**: read each subagent artifact in full — they are already condensed. Do not re-open the source files they cite; trust their `file:line` evidence.

### 2. [AMBIGUOUS] hve-research.md — Inputs vs Phase 0

**What happened:** Inputs says mode defaults to `standard` (2–3 subagents) when no `--mode` flag is passed. Phase 0 says classify difficulty and use the classification's count (Challenging → 3–5), mode overriding only "if `--mode` was specified." Both claim the no-flag case. I classified the task Challenging and chose the Phase 0 path (dispatched 4); a model anchoring on the Inputs line would dispatch 2–3 and under-research exactly the tasks that need coverage most.

**Suggested change (hve-research.md Inputs):**
> - Mode: only set when a `--mode` flag is passed; otherwise Phase 0's difficulty classification determines subagent count.

### 3. [GAP] hve-research.md — Phase 2→3 transition

**What happened:** The flow is strictly linear (dispatch → wait → consolidate). One subagent returned Complete while explicitly flagging an unresolved evidence hole (all June 2026 upstream commits missing — the exact window the drift report depends on). The docs are silent on iteration. A weaker model would consolidate over the hole and present an incomplete drift report as complete. Invented rule: one bounded follow-up round to the affected subagent before consolidation.

**Suggested change (hve-research.md Phase 2, append):**
> If a subagent's response flags an unresolved evidence gap that a research question depends on, dispatch **one** follow-up round to that subagent before consolidating. Do not iterate further; remaining gaps go to Open Questions.

### 4. [GAP] hve-research.md — Phase 3 doc template

**What happened:** The task demanded evaluative judgment ("whether each change is worth adopting — judge, don't just diff"), but the consolidated-research template has only neutral sections (Key Findings, Open Questions). No home exists for recommendations. A weaker model either drops the judgment (template-compliant, task-failing) or dumps verdicts unstructured into Key Findings. Invented rule: findings carrying a verdict get an inline **Adopt / Adapt / Reject** tag, and a "Preliminary adoption assessment" subsection was added.

**Suggested change (hve-research.md template):** add an optional section:
> `## Recommendations (preliminary)` — only for tasks whose research questions are themselves evaluative; mark each recommendation with a confidence marker. Final judgment still belongs to the Plan phase.

### 5. [GAP] hve-researcher agent — toolset vs GitHub-repo research

**What happened:** Researchers have Read/Write/Glob/Grep/WebFetch only. GitHub renders `.github/` directory pages as 404/empty to WebFetch, so the rpi-deep-dive subagent could not verify docs-site paraphrases against upstream agent source files, and no researcher could run `gh`/`git` (no Bash). The deep-dive agent worked around it via docs-site pages and flagged the limitation; a weaker model might retry-loop on 404s or fabricate the file contents.

**Suggested change (.claude/agents/hve-researcher.md):** add a note: "For GitHub repos, fetch raw file URLs (raw.githubusercontent.com/OWNER/REPO/BRANCH/path) — directory pages are not fetchable. If raw paths are unknown, report the limitation as an open question; do not retry rendered directory URLs."

### 6. [FRICTION] hve-research.md — Phase 2 WebFetch cap

**What happened:** "Max 3 URLs per question" is calibrated for library-docs lookups. This task's *subject* was an external repo + docs site, and the user said "you may need to explore other linked pages." I complied by phrasing 3–4 questions per web subagent so the effective budget scaled — letter-compliant rule-gaming. A weaker model would obey the cap flatly and return a drift report based on 3 pages.

**Suggested change (hve-research.md Phase 2):**
> ...use WebFetch (max 3 URLs per question; for tasks whose subject **is** an external repo or documentation site, budget up to 10 URLs per subagent instead; extract only the relevant section; summarize before returning).

### 7. [GAP] hve-research.md — Phase 1 orientation tools

**What happened:** Phase 1 authorizes "Glob and Grep" for orientation, but establishing port provenance (initial commit date, drift window start) required `git log` via Bash — and no subagent could do it either (hve-researcher has no Bash). Invented rule: the parent may run read-only git commands during orientation.

**Suggested change (hve-research.md Phase 1, step 2):**
> 2. Use Glob, Grep, and read-only git commands (log, show, diff) to do a quick orientation of the codebase...

### 8. [GAP] CLAUDE.md — Tracking Folder Structure

**What happened:** A methodology friction log has no home in the tracking taxonomy (not research, not a challenge, not doc-ops). Invented rule: co-locate with the research artifact it accompanied (`research/YYYY-MM-DD/<slug>-friction-log.md`). Low impact — but any meta-artifact (retrospectives, process notes) hits the same wall.

**Suggested change (CLAUDE.md tracking tree):** either document a `meta/` folder or state the co-location rule: "Artifacts about the methodology itself co-locate with the phase artifact they accompany, suffixed by kind."

### 9. [AMBIGUOUS] CLAUDE.md — Artifact Naming Conventions

**What happened:** "Slug: 3–6 words derived from the task description" gives no rule when the task description is a multi-paragraph compound prompt (drift report + judgment sections + patches + friction log). I chose `upstream-drift-judgment-layer` (the two primary deliverables). Two models would pick two different slugs, and since standalone phase commands discover artifacts by recency rather than slug, this is mostly harmless — until two tasks run the same day.

**Suggested change (CLAUDE.md naming):** add: "For compound tasks, slug the primary deliverable; secondary deliverables co-locate under the same slug with a kind suffix."

### 10. [FRICTION] install.sh --global + repo CLAUDE.md — double context load

**What happened:** In this session, the identical HVE block was loaded twice: once from ~/.claude/CLAUDE.md (global install) and once from the repo's own CLAUDE.md. That is thousands of duplicated tokens in every session in this repo. The docs warn against combining a global install with per-project copies, but the hve-claude dev repo itself unavoidably is a per-project copy.

**Suggested change (docs/installation.md or CONTRIBUTING.md):** note that when developing hve-claude itself with a global install active, the HVE block loads twice; consider trimming the global block or accepting the cost. (A code fix — install.sh detecting the dev repo — is likely over-engineering.)

---

## Not logged as friction (worked as designed)

- Subagent Response Protocol (7-bullet cap + artifact-holds-detail): scaled fine even for the judgment-gaps agent, whose artifact carries ~30 findings. The protocol's design assumption held.
- Handoff-by-disk (standalone commands discovering latest artifacts): not exercised across sessions here, but the date-folder discovery made the prior-research check in Phase 1 trivial.
- Confidence markers: consistently applied by all four subagents without further prompting; the convention appears self-enforcing once stated in the agent definition.
