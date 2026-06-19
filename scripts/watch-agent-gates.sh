#!/usr/bin/env bash
# Delegates to PowerShell watch-agent-gates (Windows-primary repo)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
if command -v pwsh >/dev/null 2>&1; then
  pwsh -File scripts/watch-agent-gates.ps1 "$@"
elif command -v powershell >/dev/null 2>&1; then
  powershell -File scripts/watch-agent-gates.ps1 "$@"
else
  echo "FAIL: PowerShell required for watch-agent-gates on this repo"
  exit 1
fi
