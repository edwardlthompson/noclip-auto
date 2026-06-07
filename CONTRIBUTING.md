# Contributing to NoClip Auto

Thank you for contributing to this FOSS Lightroom Classic plugin.

## Development setup

1. Clone the repository.
2. Install [Rust](https://rustup.rs/) for building `noclip-analyze`.
3. Build the analyzer and install the plugin:
   ```powershell
   .\scripts\build-analyzer.ps1
   .\scripts\install-plugin.ps1
   ```
4. Run smoke tests before opening a PR:
   ```powershell
   .\scripts\smoke\m0_smoke.ps1
   .\scripts\smoke\m2_smoke.ps1
   ```

## Code style

- **Lua:** Keep entry files ≤ 50 lines; Core modules ≤ 200 lines. Lazy-load via `require()` inside async tasks.
- **Rust:** Minimal dependencies; use `release-small` for shipped binaries.
- **Paths:** Never hardcode OS paths outside `Core/Platform.lua`.

## Pull requests

- One logical change per PR when possible.
- Update `docs/CHANGELOG.md` under `[Unreleased]`.
- Ensure CI passes (Rust tests, FOSS audit, size gates).

## Mac validation

We welcome Mac testers. See [docs/MAC.md](docs/MAC.md) and the Mac validation issue template.

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.
