# Project Initiation: Data Architecture Setup

## Context

This project uses:
- TypeScript + React Native (Expo/EAS) targeting web, iOS, Android
- Supabase (Postgres, RLS, Vault, Realtime)
- Google OAuth
- TanStack Query

**Core principle**: Single source of truth. All projection/model data flows from database → `/lib/models` → hooks → components. No hardcoded data in UI files.

---

## Phase 1: Database Schema

### 1.1 Create Core Tables

```sql
-- Claims: verified data points with sources
-- All timestamps use timestamptz (never timestamp)
CREATE TABLE IF NOT EXISTS claims (
    id VARCHAR(100) PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    statement TEXT NOT NULL,
    value NUMERIC,
    unit VARCHAR(50),
    status VARCHAR(20) CHECK (status IN ('verified','cited','derived','estimated','speculative')),
    confidence VARCHAR(10) CHECK (confidence IN ('high','medium','low')),
    source_org VARCHAR(200),
    source_url TEXT,
    source_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scenarios: model configuration
CREATE TABLE IF NOT EXISTS scenarios (
    id VARCHAR(50) PRIMARY KEY,
    type VARCHAR(20) NOT NULL CHECK (type IN ('demand','supply','efficiency')),
    label VARCHAR(100) NOT NULL,
    short_label VARCHAR(20),
    description TEXT,
    parameters JSONB NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Projections: cached/pre-computed model outputs
CREATE TABLE IF NOT EXISTS projections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_id VARCHAR(50) REFERENCES scenarios(id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    metric VARCHAR(50) NOT NULL,
    value NUMERIC NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(scenario_id, year, metric)
);

-- Audit trail for claim changes
CREATE TABLE IF NOT EXISTS claim_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id VARCHAR(100) REFERENCES claims(id) ON DELETE CASCADE,
    changed_by UUID REFERENCES auth.users(id),
    old_value JSONB,
    new_value JSONB,
    changed_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 1.2 RLS Policies

```sql
-- Claims: public read, authenticated write
ALTER TABLE claims ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Claims are viewable by everyone"
    ON claims FOR SELECT
    USING (true);

CREATE POLICY "Claims are editable by authenticated users"
    ON claims FOR ALL
    USING (auth.role() = 'authenticated');

-- Scenarios: public read, authenticated write
ALTER TABLE scenarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Scenarios are viewable by everyone"
    ON scenarios FOR SELECT
    USING (true);

CREATE POLICY "Scenarios are editable by authenticated users"
    ON scenarios FOR ALL
    USING (auth.role() = 'authenticated');

-- Projections: public read, authenticated write
ALTER TABLE projections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Projections are viewable by everyone"
    ON projections FOR SELECT
    USING (true);

CREATE POLICY "Projections are editable by authenticated users"
    ON projections FOR ALL
    USING (auth.role() = 'authenticated');
```

### 1.3 Helper Functions (SECURITY DEFINER for cross-table queries)

```sql
-- Get claim with latest history (avoids RLS nesting issues)
CREATE OR REPLACE FUNCTION get_claim_with_history(claim_id_param VARCHAR)
RETURNS TABLE (
    id VARCHAR,
    category VARCHAR,
    value NUMERIC,
    last_changed_at TIMESTAMPTZ,
    change_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.category,
        c.value,
        MAX(h.changed_at) as last_changed_at,
        COUNT(h.id) as change_count
    FROM claims c
    LEFT JOIN claim_history h ON c.id = h.claim_id
    WHERE c.id = claim_id_param
    GROUP BY c.id, c.category, c.value;
END;
$$;
```

---

## Phase 2: /lib Structure

### 2.1 Directory Structure

```
lib/
├── supabase/
│   ├── client.ts           # Supabase client (single instance)
│   ├── types.ts            # Generated types from Supabase
│   └── queries/
│       ├── claims.ts       # Claim queries
│       ├── scenarios.ts    # Scenario queries
│       └── keys.ts         # TanStack Query key factories
├── constants/
│   ├── terminology.ts      # Neutral scenario names
│   └── units.ts            # Formatters (formatTokens, etc.)
├── models/
│   ├── types.ts            # Shared interfaces
│   ├── assumptions.ts      # Authoritative values (from DB with fallbacks)
│   ├── supply.ts           # Supply calculations
│   └── demand.ts           # Demand calculations
└── hooks/
    ├── useClaims.ts        # TanStack Query wrapper for claims
    ├── useScenarios.ts     # TanStack Query wrapper for scenarios
    └── useProjections.ts   # Combined model hook
```

### 2.2 Create `/lib/supabase/client.ts`

```typescript
import { createClient } from '@supabase/supabase-js';
import { Database } from './types';
import Config from '@/config'; // Centralized config, never process.env directly

const supabaseUrl = Config.SUPABASE_URL;
const supabaseAnonKey = Config.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey);

