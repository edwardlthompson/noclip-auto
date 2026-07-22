#!/usr/bin/env bash
# Child-repo upgrade smoke: ensure cherry-pick areas exist and bootstrap validates.
# Full template init-project simulation lives upstream only.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

AREAS=(
  scripts/check-file-encoding.py
  scripts/check-template-updates.ps1
  scripts/validate-bootstrap.ps1
  docs/UPGRADING_FROM_TEMPLATE.md
  docs/CURSOR_MODES.md
  docs/help/BATCH_COMMANDS.md
  .cursor/rules/cursor-modes.mdc
  .cursor/rules/batch-commands.mdc
  .cursor/rules/local-compute.mdc
  .cursor/hooks.json
  .github/workflows/dependency-review.yml
  .github/workflows/scorecard.yml
)

for path in "${AREAS[@]}"; do
  if [ ! -e "$path" ]; then
    echo "MISSING: $path"
    exit 1
  fi
done

if command -v pwsh >/dev/null 2>&1; then
  pwsh -File scripts/validate-bootstrap.ps1 -Quick
else
  bash scripts/validate-bootstrap.sh --quick
fi

python3 scripts/check-file-encoding.py .
echo "==> Child-repo template upgrade smoke passed"
