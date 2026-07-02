#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ios-common.sh"

CONFIGURATION="${IOS_CONFIGURATION:-Debug}"
DERIVED_DATA_PATH="${IOS_DERIVED_DATA_PATH:-$IOS_ROOT_DIR/build/ScreenshotDerivedData}"
OUTPUT_DIR="${IOS_SCREENSHOT_OUTPUT_DIR:-$IOS_ROOT_DIR/AppStore/Screenshots}"
DEVICE_NAME="${IOS_SCREENSHOT_DEVICE_NAME:-ColorInvo 14 Plus Screenshots}"
DEVICE_TYPE="${IOS_SCREENSHOT_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-14-Plus}"
RUNTIME="${IOS_SCREENSHOT_RUNTIME:-}"
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

launch_for_screenshot() {
    local device_id="$1"
    local target="$2"

    xcrun simctl terminate "$device_id" "$IOS_BUNDLE_ID_VALUE" >/dev/null 2>&1 || true

    case "$target" in
        main)
            SIMCTL_CHILD_COLORINVO_SHOWCASE_DATA=1 \
                xcrun simctl launch --terminate-running-process "$device_id" "$IOS_BUNDLE_ID_VALUE" \
                --showcase-data >/dev/null
            ;;
        widget)
            SIMCTL_CHILD_COLORINVO_SHOWCASE_DATA=1 \
                SIMCTL_CHILD_COLORINVO_SCREENSHOT_TARGET=widget \
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

mkdir -p "$OUTPUT_DIR"

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
xcrun simctl status_bar "$DEVICE_ID" override \
    --time 9:41 \
    --dataNetwork wifi \
    --wifiBars 3 \
    --cellularBars 4 \
    --batteryState charged \
    --batteryLevel 100 >/dev/null

MAIN_OUTPUT="$OUTPUT_DIR/colorinvo-iphone-6-5-main.png"
WIDGET_OUTPUT="$OUTPUT_DIR/colorinvo-iphone-6-5-widget.png"

echo "Capturing main screenshot..."
launch_for_screenshot "$DEVICE_ID" main
sleep 7
capture_png "$DEVICE_ID" "$MAIN_OUTPUT"

echo "Capturing widget help screenshot..."
launch_for_screenshot "$DEVICE_ID" widget
sleep 4
capture_png "$DEVICE_ID" "$WIDGET_OUTPUT"

echo "Captured 6.5-inch ASC screenshots:"
echo "  $MAIN_OUTPUT"
echo "  $WIDGET_OUTPUT"
