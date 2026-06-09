#!/usr/bin/env bash
# Copyright 2026 NoClip Auto contributors
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CARGO_DIR="$ROOT/noclip-analyze"
BIN_DIR="$ROOT/NoClipAuto.lrdevplugin/bin/macos-arm64"
PROFILE="${1:-release-small}"
TARGET="${2:-aarch64-apple-darwin}"

mkdir -p "$BIN_DIR"

pushd "$CARGO_DIR" >/dev/null
rustup target add "$TARGET" 2>/dev/null || true
cargo build --profile "$PROFILE" --target "$TARGET"
popd >/dev/null

SRC="$CARGO_DIR/target/$TARGET/$PROFILE/noclip-analyze"
if [[ ! -f "$SRC" ]]; then
  echo "Build failed: $SRC not found" >&2
  exit 1
fi

cp -f "$SRC" "$BIN_DIR/noclip-analyze"
chmod +x "$BIN_DIR/noclip-analyze"
echo "Built and copied: $BIN_DIR/noclip-analyze"
file "$BIN_DIR/noclip-analyze"
