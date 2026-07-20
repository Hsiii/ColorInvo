#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ios-common.sh"

CONFIGURATION="${IOS_CONFIGURATION:-Debug}"
DERIVED_DATA_PATH="${IOS_DERIVED_DATA_PATH:-$IOS_ROOT_DIR/build/ScreenshotDerivedData}"
CAPTURE_DIR="${IOS_SCREENSHOT_CAPTURE_DIR:-$IOS_ROOT_DIR/build/AppStoreScreenshotCaptures}"
OUTPUT_DIR="${IOS_SCREENSHOT_OUTPUT_DIR:-$IOS_ROOT_DIR/assets/screenshots}"
DEVICE_NAME="${IOS_SCREENSHOT_DEVICE_NAME:-ColorInvo 14 Plus Screenshots}"
DEVICE_TYPE="${IOS_SCREENSHOT_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-14-Plus}"
RUNTIME="${IOS_SCREENSHOT_RUNTIME:-}"
SCREENSHOT_WALLPAPER_PATH="${IOS_SCREENSHOT_WALLPAPER_PATH:-}"
SCREENSHOT_WALLPAPER_PRESET="${IOS_SCREENSHOT_WALLPAPER_PRESET:-ios17-blue-light}"
SCREENSHOT_WALLPAPER_CONTAINER_PATH=""
APP_PATH="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION-iphonesimulator/$IOS_SCHEME_NAME.app"

find_screenshot_device() {
    xcrun simctl list devices available \
        | sed -nE "s/^[[:space:]]*${DEVICE_NAME//\//\\/} \\(([0-9A-F-]+)\\) .*/\\1/p" \
        | head -n 1
}

latest_ios_runtime() {
    xcrun simctl list runtimes available \
        | awk '/iOS .* - com\.apple\.CoreSimulator\.SimRuntime\.iOS-/ { runtime = $NF } END { print runtime }'
}

boot_device() {
    local device_id="$1"

    xcrun simctl boot "$device_id" >/dev/null 2>&1 || true
    xcrun simctl bootstatus "$device_id" -b >/dev/null
}

find_iphone_preset_wallpaper() {
    local wallpaper_file

    case "$SCREENSHOT_WALLPAPER_PRESET" in
        ios17-blue-light)
            wallpaper_file="Blue Light.HEIC"
            ;;
        ios17-background-light)
            wallpaper_file="Background Light.HEIC"
            ;;
        *)
            ios_die "Unsupported iPhone screenshot wallpaper preset: $SCREENSHOT_WALLPAPER_PRESET"
            ;;
    esac

    {
        find /Library/Developer/CoreSimulator/Volumes "$HOME/Library/Developer/CoreSimulator/Profiles" \
            -type f \
            -path "*iOS_17~iphone.wallpaperCollection*428w-926h@3x~iphone*assets/$wallpaper_file" \
            2>/dev/null || true
    } | sort | tail -n 1
}

prepare_screenshot_wallpaper() {
    local device_id="$1"
    local data_container
    local source_path
    local wallpaper_extension

    source_path="$SCREENSHOT_WALLPAPER_PATH"
    if [[ -z "$source_path" ]]; then
        source_path="$(find_iphone_preset_wallpaper)"
    fi

    [[ -f "$source_path" ]] \
        || ios_die "Screenshot iPhone wallpaper not found. Set IOS_SCREENSHOT_WALLPAPER_PATH or install a simulator runtime with preset $SCREENSHOT_WALLPAPER_PRESET."

    data_container="$(xcrun simctl get_app_container "$device_id" "$IOS_BUNDLE_ID_VALUE" data)"
    wallpaper_extension="${source_path##*.}"
    mkdir -p "$data_container/tmp"

    SCREENSHOT_WALLPAPER_CONTAINER_PATH="$data_container/tmp/colorinvo-showcase-wallpaper.$wallpaper_extension"
    cp "$source_path" "$SCREENSHOT_WALLPAPER_CONTAINER_PATH"
}

