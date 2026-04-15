import * as fs from "node:fs"
import * as path from "node:path"
import * as os from "node:os"

// ---------------------------------------------------------------------------
// Inline JSONC parser (replaces jsonc-parser dependency)
// ---------------------------------------------------------------------------

function stripJsonComments(input: string): string {
  let output = ""
  let inString = false
  let stringDelimiter = '"'
  let escaping = false
  let inLineComment = false
  let inBlockComment = false

  for (let i = 0; i < input.length; i++) {
    const ch = input[i]
    const next = input[i + 1]

    if (inLineComment) {
      if (ch === '\n') { inLineComment = false; output += ch }
      continue
    }
    if (inBlockComment) {
      if (ch === '*' && next === '/') { inBlockComment = false; i++ }
      continue
    }
    if (inString) {
      output += ch
      if (escaping) { escaping = false; continue }
      if (ch === '\\') { escaping = true; continue }
      if (ch === stringDelimiter) { inString = false }
      continue
    }
    if (ch === '"' || ch === "'") {
      inString = true; stringDelimiter = ch; output += ch; continue
    }
    if (ch === '/' && next === '/') { inLineComment = true; i++; continue }
    if (ch === '/' && next === '*') { inBlockComment = true; i++; continue }
    output += ch
  }
  return output
}

function parseJsonc(text: string): unknown {
  const withoutBom = text.replace(/^\uFEFF/, "")
  const stripped = stripJsonComments(withoutBom)
  // Remove trailing commas before } or ]
  const cleaned = stripped.replace(/,\s*([}\]])/g, "$1")
  return JSON.parse(cleaned)
}

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface DcpConfig {
  enabled: boolean
  debug: boolean
  manualMode: {
    enabled: boolean
    automaticStrategies: boolean // run dedup/purge even in manual mode
  }
  compress: {
    maxContextPercent: number // 0-1, e.g. 0.8 — above this, aggressive nudges
    minContextPercent: number // 0-1, e.g. 0.4 — below this, no nudges
    nudgeFrequency: number // inject nudge every N context events (default: 5)
    iterationNudgeThreshold: number // nudge after N tool calls since last user msg (default: 15)
    nudgeForce: "strong" | "soft"
    protectedTools: string[] // these tool outputs always protected from pruning
    protectUserMessages: boolean
  }
  strategies: {
    deduplication: {
      enabled: boolean
      protectedTools: string[]
    }
    purgeErrors: {
      enabled: boolean
      turns: number // prune error inputs after N user turns (default: 4)
      protectedTools: string[]
    }
  }
  protectedFilePatterns: string[]
  pruneNotification: "off" | "minimal" | "detailed"
}

// ---------------------------------------------------------------------------
// Defaults
// ---------------------------------------------------------------------------

const DEFAULT_CONFIG: DcpConfig = {
  enabled: true,
  debug: false,
  manualMode: {
    enabled: false,
    automaticStrategies: true,
  },
  compress: {
    maxContextPercent: 0.8,
    minContextPercent: 0.4,
    nudgeFrequency: 5,
    iterationNudgeThreshold: 15,
    nudgeForce: "soft",
    protectedTools: ["compress", "write", "edit"],
    protectUserMessages: false,
  },
  strategies: {
    deduplication: {
      enabled: true,
      protectedTools: [],
    },
    purgeErrors: {
      enabled: true,
      turns: 4,
      protectedTools: [],
    },
  },
  protectedFilePatterns: [],
  pruneNotification: "detailed",
}

const DEFAULT_CONFIG_FILE_CONTENT = `{
  // Dynamic Context Pruning (DCP) configuration
  // Full schema reference: https://github.com/your-org/pi-dynamic-context-pruning
  //
  // "$schema": "...",
  //
  // Uncomment and edit properties you want to override:
  //
  // "enabled": true,
  // "debug": false,
  // "manualMode": {
  //   "enabled": false,
  //   "automaticStrategies": true
  // },
  // "compress": {
  //   "maxContextPercent": 0.8,
  //   "minContextPercent": 0.4,
  //   "nudgeFrequency": 5,
  //   "iterationNudgeThreshold": 15,
  //   "nudgeForce": "soft",
  //   "protectedTools": ["compress", "write", "edit"],
  //   "protectUserMessages": false
  // },
  // "strategies": {
  //   "deduplication": { "enabled": true, "protectedTools": [] },
  //   "purgeErrors": { "enabled": true, "turns": 4, "protectedTools": [] }
  // },
  // "protectedFilePatterns": [],
  // "pruneNotification": "detailed"
}
`

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Recursively merge `override` into `base`. Arrays are union-merged (deduped).
 * Returns a new object; does not mutate inputs.
 */
