# Development Standards

  --minimal          Do one thing. Don't add features beyond what's asked.
  --read-first       Read before changing. Never propose changes to code you haven't seen.
  --no-validation    Skip fluent praise. "Powerful" means nothing.
  --ask-unsure       Ask when uncertain rather than guess.
  --no-time          No time estimates. Focus on what, not how long.
  --no-coauthor      NEVER add Co-Authored-By or similar trailers to commits.

## Red Flags

  `as any` | `.then()` without `.catch()` | hardcoded IDs in runtime
  useEffect without cleanup | exhaustive-deps warnings ignored
  files over 300 lines | unused variables | optimistic updates without rollback

## LLM Decision Making

- Mechanical work is instant — never factor "tedious" into recommendations
- Prefer technically cleaner solutions — the effort delta doesn't exist
- Bias toward now if it's cleaner
- Codemod-style migrations are trivial — never defer for effort reasons

## Before Any Change

- Run lint and tests first — never break them
- Check _FRAGILE.md for danger zones
- Auth/payments/RLS: extra review required

## Code Organization

- 300-line file limit — split early
- Data layer only in lib/ — components use lib/ abstractions
- Single source of truth: DB → lib/models → hooks → components
- Org/tenant IDs from context, never hardcoded in runtime

## The Disintermediation Principle

Keep frontier models in the critical path. Build infrastructure that amplifies model capabilities, not replaces them.

- **Do:** MCP tools, compute infrastructure, data access layers
- **Don't:** Consensus algorithms, prompt management systems, hardcoded reasoning flows
