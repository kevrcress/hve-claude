# Task Challenge Reference

> Invoke adversarial questioning with `/hve-challenge [topic-slug]`.

## Purpose

The challenger reads tracking artifacts as an uninformed skeptic and asks penetrating open-ended questions to surface:
- Hidden assumptions embedded in the plan
- Scope gaps (requirements missing from the plan)
- Design risks (approaches that may not achieve the goal)
- Alternatives not considered

## Protocol

- One question per turn — never yes/no
- Questions are: What, Why, How, Help me understand...
- Produces a challenge document that logs all Q&A

## Options

- `--focus research` — challenge the research document
- `--focus plan` — challenge the implementation plan
- `--focus implementation` — challenge the changes log
- `--friction-log` — record process friction encountered during the challenge session

## Output

`.claude-hve-tracking/challenges/YYYY-MM-DD-TOPIC-challenge.md`

## When to use

- After planning, before implementation — surfaces plan weaknesses early
- After implementation, before review — surfaces unexamined assumptions
- When the team feels "too aligned" on an approach — introduces productive skepticism
