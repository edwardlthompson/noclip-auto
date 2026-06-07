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
| LR status | Unknown — run detect-lr-env.ps1 |
| GitHub repo | Not initialized — run init-github-repo.ps1 |
| Analyzer path | `NoClipAuto.lrdevplugin/bin/win-x64/noclip-analyze.exe` |

## Recent events

| Date | Event |
|------|-------|
| 2026-06-07 | Initial repo scaffold: Lua plugin, Rust analyzer, docs, scripts |
| 2026-06-07 | Built noclip-analyze.exe (1.5 MB); m0/m2 smoke PASS; cargo test PASS |

## Blockers

None recorded.

## Decisions (locked)

- Bundled native analyzer required (SDK has no pixel/clipping API)
- 3-phase order: Exposure → Whites/Blacks → Highlights/Shadows
- Clip measurement: luminance ≤ 2 / ≥ 253 on preview JPEG
- PV2012 slider keys only
