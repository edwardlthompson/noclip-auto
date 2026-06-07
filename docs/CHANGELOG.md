# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- (Changes after 0.1.0 will be listed here)

### Changed

- M1 smoke: restart LR after install for reliable plugin load verification
- `wait-for-lr-plugin.ps1` — poll verify until plugin appears in logs

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
