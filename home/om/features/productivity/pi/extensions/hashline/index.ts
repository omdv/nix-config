import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { readFile, rename, unlink, writeFile } from "node:fs/promises";
import * as path from "node:path";

type Anchor = { line: number; hash: string };
type HashMismatch = { line: number; expected: string; actual: string };

type HashlineEdit =
  | { op: "replace_range"; pos: Anchor; end: Anchor; lines: string[] }
  | { op: "append_at"; pos: Anchor; lines: string[] }
  | { op: "prepend_at"; pos: Anchor; lines: string[] }
  | { op: "append_file"; lines: string[] }
  | { op: "prepend_file"; lines: string[] };

const NIBBLE_STR = "ZPMQVRWSNKTXJBYH";
const DICT = Array.from({ length: 256 }, (_, i) => {
  const h = i >>> 4;
  const l = i & 0x0f;
  return `${NIBBLE_STR[h]}${NIBBLE_STR[l]}`;
});
const RE_SIGNIFICANT = /[\p{L}\p{N}]/u;
const HASHLINE_PREFIX_RE =
  /^\s*(?:>>>|>>)?\s*(?:\+?\s*(?:\d+\s*#\s*|#\s*)|\+)\s*[ZPMQVRWSNKTXJBYH]{2}:/;
const HASHLINE_PREFIX_PLUS_RE =
  /^\s*(?:>>>|>>)?\s*\+\s*(?:\d+\s*#\s*|#\s*)?[ZPMQVRWSNKTXJBYH]{2}:/;
const DIFF_PLUS_RE = /^[+](?![+])/;

const hashlineReadSchema = Type.Object({
  path: Type.String({ description: "Path to the file to read" }),
  offset: Type.Optional(
    Type.Number({ description: "Line number to start reading from (1-indexed)" }),
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

const hashlineEditSchema = Type.Object(
  {
    path: Type.String({ description: "path" }),
    edits: Type.Array(
      Type.Object(
        {
          loc: locSchema,
          content: linesSchema,
        },
        { additionalProperties: false },
      ),
      { description: "edits over $path" },
    ),
    delete: Type.Optional(Type.Boolean({ description: "If true, delete $path" })),
    move: Type.Optional(Type.String({ description: "If set, move $path to $move" })),
  },
  { additionalProperties: false },
);

function rotl32(x: number, r: number): number {
  return ((x << r) | (x >>> (32 - r))) >>> 0;
}

function readU32LE(data: Uint8Array, i: number): number {
  return (
    (data[i] |
      (data[i + 1] << 8) |
      (data[i + 2] << 16) |
      (data[i + 3] << 24)) >>>
    0
  );
}

function xxh32(input: string, seed = 0): number {
  const PRIME32_1 = 0x9e3779b1 >>> 0;
  const PRIME32_2 = 0x85ebca77 >>> 0;
  const PRIME32_3 = 0xc2b2ae3d >>> 0;
  const PRIME32_4 = 0x27d4eb2f >>> 0;
  const PRIME32_5 = 0x165667b1 >>> 0;

  const data = new TextEncoder().encode(input);
  const len = data.length;
  let p = 0;
  let h32 = 0;

  if (len >= 16) {
    let v1 = (seed + PRIME32_1 + PRIME32_2) >>> 0;
    let v2 = (seed + PRIME32_2) >>> 0;
    let v3 = seed >>> 0;
    let v4 = (seed - PRIME32_1) >>> 0;

    const limit = len - 16;
    while (p <= limit) {
      v1 = Math.imul(rotl32((v1 + Math.imul(readU32LE(data, p), PRIME32_2)) >>> 0, 13), PRIME32_1) >>> 0;
      p += 4;
      v2 = Math.imul(rotl32((v2 + Math.imul(readU32LE(data, p), PRIME32_2)) >>> 0, 13), PRIME32_1) >>> 0;
      p += 4;
      v3 = Math.imul(rotl32((v3 + Math.imul(readU32LE(data, p), PRIME32_2)) >>> 0, 13), PRIME32_1) >>> 0;
      p += 4;
      v4 = Math.imul(rotl32((v4 + Math.imul(readU32LE(data, p), PRIME32_2)) >>> 0, 13), PRIME32_1) >>> 0;
      p += 4;
    }

    h32 = (rotl32(v1, 1) + rotl32(v2, 7) + rotl32(v3, 12) + rotl32(v4, 18)) >>> 0;
  } else {
    h32 = (seed + PRIME32_5) >>> 0;
  }

  h32 = (h32 + len) >>> 0;

  while (p + 4 <= len) {
    h32 = (h32 + Math.imul(readU32LE(data, p), PRIME32_3)) >>> 0;
    h32 = Math.imul(rotl32(h32, 17), PRIME32_4) >>> 0;
    p += 4;
  }

  while (p < len) {
    h32 = (h32 + Math.imul(data[p], PRIME32_5)) >>> 0;
    h32 = Math.imul(rotl32(h32, 11), PRIME32_1) >>> 0;
    p++;
  }

  h32 ^= h32 >>> 15;
  h32 = Math.imul(h32, PRIME32_2) >>> 0;
  h32 ^= h32 >>> 13;
  h32 = Math.imul(h32, PRIME32_3) >>> 0;
  h32 ^= h32 >>> 16;

  return h32 >>> 0;
}

function computeLineHash(idx: number, line: string): string {
  line = line.replace(/\r/g, "").trimEnd();
  const seed = RE_SIGNIFICANT.test(line) ? 0 : idx;
  return DICT[xxh32(line, seed) & 0xff];
}

function parseTag(ref: string): Anchor {
  const match = ref.match(/^\s*[>+-]*\s*(\d+)\s*#\s*([ZPMQVRWSNKTXJBYH]{2})/);
  if (!match) {
    throw new Error(`Invalid line reference "${ref}". Expected format "LINE#ID" (e.g. "5#aa").`);
  }
  const line = Number.parseInt(match[1], 10);
  if (line < 1) {
    throw new Error(`Line number must be >= 1, got ${line} in "${ref}".`);
  }
  return { line, hash: match[2] };
}

function tryParseTag(raw: string): Anchor | undefined {
  try {
    return parseTag(raw);
  } catch {
    return undefined;
  }
}

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

function hashlineParseText(edit: string[] | string | null): string[] {
  if (edit === null) return [];
  if (typeof edit === "string") {
    const normalizedEdit = edit.endsWith("\n") ? edit.slice(0, -1) : edit;
    edit = normalizedEdit.replaceAll("\r", "").split("\n");
  }
  return stripNewLinePrefixes(edit);
}

function resolveEditAnchors(
  edits: Array<{ loc: any; content: string[] | string | null }>,
): HashlineEdit[] {
  const result: HashlineEdit[] = [];
  for (const edit of edits) {
    const lines = hashlineParseText(edit.content);
    const loc = edit.loc;

    if (loc === "append") {
      result.push({ op: "append_file", lines });
    } else if (loc === "prepend") {
      result.push({ op: "prepend_file", lines });
    } else if (typeof loc === "object") {
      if ("append" in loc) {
        const anchor = tryParseTag(loc.append);
        if (!anchor) throw new Error("append requires a valid anchor.");
        result.push({ op: "append_at", pos: anchor, lines });
      } else if ("prepend" in loc) {
        const anchor = tryParseTag(loc.prepend);
        if (!anchor) throw new Error("prepend requires a valid anchor.");
        result.push({ op: "prepend_at", pos: anchor, lines });
      } else if ("range" in loc) {
        const posAnchor = tryParseTag(loc.range.pos);
        const endAnchor = tryParseTag(loc.range.end);
        if (!posAnchor || !endAnchor) {
          throw new Error("range requires valid pos and end anchors.");
        }
        result.push({ op: "replace_range", pos: posAnchor, end: endAnchor, lines });
      } else {
        throw new Error("Unknown loc shape. Expected append, prepend, or range.");
      }
    } else {
      throw new Error(`Invalid loc value: ${JSON.stringify(loc)}`);
    }
  }
  return result;
}

class HashlineMismatchError extends Error {
  constructor(
    public readonly mismatches: HashMismatch[],
    public readonly fileLines: string[],
  ) {
    super(HashlineMismatchError.formatMessage(mismatches, fileLines));
    this.name = "HashlineMismatchError";
  }

  static formatMessage(mismatches: HashMismatch[], fileLines: string[]): string {
    const mismatchSet = new Map<number, HashMismatch>();
    for (const m of mismatches) mismatchSet.set(m.line, m);

    const displayLines = new Set<number>();
    for (const m of mismatches) {
      const lo = Math.max(1, m.line - 2);
      const hi = Math.min(fileLines.length, m.line + 2);
      for (let i = lo; i <= hi; i++) displayLines.add(i);
    }

    const sorted = [...displayLines].sort((a, b) => a - b);
    const lines: string[] = [];
    lines.push(
      `${mismatches.length} line${mismatches.length > 1 ? "s have" : " has"} changed since last read. Use the updated LINE#ID references shown below (>>> marks changed lines).`,
    );
    lines.push("");

    let prevLine = -1;
    for (const lineNum of sorted) {
      if (prevLine !== -1 && lineNum > prevLine + 1) lines.push("    ...");
      prevLine = lineNum;
      const text = fileLines[lineNum - 1];
      const hash = computeLineHash(lineNum, text);
      const prefix = `${lineNum}#${hash}`;
      if (mismatchSet.has(lineNum)) lines.push(`>>> ${prefix}:${text}`);
      else lines.push(`    ${prefix}:${text}`);
    }

    return lines.join("\n");
  }
}

function applyHashlineEdits(
  text: string,
  edits: HashlineEdit[],
): { lines: string; firstChangedLine: number | undefined; warnings?: string[] } {
  if (edits.length === 0) return { lines: text, firstChangedLine: undefined };

  const fileLines = text.split("\n");
  const originalFileLines = [...fileLines];
  let firstChangedLine: number | undefined;
  const warnings: string[] = [];

  const mismatches: HashMismatch[] = [];
  function validateRef(ref: Anchor): boolean {
    if (ref.line < 1 || ref.line > fileLines.length) {
      throw new Error(`Line ${ref.line} does not exist (file has ${fileLines.length} lines)`);
    }
    const actualHash = computeLineHash(ref.line, fileLines[ref.line - 1]);
    if (actualHash === ref.hash) return true;
    mismatches.push({ line: ref.line, expected: ref.hash, actual: actualHash });
    return false;
  }

  for (const edit of edits) {
    switch (edit.op) {
      case "replace_range": {
        const startValid = validateRef(edit.pos);
        const endValid = validateRef(edit.end);
        if (!startValid || !endValid) continue;
        if (edit.pos.line > edit.end.line) {
          throw new Error(
            `Range start line ${edit.pos.line} must be <= end line ${edit.end.line}`,
          );
        }
        break;
      }
      case "append_at":
      case "prepend_at": {
        if (!validateRef(edit.pos)) continue;
        if (edit.lines.length === 0) edit.lines = [""];
        break;
      }
      case "append_file":
      case "prepend_file": {
        if (edit.lines.length === 0) edit.lines = [""];
        break;
      }
    }
  }

  if (mismatches.length > 0) throw new HashlineMismatchError(mismatches, fileLines);

  if ((process.env.PI_HASHLINE_AUTOCORRECT_ESCAPED_TABS ?? "1") !== "0") {
    for (const edit of edits) {
      if (edit.lines.length === 0) continue;
      const hasEscapedTabs = edit.lines.some((line) => line.includes("\\t"));
      if (!hasEscapedTabs) continue;
      const hasRealTabs = edit.lines.some((line) => line.includes("\t"));
      if (hasRealTabs) continue;
      let correctedCount = 0;
      edit.lines = edit.lines.map((line) =>
        line.replace(/^((?:\\t)+)/, (escaped) => {
          correctedCount += escaped.length / 2;
          return "\t".repeat(escaped.length / 2);
        }),
      );
      if (correctedCount > 0) {
        warnings.push(
          "Auto-corrected escaped tab indentation in edit: converted leading \\t sequence(s) to real tab characters",
        );
      }
    }
  }

  for (const edit of edits) {
    let endLine: number;
    if (edit.op === "replace_range") {
      endLine = edit.end.line;
    } else {
      continue;
    }
    if (edit.lines.length === 0) continue;
    const nextSurvivingIdx = endLine;
    if (nextSurvivingIdx >= originalFileLines.length) continue;
    const nextSurvivingLine = originalFileLines[nextSurvivingIdx];
    const lastInsertedLine = edit.lines[edit.lines.length - 1];
    const trimmedNext = nextSurvivingLine.trim();
    const trimmedLast = lastInsertedLine.trim();
    if (trimmedLast.length > 0 && trimmedLast === trimmedNext) {
      const tag = `${endLine + 1}#${computeLineHash(endLine + 1, nextSurvivingLine)}`;
      warnings.push(
        `Possible boundary duplication: your last replacement line \`${trimmedLast}\` is identical to the next surviving line ${tag}. If you meant to replace the entire block, set \`end\` to ${tag} instead.`,
      );
    }
  }

  const annotated = edits.map((edit, idx) => {
    let sortLine: number;
    let precedence: number;
    switch (edit.op) {
      case "replace_range":
        sortLine = edit.end.line;
        precedence = 0;
        break;
      case "append_at":
        sortLine = edit.pos.line;
        precedence = 1;
        break;
      case "prepend_at":
        sortLine = edit.pos.line;
        precedence = 2;
        break;
      case "append_file":
        sortLine = fileLines.length + 1;
        precedence = 1;
        break;
      case "prepend_file":
        sortLine = 0;
        precedence = 2;
        break;
    }
    return { edit, idx, sortLine, precedence };
  });

  annotated.sort((a, b) => b.sortLine - a.sortLine || a.precedence - b.precedence || a.idx - b.idx);

  for (const { edit } of annotated) {
    switch (edit.op) {
      case "replace_range": {
        const count = edit.end.line - edit.pos.line + 1;
        fileLines.splice(edit.pos.line - 1, count, ...edit.lines);
        trackFirstChanged(edit.pos.line);
        break;
      }
      case "append_at": {
        fileLines.splice(edit.pos.line, 0, ...edit.lines);
        trackFirstChanged(edit.pos.line + 1);
        break;
      }
      case "prepend_at": {
        fileLines.splice(edit.pos.line - 1, 0, ...edit.lines);
        trackFirstChanged(edit.pos.line);
        break;
      }
      case "append_file": {
        if (fileLines.length === 1 && fileLines[0] === "") {
          fileLines.splice(0, 1, ...edit.lines);
          trackFirstChanged(1);
        } else {
          fileLines.splice(fileLines.length, 0, ...edit.lines);
          trackFirstChanged(fileLines.length - edit.lines.length + 1);
        }
        break;
      }
      case "prepend_file": {
        if (fileLines.length === 1 && fileLines[0] === "") {
          fileLines.splice(0, 1, ...edit.lines);
        } else {
          fileLines.splice(0, 0, ...edit.lines);
        }
        trackFirstChanged(1);
        break;
      }
    }
  }

  return {
    lines: fileLines.join("\n"),
    firstChangedLine,
    ...(warnings.length > 0 ? { warnings } : {}),
  };

  function trackFirstChanged(line: number): void {
    if (firstChangedLine === undefined || line < firstChangedLine) {
      firstChangedLine = line;
    }
  }
}

function formatHashLines(text: string, startLine = 1): string {
  const lines = text.split("\n");
  return lines
    .map((line, i) => {
      const num = startLine + i;
      return `${num}#${computeLineHash(num, line)}:${line}`;
    })
    .join("\n");
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "read",
    label: "read",
    description:
      "Read file content formatted as LINE#ID:TEXT. Use these LINE#ID anchors with edit.",
    promptSnippet:
      "Read the file first and copy LINE#ID anchors exactly from this output before edit.",
    parameters: hashlineReadSchema,
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const cwd = ctx.cwd;
      const filePath = path.isAbsolute(params.path)
        ? path.normalize(params.path)
        : path.resolve(cwd, params.path);

      const content = await readFile(filePath, "utf8");
      const allLines = content.split("\n");
      const startLine = params.offset ? Math.max(0, params.offset - 1) : 0;
      const effectiveLimit = params.limit ?? 200;
      const endLine = Math.min(startLine + effectiveLimit, allLines.length);

      if (params.offset && startLine >= allLines.length) {
        return {
          content: [
            {
              type: "text" as const,
              text: `Offset ${params.offset} is beyond end of file (${allLines.length} lines total).`,
            },
          ],
        };
      }

      const slice = allLines.slice(startLine, endLine).join("\n");
      let output = formatHashLines(slice, startLine + 1);
      if (endLine < allLines.length) {
        output += `\n\n[${allLines.length - endLine} more lines in file. Use offset=${endLine + 1} to continue]`;
      }

      return {
        content: [{ type: "text" as const, text: output }],
      };
    },
  });

  pi.registerTool({
    name: "edit",
    label: "edit",
    description:
      "Apply precise file edits using LINE#ID anchors from read output.",
    promptSnippet:
      "Read first with read, then apply minimal edits with exact LINE#ID anchors.",
    promptGuidelines: [
      "Use anchors exactly as LINE#ID from the latest read output.",
      "range requires both pos and end.",
      "After a successful edit, re-read before editing the same file again.",
    ],
    parameters: hashlineEditSchema,
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const cwd = ctx.cwd;
      const filePath = path.isAbsolute(params.path)
        ? path.normalize(params.path)
        : path.resolve(cwd, params.path);
      const movePath = params.move
        ? path.isAbsolute(params.move)
          ? path.normalize(params.move)
          : path.resolve(cwd, params.move)
        : undefined;

      if (params.delete) {
        await unlink(filePath);
        return { content: [{ type: "text" as const, text: `Deleted ${params.path}` }] };
      }

      const toolEdits = params.edits as Array<{ loc: any; content: string[] | string | null }>;

      let sourceContent: string;
      try {
        sourceContent = await readFile(filePath, "utf8");
      } catch {
        // Match oh-my-pi creation behavior: only prepend/append on missing file.
        const lines: string[] = [];
        for (const edit of toolEdits) {
          if (edit.loc === "append") lines.push(...hashlineParseText(edit.content));
          else if (edit.loc === "prepend") lines.unshift(...hashlineParseText(edit.content));
          else throw new Error(`File not found: ${params.path}`);
        }
        await writeFile(filePath, lines.join("\n"), "utf8");
        if (movePath) await rename(filePath, movePath);
        return {
          content: [
            {
              type: "text" as const,
              text: movePath ? `Created ${params.path} and moved to ${params.move}` : `Created ${params.path}`,
            },
          ],
        };
      }

      const edits = resolveEditAnchors(toolEdits);
      const result = applyHashlineEdits(sourceContent, edits);

      if (result.lines === sourceContent && !movePath) {
        throw new Error(
          `No changes made to ${params.path}. The edits produced identical content. Re-read the file and adjust anchors/content.`,
        );
      }

      await writeFile(filePath, result.lines, "utf8");
      if (movePath) await rename(filePath, movePath);

      const resultText = movePath
        ? `Moved ${params.path} to ${params.move}`
        : `Updated ${params.path}`;
      const warningsBlock = result.warnings?.length
        ? `\n\nWarnings:\n${result.warnings.join("\n")}`
        : "";

      return {
        content: [
          {
            type: "text" as const,
            text: `${resultText}${warningsBlock}`,
          },
        ],
        details: {
          firstChangedLine: result.firstChangedLine,
        },
      };
    },
  });

}
