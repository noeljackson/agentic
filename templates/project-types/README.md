# Project-Specific Templates

This directory contains specialized templates for specific project types. Each template includes complete setup instructions, database schemas, code structure, and verification tools.

## Available Templates

### Data Modeling

**Location:** `data-modeling/`

**For projects with:**
- Complex data projections and scenarios
- Database-driven calculations
- Verified claims with sources
- Multi-scenario analysis

**Includes:**
- Complete Supabase database schema
- `/lib` structure with single source of truth pattern
- TanStack Query integration with optimistic updates
- Verification scripts to catch architecture violations
- Seed data scripts

**See:** [`data-modeling/PROJECT_INITIATION.md`](data-modeling/PROJECT_INITIATION.md)

---

## When to Use Project-Specific Templates

**Use these when:**
- Your project has specialized architectural needs
- You need a proven pattern for a specific domain
- You want guardrails to prevent common mistakes

**Don't use these when:**
- Building a simple CRUD app
- General templates (in `templates/`) are sufficient
- Your project doesn't match any specialized pattern

---

## Contributing New Templates

Have a pattern that works? Consider adding it here:

1. Create a new directory under `project-types/`
2. Include complete setup instructions
3. Provide verification tools
4. Document when to use (and when not to)
5. Update this README
