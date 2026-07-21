#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/android-common.sh"
android_resolve_release_versions
android_require_release_signing
android_gradle bundleRelease \
    -PversionName="$ANDROID_VERSION_NAME" \
    -PversionCode="$ANDROID_VERSION_CODE"
echo "Signed bundle: $ANDROID_APP_DIR/app/build/outputs/bundle/release/app-release.aab"
