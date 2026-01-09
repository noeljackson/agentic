# Vocabulary

Canonical terms for this project. Use these consistently.

---

## Entity Glossary

| Term | Definition | Database Table | Notes |
|------|------------|----------------|-------|
| **User** | A person using the app | `profiles` | Not `auth.users` — that's internal |
| **Organization** | A tenant/workspace | `organizations` | Multi-tenant boundary |
| **Membership** | User's role in an org | `memberships` | Links user to org with role |

---

## Disambiguation

Terms that cause confusion:

| When you say... | You might mean... | Canonical term |
|-----------------|-------------------|----------------|
| "user" | Auth record | **Auth User** (`auth.users`) |
| "user" | Profile record | **Profile** (`profiles`) |
| "user" | The person | **User** (abstract) |
| "member" | A person in an org | **Member** (abstract) |
| "member" | The database record | **Membership** (`memberships`) |

**Rule:** In code and docs, use the canonical term. In conversation, context clarifies.

---

## Screen Index

Canonical names for app screens:

| Screen Name | Route | Description |
|-------------|-------|-------------|
| Home | `/` or `/(tabs)/home` | Main dashboard |
| Login | `/(auth)/login` | Authentication |
| Settings | `/settings` | User preferences |
| [Add screens as built] | | |

---

## API Conventions

| Pattern | Example | When to use |
|---------|---------|-------------|
| List resources | `GET /api/items` | Fetching collections |
| Get single | `GET /api/items/:id` | Fetching one item |
| Create | `POST /api/items` | Creating new |
| Update | `PATCH /api/items/:id` | Partial update |
| Delete | `DELETE /api/items/:id` | Removal |

---

## Naming Conventions

| Context | Style | Example |
|---------|-------|---------|
| TypeScript variables | camelCase | `userId`, `organizationId` |
| TypeScript types | PascalCase | `UserProfile`, `Organization` |
| Database columns | snake_case | `user_id`, `created_at` |
| API endpoints | kebab-case | `/api/user-profiles` |
| File names | kebab-case | `user-profile.ts` |
| Component files | PascalCase | `UserProfile.tsx` |

---

## Acronyms & Abbreviations

| Abbreviation | Full Term | Context |
|--------------|-----------|---------|
| RLS | Row-Level Security | Supabase policies |
| OTA | Over-the-Air | Expo updates |
| E2E | End-to-End | Testing |

---

## Project-Specific Terms

| Term | Definition |
|------|------------|
| [Domain term 1] | [What it means in this project] |
| [Domain term 2] | [What it means in this project] |

---

*Update this file when new terms emerge or confusion arises.*
