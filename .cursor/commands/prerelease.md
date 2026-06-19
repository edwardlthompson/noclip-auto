# Pre-release gate

```powershell
.\scripts\pre-release-gate.ps1
```

Confirms full feature-gate, template version, Info.lua ↔ CHANGELOG alignment, and FOSS audit.

Optional after merge to `main`:

```powershell
.\scripts\check-github-ci.ps1 -WaitSeconds 300
```

Do not run `publish-release.ps1` until this gate passes. See @docs/RUNBOOK.md and @docs/SECURITY_TRIAGE.md.

Begin now.
