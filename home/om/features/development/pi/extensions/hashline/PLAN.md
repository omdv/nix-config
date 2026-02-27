# Hashline Gap Plan (vs target Dirac-style behavior)

Target folder requested: `@home/om/features/development/pi/extensions/hashline/`
Resolved on disk: `/home/om/nix-config/home/om/features/development/pi/extensions/hashline/`

## Objective

Bring `hashline` extension behavior in line with the desired safety and reliability model:

- Stateful anchors that are isolated per task/session
- Deterministic anchored edits (strict stale-anchor rejection)
- Robust multi-edit behavior with clear diagnostics
- Better read/edit safety at scale (hashes, size guardrails)

---

## Current State Summary

Implemented already:

- Stateful line anchors with reconcile-by-diff (`reconcileAnchors`)
- Batched edits (`path+edits`, `files[]`)
- Preflight planning + commit phase + rollback
- Overlap detection for `replace_range`

Main gaps:

1. Global anchor state (not task-scoped)
2. Weak anchor validation (`LINE#ID` only)
3. Anchor drift auto-remap (warning, not failure)
4. No partial-success per-edit reporting
5. No file hash/change guard in `read`
6. No large-file read guardrails
7. Replace-with-empty inserts blank line (not true delete)
8. No anchor cache bounds / eviction

---

## Prioritized Plan

## P0 (must-have correctness/safety)

### P0.1 Task-scoped anchor state

**Gap:** `anchorStateByFile` is global; multiple tasks can interfere.

**Implementation:**

- Replace `Map<string, FileAnchorState>` with nested map: `Map<string, Map<string, FileAnchorState>>`.
- Add helpers:
  - `getTaskId(ctx): string` (derive stable session/task key; fallback `"default"`)
  - `getTaskState(taskId)`
- Update all state access sites:
  - `reconcileAnchors(...)` -> include `taskId`
  - `dropAnchorState(...)` -> include `taskId`
  - move/rename state transfer in commit phase -> within task map

**Acceptance criteria:**

- Same file edited concurrently by two tasks keeps independent anchors.

---

### P0.2 Strict anchor validation with content proof

**Gap:** Anchor reference only verifies ID/line pair; no content match.

**Implementation:**

- Extend wire format from `LINE#ID` to `LINE#ID:TEXT` (or accept both with strict mode default).
- Add parser that captures optional trailing text.
- In `resolveAnchor`, validate:
  1. ID exists
  2. line resolves uniquely and exactly
  3. if content provided, it equals current file line exactly
- On mismatch: fail with actionable error (`re-read file; anchor stale/content mismatch`).

**Acceptance criteria:**

- If line content changed after read, edit fails deterministically.
- No nearest-line auto-fix in strict mode.

---

### P0.3 Disable silent anchor drift remap (strict by default)

**Gap:** `resolveAnchor` currently remaps moved anchors and warns.

**Implementation:**

- Add mode flag (internal constant or tool param):
  - `strictAnchorResolution = true` default
- In strict mode:
  - If line number changed or multiple candidates exist, error instead of remap.
- Optionally keep legacy fallback path for non-strict mode.

**Acceptance criteria:**

- Moved anchors fail rather than mutating unintended code.

---

### P0.4 Fix replace-to-empty semantics

**Gap:** empty insert coerced to `[""]`, so deletion becomes blank line.

**Implementation:**

- In `applyHashlineEdits`, stop forcing `item.insert.length===0 ? [""] : item.insert`.
- For replace ops, permit zero inserted lines (true deletion).
- Keep append/prepend behavior explicit (if empty content, make it no-op or reject clearly).

**Acceptance criteria:**

- Replacing a range with empty content actually removes lines.

---

### P0.5 Add anchor state bounds (memory safety)

**Gap:** no LRU/limits.

**Implementation:**

- Add caps:
  - max tracked tasks
  - max files per task
  - optional max lines per tracked file (fallback deterministic anchors)
- Apply LRU eviction at task and file level.

**Acceptance criteria:**

- Long-running sessions do not grow memory unbounded.

---

## P1 (workflow reliability / operator safety)

### P1.1 Read tool file hash + unchanged short-circuit signal

**Gap:** no `[File Hash: ...]` metadata.

**Implementation:**

