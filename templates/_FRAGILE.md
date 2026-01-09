# Fragile Areas

Areas of the codebase that require extra care. Read before making changes.

---

## Risk Heatmap

| Area | Complexity | Multi-Service | State Machine | Test Coverage | Risk Level |
|------|------------|---------------|---------------|---------------|------------|
| [Auth Flow] | High | Yes | Yes | Medium | 🔴 High |
| [Payments] | High | Yes | No | Low | 🔴 High |
| [Onboarding] | Medium | No | Yes | Low | 🟡 Medium |
| [Profile] | Low | No | No | High | 🟢 Low |

**Risk Levels:**
- 🔴 **High** — Changes here can break core functionality. Extra review required.
- 🟡 **Medium** — Proceed with caution. Test thoroughly.
- 🟢 **Low** — Standard development practices apply.

---

## Dependency Graph

```
[Authentication]
    ↓
[Organization/Tenant Context]
    ↓
[User Profile & Permissions]
    ↓
[Feature Data Layer]
    ↓
[External Services (Payments, APIs, etc.)]
```

Changes to upstream components affect everything downstream.

---

## Danger Zones

### [Area 1: e.g., Auth Flow]

**Why it's fragile:**
- [Touches multiple services]
- [State machine with many edge cases]
- [Security-critical]

**Historical issues:**
- [Past bug 1 and how it was fixed]
- [Past bug 2 and how it was fixed]

**Before changing:**
- [ ] Read relevant tests in `__tests__/[area]/`
- [ ] Understand all state transitions
- [ ] Check RLS policies if database is involved
- [ ] Get security review for auth changes

**Files involved:**
- `path/to/critical/file.ts` — [what it does]
- `path/to/another/file.ts` — [what it does]

---

### [Area 2: e.g., Payment Processing]

**Why it's fragile:**
- [Multiple payment providers]
- [Money involved — errors are costly]
- [Webhook ordering matters]

**Historical issues:**
- [Duplicate charges incident]
- [Webhook race condition]

**Before changing:**
- [ ] Test in sandbox environment first
- [ ] Verify idempotency keys work
- [ ] Check webhook retry behavior
- [ ] Review with Platform Engineer

**Files involved:**
- `path/to/payment/handler.ts`
- `supabase/functions/stripe-webhook/`

---

## Gotchas & Non-Obvious Things

### [Gotcha 1: e.g., Token Storage]

[Platform] has a [limitation]. [Component] works around this by [approach].

**Files:** `path/to/file.ts`

**If you break this:** [Consequence]

---

### [Gotcha 2: e.g., ID Confusion]

`[entity].id` is the primary identifier, not `[other_field]`. They differ when [condition].

**Always use:** `[preferred_field]`

---

### [Gotcha 3: e.g., Fallback Behavior]

When [condition], the system falls back to [behavior]. This is intentional for [reason].

**Don't "fix" this** unless you understand the migration path.

---

## Testing Requirements by Area

| Area | Unit Tests | Integration Tests | RLS Tests | Manual QA |
|------|------------|-------------------|-----------|-----------|
| Auth | Required | Required | Required | Required |
| Payments | Required | Required | N/A | Required |
| UI Components | Recommended | Optional | N/A | Recommended |
| API Endpoints | Required | Required | Required | Optional |

---

## When to Update This File

- After fixing a production incident
- When discovering a new non-obvious behavior
- When adding a new integration with external services
- During architecture reviews

---

*This file prevents repeated mistakes. Keep it current.*
