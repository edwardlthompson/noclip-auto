# Module D: Adobe Lightroom Classic — NoClip Auto

> Active stack module. Production plugin: `NoClipAuto.lrdevplugin/` (not `examples/lightroom/`).

## Requirements

- **Lightroom SDK compliance:** All plugin Lua must use Adobe Lightroom SDK `Lr*` namespaces (`LrTasks`, `LrDialogs`, `LrLogger`, `LrView`, `LrPrefs`, etc.). Do not import generic Lua modules or call OS APIs outside SDK boundaries except via documented polyfills (`Core/Loader.lua`).
- **Entry file budget:** Menu/process entry files ≤ 50 lines; `Core/*` modules ≤ 200 lines (`scripts/check-lua-size.ps1 -ShippedOnly`).
- **Async menus:** Menu handlers use `postAsyncTaskWithContext` + `attachErrorDialogToFunctionContext`; never block the UI thread.
- **Init constraint:** `Init.lua` cannot `require()` Core modules (`package` is nil) — use `dofile` or smoke bootstraps.

## Production layout

| Path | Role |
|------|------|
| `NoClipAuto.lrdevplugin/Info.lua` | Manifest, SDK version, menu items |
| `NoClipAuto.lrdevplugin/Init.lua` | Logger + prefs bootstrap |
| `NoClipAuto.lrdevplugin/ProcessLibrary.lua` | Batch (Library) entry |
| `NoClipAuto.lrdevplugin/ProcessDevelop.lua` | Single photo (Develop/File) entry |
| `NoClipAuto.lrdevplugin/PluginInfoProvider.lua` | Plugin Manager settings UI |
| `NoClipAuto.lrdevplugin/Core/` | Pipeline, preview, batch, prefs |
| `NoClipAuto.lrdevplugin/bin/` | Bundled `noclip-analyze` per platform |

## SDK version compatibility

| Field | Value | Notes |
|-------|-------|-------|
| `LrSdkVersion` | **6.0** | Declared in `Info.lua` |
| `LrSdkMinimumVersion` | **6.0** | Lightroom Classic with SDK 6.0+ |
| Process Version | **2012** | PV2012 slider keys only |

Record changes in `AGENT_MEMORY.md` when bumping SDK targets.

## Activation checklist

- ✅ All shipped Lua uses `Lr*` SDK namespaces (FOSS audit + code review)
- ✅ `Info.lua` manifest complete (menus, URL handler, version)
- ✅ `LrLogger` configured in `Init.lua`
- ✅ Plugin Manager prefs persist via `Core/Prefs.lua` + `startDialog`/`endDialog`
- ✅ Settings hints per [docs/SETTINGS_UI.md](../../docs/SETTINGS_UI.md) and `.cursor/rules/settings-ui-hints.mdc`
- ✅ Install path documented: `%APPDATA%\Adobe\Lightroom\Modules\` (Win), `~/Library/Application Support/Adobe/Lightroom/Modules/` (Mac)

## Golden Path reference

See [examples/golden-path/README.md](../../examples/golden-path/README.md) for the end-to-end tone-recovery flow. Algorithm detail: [docs/ALGORITHM.md](../../docs/ALGORITHM.md).

**Key flow:** export tier-sized preview JPEG → `noclip-analyze` counts clipped pixels → 3-phase slider loop (Exposure → Whites/Blacks → Highlights/Shadows).

## Feature gate (NoClip profile)

| Stage | Command |
|-------|---------|
| Plugin scaffold | `scripts/smoke/m0_smoke.ps1` |
| Plugin load (LR) | `scripts/smoke/m1_smoke.ps1` `[LR]` |
| Preview loop | `scripts/smoke/m3_smoke.ps1` `[LR]` |
| Lua size | `scripts/check-lua-size.ps1 -ShippedOnly` |
| Milestone rollup | `scripts/run-milestone-gate.ps1 -Milestone N` |

## Owner labels

| Task type | Label |
|-----------|-------|
| Scaffold Lua, docs, smoke scripts | `AGENT` |
| SDK version / LR target approval | `HUMAN` |
| Plugin load testing in Lightroom | `HUMAN` or `[LR]` automation |
| CI namespace / size gates | `AUTO` |