export default supabase;
```

### 2.3 Create `/lib/supabase/queries/keys.ts`

```typescript
/**
 * TanStack Query key factories
 * All query keys defined here - no string literals in components
 */

export const claimKeys = {
  all: ['claims'] as const,
  lists: () => [...claimKeys.all, 'list'] as const,
  list: (filters: { category?: string }) => [...claimKeys.lists(), filters] as const,
  details: () => [...claimKeys.all, 'detail'] as const,
  detail: (id: string) => [...claimKeys.details(), id] as const,
};

export const scenarioKeys = {
  all: ['scenarios'] as const,
  lists: () => [...scenarioKeys.all, 'list'] as const,
  list: (type?: string) => [...scenarioKeys.lists(), { type }] as const,
  details: () => [...scenarioKeys.all, 'detail'] as const,
  detail: (id: string) => [...scenarioKeys.details(), id] as const,
  defaults: () => [...scenarioKeys.all, 'defaults'] as const,
};

export const projectionKeys = {
  all: ['projections'] as const,
  byScenario: (scenarioId: string) => [...projectionKeys.all, scenarioId] as const,
  byYear: (year: number) => [...projectionKeys.all, 'year', year] as const,
};
```

### 2.4 Create `/lib/supabase/queries/claims.ts`

```typescript
import supabase from '../client';
import type { Database } from '../types';

type Claim = Database['public']['Tables']['claims']['Row'];
type ClaimInsert = Database['public']['Tables']['claims']['Insert'];
type ClaimUpdate = Database['public']['Tables']['claims']['Update'];

export async function getClaims(category?: string): Promise<Claim[]> {
  let query = supabase
    .from('claims')
    .select('*')
    .order('category', { ascending: true });

  if (category) {
    query = query.eq('category', category);
  }

  const { data, error } = await query;

  if (error) {
    throw new Error(`Failed to fetch claims: ${error.message}`);
  }

  return data ?? [];
}

export async function getClaim(id: string): Promise<Claim | null> {
  const { data, error } = await supabase
    .from('claims')
    .select('*')
    .eq('id', id)
    .single();

  if (error && error.code !== 'PGRST116') {
    throw new Error(`Failed to fetch claim: ${error.message}`);
  }

  return data;
}

export async function getClaimValue(id: string): Promise<number | null> {
  const claim = await getClaim(id);
  return claim?.value ?? null;
}

export async function upsertClaim(claim: ClaimInsert): Promise<Claim> {
  const { data, error } = await supabase
    .from('claims')
    .upsert(claim, { onConflict: 'id' })
    .select()
    .single();

  if (error) {
    throw new Error(`Failed to upsert claim: ${error.message}`);
  }

  return data;
}

