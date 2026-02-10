# Provider Ordering

**This is a danger zone.** Changing provider order can cause subtle bugs or crashes.

## Why Order Matters

Each provider may depend on context from providers above it:
- QueryClientProvider must wrap anything using React Query
- Store providers must wrap components using those stores
- Feature providers may depend on multiple stores

## Composition Pattern

Use a compose function to reduce nested JSX:

```typescript
const compose = (providers: React.FC<{ children: React.ReactNode }>[]) =>
  providers.reduce((Prev, Curr) => ({ children }) => {
    const Provider = Prev ? (
      <Prev>
        <Curr>{children}</Curr>
      </Prev>
    ) : (
      <Curr>{children}</Curr>
    )
    return Provider
  })

const Providers = compose([
  UniversalThemeProvider,
  SafeAreaProvider,
  TamaguiProvider,
  ToastProvider,
  QueryClientProvider,
  // ... stores in dependency order
])
```

## Recommended Order

```typescript
const providers = [
  // 1. Base providers (no dependencies)
  UniversalThemeProvider,    // Theme initialization
  SafeAreaProvider,          // Safe area context
  TelemetryProvider,         // OTEL - BEFORE API calls

  // 2. UI framework
  TamaguiProvider,           // UI components
  ToastProvider,             // Toast notifications

  // 3. Analytics
  PostHogProvider,           // Analytics

  // 4. Gates
  MaintenanceGate,           // Block app during maintenance

  // 5. Data layer
  QueryClientProvider,       // React Query - needed by tRPC

  // 6. Global stores (no cross-dependencies)
  GlobalStoreProvider,

  // 7. Feature stores (may have dependencies)
  CommentWriterStoreProvider,
  PostDraftsStoreProvider,
  TagsStoreProvider,
  AppStoreProvider,

  // 8. Prefetchers (depend on QueryClient + stores)
  ProfilePrefetcher,

  // 9. Media stores
  UploadStoreProvider,
  MusicPlayerStoreProvider,

  // 10. Orchestrators (depend on stores + QueryClient)
  ConditionalPlaybackOrchestrator,  // AFTER MusicPlayerStoreProvider

  // 11. Collection/data stores
  CollectionStoreProvider,

  // 12. Push notifications (depend on AppStore, MusicPlayer, QueryClient)
  PushNotificationProvider,

  // 13. Portal (for modals, should be last)
  PortalProvider,
]
```

## Top-Level Wrapping

Some providers need special handling and wrap the composed chain:

```typescript
export function Provider({ children, initialSession }) {
  return (
    <ClientOnlyDatePickerProvider>  {/* SSR guard */}
      <AuthProvider initialSession={initialSession}>
        <Providers>
          <InviteTokenValidationHandler />
          <ReferralCapture />
          {children}
        </Providers>
      </AuthProvider>
    </ClientOnlyDatePickerProvider>
  )
}
```

## Critical Comments

Document why specific ordering exists:

```typescript
// TelemetryProvider - Initialize OTEL before providers that make API calls
// ConditionalPlaybackOrchestrator must be AFTER MusicPlayerStoreProvider and QueryClientProvider
// PushNotificationProvider must be AFTER AppStoreProvider, MusicPlayerStoreProvider, QueryClientProvider
```

## Adding New Providers

1. Identify dependencies (what contexts does it consume?)
2. Find the lowest position that satisfies all dependencies
3. Add a comment explaining the placement
4. Test on both web and native platforms

## Red Flags

- Provider added "at the bottom" without checking dependencies
- Provider using context from a sibling (must be child)
- Missing platform-specific provider variant
- Provider that should be in compose() but is manually nested
