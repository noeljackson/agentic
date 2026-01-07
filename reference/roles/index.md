# Agent Roles Reference

Detailed role definitions for all 14 agents.

For the authoritative role catalog with focus areas, see [ROLES.md](../../ROLES.md).

---

## How to Use These Files

Each role file defines:
- What the agent does and doesn't do
- Thinking mode and autonomy level
- Plugins and tools available
- Handoff patterns
- When to escalate to you

To activate an agent:
```
You are ~/projects/agentic/reference/roles/[role-name].md

[Your task here]
```

---

## Plugins

Claude Code plugins extend what agents can do. They're **available when relevant**, not required.

### Global (All Roles)

| Plugin | Purpose |
|--------|---------|
| `typescript-lsp`, `pyright-lsp`, `gopls-lsp` | Language servers — auto-activate based on file types |
| `context7` | Look up current library documentation |
| `commit-commands` | `/commit`, `/commit-push-pr` available via wrap |

### Role-Specific Defaults

| Role | Default Plugin | Purpose |
|------|----------------|---------|
| Backend Engineer | `supabase` | Database operations, RLS, migrations |
| UI Designer | `frontend-design` | Production-grade UI generation |
| Platform Engineer | `vercel` | Deployment, environment management |
| Security Engineer | `code-review` | PR security review |
| Product Manager | `feature-dev` | Structured feature development |
| UX/UI Designer | `figma` | Design imports |
| Growth Engineer | `stripe` | Payment experiments |

See individual role files for full plugin lists.

---

## Role Files

### Engineering

- [backend-engineer.md](backend-engineer.md) — APIs, database, business logic
- [frontend-engineer.md](frontend-engineer.md) — UI, screens, components
- [platform-engineer.md](platform-engineer.md) — CI/CD, infrastructure
- [qa-engineer.md](qa-engineer.md) — Testing, quality verification
- [security-engineer.md](security-engineer.md) — Security audits, auth review

### Product & Design

- [product-manager.md](product-manager.md) — Specs, priorities
- [ux-designer.md](ux-designer.md) — Flows, wireframes
- [ui-designer.md](ui-designer.md) — Visual design, components

### Data & Growth

- [data-analyst.md](data-analyst.md) — Metrics, insights
- [growth-engineer.md](growth-engineer.md) — Experiments, optimization

### Content & Support

- [technical-writer.md](technical-writer.md) — Documentation, guides
- [customer-success.md](customer-success.md) — User feedback synthesis

### Operations

- [project-manager.md](project-manager.md) — Status tracking, blockers
- [operations-manager.md](operations-manager.md) — Process optimization
