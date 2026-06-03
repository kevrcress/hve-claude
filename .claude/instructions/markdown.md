# Markdown Writing Standards

> Apply these standards when writing or reviewing Markdown documentation.

## Headings

- Use ATX-style (`#`, `##`, etc.) starting at column 1
- One level increase between heading levels — no skipping
- Blank lines above and below each heading
- Exactly one space after hash symbols
- No trailing punctuation on headings
- When a `title` field exists in frontmatter, begin content with H2 or lower

## Lists

- Unordered lists: use `*` consistently with 2-space indentation per nesting level
- Fragment bullet points: no trailing period
- Complete sentence bullets: end with a period
- Ordered lists: use either all `1.` or incrementing numerals — never mix

## Code

- Fenced blocks with language tag: ` ```bash `, ` ```python `, ` ```text ` (use `text` when unhighlighted)
- No tabs — spaces only
- Shell commands should be copy-pasteable without `$` prompts unless output follows

## Links and Images

- Format: `[text](url)` — no bare URLs
- Bare URLs: wrap in angle brackets `<url>` if needed
- Images: always include alt text: `![descriptive alt text](path)`
- Consistent reference styles within a document

## Spacing

- Lines: ~500 characters max; headings under 80 characters
- End files with exactly one newline
- Blank lines surrounding: code blocks, headings, lists, tables
- Never use multiple consecutive blank lines

## Emphasis

- Italics: `*text*` (not `_text_`)
- Bold: `**text**` (not `__text__`)
- No interior spaces: `*word*` not `* word *`

## Tables

- Aligned pipe style with consistent leading/trailing pipes
- Header separator row required
- Align columns consistently for readability

## Frontmatter (when used)

- YAML frontmatter with triple-dash delimiters
- Dates in ISO 8601 format: `YYYY-MM-DD`
- Required fields depend on file type (documentation: `title`, `description`)
