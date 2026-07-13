#!/usr/bin/env bash
# Empaqueta dist/AltTabX.app en zip y dmg para distribución.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/AltTabX.app"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist" 2>/dev/null || echo "1.0.0")"
DIST="$ROOT/dist"
ZIP="$DIST/AltTabX-${VERSION}.zip"
DMG="$DIST/AltTabX-${VERSION}.dmg"
STAGING="$DIST/dmg-staging"

if [[ ! -d "$APP" ]]; then
  echo "Falta $APP — ejecutá primero: ./scripts/build-release.sh"
  exit 1
fi

echo "Empaquetando AltTabX ${VERSION}…"

rm -f "$ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"
echo "ZIP: $ZIP"

rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING"
ditto "$APP" "$STAGING/AltTabX.app"
ln -s /Applications "$STAGING/Applications"

hdiutil create \
  -volname "AltTabX ${VERSION}" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "$DMG" >/dev/null

rm -rf "$STAGING"
echo "DMG: $DMG"
echo ""
ls -lh "$ZIP" "$DMG"
