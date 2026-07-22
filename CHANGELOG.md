# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.8] — 2026-07-21

Bootstrap tooling alignment to agent-project-bootstrap v0.15.0 (Sprint BA). No clipping-algorithm changes.

### Added

- Cursor FOSS hooks, skills, agents; /cleanup command; local-compute / security-triage / feature-modules rules
- TEMPLATE_INDEX.json, HUMAN_BACKLOG.md, docs/BOOTSTRAP_ALIGNMENT.md, upgrade/init docs
- Scripts: file-encoding check, template-update checker, parallel/maintainer helpers
- CI: dependency-review, OpenSSF Scorecard, stale, weekly-health (lightroom-rust)

### Changed

- .template-version **0.11.0 → 0.15.0**; validate-bootstrap expanded for BA artifacts
- README agent workflow section; batch command registry (26 commands)

## [1.3.7] — 2026-06-18
Fix Windows Active Photo analyze failure; fix keyboard shortcut docs and menu titles.

### Added

- **`scripts/NoClipAuto-shortcuts.ahk`** — AutoHotkey v2 defaults (Ctrl+Alt+A File Active Photo, Ctrl+Alt+B batch) for Windows.

### Fixed

- **"analyzer returned no output"** on Windows — run `noclip-analyze` inside `LrTasks.startAsyncTask` (LR blocks bare `execute` in menu async context); stdout-first then file fallback; validate JPEG magic bytes; unique preview filenames.
- **Keyboard shortcuts** — File and Library both used identical menu title `Active Photo`, so macOS App Shortcuts (and manual assignment) could not distinguish them. File menu item renamed **`NoClip Auto - Active Photo (File)`**. Windows Settings App Shortcuts do not work for LR plugins; use AutoHotkey instead.

### Changed

- `print-lr-shortcut-help.ps1` documents macOS vs Windows setup correctly (no longer opens wrong Settings page on Windows).

## [1.3.6] — 2026-06-10

Fix Windows analyzer failures during Active Photo / batch measure loops.

### Fixed

- **"analyzer returned no output"** — measure loop can run many times per second; output files used `os.time()` only and collided. Each analyze call now gets a unique output path; Windows polling restored to the reliable M3 pattern (60s, 100ms sleep).

## [1.3.5] — 2026-06-10

Active Photo feedback and large-batch speed improvements.

### Added

- **Fast performance tier** — 384px thumbnail preview, overlap prefetch, 2× phase step sizes (fewer iterations per photo).
- **Progress bar for Active Photo** — File/Library single-photo runs show phase captions (was silent for minutes).
- **`enableDevelopSnapshots`** pref (default OFF) — optional single before snapshot; intermediate snapshots removed.

### Changed

- **Balanced tier** enables overlap prefetch; default tier **Fast**; default max iterations **40** (was 60).
- Measure-loop develop writes skip History entries until the final apply (quieter, faster catalog updates).
- Auto Tone skips slow `revealPhoto` fallback when the photo is already the Develop target.
- Windows analyzer wait uses yield polling instead of 500ms sleeps.

## [1.3.4] — 2026-06-10

Correct Develop single-photo menu path; fix Library Active Photo crash.

### Fixed

- **Develop “Photo menu” missing** — `LrDevelopMenuItems` is not a valid Lightroom SDK key (LR ignores it). Active Photo is now on **File → Plug-in Extras**, which works in Develop and all modules.
- **Library Active Photo crash** — `getTargetPhoto()` is Develop-only; fall back to the selected Library photo.

## [1.3.3] — 2026-06-08

Restore settings UI, reachable single-photo menu, faster progress, and reliable develop apply.

### Added

- **`Core/SettingsUI.lua`** — Plugin Manager sliders with numeric fields, full per-setting hint text, and Reset to defaults.
- **Library → Plug-in Extras → NoClip Auto - Active Photo** — single-photo entry without switching to Develop.
- **`useFullSizePreview`** pref (default off) — optional full export for measure loop; default uses fast thumbnail preview.
- **`Core/RunSummary.lua`** — completion dialogs show iterations, clip before/after, exposure delta, and zero-change warnings.
- Docs: [`docs/SETTINGS_UI.md`](SETTINGS_UI.md), agent memory rule, `.cursor/rules/settings-ui-hints.mdc`.
- **`scripts/verify-develop-menu.ps1`** — confirms installed `Info.lua` has Library + Develop menu entries.

### Fixed

- **Frozen progress bar** — thumbnail measure path by default; fractional `setPortionComplete` and phase captions during batch.
- **"Processed: 1" but no slider movement** — unified `SettingsIO.applyTone` (3-arg `applyDevelopSettings`); final sync at end of pipeline; Auto Tone fallback via `revealPhoto` + `setAutoTone` when batch flags produce no change.
- **Develop Photo menu hard to find** — Plugin Manager hint documents Library batch + Active Photo paths.

