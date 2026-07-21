#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/android-common.sh"
android_require_device

ADB="$ANDROID_HOME/platform-tools/adb"
TEST_CLASS="dev.hsichen.colorinvo.PlayStoreScreenshotTest"

capture_locale() {
    local locale="$1"
    local play_locale="$2"
    local remote_name="play-store-${locale}.png"
    local output_dir="$ANDROID_APP_DIR/play/$play_locale/images/phoneScreenshots"

    android_gradle connectedDebugAndroidTest \
        -Pandroid.testInstrumentationRunnerArguments.class="$TEST_CLASS" \
        -Pandroid.testInstrumentationRunnerArguments.locale="$locale"
    mkdir -p "$output_dir"
    "$ADB" pull "/sdcard/Android/data/$ANDROID_DEBUG_PACKAGE_NAME/files/$remote_name" "$output_dir/1_main.png"
}

capture_locale "en-US" "en-US"
capture_locale "zh-TW" "zh-TW"
