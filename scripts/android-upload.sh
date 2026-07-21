#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/android-common.sh"

ANDROID_AAB_PATH="${ANDROID_AAB_PATH:-$ANDROID_APP_DIR/app/build/outputs/bundle/release/app-release.aab}"
PLAY_TRACK="${PLAY_TRACK:-internal}"
export ANDROID_AAB_PATH PLAY_TRACK

[[ -f "$ANDROID_AAB_PATH" ]] || android_die "Release bundle not found at $ANDROID_AAB_PATH. Run bun run android:bundle first."
[[ -n "${PLAY_SERVICE_ACCOUNT_JSON:-}" && -f "$PLAY_SERVICE_ACCOUNT_JSON" ]] || android_die "PLAY_SERVICE_ACCOUNT_JSON must point to a Play Console service-account JSON file."
command -v bundle >/dev/null || android_die "Ruby Bundler is required. Run gem install bundler, then bundle install in apps/android."

(cd "$ANDROID_APP_DIR" && bundle check >/dev/null) || android_die "Fastlane dependencies are missing. Run bundle install in apps/android."
(cd "$ANDROID_APP_DIR" && bundle exec fastlane android upload)
