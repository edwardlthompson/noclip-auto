#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --skip-archive) ARGS+=(-SkipArchive) ;;
    --skip-m9) ARGS+=(-SkipM9) ;;
    *) ;;
  esac
done
if command -v pwsh >/dev/null 2>&1; then
  pwsh -File scripts/run-milestone-tm-gate.ps1 "${ARGS[@]}"
else
  echo "FAIL: PowerShell required for run-milestone-tm-gate on this repo"
  exit 1
fi