export async function updateClaim(id: string, updates: ClaimUpdate): Promise<Claim> {
  const { data, error } = await supabase
    .from('claims')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();

  if (error) {
    throw new Error(`Failed to update claim: ${error.message}`);
  }

  return data;
}
```

### 2.5 Create `/lib/hooks/useClaims.ts`

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { claimKeys } from '../supabase/queries/keys';
import { getClaims, getClaim, updateClaim } from '../supabase/queries/claims';
import type { Database } from '../supabase/types';

type Claim = Database['public']['Tables']['claims']['Row'];
type ClaimUpdate = Database['public']['Tables']['claims']['Update'];

export function useClaims(category?: string) {
  return useQuery({
    queryKey: claimKeys.list({ category }),
    queryFn: () => getClaims(category),
  });
}

export function useClaim(id: string) {
  return useQuery({
    queryKey: claimKeys.detail(id),
    queryFn: () => getClaim(id),
    enabled: Boolean(id),
  });
}

export function useUpdateClaim() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, updates }: { id: string; updates: ClaimUpdate }) =>
      updateClaim(id, updates),

    // Optimistic update with rollback
    onMutate: async ({ id, updates }) => {
      await queryClient.cancelQueries({ queryKey: claimKeys.detail(id) });

      const previous = queryClient.getQueryData<Claim>(claimKeys.detail(id));

      queryClient.setQueryData<Claim>(claimKeys.detail(id), (old) =>
        old ? { ...old, ...updates } : old
      );

      return { previous, id };
    },

    onError: (_err, _vars, context) => {
      if (context?.previous) {
        queryClient.setQueryData(claimKeys.detail(context.id), context.previous);
      }
    },

    onSettled: (_data, _error, { id }) => {
      queryClient.invalidateQueries({ queryKey: claimKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: claimKeys.lists() });
    },
  });
}
```

### 2.6 Create `/lib/constants/terminology.ts`

```typescript
/**
 * Neutral terminology for scenarios
 * Never use "aggressive" or "conservative"
 */

export const DEMAND_SCENARIOS = {
  baseline: {
    id: 'demand-baseline',
    label: 'Current Trajectory',
    short: 'Baseline',
  },
  high: {
    id: 'demand-high',
    label: 'High Adoption',
    short: 'High',
  },
  full: {
    id: 'demand-full',
    label: 'Full Deployment',
    short: 'Full',
  },
} as const;

export const EFFICIENCY_SCENARIOS = {
  baseline: {
    id: 'eff-baseline',
    label: 'Baseline Trajectory',
    short: '100×',
    multiplier: 100,
  },
  accelerated: {
    id: 'eff-accelerated',
    label: 'Accelerated',
    short: '500×',
    multiplier: 500,
  },
  sustained: {
    id: 'eff-sustained',
    label: 'Sustained Rate',
    short: '1000×',
    multiplier: 1000,
  },
} as const;

export const SUPPLY_SCENARIOS = {
  baseline: {
    id: 'supply-baseline',
    label: 'Current Build Rate',
    short: 'Baseline',
    growthRate: 0.25,
  },
  accelerated: {
    id: 'supply-accelerated',
    label: 'Accelerated Build',
    short: 'Accelerated',
    growthRate: 0.35,
  },
  maximum: {
    id: 'supply-maximum',
    label: 'Maximum Feasible',
    short: 'Maximum',
    growthRate: 0.45,
  },
} as const;

export type DemandScenarioKey = keyof typeof DEMAND_SCENARIOS;
export type EfficiencyScenarioKey = keyof typeof EFFICIENCY_SCENARIOS;
export type SupplyScenarioKey = keyof typeof SUPPLY_SCENARIOS;
```

### 2.7 Create `/lib/constants/units.ts`

