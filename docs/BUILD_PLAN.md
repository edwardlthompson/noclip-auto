# BUILD_PLAN — NoClip Auto

Active milestone tasks only. Completed items are archived to [BUILD_PLAN_COMPLETED.md](BUILD_PLAN_COMPLETED.md) via `scripts/archive-completed-tasks.ps1`.

**Current milestone:** M2 (Clipping analyzer) — M0/M1 scaffolding largely complete.

**Labels:** `[AGENT]` scriptable · `[LR]` needs Lightroom via automation · `[HUMAN-ONLY]` H1–H3 only · `[PARALLEL-OK]` safe to parallelize

---

## M0 — Agent infrastructure, FOSS, GitHub

<!-- PARALLEL -->
- [x] [AGENT] [PARALLEL-OK] LICENSE (Apache-2.0) + CONTRIBUTING.md + SECURITY.md + docs/FOSS.md
- [x] [AGENT] [PARALLEL-OK] Create docs/BUILD_PLAN.md with M0–M6 sections
- [x] [AGENT] [PARALLEL-OK] Create docs/AGENT_MEMORY.md + CHANGELOG.md + GATES.md + docs/GITHUB.md
- [x] [AGENT] [PARALLEL-OK] Create .cursor/AGENTS.md with autopilot loop
- [x] [AGENT] [PARALLEL-OK] Create .github/workflows/ci.yml
- [x] [AGENT] [PARALLEL-OK] scripts/archive-completed-tasks.ps1 + run-milestone-gate.ps1 + foss-audit.ps1
- [x] [AGENT] [PARALLEL-OK] scripts/smoke/m0_smoke.ps1 + README.md
- [x] [AGENT] [PARALLEL-OK] scripts/detect-lr-env.ps1 + init-github-repo.ps1 + update-agent-memory.ps1
- [x] [AGENT] [PARALLEL-OK] scripts/ensure-lr-running.ps1 + verify-lr-plugin.ps1 (stubs)
<!-- END PARALLEL -->

- [ ] [AGENT] Run init-github-repo.ps1 (skip if remote exists); detect-lr-env.ps1 → update AGENT_MEMORY
- [ ] [HUMAN-ONLY] H1: gh auth login — only if init-github-repo.ps1 exits NEEDS_GH_AUTH

