# Platform-Specific Files

Cross-platform code uses file extensions to provide platform-specific implementations.

## Extension Conventions

| Extension | Platform | Bundler Resolution |
|-----------|----------|-------------------|
| `.tsx` | Default (usually web) | Fallback when no platform match |
| `.native.tsx` | React Native (iOS + Android) | Matched by Metro |
| `.web.tsx` | Web only | Matched by webpack/Next.js |
| `.ios.tsx` | iOS only | Matched by Metro |
| `.android.tsx` | Android only | Matched by Metro |

## Resolution Order

**Metro (React Native):**
1. `.ios.tsx` / `.android.tsx` (platform-specific)
2. `.native.tsx` (shared native)
3. `.tsx` (default)

**Webpack/Next.js (Web):**
1. `.web.tsx` (web-specific)
2. `.tsx` (default)

## Common Patterns

### API Client Split

```
utils/
├── api.ts           # Web (Next.js with createTRPCNext)
└── api.native.ts    # Native (createTRPCReact with Bearer token)
```

### Provider Split

```
provider/
├── auth/
│   ├── AuthProvider.tsx        # Shared logic
│   └── AuthProvider.native.tsx # Native-specific (SecureStore, etc.)
├── safe-area/
│   └── SafeAreaProvider.native.tsx  # Native only
└── toast/
    └── ToastViewport.native.tsx     # Native toast positioning
```

### Component Split

```
features/
├── collection/
│   └── components/
│       ├── CollectionPanel.tsx        # Web (sidebar panel)
│       └── CollectionPanel.native.tsx # Native (bottom sheet)
└── settings/
    └── manage-subscription.web.tsx    # Web only feature
```

### Utility Split

```
utils/
├── spring.ts           # Default animation config
├── spring.web.ts       # CSS spring animations
├── imageCompression.ts # Default
└── imageCompression.web.ts  # Web-specific compression
```

## No-Op Pattern

When a feature only exists on one platform, provide a no-op for the other:

```typescript
// NativeScreenContainer/index.tsx (native)
import { useScrollToTop } from '@react-navigation/native'
export const ScrollToTopTabBarContainer = ({ children }) => {
  const ref = useRef(null)
  useScrollToTop(ref)
  return <ScrollView ref={ref}>{children}</ScrollView>
}

// NativeScreenContainer/index.web.tsx (web - no-op)
export const ScrollToTopTabBarContainer = ({ children }) => {
  return <>{children}</>
}
```

## Storage Abstraction

Handle different storage APIs:

```typescript
// In store factory
import { createJSONStorage } from 'zustand/middleware'
import AsyncStorage from '@react-native-async-storage/async-storage'

const isWeb = typeof window !== 'undefined' && !window.ReactNativeWebView

export const createAppStore = () => createStore()(
  persist(
    (set, get) => ({ /* state */ }),
    {
      name: 'app-store',
      storage: createJSONStorage(() => isWeb ? localStorage : AsyncStorage),
    }
  )
)
```

## When to Split

**Split when:**
- Different APIs (localStorage vs AsyncStorage)
- Different UI paradigms (sidebar vs bottom sheet)
- Platform-specific features (push notifications, deep links)
- Different navigation patterns

**Don't split when:**
- Only styling differences (use responsive breakpoints)
- Minor prop differences (use Platform.OS check)
- Shared business logic (keep in shared file)

## Red Flags

- Platform check in shared component that should be split
- `.native.tsx` importing from web-only package
- Missing platform file causing crash on one platform
- Duplicate logic that should be in shared file
