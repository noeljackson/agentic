# Third-Party Services Checklist

> Comprehensive list of recommended services for React Native + Supabase projects

**Priority Order:** Always prefer Supabase ecosystem services first, then proven third-party integrations.

---

## 🎯 Supabase Ecosystem (PRIORITY 1)

### Core Platform
- **Supabase** — https://supabase.com
  - [ ] Create project
  - [ ] Configure custom domain (`api.yourapp.com`)
  - [ ] Set up database schema
  - [ ] Configure RLS policies
  - [ ] Enable Realtime for live updates
  - [ ] Set up Storage buckets
  - [ ] Configure Auth providers
  - [ ] Deploy Edge Functions
  - Env vars: `EXPO_PUBLIC_SUPABASE_URL`, `EXPO_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`

### Supabase Features to Use

**Authentication Providers** (Built-in)
- [ ] Google OAuth (primary)
- [ ] Apple Sign-in (iOS requirement)
- [ ] Email/password
- [ ] Magic links
- Configuration: Supabase Dashboard → Authentication → Providers

**Edge Functions** (Serverless)
- [ ] Set up for server-side operations
- [ ] Store secrets: `npx supabase secrets set KEY=value`
- [ ] Deploy: `npx supabase functions deploy`
- Use for: webhooks, scheduled tasks, AI integrations, email sending

**Storage** (File Uploads)
- [ ] Create buckets (avatars, documents, exports, etc.)
- [ ] Configure RLS policies for storage
- [ ] Set up upload limits and allowed MIME types
- Pattern: `supabase.storage.from('bucket').upload()`

**Realtime** (Live Updates)
- [ ] Enable on tables that need live subscriptions
- [ ] Configure broadcast/presence if needed
- Pattern: `supabase.channel().on('postgres_changes')`

**Vault** (Secrets Management)
- [ ] Store sensitive data (API keys for user integrations)
- [ ] Use `pgsodium` extension for encryption
- Pattern: Store encrypted tokens per-user

**Cron** (Scheduled Jobs)
- [ ] Set up via `pg_cron` extension
- [ ] Alternative: Use Supabase Edge Functions with HTTP cron triggers
- Use for: data sync, cleanup jobs, report generation

**Database Webhooks**
- [ ] Configure for external service notifications
- [ ] Set up event triggers (INSERT, UPDATE, DELETE)
- Use for: Stripe sync, analytics, audit logs

---

## 📧 Email & Messaging (PRIORITY 2)

### Resend
- **Resend** — https://resend.com
  - [ ] Create account
  - [ ] Verify domain (SPF, DKIM, DMARC)
  - [ ] Generate API key
  - [ ] Create email templates
  - [ ] Store key in Supabase secrets: `npx supabase secrets set RESEND_API_KEY=xxx`
  - Sender format: `App Name <noreply@yourdomain.com>`
  - Pattern: Use from Edge Functions, not client-side
  - Locale support: Pass user's locale for i18n email templates

**Why Resend:**
- Developer-first, simple API
- Excellent deliverability
- React email templates supported
- Cost-effective ($20/mo for 50k emails)

---

## 🐛 Error Monitoring (PRIORITY 2)

### Sentry
- **Sentry** — https://sentry.io
  - [ ] Create organization and project
  - [ ] Get DSN from settings
  - [ ] Install packages: `@sentry/react-native`, `@sentry/browser`
  - [ ] Configure in `app/_layout.tsx` (init before other code)
  - [ ] Set up source maps for production builds
  - [ ] Enable session replay for web
  - [ ] Configure user feedback widget
  - Env var: `EXPO_PUBLIC_SENTRY_DSN`
  - Sample rate: 100% errors, 20% performance in prod

**Features to Enable:**
- Native crash reporting (iOS/Android)
- Web session replays
- Performance monitoring
- User feedback with screenshots
- EAS Update integration for OTA debugging
- Environment detection (dev/staging/production)

