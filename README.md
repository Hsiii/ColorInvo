<h1 align="center">ColorInvo</h1>
<div align="center">

  Make your Taiwan mobile invoice carrier barcode match your wallpaper.
  Pick an image, let ColorInvo build the palette, and keep a beautiful scan-ready barcode on your Home Screen.

  <img src="Resources/ColorInvo/Assets.xcassets/AppIcon.appiconset/AppIcon-10241024-1x.png" alt="ColorInvo app icon" width="96" />

  <a href="#how-it-works">How it works</a>
   ·
  <a href="#development">Development</a>
   ·
  <a href="#release">Release</a>
   ·
  <a href="./README.zh.md">繁體中文</a>
</div>

## Why

- **Wallpaper-matched:** Choose the wallpaper image you already like, and ColorInvo turns it into barcode colors that feel at home on your screen.
- **Autonomous color work:** The app analyzes the image, generates matching palettes, and applies the first usable result so you are not tuning colors by hand.
- **Quick setup:** Enter the Taiwan mobile invoice carrier code, pick a wallpaper image, save, and the widget reloads with the same settings.
- **Beautiful by source:** The palette comes from your own wallpaper instead of generic theme presets, so the barcode looks intentional beside your icons.
- **Scanner-aware:** ColorInvo checks barcode and background colors against scanner-oriented reflectance guidance before saving.
- **Private by default:** Carrier settings and wallpaper-derived colors stay in the shared app group on device.

## How It Works

1. Enter your Taiwan mobile invoice carrier code.
2. Select the wallpaper image you want the barcode to match.
3. ColorInvo extracts a dominant color and builds scan-conscious barcode palettes from it.
4. Save once, then add the medium iOS widget for a matching Home Screen barcode.

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

This project is being prepared for a possible App Store release, so the archive, export, and upload helpers are kept reproducible while listing and review details are finalized.

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

ColorInvo stores the carrier code and palette in the shared app group so the app and widget can read the same settings. Wallpaper-derived palettes are generated on device from the image selected by the user.

## Troubleshooting

If project generation fails, confirm `xcodegen` is installed and available on `PATH`. If device signing fails, verify `APPLE_TEAM_ID`, bundle identifiers, and app-group capabilities in the Apple Developer portal. If upload auth fails, set `ASC_KEY_ID`, `ASC_ISSUER_ID`, and `ASC_KEY_PATH` together.
