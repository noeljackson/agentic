# Existing Project Guide

How to adopt Agentic for a project that already has code.

---

## Overview

Adopting Agentic for an existing project involves:

1. Add documentation structure
2. Capture current state
3. Define conventions from existing patterns
4. Start using agents for new work

**Key difference from new projects:** You're documenting what exists, not designing from scratch.

---

## Step 1: Add Documentation Structure

```bash
cd your-existing-project

# Create docs directory (if it doesn't exist)
mkdir -p docs

# Copy templates
cp ~/projects/agentic/templates/_AGENTS.md docs/
cp ~/projects/agentic/templates/_VISION.md docs/
cp ~/projects/agentic/templates/_ROADMAP.md docs/
cp ~/projects/agentic/templates/_ARCHITECTURE.md docs/
cp ~/projects/agentic/templates/_CONVENTIONS.md docs/
```

---

## Step 2: Document Current State

Unlike a new project, you need to capture what already exists.

### Option A: Do It Yourself

If you know the codebase well, fill in the templates:

**_VISION.md:**
- What does this project do?
- Who uses it?
- Why does it exist?

**_ARCHITECTURE.md:**
- What's the tech stack?
- What are the key components?
- What patterns are used?

**_CONVENTIONS.md:**
- What naming patterns exist?
- How is the code structured?
- What's the git workflow?

### Option B: Use an Agent to Help

Activate the Technical Writer or Backend Engineer to explore:

```
You are ~/projects/agentic/docs/roles/technical-writer.md

This is an existing project. Help me document its current state:
1. Explore the codebase structure
2. Identify the tech stack
3. Document existing patterns
4. Fill in docs/_ARCHITECTURE.md
```

Or for more technical analysis:

```
You are ~/projects/agentic/docs/roles/backend-engineer.md

This is an existing project. Help me understand:
1. The overall architecture
2. Database schema
3. Key patterns and conventions
4. Areas that need documentation
```

---

## Step 3: Capture Your Roadmap

Your project probably has implicit plans. Make them explicit:

```
You are ~/projects/agentic/docs/roles/product-manager.md

This is an existing project. Help me:
1. Document what we've already built (recently completed)
2. Capture our current priorities (task queue)
3. Organize future plans into a roadmap
4. Identify decisions we've been deferring
```

After this, `_ROADMAP.md` should reflect:
- Current phase
- What's in progress
- What's coming next
- What's been explicitly deferred

---

## Step 4: Define Conventions

Look at your existing code to extract patterns:

```
You are ~/projects/agentic/docs/roles/platform-engineer.md

Analyze this codebase and help me document our conventions:
1. File and folder structure
2. Naming patterns
3. Code style
4. Testing approach
5. Git workflow
```

**Important:** Document what IS, not what should be. You can evolve conventions later.

---

## Step 5: Set Up _AGENTS.md

Now configure the coordination file for your team:

```markdown
# Agents

## Active Agents

| Role | Status | Current Focus |
|------|--------|---------------|
| Frontend Engineer | Active | New feature X |
| Backend Engineer | Active | API refactor |
| QA Engineer | On-demand | — |

## Frontend Engineer

### Current Status
| Field | Value |
|-------|-------|
| **Status** | Active |
| **Current Task** | Implement new dashboard |
| **Last Updated** | [today] |

### Task Queue
1. [ ] Implement new dashboard
2. [ ] Fix mobile layout issues
3. [ ] Add accessibility improvements

### Recently Completed
- [x] Migrated to new design system (Jan 10)
```

---

## Common Scenarios

### "We have a lot of tech debt"

Activate the Backend Engineer or Platform Engineer to audit:

```
You are ~/projects/agentic/docs/roles/backend-engineer.md

Audit this codebase for technical debt:
1. Identify areas that need refactoring
2. Prioritize by impact and effort
3. Create a tech debt backlog in _ROADMAP.md
```

### "We don't have tests"

Activate the QA Engineer to create a testing strategy:

```
You are ~/projects/agentic/docs/roles/qa-engineer.md

This project has minimal test coverage. Help me:
1. Identify critical paths that need tests first
2. Create a testing strategy
3. Start adding tests to the most important areas
```

### "Our docs are outdated"

Activate the Technical Writer to audit and update:

```
You are ~/projects/agentic/docs/roles/technical-writer.md

Our documentation is outdated. Help me:
1. Identify what's wrong or missing
2. Prioritize what to fix
3. Update the most critical docs
```

### "We need to improve security"

Activate the Security Engineer to audit:

```
You are ~/projects/agentic/docs/roles/security-engineer.md

Perform a security audit of this codebase:
1. Check for common vulnerabilities
2. Review authentication and authorization
3. Document findings and recommendations
```

---

## Gradual Adoption

You don't have to use all agents at once. Adopt gradually:

### Week 1: Documentation
- Add the docs structure
- Capture current state
- Set up _AGENTS.md

### Week 2: First Agent
- Use one agent for a real task
- Learn the activation pattern
- Get comfortable with the workflow

### Week 3+: Expand
- Add more agents as needed
- Refine your conventions
- Build team habits

---

## Tips for Existing Projects

### Honor What Works
Don't change patterns just because an agent suggests it. Stability matters.

### Document Before Changing
Before refactoring, capture current state. You need to know what you're changing from.

### Use Agents for New Work First
Easier to adopt for new features than retrofitting existing code.

### Keep Agents Informed
When activating agents, mention relevant existing patterns:
```
You are ~/projects/agentic/docs/roles/frontend-engineer.md

Note: We use Vue, not React. Our component pattern is [describe it].
Check docs/_CONVENTIONS.md for our coding standards.
```

### Evolve, Don't Revolutionize
Change incrementally. Big rewrites are risky.

---

## Checklist

Before starting with agents:

- [ ] `docs/_VISION.md` — Captured what we're building
- [ ] `docs/_ROADMAP.md` — Current and future priorities
- [ ] `docs/_ARCHITECTURE.md` — Tech stack and patterns
- [ ] `docs/_CONVENTIONS.md` — Coding standards
- [ ] `docs/_AGENTS.md` — Ready for agent coordination

---

## Next Steps

- [Feature Lifecycle](workflows/feature-lifecycle.md) — How new work flows
- [Decisions](../specs/decisions.md) — Human vs agent decisions
- Browse [Roles](../roles/) — Find the right agent for your needs

---

> **Remember:** Agentic adapts to your project, not the other way around. Start where you are.
