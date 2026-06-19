# Agent Router — NoClip Auto

1. **First read:** `docs/START_HERE.md`
2. **Cursor modes:** `docs/CURSOR_MODES.md`
3. **Task board:** `BUILD_PLAN.md` (Sequential before Parallel)
4. **Operating guide:** `docs/FOR_AGENTS.md`
5. **Living memory:** update `AGENT_MEMORY.md` only at milestone/sprint boundaries

## Autopilot loop

1. Read `BUILD_PLAN.md` — find current Sequential task
2. Complete pending `[AGENT]` tasks
3. Run `scripts/watch-agent-gates.ps1 -Once -Step <label>`
4. On sprint/milestone pass: `scripts/archive-completed-tasks.ps1`, update `CHANGELOG.md` + `AGENT_MEMORY.md`
5. Append major decisions to `DECISION_LOG.md`

## Stop conditions

- Sprint TM gate exit 0 → TM sprint complete; open tasks live in `BUILD_PLAN.md` Open section
- H2 (LR not installed) + `[LR]` task → finish non-LR work, stop
- H1 (gh not authed) + release task → finish local work, stop
- 3-strike on same gate step → escalate to `[HUMAN]`

## Key paths

| Path | Role |
|------|------|
| `NoClipAuto.lrdevplugin/` | Shipped Lightroom plugin |
| `noclip-analyze/` | Rust analyzer |
| `BUILD_PLAN.md` | Active tasks |
| `docs/ALGORITHM.md` | Pipeline reference |
| `examples/golden-path/README.md` | Golden Path index |

## Build commands

```powershell
.\scripts\build-analyzer.ps1
.\scripts\install-plugin.ps1
.\scripts\validate-bootstrap.ps1 -Quick
.\scripts\smoke\m0_smoke.ps1
.\scripts\smoke\m2_smoke.ps1
```
