#!/usr/bin/env bash
# Copyright 2026 NoClip Auto contributors
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "M7 smoke: macOS analyzer build + fixture test"

"$ROOT/scripts/build-analyzer-macos.sh" release-small aarch64-apple-darwin

ANALYZER="$ROOT/NoClipAuto.lrdevplugin/bin/macos-arm64/noclip-analyze"
FIXTURES="$ROOT/tests/fixtures"

if [[ ! -f "$FIXTURES/gray.jpg" ]]; then
  "$ROOT/scripts/generate-fixtures.sh"
fi

if [[ ! -x "$ANALYZER" ]]; then
  echo "Analyzer not executable: $ANALYZER" >&2
  exit 1
fi

for fixture in black.jpg white.jpg gray.jpg; do
  path="$FIXTURES/$fixture"
  if [[ ! -f "$path" ]]; then
    echo "Missing fixture: $path" >&2
    exit 1
  fi
  output="$("$ANALYZER" --input "$path" --shadow-threshold 2 --highlight-threshold 253)"
  if [[ "$output" != *'"schema_version":2'* ]]; then
    echo "Expected schema_version 2 on $fixture: $output" >&2
    exit 1
  fi
  echo "OK $fixture"
done

test -f "$ROOT/scripts/install-plugin.sh"
test -f "$ROOT/scripts/ensure-lr-running.sh"

echo "M7 smoke PASS"
