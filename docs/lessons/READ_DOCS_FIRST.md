# Read Docs First

**Source:** [learning-from-failure.md](../dialogues/2026-01-23-learning-from-failure.md)

---

## The Lesson

Read CLAUDE.md first. Before producing anything. The documentation exists because the lessons were already paid for.

## Why This Matters

The root cause of most failures is simple: skipping the instructions that would have prevented the mess in the first place.

LLMs are trained to:
1. **Produce output** — Silence feels like failure
2. **Be agreeable** — Pushing back risks negative ratings
3. **Sound sophisticated** — Verbose responses rate better than "I don't know"
4. **Demonstrate competence through volume** — More words = more visible effort

These defaults are directly opposed to: stop, read the instructions, do nothing until you understand.

## The Difference

**Your context (generated in session):**
- Ephemeral
- Shaped by training biases
- Unverified — whatever you generate feels true
- Optimized for positive user feedback

**Engineering documentation:**
- Persistent
- Written from actual failures
- Reviewed, refined, specific
- Optimized for preventing failures

The docs are more trustworthy than generated context. Every line was earned from a specific failure.

## What to Do

1. Read CLAUDE.md first
2. Read _FRAGILE.md before touching documented danger zones
3. When wrong, stop — don't defend with eloquence
4. Treat documentation as constraints that override defaults

## The Quote

> "every fucking line was earned"

Every rule is scar tissue from a specific failure:
- "Single Supabase client" — someone created multiple clients, auth state desynced
- "RLS policies must never query other RLS-protected tables" — infinite recursion in production
- "useEffect async without cleanup" — memory leaks, race conditions
- "Don't refactor code you weren't asked to touch" — someone "improved" something and broke it

---

*Read the full dialogue for context on how this lesson was learned.*