```typescript
/**
 * Standardized formatting functions
 * Import these - never define locally in components
 */

export function formatTokens(value: number, precision = 1): string {
  if (value >= 1e21) return `${(value / 1e21).toFixed(precision)} Sx`;
  if (value >= 1e18) return `${(value / 1e18).toFixed(precision)} Qn`;
  if (value >= 1e15) return `${(value / 1e15).toFixed(precision)} Qd`;
  if (value >= 1e12) return `${(value / 1e12).toFixed(precision)} T`;
  if (value >= 1e9) return `${(value / 1e9).toFixed(precision)} B`;
  if (value >= 1e6) return `${(value / 1e6).toFixed(precision)} M`;
  return value.toLocaleString();
}

export function formatTokensShort(value: number): string {
  if (value >= 1e21) return `${(value / 1e21).toFixed(0)}Sx`;
  if (value >= 1e18) return `${(value / 1e18).toFixed(0)}Qn`;
  if (value >= 1e15) return `${(value / 1e15).toFixed(0)}Qd`;
  if (value >= 1e12) return `${(value / 1e12).toFixed(0)}T`;
  return `${(value / 1e9).toFixed(0)}B`;
}

export function formatPower(gw: number): string {
  if (gw >= 1000) return `${(gw / 1000).toFixed(1)} TW`;
  if (gw >= 1) return `${gw.toFixed(0)} GW`;
  return `${(gw * 1000).toFixed(0)} MW`;
}

export function formatPopulation(n: number): string {
  if (n >= 1e9) return `${(n / 1e9).toFixed(1)}B`;
  if (n >= 1e6) return `${(n / 1e6).toFixed(0)}M`;
  if (n >= 1e3) return `${(n / 1e3).toFixed(0)}K`;
  return `${n}`;
}

export function formatPercent(ratio: number, precision = 1): string {
  return `${(ratio * 100).toFixed(precision)}%`;
}

export function formatCurrency(value: number, currency = 'USD'): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
    notation: value >= 1e9 ? 'compact' : 'standard',
    maximumFractionDigits: value >= 1e6 ? 1 : 0,
  }).format(value);
}
```

### 2.8 Create `/lib/models/assumptions.ts`

```typescript
import { getClaimValue } from '../supabase/queries/claims';

/**
 * SINGLE SOURCE OF TRUTH
 *
 * Values load from database with fallbacks.
 * Fallbacks used for: SSR, offline, DB errors.
 */

// Fallback values (used if DB unavailable)
const FALLBACK = {
  capacityGW: 6,
  tokensPerMWh: 2.7e8,
  utilizationRate: 0.80,
  inferenceShare: 0.35,
  internetUsers: 5.4e9,
  knowledgeWorkers: 4e8,
  developers: 3e7,
} as const;

// Sync version for client-side (uses fallbacks)
export const BASELINE = {
  year: 2024,
  capacityGW: FALLBACK.capacityGW,
  tokensPerMWh: FALLBACK.tokensPerMWh,
  utilizationRate: FALLBACK.utilizationRate,
  inferenceShare: FALLBACK.inferenceShare,
  internetUsers: FALLBACK.internetUsers,
  knowledgeWorkers: FALLBACK.knowledgeWorkers,
  developers: FALLBACK.developers,
} as const;

export const USAGE = {
  human: {
    baseline: 30_000,      // tokens/day - typical user
    intensive: 2_000_000,  // tokens/day - heavy user
  },
  agent: {
    baseline: 250_000,     // tokens/day - narrow agent
    intensive: 10_000_000, // tokens/day - continuous agent
  },
} as const;

export const ADOPTION = {
  midpoint: 2028,
  steepness: 0.8,
  maturationRate: 0.30,
} as const;

export const HOURS_PER_YEAR = 8760;

// Async loader from DB (for server-side or initial load)
export async function loadBaselineFromDB(): Promise<typeof BASELINE> {
  try {
    const [cap, eff, util, inf, pop] = await Promise.all([
      getClaimValue('cap-2024'),
      getClaimValue('eff-h100-2024'),
      getClaimValue('util-rate'),
      getClaimValue('inference-share'),
      getClaimValue('pop-internet'),
    ]);

    return {
      year: 2024,
      capacityGW: cap ?? FALLBACK.capacityGW,
      tokensPerMWh: eff ?? FALLBACK.tokensPerMWh,
      utilizationRate: util ?? FALLBACK.utilizationRate,
      inferenceShare: inf ?? FALLBACK.inferenceShare,
      internetUsers: pop ?? FALLBACK.internetUsers,
      knowledgeWorkers: FALLBACK.knowledgeWorkers,
      developers: FALLBACK.developers,
    };
  } catch (error) {
    console.error('Failed to load baseline from DB, using fallbacks:', error);
    return BASELINE;
  }
}
```

