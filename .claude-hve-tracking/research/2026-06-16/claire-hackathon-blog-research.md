# Claire Hackathon Blog Research

**Prepared:** 2026-06-16  
**Prepared by:** ContentResearch Agent  
**For:** Content Implement Agent — second hve-claude blog post  
**Source materials:** `~/GitHub/Claire/.claude-hve-tracking/` (all artifacts) + `~/GitHub/Claire/README.md` + `~/GitHub/hve-claude/blog-porting-hve-to-claude-code.md`

---

## Project Context

### What is Claire?

Claire is an AI-powered Medicare Advantage member services assistant built for the **Krava + Linq hackathon on 2026-05-30** (one day). Members ask plain-English questions about their health insurance — claims, deductibles, medications, benefits, copays — and get 2–5 sentence answers at a Grade 6–8 reading level, backed by their real member data.

Two interfaces:
- **iMessage via Linq** — members text the Linq number from their phone
- **Web dashboard** (`/dashboard`) — operator-facing, real-time monitoring of all active sessions

**Stack:** Node.js + TypeScript + Express, Krava for private AI inference, Linq for iMessage webhooks, flat JSON member fixtures.

**Why Krava:** Privacy-preserving inference — member health data is encrypted in transit and at rest; the app builder cannot read user messages. All accumulator math (deductible progress, OOP progress) is computed server-side before the prompt is sent, so Claire never does the arithmetic herself.

Source: `~/GitHub/Claire/README.md` and `~/GitHub/Claire/.claude-hve-tracking/research/2026-05-30/krava-agent-reference.md`

### Hackathon Context

Kevin participated solo. The project started from a blank `npm init` and shipped to Railway with a live demo URL by end of day. He ran hve throughout the day on each meaningful task. The first blog post covered building hve; this post is about using it under real hackathon conditions — one day, a hard deadline, no tests, and everything changing.

---

## Timeline of hve Tasks

All tasks ran on 2026-05-30. Exact order uncertain (changes logs show placeholder timestamps), but reconstructed from git log and artifact dependencies.

| # | Slug | What it built | hve phases used | Notes |
|---|------|--------------|----------------|-------|
| 1 | `krava-agent-reference` | Research document on Krava SDK/API | Research → Review | Used 3 parallel subagents; reviewed Krava PDF docs |
| 2 | `minimal-krava-test` | Initial Express server proof-of-concept with Krava streaming | Full RPI | First working Claire |
| 3 | `extend-claire-server` | FHIR loader, accumulator service, prompt builder, SSE bus, 3 HTML pages | Full RPI (3 phases) | Largest task; built the real server |
| 4 | `dashboard-ui-guide` | Implementation guide doc for wiring dashboard UI | Research → Review (doc task) | Used 3 parallel subagents; discovered stale spec |
| 5 | `linq-imessage-integration` | Linq webhook handler, HMAC verification, Krava threading | Full RPI (4 phases) | 5 discrepancies caught in planning |
| 6 | `wire-dashboard-ui` | Wired static dashboard mock to live SSE backend | Full RPI (2 phases + quality re-check) | 7 discrepancies caught; 3 majors fixed |
| 7 | `er-copay-missing-from-prompt` | ER copay fix + replaced DEMO_PLAN with full Humana PPO structure | Plan only (implemented directly in conversation) | RPI skipped under time pressure |
| 8 | `flat-json-loader` | Replaced Synthea FHIR bundle loader with flat JSON schema | Full RPI (single phase) | Git commit: 17:59 |
| 9 | `fix-review-findings` | Fixed IV-001/002/003 from `extend-claire-server` review | Full RPI (3 phases) | A task whose spec was the review findings |
| 10 | `claims-service-context` | Surface claim service descriptions to Claire's prompt | Plan + plan log only | Planned but not implemented (hackathon ended) |

**Git log timeline** (from `~/GitHub/Claire`):
```
15:54 — initial commit (minimal-krava-test + extend-claire-server done)
16:37 — fix package.json
16:52 — build: use tsx in production
17:16 — feat: extract Krava/Linq services, add real plan data and dashboard UI
17:26 — fix: remove temporary Railway debug logs
17:59 — feat: replace Synthea FHIR loader with flat JSON member schema
18:21 — fix: add debug logging for KRAVA_APP_KEY length  ← BUG introduced here
18:35 — feat: initial README
```

