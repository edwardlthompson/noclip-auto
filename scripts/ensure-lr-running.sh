#!/usr/bin/env bash
# Copyright 2026 NoClip Auto contributors
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

TIMEOUT_SEC="${1:-120}"

if pgrep -x "Lightroom" >/dev/null 2>&1 || pgrep -f "Adobe Lightroom Classic" >/dev/null 2>&1; then
  echo "Lightroom already running"
  exit 0
fi

LR_APP=""
for candidate in \
  "/Applications/Adobe Lightroom Classic/Adobe Lightroom Classic.app" \
  "/Applications/Adobe Lightroom Classic CC/Adobe Lightroom Classic CC.app"; do
  if [[ -d "$candidate" ]]; then
    LR_APP="$candidate"
    break
  fi
done

if [[ -z "$LR_APP" ]]; then
  echo "NOT_INSTALLED"
  exit 2
fi

open "$LR_APP"
echo "Started Lightroom, waiting for log heartbeat..."

LOG_DIRS=(
  "$HOME/Library/Logs/Adobe/Lightroom"
  "$HOME/Library/Application Support/Adobe/Lightroom/Logs"
)

deadline=$((SECONDS + TIMEOUT_SEC))
while (( SECONDS < deadline )); do
  for log_dir in "${LOG_DIRS[@]}"; do
    if [[ -d "$log_dir" ]]; then
      recent="$(find "$log_dir" -name "*.log" -type f -mmin -2 2>/dev/null | head -1 || true)"
      if [[ -n "$recent" ]]; then
        echo "Log heartbeat detected: $(basename "$recent")"
        exit 0
      fi
    fi
  done
  sleep 3
done

echo "Timeout waiting for LR log heartbeat" >&2
exit 1
