# Parallel Agent Scopes — NoClip Auto

> Isolated file scopes for BUILD_PLAN Parallel lane. No two agents may touch the same path prefix.

## Rules

1. One branch per agent: `feature/agent-<task-slug>`
2. Run `scripts/check-parallel-scope.ps1` before dispatch
3. Shared pipeline/schema: **Sequential agent only** (`Core/Pipeline/`, `ClippingClient.lua`)
4. Never edit `BUILD_PLAN.md` from parallel agents (sequential owner)

## lightroom+rust defaults

| Agent task | Isolated scope |
|------------|----------------|
| Lightroom UI / prefs | `NoClipAuto.lrdevplugin/PluginInfoProvider.lua`, `Core/SettingsUI.lua`, `Core/Prefs.lua` |
| Pipeline phase | One file under `NoClipAuto.lrdevplugin/Core/Pipeline/` per agent |
| Analyzer | `noclip-analyze/src/` (one module per agent) |
| Docs only | `docs/**`, `modules/**`, `README.md` |
| CI/scripts | `scripts/<named-script>.ps1`, `.github/workflows/<one-file>.yml` |

## Never parallelize

- `NoClipAuto.lrdevplugin/Core/Pipeline/Orchestrator.lua` + multiple phase files in one sprint step
- `scripts/run-milestone-gate.ps1`, `scripts/run-milestone-tm-gate.ps1`
- `noclip-analyze/Cargo.toml` + lockfile bumps without sequential owner

## Production path lock

Do not move `NoClipAuto.lrdevplugin/` or `noclip-analyze/` — see `docs/BOOTSTRAP_TEMPLATE_MAP.md`.
