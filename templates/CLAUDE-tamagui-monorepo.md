# Tamagui Monorepo Project

Cross-platform app using Tamagui, tRPC, Zustand, and a monorepo structure.

## Stack

- **UI:** Tamagui (cross-platform)
- **State:** Zustand with React Context wrappers
- **API:** tRPC with TanStack Query
- **Structure:** Monorepo (apps/, packages/)
- **Platforms:** iOS, Android, Web

## Project Structure

```
project/
├── apps/
│   ├── expo/              # Mobile app (Expo)
│   └── next/              # Web app (Next.js)
├── packages/
│   ├── app/               # Shared app code
│   │   ├── features/      # Feature modules
│   │   ├── provider/      # Provider composition
│   │   │   └── stores/    # Zustand stores
│   │   └── utils/         # Shared utilities
│   ├── api/               # tRPC routers
│   └── ui/                # Shared UI components
```

## Critical: Provider Ordering

Providers must be composed in dependency order. See `templates/project-types/monorepo-tamagui/PROVIDER_ORDERING.md`.

Typical order:
1. Theme providers (UniversalThemeProvider, TamaguiProvider)
2. Safe area, toast, analytics
3. QueryClientProvider (React Query)
4. Auth providers
5. Store providers (in dependency order)
6. Feature providers (that depend on stores)

## Platform-Specific Files

Use file extensions for platform splits:
- `.tsx` — Default (usually web)
- `.native.tsx` — React Native/Expo
- `.web.tsx` — Web override

See `templates/project-types/monorepo-tamagui/PLATFORM_FILES.md`.

## Zustand Patterns

Stores use vanilla Zustand with React Context wrappers for dependency injection:

```typescript
// Factory function
export const createAppStore = (initState = defaultInitState) => {
  return createStore<AppStore>()(
    persist(
      (set, get) => ({ ...initState, actions }),
      { name: 'app-store', storage: createJSONStorage(() => storage) }
    )
  )
}

// Provider wraps the store
export const AppStoreProvider = ({ children }) => {
  const storeRef = useRef<AppStoreApi>(null)
  if (!storeRef.current) {
    storeRef.current = createAppStore()
  }
  return <AppStoreContext.Provider value={storeRef.current}>{children}</AppStoreContext.Provider>
}

// Hook with selector
export const useAppStore = <T,>(selector: (store: AppStore) => T): T => {
  const context = useContext(AppStoreContext)
  if (!context) throw new Error('useAppStore must be used within AppStoreProvider')
  return useStore(context, selector)
}
```

See `templates/project-types/monorepo-tamagui/ZUSTAND_PATTERNS.md`.

## tRPC Patterns

- Server: Procedures in `packages/api/src/routers/`
- Web client: `createTRPCNext` with cookie auth
- Native client: `createTRPCReact` with Authorization header

See `templates/project-types/monorepo-tamagui/TRPC_PATTERNS.md`.

## URL ID vs Database ID

For public-facing URLs, use URL-safe IDs (slugs or short IDs) separate from database UUIDs:

```typescript
// Router receives URL ID
const track = await api.tracks.getByUrlId.useQuery({ urlId: params.urlId })

// Internal operations use database ID
const mutation = api.tracks.update.useMutation()
mutation.mutate({ id: track.data.id, ... })  // UUID
```

## Red Flags

- Provider out of order (causes undefined context errors)
- Missing `.native.tsx` for platform-specific code
- Zustand store accessed outside its provider
- tRPC client using wrong auth method for platform
- Hardcoded URLs or IDs that should come from config

## Danger Zones

Document these in `docs/_FRAGILE.md`:
- Provider ordering changes
- Audio/video playback system
- Auth flow (especially token refresh)
- Real-time subscriptions
- Deep linking / URL routing

## Detailed Patterns

See `templates/project-types/monorepo-tamagui/`:
- `PROVIDER_ORDERING.md` — Critical ordering with rationale
- `PLATFORM_FILES.md` — Platform split conventions
- `ZUSTAND_PATTERNS.md` — Store factory pattern
- `TRPC_PATTERNS.md` — Client setup and key patterns
