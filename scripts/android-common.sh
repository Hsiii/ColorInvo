#!/usr/bin/env bash

ANDROID_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_APP_DIR="${ANDROID_APP_DIR:-$ANDROID_ROOT_DIR/apps/android}"
ANDROID_PACKAGE_NAME="${ANDROID_PACKAGE_NAME:-dev.hsichen.colorinvo}"
ANDROID_DEBUG_PACKAGE_NAME="${ANDROID_DEBUG_PACKAGE_NAME:-$ANDROID_PACKAGE_NAME.debug}"

android_die() {
    echo "$*" >&2
    exit 1
}

android_load_env_file() {
    local env_path="$1"
    [[ -f "$env_path" ]] || return 0

    local line key value
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" == \#* || "$line" != *=* ]] && continue
        key="${line%%=*}"
        value="${line#*=}"
        [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
        [[ -z "${!key+x}" ]] || continue
        printf -v "$key" '%s' "$value"
        export "$key"
    done <"$env_path"
}

android_load_env() {
    if [[ -n "${ANDROID_ENV_FILE:-}" ]]; then
        android_load_env_file "$ANDROID_ENV_FILE"
    else
        android_load_env_file "$ANDROID_ROOT_DIR/.env.local"
        android_load_env_file "$ANDROID_ROOT_DIR/.env"
    fi
}

android_find_sdk() {
    local candidate
    for candidate in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Library/Android/sdk"; do
        [[ -n "$candidate" && -d "$candidate/platforms" ]] || continue
        ANDROID_HOME="$candidate"
        ANDROID_SDK_ROOT="$candidate"
        export ANDROID_HOME ANDROID_SDK_ROOT
        return
    done
    android_die "Android SDK not found. Install API 36 in Android Studio or set ANDROID_HOME."
}

android_gradle() {
    (cd "$ANDROID_APP_DIR" && ./gradlew "$@")
}

android_device_count() {
    "$ANDROID_HOME/platform-tools/adb" devices | awk 'NR > 1 && $2 == "device" { count++ } END { print count + 0 }'
}

android_require_device() {
    [[ "$(android_device_count)" -gt 0 ]] || android_die "No unlocked Android device or emulator is connected."
}

android_resolve_release_versions() {
    ANDROID_VERSION_NAME="${ANDROID_VERSION_NAME:-0.1.0}"
    ANDROID_VERSION_CODE="${ANDROID_VERSION_CODE:-1}"
    if [[ "${ANDROID_RELEASE_PROMPT:-0}" == "1" && -t 0 ]]; then
        local value
        read -r -p "Version name [$ANDROID_VERSION_NAME]: " value
        ANDROID_VERSION_NAME="${value:-$ANDROID_VERSION_NAME}"
        read -r -p "Version code [$ANDROID_VERSION_CODE]: " value
        ANDROID_VERSION_CODE="${value:-$ANDROID_VERSION_CODE}"
    fi
    [[ "$ANDROID_VERSION_CODE" =~ ^[1-9][0-9]*$ ]] || android_die "ANDROID_VERSION_CODE must be a positive integer."
    export ANDROID_VERSION_NAME ANDROID_VERSION_CODE
}

android_require_release_signing() {
    local properties_path="$ANDROID_APP_DIR/keystore.properties"
    [[ -f "$properties_path" ]] || android_die "Missing apps/android/keystore.properties. Copy keystore.properties.example and add the upload-key values."
    local store_file
    store_file="$(awk -F= '$1 == "storeFile" { print substr($0, index($0, "=") + 1); exit }' "$properties_path")"
    [[ -n "$store_file" ]] || android_die "storeFile is missing from keystore.properties."
    [[ "$store_file" = /* ]] || store_file="$ANDROID_APP_DIR/$store_file"
    [[ -f "$store_file" ]] || android_die "Android upload keystore not found at $store_file."
}

android_load_env
android_find_sdk
