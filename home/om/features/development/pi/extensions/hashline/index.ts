import { constants } from "node:fs";
import {
  access as fsAccess,
  mkdir,
  readFile,
  rename,
  stat,
  unlink,
  writeFile,
} from "node:fs/promises";
import * as path from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { renderDiff } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import * as Diff from "diff";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type AnchorRef = { line: number; id: string; content?: string };
type ResolvedAnchor = { line: number; moved: boolean };

type HashlineEdit =
  | { op: "replace_range"; pos: AnchorRef; end: AnchorRef; lines: string[] }
  | { op: "append_at"; pos: AnchorRef; lines: string[] }
  | { op: "prepend_at"; pos: AnchorRef; lines: string[] }
  | { op: "append_file"; lines: string[] }
  | { op: "prepend_file"; lines: string[] };

type PlannedOp =
  | {
      kind: "delete";
      requestedPath: string;
      absolutePath: string;
      summary: string;
    }
  | {
      kind: "write";
      requestedPath: string;
      absolutePath: string;
      moveTo?: { requested: string; absolute: string };
      content: string;
      summary: string;
      warnings: string[];
      diff?: string;
      firstChangedLine?: number;
    };

interface FileAnchorState {
  lines: string[];
  anchors: string[];
  nextId: number;
}

// ---------------------------------------------------------------------------
// Anchor state
// ---------------------------------------------------------------------------

const ANCHOR_ALPHABET = "ZPMQVRWSNKTXJBYH";
const ANCHOR_BASE = ANCHOR_ALPHABET.length;

const STRICT_ANCHOR_RESOLUTION = true;
const REQUIRE_ANCHOR_CONTENT = true;
const MAX_TRACKED_TASKS = 64;
const MAX_TRACKED_FILES_PER_TASK = 1024;
const MAX_TRACKED_LINES = 50000;
const MAX_FULL_READ_BYTES = 50 * 1024;

const anchorStateByTask = new Map<string, Map<string, FileAnchorState>>();
const lastReadHashByTask = new Map<string, Map<string, string>>();

function getTaskId(ctx: any): string {
  const sessionFile = ctx?.sessionManager?.getSessionFile?.();
  if (typeof sessionFile === "string" && sessionFile.length > 0) {
    return `session:${sessionFile}`;
  }

  const leafId = ctx?.sessionManager?.getLeafId?.();
  if (typeof leafId === "string" && leafId.length > 0) {
    return `leaf:${leafId}`;
  }

  return "default";
}

function touchLruMap<V>(map: Map<string, V>, key: string, value: V) {
  map.delete(key);
  map.set(key, value);
}

function getTaskState(taskId: string): Map<string, FileAnchorState> {
  let state = anchorStateByTask.get(taskId);
  if (!state) {
    state = new Map<string, FileAnchorState>();
    touchLruMap(anchorStateByTask, taskId, state);
    while (anchorStateByTask.size > MAX_TRACKED_TASKS) {
      const oldestTaskId = anchorStateByTask.keys().next().value;
      if (oldestTaskId === undefined) break;
      anchorStateByTask.delete(oldestTaskId);
      lastReadHashByTask.delete(oldestTaskId);
    }
    return state;
  }

  touchLruMap(anchorStateByTask, taskId, state);
  return state;
}

function getTaskReadHashes(taskId: string): Map<string, string> {
  let hashes = lastReadHashByTask.get(taskId);
  if (!hashes) {
    hashes = new Map<string, string>();
    lastReadHashByTask.set(taskId, hashes);
  }
  return hashes;
}

function setTaskReadHash(taskId: string, absolutePath: string, hash: string) {
  const hashes = getTaskReadHashes(taskId);
  touchLruMap(hashes, absolutePath, hash);
  while (hashes.size > MAX_TRACKED_FILES_PER_TASK) {
    const oldestPath = hashes.keys().next().value;
    if (oldestPath === undefined) break;
    hashes.delete(oldestPath);
  }
}

function contentHash(content: string): string {
  let h = 2166136261;
  for (let i = 0; i < content.length; i++) {
    h = Math.imul(h ^ content.charCodeAt(i), 16777619);
  }
  return (h >>> 0).toString(16).padStart(8, "0");
}

function encodeAnchorId(n: number): string {
  let out = "";
  let x = n;
  do {
    out = ANCHOR_ALPHABET[x % ANCHOR_BASE] + out;
    x = Math.floor(x / ANCHOR_BASE);
  } while (x > 0);
  while (out.length < 2) out = ANCHOR_ALPHABET[0] + out;
  return out;
}

function normalizeLineForAnchor(line: string): string {
  return line.replace(/\r/g, "");
}

/**
 * Dirac-style reconcile: use structural diff between previous and current lines.
 * Unchanged segments keep anchor IDs exactly, inserted/changed lines get new IDs.
 */
