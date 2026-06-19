# Documentation checks

Docs-only validation (no full feature gate):

```powershell
.\scripts\validate-bootstrap.ps1 -Quick
.\scripts\check-repo-hygiene.ps1
.\scripts\foss-audit.ps1
.\scripts\check-batch-commands.ps1
```

Verify @README.md links resolve (badges, gate table, module links). Fix failures before commit.

Begin now.
