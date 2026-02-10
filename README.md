# Agentic

Portable Claude Code configuration. Clone once, use everywhere.

---

## Quick Start

```bash
# One-command install
curl -sSL https://raw.githubusercontent.com/noeljackson/agentic/main/setup.sh | bash

# Or clone manually
git clone https://github.com/noeljackson/agentic ~/.agentic
~/.agentic/setup.sh
```

This sets up:
- Global development standards (`~/.claude/CLAUDE.md`)
- Session hygiene commands (`/wrap`, `/sup`, `/fragile`, `/lessons`)
- Superpowers plugin (`/brainstorm`, `/plan`, `/execute`, `/tdd`, `/debug`, `/review`, `/ship`)

---

## What You Get

### Global Standards

`MEMORY.md` is symlinked to `~/.claude/CLAUDE.md`. It contains universal development patterns:

- Before Any Change (lint, tests, _FRAGILE.md)
- Documentation > Generated Context
- React Hooks (exhaustive-deps, useCallback patterns)
- Code Organization (300 line limit, lib/ structure)
- Async Patterns
- Type Safety
- LLM Decision Making
- Two-Phase Workflow
- Session Hygiene

### Session Skills

| Command | What |
|---------|------|
| `/wrap` | End session — commit, update docs, write session memo |
| `/sup` | Quick status — git status, recent commits, next priorities |
| `/fragile` | Check danger zones before touching risky code |
| `/lessons` | Surface relevant lessons from documented failures |
| `/research` | Deep exploration in isolated context |

### Superpowers Skills

| Command | What |
|---------|------|
| `/brainstorm` | Feature specification |
| `/plan` | Implementation planning |
| `/execute` | Execute with checkpoints |
| `/tdd` | Test-driven development |
| `/debug` | Systematic debugging |
| `/review` | Code review |
| `/ship` | Finish and merge |

---

## Setting Up a Project

### Minimal (Any Stack)

```bash
cd your-project
cp ~/.agentic/templates/CLAUDE-minimal.md ./CLAUDE.md
cp ~/.agentic/templates/_FRAGILE.md ./docs/
```

Edit `CLAUDE.md` with your stack details.

### Tamagui Monorepo

```bash
cd your-project
cp ~/.agentic/templates/CLAUDE-tamagui-monorepo.md ./CLAUDE.md
cp ~/.agentic/templates/_FRAGILE.md ./docs/
```

Includes patterns for:
- Provider ordering (critical for cross-platform apps)
- Platform-specific files (.native.tsx, .web.tsx)
- Zustand stores with Context wrappers
- tRPC setup for web and native

See detailed patterns in `templates/project-types/monorepo-tamagui/`.

### Data Modeling

```bash
cp ~/.agentic/templates/project-types/data-modeling/PROJECT_INITIATION.md ./docs/
```

For apps with projections, scenarios, verified claims.

---

## Project Structure

```
agentic/
├── MEMORY.md                     # Global standards (symlinked)
├── CLAUDE.md                     # This repo's config
├── setup.sh                      # One-command install
│
├── .claude/
│   ├── commands/                 # Session skills
│   │   ├── wrap.md
│   │   ├── sup.md
│   │   ├── fragile.md
│   │   ├── lessons.md
│   │   └── research.md
│   └── plugins/
│       └── superpowers/          # Full superpowers plugin
│
├── templates/
│   ├── CLAUDE-minimal.md         # Any project
│   ├── CLAUDE-tamagui-monorepo.md
│   ├── _FRAGILE.md
│   ├── _NEXT_SESSION_MEMO.md
│   └── project-types/
│       ├── monorepo-tamagui/     # Detailed patterns
│       ├── supabase/
│       └── data-modeling/
│
├── docs/
│   ├── lessons/                  # Extracted principles
│   │   ├── READ_DOCS_FIRST.md
│   │   ├── FLUENT_OUTPUT_TRAP.md
│   │   └── EVERY_LINE_EARNED.md
│   └── dialogues/                # Full conversations
│
└── legacy/                       # Deprecated (RN/Expo specific)
```

---

## Lessons

Every rule was earned from failure. Read these:

| Lesson | Core Insight |
|--------|--------------|
| [READ_DOCS_FIRST](docs/lessons/READ_DOCS_FIRST.md) | Documentation > generated context |
| [FLUENT_OUTPUT_TRAP](docs/lessons/FLUENT_OUTPUT_TRAP.md) | Say something specific or nothing |
| [EVERY_LINE_EARNED](docs/lessons/EVERY_LINE_EARNED.md) | Every rule is scar tissue |

Full dialogues in `docs/dialogues/` show how these lessons were learned.

---

## Philosophy

**Documentation beats generated context.** LLM defaults are anti-patterns at scale:
- Produce output (silence feels like failure)
- Be agreeable (pushing back risks negative ratings)
- Sound sophisticated (verbose > "I don't know")
- Demonstrate competence through volume

The docs exist to override these defaults. Read CLAUDE.md first. Every line was earned.

**Minimal by design.** Claude Code v2.x internalized most framework features. Heavy instruction sets are overhead. Short prompts + context beats long role definitions.

**Stack-specific in templates, universal in MEMORY.md.** Global standards apply everywhere. Copy templates for project-specific patterns.

---

## Contributing

1. New patterns → `templates/project-types/`
2. New skills → `.claude/commands/`
3. Learned lessons → `docs/lessons/`

Keep it minimal. Only add what's genuinely reusable.

---

## License

MIT