**Implementation Pattern:**
```typescript
// lib/sentry.ts
import * as Sentry from '@sentry/react-native';

export const initSentry = () => {
  if (__DEV__) return;
  Sentry.init({
    dsn: ENV.sentry.dsn,
    tracesSampleRate: 0.2,
    _experiments: { profilesSampleRate: 0.2 },
  });
};
```

---

## 💳 Payments (PRIORITY 2)

### Stripe
- **Stripe** — https://stripe.com
  - [ ] Create account
  - [ ] Complete business verification
  - [ ] Configure payment methods
  - [ ] Set up webhooks (stripe-webhook Edge Function)
  - [ ] Store keys in Supabase secrets
  - Env vars: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`
  - Use for: Web payments, donations, subscriptions

**Stripe Connect** (for Marketplaces)
- [ ] Enable Connect in Stripe Dashboard
- [ ] Create onboarding flow (Edge Function)
- [ ] Set up Connect webhooks
- Env var: `STRIPE_CONNECT_WEBHOOK_SECRET`
- Pattern: Instructor/seller payouts, split payments

**Webhook Security:**
- Verify signatures with `stripe.webhooks.constructEvent()`
- Use `STRIPE_WEBHOOK_SECRET` from Stripe Dashboard
- Handle idempotency (store event IDs)

### RevenueCat (Mobile IAP)
- **RevenueCat** — https://revenuecat.com
  - [ ] Create account
  - [ ] Connect App Store Connect
  - [ ] Connect Google Play Console
  - [ ] Create products/entitlements
  - [ ] Generate API keys (iOS, Android)
  - [ ] Set up webhook to Supabase Edge Function
  - Env vars: `EXPO_PUBLIC_REVENUECAT_IOS_KEY`, `EXPO_PUBLIC_REVENUECAT_ANDROID_KEY`
  - Pattern: Initialize after user profile loads with `userId`

**Why RevenueCat:**
- Abstracts App Store & Google Play APIs
- Handles receipt validation
- Subscription lifecycle management
- Analytics dashboard
- Web purchases use Stripe instead

**Implementation:**
```typescript
// lib/purchases.ts
import Purchases from 'react-native-purchases';

export const initializePurchases = async (userId: string) => {
  if (Platform.OS === 'web') return;
  Purchases.configure({
    apiKey: Platform.select({
      ios: ENV.revenueCat.iosKey,
      android: ENV.revenueCat.androidKey,
    }),
  });
  await Purchases.logIn(userId);
};
```

---

## 🎥 Video Hosting (PRIORITY 3)

### Vimeo
- **Vimeo** — https://vimeo.com
  - [ ] Create account (Advanced plan recommended: $75/mo annual, 7TB storage)
  - [ ] Generate access token (Settings → Apps → New app)
  - [ ] Configure privacy: Private videos only
  - [ ] Set domain whitelist (your domain only)
  - [ ] Disable Vimeo.com viewing
  - [ ] Store keys in Supabase secrets
  - Env vars: `VIMEO_ACCESS_TOKEN`, `VIMEO_CLIENT_ID`, `VIMEO_CLIENT_SECRET`

**Features:**
- TUS chunked upload protocol for large files
- Private embed-only mode
- Domain locking (prevent unauthorized embedding)
- Custom player controls
- Video analytics

**Implementation Pattern:**
```typescript
// Edge Function: vimeo-upload/index.ts
// 1. Init upload: POST /me/videos (get upload link)
// 2. TUS upload: PATCH with chunks
// 3. Complete: Check transcode status
// 4. Store video_id in database
```

**Brand Settings:**
- Disable share button
- Disable like button
- Disable watch-later button
- Custom embed player color

### YouTube (Read-Only)
- **YouTube Data API** — https://console.cloud.google.com
  - [ ] Enable YouTube Data API v3
  - [ ] Generate API key
  - [ ] Store in Supabase secrets: `YOUTUBE_API_KEY`
  - Use for: Public video fetching, channel presence
  - Rate limit: 10,000 quota units/day

---

## 🏃 Wearables & Health Data (PRIORITY 3)

### Whoop
- **Whoop** — https://developer.whoop.com
  - [ ] Apply for developer access
  - [ ] Create OAuth application
  - [ ] Configure redirect URI: `https://api.yourapp.com/functions/v1/whoop-callback`
  - [ ] Generate client ID and secret
  - [ ] Store in Supabase secrets
  - Env vars: `WHOOP_CLIENT_ID`, `WHOOP_CLIENT_SECRET`, `WHOOP_REDIRECT_URI`

