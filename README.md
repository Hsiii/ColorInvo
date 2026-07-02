# ColorInvo

Minimal iOS app for storing a Taiwan mobile invoice carrier barcode with color presets.

## Build

```bash
bun run ios:check
bun run ios:simulator
```

## Release Helpers

Copy `.env.example` to `.env`, fill the Apple credentials, then use:

```bash
bun run ios:archive
bun run ios:export
bun run ios:upload
```
