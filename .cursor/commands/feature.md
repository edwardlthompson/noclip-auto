# Feature vertical slice step

Execute the active BUILD_PLAN feature row only (one feature per task). See @docs/FEATURE_MODULES.md and @docs/adr/0001-core-architecture.md.

**Stack:** `lightroom-rust`. Do not relocate production paths.

After each AGENT step:

```powershell
.\scripts\watch-agent-gates.ps1 -Once -Step scaffold
```

Use `-Step tests` or `-Step wire` when appropriate. On failure, use `/debug` or escalate.

Begin now.
