#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_FILE="$ROOT_DIR/ColorInvo.xcodeproj/project.pbxproj"

if [[ ! -f "$PROJECT_FILE" ]]; then
    exit 0
fi

perl -0pi -e 's/SystemCapabilities = "\[\\"com\.apple\.ApplicationGroups\.iOS\\": \[\\"enabled\\": 1\]\]";/SystemCapabilities = {\n\t\t\t\t\t\t\tcom.apple.ApplicationGroups.iOS = {\n\t\t\t\t\t\t\t\tenabled = 1;\n\t\t\t\t\t\t\t};\n\t\t\t\t\t\t};/g' "$PROJECT_FILE"
