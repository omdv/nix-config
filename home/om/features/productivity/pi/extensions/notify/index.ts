/**
 * Desktop Notification Extension
 *
 * Sends a native desktop notification via notify-send (dunst) when the agent
 * finishes a turn and is waiting for input.
 */

import { execFile } from "node:child_process";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const isTextPart = (part: unknown): part is { type: "text"; text: string } =>
  Boolean(
    part &&
      typeof part === "object" &&
      "type" in part &&
      part.type === "text" &&
      "text" in part,
  );

const extractLastAssistantText = (
  messages: Array<{ role?: string; content?: unknown }>,
): string | null => {
  for (let i = messages.length - 1; i >= 0; i--) {
    const message = messages[i];
    if (message?.role !== "assistant") continue;

    const content = message.content;
    if (typeof content === "string") return content.trim() || null;

    if (Array.isArray(content)) {
      const text = content
        .filter(isTextPart)
        .map((part) => part.text)
        .join("\n")
        .trim();
      return text || null;
    }
  }
  return null;
};

const formatBody = (text: string | null): string => {
  if (!text) return "";
  // Strip markdown: remove code fences, headings, bold/italic markers
  const plain = text
    .replace(/```[\s\S]*?```/g, "[code]")
    .replace(/`[^`]+`/g, (m) => m.slice(1, -1))
    .replace(/^#{1,6}\s+/gm, "")
    .replace(/\*\*([^*]+)\*\*/g, "$1")
    .replace(/\*([^*]+)\*/g, "$1")
    .replace(/\s+/g, " ")
    .trim();
  return plain.length > 200 ? `${plain.slice(0, 199)}…` : plain;
};

const notify = (title: string, body: string, urgency: "low" | "normal" | "critical" = "normal"): void => {
  const args = [
    "--app-name=pi",
    `--urgency=${urgency}`,
    "--icon=dialog-information",
    title,
  ];
  if (body) args.push(body);
  execFile("notify-send", args, () => {
    // Ignore errors (e.g. no notification daemon running)
  });
};

export default function (pi: ExtensionAPI) {
  pi.on("agent_end", async (event) => {
    const lastText = extractLastAssistantText(event.messages ?? []);
    const body = formatBody(lastText);
    notify("π ready", body);
  });
}
