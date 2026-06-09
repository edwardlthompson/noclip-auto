#!/usr/bin/env bash
# Copyright 2026 NoClip Auto contributors
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURES="$ROOT/tests/fixtures"
mkdir -p "$FIXTURES"

python3 - "$FIXTURES" <<'PY'
import subprocess
import sys
from pathlib import Path

fixtures = Path(sys.argv[1])
fixtures.mkdir(parents=True, exist_ok=True)

try:
    from PIL import Image
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pillow", "-q"])
    from PIL import Image

for name, rgb in [("black", (0, 0, 0)), ("white", (255, 255, 255)), ("gray", (128, 128, 128))]:
    Image.new("RGB", (10, 10), rgb).save(fixtures / f"{name}.jpg")

Image.new("RGB", (1920, 1080), (128, 128, 128)).save(fixtures / "bench-1080p.jpg")
print(f"Generated fixtures in {fixtures}")
PY
