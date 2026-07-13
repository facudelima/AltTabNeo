#!/usr/bin/env bash
# Compila AltTabX en Release y deja el .app en dist/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DERIVED="$ROOT/build"
DIST="$ROOT/dist"
APP="$DIST/AltTabX.app"

echo "Compilando AltTabX (Release)…"
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild \
    -project AltTabX.xcodeproj \
    -scheme Release \
    -configuration Release \
    -derivedDataPath "$DERIVED" \
    build \
    CODE_SIGN_IDENTITY="Apple Development" \
    DEVELOPMENT_TEAM=AWYV6ST973

BUILT="$DERIVED/Build/Products/Release/AltTabX.app"
if [[ ! -d "$BUILT" ]]; then
  echo "No se encontró $BUILT"
  exit 1
fi

mkdir -p "$DIST"
rm -rf "$APP"
ditto "$BUILT" "$APP"
xattr -cr "$APP" 2>/dev/null || true

echo ""
echo "Listo: $APP"
codesign -dv "$APP" 2>&1 | grep -E 'Identifier=|Signature|TeamIdentifier' || true