function reconcileAnchors(
  absolutePath: string,
  currentLinesRaw: string[],
  taskId = "default",
): string[] {
  const currentLines = currentLinesRaw.map(normalizeLineForAnchor);

  if (currentLines.length > MAX_TRACKED_LINES) {
    return currentLines.map((_, i) => `L${i + 1}`);
  }

  const taskState = getTaskState(taskId);
  const prev = taskState.get(absolutePath);

  if (!prev) {
    const anchors = currentLines.map((_, i) => encodeAnchorId(i));
    const next: FileAnchorState = {
      lines: currentLines,
      anchors,
      nextId: currentLines.length,
    };
    touchLruMap(taskState, absolutePath, next);
    while (taskState.size > MAX_TRACKED_FILES_PER_TASK) {
      const oldestPath = taskState.keys().next().value;
      if (oldestPath === undefined) break;
      taskState.delete(oldestPath);
    }
    return anchors;
  }

  const changes = Diff.diffArrays(prev.lines, currentLines);
  const newAnchors: string[] = new Array(currentLines.length);
  let oldIdx = 0;
  let newIdx = 0;
  let nextId = prev.nextId;

  for (const chunk of changes) {
    const arr = chunk.value ?? [];
    if (chunk.removed) {
      oldIdx += arr.length;
      continue;
    }
    if (chunk.added) {
      for (let i = 0; i < arr.length; i++) {
        newAnchors[newIdx++] = encodeAnchorId(nextId++);
      }
      continue;
    }

    for (let i = 0; i < arr.length; i++) {
      newAnchors[newIdx++] = prev.anchors[oldIdx++];
    }
  }

  for (let i = 0; i < newAnchors.length; i++) {
    if (!newAnchors[i]) newAnchors[i] = encodeAnchorId(nextId++);
  }

  const next: FileAnchorState = {
    lines: currentLines,
    anchors: newAnchors,
    nextId,
  };
  touchLruMap(taskState, absolutePath, next);
  while (taskState.size > MAX_TRACKED_FILES_PER_TASK) {
    const oldestPath = taskState.keys().next().value;
    if (oldestPath === undefined) break;
    taskState.delete(oldestPath);
  }

  return newAnchors;
}

function dropAnchorState(absolutePath: string, taskId = "default") {
  anchorStateByTask.get(taskId)?.delete(absolutePath);
  lastReadHashByTask.get(taskId)?.delete(absolutePath);
}

// ---------------------------------------------------------------------------
// Schemas
// ---------------------------------------------------------------------------

const hashlineReadSchema = Type.Object({
  path: Type.String({ description: "Path to the file to read" }),
  offset: Type.Optional(
    Type.Number({
      description: "Line number to start reading from (1-indexed)",
    }),
  ),
  limit: Type.Optional(
    Type.Number({ description: "Maximum number of lines to read" }),
  ),
});

const linesSchema = Type.Union([
  Type.Array(Type.String(), { description: "content (preferred format)" }),
  Type.String(),
  Type.Null(),
]);

const locSchema = Type.Union(
  [
    Type.Literal("append"),
    Type.Literal("prepend"),
    Type.Object({ append: Type.String({ description: "anchor" }) }),
    Type.Object({ prepend: Type.String({ description: "anchor" }) }),
    Type.Object({
      range: Type.Object({
        pos: Type.String({ description: "first line to edit (inclusive)" }),
        end: Type.String({ description: "last line to edit (inclusive)" }),
      }),
    }),
  ],
  { description: "insert location" },
);

const fileEditItemSchema = Type.Object(
  {
    path: Type.String({ description: "path" }),
    edits: Type.Optional(
      Type.Array(
        Type.Object(
          {
            loc: locSchema,
            content: linesSchema,
          },
          { additionalProperties: false },
        ),
        { description: "edits over $path" },
      ),
    ),
    delete: Type.Optional(
      Type.Boolean({ description: "If true, delete $path" }),
    ),
    move: Type.Optional(
      Type.String({ description: "If set, move $path to $move" }),
    ),
  },
  { additionalProperties: false },
);

const hashlineEditSchema = Type.Object(
  {
    path: Type.Optional(Type.String({ description: "path" })),
    edits: Type.Optional(
      Type.Array(
        Type.Object(
          {
            loc: locSchema,
            content: linesSchema,
          },
          { additionalProperties: false },
        ),
        { description: "edits over $path" },
      ),
    ),
    delete: Type.Optional(
      Type.Boolean({ description: "If true, delete $path" }),
    ),
    move: Type.Optional(
      Type.String({ description: "If set, move $path to $move" }),
    ),
    files: Type.Optional(
      Type.Array(fileEditItemSchema, {
        description: "Batch edits over multiple files",
      }),
    ),
  },
  { additionalProperties: false },
);

// ---------------------------------------------------------------------------
// Parse + normalize helpers
// ---------------------------------------------------------------------------

