# FOSS Policy — NoClip Auto

## License

This project is licensed under **Apache License 2.0**. See [LICENSE](../LICENSE).

## Dependencies

### Rust (`noclip-analyze`)

Allowed licenses: MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, Unicode-3.0.

Run `scripts/foss-audit.ps1` to verify.

### Lua plugin

Uses Adobe Lightroom Classic SDK APIs only. **Do not commit Adobe SDK files** to this repository.

## Shipped artifacts

- `NoClipAuto.lrdevplugin/` — Lua source + bundled analyzer binary
- Analyzer source always available in `noclip-analyze/`
- CI builds prove reproducibility

## Network

v1.0 has **no network calls** in plugin or analyzer.

## Contribution

Contributions are licensed under Apache-2.0. See [CONTRIBUTING.md](../CONTRIBUTING.md).
