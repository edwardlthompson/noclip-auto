# Golden Path — NoClip Auto

> **This folder is documentation only.** Production code lives at `NoClipAuto.lrdevplugin/` and `noclip-analyze/`. Do not duplicate or relocate shipped sources here — install paths, release zips, and smoke scripts depend on the current layout.

See [docs/BOOTSTRAP_TEMPLATE_MAP.md](../../docs/BOOTSTRAP_TEMPLATE_MAP.md) for template alignment.

## Stack

| Layer | Production path | Module guide |
|-------|-----------------|--------------|
| Lightroom plugin | `NoClipAuto.lrdevplugin/` | [modules/lightroom/MODULE.md](../../modules/lightroom/MODULE.md) |
| Rust analyzer | `noclip-analyze/` | [modules/rust/MODULE.md](../../modules/rust/MODULE.md) |
| Tests & fixtures | `tests/` | Golden JSON under `tests/golden/` |

## End-to-end flow

```text
User selects photos (Library or Develop)
        │
        ▼
ProcessLibrary.lua / ProcessDevelop.lua  (≤50 line entry)
        │
        ▼
BatchRunner.lua / SingleRunner.lua
        │
        ▼
PreviewRender.lua  ──► tier-sized JPEG export
        │
        ▼
ClippingClient.lua ──► noclip-analyze (bundled binary)
        │
        ▼
Pipeline/Orchestrator.lua  ──► 3-phase slider loop
   Phase 1: Exposure
   Phase 2: Whites / Blacks  (capped ±25)
   Phase 3: Highlights / Shadows
        │
        ▼
SettingsIO.lua applyDevelopSettings (or dry-run log)
```

Full algorithm: [docs/ALGORITHM.md](../../docs/ALGORITHM.md)

## Entry points (start here when changing behavior)

| Concern | File |
|---------|------|
| Batch menu | `NoClipAuto.lrdevplugin/ProcessLibrary.lua` |
| Single photo | `NoClipAuto.lrdevplugin/ProcessDevelop.lua` |
| Pipeline loop | `NoClipAuto.lrdevplugin/Core/Pipeline/Orchestrator.lua` |
| Clip measurement | `noclip-analyze/src/analyze.rs` |
| Lua ↔ analyzer bridge | `NoClipAuto.lrdevplugin/Core/ClippingClient.lua` |
| Plugin prefs | `NoClipAuto.lrdevplugin/Core/Prefs.lua`, `Core/SettingsUI.lua` |
| Platform paths | `NoClipAuto.lrdevplugin/Core/Platform.lua` |

## Analyzer CLI (Golden Path smoke)

```powershell
.\scripts\build-analyzer.ps1
.\scripts\test_analyzer.ps1
.\scripts\smoke\m2_smoke.ps1
```

Expected: 100% clip on pure black/white fixtures, 0% on gray. JSON includes `schema_version` (v2 for histogram stats after M8).

## Lightroom validation (requires LR installed)

```powershell
.\scripts\build-analyzer.ps1
.\scripts\install-plugin.ps1
.\scripts\smoke\m1_smoke.ps1
```

See [docs/LR_TESTING.md](../../docs/LR_TESTING.md) for Plug-in Manager enable, URL handler smokes, and menu automation.

## Size and performance gates

| Gate | Script | Threshold |
|------|--------|-----------|
| GS exe | `scripts/check-bundle-size.ps1` | ≤ 2 MB |
| GS zip | release packaging | ≤ 5 MB |
| GS Lua | `scripts/check-lua-size.ps1 -ShippedOnly` | ≤ 200 lines/file |
| GP bench | `scripts/bench-analyzer.ps1` | ≥ 50 MP/s |

## What not to copy from the bootstrap template

The upstream template ships `examples/lightroom/` (minimal `Info.lua` stub) and `examples/rust/` (hello binary). This repo **supersedes** those stubs with production implementations at the paths above. When upgrading from template, cherry-pick docs and CI — not example code.
