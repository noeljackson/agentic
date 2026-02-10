Commit ALL changes, create a new version tag, and push everything. No co-authoring.

## Steps

1. Run `git status` to see all changes (staged, unstaged, and untracked)
2. Run `git diff` to see the actual code changes
3. Run `git log --oneline -5` to see recent commit message style
4. Check current branch with `git branch --show-current`
5. Check if branch has upstream with `git status -sb`
6. Analyze the changes and draft a concise commit message:
   - Summarize the nature of the changes (feature, fix, refactor, docs, etc.)
   - Focus on the "why" rather than the "what"
   - Match the repository's commit message style
7. Stage all relevant changes with `git add`
8. Commit with the message (NO co-author, NO "Generated with Claude Code" footer)
9. Find the latest version tag:
   - Run `git tag --list 'v*' --sort=-v:refname | head -1`
   - Parse the version number (e.g., v1.2.3)
   - Increment the patch version (e.g., v1.2.3 → v1.2.4)
   - If no tags exist, start with v0.0.1
10. Create the new tag: `git tag <new-version>`
11. Push commit and tag to remote:
    - If branch has no upstream, use `git push -u origin <branch>`
    - Otherwise use `git push`
    - Push the tag: `git push origin <new-version>`
12. Run `git status` and display the new version tag

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
- Always increment the PATCH version (last number)
- Tag format is lowercase v followed by semver: v1.2.3
