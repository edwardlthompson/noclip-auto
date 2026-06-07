# GitHub — NoClip Auto

## Repository

**URL:** https://github.com/edwardlthompson/noclip-auto

**About (short — GitHub sidebar, ~97 chars):**
```
Auto-fix highlight and shadow clipping in Lightroom Classic. FOSS, local-only, Windows. Apache-2.0.
```

**About (long — README + Plugin Manager):** version, release notes, changelog, GitHub, Venmo. See [GITHUB_ABOUT.md](GITHUB_ABOUT.md).

**Donations:** [Venmo](https://venmo.com/code?user_id=1857304970395648420) (README and Plugin Manager only — not in GitHub About)

## CI

Workflow: `.github/workflows/ci.yml`

Jobs: rust-test, foss-audit, m0-smoke, m2-smoke, build-analyzer, size-gate, build-analyzer-macos-arm64

Badge:

```markdown
![CI](https://github.com/edwardlthompson/noclip-auto/actions/workflows/ci.yml/badge.svg)
```

## Releases

```powershell
.\scripts\package-release.ps1 -Version 1.0.0
.\scripts\publish-release.ps1 -Version 1.0.0
```

| Version | Asset |
|---------|-------|
| v1.0.0 | `NoClipAuto-v1.0.0-win64.lrdevplugin.zip` |
| v1.1.0 | `NoClipAuto-v1.1.0-mac-universal.lrdevplugin.zip` (UNVALIDATED) |

## Issues

Templates in `.github/ISSUE_TEMPLATE/`.
