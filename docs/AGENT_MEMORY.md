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
| 2026-06-07 | About sections: README + Plugin Manager (long); GitHub About shortened |

## Blockers

None recorded.

## Decisions (locked)

- Bundled native analyzer required (SDK has no pixel/clipping API)
- 3-phase order: Exposure → Whites/Blacks → Highlights/Shadows
- Clip measurement: luminance ≤ 2 / ≥ 253 on preview JPEG
- PV2012 slider keys only
- GitHub About = short (~100 chars); README/Plugin About = long
