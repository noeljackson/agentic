# Feature Lifecycle

How a feature goes from idea to shipped using Agentic agents.

---

## Overview

A feature typically flows through these stages:

```
Idea → Spec → Design → Build → Test → Ship
```

Different agents engage at different stages. The human orchestrates transitions.

---

## Stage 1: Idea

**Owner:** Human (you)

Features start with you:
- User feedback suggests a need
- You see an opportunity
- Strategy requires a capability

**Output:** A rough idea to explore

**Next:** Activate Product Manager

---

## Stage 2: Specification

**Owner:** Product Manager

```
You are ~/projects/agentic/docs/roles/product-manager.md

I want to add [feature idea]. Help me:
1. Define the user problem clearly
2. Write user stories
3. Define acceptance criteria
4. Identify scope (in/out)
```

**Product Manager does:**
- Asks clarifying questions
- Defines user stories
- Creates acceptance criteria
- Flags trade-offs for your decision
- Updates `_ROADMAP.md`

**Your job:**
- Answer questions
- Make scope decisions
- Approve the spec

**Output:** Clear spec with user stories and acceptance criteria

**Next:** Activate UX Designer (if UI) or Backend Engineer (if backend-first)

---

## Stage 3: Design

**Owner:** UX Designer → UI Designer (if UI-heavy)

### UX Design

```
You are ~/projects/agentic/docs/roles/ux-designer.md

Read the spec for [feature] in docs/_ROADMAP.md. Create:
1. User flow for the feature
2. Wireframes for key screens
3. Edge cases and error states
```

**UX Designer does:**
- Maps user journey
- Creates wireframes
- Identifies edge cases
- Flags UX decisions for you

### UI Design (if needed)

```
You are ~/projects/agentic/docs/roles/ui-designer.md

Review the wireframes for [feature]. Create:
1. Visual design following our design system
2. Component specs for new components
3. Responsive considerations
```

**UI Designer does:**
- Creates visual designs
- Extends design system if needed
- Documents component specs

**Your job:**
- Review designs
- Approve UX/UI direction
- Decide on trade-offs

**Output:** Approved designs with specs

**Next:** Activate Backend Engineer (for API) and/or Frontend Engineer (for UI)

---

## Stage 4: Build

**Owner:** Frontend Engineer + Backend Engineer

Often these work in parallel:

### Backend First (or Parallel)

```
You are ~/projects/agentic/docs/roles/backend-engineer.md

Implement the backend for [feature]:
1. Design data model (update _SCHEMA.md)
2. Create API endpoints
3. Write tests
4. Update cross-agent notes with API contract
```

**Backend Engineer does:**
- Designs/updates schema
- Implements API
- Writes tests
- Documents API for Frontend

### Frontend

```
You are ~/projects/agentic/docs/roles/frontend-engineer.md

Implement the UI for [feature]:
1. Build screens per design specs
2. Connect to API (see cross-agent notes)
3. Handle loading/error states
4. Write component tests
```

**Frontend Engineer does:**
- Builds UI components
- Integrates with API
- Handles edge cases
- Writes tests

### Coordination

**Cross-Agent Notes Example:**
```markdown
### From Backend Engineer (Jan 15)

API for [feature] is ready:

**Endpoints:**
- POST /api/things - Create thing
- GET /api/things/:id - Get thing

**For Frontend Engineer:**
- Types in `lib/types.ts`
- Auth required
- See example payloads in tests
```

**Your job:**
- Review progress
- Unblock dependencies
- Make decisions when surfaced
- Review code if you want

**Output:** Working feature code with tests

**Next:** Activate QA Engineer

---

## Stage 5: Test

**Owner:** QA Engineer

```
You are ~/projects/agentic/docs/roles/qa-engineer.md

Test the [feature]:
1. Verify acceptance criteria
2. Test edge cases
3. Check error handling
4. Report any issues found
```

**QA Engineer does:**
- Tests against acceptance criteria
- Explores edge cases
- Documents bugs found
- Verifies fixes

**Bug Reports go to:**
- Frontend Engineer (UI issues)
- Backend Engineer (API issues)

**Your job:**
- Review testing status
- Decide on ship-blocking vs defer
- Approve for release

**Output:** Verified feature, known issues documented

**Next:** Ship it

---

## Stage 6: Ship

**Owner:** Human (you) + Platform Engineer

### Pre-Ship Checklist

Activate QA for final check:
```
You are ~/projects/agentic/docs/roles/qa-engineer.md

Pre-ship checklist for [feature]:
1. All acceptance criteria met?
2. Tests passing?
3. No critical bugs open?
4. Documentation updated?
```

### Deploy (if needed)

```
You are ~/projects/agentic/docs/roles/platform-engineer.md

Deploy [feature]:
1. Verify staging environment
2. Run deployment
3. Verify production
4. Monitor for issues
```

### Post-Ship

- Update `_ROADMAP.md` — Mark complete
- Update `_AGENTS.md` — Capture in recently completed
- Celebrate 🎉

---

## The Complete Flow

```
┌─────────────┐
│    HUMAN    │ ← Has idea
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   PRODUCT   │ ← Spec
│   MANAGER   │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│     UX      │────▶│     UI      │ ← Design
│  DESIGNER   │     │  DESIGNER   │
└──────┬──────┘     └──────┬──────┘
       │                   │
       └─────────┬─────────┘
                 │
       ┌─────────┴─────────┐
       ▼                   ▼
┌─────────────┐     ┌─────────────┐
│   BACKEND   │◄───▶│  FRONTEND   │ ← Build
│  ENGINEER   │     │  ENGINEER   │
└──────┬──────┘     └──────┬──────┘
       │                   │
       └─────────┬─────────┘
                 │
                 ▼
          ┌─────────────┐
          │     QA      │ ← Test
          │  ENGINEER   │
          └──────┬──────┘
                 │
                 ▼
          ┌─────────────┐
          │   PLATFORM  │ ← Ship
          │  ENGINEER   │
          └──────┬──────┘
                 │
                 ▼
          ┌─────────────┐
          │    HUMAN    │ ← Approve & Celebrate
          └─────────────┘
```

---

## Shortcuts

Not every feature needs every stage:

### Small Bug Fix
```
Human → Backend or Frontend Engineer → QA → Ship
```

### Backend-Only Feature
```
Human → Product Manager → Backend Engineer → QA → Ship
```

### Design Refresh
```
Human → UI Designer → Frontend Engineer → QA → Ship
```

### Quick Experiment
```
Human → Growth Engineer → Ship (with feature flag)
```

---

## Tips

### Keep Specs Light
Not everything needs a full spec. Match rigor to risk.

### Parallelize When Possible
Backend and Frontend can often work simultaneously once API is defined.

### Don't Skip QA
Even small changes benefit from verification.

### Document as You Go
Update _AGENTS.md throughout, not just at the end.

### Ship Incrementally
Smaller features, shipped faster, are better than big bangs.

---

## Related Guides

- [New Project](../new-project.md) — Starting from scratch
- [Existing Project](../existing-project.md) — Adopting for existing code
- [Decisions](../../specs/decisions.md) — When to escalate

---

> **Remember:** This is a framework, not a rigid process. Adapt to what your feature needs.