---

## Bugs Caught by hve

These are the bugs hve caught. The most important for the blog post are the ones that would have shipped if not for the review phase.

### Bug 1: Unguarded null assertion crashes on Krava stream body (Critical → Fixed)

**Finding ID:** `minimal-krava-test` IV-001 [Critical]  
**Source:** `.claude-hve-tracking/reviews/rpi/2026-05-30/minimal-krava-test-quality.md`  
**Phase caught:** Review (quality validator)

**What it was:** `src/server.ts:53` had `response.body!.getReader()` — a non-null assertion with no guard. If Krava returned a 204 or a response with a null body, the code would throw an unhandled runtime error.

**Exact quote from review:**
> "Non-null assertion on response.body without guarantee it exists. If the fetch succeeds but body is null (e.g., due to a 204 No Content or certain streaming scenarios), the code will throw at runtime, potentially exposing the error to clients."

**What would have happened:** Crash on any edge case where the Krava response body was null, with a 500 and a stack trace returned to the user.

**Fixed during hackathon:** Yes. Added explicit guard:
```typescript
if (!response.body) {
  throw new Error('Krava response missing body stream');
}
const reader = response.body.getReader();
```
Source: Review log "IV-001 Critical | `response.body!.getReader()` — unguarded null assertion | Fixed: explicit `if (!response.body)` guard added at `src/server.ts:53`"

---

### Bug 2: Internal error details leaked to client in 500 response (Major → Fixed)

**Finding ID:** `minimal-krava-test` IV-002 [Major]  
**Source:** `.claude-hve-tracking/reviews/rpi/2026-05-30/minimal-krava-test-quality.md`  
**Phase caught:** Review (quality validator)

**What it was:** `src/server.ts:76` — `return res.status(500).json({ error: String(err) });`  
Turned the full error object into a string and returned it to the client, which could include API URLs, stack traces, internal service names.

**What would have happened:** Any Krava error would expose implementation details to the browser. In a demo scenario with judges, this would show raw internal error messages.

**Fixed during hackathon:** Yes. Replaced `String(err)` with a static message; full error still logged server-side.

---

### Bug 3: Empty webhook secret allows HMAC forgery (Critical → Downgraded to Major, not fully fixed)

**Finding ID:** `linq-imessage-integration` IV-001 [Critical → Major]  
**Source:** `.claude-hve-tracking/reviews/rpi/2026-05-30/linq-imessage-integration-review.md`  
**Phase caught:** Review (quality validator)

**What it was:** `src/routes/webhooks/linq.ts:78` — `const secret = process.env.LINQ_WEBHOOK_SECRET ?? ''`  
If `LINQ_WEBHOOK_SECRET` is unset, HMAC is computed against an empty string. An attacker who knows the algorithm (HMAC-SHA256, which is public in the code) can forge a valid webhook signature.

**Exact quote from review:**
> "If LINQ_WEBHOOK_SECRET is unset, HMAC is computed against an empty string — any attacker who knows the algorithm can forge valid signatures. Easy one-line fix: return false early if secret is empty."

**What would have happened:** Any external actor could POST fake Linq webhooks and trigger Claire to respond as if it were a real member message.

**Fixed during hackathon:** Downgraded to Major. The review verdict: "Major for hackathon (env var is set in deployment; risk is misconfiguration, not active exploitation)." The fix (a 2-line guard) was called out explicitly but deferred.

---

### Bug 4: JSON.parse in SSE handlers crashes React tree on malformed data (Major → Fixed)

**Finding ID:** `wire-dashboard-ui` IV-001 [Major]  
**Source:** `.claude-hve-tracking/reviews/rpi/2026-05-30/wire-dashboard-ui-review.md`  
**Phase caught:** Review (quality validator)

**What it was:** All five SSE event handlers in `public/app.jsx` called `JSON.parse(e.data)` without a try-catch. A single malformed SSE frame (e.g., a partial frame on reconnect) would throw and crash the entire React component tree.

**Exact quote from review:**
> "Risk: malformed SSE data (e.g. a transient partial frame) crashes the React component tree"