const HASHLINE_PREFIX_RE =
  /^\s*(?:>>>|>>)?\s*(?:\+?\s*(?:\d+\s*#\s*|#\s*)|\+)\s*(?:[ZPMQVRWSNKTXJBYH]{2,}|L\d+):/;
const HASHLINE_PREFIX_PLUS_RE =
  /^\s*(?:>>>|>>)?\s*\+\s*(?:\d+\s*#\s*|#\s*)?(?:[ZPMQVRWSNKTXJBYH]{2,}|L\d+):/;
const DIFF_PLUS_RE = /^[+](?![+])/;

function stripNewLinePrefixes(lines: string[]): string[] {
  let hashPrefixCount = 0;
  let diffPlusHashPrefixCount = 0;
  let diffPlusCount = 0;
  let nonEmpty = 0;

  for (const l of lines) {
    if (l.length === 0) continue;
    nonEmpty++;
    if (HASHLINE_PREFIX_RE.test(l)) hashPrefixCount++;
    if (HASHLINE_PREFIX_PLUS_RE.test(l)) diffPlusHashPrefixCount++;
    if (DIFF_PLUS_RE.test(l)) diffPlusCount++;
  }
  if (nonEmpty === 0) return lines;

  const stripHash = hashPrefixCount > 0 && hashPrefixCount === nonEmpty;
  const stripPlus =
    !stripHash &&
    diffPlusHashPrefixCount === 0 &&
    diffPlusCount > 0 &&
    diffPlusCount >= nonEmpty * 0.5;

  if (!stripHash && !stripPlus && diffPlusHashPrefixCount === 0) return lines;

  return lines.map((l) => {
    if (stripHash) return l.replace(HASHLINE_PREFIX_RE, "");
    if (stripPlus) return l.replace(DIFF_PLUS_RE, "");
    if (diffPlusHashPrefixCount > 0 && HASHLINE_PREFIX_PLUS_RE.test(l)) {
      return l.replace(HASHLINE_PREFIX_RE, "");
    }
    return l;
  });
}

function parseContent(content: string[] | string | null): string[] {
  if (content === null) return [];
  if (Array.isArray(content)) return stripNewLinePrefixes(content);
  const normalized = content.endsWith("\n") ? content.slice(0, -1) : content;
  return stripNewLinePrefixes(normalized.replaceAll("\r", "").split("\n"));
}

function parseAnchorRef(raw: string): AnchorRef {
  const m = raw.match(
    /^\s*[>+-]*\s*(\d+)\s*#\s*((?:[ZPMQVRWSNKTXJBYH]{2,})|(?:L\d+))(?::([\s\S]*))?\s*$/,
  );
  if (!m) {
    throw new Error(
      `Invalid line reference "${raw}". Expected format "LINE#ID:TEXT" (e.g. "305#YW:const x = 1").`,
    );
  }
  const line = Number.parseInt(m[1], 10);
  if (!Number.isFinite(line) || line < 1) {
    throw new Error(`Line number must be >= 1 in "${raw}".`);
  }
  const content = m[3] === undefined ? undefined : m[3].replace(/\r/g, "");
  return { line, id: m[2], content };
}

function tryParseAnchorRef(raw: unknown): AnchorRef | undefined {
  if (typeof raw !== "string") return undefined;
  try {
    return parseAnchorRef(raw);
  } catch {
    return undefined;
  }
}

function resolveEditPayload(
  edits: Array<{ loc: any; content: string[] | string | null }>,
): HashlineEdit[] {
  const out: HashlineEdit[] = [];

  for (const edit of edits) {
    const lines = parseContent(edit.content);
    const loc = edit.loc;

    if (loc === "append") {
      out.push({ op: "append_file", lines });
      continue;
    }
    if (loc === "prepend") {
      out.push({ op: "prepend_file", lines });
      continue;
    }

    if (typeof loc === "string") {
      const one = tryParseAnchorRef(loc);
      if (one) {
        out.push({ op: "replace_range", pos: one, end: one, lines });
        continue;
      }
      throw new Error(`Invalid loc value: ${JSON.stringify(loc)}`);
    }

    if (!loc || typeof loc !== "object") {
      throw new Error(`Invalid loc value: ${JSON.stringify(loc)}`);
    }

    if ("append" in loc) {
      const a = tryParseAnchorRef(loc.append);
      if (!a) throw new Error("append requires a valid LINE#ID:TEXT anchor.");
      out.push({ op: "append_at", pos: a, lines });
      continue;
    }

    if ("prepend" in loc) {
      const a = tryParseAnchorRef(loc.prepend);
      if (!a) throw new Error("prepend requires a valid LINE#ID:TEXT anchor.");
      out.push({ op: "prepend_at", pos: a, lines });
      continue;
    }

    if ("range" in loc && loc.range) {
      const pos = tryParseAnchorRef(loc.range.pos);
      const end = tryParseAnchorRef(loc.range.end);
      if (!pos || !end) {
        throw new Error(
          "range requires valid pos and end anchors in LINE#ID:TEXT format.",
        );
      }
      out.push({ op: "replace_range", pos, end, lines });
      continue;
    }

    throw new Error(`Unknown loc shape: ${JSON.stringify(loc)}`);
  }

  return out;
}

// ---------------------------------------------------------------------------
// Anchor resolving + edit apply
// ---------------------------------------------------------------------------

function buildAnchorIndex(anchors: string[]): Map<string, number[]> {
  const index = new Map<string, number[]>();
  for (let i = 0; i < anchors.length; i++) {
    const id = anchors[i];
    let arr = index.get(id);
    if (!arr) {
      arr = [];
      index.set(id, arr);
    }
    arr.push(i + 1);
  }
  return index;
}

function resolveAnchor(
  ref: AnchorRef,
  anchorIndex: Map<string, number[]>,
  lines: string[],
): ResolvedAnchor {
  const candidates = anchorIndex.get(ref.id);
  if (!candidates || candidates.length === 0) {
    throw new Error(
      `Anchor ${ref.line}#${ref.id} was not found in current file state. The line may have changed or been deleted. Re-read the file.`,
    );
  }

  if (REQUIRE_ANCHOR_CONTENT && ref.content === undefined) {
    throw new Error(
      `Anchor ${ref.line}#${ref.id} is missing line content proof. Use LINE#ID:TEXT from the latest read output.`,
    );
  }

  const exactMatch = candidates.includes(ref.line)
    ? ref.line
    : undefined;

  if (STRICT_ANCHOR_RESOLUTION) {
    if (exactMatch === undefined) {
      throw new Error(
        `Anchor ${ref.line}#${ref.id} no longer resolves to the same line. Re-read the file and use current anchors.`,
      );
    }

    if (ref.content !== undefined) {
      const actual = normalizeLineForAnchor(lines[exactMatch - 1] ?? "");
      if (actual !== ref.content) {
        throw new Error(
          `Anchor ${ref.line}#${ref.id} content mismatch. Expected line: "${actual}", provided: "${ref.content}". Re-read and retry.`,
        );
      }
    }

    return { line: exactMatch, moved: false };
  }

  if (exactMatch !== undefined) {
    if (ref.content !== undefined) {
      const actual = normalizeLineForAnchor(lines[exactMatch - 1] ?? "");
      if (actual !== ref.content) {
        throw new Error(
          `Anchor ${ref.line}#${ref.id} content mismatch. Expected line: "${actual}", provided: "${ref.content}". Re-read and retry.`,
        );
      }
    }
    return { line: exactMatch, moved: false };
  }

  if (candidates.length === 1) return { line: candidates[0], moved: true };

  let best = candidates[0];
  let bestDist = Math.abs(best - ref.line);
  for (let i = 1; i < candidates.length; i++) {
    const d = Math.abs(candidates[i] - ref.line);
    if (d < bestDist) {
      best = candidates[i];
      bestDist = d;
    }
  }
  return { line: best, moved: true };
}

function validateNoOverlappingRanges(
  ranges: Array<{ start: number; end: number }>,
) {
  const sorted = [...ranges].sort((a, b) => a.start - b.start || a.end - b.end);
  for (let i = 1; i < sorted.length; i++) {
    if (sorted[i].start <= sorted[i - 1].end) {
      throw new Error(
        `Overlapping replace_range edits are not allowed: [${sorted[i - 1].start}-${sorted[i - 1].end}] overlaps [${sorted[i].start}-${sorted[i].end}].`,
      );
    }
  }
}

function applyHashlineEdits(
  source: string,
  edits: HashlineEdit[],
  anchorIndex: Map<string, number[]>,
): {
  content: string;
  warnings: string[];
  failedEdits: string[];
  appliedEdits: number;
  firstChangedLine?: number;
} {
  if (edits.length === 0)
    return { content: source, warnings: [], failedEdits: [], appliedEdits: 0 };

  const warnings: string[] = [];
  const failedEdits: string[] = [];
  const lines = source.split("\n");
  let firstChangedLine: number | undefined;

  type ResolvedEdit = {
    edit: HashlineEdit;
    start: number;
    end: number;
    insert: string[];
    sortLine: number;
    precedence: number;
  };

  const resolved: ResolvedEdit[] = [];
  const replaceRanges: Array<{ start: number; end: number }> = [];

  const describeEdit = (edit: HashlineEdit): string => {
    switch (edit.op) {
      case "replace_range":
        return `replace_range ${edit.pos.line}#${edit.pos.id}..${edit.end.line}#${edit.end.id}`;
      case "append_at":
        return `append_at ${edit.pos.line}#${edit.pos.id}`;
      case "prepend_at":
        return `prepend_at ${edit.pos.line}#${edit.pos.id}`;
      case "append_file":
        return "append_file";
      case "prepend_file":
        return "prepend_file";
    }
  };

  for (const edit of edits) {
    try {
      switch (edit.op) {
        case "replace_range": {
          const start = resolveAnchor(edit.pos, anchorIndex, lines);
          const end = resolveAnchor(edit.end, anchorIndex, lines);
          if (start.moved) {
            warnings.push(
              `Anchor ${edit.pos.line}#${edit.pos.id} moved to line ${start.line}.`,
            );
          }
          if (end.moved) {
            warnings.push(
              `Anchor ${edit.end.line}#${edit.end.id} moved to line ${end.line}.`,
            );
          }
          if (start.line > end.line) {
            throw new Error(
              `Range start line ${start.line} must be <= end line ${end.line}.`,
            );
          }
          replaceRanges.push({ start: start.line, end: end.line });
          resolved.push({
            edit,
            start: start.line,
            end: end.line,
            insert: edit.lines,
            sortLine: end.line,
            precedence: 0,
          });
          break;
        }
        case "append_at": {
          const pos = resolveAnchor(edit.pos, anchorIndex, lines);
          if (pos.moved) {
            warnings.push(
              `Anchor ${edit.pos.line}#${edit.pos.id} moved to line ${pos.line}.`,
            );
          }
          resolved.push({
            edit,
            start: pos.line,
            end: pos.line,
            insert: edit.lines,
            sortLine: pos.line,
            precedence: 1,
          });
          break;
        }
        case "prepend_at": {
          const pos = resolveAnchor(edit.pos, anchorIndex, lines);
          if (pos.moved) {
            warnings.push(
              `Anchor ${edit.pos.line}#${edit.pos.id} moved to line ${pos.line}.`,
            );
          }
          resolved.push({
            edit,
            start: pos.line,
            end: pos.line,
            insert: edit.lines,
            sortLine: pos.line,
            precedence: 2,
          });
          break;
        }
        case "append_file":
          resolved.push({
            edit,
            start: lines.length + 1,
            end: lines.length + 1,
            insert: edit.lines,
            sortLine: lines.length + 1,
            precedence: 1,
          });
          break;
        case "prepend_file":
          resolved.push({
            edit,
            start: 0,
            end: 0,
            insert: edit.lines,
            sortLine: 0,
            precedence: 2,
          });
          break;
      }
    } catch (error: any) {
      failedEdits.push(
        `${describeEdit(edit)} failed: ${error?.message ?? String(error)}`,
      );
    }
  }

  try {
    validateNoOverlappingRanges(replaceRanges);
  } catch (error: any) {
    failedEdits.push(`range validation failed: ${error?.message ?? String(error)}`);
    return {
      content: source,
      warnings,
      failedEdits,
      appliedEdits: 0,
      firstChangedLine,
    };
  }

  resolved.sort(
    (a, b) => b.sortLine - a.sortLine || a.precedence - b.precedence,
  );

  let appliedEdits = 0;
  for (const item of resolved) {
    const insert = item.insert;
    switch (item.edit.op) {
      case "replace_range": {
        const removeCount = item.end - item.start + 1;
        lines.splice(item.start - 1, removeCount, ...insert);
        firstChangedLine =
          firstChangedLine === undefined
            ? item.start
            : Math.min(firstChangedLine, item.start);
        appliedEdits++;
        break;
      }
      case "append_at": {
        lines.splice(item.start, 0, ...insert);
        const changed = item.start + 1;
        firstChangedLine =
          firstChangedLine === undefined
            ? changed
            : Math.min(firstChangedLine, changed);
        appliedEdits++;
        break;
      }
      case "prepend_at": {
        lines.splice(item.start - 1, 0, ...insert);
        firstChangedLine =
          firstChangedLine === undefined
            ? item.start
            : Math.min(firstChangedLine, item.start);
        appliedEdits++;
        break;
      }
      case "append_file": {
        if (lines.length === 1 && lines[0] === "") {
          lines.splice(0, 1, ...insert);
          firstChangedLine =
            firstChangedLine === undefined ? 1 : Math.min(firstChangedLine, 1);
        } else {
          const before = lines.length;
          lines.splice(lines.length, 0, ...insert);
          const changed = before + 1;
          firstChangedLine =
            firstChangedLine === undefined
              ? changed
              : Math.min(firstChangedLine, changed);
        }
        appliedEdits++;
        break;
      }
      case "prepend_file": {
        if (lines.length === 1 && lines[0] === "") {
          lines.splice(0, 1, ...insert);
        } else {
          lines.splice(0, 0, ...insert);
        }
        firstChangedLine =
          firstChangedLine === undefined ? 1 : Math.min(firstChangedLine, 1);
        appliedEdits++;
        break;
      }
    }
  }

  return {
    content: lines.join("\n"),
    warnings,
    failedEdits,
    appliedEdits,
    firstChangedLine,
  };
}

// ---------------------------------------------------------------------------
// Diff output for vanilla-like edit renderer
// ---------------------------------------------------------------------------

function generateDiffString(
  oldContent: string,
  newContent: string,
  contextLines = 4,
): { diff: string; firstChangedLine?: number } {
  const oldLines = oldContent.split("\n");
  const newLines = newContent.split("\n");
  const width = String(Math.max(oldLines.length, newLines.length, 1)).length;

  const chunks = Diff.diffLines(oldContent, newContent);
  const out: string[] = [];

  let oldNo = 1;
  let newNo = 1;
  let firstChangedLine: number | undefined;
  let lastWasChange = false;

  for (let i = 0; i < chunks.length; i++) {
    const c = chunks[i];
    const lines = c.value.split("\n");
    if (lines[lines.length - 1] === "") lines.pop();

    if (c.added || c.removed) {
      if (firstChangedLine === undefined && c.added) firstChangedLine = newNo;
      for (const line of lines) {
        if (c.added) {
          out.push(`+${String(newNo).padStart(width, " ")} ${line}`);
          newNo++;
        } else {
          out.push(`-${String(oldNo).padStart(width, " ")} ${line}`);
          oldNo++;
        }
      }
      lastWasChange = true;
      continue;
    }

    const nextIsChange =
      i < chunks.length - 1 && !!(chunks[i + 1].added || chunks[i + 1].removed);
    if (!lastWasChange && !nextIsChange) {
      oldNo += lines.length;
      newNo += lines.length;
      continue;
    }

    if (lastWasChange && nextIsChange) {
      if (lines.length <= contextLines * 2) {
        for (const line of lines) {
          out.push(` ${String(oldNo).padStart(width, " ")} ${line}`);
          oldNo++;
          newNo++;
        }
      } else {
        for (const line of lines.slice(0, contextLines)) {
          out.push(` ${String(oldNo).padStart(width, " ")} ${line}`);
          oldNo++;
          newNo++;
        }
        const skipped = lines.length - contextLines * 2;
        out.push(` ${"".padStart(width, " ")} ...`);
        oldNo += skipped;
        newNo += skipped;
        for (const line of lines.slice(-contextLines)) {
          out.push(` ${String(oldNo).padStart(width, " ")} ${line}`);
          oldNo++;
          newNo++;
        }
      }
    } else if (lastWasChange) {
      const shown = lines.slice(0, contextLines);
      for (const line of shown) {
        out.push(` ${String(oldNo).padStart(width, " ")} ${line}`);
        oldNo++;
        newNo++;
      }
      if (shown.length < lines.length) {
        const skipped = lines.length - shown.length;
        out.push(` ${"".padStart(width, " ")} ...`);
        oldNo += skipped;
        newNo += skipped;
      }
    } else {
      const skipped = Math.max(0, lines.length - contextLines);
      if (skipped > 0) {
        out.push(` ${"".padStart(width, " ")} ...`);
        oldNo += skipped;
        newNo += skipped;
      }
      for (const line of lines.slice(skipped)) {
        out.push(` ${String(oldNo).padStart(width, " ")} ${line}`);
        oldNo++;
        newNo++;
      }
    }
    lastWasChange = false;
  }

  return { diff: out.join("\n"), firstChangedLine };
}

// ---------------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------------

function formatHashLines(
  lines: string[],
  anchors: string[],
  startLine: number,
): string {
  return lines
    .map((line, i) => `${startLine + i}#${anchors[i]}:${line}`)
    .join("\n");
}

function resolveAbsolute(cwd: string, p: string): string {
  return path.isAbsolute(p) ? path.normalize(p) : path.resolve(cwd, p);
}

function ensureParentDir(filePath: string) {
  return mkdir(path.dirname(filePath), { recursive: true });
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "read",
    label: "read",
    description:
      "Read file content formatted as LINE#ID:TEXT. Line anchors are stable across reads for unchanged lines.",
    promptSnippet:
      "Read the file first, then use LINE#ID:TEXT anchors for edit. Anchors are stable across reads for unchanged lines.",
    parameters: hashlineReadSchema,
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const taskId = getTaskId(ctx);
      const absolutePath = resolveAbsolute(ctx.cwd, params.path);

      const fullReadRequested = params.offset === undefined && params.limit === undefined;
      if (fullReadRequested) {
        const fileStat = await stat(absolutePath);
        if (fileStat.isFile() && fileStat.size > MAX_FULL_READ_BYTES) {
          return {
            content: [
              {
                type: "text" as const,
                text: `File is ${Math.round(fileStat.size / 1024)}KB, exceeding ${Math.round(MAX_FULL_READ_BYTES / 1024)}KB full-read limit. Use offset/limit for a targeted read.`,
              },
            ],
          };
        }
      }

      const content = await readFile(absolutePath, "utf8");
      const currentHash = contentHash(content);
      const previousHash = getTaskReadHashes(taskId).get(absolutePath);
      const allLines = content.split("\n");
      const allAnchors = reconcileAnchors(absolutePath, allLines, taskId);

      if (fullReadRequested && previousHash === currentHash) {
        return {
          content: [
            {
              type: "text" as const,
              text: `no changes have been made to the file since your last read (Hash: ${currentHash})`,
            },
          ],
        };
      }

      const startIdx = Math.max(0, (params.offset ?? 1) - 1);
      const limit = Math.max(1, params.limit ?? 200);
      const endIdx = Math.min(allLines.length, startIdx + limit);

      if (params.offset && startIdx >= allLines.length) {
        return {
          content: [
            {
              type: "text" as const,
              text: `Offset ${params.offset} is beyond end of file (${allLines.length} lines total).`,
            },
          ],
        };
      }

      const sliceLines = allLines.slice(startIdx, endIdx);
      const sliceAnchors = allAnchors.slice(startIdx, endIdx);
      let out = `[File Hash: ${currentHash}]\n${formatHashLines(sliceLines, sliceAnchors, startIdx + 1)}`;

      if (endIdx < allLines.length) {
        out += `\n\n[${allLines.length - endIdx} more lines in file. Use offset=${endIdx + 1} to continue]`;
      }

      setTaskReadHash(taskId, absolutePath, currentHash);

      return {
        content: [{ type: "text" as const, text: out }],
      };
    },
  });

  pi.registerTool({
    name: "edit",
    label: "edit",
    description:
      "Apply precise file edits using LINE#ID:TEXT anchors. Anchors are stable across reads for unchanged lines.",
    promptSnippet:
      "Batch related edits in one call. Use files[] for multi-file edits. Use LINE#ID:TEXT anchors from prior read output.",
    promptGuidelines: [
      "Prefer one edit call with multiple edits (or files[]) instead of many small calls.",
      "Use exact LINE#ID:TEXT anchors from prior read output.",
      "range requires both pos and end; ranges must not overlap.",
    ],
    parameters: hashlineEditSchema,
    renderResult(result, _options, _theme, context) {
      if (context.isError) return undefined;
      const diff = (result as any).details?.diff;
      const argPath = (context.args as any)?.path;
      if (typeof diff === "string" && diff.length > 0) {
        return renderDiff(diff, {
          filePath: typeof argPath === "string" ? argPath : undefined,
        });
      }
      return undefined;
    },
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const taskId = getTaskId(ctx);
      const requests: Array<{
        path: string;
        edits?: Array<{ loc: any; content: string[] | string | null }>;
        delete?: boolean;
        move?: string;
      }> = [];

      if (params.path) {
        requests.push({
          path: params.path,
          edits: params.edits,
          delete: params.delete,
          move: params.move,
        });
      }
      if (Array.isArray(params.files)) {
        for (const f of params.files) requests.push(f as any);
      }

      if (requests.length === 0) {
        throw new Error("No edits provided. Use path+edits or files[].");
      }

      const plan: PlannedOp[] = [];

      // Preflight: compute all outputs without mutating filesystem
      for (const req of requests) {
        const absolutePath = resolveAbsolute(ctx.cwd, req.path);
        const moveTo = req.move
          ? {
              requested: req.move,
              absolute: resolveAbsolute(ctx.cwd, req.move),
            }
          : undefined;

        if (req.delete) {
          await fsAccess(absolutePath, constants.F_OK);
          plan.push({
            kind: "delete",
            requestedPath: req.path,
            absolutePath,
            summary: `Deleted ${req.path}`,
          });
          continue;
        }

        const edits = req.edits ?? [];
        if (edits.length === 0)
          throw new Error(`No edits provided for ${req.path}.`);

        let sourceContent: string | null = null;
        try {
          sourceContent = await readFile(absolutePath, "utf8");
        } catch {
          sourceContent = null;
        }

        if (sourceContent === null) {
          const createdLines: string[] = [];
          for (const edit of edits) {
            if (edit.loc === "append")
              createdLines.push(...parseContent(edit.content));
            else if (edit.loc === "prepend")
              createdLines.unshift(...parseContent(edit.content));
            else
              throw new Error(
                `File not found: ${req.path}. Create with append/prepend only.`,
              );
          }
          const newContent = createdLines.join("\n");
          const diffInfo = generateDiffString("", newContent);
          plan.push({
            kind: "write",
            requestedPath: req.path,
            absolutePath,
            moveTo,
            content: newContent,
            summary: moveTo
              ? `Created ${req.path} and moved to ${req.move}`
              : `Created ${req.path}`,
            warnings: [],
            diff: diffInfo.diff,
            firstChangedLine: diffInfo.firstChangedLine,
          });
          continue;
        }

        const sourceLines = sourceContent.split("\n");
        const anchors = reconcileAnchors(absolutePath, sourceLines, taskId);
        const anchorIndex = buildAnchorIndex(anchors);

        const parsedEdits = resolveEditPayload(edits);
        const applied = applyHashlineEdits(
          sourceContent,
          parsedEdits,
          anchorIndex,
        );

        if (applied.appliedEdits === 0 && !moveTo) {
          const diagnostics = applied.failedEdits.length
            ? ` Diagnostics:\n${applied.failedEdits.join("\n")}`
            : "";
          throw new Error(
            `No valid edits could be applied to ${req.path}.${diagnostics}`,
          );
        }

        if (applied.content === sourceContent && !moveTo) {
          throw new Error(
            `No changes made to ${req.path}. The edits produced identical content. Re-read and adjust anchors/content.`,
          );
        }

        const diffInfo = generateDiffString(sourceContent, applied.content);

        // keep state in sync with expected post-edit content
        reconcileAnchors(absolutePath, applied.content.split("\n"), taskId);

        const warnings = [...applied.warnings];
        if (applied.failedEdits.length > 0) {
          warnings.push(
            `Skipped ${applied.failedEdits.length} invalid edit(s):`,
            ...applied.failedEdits,
          );
        }

        plan.push({
          kind: "write",
          requestedPath: req.path,
          absolutePath,
          moveTo,
          content: applied.content,
          summary: moveTo
            ? `Moved ${req.path} to ${req.move}`
            : `Updated ${req.path} (applied ${applied.appliedEdits}/${parsedEdits.length} edits)`,
          warnings,
          diff: diffInfo.diff,
          firstChangedLine:
            applied.firstChangedLine ?? diffInfo.firstChangedLine,
        });
      }

      // Commit phase with best-effort rollback
      const backup = new Map<string, string | null>();
      for (const op of plan) {
        if (backup.has(op.absolutePath)) continue;
        try {
          backup.set(op.absolutePath, await readFile(op.absolutePath, "utf8"));
        } catch {
          backup.set(op.absolutePath, null);
        }
      }

      try {
        for (const op of plan) {
          if (op.kind === "delete") {
            await unlink(op.absolutePath);
            dropAnchorState(op.absolutePath, taskId);
            continue;
          }
          await ensureParentDir(op.absolutePath);
          await writeFile(op.absolutePath, op.content, "utf8");
          if (op.moveTo) {
            await ensureParentDir(op.moveTo.absolute);
            await rename(op.absolutePath, op.moveTo.absolute);
            const taskState = getTaskState(taskId);
            const state = taskState.get(op.absolutePath);
            if (state) {
              taskState.set(op.moveTo.absolute, state);
              taskState.delete(op.absolutePath);
            }

            const readHashes = getTaskReadHashes(taskId);
            const hash = readHashes.get(op.absolutePath);
            if (hash) {
              readHashes.set(op.moveTo.absolute, hash);
              readHashes.delete(op.absolutePath);
            }
          }
        }
      } catch (error: any) {
        for (const [file, previous] of backup.entries()) {
          try {
            if (previous === null) {
              await unlink(file).catch(() => undefined);
              dropAnchorState(file, taskId);
            } else {
              await ensureParentDir(file);
              await writeFile(file, previous, "utf8");
              reconcileAnchors(file, previous.split("\n"), taskId);
            }
          } catch {
            // best effort
          }
        }
        throw new Error(
          `Batch commit failed and was rolled back: ${error?.message ?? String(error)}`,
        );
      }

      const summaries = plan.map((op) => op.summary).join("\n");
      const warnings = plan
        .filter(
          (op): op is Extract<PlannedOp, { kind: "write" }> =>
            op.kind === "write",
        )
        .flatMap((op) => op.warnings);

      const diffBlocks = plan
        .filter(
          (op): op is Extract<PlannedOp, { kind: "write" }> =>
            op.kind === "write",
        )
        .map((op) => ({
          path: op.moveTo?.requested ?? op.requestedPath,
          diff: op.diff,
        }))
        .filter((x) => x.diff && x.diff.length > 0)
        .map((x) => (plan.length > 1 ? `*** ${x.path}\n\n${x.diff}` : x.diff!));

      const firstChangedLine = plan
        .filter(
          (op): op is Extract<PlannedOp, { kind: "write" }> =>
            op.kind === "write",
        )
        .reduce<number | undefined>((min, op) => {
          if (op.firstChangedLine === undefined) return min;
          if (min === undefined) return op.firstChangedLine;
          return Math.min(min, op.firstChangedLine);
        }, undefined);

      const warningText =
        warnings.length > 0 ? `\n\nWarnings:\n${warnings.join("\n")}` : "";

      return {
        content: [
          { type: "text" as const, text: `${summaries}${warningText}` },
        ],
        details: {
          diff: diffBlocks.join("\n\n"),
          firstChangedLine,
        },
      };
    },
  });
}