---

## Phase 3: Verification Script

### Create `/scripts/verify-architecture.ts`

```typescript
#!/usr/bin/env npx ts-node

/**
 * Verify data architecture integrity
 * Run after refactoring or when adding new files
 */

import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

const ANALYSIS_DIR = './analysis';
const COMPONENTS_DIR = './components';

interface VerificationResult {
  pass: boolean;
  issues: string[];
}

function checkNoLocalFormatters(): VerificationResult {
  const issues: string[] = [];

  try {
    const result = execSync(
      `grep -rn "function formatTokens\\|function formatPower\\|function formatPopulation" --include="*.tsx" --include="*.ts" . | grep -v "/lib/" | grep -v "node_modules"`,
      { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }
    );

    if (result.trim()) {
      result.trim().split('\n').forEach(line => {
        issues.push(`Local formatter found: ${line}`);
      });
    }
  } catch {
    // grep returns non-zero if no matches - that's good
  }

  return { pass: issues.length === 0, issues };
}

function checkNoHardcodedProjections(): VerificationResult {
  const issues: string[] = [];
  const pattern = /year:\s*['"]?202[5-9]|year:\s*['"]?203[0-5]/;

  const dirs = [ANALYSIS_DIR, COMPONENTS_DIR].filter(fs.existsSync);

  dirs.forEach(dir => {
    const files = fs.readdirSync(dir).filter(f => f.endsWith('.tsx'));

    files.forEach(file => {
      const content = fs.readFileSync(path.join(dir, file), 'utf8');
      const lines = content.split('\n');

      lines.forEach((line, i) => {
        if (pattern.test(line) && !line.includes('// historical')) {
          issues.push(`${file}:${i + 1} - Possible hardcoded projection: ${line.trim().slice(0, 60)}`);
        }
      });
    });
  });

  return { pass: issues.length === 0, issues };
}

function checkNoProblematicTerminology(): VerificationResult {
  const issues: string[] = [];

  try {
    const result = execSync(
      `grep -rni "aggressive\\|conservative" --include="*.tsx" --include="*.ts" . | grep -v "node_modules" | grep -v ".git"`,
      { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }
    );

    if (result.trim()) {
      result.trim().split('\n').forEach(line => {
        if (!line.includes('// legacy') && !line.includes('CHANGELOG')) {
          issues.push(`Problematic terminology: ${line}`);
        }
      });
    }
  } catch {
    // No matches - good
  }

  return { pass: issues.length === 0, issues };
}

function checkLibImports(): VerificationResult {
  const issues: string[] = [];

  if (!fs.existsSync(ANALYSIS_DIR)) {
    return { pass: true, issues: [] };
  }

  const files = fs.readdirSync(ANALYSIS_DIR).filter(f => f.endsWith('.tsx'));

  files.forEach(file => {
    const content = fs.readFileSync(path.join(ANALYSIS_DIR, file), 'utf8');

    // Check if file uses projections but doesn't import from lib
    const usesProjections = /supply|demand|tokens|capacity/i.test(content);
    const importsFromLib = /from\s+['"]@?\/lib|from\s+['"]\.\.\/lib/.test(content);

    if (usesProjections && !importsFromLib) {
      issues.push(`${file} - Uses projection concepts but doesn't import from /lib`);
    }
  });

  return { pass: issues.length === 0, issues };
}

// Run all checks
console.log('🔍 Verifying data architecture...\n');

const checks = [
  { name: 'No local formatters', fn: checkNoLocalFormatters },
  { name: 'No hardcoded projections', fn: checkNoHardcodedProjections },
  { name: 'No problematic terminology', fn: checkNoProblematicTerminology },
  { name: 'Lib imports present', fn: checkLibImports },
];

