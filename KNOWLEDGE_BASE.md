# Knowledge Base

> Project-specific edge cases, resolved bugs, and anti-patterns for NoClip Auto.
> **Do not populate with generic framework definitions.**

## How to use

1. Add entries only after resolving a non-obvious issue specific to this project.
2. Include: symptom, root cause, fix, and prevention.
3. Link to [DECISION_LOG.md](DECISION_LOG.md) or PRs when available.

## Module index

| Area | Doc | Production path |
|------|-----|-----------------|
| Lightroom plugin | [modules/lightroom/MODULE.md](modules/lightroom/MODULE.md) | `NoClipAuto.lrdevplugin/` |
| Rust analyzer | [modules/rust/MODULE.md](modules/rust/MODULE.md) | `noclip-analyze/` |
| Golden Path | [examples/golden-path/README.md](examples/golden-path/README.md) | Docs-only pointer to prod paths |
| Feature modules | [docs/FEATURE_MODULES.md](docs/FEATURE_MODULES.md) | Vertical slices + gate scripts |
| Bootstrap map | [docs/BOOTSTRAP_TEMPLATE_MAP.md](docs/BOOTSTRAP_TEMPLATE_MAP.md) | Template alignment |
| Gates | [docs/GATES.md](docs/GATES.md) | M0–M9 + bootstrap gate matrix |

### Gate scripts

| Script | Profile |
|--------|---------|
| `scripts/validate-bootstrap.ps1` | Artifact + FOSS checks (`-Quick` skips m0 smoke) |
| `scripts/feature-gate.ps1` | CI (`-Ci`) or full local (cargo, m2, size) |
| `scripts/pre-release-gate.ps1` | Pre-tag: full feature-gate + version coherence |
| `scripts/watch-agent-gates.ps1` | Sprint step runner (`-Step tmN`) |
| `scripts/run-milestone-tm-gate.ps1` | TM sprint closure gate |

## Entries

### KB-001 — Init.lua cannot require() Core modules

| Field | Detail |
|-------|--------|
| **Symptom** | Plugin fails at startup; `module 'Core.Prefs' not found` from Init |
| **Cause** | `package` is nil in Lightroom Init context |
| **Fix** | `dofile` for Init smoke bootstraps; defer `require` until `Loader.setup()` inside `postAsyncTaskWithContext` |
| **Prevention** | Never add `require("Core.*")` to `Init.lua`; see DECISION_LOG 2026-06-07 |

### KB-002 — Windows analyzer returns no output from menu async

| Field | Detail |
|-------|--------|
| **Symptom** | Batch or Active Photo fails with "analyzer returned no output" |
| **Cause** | Bare `LrTasks.execute` / external spawn from menu async context; colliding output paths when `os.time()` reused |
| **Fix** | Run analyze inside `LrTasks.startAsyncTask`; unique output path per call; stdout-first then file fallback; validate JPEG magic bytes |
| **Prevention** | Follow `Core/ClippingClient.lua` pattern; see CHANGELOG 1.3.6–1.3.7 |

### KB-003 — Plugin Manager prefs do not auto-persist

| Field | Detail |
|-------|--------|
| **Symptom** | User changes clip threshold; next session reverts to default |
| **Cause** | `propertyTable` in Plugin Manager is not auto-saved |
| **Fix** | `startDialog`/`endDialog` in `PluginInfoProvider.lua` + `Core/Prefs.lua` load/save via `LrPrefs.prefsForPlugin()` |
| **Prevention** | Read [docs/SETTINGS_UI.md](SETTINGS_UI.md) before editing prefs UI |

### KB-004 — smoke/*.trigger hijacks Library menu

| Field | Detail |
|-------|--------|
| **Symptom** | Library menu runs dev smoke instead of production batch |
| **Cause** | Stale `smoke/*.trigger` left in installed plugin from old `ProcessLibrary` dev shortcut |
| **Fix** | Remove triggers from installed copy; production path is `ProcessLibrary.lua` → `BatchRunner` only |
| **Prevention** | `.gitignore` excludes `smoke/*.trigger`; never ship triggers in release zip (removed v1.3.1) |

### KB-005 — M3 requires one-time Plug-in Manager Enable

| Field | Detail |
|-------|--------|
| **Symptom** | `m1_smoke.ps1` / URL handler smokes fail on fresh install |
| **Cause** | Lightroom disables new plugins until explicitly enabled |
| **Fix** | `scripts/enable-lr-plugin.ps1` or manual Plug-in Manager → Enable |
| **Prevention** | Document in [docs/LR_TESTING.md](docs/LR_TESTING.md); record LR status in `AGENT_MEMORY.md` |

### KB-006 — macOS analyzer UNVALIDATED

| Field | Detail |
|-------|--------|
| **Symptom** | macOS user reports analyzer or menu failures |
| **Cause** | CI builds `aarch64-apple-darwin` binary without maintainer on-device LR proof |
| **Fix** | Community validation per [docs/MAC.md](MAC.md); file issues with LR version + macOS version |
| **Prevention** | Release tags include UNVALIDATED-macOS label; do not claim Mac support in README beyond CI-built status |

### KB-007 — Lua file size gate (200 lines shipped)

| Field | Detail |
|-------|--------|
| **Symptom** | CI `size-gate` or `check-lua-size.ps1 -ShippedOnly` fails |
| **Cause** | Core module grew past 200 lines |
| **Fix** | Split into focused modules under `Core/`; never strip Settings UI hints for line count |
| **Prevention** | Use `Core/SettingsUI.lua` helpers; see `.cursor/rules/settings-ui-hints.mdc` |

### KB-008 — Template migration: production path lock

| Field | Detail |
|-------|--------|
| **Symptom** | Agent proposes moving plugin to `examples/lightroom/` |
| **Cause** | Bootstrap template defaults to `examples/{stack}/` Golden Path stubs |
| **Fix** | Keep `NoClipAuto.lrdevplugin/` and `noclip-analyze/` at repo root; document in `examples/golden-path/README.md` |
| **Prevention** | Read [docs/BOOTSTRAP_TEMPLATE_MAP.md](BOOTSTRAP_TEMPLATE_MAP.md) before structural changes |
