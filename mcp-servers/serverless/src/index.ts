#!/usr/bin/env node

/**
 * Serverless MCP Server
 *
 * Two tools for Claude Code:
 *   - discover: What serverless functions exist in this project?
 *   - invoke: Call a function by name
 *
 * Supports: Supabase Edge Functions
 * Does NOT replicate CLIs/SDKs — just awareness and invocation.
 */

import { config } from "@dotenvx/dotenvx";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";
import { readdir, stat } from "fs/promises";

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(__dirname, "../../..");

config({ path: resolve(projectRoot, ".env.local") });

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

// =============================================================================
// Discovery
// =============================================================================

interface FunctionInfo {
  name: string;
  service: "supabase";
  path?: string;
  endpoint?: string;
}

async function discoverFunctions(): Promise<FunctionInfo[]> {
  const functions: FunctionInfo[] = [];
  const functionsDir = resolve(projectRoot, "supabase/functions");

  try {
    const entries = await readdir(functionsDir);
    for (const entry of entries) {
      const entryPath = resolve(functionsDir, entry);
      const stats = await stat(entryPath);
      if (stats.isDirectory() && !entry.startsWith("_")) {
        const supabaseUrl = process.env.SUPABASE_URL || process.env.EXPO_PUBLIC_SUPABASE_URL;
        functions.push({
          name: entry,
          service: "supabase",
          path: `supabase/functions/${entry}`,
          endpoint: supabaseUrl ? `${supabaseUrl}/functions/v1/${entry}` : undefined,
        });
      }
    }
  } catch (e) {
    // No supabase/functions directory
  }

  return functions;
}

// =============================================================================
// Invocation
// =============================================================================

async function invokeFunction(
  name: string,
  payload: unknown,
  endpoint?: string
): Promise<{ result: unknown; status: number }> {
  const supabaseUrl = process.env.SUPABASE_URL || process.env.EXPO_PUBLIC_SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY || process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseKey) {
    throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY/SUPABASE_ANON_KEY");
  }

  const url = endpoint || `${supabaseUrl}/functions/v1/${name}`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${supabaseKey}`,
    },
    body: JSON.stringify(payload),
  });

  const contentType = response.headers.get("content-type");
  const result = contentType?.includes("application/json")
    ? await response.json()
    : await response.text();

  return { result, status: response.status };
}

// =============================================================================
// MCP Server
// =============================================================================

const server = new Server(
  {
    name: "serverless-mcp",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "discover",
        description: "Discover Supabase edge functions in this project",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "invoke",
        description: "Invoke a Supabase edge function by name",
        inputSchema: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "Function name",
            },
            payload: {
              type: "object",
              description: "Request payload (optional)",
            },
            endpoint: {
              type: "string",
              description: "Override endpoint URL (optional)",
            },
          },
          required: ["name"],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "discover": {
        const functions = await discoverFunctions();

        return {
          content: [{
            type: "text",
            text: JSON.stringify({
              functions,
              count: functions.length,
            }, null, 2),
          }],
        };
      }

      case "invoke": {
        const { name: fnName, payload = {}, endpoint } = args as {
          name: string;
          payload?: unknown;
          endpoint?: string;
        };

        const result = await invokeFunction(fnName, payload, endpoint);

        return {
          content: [{
            type: "text",
            text: JSON.stringify({
              function: fnName,
              service: "supabase",
              ...result,
            }, null, 2),
          }],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [{
        type: "text",
        text: JSON.stringify({
          error: error instanceof Error ? error.message : String(error),
        }, null, 2),
      }],
      isError: true,
    };
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Serverless MCP server running");
}

main().catch(console.error);
