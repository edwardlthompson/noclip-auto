# Changelog



All notable changes to this project will be documented in this file.



The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),

and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).



## [Unreleased]

## [1.2.0] — 2026-06-08

Smart Tone & Balance: mandatory Auto Tone, analyzer v2, optional Balance phase.

### Added

- **Phase 0 Auto Tone** — mandatory first step on every photo (batch `flattenAutoNow` or Develop `setAutoTone`).
- **Analyzer v2** — histogram stats (mean/median/p05/p50/p95, log-avg luma, per-channel clip counts); `schema_version: 2`.
- **Phase 4 Balance** (opt-in pref) — median target exposure + parametric S-curve stretch when not clipped.
- Interim develop apply during measure loop (`SettingsIO.syncToPhoto`) with dry-run restore.
- M8 LR smoke: `Core/M8Smoke.lua`, `M8SmokeBootstrap.lua`, `ProcessM8Smoke.lua`, `scripts/smoke/m8_lr_smoke.ps1`.

### Changed

- Pipeline order: snapshot → Auto Tone → measure → phases 1–3 → optional balance → restore if dry-run.

## [1.1.0] — 2026-06-08

macOS Apple Silicon release (**UNVALIDATED** — CI-built, not maintainer-tested on Mac hardware).

### Added

- `install-plugin.sh`, `ensure-lr-running.sh`, `build-analyzer-macos.sh`, `package-release-macos.sh`
- CI job `build-analyzer-macos-arm64`; workflow `release-macos.yml` for macOS zip + GitHub prerelease
- `scripts/smoke/m7_smoke.sh` / `m7_smoke.ps1`; Gate GM in GATES.md; expanded [MAC.md](MAC.md)

## [1.0.0] — 2026-06-08

First stable Windows release.



### Added



- High-tier batch export/analyze overlap (`PreviewPrefetch`)

- Release packaging: `package-release.ps1`, `publish-release.ps1`, `bench-analyzer.ps1`

- M5 batch integration: `BatchRunner.runBatch`, dry-run log, `NoClipAuto-last-run.json`

- M5 smoke: `M5SmokeBootstrap.lua`, `m5_smoke.ps1`

- Thumbnail preview fallback in `PreviewRender` for LR-safe smoke paths

- M4 tone pipeline gate: `verify-tone-quality.ps1`, golden fixtures

- `noclip-analyze --output` for LR-safe JSON capture on Windows



### Changed



- Pipeline step sizes and iteration caps validated against golden fixtures (see `Config.lua`)

- M3 smoke: preview via `requestJpegThumbnail` + `postAsyncTaskWithContext`

- Windows analyzer: write JSON via `--output` file



### Fixed



- BatchRunner split into `BatchReport`, `BatchSmoke` for modularity and size gate

- Gate G5: batch dry-run 10 photos + dry-run log



## [0.1.0] — 2026-06-07



Pre-release. First public GitHub release.



### Added



- **M0 complete:** FOSS scaffold, GitHub repo, CI workflow, agent docs, smoke/gate scripts

- Two-tier About metadata (short GitHub sidebar + long README/Plugin Manager)

- Plugin Manager About with version, release notes, Changelog/GitHub/Venmo buttons

- 3-phase tone pipeline (Exposure, Whites/Blacks, Highlights/Shadows)

- Batch and Develop menu workflows

- Bundled `noclip-analyze` clipped-pixel counter (Rust)

- Dry-run mode, develop snapshots, batch JSON report

- Performance tiers (Low / Balanced / High)

