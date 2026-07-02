# ColorInvo

Minimal iOS app for storing a Taiwan mobile invoice carrier barcode with color presets.

## Build

```bash
bun run ios:check
bun run ios:simulator
```

## Device Build

Set `APPLE_TEAM_ID` in `.env`, or let the scripts reuse `../OnTrack/.env` when present, then use:

```bash
bun run ios:device
```

The Apple Developer account must have `group.dev.hsichen.colorinvo` enabled for both `dev.hsichen.colorinvo` and `dev.hsichen.colorinvo.widget`.

## Release Helpers

With the same `.env`, fill the App Store Connect credentials, then use:

```bash
bun run ios:archive
bun run ios:export
bun run ios:upload
```
