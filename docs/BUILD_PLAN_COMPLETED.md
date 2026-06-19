# BUILD_PLAN_COMPLETED

Archived completed tasks moved from [BUILD_PLAN.md](../BUILD_PLAN.md) by `scripts/archive-completed-tasks.ps1`.

<!-- Archive entries appear below this line after first milestone gate pass -->

## Archived 2026-06-07 17:33

- [x] [AGENT] [PARALLEL-OK] LICENSE (Apache-2.0) + CONTRIBUTING.md + SECURITY.md + docs/FOSS.md
- [x] [AGENT] [PARALLEL-OK] Create docs/BUILD_PLAN.md with M0–M6 sections
- [x] [AGENT] [PARALLEL-OK] Create docs/AGENT_MEMORY.md + CHANGELOG.md + GATES.md + docs/GITHUB.md
- [x] [AGENT] [PARALLEL-OK] Create .cursor/AGENTS.md with autopilot loop
- [x] [AGENT] [PARALLEL-OK] Create .github/workflows/ci.yml
- [x] [AGENT] [PARALLEL-OK] scripts/archive-completed-tasks.ps1 + run-milestone-gate.ps1 + foss-audit.ps1
- [x] [AGENT] [PARALLEL-OK] scripts/smoke/m0_smoke.ps1 + README.md
- [x] [AGENT] [PARALLEL-OK] scripts/detect-lr-env.ps1 + init-github-repo.ps1 + update-agent-memory.ps1
- [x] [AGENT] [PARALLEL-OK] scripts/ensure-lr-running.ps1 + verify-lr-plugin.ps1 (stubs)
- [x] [AGENT] Run init-github-repo.ps1; detect-lr-env.ps1 → update AGENT_MEMORY
- [x] [HUMAN-ONLY] H1: gh auth login — N/A (gh auth active)
- [x] [AGENT] [PARALLEL-OK] README `## About` — version, release notes, changelog, GitHub, Venmo
- [x] [AGENT] [PARALLEL-OK] Plugin Manager About — Core/About.lua + PluginInfoProvider.lua
- [x] [AGENT] [PARALLEL-OK] Shorten live GitHub repo About via `gh repo edit` (97 chars)
- [x] [AGENT] [PARALLEL-OK] Update GITHUB_ABOUT.md — short vs long convention
- [x] [AGENT] [PARALLEL-OK] Sync short description in GITHUB.md
- [x] [AGENT] Verify About sidebar on GitHub (97 chars, preview-safe)
- [x] GitHub About ≤ 120 chars (97 chars applied)
- [x] BUILD_PLAN, AGENT_MEMORY, CHANGELOG, GATES, LR_TESTING, AGENTS.md exist
- [x] Gate GF (FOSS) passes
- [x] GitHub Actions green on main
- [x] run-milestone-gate.ps1 -Milestone 0 exit 0
- [x] README install path matches `%APPDATA%\Adobe\Lightroom\Modules\`
- [x] detect-lr-env.ps1 → LR INSTALLED in AGENT_MEMORY
- [x] [AGENT] [PARALLEL-OK] NoClipAuto.lrdevplugin/Info.lua manifest
- [x] [AGENT] [PARALLEL-OK] Init.lua (LrLogger, prefs stub)
- [x] [AGENT] [PARALLEL-OK] ProcessLibrary.lua + ProcessDevelop.lua thin entries
- [x] [AGENT] [PARALLEL-OK] PluginInfoProvider.lua prefs UI
- [x] [AGENT] [PARALLEL-OK] Core/Platform.lua
- [x] [AGENT] [PARALLEL-OK] Scaffold noclip-analyze/ Rust crate
- [x] [AGENT] [PARALLEL-OK] Unit tests: synthetic black/white fixtures
- [x] [AGENT] [PARALLEL-OK] Core/ClippingClient.lua — LrTasks.execute + JSON parse
- [x] [AGENT] Core/PreviewRender.lua — tier-aware preview export
- [x] [AGENT] Core/SettingsIO.lua — PV2012 helpers
- [x] [AGENT] Core/PerformanceTier.lua
- [x] [AGENT] [PARALLEL-OK] Core/Pipeline/Config.lua
- [x] [AGENT] [PARALLEL-OK] PhaseExposure.lua, PhaseWhitesBlacks.lua, PhaseHighlightsShadows.lua
- [x] [AGENT] [PARALLEL-OK] Orchestrator.lua — 3-phase loop
- [x] [AGENT] Core/BatchRunner.lua — progress, cancel, skip VIDEO
- [x] [AGENT] Core/SingleRunner.lua — Develop active photo
- [x] [AGENT] [PARALLEL-OK] PerformanceTier.lua + Config.lua
- [x] [AGENT] [PARALLEL-OK] Pipeline phase split
- [x] [AGENT] [PARALLEL-OK] Rust release-small + release-bench profiles


## Archived 2026-06-08 12:24

- [x] [AGENT] Core/PreviewRender.lua — LrExportSession preview JPEG export
- [x] [AGENT] Core/PreviewSmoke.lua — automated smoke (import, export, analyze)
- [x] [AGENT] M3SmokeHeadless.lua + ProcessM3Smoke.lua — headless smoke (menu + Init trigger)
- [x] [AGENT] wait-for-lr-ready.ps1, enable-lr-plugin.ps1
- [x] [AGENT] [LR] Preview JPEG created for test photo
- [x] [AGENT] [LR] m3_smoke.ps1 exit 0


## Archived 2026-06-08 12:28

- [x] [AGENT] verify-tone-quality.ps1 + tests/golden/ thresholds
- [x] [AGENT] m4_smoke.ps1
- [x] Golden fixtures pass verify-tone-quality.ps1
- [x] Phase 2 caps enforced (Blacks +25, Whites −25)


## Archived 2026-06-09 09:20

### M8 — Smart Tone & Balance ✅

Gate G8 passed 2026-06-08. v1.2.0 win64 + macOS (UNVALIDATED) released.

- [x] Phase 0 Auto Tone (mandatory) + interim `SettingsIO.syncToPhoto`
- [x] Analyzer v2 (`schema_version: 2`)
- [x] Phase 4 Balance (opt-in pref)
- [x] `m8_smoke.ps1`, `m8_lr_smoke.ps1`, Gate G8 automated
- [x] Tag v1.2.0 release (win64 + macOS)


## M9 — Lens profile pre-pass ✅

Gate G9 passed 2026-06-09. v1.3.0 win64 + macOS (UNVALIDATED) released.

- [x] `Core/Pipeline/LensProfile.lua` + SettingsIO lens extract/restore on dry-run
- [x] Orchestrator Phase −1 (before Auto Tone) + snapshot `NoClip Auto (lens profile)`
- [x] Pref `enableLensProfileCorrection` (default on) + Plugin Manager UI
- [x] `m9_smoke.ps1`, `m9_lr_smoke.ps1`, `m5_menu_smoke.ps1`, Gate G9 automated
- [x] Tag v1.3.0 release (win64 + macOS)


## Sprint TM — Template Migration ✅ (2026-06-18)

Bootstrap alignment to [agent-project-bootstrap](https://github.com/edwardlthompson/agent-project-bootstrap) v0.11.0 for **lightroom+rust** child repo.

| Phase | Deliverables |
|-------|--------------|
| TM.0 | validate-bootstrap, watch-agent-gates, BOOTSTRAP_TEMPLATE_MAP |
| TM.1 | modules/lightroom + rust, examples/golden-path |
| TM.2 | DECISION_LOG, ADR-0001, KNOWLEDGE_BASE, agent docs |
| TM.3 | 9 bootstrap .cursor/rules + CURSOR_MODES |
| TM.4 | dependabot, security/codeql, CI jobs, feature-gate, repo-hygiene |
| TM.5 | Root BUILD_PLAN, AGENTS, AGENT_MEMORY, CHANGELOG |
| TM.6 | editorconfig, gitattributes, pre-commit, template provenance |
| TM.7 | pre-release-gate, full feature-gate profile |
| TM.8 | README badges/gates, KNOWLEDGE_BASE module index |
| TM.9 | run-milestone-tm-gate closure |

**Gate:** `scripts/run-milestone-tm-gate.ps1` exit 0 on 2026-06-18.

Full task list: [COMPLETED_TASKS.md](../COMPLETED_TASKS.md).

