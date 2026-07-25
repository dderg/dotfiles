// prompt-stash — Claude Code style "Ctrl+S" draft stashing.
//
// Ctrl+S with text in the editor stashes it (editor clears). Type and send a
// different message; once that turn finishes, the stash restores into the
// (now empty) editor automatically. Ctrl+S again on an empty editor restores
// the stash immediately without waiting for a turn to finish. Single slot —
// stashing again overwrites whatever was stashed before.
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

export default function promptStash(pi: ExtensionAPI) {
	pi.setLabel("Prompt Stash");

	let stash: string | null = null;

	pi.registerShortcut("ctrl+s", {
		description: "Stash/restore the draft prompt",
		handler(ctx) {
			const current = ctx.ui.getEditorText();

			if (current.trim().length > 0) {
				stash = current;
				ctx.ui.setEditorText("");
				ctx.ui.setStatus("stash", "\u{1F4CC} stashed");
				ctx.ui.notify("Draft stashed", "info");
				return;
			}

			if (stash !== null) {
				ctx.ui.setEditorText(stash);
				stash = null;
				ctx.ui.setStatus("stash", undefined);
				ctx.ui.notify("Draft restored", "info");
			}
		},
	});

	pi.on("turn_end", async (_event, ctx) => {
		if (stash === null) return;
		if (ctx.ui.getEditorText().trim().length > 0) return;
		ctx.ui.setEditorText(stash);
		stash = null;
		ctx.ui.setStatus("stash", undefined);
		ctx.ui.notify("Draft restored", "info");
	});
}
