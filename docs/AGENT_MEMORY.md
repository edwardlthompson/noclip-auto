# AGENT_MEMORY

Persistent facts for agents. Rolling log — older events may move to AGENT_MEMORY_ARCHIVE.md.

## Project

| Key | Value |
|-----|-------|
| Name | NoClip Auto |
| License | Apache-2.0 |
| Primary platform | Windows 11 |
| Mac status | CI-built, UNVALIDATED |
| Install path (Win) | `%APPDATA%\Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin\` |
| Install path (Mac) | `~/Library/Application Support/Adobe/Lightroom/Modules/` |

## Environment

| Key | Value |
|-----|-------|
| LR status | INSTALLED — `C:\Program Files\Adobe\Adobe Lightroom Classic` |
| GitHub repo | https://github.com/edwardlthompson/noclip-auto |
| Analyzer path | `NoClipAuto.lrdevplugin/bin/win-x64/noclip-analyze.exe` |

## Recent events

| Date | Event |
|------|-------|
| 2026-06-07 | Initial repo scaffold: Lua plugin, Rust analyzer, docs, scripts |
| 2026-06-07 | GitHub repo created: https://github.com/edwardlthompson/noclip-auto |
| 2026-06-07 | Built noclip-analyze.exe (1.5 MB); m0/m2 smoke PASS; cargo test PASS |
| 2026-06-07 | M0 gate passed: FOSS audit, m0 smoke, CI green, LR detected INSTALLED |
| 2026-06-07 | M2 gate passed: cargo test, test_analyzer, m2_smoke; exe 1.5 MB |
| 2026-06-07 | M3 scaffold: PreviewRender, PreviewSmoke, m3_smoke, URL handler; verify-lr-plugin fixed (load marker) |
| 2026-06-08 | **M4 gate passed**: `verify-tone-quality.ps1`, golden fixtures, phase 2 caps (+25/−25) |
| 2026-06-08 | **M5 gate passed**: BatchRunner overlap, dry-run log, `m5_smoke.ps1` (Init bootstrap + thumbnail preview) |
| 2026-06-08 | **M6 gate passed**: v1.0.0 win64 release; GS (exe 1.5 MB, zip 0.68 MB); GP 115 MP/s |

## Blockers

| Date | Blocker | Mitigation |
|------|---------|------------|
| 2026-06-07 | M3 smoke requires one-time **Plug-in Manager → Enable** for NoClip Auto | `enable-lr-plugin.ps1`; see LR_TESTING.md |

## Decisions (locked)

- Bundled native analyzer required (SDK has no pixel/clipping API)
- M3 preview smoke uses `requestJpegThumbnail` (not `LrExportSession` from Init/menu async)
- Windows: run `noclip-analyze --output` from PowerShell in `m3_smoke.ps1`; LR cannot spawn analyzer reliably
- Manual M3 menu smoke PASS = preview JPEG valid; clip counts verified in automated gate
- M5 automated smoke uses `M5SmokeBootstrap.lua` (Init dofile); production batch via `BatchRunner` + menu `ProcessM5Smoke.lua`
- M8 LR smoke uses `M8SmokeBootstrap.lua` → `require("Core.M8Smoke")` after package.path setup; validates Auto Tone + analyzer v2 on 3-photo dry-run
- M7 macOS: CI builds `aarch64-apple-darwin` analyzer; release via `release-macos.yml` (UNVALIDATED prerelease)
- Init cannot `require()` Core modules — use dofile bootstrap or menu/URL toolkit entry points
- 3-phase order: Exposure → Whites/Blacks → Highlights/Shadows
- Clip measurement: luminance ≤ 2 / ≥ 253 on preview JPEG
- PV2012 slider keys only
- GitHub About = short (~100 chars); README/Plugin About = long
