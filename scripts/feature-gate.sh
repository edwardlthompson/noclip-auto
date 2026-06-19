#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --quick) ARGS+=(-Quick) ;;
    --ci) ARGS+=(-Ci) ;;
    --stack=*) ARGS+=(-Stack "${arg#*=}") ;;
    --stack) ARGS+=(-Stack "${2:-lightroom-rust}"); shift ;;
    *) ;;
  esac
done
if command -v pwsh >/dev/null 2>&1; then
  pwsh -File scripts/feature-gate.ps1 "${ARGS[@]}"
else
  echo "FAIL: PowerShell required for feature-gate on this repo"
  exit 1
fi
