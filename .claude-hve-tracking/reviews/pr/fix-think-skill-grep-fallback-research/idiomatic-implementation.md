# PR Review — Idiomatic Implementation: fix/think-skill-grep-fallback-research
Date: 2026-08-05
Branch: fix/think-skill-grep-fallback-research
Dimension(s): Idiomatic Implementation

## Idiomatic Implementation

### II-001 [MINOR]
Location: `.claude/commands/hve-plan.md:49`, `.claude/commands/hve.md:85`
Finding: The new wording introduces the parenthetical `(interleaved/extended thinking)` alongside "extended reasoning pass." This term appears nowhere else in the corpus — not in CLAUDE.md's Effort Level section, not in `.claude/prompts/rpi.md:9` (`--think`: Activate extended reasoning during planning), and not in the precedent fix this PR is explicitly modeled on at `.claude/commands/hve-review.md:129` ("use extended reasoning to think through..."). The established term throughout the repo is simply "extended reasoning"; adding an unglossed alternate label creates terminology drift without adding executable clarity.
Recommendation: Drop the parenthetical, or if the distinction matters, define "interleaved thinking" once (e.g. in CLAUDE.md's Effort Level section) and reference it, rather than inventing it inline in two command files.

### II-002 [MINOR]
Location: `.claude/commands/hve-plan.md:49`, `.claude/commands/hve.md:85`
Finding: The added sentence "No `/think` command exists in Claude Code — describe the behavior, don't invoke it as a slash command." is meta-commentary aimed at whoever edits this prompt file in the future, not an instruction to the agent executing the numbered step at runtime. This breaks from the corpus's established tone (`.claude/instructions/writing-style.md` Tone section: "Direct and action-oriented," "Present tense for describing behavior") — the rest of the numbered list in both files is pure imperative instruction, and this is the only step anywhere in the corpus that explains the history/rationale of a prior bug inline rather than just stating current correct behavior. The precedent line at `.claude/commands/hve-review.md:129` fixed the same class of bug without any such aside.
Recommendation: Either drop the explanatory clause now that the instruction itself is corrected, or move it to an HTML comment / footnote outside the numbered step so the runtime instruction stays a clean imperative sentence.

### II-003 [MINOR]
Location: `.claude/agents/hve-researcher.md:30` vs `.claude/commands/hve-research.md:47`
Finding: The two parallel Grep-fallback fixes state the same prohibition with different wording: hve-researcher.md says "do not reach for Bash to work around this" while hve-research.md says "never add Bash to route around this." Both files also use slightly different subject nouns ("this agent" vs "the research phase," which is contextually appropriate) but the core prohibition itself should read as the same phrase per the corpus's own consistency rule (`.claude/instructions/writing-style.md` Consistency section: "Use the same term for the same concept throughout").
Recommendation: Standardize the prohibition clause to identical wording (e.g. both use "never reach for Bash to work around this") across the two files, since they describe the exact same rule for closely related read-only carriers.

### II-004 [MINOR]
Location: `.claude/agents/hve-researcher.md:6` (tools frontmatter) vs `.claude/agents/hve-researcher.md:30`; `.claude/commands/hve-research.md:4` (allowed-tools) vs `.claude/commands/hve-research.md:47`
Finding: Both files explicitly grant Grep in frontmatter (`tools: Read, Write, Glob, Grep, WebFetch` and `allowed-tools: Read, Write, Glob, Grep, Agent`), yet the new body text hedges with "If no standalone Grep tool is available in this session." The repo's established idiom treats the frontmatter tools list as the authoritative contract for what a subagent/command can use — see `.claude/commands/hve-review.md:81`, "Never delegate a step requiring command execution to a subagent without checking its tool list." Writing defensive fallback text that contradicts the file's own declared grant is a new pattern not otherwise used in the corpus, and reads ambiguously: is Grep sometimes withheld by the harness despite the frontmatter grant, or is this guarding against a different failure mode (e.g., Grep returning no results)?
Recommendation: Clarify intent — either explain (in the file or in a shared instructions doc) that harness tool exposure can diverge from frontmatter declarations, or rephrase the condition to something the frontmatter doesn't contradict, e.g. "if Grep is unavailable or returns no usable matches."

## Positive Notes (not findings)
- The `/think` fix wording is properly modeled on the established `hve-review.md:129` precedent and is applied identically/consistently to both `hve.md` and `hve-plan.md`, with no leftover invokable `/think` references anywhere else in `.claude/` (verified via corpus-wide grep).
- The Grep-fallback addition follows the corpus's "specify fallback behavior" and "state what NOT to do alongside what to do" conventions from `.claude/instructions/writing-style.md`, and correctly reinforces each file's pre-existing read-only design constraint rather than inventing a new constraint.