**What would have happened:** During a live demo, any SSE hiccup (transient network drop, server restart) would crash the dashboard silently, requiring a page reload to recover. This is the kind of thing that happens exactly when judges are watching.

**Fixed during hackathon:** Yes. Re-validated in `.claude-hve-tracking/reviews/rpi/2026-05-30/wire-dashboard-ui-quality-v2.md`: "✅ IV-001 resolved: all six SSE handlers have try-catch around JSON.parse (app.jsx:405–471)"

---

### Bug 5: No SSE disconnect feedback — stale dashboard silently shows dead session (Major → Fixed)

**Finding ID:** `wire-dashboard-ui` IV-002 [Major]  
**Source:** `.claude-hve-tracking/reviews/rpi/2026-05-30/wire-dashboard-ui-review.md`  
**Phase caught:** Review (quality validator)

**What it was:** `public/app.jsx` had no `es.onerror` handler on the EventSource. If the SSE connection dropped, the dashboard would show stale member data with no indication that it was no longer live.

**What would have happened:** Demo audience watching the dashboard would think they're seeing a live session when they're looking at frozen data.

**Fixed during hackathon:** Yes. Added `sseError` state, `es.onerror` handler, and "Connection lost — reconnecting..." error banner. Re-validated: "✅ IV-002 resolved: sseError state + es.onerror + error banner rendered (app.jsx:280, 403, 519–524)"

---

### Bug 6: .gitignore missing TLS/JWT key patterns (Major → Fixed)

**Finding ID:** `wire-dashboard-ui` IV-003 [Major]  
**Source:** `.claude-hve-tracking/reviews/rpi/2026-05-30/wire-dashboard-ui-review.md`  
**Phase caught:** Review (quality validator)

**What it was:** `.gitignore` was missing `*.pem`, `*.key`, `*.p12`, `*.pfx` — TLS and JWT key file patterns. If any cert or key file landed in the project directory, it could be committed.

**Fixed during hackathon:** Yes. Re-validated: "✅ IV-003 resolved: *.pem, *.key, *.p12, *.pfx all present in .gitignore"

---

### Bug 7: Debug logs expose KRAVA_APP_KEY metadata at startup (Critical → NOT FIXED)

**Finding ID:** `er-copay-missing-from-prompt` IV-001 [Critical]  
**Source:** `.claude-hve-tracking/reviews/rpi/2026-05-30/er-copay-missing-from-prompt-quality.md`  
**Phase caught:** Review (quality validator)

**What it was:** `src/server.ts:2-3` — two `console.log` statements added during debugging:
```typescript
console.log('[debug] KRAVA_APP_KEY present:', !!process.env.KRAVA_APP_KEY, 'length:', process.env.KRAVA_APP_KEY?.length ?? 0);
console.log('[debug] KRAVA_BASE_URL:', process.env.KRAVA_BASE_URL);
```
These were added in git commit `18:21 — "fix(server): add debug logging for KRAVA_APP_KEY length and value representation"`. The app was deployed to Railway. These logs were running in production.

**Exact quote from review:**
> "Startup logs may be captured by monitoring/observability systems, APM agents, or container orchestration platforms. Although not leaking the key itself, confirming presence and length enables attackers to validate environment state. KRAVA_BASE_URL exposes internal infrastructure configuration."

**What would have happened:** Railway captures all stdout. Any monitoring system or operator with log access could confirm the key's presence and length — useful for brute-force validation or confirming target systems.

**Fixed during hackathon:** No. The `er-copay-missing-from-prompt` review marked the task "⚠️ Needs Rework" with this as Critical, but the task status remained "In Progress" and the fix was not applied before the hackathon ended. A previous commit at 17:26 had removed *other* debug logs ("remove temporary Railway debug logs"), but new ones were added at 18:21 and caught by the review.

---

### Bug 8: OOP accumulator not capped — showing $10,973.98 instead of $4,500 max (Found by live testing, not hve)

**Source:** `.claude-hve-tracking/changes/2026-05-30/extend-claire-server-changes.md` — "Post-Implementation Fix" section  
**Phase caught:** Live data testing (not hve review)