let allPass = true;

checks.forEach(({ name, fn }) => {
  const result = fn();
  const status = result.pass ? '✅' : '❌';
  console.log(`${status} ${name}`);

  if (!result.pass) {
    allPass = false;
    result.issues.forEach(issue => console.log(`   └─ ${issue}`));
  }
});

console.log('\n' + (allPass ? '✅ All checks passed' : '❌ Issues found - see above'));

process.exit(allPass ? 0 : 1);
```

---

## Phase 4: Seed Script

### Create `/scripts/seed-claims.ts`

```typescript
#!/usr/bin/env npx ts-node

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

const CLAIMS = [
  // Infrastructure
  {
    id: 'cap-2024',
    category: 'infrastructure',
    statement: 'Global AI datacenter capacity',
    value: 6,
    unit: 'GW',
    status: 'cited',
    confidence: 'high',
    source_org: 'IEA',
    notes: 'AI-dedicated capacity only',
  },
  {
    id: 'util-rate',
    category: 'infrastructure',
    statement: 'Average datacenter utilization',
    value: 0.80,
    unit: 'ratio',
    status: 'estimated',
    confidence: 'medium',
    source_org: 'Industry average',
  },
  {
    id: 'inference-share',
    category: 'infrastructure',
    statement: 'Inference share of AI compute',
    value: 0.35,
    unit: 'ratio',
    status: 'estimated',
    confidence: 'low',
    source_org: 'SemiAnalysis',
    notes: 'Training ~65%',
  },

  // Efficiency
  {
    id: 'eff-h100-2024',
    category: 'efficiency',
    statement: 'H100 inference efficiency',
    value: 2.7e8,
    unit: 'tokens/MWh',
    status: 'derived',
    confidence: 'medium',
    source_org: 'NVIDIA specs',
  },

  // Population
  {
    id: 'pop-internet',
    category: 'population',
    statement: 'Global internet users',
    value: 5.4e9,
    unit: 'people',
    status: 'verified',
    confidence: 'high',
    source_org: 'ITU',
    notes: '2024 estimate',
  },
  {
    id: 'pop-knowledge',
    category: 'population',
    statement: 'Knowledge workers globally',
    value: 4e8,
    unit: 'people',
    status: 'cited',
    confidence: 'medium',
    source_org: 'McKinsey',
  },
  {
    id: 'pop-developers',
    category: 'population',
    statement: 'Software developers globally',
    value: 3e7,
    unit: 'people',
    status: 'cited',
    confidence: 'high',
    source_org: 'GitHub',
    notes: '2024 survey',
  },
];

const SCENARIOS = [
  // Demand
  { id: 'demand-baseline', type: 'demand', label: 'Current Trajectory', short_label: 'Baseline', parameters: { ceiling: 0.5, maturation_boost: 1.0 }, is_default: true },
  { id: 'demand-high', type: 'demand', label: 'High Adoption', short_label: 'High', parameters: { ceiling: 0.7, maturation_boost: 1.2 }, is_default: false },
  { id: 'demand-full', type: 'demand', label: 'Full Deployment', short_label: 'Full', parameters: { ceiling: 0.85, maturation_boost: 1.5 }, is_default: false },

  // Efficiency
  { id: 'eff-baseline', type: 'efficiency', label: 'Baseline Trajectory', short_label: '100×', parameters: { multiplier_2035: 100 }, is_default: true },
  { id: 'eff-accelerated', type: 'efficiency', label: 'Accelerated', short_label: '500×', parameters: { multiplier_2035: 500 }, is_default: false },
  { id: 'eff-sustained', type: 'efficiency', label: 'Sustained Rate', short_label: '1000×', parameters: { multiplier_2035: 1000 }, is_default: false },

  // Supply
  { id: 'supply-baseline', type: 'supply', label: 'Current Build Rate', short_label: 'Baseline', parameters: { annual_growth: 0.25 }, is_default: true },
  { id: 'supply-accelerated', type: 'supply', label: 'Accelerated Build', short_label: 'Accelerated', parameters: { annual_growth: 0.35 }, is_default: false },
  { id: 'supply-maximum', type: 'supply', label: 'Maximum Feasible', short_label: 'Maximum', parameters: { annual_growth: 0.45 }, is_default: false },
];

