# Feature Specification Format

How to write specs that enable parallel work.

---

## Purpose

A good feature spec:
1. Defines what "done" looks like
2. Enables agents to work in parallel
3. Shows dependencies clearly
4. Reduces back-and-forth questions

---

## Template

```markdown
# Feature: [Name]

## Objective

[One sentence: what does this feature do for users?]

## Success Criteria

- [ ] [User-visible outcome 1]
- [ ] [User-visible outcome 2]
- [ ] [User-visible outcome 3]

## Scope

### In Scope
- [What's included]

### Out of Scope
- [What's explicitly not included]

## Technical Approach

[High-level approach. Architecture decisions already made.]

## Task Breakdown

### Backend Tasks

| ID | Task | Depends On | Output |
|----|------|------------|--------|
| B1 | Create database schema | — | `migrations/xxx.sql` |
| B2 | Add RLS policies | B1 | RLS policies |
| B3 | Implement API endpoint | B1 | `POST /api/resource` |
| B4 | Add types | B3 | `lib/types.ts` |

### Frontend Tasks

| ID | Task | Depends On | Output |
|----|------|------------|--------|
| F1 | Create list view | B4 | `app/resource/index.tsx` |
| F2 | Create detail view | B4 | `app/resource/[id].tsx` |
| F3 | Add form component | B3, B4 | `components/ResourceForm.tsx` |
| F4 | Connect mutations | B3 | Hooks in `hooks/useResource.ts` |

### QA Tasks

| ID | Task | Depends On | Output |
|----|------|------------|--------|
| Q1 | Unit tests for API | B3 | `__tests__/api/resource.test.ts` |
| Q2 | RLS tests | B2 | `__tests__/rls/resource.test.ts` |
| Q3 | E2E flow test | F1-F4 | `e2e/resource.spec.ts` |

## Decisions Made

| Decision | Options Considered | Choice | Rationale |
|----------|-------------------|--------|-----------|
| [Topic] | [A, B, C] | [Choice] | [Why] |

## Decisions Deferred

- [Topic] — decide during [phase]

## Checkpoints

| After Phase | Review |
|-------------|--------|
| Spec | Founder approves scope |
| Backend | Auto-proceed (types ready) |
| Frontend | Auto-proceed (UI complete) |
| QA | Review coverage |
| Ship | Founder approves release |
```

---

## Task ID Convention

Use short, scannable IDs:

| Prefix | Role | Example |
|--------|------|---------|
| B | Backend | B1, B2, B3 |
| F | Frontend | F1, F2, F3 |
| P | Platform | P1, P2 |
| Q | QA | Q1, Q2 |
| S | Security | S1, S2 |
| D | Design | D1, D2 |

**In _AGENTS.md**, reference by ID:
```markdown
| Task | Status | Blocked By |
|------|--------|------------|
| F3: Form component | Blocked | B3, B4 |
```

---

## Dependency Notation

### Direct dependency
```
F1 depends on B4
```
F1 cannot start until B4 is complete.

### Parallel work
```
B1, B2 have no dependencies
F1, F2 both depend only on B4
```
B1 and B2 can run in parallel. F1 and F2 can run in parallel once B4 is done.

### Visualization
```
B1 ──┐
     ├──→ B4 ──→ F1
B2 ──┤           ↓
     └──→ B3 ──→ F3
              ↓
             Q1
```

---

## Tracking in _AGENTS.md

When executing a feature spec:

```markdown
## Active Work

| Task | Status | Owner | Blocked By | Output | Updated |
|------|--------|-------|------------|--------|---------|
| B1: Schema | ✅ Complete | Backend | — | migration applied | Jan 8 |
| B3: API endpoint | 🔵 In Progress | Backend | — | — | Jan 8 |
| F1: List view | ⏸️ Blocked | Frontend | B4 | — | Jan 8 |
```

---

## Spec Evolution

Specs are living documents:

1. **Draft** — Initial proposal, gaps allowed
2. **Approved** — Founder approved scope and approach
3. **In Progress** — Tasks being executed
4. **Complete** — All tasks done, feature shipped
5. **Archived** — Moved to `docs/plans/completed/`

---

## Example: User Profiles Feature

```markdown
# Feature: User Profiles

## Objective

Users can view and edit their profile information.

## Success Criteria

- [ ] Users can see their profile page
- [ ] Users can edit name, email, and avatar
- [ ] Changes persist across sessions
- [ ] Other users can view public profiles

## Task Breakdown

### Backend Tasks

| ID | Task | Depends On | Output |
|----|------|------------|--------|
| B1 | Add profile fields migration | — | `migrations/add_profile_fields.sql` |
| B2 | RLS: own profile editable | B1 | RLS policy |
| B3 | RLS: public profiles readable | B1 | RLS policy |
| B4 | GET /api/profiles/:id | B1 | Endpoint |
| B5 | PATCH /api/profiles/:id | B1, B2 | Endpoint |
| B6 | Export Profile type | B4 | `lib/types.ts` |

### Frontend Tasks

| ID | Task | Depends On | Output |
|----|------|------------|--------|
| F1 | Profile view screen | B6 | `app/profile/[id].tsx` |
| F2 | Profile edit form | B5, B6 | `components/ProfileForm.tsx` |
| F3 | Avatar upload | B5 | `components/AvatarUpload.tsx` |
| F4 | useProfile hook | B4, B5 | `hooks/useProfile.ts` |

### QA Tasks

| ID | Task | Depends On | Output |
|----|------|------------|--------|
| Q1 | RLS tests | B2, B3 | `__tests__/rls/profiles.test.ts` |
| Q2 | API tests | B4, B5 | `__tests__/api/profiles.test.ts` |
| Q3 | E2E edit flow | F1-F4 | `e2e/profile-edit.spec.ts` |

## Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Avatar storage | Supabase Storage | Already using it |
| Public by default | No | Privacy first |
```

---

## Anti-Patterns

### Vague tasks
❌ "Build the profile feature"
✅ "B4: GET /api/profiles/:id endpoint"

### Missing dependencies
❌ "F1: Profile screen" (what does it need?)
✅ "F1: Profile screen | Depends on: B6"

### No output specified
❌ "B1: Database changes"
✅ "B1: Add profile fields | Output: `migrations/xxx.sql`"

### Scope creep in spec
❌ "Also add notifications and social features"
✅ "Out of scope: notifications, social (future feature)"

---

*Good specs enable parallel work. Bad specs create blocking.*