**What it was:** During live testing, `oopPaid` was not capped at `oopTotal`. Andrew Williamson's Synthea data had `memberOwes` values summing to $10,973.98 — nearly 2.5x the $4,500 OOP max. The member dashboard would show he owed $10,973 out of a $4,500 cap.

**Exact quote from changes log:**
> "Bug found during live data testing: `oopPaid` was not capped at `oopTotal`. Andrew Williamson's 2026 `memberOwes` summed to $10,973.98 (Synthea over-reports member liability), exceeding the $4,500 OOP max."

**Fix:** Added `oopPaid = Math.min(oopPaid, oopTotal)` in `accumulator.ts:30` — symmetric with the existing deductible cap. Result: "andrew_williamson shows OOP $4,500.00/$4,500.00 (correct — maxed out)."

**Note for blog post:** This is an interesting contrast case. hve's review phase catches *structural and security* bugs. This was a *data interaction* bug that only appeared when real data was loaded. The lesson: hve and live testing are complementary, not redundant.

---

## Work Saved by hve (Planning-Phase Catches)

These are cases where the planning phase caught something before implementation started — preventing wasted work.

### DR-001 (extend-claire-server): Referenced spec called `streamKravaChat` as if it exists

**Source:** `.claude-hve-tracking/plans/logs/2026-05-30/extend-claire-server-log.md`

> "The spec's updated POST /chat handler references `streamKravaChat(userToken, message, { chatId, system })` as if it already exists, but the existing server uses inline streaming."

**What would have happened:** Implementation would have tried to import a function that didn't exist, hit a runtime error on first test, then had to figure out where the function was supposed to come from. Instead, planning resolved it: Phase 2, Step 2.1 explicitly extracts the helper first.

---

### DR-002 (extend-claire-server): New handler also needs `userId` but Krava SDK type wasn't visible

**Source:** `.claude-hve-tracking/plans/logs/2026-05-30/extend-claire-server-log.md`

Planning caught that `getOrCreate` returns both `userToken` and `userId`, but the Krava SDK type wasn't exported, making the field name uncertain. Resolution logged: "Cast as `{ userToken: string; userId: string }` and use `patientId` as fallback if `userId` is undefined at runtime."

---

### DR-003 (extend-claire-server): Loader can't compute accumulators at load time

**Source:** `.claude-hve-tracking/plans/logs/2026-05-30/extend-claire-server-log.md`

> "loadAllPatients returns LoadedPatientData which includes accumulators: AccumulatorState, but accumulators are calculated in server.ts after loading. The loader itself cannot compute them."

Resolution: Loader initializes accumulators with zero values; server overwrites immediately. Caught before implementation, preventing a type error mid-build.

---

### DR-007 (wire-dashboard-ui): Stale "Analyzing" state persists on session switch — Major visual bug

**Source:** `.claude-hve-tracking/plans/logs/2026-05-30/wire-dashboard-ui-log.md`

This is the strongest example in the set. The plan log caught a Major visual bug *before a line of code was written:*

> "Plan §2.2 says 'Session switch handler: setActiveId, call loadSession if not cached, clear analyzing/context/attestTime.' However, Details §SSE Handler (line 207-209) shows only setActiveId(id) and activeIdRef.current = id in handleSelect — no clearing of state."
>
> "Gap: The 'Analyzing in secure enclave' spinner and TEE timestamp will persist visually from the previous session until the next SSE event overwrites them. When switching to a cached session with no recent messages, stale spinner/timestamp will appear."
>
> "Severity: Major — visual bug that creates confusion (old session's 'Analyzing' indicator persists on new session until a message arrives)."
>
> "Status: Open — blocking Phase 2 implementation."

**What would have happened:** Member services demo with the judge watching. Agent switches sessions. The previous member's "Analyzing in secure enclave" indicator hangs on screen for the new member, making the dashboard look broken. This was caught entirely in planning.

---

### DR-001 (wire-dashboard-ui): Spec said SSE payload field was `text`, actual backend sends `response`

**Source:** `.claude-hve-tracking/plans/logs/2026-05-30/wire-dashboard-ui-log.md`

> "Dashboard UI guide spec (§2.1) documents the SSE payload as `{ text, timestamp, memberContext }` based on the original task prompt. Actual backend (`src/server.ts:178`) broadcasts `{ patientId, response, timestamp }` — no `text` field, no `memberContext`."