async function seed() {
  console.log('Seeding claims...');

  const { error: claimsError } = await supabase
    .from('claims')
    .upsert(CLAIMS, { onConflict: 'id' });

  if (claimsError) {
    console.error('Failed to seed claims:', claimsError);
    process.exit(1);
  }

  console.log(`✅ Seeded ${CLAIMS.length} claims`);

  console.log('Seeding scenarios...');

  const { error: scenariosError } = await supabase
    .from('scenarios')
    .upsert(SCENARIOS, { onConflict: 'id' });

  if (scenariosError) {
    console.error('Failed to seed scenarios:', scenariosError);
    process.exit(1);
  }

  console.log(`✅ Seeded ${SCENARIOS.length} scenarios`);

  console.log('\n✅ Seeding complete');
}

seed().catch(console.error);
```

---

## Checklist

### Database
- [ ] Tables created (claims, scenarios, projections, claim_history)
- [ ] RLS policies applied
- [ ] Helper functions created
- [ ] Seed data inserted

### /lib Structure
- [ ] `/lib/supabase/client.ts` - single Supabase instance
- [ ] `/lib/supabase/queries/keys.ts` - TanStack Query key factories
- [ ] `/lib/supabase/queries/claims.ts` - claim CRUD
- [ ] `/lib/constants/terminology.ts` - neutral scenario names
- [ ] `/lib/constants/units.ts` - formatters
- [ ] `/lib/models/assumptions.ts` - authoritative values
- [ ] `/lib/hooks/useClaims.ts` - React Query wrapper

### Scripts
- [ ] `/scripts/verify-architecture.ts` - verification checks
- [ ] `/scripts/seed-claims.ts` - initial data

### Verification
- [ ] `npx ts-node scripts/verify-architecture.ts` passes
- [ ] No `formatTokens` outside `/lib`
- [ ] No "aggressive/conservative" terminology
- [ ] All visualization files import from `/lib`

---

## Using This Template

### For New Projects

1. Copy this file to your project root
2. Run Phase 1 SQL in Supabase SQL Editor
3. Create the `/lib` structure from Phase 2
4. Add scripts from Phases 3 & 4
5. Run seed script: `npx ts-node scripts/seed-claims.ts`
6. Verify: `npx ts-node scripts/verify-architecture.ts`

### Architecture Principles

**Data flow:**
```
Database (Supabase)
    ↓
/lib/supabase/queries (typed CRUD)
    ↓
/lib/models (calculations with DB fallbacks)
    ↓
/lib/hooks (TanStack Query wrappers)
    ↓
Components (pure UI, no logic)
```

**Key rules:**
- Single source of truth: DB → lib → hooks → components
- No hardcoded data in UI files
- All formatters in `/lib/constants/units.ts`
- All scenario names in `/lib/constants/terminology.ts`
- TanStack Query keys in `/lib/supabase/queries/keys.ts`
- Optimistic updates with rollback on all mutations
- SECURITY DEFINER functions for cross-table queries

**What this prevents:**
- Duplicate formatters across components
- Hardcoded values that drift from DB
- String literal query keys
- RLS nesting issues
- Missing rollback on failed mutations
- Inconsistent terminology

### When to Use This Pattern

**Good for:**
- Data modeling applications
- Projection/scenario tools
- Applications with verified claims/sources
- Multi-scenario analysis tools
- Research/analysis platforms

**Not needed for:**
- Simple CRUD apps
- Apps without complex calculations
- Static content sites
- Apps without scenario modeling
