# Feature Modules (Vertical Slices)

> How to add incremental features to NoClip Auto after bootstrap migration. Read when implementing new BUILD_PLAN feature rows (post-M9).

## Stack layout

| Layer | Lightroom | Rust |
|-------|-----------|------|
| Composition root | `ProcessLibrary.lua`, `ProcessDevelop.lua` (≤50 lines) | `src/main.rs` CLI |
| Domain logic | `Core/Pipeline/{Feature}.lua` | `src/{module}.rs` |
| Port | `Core/ClippingClient.lua`, `Core/SettingsIO.lua` | JSON output contract |
| Adapter | LR SDK via `BatchRunner` / `SingleRunner` | `image`, `serde_json` crates |
| Tests | `scripts/smoke/m*_smoke.ps1`, manual `[LR]` | `cargo test`, `tests/golden/*.json` |

**Golden Path reference:** [examples/golden-path/README.md](../examples/golden-path/README.md)

## Feature container contract

### New pipeline phase (Lua)

| Step | Location | Rule |
|------|----------|------|
| Phase logic | `Core/Pipeline/Phase{Name}.lua` | Pure rules; no spawn/I/O |
| Register in orchestrator | `Core/Pipeline/Orchestrator.lua` | Wire phase order only |
| Config knob | `Core/Prefs.lua` + `Core/SettingsUI.lua` | Hint text required |
| Docs | `docs/ALGORITHM.md` | Update phase table |
| Regression | `tests/golden/*.json` + `verify-tone-quality.ps1` | Required |

### New analyzer capability (Rust)

| Step | Location | Rule |
|------|----------|------|
| Logic | `noclip-analyze/src/*.rs` | Keep CLI stable or bump `schema_version` |
| Bridge | `Core/ClippingClient.lua` | Parse new JSON fields here only |
| Tests | `cargo test` + `test_analyzer.ps1` | Required |
| Size/perf | `check-bundle-size.ps1`, `bench-analyzer.ps1` | Gates GS + GP |

**Lego rule:** A feature should be removable by deleting its phase module, prefs keys, and orchestrator lines — then `m4_smoke.ps1` (or higher) still passes.

## Per-feature Definition of Done

- ⬜ `[HUMAN]` Acceptance criteria in `docs/features/{name}.md` (create when needed)
- ⬜ `[AGENT]` Feature logic in isolated module(s)
- ⬜ `[AGENT]` Unit/smoke tests updated
- ⬜ `[AGENT]` `docs/ALGORITHM.md` + `DECISION_LOG.md` if behavior changes
- ⬜ `[AUTO]` `watch-agent-gates.ps1 -Once -Step tests` (or milestone gate)
- ⬜ `[LR]` LR smoke when Develop/catalog path touched
- ⬜ `[HUMAN]` Manual smoke on real photos (optional for dry-run-only features)

## Autonomous agent protocol

After each `[AGENT]` BUILD_PLAN step (post-TM product work):

```powershell
.\scripts\watch-agent-gates.ps1 -Once -Step tmN
```

After product feature work (post-TM):

```powershell
.\scripts\watch-agent-gates.ps1 -Once -Step tests
.\scripts\run-milestone-gate.ps1 -Milestone 4   # pipeline features
```

- Exit `0`: proceed
- Exit `1`: fix and re-run; check KNOWLEDGE_BASE.md
- Exit `2`: environment block — escalate to `[HUMAN]`

## Commands

| Script | Purpose |
|--------|---------|
| `scripts/feature-gate.ps1` | Stack lint/test rollup — full profile: cargo test/clippy, m2, size |
| `scripts/pre-release-gate.ps1` | Pre-tag checks: full feature-gate + version coherence |
| `scripts/watch-agent-gates.ps1` | Step dispatcher + gate loop |
| `scripts/validate-bootstrap.ps1` | Bootstrap artifact check |
| `scripts/run-milestone-gate.ps1` | M0–M9 milestone rollup |
| `scripts/verify-tone-quality.ps1` | Pipeline golden regression |

## Anti-patterns

| Do not | Why |
|--------|-----|
| Spawn analyzer outside `ClippingClient.lua` | Breaks hexagonal port (ADR-0001) |
| `require()` in `Init.lua` | KB-001 — runtime failure |
| Hardcode OS paths outside `Platform.lua` | Breaks Mac/Win parity |
| Strip settings hints for line count | KB-007 — user confusion + rule violation |
| Batch multiple features in one PR | Breaks lego isolation |
| Move plugin to `examples/lightroom/` | KB-008 — breaks install/releases |

## Reference exemplars (shipped features)

| Feature | Phase module | Milestone |
|---------|--------------|-----------|
| Clip loop | `PhaseExposure`, `PhaseWhitesBlacks`, `PhaseHighlightsShadows` | M4 |
| Batch + dry-run | `BatchRunner`, `SettingsIO` | M5 |
| Auto Tone + Balance | `AutoTone`, `PhaseBalance` | M8 |
| Lens profile | `LensProfile` | M9 |