The spec was stale. Planning caught it by inspecting the actual server code and corrected it before implementation started. If implementation had followed the spec, `e.data.text` would always be `undefined` and the dashboard would never display Claire's responses.

---

### DR-002 (wire-dashboard-ui): Spec said API returns cents — actual backend returns dollars

**Source:** `.claude-hve-tracking/plans/logs/2026-05-30/wire-dashboard-ui-log.md`

> "DashboardData interface in the original guide spec uses cents. Backend implementation (src/server.ts:99-105) divides by 100 before sending to the frontend."

If implementation had followed the spec and divided by 100 again, all monetary values would be 100x too small (e.g., deductible showing $0.01 instead of $1.00).

---

### DR-001 (linq-imessage-integration): Middleware ordering — `express.json()` can't be before the webhook

**Source:** `.claude-hve-tracking/plans/logs/2026-05-30/linq-imessage-integration-log.md`

> "The task spec says to mount the webhook route. In current server.ts, patients are loaded at line 59 — after app.use(express.json()) at line 55. Mounting the webhook route with createLinqRouter(patients, platform) requires patients to be available at mount time."

Caught in planning. The fix (move `express.json()` after webhook mount) was explicit in the implementation phases. Without this catch, the webhook handler would have received parsed JSON instead of raw body, breaking HMAC verification.

---

### DR-005 (linq-imessage-integration): Linq chat threading API contract unverified

**Source:** `.claude-hve-tracking/plans/logs/2026-05-30/linq-imessage-integration-log.md`

> "It is unclear from the spec alone whether a chatId field in the request body is required/supported for threading."

Planning explicitly marked this as a known risk (Severity: Major in the validation log) and documented it as "implementor must verify against live Linq API docs before integration testing." Rather than having the implementation silently fail in testing, the risk was surfaced and tracked.

---

### DR-001 (er-copay-missing-from-prompt): Dashboard hardcodes $20/$45 copays but DEMO_PLAN has $10/$40

**Source:** `.claude-hve-tracking/plans/logs/2026-05-30/er-copay-missing-from-prompt-log.md`

> "PCP and Specialist copay values diverge between dashboard and prompt. app.jsx hardcodes PCP $20 / Specialist $45; DEMO_PLAN has $10 / $40. Resolution: Update DEMO_PLAN to match dashboard — dashboard is the member-visible source of truth."

Claire's spoken answer would have contradicted the dashboard display. A member could ask "what's my copay?" and Claire would say $10, but the dashboard shows $20.

---

## Interesting Patterns

### 1. Parallel subagents for research

Two tasks used parallel research subagents:

**`krava-agent-reference`** — 3 parallel subagents reading Krava's PDF documentation:
- `krava-agent-reference-overview-setup.md`
- `krava-agent-reference-auth-access.md`
- `krava-agent-reference-api-chat.md`

Each subagent read a different set of Krava docs concurrently, then the main agent synthesized into a single reference document. The consolidated doc was then reviewed and passed with 3 minor findings.

**`dashboard-ui-guide`** — 3 parallel subagents doing initial research on the dashboard:
- `dashboard-ui-guide-components.md`
- `dashboard-ui-guide-data-model.md`
- `dashboard-ui-guide-accessibility.md`

However — the memory artifact records that this research was **partially superseded** because the task prompt's spec was stale. The real design came from an actual HTML/JSX package that had to be extracted from a gzip archive (WebFetch returned binary, not HTML). The subagent research produced a component inventory that didn't match the real layout. The memory notes: "that research is partially superseded by the real HTML — the component inventory it produced does NOT match the real layout."

This is a real pattern worth calling out in the blog: when a task prompt describes something stale, the research phase catches it by going to primary sources.

Source: `.claude-hve-tracking/memory/2026-05-30/dashboard-ui-guide.md`

---

### 2. The spec was wrong, and planning found the ground truth

Three times, planning caught that the task spec was describing something that no longer matched the actual codebase:

