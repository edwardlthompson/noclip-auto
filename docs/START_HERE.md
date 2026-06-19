# Start Here

> **Read this file first** — whether you are a human or a Cursor agent.

## What is this?

**NoClip Auto** is a FOSS Adobe Lightroom Classic plugin that recovers clipped highlights and shadows using a bundled Rust analyzer (`noclip-analyze`). Active stack: **lightroom + rust**.

**Current work:** Sprint TM complete (bootstrap aligned). Product milestones M0–M9 done (v1.3.7); development paused (alpha).

**Agent shortcuts:** type `/` in chat — see [docs/help/BATCH_COMMANDS.md](help/BATCH_COMMANDS.md) (`/verify`, `/gates`, `/ship`, …).

## Which mode are you in?

- **Ship / maintain:** Read `BUILD_PLAN.md` Sprint Audit → `/verify` or `/ship` after changes
- **Product fix / feature:** Read `docs/FOR_AGENTS.md` + `docs/ALGORITHM.md` — respect hexagonal boundaries in `docs/adr/0001-core-architecture.md`
- **Bootstrap reference:** Read `docs/BOOTSTRAP_TEMPLATE_MAP.md` — do not move production paths

## Agent read order

1. [README.md](../README.md)
2. `docs/START_HERE.md` (this file)
3. [docs/CURSOR_MODES.md](CURSOR_MODES.md) — pick mode before editing
4. [BUILD_PLAN.md](../BUILD_PLAN.md) — Sequential lane first
5. [AGENTS.md](../AGENTS.md) — agent router
6. Active modules only:
   - [modules/lightroom/MODULE.md](../modules/lightroom/MODULE.md)
   - [modules/rust/MODULE.md](../modules/rust/MODULE.md)
7. [examples/golden-path/README.md](../examples/golden-path/README.md)
8. [docs/ALGORITHM.md](ALGORITHM.md) when touching pipeline logic
9. [KNOWLEDGE_BASE.md](../KNOWLEDGE_BASE.md) when debugging non-obvious failures

## Do not read yet

- Inactive bootstrap stacks (`examples/web`, `examples/python`, etc.) — not present in this repo
- [docs/BUILD_PLAN_COMPLETED.md](BUILD_PLAN_COMPLETED.md) — archive unless researching history
- Full [PROMPT_LIBRARY.md](../PROMPT_LIBRARY.md) — use entries on demand

## BUILD_PLAN labels

| Label | Owner |
|-------|-------|
| `[AGENT]` | Cursor Agent — code, docs, scripts, CI |
| `[HUMAN]` | Human — credentials, GitHub settings, approvals |
| `[LR]` | Needs Lightroom installed — use smoke scripts |
| `[AUTO]` | CI / bot scripts |
| `[PARALLEL-OK]` | Safe to parallelize after schema lock |

Filter: `grep '\[AGENT\]' BUILD_PLAN.md`

## Gates (run after each AGENT step)

```powershell
.\scripts\watch-agent-gates.ps1 -Once -Step scaffold   # quick gate
.\scripts\validate-bootstrap.ps1 -Quick
.\scripts\feature-gate.ps1 -Stack lightroom-rust -Ci
.\scripts\smoke\m0_smoke.ps1
.\scripts\smoke\m2_smoke.ps1
```

## Key paths (production — do not relocate)

| Path | Role |
|------|------|
| `NoClipAuto.lrdevplugin/` | Shipped Lightroom plugin |
| `noclip-analyze/` | Rust analyzer source |
| `tests/` | Golden fixtures + bench JPEG |
| `scripts/smoke/` | Milestone smoke tests |

## Security

- No network calls in plugin or analyzer v1
- Report issues via [SECURITY.md](../SECURITY.md)
- Adobe Lightroom SDK is **not** in this repo — download separately for local dev

## Agent prompts

**General session:**

```
Read @docs/START_HERE.md and @BUILD_PLAN.md.
Use /verify before PR; /ship only when publishing.
Preserve NoClipAuto.lrdevplugin/ and noclip-analyze/ paths.
```

**Pipeline work:**

```
Read @docs/ALGORITHM.md and @docs/adr/0001-core-architecture.md.
Do not spawn analyzer outside Core/ClippingClient.lua.
```
