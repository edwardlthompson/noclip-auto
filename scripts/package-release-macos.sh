#!/usr/bin/env bash
# Copyright 2026 NoClip Auto contributors
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

VERSION="${1:?Usage: package-release-macos.sh <version>}"
MAX_ZIP_MB="${2:-5}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/NoClipAuto.lrdevplugin"
DIST="$ROOT/dist"
STAGE="$DIST/NoClipAuto.lrdevplugin"
ZIP_NAME="NoClipAuto-v${VERSION}-macos-arm64.lrdevplugin.zip"
ZIP_PATH="$DIST/$ZIP_NAME"

DEV_EXCLUDE=(
  "M3SmokeHeadless.lua"
  "M5SmokeBootstrap.lua"
  "M8SmokeBootstrap.lua"
  "ProcessM3Smoke.lua"
  "ProcessM5Smoke.lua"
  "ProcessM8Smoke.lua"
)

"$ROOT/scripts/build-analyzer-macos.sh" release-small aarch64-apple-darwin

rm -rf "$STAGE"
mkdir -p "$DIST"
cp -R "$SRC" "$STAGE"

for name in "${DEV_EXCLUDE[@]}"; do
  rm -f "$STAGE/$name"
done

if [[ -d "$STAGE/smoke" ]]; then
  rm -f "$STAGE/smoke/"*.trigger 2>/dev/null || true
fi

# macOS release ships arm64 analyzer only (no Windows exe).
rm -rf "$STAGE/bin/win-x64"
mkdir -p "$STAGE/bin/win-x64"
: > "$STAGE/bin/win-x64/.gitkeep"

chmod +x "$STAGE/bin/macos-arm64/noclip-analyze"

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
INFO="$STAGE/Info.lua"
ABOUT="$STAGE/Core/About.lua"

perl -i -pe 's/^\s*\{ title = "NoClip Auto - M3 Smoke \(dev\)", file = "ProcessM3Smoke.lua" \},\n//m' "$INFO"
perl -i -pe 's/^\s*\{ title = "NoClip Auto - M5 Smoke \(dev\)", file = "ProcessM5Smoke.lua" \},\n//m' "$INFO"
perl -i -pe 's/^\s*\{ title = "NoClip Auto - M8 Smoke \(dev\)", file = "ProcessM8Smoke.lua" \},\n//m' "$INFO"
perl -i -pe "s/VERSION = \{ major = \\d+, minor = \\d+, revision = \\d+, build = \\d+ \}/VERSION = { major = $MAJOR, minor = $MINOR, revision = $PATCH, build = 0 }/" "$INFO"
perl -i -pe "s/About\\.VERSION = \{ major = \\d+, minor = \\d+, revision = \\d+, build = \\d+ \}/About.VERSION = { major = $MAJOR, minor = $MINOR, revision = $PATCH, build = 0 }/" "$ABOUT"

rm -f "$ZIP_PATH"
(
  cd "$DIST"
  zip -r "$ZIP_NAME" "$(basename "$STAGE")"
)

if [[ ! -f "$STAGE/bin/macos-arm64/noclip-analyze" ]]; then
  echo "macOS analyzer missing in stage" >&2
  exit 1
fi

if ! unzip -l "$ZIP_PATH" | grep -q "macos-arm64/noclip-analyze"; then
  echo "Release zip missing macos-arm64/noclip-analyze" >&2
  exit 1
fi

ZIP_MB=$(du -m "$ZIP_PATH" | cut -f1)
if (( ZIP_MB > MAX_ZIP_MB )); then
  echo "Release zip too large: ${ZIP_MB} MB (max ${MAX_ZIP_MB} MB)" >&2
  exit 1
fi

EXE_MB=$(du -m "$STAGE/bin/macos-arm64/noclip-analyze" | cut -f1)
if (( EXE_MB > 2 )); then
  echo "Analyzer too large: ${EXE_MB} MB (max 2 MB)" >&2
  exit 1
fi

echo "Packaged: $ZIP_PATH (${ZIP_MB} MB)"
