# New Project Guide

How to start a new project from scratch using Agentic.

---

## Overview

Starting a new project involves:

1. Create project structure
2. Write your initial vision
3. Activate Product Manager to refine and plan
4. Build your roadmap
5. Start development with engineering agents

**Time to first agent:** ~10 minutes

---

## Step 1: Create Project Structure

```bash
# Create your project
mkdir my-project
cd my-project
git init

# Create docs directory
mkdir docs

# Copy templates from Agentic
cp ~/projects/agentic/templates/_VISION.md docs/
cp ~/projects/agentic/templates/_ROADMAP.md docs/
cp ~/projects/agentic/templates/_AGENTS.md docs/
cp ~/projects/agentic/templates/_ARCHITECTURE.md docs/
cp ~/projects/agentic/templates/_CONVENTIONS.md docs/
```

You now have:
```
my-project/
└── docs/
    ├── _AGENTS.md
    ├── _ARCHITECTURE.md
    ├── _CONVENTIONS.md
    ├── _ROADMAP.md
    └── _VISION.md
```

---

## Step 2: Write Your Vision

Open `docs/_VISION.md` and fill it in. **This is your job as the human.**

You don't need to have everything figured out. Start with what you know:

```markdown
# Vision

## One-Liner
A mobile app that helps dog owners find and book dog walkers.

## Problem
Dog owners struggle to find reliable, available dog walkers on short notice.
They resort to asking neighbors or leaving dogs home alone.

## Target Users
| User Type | Description | Primary Need |
|-----------|-------------|--------------|
| Dog owners | Busy professionals with dogs | Reliable, on-demand dog walking |
| Dog walkers | People who want flexible income | Easy way to find clients |

## Success Looks Like
| Timeframe | Success Metric |
|-----------|----------------|
| 3 months | 100 active users in one city |
| 1 year | Expanding to 5 cities, profitable |

## Open Questions
1. Should we start B2C or partner with apartment buildings?
2. How do we handle trust/safety?
3. What's the minimum feature set to launch?
```

**Don't worry about:**
- Perfect prose
- Complete answers
- Technical details

Just get your thoughts down. The Product Manager will help refine.

---

## Step 3: Activate Product Manager

Now bring in your first agent:

```
You are ~/projects/agentic/docs/roles/product-manager.md

This is a new project. Read docs/_VISION.md and help me:
1. Ask clarifying questions about the vision
2. Identify gaps I haven't considered
3. Propose an initial MVP scope
4. Create a phased roadmap
```

### What the Product Manager Does:

1. **Asks clarifying questions**
   - Who exactly is the target user?
   - What's the core value proposition?
   - What are your constraints (time, money, resources)?

2. **Identifies gaps**
   - "You haven't addressed pricing — is this subscription or per-walk?"
   - "What about the walker verification process?"

3. **Proposes MVP scope**
   - What's IN: Core booking flow, basic profiles, payment
   - What's OUT: Reviews, recurring walks, multiple dogs

4. **Creates roadmap**
   - Phase 1: MVP (core booking)
   - Phase 2: Trust & Safety (reviews, verification)
   - Phase 3: Growth (multiple cities)

### Your Job:

- Answer the questions
- Make decisions on trade-offs
- Approve or adjust the scope
- Finalize the roadmap

After this conversation, you'll have:
- Refined `_VISION.md`
- Populated `_ROADMAP.md`
- Clear next steps

---

## Step 4: Continue with Architecture

If your project needs technical design, activate the Backend Engineer:

```
You are ~/projects/agentic/docs/roles/backend-engineer.md

Read docs/_VISION.md and docs/_ROADMAP.md. Help me:
1. Propose a tech stack for this project
2. Design the initial data model
3. Identify key architectural decisions
```

The Backend Engineer will:
- Recommend technologies based on your needs
- Design the database schema
- Populate `_ARCHITECTURE.md`
- Surface decisions you need to make

---

## Step 5: Start Development

Once you have vision, roadmap, and architecture, activate engineering agents:

**For UI-heavy work:**
```
You are ~/projects/agentic/docs/roles/frontend-engineer.md

Read docs/_AGENTS.md for your task queue. We're starting Phase 1.
```

**For backend work:**
```
You are ~/projects/agentic/docs/roles/backend-engineer.md

Read docs/_AGENTS.md for your task queue. Start with the database schema.
```

**For parallel work:**
Activate multiple agents in separate sessions, each working on their scope.

---

## Managing the Project

As work progresses:

### Update _AGENTS.md
Keep task queues and status current:
```markdown
## Frontend Engineer

### Current Status
| Field | Value |
|-------|-------|
| **Status** | Active |
| **Current Task** | Build booking flow UI |
| **Last Updated** | 2024-01-15 |

### Task Queue
1. [x] Set up project structure
2. [ ] Build booking flow UI
3. [ ] Add user profile screen
```

### Handle Handoffs
When agents need to coordinate:
```markdown
## Cross-Agent Notes

### From Backend Engineer (Jan 15)
API for booking is ready at `/api/bookings`.

**For Frontend Engineer:**
- POST /api/bookings creates a booking
- See types in `lib/types.ts`
- Auth token required in header
```

### Make Decisions
When agents surface decisions, decide and document:
```markdown
## Decisions Log

| Date | Decision | Rationale | Decided By |
|------|----------|-----------|------------|
| Jan 15 | Use Stripe for payments | Industry standard, good docs | Human |
```

---

## Tips for Success

### Start Small
Don't try to plan everything. Get to working software quickly.

### One Agent at a Time (Usually)
Sequential work is simpler. Parallelize when you're comfortable.

### You're Still the Builder
Agents help, but you should understand what's being built.

### Document Decisions
Future-you will thank present-you.

### Iterate
Your first vision will evolve. That's good.

---

## Common First-Project Flow

```
Day 1:
├── Create structure
├── Write vision
└── Product Manager → Refined vision, roadmap

Day 2-3:
├── Backend Engineer → Architecture, schema
└── Human reviews, decides

Day 4+:
├── Frontend + Backend → Build MVP
├── QA → Testing
└── Ship it 🚀
```

---

## Next Steps

After setup:
- [Feature Lifecycle](workflows/feature-lifecycle.md) — How features flow through agents
- Browse [Roles](../roles/) — Understand each agent's capabilities
- Read [Decisions](../specs/decisions.md) — When to decide vs delegate

---

> **Remember:** The goal is working software. Agents are here to help you build it faster and better.
