# GitHub — NoClip Auto

## Repository

**URL:** https://github.com/edwardlthompson/noclip-auto

**About (description):**
```
FOSS Lightroom Classic plugin that automatically recovers clipped highlights and shadows using a 3-phase tone pipeline. Batch and single-photo workflows. Local-only, no cloud. Windows primary. Apache-2.0.
```

See [GITHUB_ABOUT.md](GITHUB_ABOUT.md) for topics and metadata.

## CI

Workflow: `.github/workflows/ci.yml`

Jobs: rust-test, foss-audit, m0-smoke, m2-smoke, build-analyzer, size-gate

Badge (add to README after repo exists):

```markdown
![CI](https://github.com/OWNER/noclip-auto/actions/workflows/ci.yml/badge.svg)
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

## Agent memory

After repo creation, `init-github-repo.ps1` updates `docs/AGENT_MEMORY.md` with the repo URL.
