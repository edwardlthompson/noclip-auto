# Gate autofix (feature scope)

Autonomous feature step with auto-fix:

```powershell
.\scripts\watch-agent-gates.ps1 -Once -Autofix -Step scaffold
```

If exit 1: read gate output; fix lint/tests in active feature scope; re-run.
On repeated failure (3-strike), halt and switch to Debug Mode or escalate to [HUMAN].
Push to remote still requires `/push`, `/ship`, or explicit user approval.

Begin now.