launch_for_screenshot() {
    local device_id="$1"
    local target="$2"

    xcrun simctl terminate "$device_id" "$IOS_BUNDLE_ID_VALUE" >/dev/null 2>&1 || true

    case "$target" in
        widget-cat|widget-wave)
            local decoration
            decoration="${target#widget-}"

            SIMCTL_CHILD_COLORINVO_SHOWCASE_DATA=1 \
                SIMCTL_CHILD_COLORINVO_SHOWCASE_WALLPAPER_PATH="$SCREENSHOT_WALLPAPER_CONTAINER_PATH" \
                SIMCTL_CHILD_COLORINVO_SCREENSHOT_TARGET=widget \
                SIMCTL_CHILD_COLORINVO_SHOWCASE_DECORATION="$decoration" \
                xcrun simctl launch --terminate-running-process "$device_id" "$IOS_BUNDLE_ID_VALUE" \
                --showcase-data --screenshot-widget >/dev/null
            ;;
        *)
            ios_die "Unknown screenshot target: $target"
            ;;
    esac
}

capture_png() {
    local device_id="$1"
    local output_path="$2"
    local width
    local height

    xcrun simctl io "$device_id" screenshot --type=png --mask=ignored "$output_path" >/dev/null
    sips -g pixelWidth -g pixelHeight "$output_path"

    width="$(sips -g pixelWidth "$output_path" | awk '/pixelWidth/ { print $2 }')"
    height="$(sips -g pixelHeight "$output_path" | awk '/pixelHeight/ { print $2 }')"
    [[ "$width" == "1284" && "$height" == "2778" ]] \
        || ios_die "Expected a 1284x2778 6.5-inch ASC screenshot, got ${width}x${height}: $output_path"
}

if [[ "$CONFIGURATION" != "Debug" ]]; then
    ios_die "Screenshot capture requires IOS_CONFIGURATION=Debug."
fi

mkdir -p "$CAPTURE_DIR" "$OUTPUT_DIR"

if [[ -z "$RUNTIME" ]]; then
    RUNTIME="$(latest_ios_runtime)"
fi
[[ -n "$RUNTIME" ]] || ios_die "No available iOS simulator runtime found."

DEVICE_ID="$(find_screenshot_device)"
if [[ -z "$DEVICE_ID" ]]; then
    DEVICE_ID="$(xcrun simctl create "$DEVICE_NAME" "$DEVICE_TYPE" "$RUNTIME")"
fi

echo "Building $IOS_SCHEME_NAME for $DEVICE_NAME..."
ios_generate_project
xcodebuild \
    -project "$IOS_PROJECT_PATH" \
    -scheme "$IOS_SCHEME_NAME" \
    -configuration "$CONFIGURATION" \
    -sdk iphonesimulator \
    -destination "id=$DEVICE_ID" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO \
    build >/dev/null

[[ -d "$APP_PATH" ]] || ios_die "Built app not found at $APP_PATH."

boot_device "$DEVICE_ID"
xcrun simctl uninstall "$DEVICE_ID" "$IOS_BUNDLE_ID_VALUE" >/dev/null 2>&1 || true
xcrun simctl install "$DEVICE_ID" "$APP_PATH"
prepare_screenshot_wallpaper "$DEVICE_ID"
xcrun simctl status_bar "$DEVICE_ID" override \
    --time 9:41 \
    --dataNetwork wifi \
    --wifiBars 3 \
    --cellularBars 4 \
    --batteryState charged \
    --batteryLevel 100 >/dev/null

CAT_CAPTURE="$CAPTURE_DIR/colorinvo-iphone-6-5-widget-cat.png"
WAVE_CAPTURE="$CAPTURE_DIR/colorinvo-iphone-6-5-widget-wave.png"

echo "Capturing cat decoration source..."
launch_for_screenshot "$DEVICE_ID" widget-cat
sleep 4
capture_png "$DEVICE_ID" "$CAT_CAPTURE"

echo "Capturing paint decoration source..."
launch_for_screenshot "$DEVICE_ID" widget-wave
sleep 4
capture_png "$DEVICE_ID" "$WAVE_CAPTURE"

echo "Composing App Store screenshots..."
swift "$IOS_ROOT_DIR/scripts/ios-compose-app-store-screenshots.swift" \
    --cat "$CAT_CAPTURE" \
    --wave "$WAVE_CAPTURE" \
    --output-dir "$OUTPUT_DIR"

echo "Generated connected 6.5-inch App Store screenshots:"
echo "  $OUTPUT_DIR/colorinvo-iphone-6-5-01-wallpaper-palette.png"
echo "  $OUTPUT_DIR/colorinvo-iphone-6-5-02-decorations.png"
echo "  $OUTPUT_DIR/colorinvo-iphone-6-5-03-scanner-widget.png"
