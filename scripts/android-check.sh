#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/android-common.sh"
android_gradle testDebugUnitTest lintDebug assembleDebug assembleDebugAndroidTest
