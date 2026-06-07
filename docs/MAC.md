# Mac Support — NoClip Auto

**Status: UNVALIDATED** — macOS binaries are CI-compiled; not tested by the maintainer.

## Install path

```
~/Library/Application Support/Adobe/Lightroom/Modules/NoClipAuto.lrdevplugin/
```

Or run:

```bash
./scripts/install-plugin.sh
```

## Gatekeeper

If the analyzer is blocked:

```bash
xattr -cr NoClipAuto.lrdevplugin
chmod +x NoClipAuto.lrdevplugin/bin/macos-arm64/noclip-analyze
```

## Binary layout

```
bin/macos-arm64/noclip-analyze
bin/macos-x64/noclip-analyze    # optional Intel
```

## Known caveats

- App Store Lightroom builds may restrict `LrTasks.execute`
- Use Adobe installer version of Lightroom Classic when possible

## Validation

We need community testers. Use the Mac validation issue template on GitHub.

Report: LR version, macOS version, Apple Silicon vs Intel, smoke log output.

## Release label

macOS release assets are tagged **UNVALIDATED-macOS** until community validation.