- **DR-001 (wire-dashboard-ui):** Spec said SSE event field was `text`; actual server sent `response`
- **DR-002 (wire-dashboard-ui):** Spec said API values were in cents; actual server sent dollars
- **dashboard-ui-guide memory:** "Wrote the guide against the ACTUAL UI, not the task-prompt spec. The original task prompt described a layout that turned out to be stale."

At a hackathon, where tasks are written once and the codebase changes fast, specs go stale within hours. hve's planning phase reads the actual code before building, which means these drift cases get caught.

---

### 3. `fix-review-findings` as a formal task

After `extend-claire-server` review produced 3 actionable findings, Kevin created a dedicated task (`fix-review-findings`) to address them. This task had its own full RPI loop — plan, implement, review — and a clean validation: "Critical: 0 | Major: 0 | Minor: 0." 

The "spec" for this task was the review document itself. This pattern (review → new task → fix → re-review) is something that naturally emerges from hve and is worth calling out.

Source: `.claude-hve-tracking/reviews/rpi/2026-05-30/fix-review-findings-review.md`

---

### 4. What happens when you skip the workflow under time pressure

`er-copay-missing-from-prompt` was the clearest example of running outside hve. From the review log:

> "RPI validator skipped — no changes log artifact (implementation was done directly in conversation, not via /hve-implement)."

The result: the review caught a Critical security bug (debug logs exposing KRAVA_APP_KEY metadata) that was NOT fixed before the hackathon ended. The task status was "In Progress / Needs Rework." The critical bug shipped to Railway.

By contrast, every task that went through the full RPI loop ended with all critical and major findings addressed before moving on. The one task that skipped hve under time pressure produced the only unresolved Critical finding of the day.

---

### 5. The SDK export that wasn't there

`minimal-krava-test` plan assumed `streamKravaChat` was an exported function from `@kravalabs/api-client`. The research document listed it as "confirmed." 

The RPI validator found, by actually inspecting `node_modules/@kravalabs/api-client/dist/index.d.ts`, that the export didn't exist:

> "SDK exports verified: createKravaPlatformClient ✅ present; streamKravaChat ❌ absent"

Implementation correctly adapted: raw fetch + SSE parsing instead. The deviation was documented in the changes log and the review noted it as Minor (the adaptation was correct).

This pattern — research says something exists, RPI validator checks the actual package — is a concrete demonstration of how each phase adds independent verification rather than just accepting the prior phase's outputs.

Source: `.claude-hve-tracking/reviews/rpi/2026-05-30/minimal-krava-test-rpi.md`

---

### 6. The multi-phase living decision log

The planning logs capture something genuinely interesting for the blog: they're not just "here's the plan" documents. They're a *living record of what was uncertain or wrong at planning time*, with resolution status tracked per item. Examples from `extend-claire-server`:

- DR-001 (streamKravaChat undefined): `Status: Resolved`
- DR-002 (userId field name): `Status: Open — verify userId field name at runtime`
- DR-003 (AccumulatorState timing): `Status: Resolved`
- DR-004 (Route conflict): `Status: Resolved — explicit route handles both cases`

An "Open" status in a plan log means "we know this is uncertain, and we named it so it can be verified in implementation." This is different from just ignoring the uncertainty.

---

### 7. Severity calibration under time pressure

The review phase under hackathon conditions explicitly reasoned about severity in hackathon context, not production context. Examples:

- `linq-imessage-integration` IV-001: "Downgraded to Major for hackathon (env var is set in deployment; risk is misconfiguration, not active exploitation)."
- `flat-json-loader` IV-001/IV-002 (Major): "Deferring these to post-hackathon cleanup is reasonable."
- `minimal-krava-test` IV-003 (Major — buffered streaming): "Accepted: test UI sends one message at a time and awaits; progressive streaming adds complexity without UX benefit for this PoC"

This is a nuanced pattern: hve isn't a wall that blocks shipping. It surfaces findings with severity reasoning, and the developer makes an informed choice about what to fix now vs. defer. The findings exist and are tracked even when deferred.

---

## Hackathon-Specific Observations

**Time pressure changes how hve is used, not whether it's used.**  
Of the 10 tasks, 6 ran full RPI. 1 ran partial (plan only). 1 skipped implement/review entirely. 2 were research/doc tasks. Even under a single-day hackathon, Kevin ran the full loop on the majority of tasks.

