# tRPC Patterns

Type-safe API layer using tRPC with TanStack Query.

## Architecture

```
packages/
├── api/
│   └── src/
│       ├── trpc.ts           # Context, procedures
│       └── routers/
│           ├── _app.ts       # Router composition
│           ├── profiles.ts
│           └── ...
└── app/
    └── utils/
        ├── api.ts            # Web client
        └── api.native.ts     # Native client
```

## Server Setup

### Context Creation

```typescript
// packages/api/src/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server'
import { createServerClient } from '@supabase/ssr'

export const createTRPCContext = async (opts: { headers: Headers }) => {
  const supabase = createServerClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_ANON_KEY!,
    { cookies: /* cookie handling */ }
  )

  // Get user from session
  const { data: { user } } = await supabase.auth.getUser()

  return {
    supabase,
    user,
    headers: opts.headers,
  }
}

const t = initTRPC.context<typeof createTRPCContext>().create({
  transformer: SuperJSON,
})

export const router = t.router
export const publicProcedure = t.procedure
export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' })
  }
  return next({ ctx: { ...ctx, user: ctx.user } })
})
```

### Router Composition

```typescript
// packages/api/src/routers/_app.ts
import { router } from '../trpc'
import { profilesRouter } from './profiles'
import { tracksRouter } from './tracks'

export const appRouter = router({
  profiles: profilesRouter,
  tracks: tracksRouter,
  // ... other routers
})

export type AppRouter = typeof appRouter
```

## Web Client (Next.js)

```typescript
// packages/app/utils/api.ts
import { createTRPCNext } from '@trpc/next'
import { httpBatchLink, loggerLink } from '@trpc/client'
import SuperJSON from 'superjson'
import type { AppRouter } from '@acme/api'

export const api = createTRPCNext<AppRouter>({
  transformer: SuperJSON,
  config() {
    return {
      links: [
        loggerLink({
          enabled: (opts) =>
            process.env.NODE_ENV === 'development' ||
            (opts.direction === 'down' && opts.result instanceof Error),
        }),
        httpBatchLink({
          url: `${getBaseUrl()}/api/trpc`,
        }),
      ],
    }
  },
  ssr: false,  // Disable SSR, use 'use client'
})
```

## Native Client (React Native)

```typescript
// packages/app/utils/api.native.ts
import { createTRPCReact } from '@trpc/react-query'
import { httpBatchLink, loggerLink } from '@trpc/client'
import SuperJSON from 'superjson'
import type { AppRouter } from '@acme/api'

export const api = createTRPCReact<AppRouter>()

export const createTrpcClient = () =>
  api.createClient({
    transformer: SuperJSON,
    links: [
      loggerLink({ enabled: () => true }),
      httpBatchLink({
        url: `${getBaseUrl()}/api/trpc`,
        async headers() {
          // Native uses Authorization header
          const session = await getSession()
          if (session?.access_token) {
            return { Authorization: `Bearer ${session.access_token}` }
          }
          return {}
        },
      }),
    ],
  })
```

## Query Patterns

### Basic Query

```typescript
// Component
const { data, isLoading, error } = api.profiles.getById.useQuery({ id: profileId })

// With options
const { data } = api.tracks.list.useQuery(
  { limit: 20, offset: 0 },
  {
    enabled: !!userId,  // Conditional fetching
    staleTime: 5 * 60 * 1000,  // 5 minutes
  }
)
```

### Mutation with Optimistic Update

```typescript
const utils = api.useUtils()

const mutation = api.tracks.update.useMutation({
  onMutate: async (newData) => {
    // Cancel outgoing refetches
    await utils.tracks.getById.cancel({ id: newData.id })

    // Snapshot previous value
    const previous = utils.tracks.getById.getData({ id: newData.id })

    // Optimistic update
    utils.tracks.getById.setData({ id: newData.id }, (old) => ({
      ...old,
      ...newData,
    }))

    return { previous }
  },
  onError: (err, newData, context) => {
    // Rollback on error
    if (context?.previous) {
      utils.tracks.getById.setData({ id: newData.id }, context.previous)
    }
  },
  onSettled: (data, error, variables) => {
    // Refetch after mutation
    utils.tracks.getById.invalidate({ id: variables.id })
  },
})
```

### Invalidation Patterns

```typescript
const utils = api.useUtils()

// Invalidate single query
utils.profiles.getById.invalidate({ id })

// Invalidate all queries for a router
utils.profiles.invalidate()

// Invalidate on context change
useEffect(() => {
  utils.invalidate()  // Invalidate everything on org change
}, [orgId])
```

## Authentication Flow

### Web (Cookie-based)

Cookies are automatically sent with requests. Server reads session from cookie.

### Native (Bearer Token)

```typescript
// In api.native.ts headers function
async headers() {
  // Use getClaims() for local validation (no network call)
  const { data: claimsData } = await supabase.auth.getClaims()

  if (claimsData?.claims) {
    const session = (await supabase.auth.getSession()).data.session
    if (session?.access_token) {
      return { Authorization: `Bearer ${session.access_token}` }
    }
  }
  return {}
}
```

### Server Verification (Native)

```typescript
// In trpc.ts for native auth
const authHeader = opts.headers.get('Authorization')
if (authHeader?.startsWith('Bearer ')) {
  const token = authHeader.slice(7)
  // Verify JWT using JWKS
  const payload = await verifyJWT(token)
  // ...
}
```

## Error Handling

```typescript
// In router
export const tracksRouter = router({
  getById: protectedProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ ctx, input }) => {
      const track = await ctx.supabase
        .from('tracks')
        .select('*')
        .eq('id', input.id)
        .single()

      if (track.error) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: 'Track not found',
        })
      }

      return track.data
    }),
})

// In component
const { error } = api.tracks.getById.useQuery({ id })
if (error?.data?.code === 'NOT_FOUND') {
  return <NotFound />
}
```

## Red Flags

- String query keys (use router paths: `api.profiles.getById`)
- Missing error handling on mutations
- Invalidation not matching query params
- Using `getUser()` in hot paths (use `getClaims()` for local validation)
- Mixing web and native auth methods
