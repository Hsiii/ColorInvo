#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/android-common.sh"

ANDROID_RELEASE_PROMPT="${ANDROID_RELEASE_PROMPT:-1}"
android_resolve_release_versions
export ANDROID_VERSION_NAME ANDROID_VERSION_CODE

"$SCRIPT_DIR/android-check.sh"
"$SCRIPT_DIR/android-bundle.sh"
"$SCRIPT_DIR/android-upload.sh"
