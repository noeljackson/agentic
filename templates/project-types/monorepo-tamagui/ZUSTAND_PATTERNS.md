# Zustand Patterns

State management using Zustand with React Context wrappers for dependency injection.

## Why Context Wrappers?

Plain Zustand stores are global singletons. Context wrappers provide:
- Dependency injection (store can be provided at different tree levels)
- Testing (mock stores per test)
- Multiple instances (if needed)
- Clear provider boundaries (error if used outside provider)

## Store Factory Pattern

```typescript
// types
interface AppState {
  isOpen: boolean
  viewMode: 'grid' | 'list'
}

interface AppActions {
  setIsOpen: (open: boolean) => void
  setViewMode: (mode: 'grid' | 'list') => void
}

type AppStore = AppState & AppActions
type AppStoreApi = StoreApi<AppStore>

// default state
const defaultInitState: AppState = {
  isOpen: false,
  viewMode: 'grid',
}

// factory function
export const createAppStore = (initState: AppState = defaultInitState) => {
  return createStore<AppStore>()(
    persist(
      (set, get) => ({
        ...initState,
        setIsOpen: (open) => set({ isOpen: open }),
        setViewMode: (mode) => set({ viewMode: mode }),
      }),
      {
        name: 'app-store',
        storage: createJSONStorage(() => isWeb ? localStorage : AsyncStorage),
      }
    )
  )
}
```

## Provider Pattern

```typescript
// context
const AppStoreContext = createContext<AppStoreApi | null>(null)

// provider
interface AppStoreProviderProps {
  children: React.ReactNode
  initialState?: Partial<AppState>
}

export const AppStoreProvider = ({ children, initialState }: AppStoreProviderProps) => {
  const storeRef = useRef<AppStoreApi>(null)

  if (!storeRef.current) {
    storeRef.current = createAppStore({
      ...defaultInitState,
      ...initialState,
    })
  }

  return (
    <AppStoreContext.Provider value={storeRef.current}>
      {children}
    </AppStoreContext.Provider>
  )
}
```

## Hook Pattern

```typescript
// selector hook
export const useAppStore = <T,>(selector: (store: AppStore) => T): T => {
  const appStoreContext = useContext(AppStoreContext)

  if (!appStoreContext) {
    throw new Error('useAppStore must be used within AppStoreProvider')
  }

  return useStore(appStoreContext, selector)
}

// usage
const isOpen = useAppStore((s) => s.isOpen)
const setIsOpen = useAppStore((s) => s.setIsOpen)
```

## Persist Middleware

```typescript
import { persist, createJSONStorage } from 'zustand/middleware'
import AsyncStorage from '@react-native-async-storage/async-storage'

const isWeb = typeof window !== 'undefined' && !window.ReactNativeWebView

createStore()(
  persist(
    (set, get) => ({ /* state */ }),
    {
      name: 'app-store',  // unique key in storage
      storage: createJSONStorage(() => isWeb ? localStorage : AsyncStorage),
      partialize: (state) => ({
        // only persist specific fields
        viewMode: state.viewMode,
        // don't persist transient state like isOpen
      }),
    }
  )
)
```

## getState() for Non-Reactive Access

When you need current state outside of React (event handlers, async callbacks):

```typescript
// In a non-React context
const handleExternalEvent = () => {
  const store = useAppStoreContext.getState()  // Direct access
  if (store.isOpen) {
    store.setIsOpen(false)
  }
}

// In store definition, access other state
const createPlayerStore = () => createStore()((set, get) => ({
  play: () => {
    const currentTrack = get().currentTrack  // get() for same store
    if (currentTrack) {
      // play logic
    }
  },
}))
```

## Transient Updates (No Re-render)

For high-frequency updates (audio position, animations):

```typescript
const createPlayerStore = () => createStore()((set, get) => ({
  position: 0,

  // This triggers re-renders on every update
  setPosition: (pos) => set({ position: pos }),

  // Transient ref for high-frequency updates
  positionRef: { current: 0 },

  updatePositionTransient: (pos) => {
    get().positionRef.current = pos
    // No set() = no re-render
  },
}))

// Component reads ref when needed, not on every tick
const position = usePlayerStore((s) => s.positionRef.current)
```

## Store Subscriptions

Subscribe to store changes outside React:

```typescript
const unsubscribe = useAppStore.subscribe(
  (state) => state.isOpen,
  (isOpen, prevIsOpen) => {
    if (isOpen && !prevIsOpen) {
      analytics.track('panel_opened')
    }
  }
)

// Clean up
unsubscribe()
```

## File Organization

```
provider/
└── stores/
    ├── index.ts                    # Re-exports all stores
    ├── app-store-provider.tsx      # Provider component
    ├── useAppStore.ts              # Store factory + hook
    ├── collection-store-provider.tsx
    ├── useCollectionStore.ts
    └── ...
```

## Red Flags

- Using store outside its provider (causes "must be used within" error)
- Persisting transient state (bloats storage, slow hydration)
- Subscribing without cleanup (memory leak)
- Direct store modification without set() (breaks reactivity)
- Heavy computations in selectors (use useMemo outside)
