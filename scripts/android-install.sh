#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/android-common.sh"
android_require_device
android_gradle installDebug
"$ANDROID_HOME/platform-tools/adb" shell am start -n "$ANDROID_DEBUG_PACKAGE_NAME/$ANDROID_PACKAGE_NAME.MainActivity"
