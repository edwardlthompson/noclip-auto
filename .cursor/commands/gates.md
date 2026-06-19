# Local validation gates

Run NoClip **lightroom+rust** gates (Windows PowerShell):

```powershell
.\scripts\validate-bootstrap.ps1 -Quick
.\scripts\feature-gate.ps1 -Stack lightroom-rust -Ci
.\scripts\check-repo-hygiene.ps1
```

For full local profile before release:

```powershell
.\scripts\feature-gate.ps1 -Stack lightroom-rust
```

Report pass/fail per script. Fix failures in scope before marking BUILD_PLAN items complete.

Begin now.
