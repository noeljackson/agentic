# Development Workflow

Standard phases for all changes. Match ceremony to risk.

---

## The Phases

```
UNDERSTAND → DESIGN → IMPLEMENT → VERIFY → RELEASE → MONITOR
```

Every change goes through these phases. The depth of each phase scales with risk.

---

## Phase 1: Understand

**Goal:** Know what you're fixing and why.

- [ ] Reproduce the issue or understand the request
- [ ] Identify root cause (not just symptoms)
- [ ] Check what's affected (files, features, users)
- [ ] Review `_FRAGILE.md` for danger zones

**Questions to answer:**
- What's the actual problem?
- Why is it happening?
- What will success look like?

---

## Phase 2: Design

**Goal:** Plan before coding.

**For small changes (1-3 files):**
- Mental model is sufficient
- Describe approach in one sentence

**For medium changes (3-10 files):**
- Write a brief proposal
- List files to modify
- Identify dependencies

**For large changes (10+ files):**
- Create a plan document
- Use `/feature-dev` for full ceremony
- Get founder approval before starting

**Output:** Clear understanding of what will change and why.

---

## Phase 3: Implement

**Goal:** Make the smallest change that solves the problem.

**Principles:**
- Minimal diffs — don't refactor "while you're here"
- One concern per commit
- Type check as you go: `npx tsc --noEmit`
- Run tests incrementally

**Avoid:**
- Touching unrelated code
- Adding features not requested
- "Improving" code outside scope

---

## Phase 4: Verify

**Goal:** Confirm it works and doesn't break other things.

**Checklist:**
- [ ] Unit tests pass: `npm test`
- [ ] Type check passes: `npx tsc --noEmit`
- [ ] Lint passes: `npm run lint`
- [ ] Manual test of changed behavior
- [ ] Check for regressions in related areas

**For high-risk changes:**
- [ ] RLS tests pass (if database changes)
- [ ] Security review (if auth/permissions)
- [ ] Preview deployment before production

---

## Phase 5: Release

**Goal:** Ship safely.

### OTA Updates (JS-only changes)
```bash
# Preview first
npx eas-cli update --channel preview --message "description"

# Then production
npx eas-cli update --channel production --message "description"
```

### Native Builds (native code changes)
```bash
# Build
npx eas-cli build --profile production --platform all

# Submit
npx eas-cli submit --platform ios --latest
```

### Database Migrations
```bash
# Push migration
npx supabase db push

# Verify
npx supabase db diff
```

---

## Phase 6: Monitor

**Goal:** Confirm it worked in production.

- [ ] Check error rates (Sentry, logs)
- [ ] Verify user-facing behavior
- [ ] Watch for 24 hours post-deploy
- [ ] Update `_SESSION_MEMO.md` with deployment status

---

## Ceremony Levels

Match depth to risk:

### Low Risk (typo, copy change, config tweak)
```
Understand (30 sec) → Implement → Verify (lint) → Release
```

### Medium Risk (bug fix, small feature)
```
Understand → Design (brief) → Implement → Verify (tests) → Release → Monitor
```

### High Risk (auth, payments, schema changes)
```
Understand → Design (detailed) → Review → Implement → Verify (full) → Preview → Release → Monitor
```

---

## Decision Points

### When to pause and ask:
- Scope unclear after 10 minutes of investigation
- Multiple valid approaches, unclear which is preferred
- Change touches `_FRAGILE.md` danger zone
- Estimated effort exceeds expectation

### When to proceed:
- Clear requirements
- Single obvious approach
- Low-risk area
- Covered by tests

---

## Commit Messages

Format:
```
type(scope): description

[optional body explaining why]
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

Examples:
```
fix(auth): handle expired tokens gracefully

Previously expired tokens caused a crash. Now we redirect to login.
```

```
feat(profile): add avatar upload
```

---

*Follow this workflow. Adjust ceremony to risk.*
