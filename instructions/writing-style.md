# Writing Style Standards

> Apply these standards when writing documentation, agent instructions, and prompt engineering artifacts.

## Tone

- Direct and action-oriented
- Second person for instructions: "Read the file" not "The agent reads the file"
- Present tense for describing behavior: "This command spawns..." not "This command will spawn..."
- No hedging language: "always", "must", "never" are preferred over "should", "might", "could"

## Structure

- Lead with the most important information
- Use numbered steps for sequential procedures
- Use bullet points for non-sequential items
- Use tables for comparisons and reference data
- Use code blocks for all commands, file paths, and code snippets

## Instructions for AI Agents

- Be specific: "Spawn one hve-researcher subagent per research theme" not "Spawn researcher subagents"
- Quantify limits: "up to 7 findings", "max 3 URLs", "≤ 240 chars each"
- Name the tool to use: "via the Agent tool", "using Bash", "with Grep"
- Specify output paths explicitly: `.claude-hve-tracking/research/YYYY-MM-DD/topic.md`
- State what NOT to do alongside what to do: "Read; never write to implementation files"

## Avoiding Ambiguity

- Define all placeholders: `{{YYYY-MM-DD}}`, `TASK-SLUG`, `PHASE-N`
- Specify fallback behavior: "If not specified, use the most recent artifact"
- State success criteria: "Complete when all plan steps are checked off"
- State blocking conditions: "Stop and surface to the user if any Critical findings exist"

## Consistency

- Use the same term for the same concept throughout: "tracking folder" not "tracking directory" and "tracking folder" in the same document
- HVE severity always capitalized: Critical, Major, Minor
- Confidence markers always in brackets: `[HIGH]`, `[MEDIUM]`, `[LOW]`
- File paths always in backticks: `.claude-hve-tracking/research/`