**The tasks most likely to skip hve were the scope-expanding ones.**  
`er-copay-missing-from-prompt` grew significantly beyond its original scope (started as a 4-line ER copay fix, ended up replacing the entire DEMO_PLAN structure with a full nested Humana PPO plan + Part D). When scope expanded in conversation, the hve artifacts fell behind. The review caught the resulting mess, but it was too late to do a clean fix.

**Planning artifacts outlasted their tasks.**  
`claims-service-context` has a plan and a plan log, but no changes or review artifacts — it was planned but the hackathon ended before implementation started. The plan survived as documentation of what would have been next.

**The living demo URL changed the stakes for robustness.**  
Several findings reference Railway as the deployment target. The dashboard being publicly accessible (live demo URL: `hackathonclaire-production.up.railway.app`) meant SSE disconnect handling and error recovery weren't just polish — a crashing dashboard during a live demo is a demo failure. The wire-dashboard-ui fixes (IV-001/002/003, all resolved) addressed exactly that.

**"Accepted for hackathon" is a documented decision, not an oversight.**  
Multiple findings ended with explicit acceptance decisions: "acceptable for hackathon scope," "deferred per plan," "acceptable per original review." These aren't gaps — they're tracked decisions that would have been unknown risks if hve hadn't surfaced them.

---

## Artifact Statistics

| Category | Count |
|----------|-------|
| Task slugs with any hve artifact | 10 |
| Full RPI loops (plan + changes + review) | 6 |
| Research-only tasks | 2 (`krava-agent-reference`, `dashboard-ui-guide`) |
| Partial loops (plan only) | 1 (`claims-service-context`) |
| Partial loops (skipped implement/review) | 1 (`er-copay-missing-from-prompt`) |
| Plan files | 7 |
| Plan logs (discrepancy/decision records) | 6 |
| Changes files | 7 |
| Details files | 6 |
| Memory files | 1 |
| Main review files | ~12 |
| Phase validation files | ~10 |
| Research files (main) | 3 |
| Research files (subagents) | 6 |
| **Total artifact files** | **~70** |

**Bugs by severity across all reviews:**

| Severity | Total Found | Fixed During Hackathon | Deferred | Not Fixed (shipped) |
|----------|-------------|----------------------|----------|---------------------|
| Critical | 3 | 1 (IV-001 minimal-krava-test) | 1 (IV-001 linq webhook secret) | 1 (IV-001 KRAVA_APP_KEY debug log) |
| Major | ~12 | ~6 | ~4 | 2 |
| Minor | ~20 | ~5 | ~15 | 0 |

**Discrepancy records (DR-NNN) in plan logs:**
- `extend-claire-server`: 4 (DR-001 to DR-004, all resolved)
- `flat-json-loader`: 4 (DD-001 to DD-004, all resolved)
- `linq-imessage-integration`: 5 DRs + 5 DDs (2 major open at planning, flagged)
- `wire-dashboard-ui`: 7 (DR-001 to DR-007; DR-007 was Major blocking)
- `er-copay-missing-from-prompt`: 2 (DR-001, DD-001, both resolved)
- `claims-service-context`: 3 (DD-001 to DD-003, all resolved in plan)

---

## Raw Notes

### Tone and angle for the blog post

The first post was about *building* hve. This post should be about *relying on it* — specifically in the worst conditions for careful engineering: one day, hard deadline, no tests, changing scope.

Kevin's exact words from the first post's closing: "there's a follow-up coming about the time I leaned on this thing to get through a hackathon with my sanity intact."

Key angles:
1. **The spec was wrong, and planning found it.** Multiple times. This is the most repeatable pattern.
2. **The review caught what live testing wouldn't.** The SSE disconnect bug (IV-002 in wire-dashboard-ui) would not have appeared until a specific network event during a demo. The JSON.parse crash (IV-001) would only appear on a specific malformed frame. These aren't things you'd find by "testing" — they require reading the code with a specific failure mode in mind.
3. **The one task that skipped hve produced the only unresolved Critical.** This is a strong concrete contrast. The debug log security bug was introduced in a commit at 18:21, not caught by any review because the task ran outside hve, and deployed to Railway.
4. **Severity calibration, not severity absolutism.** hve doesn't block shipping. It surfaces findings with reasoning, and the developer makes the call. Every deferred finding in the log has an explicit rationale.
5. **Parallel subagents made the research phases fast.** At a hackathon, waiting for 10-minute serial research runs isn't viable. The 3-subagent pattern on krava-agent-reference and dashboard-ui-guide was the difference between research taking 3 minutes and 9 minutes.

