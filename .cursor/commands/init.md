# Child repo bootstrap verify

NoClip Auto is a **bootstrapped child repo** (Sprint TM complete). Verify alignment rather than greenfield init.

1. Read @docs/START_HERE.md and @docs/BOOTSTRAP_TEMPLATE_MAP.md.
2. Confirm `.template-version` = `0.11.0` and production paths are locked.
3. Run:

```powershell
.\scripts\validate-bootstrap.ps1 -Quick
.\scripts\check-batch-commands.ps1
```

4. Pick Cursor mode per @docs/CURSOR_MODES.md; read @BUILD_PLAN.md for active work.

Begin now.
