#!/usr/bin/env bash
# Copyright 2026 NoClip Auto contributors
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURES="$ROOT/tests/fixtures"
VENV="$ROOT/.fixture-venv"
mkdir -p "$FIXTURES"

if [[ ! -x "$VENV/bin/python" ]]; then
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install --upgrade pip pillow -q
fi

"$VENV/bin/python" - "$FIXTURES" <<'PY'
import sys
from pathlib import Path
from PIL import Image

fixtures = Path(sys.argv[1])
fixtures.mkdir(parents=True, exist_ok=True)

for name, rgb in [("black", (0, 0, 0)), ("white", (255, 255, 255)), ("gray", (128, 128, 128))]:
    Image.new("RGB", (10, 10), rgb).save(fixtures / f"{name}.jpg")

Image.new("RGB", (1920, 1080), (128, 128, 128)).save(fixtures / "bench-1080p.jpg")
print(f"Generated fixtures in {fixtures}")
PY
