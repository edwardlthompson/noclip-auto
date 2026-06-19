#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
if command -v pwsh >/dev/null 2>&1; then
  pwsh -File scripts/check-batch-commands.ps1
else
  echo "FAIL: PowerShell required for check-batch-commands on this repo"
  exit 1
fi
