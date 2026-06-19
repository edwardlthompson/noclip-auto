# Weekly security triage

Follow @docs/SECURITY_TRIAGE.md weekly pass.
Review Dependabot alerts (Critical/High first); triage open PRs (`cargo`, `github-actions`).
Confirm CI, Security Scan, and CodeQL green on main:

```powershell
.\scripts\check-github-ci.ps1 -WaitSeconds 300
```

Begin now.
