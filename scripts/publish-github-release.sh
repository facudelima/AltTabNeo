#!/usr/bin/env bash
# Build → package → firmar Sparkle → actualizar appcast.
# Con --yes también crea el release en GitHub (requiere git credential con scope repo).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

REPO="facudelima/AltTabNeo"
SIGN_UPDATE="${SIGN_UPDATE:-$ROOT/.sparkle-tools/bin/sign_update}"
[[ -x "$SIGN_UPDATE" ]] || SIGN_UPDATE="$ROOT/vendor/Sparkle/bin/sign_update"
KEY_FILE="${SPARKLE_PRIVATE_KEY:-$ROOT/config/secrets/sparkle_eddsa_private.key}"
DO_UPLOAD=false
[[ "${1:-}" == "--yes" || "${1:-}" == "--upload-only" ]] && DO_UPLOAD=true
UPLOAD_ONLY=false
[[ "${1:-}" == "--upload-only" ]] && UPLOAD_ONLY=true

if [[ ! -f "$KEY_FILE" ]]; then
  echo "Falta la clave privada Sparkle: $KEY_FILE"
  echo "Generala con: ./.sparkle-tools/bin/generate_keys --account alttabneo -x $KEY_FILE"
  exit 1
fi
if [[ ! -x "$SIGN_UPDATE" ]]; then
  echo "Falta sign_update en $SIGN_UPDATE"
  exit 1
fi

github_token() {
  printf 'protocol=https\nhost=github.com\n\n' | git credential fill 2>/dev/null \
    | awk -F= '/^password=/{print $2; exit}'
}

if [[ "$UPLOAD_ONLY" != true ]]; then
  echo "==> Build Release"
  ./scripts/build-release.sh
  echo "==> Package zip/dmg"
  ./scripts/package-installer.sh
fi

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' dist/AltTabNeo.app/Contents/Info.plist)"
BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' dist/AltTabNeo.app/Contents/Info.plist)"
MIN_OS="$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' dist/AltTabNeo.app/Contents/Info.plist 2>/dev/null || echo '10.13')"
ZIP="dist/AltTabNeo-${VERSION}.zip"
DMG="dist/AltTabNeo-${VERSION}.dmg"
TAG="v${VERSION}"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${TAG}/AltTabNeo-${VERSION}.zip"

if [[ ! -f "$ZIP" || ! -f "$DMG" ]]; then
  echo "Faltan artefactos $ZIP / $DMG"
  exit 1
fi

LENGTH="$(stat -f%z "$ZIP")"
SIGNATURE="$("$SIGN_UPDATE" --ed-key-file "$KEY_FILE" -p "$ZIP")"
PUB_DATE="$(date -u '+%a, %d %b %Y %H:%M:%S +0000')"

echo "==> Actualizar appcast.xml (${TAG}, build ${BUILD})"
cat > appcast.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <title>AltTabNeo</title>
    <link>https://github.com/${REPO}</link>
    <description>AltTabNeo updates</description>
    <language>en</language>
    <item>
      <title>Version ${VERSION}</title>
      <pubDate>${PUB_DATE}</pubDate>
      <sparkle:version>${BUILD}</sparkle:version>
      <sparkle:shortVersionString>${VERSION}</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>${MIN_OS}</sparkle:minimumSystemVersion>
      <enclosure
        url="${DOWNLOAD_URL}"
        length="${LENGTH}"
        type="application/octet-stream"
        sparkle:edSignature="${SIGNATURE}" />
    </item>
  </channel>
</rss>
EOF

if [[ "$UPLOAD_ONLY" != true ]]; then
  echo "==> Instalar en /Applications"
  ./scripts/install-to-applications.sh >/dev/null || true
fi

echo ""
echo "Artefactos listos:"
echo "  ZIP: $ZIP ($LENGTH bytes)"
echo "  DMG: $DMG"
echo "  edSignature: $SIGNATURE"
echo "  appcast: appcast.xml"

if [[ "$DO_UPLOAD" != true ]]; then
  echo ""
  echo "Siguiente: commiteá, pusheá, y corré:"
  echo "  ./scripts/publish-github-release.sh --upload-only"
  exit 0
fi

TOKEN="$(github_token)"
if [[ -z "${TOKEN}" ]]; then
  echo "No hay credencial de GitHub (git credential / gh auth login)"
  exit 1
fi

echo "==> Publicar release ${TAG} en GitHub"
export GH_TOKEN="$TOKEN" REPO VERSION BUILD TAG ZIP DMG ROOT
python3 <<'PY'
import json, os, re, urllib.request, urllib.error

token = os.environ["GH_TOKEN"]
repo = os.environ["REPO"]
version = os.environ["VERSION"]
tag = os.environ["TAG"]
zip_path = os.path.join(os.environ["ROOT"], os.environ["ZIP"])
dmg_path = os.path.join(os.environ["ROOT"], os.environ["DMG"])

def api(method, url, data=None, content_type="application/json"):
    body = None if data is None else (data if isinstance(data, (bytes, bytearray)) else json.dumps(data).encode())
    req = urllib.request.Request(url, data=body, method=method, headers={
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        **({"Content-Type": content_type} if body is not None else {}),
    })
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read().decode()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        raise SystemExit(f"GitHub API {method} {url} -> {e.code}: {err}")

# Delete existing release for this tag (keep tag; recreate release)
try:
    existing = api("GET", f"https://api.github.com/repos/{repo}/releases/tags/{tag}")
    rid = existing.get("id")
    if rid:
        print(f"  Borrando release previo id={rid}")
        api("DELETE", f"https://api.github.com/repos/{repo}/releases/{rid}")
except SystemExit as e:
    if "404" not in str(e):
        raise

changelog = open(os.path.join(os.environ["ROOT"], "CHANGELOG.md")).read()
m = re.search(rf"^## {re.escape(version)}[^\n]*\n(.*?)(?=^## |\Z)", changelog, re.S | re.M)
section = (m.group(1).strip() if m else "")
body = f"""## AltTabNeo {version}

{section}

### Instalación
1. Descargá el `.dmg` o `.zip`
2. Arrastrá **AltTabNeo** a Aplicaciones
3. Concedé Accesibilidad

Las instalaciones posteriores reciben actualizaciones automáticas vía Sparkle.
"""

release = api("POST", f"https://api.github.com/repos/{repo}/releases", {
    "tag_name": tag,
    "name": f"AltTabNeo {version}",
    "body": body,
    "draft": False,
    "prerelease": False,
})
release_id = release["id"]
print(f"  Release creado: {release['html_url']}")

def upload(path):
    name = os.path.basename(path)
    print(f"  Subiendo {name}…")
    with open(path, "rb") as f:
        data = f.read()
    url = f"https://uploads.github.com/repos/{repo}/releases/{release_id}/assets?name={urllib.request.quote(name)}"
    asset = api("POST", url, data=data, content_type="application/octet-stream")
    print(f"   -> {asset.get('browser_download_url')}")

upload(zip_path)
upload(dmg_path)
print("OK")
PY
