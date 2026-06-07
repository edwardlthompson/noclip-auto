# LR Testing — NoClip Auto

Automated Lightroom testing via PowerShell scripts. **No manual UI checks** for gates.

## Prerequisites

- Lightroom Classic installed (H2 if not)
- Plugin installed: `scripts/install-plugin.ps1`

## Script flow

```powershell
.\scripts\ensure-lr-running.ps1      # Start LR, wait for log heartbeat
.\scripts\install-plugin.ps1         # Copy plugin to Modules folder
.\scripts\verify-lr-plugin.ps1       # Grep LrClassicLogs for plugin load
.\scripts\run-milestone-gate.ps1 -Milestone 2
```

## Smoke tests

| Script | Requires LR | Purpose |
|--------|-------------|---------|
| m0_smoke.ps1 | No | Repo structure |
| m1_smoke.ps1 | Yes | Plugin load |
| m2_smoke.ps1 | No | Analyzer on fixtures |
| m3_smoke.ps1 | Yes | Preview export |
| m4_smoke.ps1 | Yes | Pipeline golden |
| m5_smoke.ps1 | Yes | Batch run |

## Log locations

Windows: `%LOCALAPPDATA%\Adobe\Lightroom\Logs\LrClassicLogs`

## verify-tone-quality.ps1

Compares before/after clip metrics against thresholds in `tests/golden/`.

## Troubleshooting

- **Plugin not listed:** Restart LR after install-plugin.ps1
- **Analyzer not found:** Run build-analyzer.ps1
- **Lua errors:** Check LrClassicLogs for NoClipAuto entries
