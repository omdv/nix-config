import fs from "fs";
import path from "path";
import type { DcpState } from "./state";

interface ContextUsageLike {
	tokens: number | null;
	contextWindow: number;
}

interface BenchmarkRun {
	runId: string;
	projectPath: string;
	startedAt: number;
	manualModeStart: boolean;
	manualModeTransitions: number;
	toolCallsByName: Record<string, number>;
	toolErrorsByName: Record<string, number>;
	compressToolCalls: number;
	nudges: Record<string, number>;
	maxContextPercent: number;
	snapshotCount: number;
	timeAbove70Ms: number;
	timeAbove85Ms: number;
	timeAbove95Ms: number;
	lastUsageTs: number | null;
	lastUsagePercent: number | null;
}

function inc(map: Record<string, number>, key: string): void {
	map[key] = (map[key] ?? 0) + 1;
}

function appendJsonl(filePath: string, records: unknown[]): void {
	if (records.length === 0) return;
	const payload = records.map((r) => JSON.stringify(r)).join("\n") + "\n";
	fs.appendFileSync(filePath, payload, "utf8");
}

export class BenchmarkLogger {
	private readonly dir: string;
	private readonly runsPath: string;
	private readonly snapshotsPath: string;
	private readonly eventsPath: string;
	private run: BenchmarkRun | null = null;
	private snapshotsBuffer: unknown[] = [];
	private eventsBuffer: unknown[] = [];
	private readonly flushEvery = 25;

	constructor(projectDir: string) {
		this.dir = path.join(projectDir, ".dcp");
		this.runsPath = path.join(this.dir, "benchmark-runs.jsonl");
		this.snapshotsPath = path.join(this.dir, "benchmark-snapshots.jsonl");
		this.eventsPath = path.join(this.dir, "benchmark-events.jsonl");
		fs.mkdirSync(this.dir, { recursive: true });
	}

	startSession(manualMode: boolean): void {
		const now = Date.now();
		this.run = {
			runId: `run-${now}`,
			projectPath: process.cwd(),
			startedAt: now,
			manualModeStart: manualMode,
			manualModeTransitions: 0,
			toolCallsByName: {},
			toolErrorsByName: {},
			compressToolCalls: 0,
			nudges: {},
			maxContextPercent: 0,
			snapshotCount: 0,
			timeAbove70Ms: 0,
			timeAbove85Ms: 0,
			timeAbove95Ms: 0,
			lastUsageTs: null,
			lastUsagePercent: null,
		};
		this.recordEvent("session_start", { manualMode });
	}

	recordToolCall(toolName: string): void {
		if (!this.run) return;
		inc(this.run.toolCallsByName, toolName);
		if (toolName === "compress") this.run.compressToolCalls++;
	}

	recordToolResult(toolName: string, isError: boolean): void {
		if (!this.run) return;
		if (isError) inc(this.run.toolErrorsByName, toolName);
	}

	recordManualModeChange(manualMode: boolean): void {
		if (!this.run) return;
		this.run.manualModeTransitions++;
		this.recordEvent("manual_mode_changed", { manualMode });
	}

	recordNudge(nudgeType: string): void {
		if (!this.run) return;
		inc(this.run.nudges, nudgeType);
		this.recordEvent("nudge", { nudgeType });
	}

	recordEvent(type: string, payload: Record<string, unknown> = {}): void {
		if (!this.run) return;
		this.eventsBuffer.push({
			ts: Date.now(),
			runId: this.run.runId,
			type,
			payload,
		});
		if (this.eventsBuffer.length >= this.flushEvery) this.flush();
	}

