# NoClip Auto

[![CI](https://github.com/edwardlthompson/noclip-auto/actions/workflows/ci.yml/badge.svg)](https://github.com/edwardlthompson/noclip-auto/actions/workflows/ci.yml)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%2011-blue)](docs/MAC.md)

**Automatically recover clipped highlights and shadows in Adobe Lightroom Classic.**

NoClip Auto is a free, open-source plugin that runs a 3-phase tone pipeline until clipped pixels are eliminated. It works locally on your machine—no cloud, no uploads, no subscription.

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
2. Go to **File → Plug-in Extras → NoClip Auto — Selected Photos**  
   (also available under **Export** menu).
3. Wait for the progress dialog to finish.

### Single photo (Develop)

1. Open a photo in the **Develop** module.
2. Go to **Settings → NoClip Auto — Active Photo**.

### Settings

Open **File → Plug-in Manager → NoClip Auto** to configure:

- **Clip threshold (%)** — stop when clipping falls below this (default 0.05%)
- **Performance tier** — Auto, Low, Balanced, or High
- **Dry run** — log changes without applying
- **Max iterations** — safety cap per photo (default 60)

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
```

---

## Project status

Active development. See [docs/BUILD_PLAN.md](docs/BUILD_PLAN.md) for milestone progress and [docs/CHANGELOG.md](docs/CHANGELOG.md) for release notes.

| Milestone | Status |
|-----------|--------|
| M0 — Infrastructure | Complete |
| M1 — Plugin scaffold | Complete |
| M2 — Clipping analyzer | Complete |
| M3–M4 — Preview + pipeline | Code complete; LR validation pending |
| M5–M6 — Batch tuning + v1.0 release | In progress |

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
- [Build plan](docs/BUILD_PLAN.md)
- [Changelog](docs/CHANGELOG.md)
- [Security policy](SECURITY.md)
