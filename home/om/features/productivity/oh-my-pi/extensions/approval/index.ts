import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

// Tools that require explicit user confirmation before execution.
const GUARDED_TOOLS = new Set([
  "bash",
  "edit",
  "write",
]);

// Tools that are unconditionally blocked regardless of UI availability.
const ALWAYS_BLOCK = new Set<string>([]);

const TOOL_LABEL: Record<string, string> = {
  bash:  "Auto-Execute",
  edit:  "Auto-Edit",
  write: "Auto-Write",
};

const SUMMARY_MAX_LINES = 5;

/** Clamp a string to at most maxLines newline-separated rows, appending an ellipsis line if truncated. */
function clampLines(text: string, maxLines: number): string {
  const lines = text.split("\n");
  if (lines.length <= maxLines) return text;
  return lines.slice(0, maxLines).join("\n") + "\n\u2026";
}

export default function approvalGate(pi: ExtensionAPI) {
  pi.setLabel("Explicit Approval Gate");

  // Per-session "approve all" grants. Cleared on session start.
  const approvedTools = new Set<string>();
  let syncStatus: () => void = () => {};

  async function revokeGrant(ctx: ExtensionContext): Promise<void> {
    if (!ctx.ui) return;

    if (approvedTools.size === 0) {
      ctx.ui.notify("No active 'approve all' grants to revoke.", "info");
      return;
    }

    const granted = [...approvedTools];
    const choice = await ctx.ui.select(
      "Revoke approval grant",
      [...granted.map(t => TOOL_LABEL[t] ?? t), "Revoke all"],
    );

    if (choice === undefined) return;

    if (choice === "Revoke all") {
      approvedTools.clear();
      syncStatus();
      ctx.ui.notify("All approval grants revoked.", "info");
    } else {
      const tool = granted.find(t => (TOOL_LABEL[t] ?? t) === choice);
      if (tool !== undefined) {
        approvedTools.delete(tool);
        syncStatus();
        ctx.ui.notify(`${TOOL_LABEL[tool] ?? tool} grant revoked.`, "info");
      }
    }
  }

  pi.on("session_start", async (_event, ctx) => {
    approvedTools.clear();
    syncStatus = () => {
      const labels = [...approvedTools].map(t => TOOL_LABEL[t] ?? t);
      const text = labels.length > 0
        ? `\x1b[91m${labels.join(" \u00b7 ")}\x1b[0m \u2502 ctrl+alt+r to revoke`
        : undefined;
      ctx.ui.setStatus("approval-grants", text);
    };
    syncStatus();
  });

  pi.on("tool_call", async (event, ctx) => {
    const { toolName, input } = event;

    if (ALWAYS_BLOCK.has(toolName)) {
      return { block: true, reason: `${toolName} is unconditionally blocked by policy` };
    }

    if (!GUARDED_TOOLS.has(toolName)) return;

    // Already granted for the session — pass through.
    if (approvedTools.has(toolName)) return;

    if (!ctx.hasUI) {
      // No interactive UI (headless / subagent run) — fail closed.
      return { block: true, reason: `${toolName} requires interactive approval but no UI is available` };
    }

    let summary: string;
    if (toolName === "bash") {
      summary = String(input.command ?? "(no command)");
    } else if (toolName === "edit") {
      const opCount = Array.isArray(input.edits) ? input.edits.length : "?";
      summary = `${input.path ?? "unknown file"} (${opCount} edit${opCount === 1 ? "" : "s"})`;
    } else if (toolName === "write") {
      summary = String(input.path ?? "unknown file");
    } else {
      summary = JSON.stringify(input);
    }

    const choice = await ctx.ui.select(
      `Approve: ${toolName}\n${clampLines(summary, SUMMARY_MAX_LINES)}`,
      ["Approve once", "Approve all (this session)", "Deny"],
    );

    if (choice === "Approve all (this session)") {
      approvedTools.add(toolName);
      syncStatus();
      return;
    }

    if (choice === "Approve once") {
      return;
    }

    // Deny covers both explicit "Deny" and dialog dismissed (undefined).
    return { block: true, reason: `User denied: ${toolName}` };
  });

  // ctrl+alt+r — revoke a session grant interactively.
  pi.registerShortcut("ctrl+alt+r", {
    description: "Revoke an approval grant for the current session",
    handler: revokeGrant,
  });

  pi.registerCommand("approval-revoke", {
    description: "Revoke a session-level 'approve all' grant for one or all tools",
    handler: revokeGrant,
  });
}