	recordSnapshot(
		usage: ContextUsageLike | null,
		state: DcpState,
		manualMode: boolean,
	): void {
		if (!this.run) return;
		const now = Date.now();
		let contextPercent: number | null = null;
		if (usage && usage.tokens !== null && usage.contextWindow > 0) {
			contextPercent = usage.tokens / usage.contextWindow;
			if (contextPercent > this.run.maxContextPercent) {
				this.run.maxContextPercent = contextPercent;
			}
		}

		if (this.run.lastUsageTs !== null && this.run.lastUsagePercent !== null) {
			const dt = Math.max(0, now - this.run.lastUsageTs);
			if (this.run.lastUsagePercent >= 0.7) this.run.timeAbove70Ms += dt;
			if (this.run.lastUsagePercent >= 0.85) this.run.timeAbove85Ms += dt;
			if (this.run.lastUsagePercent >= 0.95) this.run.timeAbove95Ms += dt;
		}
		this.run.lastUsageTs = now;
		this.run.lastUsagePercent = contextPercent;

		this.run.snapshotCount++;
		this.snapshotsBuffer.push({
			ts: now,
			runId: this.run.runId,
			manualMode,
			contextTokens: usage?.tokens ?? null,
			contextWindow: usage?.contextWindow ?? null,
			contextPercent,
			pruneOps: state.totalPruneCount,
			tokensSaved: state.tokensSaved,
			tokensReplacedByCompression: state.tokensReplacedByCompression,
			activeCompressionBlocks: state.compressionBlocks.filter((b) => b.active)
				.length,
			trackedToolCalls: state.toolCalls.size,
			prunedTools: state.prunedToolIds.size,
		});
		if (this.snapshotsBuffer.length >= this.flushEvery) this.flush();
	}

	status(state: DcpState, usage: ContextUsageLike | null): string {
		if (!this.run) return "Benchmark: inactive";
		const now = Date.now();
		const durationSec = Math.round((now - this.run.startedAt) / 1000);
		const contextPct =
			usage && usage.tokens !== null && usage.contextWindow > 0
				? `${(100 * (usage.tokens / usage.contextWindow)).toFixed(1)}%`
				: "n/a";
		return [
			"DCP Benchmark:",
			`  Run ID: ${this.run.runId}`,
			`  Duration: ${durationSec}s`,
			`  Mode: ${state.manualMode ? "manual" : "auto"}`,
			`  Context now: ${contextPct}`,
			`  Snapshots: ${this.run.snapshotCount}`,
			`  Runs file: ${this.runsPath}`,
			`  Snapshots file: ${this.snapshotsPath}`,
			`  Events file: ${this.eventsPath}`,
		].join("\n");
	}

	flush(): void {
		appendJsonl(this.snapshotsPath, this.snapshotsBuffer);
		appendJsonl(this.eventsPath, this.eventsBuffer);
		this.snapshotsBuffer = [];
		this.eventsBuffer = [];
	}

	endSession(state: DcpState): void {
		if (!this.run) return;
		const now = Date.now();
		this.recordEvent("session_shutdown", {});
		this.flush();
		appendJsonl(this.runsPath, [
			{
				runId: this.run.runId,
				projectPath: this.run.projectPath,
				startedAt: this.run.startedAt,
				endedAt: now,
				durationSec: Math.round((now - this.run.startedAt) / 1000),
				manualModeStart: this.run.manualModeStart,
				manualModeEnd: state.manualMode,
				manualModeTransitions: this.run.manualModeTransitions,
				toolCallsByName: this.run.toolCallsByName,
				toolErrorsByName: this.run.toolErrorsByName,
				compressToolCalls: this.run.compressToolCalls,
				nudges: this.run.nudges,
				maxContextPercent: this.run.maxContextPercent,
				snapshotCount: this.run.snapshotCount,
				timeAbove70Ms: this.run.timeAbove70Ms,
				timeAbove85Ms: this.run.timeAbove85Ms,
				timeAbove95Ms: this.run.timeAbove95Ms,
				tokensSaved: state.tokensSaved,
				tokensReplacedByCompression: state.tokensReplacedByCompression,
				totalPruneCount: state.totalPruneCount,
				compressionBlocksActive: state.compressionBlocks.filter((b) => b.active)
					.length,
				compressionBlocksTotal: state.compressionBlocks.length,
			},
		]);
		this.run = null;
	}
}
