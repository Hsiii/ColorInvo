<div align="center">

  <img src="apps/ios/Resources/ColorInvo/Assets.xcassets/AppIcon.appiconset/AppIcon-10241024-1x.png" alt="ColorInvo app icon" width="96" />
<h1>ColorInvo</h1>
<p>Make your Taiwan mobile invoice carrier barcode match your wallpaper on iOS and Android.</p>
  <a href="./README.zh.md">繁體中文</a>
</div>

## Why

* Instant Barcode Access: Show your invoice barcode in a second with an iOS or Android widget.
* Wallpaper-Based Theming: Pick a wallpaper, and the app extracts representative colors and a small preview to generate matching themes.
* Guaranteed Scannability: Barcode colors are generated to meet commercial scanner reflectance and contrast requirements.

## Run on Android

Install Android Studio with the Android 16 / API 36 SDK, start an emulator or connect an unlocked device, then run:

```sh
bun run android
```

Run unit tests, lint, and compile both app and instrumented-test APKs:

```sh
bun run android:check
```

With a device or emulator connected, run the full UI/widget tests:

```sh
bun run android:test:device
```

## Google Play release

1. Copy `apps/android/keystore.properties.example` to `apps/android/keystore.properties` and point it at the private Play upload keystore.
2. Install the upload tooling with `cd apps/android && bundle install`.
3. Set `PLAY_SERVICE_ACCOUNT_JSON` to a Play Console service-account key that can release this app.
4. Run `bun run android:bundle` for a signed Android App Bundle, or `bun run android:release` to check, bundle, and upload to the `internal` track.

`ANDROID_VERSION_NAME`, `ANDROID_VERSION_CODE`, `PLAY_TRACK`, and staged-release options can be set in `.env.local`. Store metadata is in `apps/android/play`; the privacy policy is [colorinvo.hsichen.dev/en/privacy](https://colorinvo.hsichen.dev/en/privacy). Generate localized phone screenshots from a connected API 36 device with `bun run android:screenshots`, then opt into uploading them with `PLAY_UPLOAD_SCREENSHOTS=true`.

See the [complete Play Console checklist](apps/android/PLAY_RELEASE.md) for one-time setup, policy declarations, store artwork, and CI secrets.

## Run on iOS Simulator

Build ColorInvo, boot and open an available iPhone simulator, install the app, and launch it:

```sh
bun run simulator
```

## Codex iOS simulator screenshots

To send a visible iOS Simulator screenshot in Codex chat, capture the booted simulator and attach the PNG bytes to the chat result instead of linking to a local Mac path:

```sh
bun run ios:screenshot-chat
```

The script writes an absolute PNG path under `.codex-screenshots/` and prints a `node_repl` snippet. Run that snippet with the `node_repl` `js` tool so Codex chat receives the image bytes through `nodeRepl.emitImage(...)`; this makes the screenshot viewable from Codex mobile too.