**Security Requirements:**
- CSRF protection: Sign `state` parameter with HMAC-SHA256
- Return URL validation (prevent open redirects)
- Token storage in Supabase Vault (per-user)

**Integration Pattern:**
- OAuth flow: auth → callback → token exchange → sync
- Debounced sync: 2+ hour minimum between syncs
- Cron job: Daily sync for active users
- Display: Recovery score with brand-compliant color coding

**Brand Guidelines:**
- See Whoop Brand Design Guidelines (PDF from developer portal)
- Use approved colors for recovery zones
- Don't modify Whoop logo

---

## 🤖 Artificial Intelligence (PRIORITY 3)

### Anthropic Claude
- **Anthropic** — https://console.anthropic.com
  - [ ] Create account
  - [ ] Generate API key
  - [ ] Store in Supabase secrets: `ANTHROPIC_API_KEY`
  - [ ] Set up rate limiting (per-user, per-day)
  - [ ] Configure input validation (profanity, prompt injection)
  - Model: `claude-3-5-sonnet-20241022` (recommended)

**Use Cases:**
- AI chat with RAG (retrieval-augmented generation)
- Text improvement/translation
- Content generation
- Data parsing

**Implementation Pattern:**
```typescript
// Edge Function: ai-chat/index.ts
const response = await fetch('https://api.anthropic.com/v1/messages', {
  method: 'POST',
  headers: {
    'x-api-key': ANTHROPIC_API_KEY,
    'anthropic-version': '2023-06-01',
  },
  body: JSON.stringify({
    model: 'claude-3-5-sonnet-20241022',
    max_tokens: 1024,
    messages: [{ role: 'user', content: userMessage }],
  }),
});
```

**Security:**
- Rate limiting: DAILY_MESSAGE_LIMIT, REQUESTS_PER_MINUTE
- Input sanitization: Remove profanity, check for prompt injection
- User context injection: Belt rank, history, preferences
- Language matching: Respond in user's input language

### Voyage AI (Embeddings)
- **Voyage AI** — https://voyageai.com
  - [ ] Create account
  - [ ] Generate API key
  - [ ] Store in Supabase secrets: `VOYAGE_API_KEY`
  - Model: `voyage-3-lite` (512 dims, $0.02/1M tokens, Anthropic recommended)
  - Use for: RAG embeddings, semantic search