**Gate G0**
- [x] BUILD_PLAN, AGENT_MEMORY, CHANGELOG, GATES, LR_TESTING, AGENTS.md exist
- [ ] Gate GF (FOSS) passes
- [ ] GitHub Actions green on main
- [ ] Archive + run-milestone-gate scripts run without error
- [x] README install path matches `%APPDATA%\Adobe\Lightroom\Modules\`
- [ ] detect-lr-env.ps1 wrote LR version or NOT_INSTALLED to AGENT_MEMORY

---

## M1 — Plugin scaffold

<!-- PARALLEL -->
- [x] [AGENT] [PARALLEL-OK] NoClipAuto.lrdevplugin/Info.lua manifest
- [x] [AGENT] [PARALLEL-OK] Init.lua (LrLogger, prefs stub)
- [x] [AGENT] [PARALLEL-OK] ProcessLibrary.lua + ProcessDevelop.lua thin entries
- [x] [AGENT] [PARALLEL-OK] PluginInfoProvider.lua prefs UI
- [x] [AGENT] [PARALLEL-OK] Core/Platform.lua
<!-- END PARALLEL -->

- [ ] [AGENT] [LR] install-plugin.ps1 + verify-lr-plugin.ps1 (ensure-lr-running.ps1 first)

**Gate G1**
- [ ] verify-lr-plugin.ps1 exit 0 — no Lua errors in LrClassicLogs `[AGENT] [LR]`
- [ ] m1_smoke.ps1 exit 0 `[AGENT] [LR]`

---

## M2 — Clipping analyzer

<!-- PARALLEL -->
- [x] [AGENT] [PARALLEL-OK] Scaffold noclip-analyze/ Rust crate
- [x] [AGENT] [PARALLEL-OK] Unit tests: synthetic black/white fixtures
- [x] [AGENT] [PARALLEL-OK] Core/ClippingClient.lua — LrTasks.execute + JSON parse
<!-- END PARALLEL -->

- [ ] [AGENT] scripts/build-analyzer.ps1 — cargo build release-small + copy to bin/win-x64/
- [ ] [AGENT] scripts/generate-fixtures.ps1 + scripts/test_analyzer.ps1
- [ ] [AGENT] Run m2_smoke.ps1 + cargo test

**Gate G2**
- [ ] noclip-analyze.exe exit 0 on fixture; clip metrics sane
- [ ] Gate GS: exe ≤ 2 MB

---

## M3 — Preview render loop

- [x] [AGENT] Core/PreviewRender.lua — tier-aware preview export
- [x] [AGENT] Core/SettingsIO.lua — PV2012 helpers
- [x] [AGENT] Core/PerformanceTier.lua

**Gate G3**
- [ ] Preview JPEG created for test photo `[AGENT] [LR]`
- [ ] m3_smoke.ps1 exit 0 `[AGENT] [LR]`

---

## M4 — Tone pipeline

<!-- PARALLEL -->
- [x] [AGENT] [PARALLEL-OK] Core/Pipeline/Config.lua
- [x] [AGENT] [PARALLEL-OK] PhaseExposure.lua, PhaseWhitesBlacks.lua, PhaseHighlightsShadows.lua
- [x] [AGENT] [PARALLEL-OK] Orchestrator.lua — 3-phase loop
<!-- END PARALLEL -->

- [ ] [AGENT] verify-tone-quality.ps1 + tests/golden/ thresholds
- [ ] [AGENT] m4_smoke.ps1

**Gate G4**
- [ ] Golden fixtures pass verify-tone-quality.ps1
- [ ] Phase 2 caps enforced (Blacks +25, Whites −25)

---

## M5 — Batch + Develop integration

- [x] [AGENT] Core/BatchRunner.lua — progress, cancel, skip VIDEO
- [x] [AGENT] Core/SingleRunner.lua — Develop active photo
- [ ] [AGENT] High-tier export/analyze overlap in BatchRunner
- [ ] [AGENT] Batch summary JSON (NoClipAuto-last-run.json) — implemented; verify in LR
- [ ] [AGENT] Develop snapshot before apply — implemented; verify in LR
- [ ] [AGENT] m5_smoke.ps1

**Gate G5**
- [ ] Batch 10 photos completes without Lua errors `[AGENT] [LR]`
- [ ] Dry-run produces log without apply `[AGENT] [LR]`

---

## M6 — Tune, release v1.0.0

- [ ] [AGENT] Tune phase steps and iteration caps on real photos `[AGENT] [LR]`
- [ ] [AGENT] Gate GS + GP pass (check-bundle-size, bench-analyzer)
- [ ] [AGENT] package-release.ps1 + publish-release.ps1
- [ ] [AGENT] Tag v1.0.0 win64 GitHub release

**Gate G6**
- [ ] Release zip ≤ 5 MB
- [ ] CHANGELOG v1.0.0 section complete

---

## M7 — Mac release (post v1.0, UNVALIDATED)

<!-- PARALLEL -->
- [ ] [AGENT] [PARALLEL-OK] install-plugin.sh + ensure-lr-running.sh
- [ ] [AGENT] [PARALLEL-OK] CI build-analyzer-macos-arm64
- [ ] [AGENT] [PARALLEL-OK] docs/MAC.md + Gate GM in GATES.md
<!-- END PARALLEL -->

- [ ] [AGENT] Tag v1.1.0 UNVALIDATED-macOS release

---

## Cross-cutting (perf + modularity)

<!-- PARALLEL -->
- [x] [AGENT] [PARALLEL-OK] PerformanceTier.lua + Config.lua
- [x] [AGENT] [PARALLEL-OK] Pipeline phase split
- [x] [AGENT] [PARALLEL-OK] Rust release-small + release-bench profiles
- [ ] [AGENT] [PARALLEL-OK] check-bundle-size.ps1 + check-lua-size.ps1 in CI
- [ ] [AGENT] [PARALLEL-OK] bench-analyzer.ps1 + GP gate thresholds
<!-- END PARALLEL -->

---

## Reference docs (not active tasks)

- Algorithm: [ALGORITHM.md](ALGORITHM.md)
- LR testing: [LR_TESTING.md](LR_TESTING.md)
- Mac: [MAC.md](MAC.md)
- Full original plan: archived in repo history / Cursor plan file
