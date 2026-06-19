#!/usr/bin/env bash
# NoClip Auto bootstrap validation (lightroom+rust child repo profile)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --quick) ARGS+=(-Quick) ;;
    *) ARGS+=("$arg") ;;
  esac
done
if command -v pwsh >/dev/null 2>&1; then
  pwsh -File scripts/validate-bootstrap.ps1 "${ARGS[@]}"
elif command -v powershell >/dev/null 2>&1; then
  powershell -File scripts/validate-bootstrap.ps1 "${ARGS[@]}"
else
  echo "FAIL: PowerShell required for validate-bootstrap on this repo"
  exit 1
fi
