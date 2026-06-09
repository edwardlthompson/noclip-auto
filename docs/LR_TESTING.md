# LR Testing — NoClip Auto

Automated Lightroom testing via PowerShell scripts. **No manual UI checks** for gates.

## Prerequisites

- Lightroom Classic installed (H2 if not)
- Plugin installed: `scripts/install-plugin.ps1`

## Script flow

```powershell
.\scripts\install-plugin.ps1 -Force
.\scripts\enable-lr-plugin.ps1 -Force   # Register path in LR preferences
.\scripts\ensure-lr-running.ps1         # Start LR, wait for log heartbeat
.\scripts\wait-for-lr-ready.ps1         # Wait for catalog + Library/Print module
.\scripts\verify-lr-plugin.ps1          # Check plugin load marker / logs
.\scripts\run-milestone-gate.ps1 -Milestone 3
```

## First-time plugin enable (one-time per machine)

Lightroom disables new plugins until you enable them in Plug-in Manager. Automated UI enable is unreliable from agent shells; do this once manually:

1. Open **File → Plug-in Manager**
2. Select **NoClip Auto** (or **Add** → `%APPDATA%\Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin`)
3. Click **Enable**, then **Done**
4. Re-run `m3_smoke.ps1`

After enable, `%TEMP%\NoClipAuto\noclip-plugin-loaded.txt` is written on LR startup (from `Init.lua`).

If smoke fails with enable instructions, run:

```powershell
.\scripts\print-lr-plugin-enable-help.ps1
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
| m8_smoke.ps1 | No | Analyzer v2 + golden regression |
| m8_lr_smoke.ps1 | Yes | Auto Tone + Orchestrator dry-run (3 photos) |
| m6_smoke.ps1 | No | Release gates (GS, GP, package) |
| m7_smoke.ps1 | No | Mac scripts + CI/release workflow checks |
| m7_smoke.sh | Yes (Mac) | Build macOS analyzer + fixture JSON |

## Log locations

Windows: `%LOCALAPPDATA%\Adobe\Lightroom\Logs\LrClassicLogs`

## verify-tone-quality.ps1

Compares before/after clip metrics against thresholds in `tests/golden/`.

## Troubleshooting

- **Plugin not listed:** Restart LR after install-plugin.ps1
- **Analyzer not found:** Run build-analyzer.ps1
- **Lua errors:** Check LrClassicLogs for NoClipAuto entries
