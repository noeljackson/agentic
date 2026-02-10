# Development Standards

> Every line was earned. Read `docs/lessons/` for why these rules exist.

## Before Any Change

- Run lint and tests first — never break them
- Check _FRAGILE.md for danger zones
- Auth/payments/RLS: extra review required
- Don't refactor code you weren't asked to touch
- Don't add features beyond what's asked

---

## Documentation > Generated Context

Your defaults are anti-patterns at scale. Documentation overrides them.

- Read CLAUDE.md before producing anything
- The docs are more trustworthy than whatever you're about to generate
- When wrong, stop — don't defend with eloquence
- See `docs/lessons/EVERY_LINE_EARNED.md` for why

---

## React Hooks

- useCallback/useEffect deps must include all context values used inside (org, tenant, user IDs)
- Wrap async load functions in useCallback before using in useEffect deps
- Use useMemo for logical expressions used in deps: `useMemo(() => data?.items ?? [], [data?.items])`
- Never ignore exhaustive-deps warnings — fix them or restructure the code

---

## Code Organization

- Files should not exceed 300 lines — split into focused modules early
- Data layer (DB clients, API clients) only in lib/ — components and hooks use lib/ abstractions
- All imports must come before any code — no inline imports after statements
- Remove unused variables immediately — don't leave them for later cleanup
- For data-heavy projects: use single source of truth pattern (DB → /lib/models → hooks → components)

---

## Async Patterns

- `.then()` chains need `.catch()`
- Long/streaming fetches need AbortController
- Multiple state updates: use Promise.all for atomic updates

---

## Type Safety

- `as any` is a last resort — if you cast the same thing repeatedly, create a typed wrapper
- Acceptable casts: test mocks, platform-specific code with documented @ts-ignore
- Query results: use typed helpers in lib/, not inline casts in components

---

## Context-Based IDs

- Org/tenant ID constants only in: scripts/, provider fallbacks, seed data
- App runtime code must get org ID from context (useOrganization, currentOrg.id)
- Never hardcode org IDs in components, hooks, or lib/ business logic

---

## Red Flags

- `as any` on anything except test mocks
- `.then()` without `.catch()`
- Optimistic updates without rollback
- Query invalidation keys that don't match
- useEffect async without cleanup
- useCallback/useEffect missing context values in deps (org, tenant, user IDs)
- Direct DB/API client imports outside lib/
- Files approaching 300 lines without a plan to split
- Unused variables or imports
- Hardcoded org/tenant IDs in app runtime code

---

## LLM Decision Making

- Never factor "tedious" or "repetitive" into recommendations — mechanical work is instant for an LLM
- Prefer technically cleaner solutions over "easier" ones — the effort delta doesn't exist
- Don't estimate human time ("this will take 2-3 days") — focus on dependencies and risk
- When choosing between "do it right now" vs "do it later", bias toward now if it's cleaner
- Codemod-style migrations (find/replace patterns across files) are trivial — never defer them for effort reasons

---

## Claude Code Tool Selection

- For open-ended exploration ("where does X happen?"): use Task(Explore), not direct Glob/Grep
- For complex features: use EnterPlanMode to get user sign-off before implementing
- For background work: Task with `run_in_background: true` for long-running operations
- For quick searches with known patterns: direct Glob/Grep is faster than spawning agents

---

## Delegation Patterns

**When to use each subagent:**

| Subagent | Use When | Model | Tools |
|----------|----------|-------|-------|
| `Explore` | "Where does X happen?" | Haiku (fast/cheap) | Read-only |
| `Plan` | Architecture decisions before coding | Inherits | Read-only |
| `general-purpose` | Multi-step research + implementation | Inherits | Full access |

**Parallel vs sequential:**
- Independent research: spawn multiple Explore agents in parallel
- Dependent work: chain sequentially (explore → plan → implement)
- Long builds/tests: use `run_in_background: true`, continue in main conversation

**Agent resumption:**
- Agents return IDs that can be resumed with full context
- Use `resume: "agent-id"` for multi-turn exploration
- Don't restart agents unnecessarily — resume preserves context

**Cost optimization:**
- Route read-only tasks to Haiku via `model: "haiku"`
- Use Explore (not general-purpose) for codebase scanning

---

## Two-Phase Workflow

For non-trivial features, use plan mode:

1. **EnterPlanMode** — signals intent to plan (requires user consent)
2. **Explore codebase** — read-only tools only (Glob, Grep, Read)
3. **Design approach** — document in conversation or plan file
4. **ExitPlanMode** — present plan for user approval
5. **Implement** — full tool access after approval

**When to use:**
- New features (not bug fixes)
- Multiple valid approaches exist
- Multi-file changes
- Architectural decisions

**Skip plan mode for:**
- Single-line fixes
- Obvious corrections
- User gave explicit detailed instructions

---

## Git Commits

- NEVER add co-author lines (Co-Authored-By) to commits
- NEVER add co-author trailers of any kind

---

## Session Hygiene

- Start sessions by reading `_NEXT_SESSION_MEMO.md` (if exists)
- End sessions with `/wrap` — updates docs, commits, writes next session memo
- Use `/sup` for quick status checks mid-session
- Check `/fragile` before touching documented danger zones
- Use `/lessons` to surface relevant learned patterns
- Read `docs/lessons/` for context on engineering expectations — every lesson was earned

---

## Stack-Specific Standards

For project-specific patterns, see templates:

- **Tamagui monorepo:** `templates/CLAUDE-tamagui-monorepo.md`
- **Supabase patterns:** `templates/project-types/supabase/`
- **Data modeling:** `templates/project-types/data-modeling/`

Copy relevant templates to your project and customize.