function deepMerge<T>(base: T, override: Partial<T>): T {
  if (override === null || override === undefined) return base
  if (typeof base !== "object" || typeof override !== "object") {
    return override as T
  }

  const result: Record<string, unknown> = { ...(base as Record<string, unknown>) }

  for (const key of Object.keys(override as Record<string, unknown>)) {
    const baseVal = (base as Record<string, unknown>)[key]
    const overVal = (override as Record<string, unknown>)[key]

    if (Array.isArray(baseVal) && Array.isArray(overVal)) {
      // Union merge: combine and deduplicate by value
      const combined = [...baseVal, ...overVal]
      result[key] = [...new Set(combined)]
    } else if (
      overVal !== null &&
      typeof overVal === "object" &&
      !Array.isArray(overVal) &&
      baseVal !== null &&
      typeof baseVal === "object" &&
      !Array.isArray(baseVal)
    ) {
      result[key] = deepMerge(
        baseVal as Record<string, unknown>,
        overVal as Record<string, unknown>,
      )
    } else if (overVal !== undefined) {
      result[key] = overVal
    }
  }

  return result as T
}

/**
 * Parse a JSONC file and return a plain object.
 * Returns `{}` on any error (missing file, parse error).
 */
function readJsoncFile(filePath: string): Record<string, unknown> {
  let raw: string
  try {
    raw = fs.readFileSync(filePath, "utf8")
  } catch {
    return {}
  }

  try {
    const parsed = parseJsonc(raw)
    if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
      return {}
    }
    return parsed as Record<string, unknown>
  } catch {
    return {}
  }
}

/**
 * Ensure the global config file exists, creating it with defaults if missing.
 */
function ensureGlobalConfig(filePath: string): void {
  const dir = path.dirname(filePath)
  try {
    fs.mkdirSync(dir, { recursive: true })
    if (!fs.existsSync(filePath)) {
      fs.writeFileSync(filePath, DEFAULT_CONFIG_FILE_CONTENT, "utf8")
    }
  } catch {
    // Best-effort; do not crash if we cannot write
  }
}

/**
 * Walk up from `startDir` looking for `.pi/dcp.jsonc`.
 * Returns the path if found, otherwise null.
 */
function findProjectConfig(startDir: string): string | null {
  let dir = path.resolve(startDir)
  const root = path.parse(dir).root

  while (true) {
    const candidate = path.join(dir, ".pi", "dcp.jsonc")
    if (fs.existsSync(candidate)) return candidate
    if (dir === root) return null
    const parent = path.dirname(dir)
    if (parent === dir) return null
    dir = parent
  }
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/**
 * Load the DCP configuration by merging (in order):
 *  1. Built-in defaults
 *  2. ~/.config/pi/dcp.jsonc  (global; auto-created if missing)
 *  3. $PI_CONFIG_DIR/dcp.jsonc  (if env var is set)
 *  4. <project>/.pi/dcp.jsonc  (walked up from projectDir)
 */
export function loadConfig(projectDir: string): DcpConfig {
  // Layer 1: defaults (deep clone so we never mutate the constant)
  let config: DcpConfig = deepMerge(DEFAULT_CONFIG, {})

  // Layer 2: global config
  const globalConfigPath = path.join(os.homedir(), ".config", "pi", "dcp.jsonc")
  ensureGlobalConfig(globalConfigPath)
  const globalRaw = readJsoncFile(globalConfigPath)
  if (Object.keys(globalRaw).length > 0) {
    config = deepMerge(config, globalRaw as Partial<DcpConfig>)
  }

  // Layer 3: $PI_CONFIG_DIR/dcp.jsonc
  const piConfigDir = process.env["PI_CONFIG_DIR"]
  if (piConfigDir) {
    const envConfigPath = path.join(piConfigDir, "dcp.jsonc")
    const envRaw = readJsoncFile(envConfigPath)
    if (Object.keys(envRaw).length > 0) {
      config = deepMerge(config, envRaw as Partial<DcpConfig>)
    }
  }

  // Layer 4: project-local config (walk up from projectDir)
  const projectConfigPath = findProjectConfig(projectDir)
  if (projectConfigPath) {
    const projectRaw = readJsoncFile(projectConfigPath)
    if (Object.keys(projectRaw).length > 0) {
      config = deepMerge(config, projectRaw as Partial<DcpConfig>)
    }
  }

  return config
}
