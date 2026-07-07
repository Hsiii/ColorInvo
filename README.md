<div align="center">

  <img src="apps/ios/Resources/ColorInvo/Assets.xcassets/AppIcon.appiconset/AppIcon-10241024-1x.png" alt="ColorInvo app icon" width="96" />
<h1>ColorInvo</h1>
  <p>Make your Taiwan mobile invoice carrier barcode match your wallpaper.</p>
  <a href="./README.zh.md">繁體中文</a>
</div>

## Why

* Instant Barcode Access: Show your invoice barcode in a second with an iOS widget.
* Wallpaper-Based Theming: Pick a wallpaper, and the app extracts representative colors and a small preview to generate matching themes.
* Guaranteed Scannability: Barcode colors are generated to meet commercial scanner reflectance and contrast requirements.

> We plan to release this to App Store in the future, hold on tight!

## Codex simulator screenshots

To send a visible iOS Simulator screenshot in Codex chat, capture the booted simulator and attach the PNG bytes to the chat result instead of linking to a local Mac path:

```sh
bun run ios:screenshot-chat
```

The script writes an absolute PNG path under `.codex-screenshots/` and prints a `node_repl` snippet. Run that snippet with the `node_repl` `js` tool so Codex chat receives the image bytes through `nodeRepl.emitImage(...)`; this makes the screenshot viewable from Codex mobile too.
