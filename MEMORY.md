# Engineering Principles

*For Claude Code `/memory`*

---

## Before Any Change

- Run lint and existing tests first — never break them
- Check _FRAGILE.md for documented danger zones
- Auth/payments/security: extra review required
- Don't refactor code you weren't asked to touch
- Don't add features beyond what's asked

---

## Code Quality Hierarchy

Priority order when making tradeoffs:
1. **Clarity**: Purpose obvious to readers, not just authors
2. **Simplicity**: Simplest approach that works
3. **Concision**: High signal-to-noise
4. **Maintainability**: Easy to modify later
5. **Consistency**: Match surrounding code style

---

## Least Mechanism

- Core language constructs first
- Standard library second
- External dependencies last
- No abstractions for one-time operations
- No error handling for impossible scenarios

---

## Error Handling

- Return errors, don't throw (except programmer bugs)
- Add context when wrapping errors
- Check return values always
- Fail fast in setup, recover gracefully in runtime
- Validate at system boundaries only (user input, external APIs)
- Check `error.code` before logging — distinguish expected vs unexpected
- Log with context prefix like `[module-name]`

---

## Global State

- Avoid mutable global state
- Pass dependencies explicitly
- No secrets in code — use environment variables
- Makes testing possible, prevents action-at-a-distance bugs

---

## Async Patterns

- Context switches (org, user, kid mode) must invalidate in-flight queries
- Parallel fetches need coordination — handle unmounted component state
- Long operations need loading states that survive re-renders
- Check for race conditions in async code
- Don't hold transactions open across async boundaries

---

## PostgreSQL & Supabase

**RLS (Row Level Security)**
- RLS policies must never query other RLS-protected tables directly
- Use SECURITY DEFINER helpers for cross-table access
- Test as multiple user types (owner, member, visitor, unauthenticated)
- New RLS policies require corresponding test coverage

**Queries**
- Parameterized queries only — never string interpolation
- Use prepared statements for repeated queries
- EXPLAIN ANALYZE before optimizing
- Prefer specific columns over SELECT *
- Supabase nested selects (`select('*, relation(*)')`) return different shapes — validate before accessing

**Transactions**
- Keep transactions short
- Use appropriate isolation level (READ COMMITTED default, SERIALIZABLE for consistency-critical)
- Handle serialization failures with retry logic

**Schema**
- Use enums for fixed value sets
- JSONB for flexible data, but index paths you query
- Timestamps: always `timestamptz`, never `timestamp`
- UUIDs for public-facing IDs, bigserial for internal FKs
- Soft deletes (`deleted_at`) for audit trails
- Profile ID ≠ Auth User ID — pre-staged profiles have null auth_user_id

**Migrations**
- One logical change per migration
- Backward-compatible first (add column, deploy, backfill, then make NOT NULL)
- Never drop columns in same deploy as code removal
- Test rollback path

---

## Query Management (TanStack Query)

- Use query key factories, not string literals — `queryKeys.user.profile(id)` not `['user-profile', id]`
- Invalidate specific keys, not broad prefixes — over-invalidation causes unnecessary refetches
- Set explicit staleTime for data that shouldn't refetch on every render
- Invalidate related queries on org/context switches to prevent stale data

---

## Environment & Platform

- Never use `process.env.EXPO_PUBLIC_*` directly in runtime code — import from centralized config
- Expo web builds replace env vars at compile time, not runtime — use Constants.expoConfig.extra fallback
- iOS SecureStore has 2048 byte limit — tokens must be chunked
- Modal + WebView doesn't composite on mobile — use absolute positioning for video overlays

---

## Testing

- Tests are code — same quality standards apply
- Table-driven tests for repetitive scenarios
- Test helpers for setup, not assertions
- Useful failure messages that explain what failed
- Test one behavior per test
- Payment flows need integration tests — deduplication logic is fragile
- Webhook handlers need tests for signature verification and idempotency

---

## Function Guidelines

- Prefer small, focused functions
- ~40 lines triggers review; >100 lines needs justification
- Keep files under 800 lines — split when approaching limit
- Deep nesting (>3-4 levels) signals need for extraction
- Comments explain WHY, not WHAT
- Don't add comments to code you didn't write

---

## Type Safety

- Use type system to prevent errors
- Explicit types for public APIs
- Type inference for local/obvious cases
- Avoid type assertions; prefer runtime checks
- `unknown` over `any` when type truly unknown
- Never use `as any` on Supabase query results — use type guards or explicit interfaces

---

## TypeScript

- `const`/`let` only, never `var`
- Named exports, not default exports
- Interfaces over type aliases for object shapes
- `===` always, except `== null` for null/undefined check
- Arrow functions for callbacks
- Avoid decorators (experimental, diverged from TC39)
- Avoid enums; prefer union types or const objects
- Nullish coalescing (`??`) over logical OR for defaults
- Optional chaining (`?.`) over manual null checks

---

## Shell Scripts

- Bash only for <100 lines and straightforward control flow
- Use ShellCheck for all scripts
- Prefer `[[ ]]` over `[ ]` and `test`
- Quote variables unless careful unquoted expansion required
- Use arrays for lists, not strings
- Avoid `eval` entirely

---

## Red Flags

Stop and reconsider if you see:
- Global mutable state
- Unhandled errors or swallowed exceptions
- Type assertions without runtime checks
- `as any` on Supabase results
- Clever code without comments
- Long functions (>100 lines) without clear structure
- Deep nesting (>4 levels)
- Unquoted shell variables
- String-interpolated SQL
- `timestamp` without timezone
- Transactions held across await
- `process.env.EXPO_PUBLIC_*` in runtime code
- Over-broad query invalidation
- RLS policies querying other RLS-protected tables

---

## When Complexity Is Justified

- Performance measured and documented
- Multiple disparate clients require it
- Simpler approach attempted first
- Tests demonstrate correct usage
- Rationale documented for future readers
