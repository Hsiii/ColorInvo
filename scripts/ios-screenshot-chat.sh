#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ios-common.sh"

DEVICE="${IOS_CHAT_SCREENSHOT_DEVICE:-booted}"
DISPLAY="${IOS_CHAT_SCREENSHOT_DISPLAY:-internal}"
OUTPUT_PATH="${IOS_CHAT_SCREENSHOT_PATH:-$IOS_ROOT_DIR/.codex-screenshots/ios-simulator-latest.png}"
OUTPUT_DIR="$(dirname "$OUTPUT_PATH")"
OUTPUT_NAME="$(basename "$OUTPUT_PATH")"
DISPLAY_ARGS=()

mkdir -p "$OUTPUT_DIR"
ABS_OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
ABS_OUTPUT_PATH="$ABS_OUTPUT_DIR/$OUTPUT_NAME"

if [[ -n "$DISPLAY" ]]; then
    DISPLAY_ARGS=(--display "$DISPLAY")
fi

xcrun simctl io "$DEVICE" screenshot "${DISPLAY_ARGS[@]}" --type=png --mask=ignored "$ABS_OUTPUT_PATH" >/dev/null

WIDTH="$(sips -g pixelWidth "$ABS_OUTPUT_PATH" | awk '/pixelWidth/ { print $2 }')"
HEIGHT="$(sips -g pixelHeight "$ABS_OUTPUT_PATH" | awk '/pixelHeight/ { print $2 }')"
[[ -n "$WIDTH" && -n "$HEIGHT" ]] || ios_die "Could not read simulator screenshot dimensions: $ABS_OUTPUT_PATH"

PATH_B64="$(printf '%s' "$ABS_OUTPUT_PATH" | base64 | tr -d '\n')"

echo "Captured simulator screenshot:"
echo "  $ABS_OUTPUT_PATH"
echo "  ${WIDTH}x${HEIGHT}"
echo
echo "Attach it in Codex chat with the node_repl js tool:"
cat <<EOF
var fs = await import('node:fs/promises');
var imagePath = Buffer.from('$PATH_B64', 'base64').toString('utf8');
var imageBytes = await fs.readFile(imagePath);
await nodeRepl.emitImage({ bytes: imageBytes, mimeType: 'image/png' });
nodeRepl.write('emitted ' + imagePath);
EOF
