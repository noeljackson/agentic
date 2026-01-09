# Agents

Current state of parallel work and agent coordination.

---

## Active Work

| Task | Status | Owner | Blocked By | Output | Updated |
|------|--------|-------|------------|--------|---------|
| [Task description] | 🔵 In Progress | Backend | — | `lib/api.ts` | Jan 8 |
| [Task description] | ⏸️ Blocked | Frontend | Backend API | — | Jan 8 |
| [Task description] | ✅ Complete | QA | — | Tests pass | Jan 7 |

**Status Key:**
- 🔵 In Progress — Active work
- ⏸️ Blocked — Waiting on dependency
- ✅ Complete — Done, ready for handoff
- 🟡 Review — Needs founder decision

**Blocked By:** Use task descriptions or role names, not specific IDs. Keep generic.

---

## Recently Completed

| Task | Completed | Owner | Notes |
|------|-----------|-------|-------|
| [What was done] | Jan 7 | Backend | [Brief note or link to handoff] |

---

## Handoffs

### [Role] → [Role] | [Date]

**What was done:**
[Brief description]

**Why it was done this way:**
[Reasoning, trade-offs considered]

**For next agent:**
- [Specific instruction]
- [File reference: `path/to/file.ts:line`]

**For Founder (FYI):**
- [One-line summary]
- [Any concerns or "No concerns"]

---

## Cross-Agent Notes

**For [Role] (from [Role]):**
- [Specific note]
- [File or context reference]

---

## Decision Queue

### Blocking
| Topic | Options | Recommendation | Added |
|-------|---------|----------------|-------|
| [Decision needed] | [A, B, C] | [Recommended choice + why] | Jan 8 |

### Non-Blocking
| Topic | Options | Recommendation | Added |
|-------|---------|----------------|-------|
| [Decision needed] | [A, B] | [Recommended choice] | Jan 8 |

### Decided
| Topic | Decision | Rationale | Date |
|-------|----------|-----------|------|
| [Topic] | [Choice] | [Why] | Jan 7 |

---

## Work Packages

### Active
| Package | Phase | Owner | State | Blocking? |
|---------|-------|-------|-------|-----------|
| [Feature name] | Frontend | Frontend Eng | Working | No |

### Queued
| Package | Next Phase | Waiting For |
|---------|------------|-------------|
| [Feature name] | Spec | [Current work] to complete |

---

## Standing Decisions

Patterns established for this project:

| Area | Decision | Rationale |
|------|----------|-----------|
| [API style] | [REST with /api prefix] | [Consistency] |
| [State management] | [TanStack Query] | [Caching, mutations] |

---

*Update this file as work progresses. It's the source of truth for coordination.*