- Add `contentHash(content)` (FNV-1a or equivalent).
- `read` output prefix:
  - `[File Hash: abcdef12]`
- Track last hash per task+file; if unchanged and full read requested, return concise unchanged message.

**Acceptance criteria:**

- Model can cheaply detect stale context and avoid redundant full-file reads.

---

### P1.2 Large file read guardrails

**Gap:** no full-read size threshold.

**Implementation:**

- Add max full-read bytes (e.g. 50KB).
- If exceeded and no line range requested, return error/instruction to use `offset/limit`.

**Acceptance criteria:**

- Prevents context flooding for large files.

---

### P1.3 Partial-success semantics for edit batches

**Gap:** one failing edit can fail entire file preflight.

**Implementation:**

- During parse/resolve phase, collect `resolvedEdits[]` + `failedEdits[]`.
- Apply all resolved edits in descending line order.
- Response contract:
  - if all fail => error
  - if some succeed => success with failure diagnostics block
- Include per-edit diagnostics (bad anchor format, not found, content mismatch, overlap, etc.).

**Acceptance criteria:**

- Valid edits are not blocked by unrelated invalid edits.

---

### P1.4 Multi-edit ordering and overlap policy hardening

**Gap:** overlap checked for replace ranges only; mixed insert/replace edge cases may be ambiguous.

**Implementation:**

- Validate edit operations for deterministic ordering:
  - forbid conflicting operations on same anchor/range in one batch unless explicitly supported
- Keep descending-application order; document precedence rules in tool prompt.

**Acceptance criteria:**

- Same input always yields same output, with no implicit tie ambiguity.

---

## P2 (UX and migration)

### P2.1 Backward compatibility shim for anchor format

**Gap:** existing prompts may send `LINE#ID`.

**Implementation:**

- Parse both:
  - strict preferred: `LINE#ID:TEXT`
  - legacy: `LINE#ID` (emit warning/deprecation notice)
- After grace period, enforce strict format.

**Acceptance criteria:**

- No abrupt breakage; migration path is explicit.

---

### P2.2 Prompt/schema updates

**Gap:** schema docs/guidelines do not enforce strict content-coupled anchors.

**Implementation:**

- Update `hashlineReadSchema` / `hashlineEditSchema` descriptions.
- Update `promptSnippet` and `promptGuidelines`:
  - always use latest anchors
  - include full `LINE#ID:TEXT` references
  - batch multiple edits in one call
  - avoid overlapping/conflicting edits

**Acceptance criteria:**

- Model behavior aligns with strict protocol.

---

### P2.3 Tests and fixtures

**Gap:** no explicit regression suite for anchor strictness + partial success.

**Implementation test matrix:**

1. Anchor stability across unchanged lines
2. Anchor changes on insertion/deletion
3. Strict content mismatch rejection
4. No drift remap in strict mode
5. Multi-edit partial success
6. Full-failure behavior
7. Replace-empty deletes lines
8. Large-file guardrail
9. Task isolation (same file, two tasks)
10. Rollback integrity for multi-file commit errors

**Acceptance criteria:**

- All above scenarios covered by automated tests.

---

## Suggested Execution Order

1. **P0.4** delete semantics fix (small, high-impact)
2. **P0.1 + P0.5** state model refactor (task scope + bounds)
3. **P0.2 + P0.3** strict anchor protocol
4. **P1.3 + P1.4** partial-success + ordering hardening
5. **P1.1 + P1.2** read hash + large-file safety
6. **P2** docs/schema/tests + compatibility shim

---

## Implementation Notes (code hotspots)

Primary file: `index.ts`

- State model: `anchorStateByFile`, `reconcileAnchors`, `dropAnchorState`
- Anchor parse/resolve: `parseAnchorRef`, `resolveAnchor`, `buildAnchorIndex`
- Apply behavior: `applyHashlineEdits`
- Read metadata: `read` tool `execute`
- Batch/response semantics: `edit` tool `execute`, plan/apply reporting

---

## Definition of Done

- Strict, task-isolated anchor protocol is default.
- Multi-edit is deterministic, supports partial success with clear diagnostics.
- Read/edit safety guardrails added (hash + size limits).
- Delete semantics corrected.
- Regression tests cover all critical edge cases.
