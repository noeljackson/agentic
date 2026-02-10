# Cleanse Claude Code Data

Clean sensitive data from `~/.claude/` — JWT tokens, debug logs, old sessions, clipboard caches.

## Steps

1. Run a dry-run first to show what would be cleaned:
```bash
~/.claude/commands/cleanse.sh --dry-run --verbose
```

2. Show the user the summary output and ask if they want to proceed.

3. If confirmed, run the actual cleanup:
```bash
~/.claude/commands/cleanse.sh --execute
```

## User options
- "just clean sessions" -> add `--sessions-only`
- "clean everything" -> add `--aggressive`
- "keep last 30 days" -> add `--keep-days 30`
- "scan for secrets" -> add `--scan`