**Integration:**
```typescript
const embedding = await fetch('https://api.voyageai.com/v1/embeddings', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${VOYAGE_API_KEY}` },
  body: JSON.stringify({
    input: [text],
    model: 'voyage-3-lite',
  }),
});
```

---

## 📱 Push Notifications (PRIORITY 3)

### Expo Push Notifications
- **Expo** — https://expo.dev
  - [ ] Configure in `app.json` → `expo.notification`
  - [ ] Generate access token: `npx eas-cli build:configure`
  - [ ] Store in Supabase secrets: `EXPO_ACCESS_TOKEN`
  - [ ] Store device tokens in database
  - Pattern: Send from Edge Function using Expo Push API

**Implementation:**
```typescript
// Edge Function: send-push/index.ts
await fetch('https://exp.host/--/api/v2/push/send', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${EXPO_ACCESS_TOKEN}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    to: deviceToken,
    title: 'Notification Title',
    body: 'Message body',
  }),
});
```

---

## 🏗️ Build & Deployment (PRIORITY 1)

### EAS (Expo Application Services)
- **EAS** — https://expo.dev
  - [ ] Create Expo account
  - [ ] Install EAS CLI: `npm install -g eas-cli`
  - [ ] Configure `eas.json` (build profiles)
  - [ ] Set up credentials (iOS & Android)
  - [ ] Configure OTA updates
  - Profiles: development, preview, production

**Build Configuration:**
```json
{
  "build": {
    "production": {
      "node": "20.18.0",
      "channel": "production",
      "ios": { "autoIncrement": "buildNumber" },
      "android": { "autoIncrement": "versionCode" }
    }
  }
}
```

### App Store Connect (iOS)
- **Apple** — https://appstoreconnect.apple.com
  - [ ] Enroll in Apple Developer Program ($99/year)
  - [ ] Create app record
  - [ ] Configure App Store listing
  - [ ] Set up TestFlight for beta testing
  - [ ] Generate provisioning profiles
  - [ ] Configure push notification certificates

### Google Play Console (Android)
- **Google** — https://play.google.com/console
  - [ ] Create developer account ($25 one-time)
  - [ ] Create app
  - [ ] Set up Play Store listing
  - [ ] Configure internal testing track
  - [ ] Generate service account JSON for automated publishing
  - [ ] Configure in-app products (if using)

---

## 🔥 Optional Services

### Firebase
- **Firebase** — https://console.firebase.google.com
  - [ ] Create project
  - [ ] Add iOS app (download GoogleService-Info.plist)
  - [ ] Add Android app (download google-services.json)
  - [ ] Enable Analytics (optional)
  - Project ID stored in config files

**When to Use:**
- Push notifications (alternative to Expo)
- Analytics (alternative to custom tables)
- Dynamic links (deep linking)
- Remote config (feature flags)

**Note:** If using Supabase, Firebase features may be redundant.

### Google Cloud (Monitoring/Alerting)
- **Google Cloud Console** — https://console.cloud.google.com
  - [ ] Create project (can reuse Firebase project)
  - [ ] Enable Cloud Monitoring API
  - [ ] Set up alert policies
  - [ ] Configure uptime checks
  - Use for: API monitoring, error rate alerts, uptime

### GitHub
- **GitHub** — https://github.com
  - [ ] Create organization (for team projects)
  - [ ] Set up repository
  - [ ] Configure branch protection rules
  - [ ] Set up Actions for CI/CD (optional)
  - [ ] Configure secrets for deployment
  - Pattern: PR reviews, issue tracking, project boards

---

## 🔐 Security & Compliance

### Environment Variable Strategy

**Public Variables** (safe to expose, in `.env.local`)
```bash
EXPO_PUBLIC_SUPABASE_URL=
EXPO_PUBLIC_SUPABASE_ANON_KEY=
EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID=
EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID=
EXPO_PUBLIC_GOOGLE_ANDROID_CLIENT_ID=
EXPO_PUBLIC_REVENUECAT_IOS_KEY=
EXPO_PUBLIC_REVENUECAT_ANDROID_KEY=
EXPO_PUBLIC_SENTRY_DSN=
```

**Server Secrets** (Supabase Edge Functions only)
```bash
# Set via: npx supabase secrets set KEY=value
SUPABASE_SERVICE_ROLE_KEY=
ANTHROPIC_API_KEY=
VOYAGE_API_KEY=
WHOOP_CLIENT_ID=
WHOOP_CLIENT_SECRET=
VIMEO_ACCESS_TOKEN=
VIMEO_CLIENT_ID=
VIMEO_CLIENT_SECRET=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_CONNECT_WEBHOOK_SECRET=
RESEND_API_KEY=
EXPO_ACCESS_TOKEN=
YOUTUBE_API_KEY=
TOKEN_ENCRYPTION_KEY=  # For CSRF protection (generate random)
```

### Security Checklist

- [ ] All webhooks verify signatures (Stripe, RevenueCat, etc.)
- [ ] OAuth flows use CSRF protection (signed state parameter)
- [ ] Redirect URLs validated (prevent open redirects)
- [ ] Rate limiting on AI/expensive operations
- [ ] Input validation (profanity, prompt injection)
- [ ] RLS policies on all Supabase tables
- [ ] Server secrets never exposed to client
- [ ] iOS SecureStore used for tokens (chunked if >2048 bytes)
- [ ] Sentry PII scrubbing enabled
- [ ] Domain privacy on embedded content (Vimeo)

---

## 📋 Setup Sequence

**Recommended Order:**

1. **Supabase** (FIRST)
   - Create project, set up schema, configure RLS
   - Enable Realtime, Storage, Auth providers

2. **Authentication**
   - Configure Google OAuth in Supabase
   - Set up Apple Sign-in (iOS requirement)

3. **Email**
   - Set up Resend, verify domain

4. **Error Monitoring**
   - Configure Sentry, deploy with source maps

5. **Payments**
   - Stripe (web), RevenueCat (mobile)

6. **Build/Deploy**
   - EAS, App Store Connect, Google Play Console

7. **Optional Services**
   - Video (Vimeo), AI (Anthropic, Voyage), wearables (Whoop)

---

## 🔗 Documentation References

Create these files in your project:
- `docs/_PLATFORM_ACCOUNTS.md` — Complete setup guide for all services
- `docs/_OAUTH_CONFIG.md` — OAuth flows and security notes
- `docs/_FRAGILE.md` — Document dangers with payment flows, RLS, webhooks
- `docs/_DEV_SETUP.md` — Local environment setup for new developers

**External Resources:**
- Supabase docs: https://supabase.com/docs
- Resend docs: https://resend.com/docs
- Sentry React Native: https://docs.sentry.io/platforms/react-native
- Stripe API: https://stripe.com/docs/api
- RevenueCat: https://docs.revenuecat.com
- Expo: https://docs.expo.dev

---

## 💡 Key Patterns from Production

**1. Centralized Configuration**
```typescript
// lib/config/env.ts
export const ENV = {
  supabase: { url: required('EXPO_PUBLIC_SUPABASE_URL'), ... },
  google: { clientId: required('EXPO_PUBLIC_GOOGLE_CLIENT_ID'), ... },
  // Never access process.env.EXPO_PUBLIC_* outside this file
};
```

**2. Initialization Order**
```typescript
// app/_layout.tsx
initSentry();                    // FIRST (catch early errors)
i18n.init();                     // i18n setup
// ... load fonts
<AuthProvider>                   // Supabase session
  <QueryClientProvider>          // TanStack Query
    <OrganizationProvider>       // Multi-tenant context
      {children}
    </OrganizationProvider>
  </QueryClientProvider>
