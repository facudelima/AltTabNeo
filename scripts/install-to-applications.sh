#!/usr/bin/env bash
# Copia AltTabX a /Applications para que los permisos de macOS no se pierdan en cada rebuild de DerivedData.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${1:-$ROOT/dist/AltTabX.app}"
DEST="/Applications/AltTabX.app"

if [[ ! -d "$SRC" ]]; then
  echo "No encontré $SRC"
  echo "Compilá con ./scripts/build-release.sh o pasá la ruta al .app:"
  echo "  $0 /ruta/a/AltTabX.app"
  exit 1
fi

echo "Origen:  $SRC"
echo "Destino: $DEST"

pkill -x AltTabX 2>/dev/null || true
sleep 0.5
pkill -9 -x AltTabX 2>/dev/null || true
sleep 0.3

rm -rf "$DEST"
ditto "$SRC" "$DEST"
xattr -cr "$DEST" 2>/dev/null || true

codesign -dv "$DEST" 2>&1 | grep -E 'Identifier=|Signature|TeamIdentifier' || true

echo ""
echo "Instalado. En Ajustes del Sistema → Privacidad → Accesibilidad:"
echo "  1. Quitá entradas viejas de AltTabX si hay varias"
echo "  2. Agregá con + → $DEST"
echo "  3. Activá el toggle"
echo ""
echo "Opcional (reset permisos del bundle): tccutil reset Accessibility com.alttabx.app"
echo ""
open "$DEST"
