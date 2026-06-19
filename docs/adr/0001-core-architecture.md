# ADR-0001: Core Application Architecture — NoClip Auto

- **Status:** Accepted (HUMAN approved 2026-06-18, TM.H3)
- **Date:** 2026-06-18
- **Deciders:** Project team
- **Supersedes:** Informal M0–M9 scaffold conventions

## Context

NoClip Auto is a **Lightroom Classic plugin + bundled Rust analyzer**. The Adobe SDK constrains Lua to `Lr*` namespaces with no direct pixel access. Agents need explicit layer boundaries after bootstrap alignment.

## Decision

**Selected pattern:** Hexagonal (Ports & Adapters)

### Domain core (Lua)

- **Pipeline rules:** `Core/Pipeline/*.lua` — pure phase logic (exposure, whites/blacks, highlights/shadows, balance, lens profile)
- **Orchestration:** `Core/Pipeline/Orchestrator.lua` — iteration loop, phase transitions, safety caps
- **Configuration:** `Core/Prefs.lua`, `Core/Pipeline/Config.lua` — thresholds, tier, dry-run

No direct file I/O or process spawn inside phase modules.

### Ports (interfaces)

| Port | Adapter | Location |
|------|---------|----------|
| Clip measurement | `ClippingClient` | `Core/ClippingClient.lua` |
| Develop settings read/write | `SettingsIO` | `Core/SettingsIO.lua` |
| Preview export | `PreviewRender` | `Core/PreviewRender.lua` |
| Platform paths | `Platform` | `Core/Platform.lua` |
| User preferences UI | `SettingsUI` + `PluginInfoProvider` | `Core/SettingsUI.lua` |

### Adapters (infrastructure)

| Adapter | Technology | Location |
|---------|------------|----------|
| Native analyzer | Rust CLI JSON | `noclip-analyze/` → `bin/*/noclip-analyze*` |
| Lightroom SDK | Lua `Lr*` APIs | Menu entries, `BatchRunner`, `SingleRunner` |
| Automation / smoke | PowerShell | `scripts/smoke/`, `scripts/*-lr-*.ps1` |

### Composition root (thin entries)

| Entry | Max lines | Role |
|-------|-----------|------|
| `ProcessLibrary.lua` | ≤50 | Library batch menu → `BatchRunner` |
| `ProcessDevelop.lua` | ≤50 | Develop/File menu → `SingleRunner` |
| `Init.lua` | minimal | Logger + prefs; `dofile` only |

**Loader:** `Core/Loader.lua` seeds `require` inside async tasks (not in Init).

## Golden Path

End-to-end reference: [examples/golden-path/README.md](../../examples/golden-path/README.md)  
Algorithm detail: [docs/ALGORITHM.md](../ALGORITHM.md)

```text
Menu entry (composition root)
    → Runner (Batch / Single)
        → PreviewRender (export JPEG)
        → ClippingClient (port)
            → noclip-analyze (adapter)
        → Orchestrator (domain loop)
        → SettingsIO (apply / dry-run restore)
```

## Consequences

- New measurement backends must implement the `ClippingClient` JSON contract — not inline spawn in pipeline code
- New pipeline phases go under `Core/Pipeline/` with unit/smoke coverage; keep files ≤200 lines
- Rust changes must keep `cargo test`, `m2_smoke.ps1`, and golden fixture compatibility
- Changing this ADR requires a new ADR entry and `[HUMAN]` approval in `BUILD_PLAN.md`

## Alternatives considered

| Pattern | Rejected because |
|---------|------------------|
| Monolithic Lua | Already outgrown; M3+ split proved necessary |
| MVVM | No traditional view layer — LR Plugin Manager is the view |
| Clean Architecture (full layers) | Folder overhead exceeds team size; hexagonal ports suffice |
| Move code to `examples/` | Breaks install, release, smoke (see DECISION_LOG 2026-06-18 TM) |

## Module index

| Module | Guide |
|--------|-------|
| Lightroom | [modules/lightroom/MODULE.md](../../modules/lightroom/MODULE.md) |
| Rust | [modules/rust/MODULE.md](../../modules/rust/MODULE.md) |
