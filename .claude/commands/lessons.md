---
description: Surface relevant lessons from documented failures
allowed-tools: Read, Glob
---

# /lessons — Surface Learned Lessons

Read documented lessons and present 1-3 most relevant to current context.

## Process

1. **Read lesson files**
   - Read `docs/lessons/READ_DOCS_FIRST.md`
   - Read `docs/lessons/FLUENT_OUTPUT_TRAP.md`
   - Read `docs/lessons/EVERY_LINE_EARNED.md`

2. **Assess current context**
   - What task is in progress?
   - What patterns might apply?

3. **Present relevant lessons**
   - Pick 1-3 most applicable
   - Extract the core insight
   - Explain why it's relevant now

## Output Format

```
## Relevant Lessons

### [Lesson Name]
**Core insight:** [One sentence]
**Why it applies:** [Brief explanation of relevance to current work]

### [Lesson Name]
**Core insight:** [One sentence]
**Why it applies:** [Brief explanation]
```

## When to Use

- Start of session (quick reminder)
- Before producing significant output
- When catching yourself in a pattern
- After making a mistake

## Example

```
## Relevant Lessons

### Read Docs First
**Core insight:** Documentation beats generated context. Every line was earned.
**Why it applies:** About to start a new feature. Should read _FRAGILE.md first.

### The Fluent Output Trap
**Core insight:** "Powerful" and "interesting" are empty words. Say something specific.
**Why it applies:** Just wrote a summary. Check if it actually says anything.
```

## Lesson Files

Located in `docs/lessons/`:

| File | Core Lesson |
|------|-------------|
| `READ_DOCS_FIRST.md` | Documentation > generated context |
| `FLUENT_OUTPUT_TRAP.md` | Say something specific or nothing |
| `EVERY_LINE_EARNED.md` | Every rule is scar tissue from failure |

Also check `docs/dialogues/` for full context on how lessons were learned.
