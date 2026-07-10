# AGENTS.md

## Workflow

- Always commit changes.
- Use conventional commits.
- Use `style` only for formatting-only changes, not CSS changes.
- Prefer patch staging when there are unrelated user edits.
- Separate prompted tasks or browser annotations into atomic commits. Group meaningful chunks; there is no need to separate every annotation.
- Do not implement everything at once and split afterward. Repeat implement, then commit, for each meaningful chunk.
- For suitable projects, use `bun`; use `bunx` when needed tools are not installed.
- When changing CSS, use tokens instead of hardcoded values, keep sizes and spacing in multiples of 4, and check whether each rule is overridden or overrides anything unintended.
- Assume development is already running on localhost; only start a dev server if one is not running.
- Leave the in-app browser intact for further annotation.

## Simulator Screenshots

- When showing iOS Simulator results to Hsi for mobile review, use a Markdown inline image that points at the local screenshot file. This was the only format that rendered on mobile.
- Capture the simulator screenshot, then send it in chat like:

```md
![iOS simulator screenshot](/tmp/colorinvo-ios-sim-test.png)
```

- Codex image attachments emitted through `nodeRepl.emitImage` from PNG bytes or a `data:image/png;base64,...` URL did not render on mobile, so do not rely on those for review.
- Prefer keeping temporary screenshots out of git. `/tmp/...` is fine for one-off captures; `.codex-screenshots/` is also ignored by this repo.
