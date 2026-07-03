#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ios-common.sh"

PROJECT_FILE="$IOS_PROJECT_PATH/project.pbxproj"
APP_ENTITLEMENTS="$IOS_APP_DIR/Sources/ColorInvoApp/ColorInvo.entitlements"
WIDGET_ENTITLEMENTS="$IOS_APP_DIR/Sources/ColorInvoWidget/ColorInvoWidget.entitlements"

ios_generate_project

xcodebuild -list -project "$IOS_PROJECT_PATH" >/dev/null
[[ -f "$APP_ENTITLEMENTS" ]] || ios_die "Missing app entitlements: $APP_ENTITLEMENTS"
[[ -f "$WIDGET_ENTITLEMENTS" ]] || ios_die "Missing widget entitlements: $WIDGET_ENTITLEMENTS"
grep -q "$IOS_APP_GROUP_ID_VALUE" "$APP_ENTITLEMENTS" \
    || ios_die "App entitlements do not contain $IOS_APP_GROUP_ID_VALUE."
grep -q "$IOS_APP_GROUP_ID_VALUE" "$WIDGET_ENTITLEMENTS" \
    || ios_die "Widget entitlements do not contain $IOS_APP_GROUP_ID_VALUE."
grep -q "$IOS_BUNDLE_ID_VALUE" "$PROJECT_FILE" \
    || ios_die "Project does not contain app bundle id $IOS_BUNDLE_ID_VALUE."
grep -q "$IOS_WIDGET_BUNDLE_ID_VALUE" "$PROJECT_FILE" \
    || ios_die "Project does not contain widget bundle id $IOS_WIDGET_BUNDLE_ID_VALUE."

while IFS= read -r strings_file; do
    plutil -lint "$strings_file" >/dev/null
done < <(find "$IOS_APP_DIR/Sources" -name "*.strings" -type f | sort)

"$IOS_ROOT_DIR/scripts/ios-build.sh" >/dev/null

echo "iOS project, localization, entitlements, and simulator build checks passed for $IOS_SCHEME_NAME."
