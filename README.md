<h1 align="center">ColorInvo</h1>
<div align="center">

  Taiwan mobile invoice carrier barcode storage with scan-safe color palettes and a WidgetKit preview.

  <img src="Resources/ColorInvo/Assets.xcassets/AppIcon.appiconset/AppIcon-10241024-1x.png" alt="ColorInvo app icon" width="96" />

  <a href="#development">Development</a>
   ·
  <a href="#release">Release</a>
   ·
  <a href="./README.zh.md">繁體中文</a>
</div>

## Why

- **Carrier first:** Store a Taiwan mobile invoice carrier code and keep the barcode ready.
- **Widget ready:** Preview the barcode in-app before adding the iOS widget.
- **Scan-safe colors:** Presets and custom colors are checked against scanner-oriented contrast guidance.
- **Wallpaper palettes:** Generate three color combinations from a selected wallpaper image.
- **Local storage:** Carrier settings are stored in the app group for the app and widget.

## Requirements

- macOS with Xcode installed
- iOS 17 SDK or newer
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [Bun](https://bun.sh)
- Apple Developer account for physical device, widget entitlement, archive, or upload workflows

## First Run

Install tooling, generate the Xcode project, then build for the simulator:

```bash
brew install xcodegen
make check
```

Open `ColorInvo.xcodeproj` in Xcode when you want to run or inspect the generated project directly.

## Development

Common commands are exposed through both `make` and `bun run`:

| Task | Make | Bun |
| --- | --- | --- |
| Generate project | `make generate` | `bun run generate` |
| Full local check | `make check` | `bun run check` |
| Simulator build | `make simulator` | `bun run simulator` |
| Device install and launch | `make device` | `bun run ios` |
| Clean build products | `make clean` | - |

The check command regenerates the Xcode project, validates localization files, verifies app-group settings, and runs a simulator build.

## Device Build

Copy `.env.example` to `.env` or `.env.local`, then set `APPLE_TEAM_ID`:

```bash
APPLE_TEAM_ID=XXXXXXXXXX
```

Build, install, and launch on a connected device:

```bash
make device
```

The Apple Developer account must have `group.dev.hsichen.colorinvo` enabled for both `dev.hsichen.colorinvo` and `dev.hsichen.colorinvo.widget`.

## Release

Set the same `APPLE_TEAM_ID` plus App Store Connect API key values in `.env` or `.env.local`:

```bash
ASC_KEY_ID=
ASC_ISSUER_ID=
ASC_KEY_PATH=
```

Then archive, export, or upload:

```bash
make archive
make export
make upload
```

For an interactive archive and upload flow:

```bash
make release
```

## Privacy

ColorInvo stores the carrier code and palette in the shared app group so the app and widget can read the same settings. Wallpaper-derived palettes are generated from the image selected by the user on device.

## Troubleshooting

If project generation fails, confirm `xcodegen` is installed and available on `PATH`. If device signing fails, verify `APPLE_TEAM_ID`, bundle identifiers, and app-group capabilities in the Apple Developer portal. If upload auth fails, set `ASC_KEY_ID`, `ASC_ISSUER_ID`, and `ASC_KEY_PATH` together.
