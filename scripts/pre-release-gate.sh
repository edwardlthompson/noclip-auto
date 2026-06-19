#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --stack=*) ARGS+=(-Stack "${arg#*=}") ;;
    --stack) ARGS+=(-Stack "${2:-lightroom-rust}"); shift ;;
    --skip-feature-gate) ARGS+=(-SkipFeatureGate) ;;
    *) ;;
  esac
done
if command -v pwsh >/dev/null 2>&1; then
  pwsh -File scripts/pre-release-gate.ps1 "${ARGS[@]}"
else
  echo "FAIL: PowerShell required for pre-release-gate on this repo"
  exit 1
fi