### Quote integrity — direct quotes from artifacts worth preserving

From `wire-dashboard-ui-log.md` on the stale analyzing bug:
> "The 'Analyzing in secure enclave' spinner and TEE timestamp will persist visually from the previous session until the next SSE event overwrites them. When switching to a cached session with no recent messages, stale spinner/timestamp will appear."

From `linq-imessage-integration-review.md` on the empty webhook secret:
> "If LINQ_WEBHOOK_SECRET is unset, HMAC is computed against an empty string — any attacker who knows the algorithm can forge valid signatures. Easy one-line fix: return false early if secret is empty."

From `er-copay-missing-from-prompt-review.md` on the debug log bug:
> "Although not leaking the key itself, confirming presence and length enables attackers to validate environment state. KRAVA_BASE_URL exposes internal infrastructure configuration."

From `minimal-krava-test-rpi.md` on the missing SDK export:
> "Research document incorrectly identified streamKravaChat as a confirmed export. Implementation correctly adapted to actual SDK; no functional loss."

From `dashboard-ui-guide.md` memory on the stale spec:
> "Wrote the guide against the ACTUAL UI, not the task-prompt spec. The original task prompt described a layout that turned out to be stale. The real design was retrieved mid-session from a user-provided URL. Source of truth = the real HTML/JSX, not the prompt."

From `extend-claire-server-changes.md` on the OOP cap bug (found by live testing, not hve):
> "Bug found during live data testing: oopPaid was not capped at oopTotal. Andrew Williamson's 2026 memberOwes summed to $10,973.98 (Synthea over-reports member liability), exceeding the $4,500 OOP max."

### Open questions for the writer

1. Should the blog post mention the KRAVA_APP_KEY debug log bug was deployed but not fixed? It's a good concrete example, but it makes Kevin look like he shipped a Critical finding. Whether to include depends on how honest the post wants to be about hackathon realities vs. hve limitations.

2. Should the post include the OOP cap bug (found by live testing, not hve)? It's a useful contrast case — shows what hve doesn't catch — but it also shows that live testing still has a role.

3. The post should probably not include all 10 tasks. Suggested narrative focus: minimal-krava-test (first bug), wire-dashboard-ui (most dramatic planning catch + fixed review bugs), er-copay/fix-review-findings as contrast, linq webhook secret. That's enough to carry the story.

4. The first post ended with an installer invite. Does this post end the same way? Or with something more specific to the hackathon experience?

### Key file paths for writer to reference

- `~/GitHub/Claire/.claude-hve-tracking/plans/logs/2026-05-30/wire-dashboard-ui-log.md` — DR-007, the stale analyzing state bug
- `~/GitHub/Claire/.claude-hve-tracking/reviews/rpi/2026-05-30/minimal-krava-test-quality.md` — IV-001/002 critical/major bugs found and fixed
- `~/GitHub/Claire/.claude-hve-tracking/reviews/rpi/2026-05-30/linq-imessage-integration-review.md` — IV-001 webhook secret vulnerability
- `~/GitHub/Claire/.claude-hve-tracking/reviews/rpi/2026-05-30/wire-dashboard-ui-review.md` — IV-001/002/003 all fixed
- `~/GitHub/Claire/.claude-hve-tracking/reviews/rpi/2026-05-30/wire-dashboard-ui-quality-v2.md` — re-validation confirming all fixed
- `~/GitHub/Claire/.claude-hve-tracking/reviews/rpi/2026-05-30/er-copay-missing-from-prompt-review.md` — the unresolved Critical
- `~/GitHub/Claire/.claude-hve-tracking/memory/2026-05-30/dashboard-ui-guide.md` — stale spec pattern
- `~/GitHub/Claire/.claude-hve-tracking/reviews/rpi/2026-05-30/minimal-krava-test-rpi.md` — SDK export miss caught by RPI validator