### Changed

- `PluginInfoProvider.lua` delegates settings UI to `SettingsUI.lua` (stays under 200-line gate).

## [1.3.2] — 2026-06-09

Settings reset, production menus only, and fixes for silent batch failure.

### Added

- Plugin Manager **Reset to defaults** button (safe Balanced preset, dry run OFF).

### Fixed

- **Library batch progress** — avoid nested `callWithContext` (batch could exit without running).
- **Prefs reload** before each run so Plugin Manager changes (especially dry run) apply immediately.
- **Dry run confirmation** — warns before a run that will not save edits.
- **Library menu** — dev smoke entries removed from `Info.lua` (production install shows one item).
- Windows analyzer spawn uses the same `cmd /c` path format as the working smoke harness.

### Changed

- Default performance tier: **Balanced** (was Auto).

## [1.3.1] — 2026-06-09

Fix production menus doing nothing in Lightroom.

### Fixed

- **Library / Develop menus silent failure** — menu scripts now use `postAsyncTaskWithContext` (yield-safe) with error dialogs attached.
- **`Core/Loader.lua`** — always loads plugin modules via `dofile`; LR native `require` cannot resolve `Core/*` ("not in the toolkit").
- **`install-plugin.ps1`** — builds and copies `noclip-analyze.exe` before installing; removes stale `smoke/*.trigger` files.
- **Library menu hijacked by dev smoke triggers** — removed M3 trigger shortcut from `ProcessLibrary.lua` (use Plug-in Extras dev items or smoke scripts instead).

## [1.3.0] — 2026-06-09

Auto lens profile correction before Auto Tone (optional pref, default on).

### Added

- **Phase −1 Lens profile** — `Core/Pipeline/LensProfile.lua`; applies `EnableLensCorrections`, `LensProfileEnable`, `AutoLateralCA` before Phase 0 Auto Tone.
- Plugin Manager pref **`enableLensProfileCorrection`** (default on) with hint text.
- Dry-run restores initial **tone and lens** develop settings via `SettingsIO.restoreInitial`.
- M9 smoke: `Core/M9Smoke.lua`, `M9SmokeBootstrap.lua`, `scripts/smoke/m9_smoke.ps1`, `scripts/smoke/m9_lr_smoke.ps1`.
- Production menu smoke: `scripts/smoke/m5_menu_smoke.ps1` (ProcessLibrary via Plug-in Extras).

### Changed

- Pipeline order: snapshot → lens profile → Auto Tone → measure → clip phases → optional balance.
- `BatchReport` includes `lensProfileApplied` / `lensHadProfile` per photo.
- `Core/Loader.lua` seeds `package` + `require` when nil (Init smoke bootstraps).
- M8/M9 LR smoke: nested async task (no `pcall` around yields); smoke analyze fallback returns schema v2 fields.

## [1.2.2] — 2026-06-09

Fix plugin load failure that hid the Develop menu and broke Library batch.

### Fixed

- **Init.lua crash** — `package` is nil in LR’s Init context; removed `package.path` and `require()` from Init. Prefs load via `dofile("Core/Prefs.lua")` only.
- **Menu `require()` paths** — new [`Core/Loader.lua`](NoClipAuto.lrdevplugin/Core/Loader.lua) sets `package.path` in menu/URL scripts (`ProcessDevelop`, `ProcessLibrary`, `UrlHandler`, dev smoke menus).
- **Develop menu missing** — was a symptom of Init failure; `LrDevelopMenuItems` entry appears under **Photo → NoClip Auto - Active Photo** once plugin loads.

### Added

- README **Keyboard shortcut** section — OS-level shortcuts (Windows/macOS); Plug-in Extras items need 3 leading spaces in the menu title.

## [1.2.1] — 2026-06-09

Fix production menu entry points (Library batch and Develop single-photo).

### Fixed

- **`require("Core.*")` in menu scripts** — configure `package.path` in `Init.lua` so `ProcessLibrary.lua` and `ProcessDevelop.lua` resolve Core modules (smoke bootstraps already did this; production menus did not).
- **README menu paths** — Develop action is under **Photo →**, not Settings; Library batch is under **Library → Plug-in Extras**.
- **Plugin Manager settings not persisting** — load/save `LrPrefs` via `startDialog`/`endDialog`; only apply defaults when a pref key is nil (not `or`-overwrite on every init).

### Added

- [`Core/Prefs.lua`](NoClipAuto.lrdevplugin/Core/Prefs.lua) — shared defaults, normalization, and property-table sync.

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

