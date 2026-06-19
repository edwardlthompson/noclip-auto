# For Agents

> Operating guide for Cursor agents on the NoClip Auto codebase.

## Phased loading

```
SessionStart → docs/START_HERE.md → BUILD_PLAN.md (Sequential)
    → modules/lightroom/MODULE.md + modules/rust/MODULE.md
    → examples/golden-path/README.md
    → docs/ALGORITHM.md (if pipeline work)
    → KNOWLEDGE_BASE.md (if debugging)
```

## Architecture constraints

- **Hexagonal layout** per [docs/adr/0001-core-architecture.md](adr/0001-core-architecture.md)
- **Production paths locked:** `NoClipAuto.lrdevplugin/`, `noclip-analyze/` — see [BOOTSTRAP_TEMPLATE_MAP.md](BOOTSTRAP_TEMPLATE_MAP.md)
- **Lua:** entry files ≤50 lines; `Core/*` ≤200 lines; SDK `Lr*` only
- **Rust:** `cargo clippy -D warnings`, `release-small` for shipped binaries
- **No network** in plugin or analyzer

## Token economy

1. Read active modules only — not absent `examples/web` stacks
2. Never fill `KNOWLEDGE_BASE.md` with generic docs
3. Update `AGENT_MEMORY.md` at milestone boundaries only
4. Read-before-write: inspect file via `@path` before editing
5. Sequential before Parallel in `BUILD_PLAN.md`
6. Respect `.cursorignore` when present (TM.6)
7. Agent shortcuts: [docs/help/BATCH_COMMANDS.md](help/BATCH_COMMANDS.md) — `/verify`, `/gates`, `/ship`, `/maintain` (25 commands)

## BUILD_PLAN protocol

1. Find first incomplete `[AGENT]` row in **Sequential** lane
2. Complete the task
3. Run `.\scripts\watch-agent-gates.ps1 -Once -Step <label>`
4. On pass: continue; at sprint end update `AGENT_MEMORY.md` + `DECISION_LOG.md`
5. Parallel lane tasks only after doc/schema lock (TM.2+)

## Parallel guardrails

- One agent per isolated path (see Sprint TM Parallel table in BUILD_PLAN)
- **Never parallelize:** `Core/Pipeline/`, `noclip-analyze/src/`, `scripts/run-milestone-gate.ps1`
- Shared schema (Prefs keys, JSON analyzer contract): sequential only

## 3-strike rule

After 3 failed fix attempts on the same step: halt, summarize, request `[HUMAN]` direction. Include:

- Failing command + exit code
- Files touched
- KB entries checked

## Lightroom tasks `[LR]`

```powershell
.\scripts\ensure-lr-running.ps1
.\scripts\install-plugin.ps1
.\scripts\smoke\m1_smoke.ps1   # example
```

If LR not installed (H2): finish non-LR work and stop LR-dependent tasks.

## Gate commands

| Script | When |
|--------|------|
| `validate-bootstrap.ps1 -Quick` | After doc/scaffold changes |
| `watch-agent-gates.ps1 -Once -Step tmN` | After each TM `[AGENT]` step |
| `run-milestone-gate.ps1 -Milestone N` | M0–M9 regression |
| `foss-audit.ps1` | License / SDK file check |
| `check-lua-size.ps1 -ShippedOnly` | After Lua edits |
| `bench-analyzer.ps1` | After Rust perf-sensitive changes |

## Failure playbook

1. Check [KNOWLEDGE_BASE.md](../KNOWLEDGE_BASE.md) for symptom match
2. Re-run the smallest failing smoke (e.g. `m2_smoke.ps1` before `m9_lr_smoke.ps1`)
3. For LR failures: `scripts/diag-lr-plugin.ps1`
4. Do not mark BUILD_PLAN items complete while gates fail
5. Append non-obvious resolutions to KNOWLEDGE_BASE + DECISION_LOG

## Memory files

| File | Update when |
|------|-------------|
| `AGENT_MEMORY.md` | Milestone / sprint boundary |
| `DECISION_LOG.md` | Major architectural decision |
| `CHANGELOG.md` | User-visible change |
| `KNOWLEDGE_BASE.md` | Non-obvious bug resolved |

## Related docs

- [docs/FEATURE_MODULES.md](FEATURE_MODULES.md) — vertical slice pattern for new features
- [PROMPT_LIBRARY.md](../PROMPT_LIBRARY.md) — copy-paste prompts
- [AGENTS.md](../AGENTS.md) — agent router
