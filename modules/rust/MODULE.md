# Module F: Rust — noclip-analyze

> Active stack module. Production crate: `noclip-analyze/` (not `examples/rust/`).

## Requirements

- **Strict dependency locking:** `Cargo.lock` committed; ship with `release-small` profile (≤ 2 MB exe per gate GS).
- **Static analysis:** `cargo clippy -- -D warnings` and `cargo test` in CI.
- **Local-only:** Analyzer reads JPEG paths from the plugin; no network calls.
- **Output contract:** JSON clip metrics (`schema_version` 1 or 2); consumed by `Core/ClippingClient.lua`.

## Production layout

| Path | Role |
|------|------|
| `noclip-analyze/Cargo.toml` | Crate manifest, `release-small` / `release-bench` profiles |
| `noclip-analyze/src/main.rs` | CLI entry (`--output`, batch mode) |
| `noclip-analyze/src/analyze.rs` | Luminance clip counting (≤2 / ≥253) |
| `noclip-analyze/src/batch.rs` | Multi-image batch analyze |
| `NoClipAuto.lrdevplugin/bin/win-x64/noclip-analyze.exe` | Shipped Windows binary |
| `NoClipAuto.lrdevplugin/bin/macos-arm64/noclip-analyze` | Shipped macOS binary (UNVALIDATED) |

## Build commands

```powershell
# Windows (primary)
.\scripts\build-analyzer.ps1 -Profile release-small

# macOS CI / local
./scripts/build-analyzer-macos.sh release-small aarch64-apple-darwin

# Tests
cd noclip-analyze && cargo test
```

## Activation checklist

- ✅ `Cargo.lock` committed
- ✅ `cargo test` + `cargo clippy -D warnings` in CI
- ✅ `scripts/test_analyzer.ps1` pass on black/white/gray fixtures
- ✅ Gate GS: exe ≤ 2 MB; Gate GP: bench ≥ 50 MP/s (`scripts/bench-analyzer.ps1`)
- ✅ MSRV/edition documented in `AGENT_MEMORY.md` (edition 2021)

## Golden Path reference

See [examples/golden-path/README.md](../../examples/golden-path/README.md) § Analyzer. Golden expected values: `tests/golden/*.json`.

## Feature gate (NoClip profile)

| Stage | Command |
|-------|---------|
| Unit tests | `cargo test` (in `noclip-analyze/`) |
| Integration | `scripts/smoke/m2_smoke.ps1` |
| Fixture sanity | `scripts/test_analyzer.ps1` |
| Size | `scripts/check-bundle-size.ps1` |
| Throughput | `scripts/bench-analyzer.ps1` |

## CodeQL

When `codeql.yml` lands (TM.4), analysis targets `noclip-analyze/` only. Until then, `cargo clippy` is the static-analysis gate.

## Owner labels

| Task type | Label |
|-----------|-------|
| Scaffold crate, tests, build scripts | `AGENT` |
| MSRV / dependency approval | `HUMAN` |
| clippy/fmt/test CI gates | `AUTO` |
