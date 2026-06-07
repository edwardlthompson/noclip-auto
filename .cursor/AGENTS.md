# NoClip Auto — Agent Autopilot

Read this file first every session. Run until current milestone gate passes.

## Loop

1. Read `docs/BUILD_PLAN.md` — find current milestone
2. Complete all pending `[AGENT]` tasks (parallelize `<!-- PARALLEL -->` blocks)
3. Run `scripts/run-milestone-gate.ps1 -Milestone N`
4. On pass: `scripts/archive-completed-tasks.ps1`, update CHANGELOG + AGENT_MEMORY
5. Advance to next milestone unless H1–H3 block

## Stop conditions only

- Milestone gate exit 0 → continue to next milestone
- H2 (LR not installed) + LR-required milestone → finish non-LR work, stop
- H1 (gh not authed) + release milestone → finish local work, stop
- M6 complete + publish-release.ps1 exit 0 → stop

## Rules

1. Never ask "should I continue?" mid-milestone
2. Script before human — write automation first
3. Never archive BUILD_PLAN without smoke pass
4. `[HUMAN-ONLY]` = H1 gh auth, H2 LR install, H3 Adobe SDK only
5. All LR verification via ensure-lr-running.ps1 + smoke scripts
6. Lead agent commits once per milestone (user must request push)

## Key paths

- Plugin: `NoClipAuto.lrdevplugin/`
- Analyzer: `noclip-analyze/`
- Active tasks: `docs/BUILD_PLAN.md`
- Algorithm: `docs/ALGORITHM.md`

## Build commands

```powershell
.\scripts\build-analyzer.ps1
.\scripts\install-plugin.ps1
.\scripts\smoke\m0_smoke.ps1
.\scripts\smoke\m2_smoke.ps1
```
