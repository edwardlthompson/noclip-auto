# NoClip Auto

> **⚠️ ALPHA — NOT RECOMMENDED FOR USE**
>
> **This plugin is not working reliably.** Development has **ceased until further notice.** Known bugs include menu/shortcut issues, analyzer failures, slow batch processing, and edits that do not always apply as expected. In practice, **manually adjusting Develop sliders is faster** than running this plugin. Use at your own risk; no support is planned at this time.

[![CI](https://github.com/edwardlthompson/noclip-auto/actions/workflows/ci.yml/badge.svg)](https://github.com/edwardlthompson/noclip-auto/actions/workflows/ci.yml)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-2ea043?style=flat-square)](LICENSE)
[![Template](https://img.shields.io/badge/template-0.15.0-0969da?style=flat-square)](.template-version)
[![Stack](https://img.shields.io/badge/stack-lightroom%2Brust-31A8FF?style=flat-square)](modules/lightroom/MODULE.md)
[![FOSS](https://img.shields.io/badge/FOSS-local--only-656d76?style=flat-square)](docs/FOSS.md)
[![Platform](https://img.shields.io/badge/platform-Windows%2011-blue?style=flat-square)](docs/MAC.md)
[![Status](https://img.shields.io/badge/status-alpha%20%2F%20paused-red?style=flat-square)](CHANGELOG.md)

**Automatically recover clipped highlights and shadows in Adobe Lightroom Classic** *(experimental; see warning above)*.

NoClip Auto is a free, open-source plugin that runs a 3-phase tone pipeline until clipped pixels are eliminated. It works locally on your machine—no cloud, no uploads, no subscription.

---

## About

| | |
|---|---|
| **Status** | **Alpha — development paused** |
| **Version** | **1.3.8** — see [CHANGELOG.md](CHANGELOG.md) |
| **License** | [Apache-2.0](LICENSE) |
| **GitHub** | [edwardlthompson/noclip-auto](https://github.com/edwardlthompson/noclip-auto) |
| **Changelog** | [CHANGELOG.md](CHANGELOG.md) |
| **Modules** | [Lightroom](modules/lightroom/MODULE.md) · [Rust](modules/rust/MODULE.md) |

### Latest release (1.3.8)

- Bootstrap tooling aligned to agent-project-bootstrap **v0.15.0** (Cursor hooks/skills, CI Scorecard/stale/weekly-health, encoding gates)
- No clipping-algorithm changes in this release

See the full [changelog](CHANGELOG.md) for version history.

### Support development

NoClip Auto is free and open source. Development is currently paused; past contributors and donors are still appreciated.

---

## Why NoClip Auto?

Blown highlights and crushed shadows are common after aggressive edits. Fixing them by hand means bouncing between sliders and squinting at clipping indicators. NoClip Auto automates that loop:

1. **Measure** — export a preview and count clipped pixels
2. **Adjust** — apply the right slider for the current pipeline phase
3. **Repeat** — until clipping is gone or safety limits are hit

You get consistent, repeatable recovery across one photo or hundreds.

---

## Features

| Feature | Description |
|---------|-------------|
| **3-phase pipeline** | Exposure → Whites/Blacks → Highlights/Shadows (Process Version 2012) |
| **Batch processing** | Run on selected photos from the Library module |
| **Single-photo mode** | Run on the active photo in Develop |
| **Dry-run mode** | Preview proposed changes without writing to the catalog |
| **Develop snapshots** | Automatic "before" snapshot for easy rollback |
| **Performance tiers** | Auto-scales preview size and batch yield to your CPU/RAM |
| **Plugin Manager prefs** | Clip threshold, tier override, iteration caps |
| **Batch report** | JSON summary of each run (`NoClipAuto-last-run.json`) |
| **Bundled analyzer** | Single install—no separate dependencies |

---

## Requirements

- **Adobe Lightroom Classic** (SDK 6.0+)
- **Windows 11** — primary, validated platform
- **macOS** — CI-built binaries included; [validation status](docs/MAC.md) is community-driven

---

## Installation

### Option A — Release zip (recommended)

1. Download the latest release from [Releases](https://github.com/edwardlthompson/noclip-auto/releases).
2. Unzip and copy the `NoClipAuto.lrdevplugin` folder to:

   ```
   %APPDATA%\Adobe\Lightroom\Modules\
   ```

3. Restart Lightroom Classic.

### Option B — Clone and build

```powershell
git clone https://github.com/edwardlthompson/noclip-auto.git
cd noclip-auto
.\scripts\build-analyzer.ps1
.\scripts\install-plugin.ps1
```

Restart Lightroom Classic after install.

---

## Usage

### Batch (Library)

1. Select one or more photos in the Library.
2. Go to **Library → Plug-in Extras → NoClip Auto - Selected Photos**  
   (also available under **Export** menu).
3. Wait for the progress dialog to finish.

### Single photo

**From Library:** select one photo → **Library → Plug-in Extras → NoClip Auto - Active Photo**

**From Develop:** open a photo → **File → Plug-in Extras → NoClip Auto - Active Photo (File)**

### Settings

Open **File → Plug-in Manager → NoClip Auto** to configure:

- Click **Done** after changing settings so they are saved for the next session.

- **Clip threshold (%)** — stop when clipping falls below this (default 0.05%)
- **Performance tier** — Auto, Low, Balanced, or High
- **Dry run** — log changes without applying
- **Max iterations** — safety cap per photo (default 60)

### Keyboard shortcut

Lightroom Classic has **no SDK API** for plugin keyboard shortcuts.

Run `.\scripts\print-lr-shortcut-help.ps1` for exact menu titles and setup steps.

**macOS:** System Settings → Keyboard → Keyboard Shortcuts → **App Shortcuts** → Adobe Lightroom Classic. Each menu title needs **three leading spaces**. File and Library Active Photo use **different titles** (shortcuts cannot share the same name):

```
   NoClip Auto - Active Photo (File)
   NoClip Auto - Active Photo
   NoClip Auto - Selected Photos
```

**Windows:** OS “App Shortcuts” in Settings **do not work** for Lightroom plugin menus. Use the included **AutoHotkey v2** script instead:

1. Install [AutoHotkey v2](https://www.autohotkey.com/)
2. Run `scripts\NoClipAuto-shortcuts.ahk` (defaults: **Ctrl+Alt+A** = Active Photo in Develop via File menu, **Ctrl+Alt+B** = batch)

If a shortcut does nothing: restart Lightroom, confirm Plug-in Manager shows **1.3.8+**, dry run OFF, and photos are selected.

---

## How it works

Lightroom's SDK cannot read pixel data or clipping statistics from Lua. NoClip Auto exports a tier-sized preview JPEG and analyzes it with a bundled native tool (`noclip-analyze`) that counts clipped pixels by luminance:

- **Shadow clip:** luminance ≤ 2  
- **Highlight clip:** luminance ≥ 253  

The plugin adjusts sliders in order until both counts hit zero (or your threshold):

```text
Phase 1  Exposure        — lift shadows or pull highlights globally
Phase 2  Whites / Blacks — recover extremes (capped at ±25)
Phase 3  Highlights / Shadows — fine-tune remaining clipping
```

Full algorithm details: [docs/ALGORITHM.md](docs/ALGORITHM.md)

```text
NoClipAuto.lrdevplugin/          ← Lightroom plugin (Lua)
  bin/win-x64/noclip-analyze.exe ← Clipped-pixel analyzer (Rust)
noclip-analyze/                  ← Analyzer source
```

The analyzer ships **inside** the plugin folder—you never install it separately.

---

## Build from source

### Prerequisites

- [Rust](https://rustup.rs/) (for `noclip-analyze`)
- [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) (Windows, C++ workload)
- Adobe Lightroom Classic SDK (optional, for local plugin dev)

### Commands

```powershell
# Build the analyzer
.\scripts\build-analyzer.ps1

# Install plugin to Lightroom Modules folder
.\scripts\install-plugin.ps1

# Run smoke tests (no Lightroom required)
.\scripts\smoke\m0_smoke.ps1
.\scripts\smoke\m2_smoke.ps1

# Full local feature gate (cargo test/clippy, build, m2, size)
.\scripts\feature-gate.ps1 -Stack lightroom-rust
```

### Development gates

| Gate | Command | When |
|------|---------|------|
| Quick bootstrap | `.\scripts\validate-bootstrap.ps1 -Quick` | After doc or scaffold changes |
| Full bootstrap | `.\scripts\validate-bootstrap.ps1` | Before milestone closure |
| Feature gate (CI) | `.\scripts\feature-gate.ps1 -Stack lightroom-rust -Ci` | Matches GitHub CI job |
| Feature gate (local) | `.\scripts\feature-gate.ps1 -Stack lightroom-rust` | Pre-merge on Windows |
| Pre-release | `.\scripts\pre-release-gate.ps1` | Before tagging a release |
| M0 smoke | `.\scripts\smoke\m0_smoke.ps1` | FOSS + environment checks |
| M2 smoke | `.\scripts\smoke\m2_smoke.ps1` | Analyzer JSON contract |

Agent sprint steps: `.\scripts\watch-agent-gates.ps1 -Once -Step <tmN>`

See [BUILD_PLAN.md](BUILD_PLAN.md), [docs/GATES.md](docs/GATES.md), and [AGENTS.md](AGENTS.md).

---

## How agents should work in this repo

1. Read [docs/START_HERE.md](docs/START_HERE.md) → pick a Cursor mode ([docs/CURSOR_MODES.md](docs/CURSOR_MODES.md)).
2. Execute [BUILD_PLAN.md](BUILD_PLAN.md) **Sequential** `[AGENT]` rows first; use `/` shortcuts ([docs/help/BATCH_COMMANDS.md](docs/help/BATCH_COMMANDS.md)).
3. Prefer local compute (hooks + worktrees); do not relocate `NoClipAuto.lrdevplugin/` or `noclip-analyze/`.
4. After scaffold/doc changes: `.\scripts\validate-bootstrap.ps1 -Quick` and `python .\scripts\check-file-encoding.py .`.

Bootstrap upgrade notes: [docs/BOOTSTRAP_ALIGNMENT.md](docs/BOOTSTRAP_ALIGNMENT.md) · [docs/UPGRADING_FROM_TEMPLATE.md](docs/UPGRADING_FROM_TEMPLATE.md).

## Project status

Development paused. Product milestones **M0–M9** are complete. **v1.3.8** ships Sprint BA (bootstrap **v0.15.0**). See [BUILD_PLAN.md](BUILD_PLAN.md).

| Milestone | Status |
|-----------|--------|
| M0 — Infrastructure | ✅ Complete |
| M1 — Plugin scaffold | ✅ Complete |
| M2 — Clipping analyzer | ✅ Complete |
| M3 — Preview pipeline | ✅ Complete |
| M4 — Tone quality | ✅ Complete |
| M5 — Batch processing | ✅ Complete |
| M6 — v1.0 release | ✅ Complete |
| M7–M9 — Smart tone, lens pre-pass, regression | ✅ Complete |
| TM — Template migration (0.11.0) | ✅ Complete |
| BA — Bootstrap align (0.15.0) | ✅ Complete (optional BA.H2 / BA.L1 open) |

Archived milestone detail: [docs/BUILD_PLAN_COMPLETED.md](docs/BUILD_PLAN_COMPLETED.md)

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

- [Report a bug](https://github.com/edwardlthompson/noclip-auto/issues/new?template=bug_report.md)
- [Request a feature](https://github.com/edwardlthompson/noclip-auto/issues/new?template=feature_request.md)
- [Mac testers wanted](docs/MAC.md) — help validate macOS builds

---

## License

Apache License 2.0 — see [LICENSE](LICENSE).

The Adobe Lightroom Classic SDK is **not** included in this repository. Download it separately from [Adobe](https://developer.adobe.com/lightroom-classic) for local development.

---

## Links

- [Algorithm](docs/ALGORITHM.md)
- [Agent shortcuts](docs/help/BATCH_COMMANDS.md)
- [Build plan](BUILD_PLAN.md)
- [Changelog](CHANGELOG.md)
- [Knowledge base](KNOWLEDGE_BASE.md)
- [Security policy](SECURITY.md)