</AuthProvider>
```

**3. Webhook Verification**
```typescript
// Stripe webhook
const sig = request.headers.get('stripe-signature');
const event = stripe.webhooks.constructEvent(body, sig, webhookSecret);

// Whoop OAuth CSRF
const state = createHmac('sha256', encryptionKey)
  .update(userId)
  .digest('hex');
```

**4. Rate Limiting**
```typescript
// AI chat
const DAILY_MESSAGE_LIMIT = 50;
const REQUESTS_PER_MINUTE = 5;

const count = await supabase
  .from('ai_messages')
  .select('id', { count: 'exact' })
  .eq('user_id', userId)
  .gte('created_at', today);

if (count >= DAILY_MESSAGE_LIMIT) {
  return new Response('Rate limit exceeded', { status: 429 });
}
```

**5. Secure Token Storage (iOS)**
```typescript
// lib/supabase.ts
class ExpoSecureStoreAdapter {
  async getItem(key: string) {
    // iOS has 2048-byte limit
    const chunks = [];
    for (let i = 0; i < 10; i++) {
      const chunk = await SecureStore.getItemAsync(`${key}-${i}`);
      if (!chunk) break;
      chunks.push(chunk);
    }
    return chunks.join('');
  }
}
```

---

This checklist is based on production patterns from a 180,000-line codebase with 30+ Edge Functions and 15+ third-party integrations.
