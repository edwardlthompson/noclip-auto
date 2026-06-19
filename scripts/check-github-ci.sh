#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --wait) ARGS+=(-WaitSeconds "${2:-300}"); shift 2 ;;
    --wait=*) ARGS+=(-WaitSeconds "${1#*=}"); shift ;;
    --ref) ARGS+=(-Ref "${2:-HEAD}"); shift 2 ;;
    --ref=*) ARGS+=(-Ref "${1#*=}"); shift ;;
    --jobs) ARGS+=(-Jobs "${2:-}"); shift 2 ;;
    --jobs=*) ARGS+=(-Jobs "${1#*=}"); shift ;;
    --skip-workflows) ARGS+=(-SkipWorkflows) ;;
    *) shift ;;
  esac
done
if command -v pwsh >/dev/null 2>&1; then
  pwsh -File scripts/check-github-ci.ps1 "${ARGS[@]}"
else
  echo "FAIL: PowerShell required for check-github-ci on this repo"
  exit 1
fi
