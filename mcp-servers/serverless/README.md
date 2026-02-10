# Serverless MCP Server

Discover and invoke Supabase edge functions.

## Why

Claude Code writes throwaway scripts. This MCP provides awareness of what exists and simple invocation, so I reach for deployed functions instead of improvising.

## Tools

| Tool | What it does |
|------|--------------|
| `discover` | Scan project for Supabase edge functions |
| `invoke` | Call a function by name, route to correct service |

## Setup

```bash
cd mcp-servers/serverless && npm install
```

Add to `.mcp.json`:
```json
{
  "mcpServers": {
    "serverless": {
      "command": "npx",
      "args": ["tsx", "mcp-servers/serverless/src/index.ts"]
    }
  }
}
```

## Environment

For Supabase invocation:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

## Usage

```
mcp__serverless__discover()
mcp__serverless__invoke({ name: "my-function", payload: { ... } })
```

## What This Doesn't Do

- Deploy functions (use `supabase functions deploy`)
- Manage cron (use Supabase dashboard)
- Replicate SDKs

Just awareness and invocation.
