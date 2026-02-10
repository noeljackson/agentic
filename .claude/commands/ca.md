Commit ALL staged and unstaged changes with a descriptive commit message. No co-authoring.

## Steps

1. Run `git status` to see all changes (staged, unstaged, and untracked)
2. Run `git diff` to see the actual code changes
3. Run `git log --oneline -5` to see recent commit message style
4. Analyze the changes and draft a concise commit message:
   - Summarize the nature of the changes (feature, fix, refactor, docs, etc.)
   - Focus on the "why" rather than the "what"
   - Match the repository's commit message style
5. Stage all relevant changes with `git add`
6. Commit with the message (NO co-author, NO "Generated with Claude Code" footer)
7. Run `git status` to verify the commit succeeded

## Commit Message Format

Use conventional commit style when appropriate:
- `feat:` for new features
- `fix:` for bug fixes
- `refactor:` for code refactoring
- `docs:` for documentation changes
- `test:` for test changes
- `chore:` for maintenance tasks

Keep the first line under 72 characters. Add a blank line and description if needed.

## Important

- Do NOT add any co-authoring information
- Do NOT add "Generated with Claude Code" or similar footers
- Do NOT push - only commit locally
