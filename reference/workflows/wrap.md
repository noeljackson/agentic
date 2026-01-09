# Wrap

The closure protocol. Say `wrap` when you're done with a piece of work.

---

## What Happens

1. **Update `_AGENTS.md`** — Mark work complete, add to "Recently Completed"
2. **Update `_SESSION_MEMO.md`** — Capture problem, root cause, solution, commits
3. **Write handoff** — If another role continues, leave notes
4. **Update `_TODAY.md`** — What got done
5. **Stage changes** — `git add` the relevant files
6. **Code review** — Run `/code-review` on staged changes (for non-trivial work)
7. **Address issues** — Fix blocking feedback before proceeding
8. **Commit** — Show what's being committed, then commit with good message
9. **Clean up** — Check for stale items, verify "done" means done
10. **Report** — Summarize what shipped

---

## Session Memo Format

For bug fixes and changes, capture the full context:

```markdown
### [Feature/Fix Name] - COMPLETE ✅

**Problem:** [User-facing issue or goal]

**Root Cause:** [Why it happened]

**Solution:**
1. [Change 1] (`path/to/file.ts:line`)
2. [Change 2] (`path/to/file.ts:line`)

**Commits:** [hash] [message]

**Deployed:** [OTA / Native / Not yet]
```

This helps future sessions understand *why* changes were made, not just *what* changed.

---

## Code Review Integration

For significant changes, wrap includes a code review step:

```
You: wrap

Agent:
Staged: 4 files changed (profiles API)

Running code review...

Review: LGTM
- Clean API design
- Types are complete
- Minor: consider adding rate limiting (non-blocking)

Committed: abc123f - "feat(profiles): add user profiles"
```

**When to skip review:**
- Single-file doc changes
- Config/formatting only
- Emergency hotfixes (note in commit why skipped)

**When review blocks:**
- Security issues found
- Breaking API changes
- Missing error handling

Address blocking issues, re-stage, then commit.

---

## Example

```
You: wrap

Agent:
Completed:
- Profiles API (4 endpoints)
- Profile screen

Committed: abc123f - "feat(profiles): add user profiles"

Handoff for Frontend:
- Endpoints at /api/profiles
- Types in lib/types.ts

Still pending:
- Password validation (not started)

Ready for: QA
```

---

## Triggers

Any of these:
- `wrap`
- `wrap it up`
- `close this out`

---

## When to Use

- After completing a feature
- End of a work session
- Before switching to different work
- Before handing off to another role

---

## Quick Version

For small changes:

```
Wrap:
- Committed: "fix: profile image upload"
- No handoffs needed
```
