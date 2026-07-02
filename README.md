# ColorInvo

Minimal iOS app for storing a Taiwan mobile invoice carrier barcode with color presets.

## Build

```bash
bun run ios:check
bun run ios:simulator
```

## Device Build

Copy `.env.example` to `.env`, set `APPLE_TEAM_ID`, then use:

```bash
bun run ios:device
```

## Release Helpers

With the same `.env`, fill the App Store Connect credentials, then use:

```bash
bun run ios:archive
bun run ios:export
bun run ios:upload
```
