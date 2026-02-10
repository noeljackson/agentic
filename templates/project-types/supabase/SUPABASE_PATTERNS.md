# Supabase Patterns

Stack-specific patterns for Supabase projects.

---

## Supabase SDK

**ALWAYS use the Supabase SDK (@supabase/supabase-js)**

- Never write direct database queries or custom database connections
- Use `.from()`, `.select()`, `.insert()`, `.update()`, `.delete()` from the SDK
- For complex queries, use Supabase RPC functions (call via `.rpc()`)
- Direct SQL is ONLY for: migrations, RLS policies, database functions (in Supabase dashboard)
- Import from `lib/supabase/client.ts`, never create multiple clients

---

## RLS & Data Access

- RLS policies must never query other RLS-protected tables — use SECURITY DEFINER helpers
- Test RLS as: owner, member, visitor, unauthenticated
- Nested selects (`select('*, relation(*)')`) return different shapes — validate before accessing
- Profile ID ≠ Auth User ID — pre-staged profiles have null auth_user_id
- `timestamptz` always, never `timestamp`

---

## Red Flags

- Direct SQL queries in code (use Supabase SDK: `.from()`, `.select()`, etc.)
- Multiple `createClient` calls (use single client from `lib/supabase/client.ts`)
- Custom database connections (use Supabase SDK only)
- RLS policies querying other RLS tables

---

## SECURITY DEFINER Pattern

When RLS policies need to access other protected tables:

```sql
-- Bad: RLS policy querying RLS table
CREATE POLICY "users_can_view_org_data" ON org_data
  USING (
    EXISTS (
      SELECT 1 FROM memberships  -- This is RLS-protected!
      WHERE memberships.org_id = org_data.org_id
      AND memberships.user_id = auth.uid()
    )
  );

-- Good: Use SECURITY DEFINER helper
CREATE OR REPLACE FUNCTION user_is_org_member(org_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM memberships
    WHERE memberships.org_id = $1
    AND memberships.user_id = auth.uid()
  );
END;
$$;

CREATE POLICY "users_can_view_org_data" ON org_data
  USING (user_is_org_member(org_id));
```

---

## TanStack Query Integration

- Query key factories, not string literals
- Invalidation keys must exactly match query keys
- Invalidate on context switches (org, user, kid mode)
- Optimistic updates: onMutate (cancel + store previous), onError (rollback)

**Key factory pattern:**

```typescript
// lib/queries/keys.ts
export const queryKeys = {
  profiles: {
    all: ['profiles'] as const,
    detail: (id: string) => ['profiles', id] as const,
    list: (filters: ProfileFilters) => ['profiles', 'list', filters] as const,
  },
  organizations: {
    all: ['organizations'] as const,
    detail: (id: string) => ['organizations', id] as const,
    members: (orgId: string) => ['organizations', orgId, 'members'] as const,
  },
}
```

**Optimistic update pattern:**

```typescript
const mutation = useMutation({
  mutationFn: updateProfile,
  onMutate: async (newProfile) => {
    // Cancel outgoing queries
    await queryClient.cancelQueries({ queryKey: queryKeys.profiles.detail(id) })

    // Snapshot previous value
    const previous = queryClient.getQueryData(queryKeys.profiles.detail(id))

    // Optimistically update
    queryClient.setQueryData(queryKeys.profiles.detail(id), newProfile)

    return { previous }
  },
  onError: (err, newProfile, context) => {
    // Rollback on error
    queryClient.setQueryData(queryKeys.profiles.detail(id), context?.previous)
  },
  onSettled: () => {
    // Refetch after mutation
    queryClient.invalidateQueries({ queryKey: queryKeys.profiles.detail(id) })
  },
})
```
