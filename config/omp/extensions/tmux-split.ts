// tmux-split — fork or branch the current omp session into a new tmux pane.
//
// /split [v]   — fork the full session and open it in a tmux split
//                (horizontal split by default; pass "v" for a vertical split).
// /splitb [v]  — pick an earlier user message, fork the session with that
//                message and everything after it dropped, and open the
//                branched copy in a tmux split.
//
// The current session is never touched: both commands clone the JSONL on
// disk (via `omp --fork`) and the new pane runs an independent session.
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

interface TextBlock {
	type?: string;
	text?: string;
}

interface SessionEntry {
	type?: string;
	message?: { role?: string; content?: string | TextBlock[] };
}

// Narrow view of the runtime SessionManager surface this extension uses.
interface SessionManagerLike {
	getSessionFile(): string | undefined;
	getHeader(): unknown;
	getBranch(): SessionEntry[];
	flush(): Promise<void>;
}

interface CommandCtx {
	cwd: string;
	sessionManager: SessionManagerLike;
	ui: {
		notify(message: string, level: string): void;
		select(title: string, options: string[]): Promise<string | undefined>;
	};
}

function entryText(entry: SessionEntry): string {
	const c = entry.message?.content;
	const text =
		typeof c === "string"
			? c
			: Array.isArray(c)
				? c
						.filter((b) => b?.type === "text")
						.map((b) => b.text ?? "")
						.join(" ")
				: "";
	return text.replace(/\s+/g, " ").trim();
}

export default function tmuxSplit(pi: ExtensionAPI) {
	pi.setLabel("Tmux Split");

	async function openSplit(ctx: CommandCtx, args: string, forkPath: string) {
		if (!process.env.TMUX) {
			ctx.ui.notify("Not inside tmux", "error");
			return;
		}
		const flag = args.trim().split(/\s+/)[0] === "v" ? "-v" : "-h";
		const quoted = `'${forkPath.replace(/'/g, `'\\''`)}'`;
		const pane = process.env.TMUX_PANE;
		const r = await pi.exec("tmux", [
			"split-window",
			flag,
			...(pane ? ["-t", pane] : []),
			"-c",
			ctx.cwd,
			`omp --fork ${quoted}`,
		]);
		if (r.code !== 0) {
			ctx.ui.notify(`tmux failed: ${r.stderr.trim()}`, "error");
		}
	}

	pi.registerCommand("split", {
		description: "Fork this session into a tmux split (arg: v for vertical)",
		handler: async (args: string, rawCtx: unknown) => {
			const ctx = rawCtx as CommandCtx; // runtime ExtensionCommandContext; typed surface above
			const file = ctx.sessionManager.getSessionFile();
			if (!file) {
				ctx.ui.notify("Session is not persisted; cannot fork", "error");
				return;
			}
			await ctx.sessionManager.flush();
			await openSplit(ctx, args, file);
		},
	});

	pi.registerCommand("splitb", {
		description:
			"Branch from an earlier user message into a tmux split (arg: v for vertical)",
		handler: async (args: string, rawCtx: unknown) => {
			const ctx = rawCtx as CommandCtx; // runtime ExtensionCommandContext; typed surface above
			const sm = ctx.sessionManager;
			const file = sm.getSessionFile();
			if (!file) {
				ctx.ui.notify("Session is not persisted; cannot fork", "error");
				return;
			}
			await sm.flush();

			const branch = sm.getBranch();
			const userIdxs: number[] = [];
			for (let i = 0; i < branch.length; i++) {
				const e = branch[i];
				if (e.type === "message" && e.message?.role === "user") userIdxs.push(i);
			}
			if (userIdxs.length === 0) {
				ctx.ui.notify("No user messages to branch from", "error");
				return;
			}

			const labels = userIdxs.map((i, n) => {
				const t = entryText(branch[i]) || "(non-text message)";
				return `${n + 1}. ${t.slice(0, 80)}`;
			});
			const picked = await ctx.ui.select(
				"Branch: drop this message and everything after it",
				labels,
			);
			if (picked == null) return;
			const idx = userIdxs[labels.indexOf(picked)];

			// Truncated copy: header + branch entries strictly before the picked
			// user message. `omp --fork <path>` re-headers it with a fresh id.
			const lines = [sm.getHeader(), ...branch.slice(0, idx)]
				.map((e) => JSON.stringify(e))
				.join("\n");
			const tmp = `${process.env.TMPDIR ?? "/tmp/"}omp-splitb-${Date.now()}.jsonl`;
			await Bun.write(tmp, `${lines}\n`);

			await openSplit(ctx, args, tmp);
		},
	});
}
