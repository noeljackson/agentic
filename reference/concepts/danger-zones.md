# Danger Zones

Why some code needs extra care, and how to work with it safely.

---

## The Problem

Not all code is equal. Some areas:
- Touch multiple services
- Handle money or security
- Have complex state machines
- Lack test coverage
- Have bitten you before

Agents (and humans) often don't know which areas are dangerous until something breaks.

---

## The Solution: _FRAGILE.md

Every project should have a `docs/_FRAGILE.md` file that maps:
1. **Where** the danger zones are
2. **Why** they're dangerous
3. **What** to check before changing them

This prevents "while I'm here" improvements in the wrong places.

---

## Anatomy of a Danger Zone

### Risk Factors

| Factor | Why It's Risky |
|--------|----------------|
| **Multi-service** | Changes ripple across systems |
| **State machine** | Edge cases multiply |
| **Security-critical** | Bugs can be exploited |
| **Money-handling** | Errors are costly |
| **Low test coverage** | No safety net |
| **Historical issues** | It's broken before |

### The Risk Heatmap

Track risk factors per area:

```markdown
| Area | Complexity | Multi-Service | State Machine | Test Coverage | Risk |
|------|------------|---------------|---------------|---------------|------|
| Auth | High | Yes | Yes | Medium | 🔴 |
| Payments | High | Yes | No | Low | 🔴 |
| Onboarding | Medium | No | Yes | Low | 🟡 |
| Settings | Low | No | No | High | 🟢 |
```

More risk factors = more caution needed.

---

## Working in Danger Zones

### Before Touching Dangerous Code

1. **Read _FRAGILE.md** — Understand why it's marked dangerous
2. **Read existing tests** — Know what's covered
3. **Trace dependencies** — What else will this affect?
4. **Check history** — Has this broken before? How?

### While Working

1. **Minimal changes** — Don't refactor, don't "improve"
2. **One thing at a time** — Smaller diffs are easier to debug
3. **Test as you go** — Don't save testing for the end
4. **Document edge cases** — Future you will thank you

### After Changes

1. **Run all related tests** — Not just the ones you think matter
2. **Manual verification** — Automated tests miss things
3. **Preview deployment** — Test in staging first
4. **Monitor post-deploy** — Watch error rates

---

## The Dependency Graph

Danger zones often form a cascade:

```
Authentication
    ↓
Organization/Tenant Context
    ↓
User Permissions
    ↓
Feature Data
    ↓
External Services
```

Changes to upstream components affect everything downstream.

**Implication:** Auth bugs are worse than Settings bugs. Treat accordingly.

---

## Documenting Gotchas

Gotchas are non-obvious behaviors that cause repeated mistakes:

### Good Gotcha Documentation

```markdown
### SecureStore Chunking (iOS)

SecureStore has a 2048 byte limit. JWT tokens exceed this,
so `lib/auth.ts` splits values into `key_chunk_0`, `key_chunk_1`, etc.

**Files:** `lib/auth.ts:45-78`

**If you break this:** Users get logged out randomly on iOS.

**Don't:** Store tokens differently without updating the chunking logic.
```

### What Makes a Good Gotcha Entry

- **Specific** — Not "be careful with auth"
- **Explains why** — The underlying constraint
- **Shows consequences** — What breaks if ignored
- **Points to files** — Where to look

---

## When to Add to _FRAGILE.md

Add entries when:
- You fix a production incident
- You discover non-obvious behavior
- You add external service integrations
- Something takes much longer than expected
- You think "someone else will hit this too"

---

## Agent Behavior in Danger Zones

### Read _FRAGILE.md First

Before making changes, agents should:
```markdown
## Before I Start

Reading _FRAGILE.md...

This touches [Auth Flow], which is marked 🔴 High Risk because:
- Multi-service (Supabase + OAuth provider)
- State machine (login → verify → session → refresh)
- Historical: Token refresh bug in v1.2

I'll proceed carefully with minimal changes.
```

### Escalate When Uncertain

If a change touches a danger zone and the agent isn't confident:
```markdown
### Escalation: Backend Engineer

**Area:** Auth Flow (🔴 High Risk)

**Proposed Change:** Update token refresh logic

**Why I'm escalating:**
- Historical issues in this area
- Change affects session state machine
- Want founder review before proceeding

**My recommendation:** [approach]
```

---

## Danger Zone Maintenance

### Regular Review

During architecture reviews:
- Is the risk assessment still accurate?
- Are there new danger zones?
- Has test coverage improved?
- Can any areas be de-risked?

### Post-Incident Updates

After every production issue:
1. Add the area to _FRAGILE.md if not already there
2. Document what happened and why
3. Note the fix and prevention measures

---

## Example: Full Danger Zone Entry

```markdown
### Payment Processing

**Risk Level:** 🔴 High

**Why it's fragile:**
- Multiple providers (Stripe Connect, RevenueCat)
- Money involved — errors are costly
- Webhook ordering matters for consistency
- Deduplication logic between providers is complex

**Historical issues:**
- v1.3: Duplicate charges from webhook retry (fixed with idempotency keys)
- v1.5: RevenueCat webhook race condition (fixed with transaction locks)

**Before changing:**
- [ ] Test in Stripe test mode first
- [ ] Verify idempotency keys work correctly
- [ ] Check webhook retry behavior
- [ ] Review with Platform Engineer
- [ ] Test both success and failure paths

**Files involved:**
- `supabase/functions/stripe-webhook/` — Stripe event handling
- `supabase/functions/revcat-webhook/` — RevenueCat events
- `lib/purchases.ts` — Client-side purchase logic
- `lib/subscriptions.ts` — Subscription state management

**RLS considerations:**
- Users can only see their own purchases
- Admin can see all purchases for refund processing
```

---

## Summary

| Concept | Purpose |
|---------|---------|
| **_FRAGILE.md** | Map danger zones before someone gets hurt |
| **Risk Heatmap** | Quick visual assessment of risk factors |
| **Gotchas** | Document non-obvious behaviors |
| **Dependency Graph** | Understand blast radius of changes |

The goal: **Know where the landmines are before you step on them.**
