# Mac Support — NoClip Auto

**Status: UNVALIDATED** — macOS binaries are CI-compiled on `macos-latest`; not tested by the maintainer on physical Mac hardware.

## Install path

```
~/Library/Application Support/Adobe/Lightroom/Modules/NoClipAuto.lrdevplugin/
```

Or run:

```bash
chmod +x scripts/install-plugin.sh scripts/ensure-lr-running.sh
./scripts/install-plugin.sh
```

## Scripts (macOS)

| Script | Purpose |
|--------|---------|
| `install-plugin.sh` | Copy plugin to Lightroom Modules folder; `chmod +x` analyzer |
| `ensure-lr-running.sh` | Start Lightroom Classic if not running; wait for log heartbeat |
| `build-analyzer-macos.sh` | Build `aarch64-apple-darwin` analyzer into `bin/macos-arm64/` |
| `package-release-macos.sh` | Stage release zip (macOS arm64 only, dev smoke stripped) |
| `smoke/m7_smoke.sh` | Build analyzer + fixture JSON smoke on Mac |

Automated gate on Windows: `scripts/smoke/m7_smoke.ps1` (script/CI checks). Full analyzer build runs in GitHub Actions `build-analyzer-macos-arm64`.

## Gatekeeper

If the analyzer is blocked:

```bash
xattr -cr NoClipAuto.lrdevplugin
chmod +x NoClipAuto.lrdevplugin/bin/macos-arm64/noclip-analyze
```

## Binary layout

```
bin/macos-arm64/noclip-analyze   # Apple Silicon (CI-built)
bin/macos-x64/noclip-analyze     # optional Intel (not CI-built by default)
```

Release zip: `NoClipAuto-v1.1.0-macos-arm64.lrdevplugin.zip` (no Windows `.exe`).

## Known caveats

- App Store Lightroom builds may restrict `LrTasks.execute`
- Use Adobe installer version of Lightroom Classic when possible

## Validation

We need community testers. Use the Mac validation issue template on GitHub.

Report: LR version, macOS version, Apple Silicon vs Intel, output of `./scripts/smoke/m7_smoke.sh`.

## Release label

macOS release assets are published as **UNVALIDATED** (GitHub prerelease) until community validation. See Gate GM in [GATES.md](GATES.md).

## Publish (maintainer)

From a machine with `gh` auth, trigger CI packaging:

```powershell
.\scripts\publish-macos-release.ps1 -Version 1.1.0 -Wait
```

Or push tag `v1.1.0` to run `.github/workflows/release-macos.yml`.
