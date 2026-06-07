# GitHub — NoClip Auto

## Repository setup

```powershell
# After H1 (gh auth) if needed
.\scripts\init-github-repo.ps1 -Owner YOUR_GH_USER -Name noclip-auto
```

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
