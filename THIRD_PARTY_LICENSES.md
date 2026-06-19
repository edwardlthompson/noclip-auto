# Third-Party Licenses

> Rust analyzer dependencies ship inside `noclip-analyze`. Adobe Lightroom SDK is **not** bundled.

## Project License

NoClip Auto is licensed under **Apache-2.0**. See [`LICENSE`](LICENSE).

The bundled `noclip-analyze` binary statically links Rust crates from `noclip-analyze/Cargo.lock`.

## Direct Rust dependencies (`noclip-analyze`)

| Crate | License (crates.io) | Use |
|-------|---------------------|-----|
| clap | MIT OR Apache-2.0 | CLI parsing |
| image | MIT OR Apache-2.0 | JPEG decode |
| rayon | MIT OR Apache-2.0 | Parallel pixel scan |
| serde | MIT OR Apache-2.0 | JSON serialization |
| serde_json | MIT OR Apache-2.0 | JSON output |

Transitive dependencies are listed in `noclip-analyze/Cargo.lock`. Regenerate this summary before releases:

```powershell
cd noclip-analyze
cargo install cargo-license --quiet 2>$null
cargo license --json
```

## Adobe Lightroom Classic SDK

The Lightroom plugin uses the Adobe SDK (`Lr*` Lua APIs). The SDK is **proprietary** and must be downloaded separately from Adobe for local development. It is not included in this repository.

## Incompatible licenses

`[HUMAN]` must approve any dependency with copyleft licenses (GPL, AGPL) that may affect distribution. Document exceptions in `DECISION_LOG.md`.

## Attribution in releases

Include this file (or a generated `NOTICE`) in release zips when shipping third-party binaries.
