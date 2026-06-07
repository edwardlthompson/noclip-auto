#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/Library/Application Support/Adobe/Lightroom/Modules/NoClipAuto.lrdevplugin"
rm -rf "$DEST"
mkdir -p "$(dirname "$DEST")"
cp -R "$ROOT/NoClipAuto.lrdevplugin" "$DEST"
chmod +x "$DEST/bin/macos-arm64/noclip-analyze" 2>/dev/null || true
chmod +x "$DEST/bin/macos-x64/noclip-analyze" 2>/dev/null || true
echo "Installed plugin to: $DEST"
