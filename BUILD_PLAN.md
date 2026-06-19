# BUILD_PLAN — NoClip Auto

Active tasks only. Completed work archives to [COMPLETED_TASKS.md](COMPLETED_TASKS.md) (TM, audits) and [docs/BUILD_PLAN_COMPLETED.md](docs/BUILD_PLAN_COMPLETED.md) (M0–M9).

**Status:** Bootstrap aligned @ v0.11.0 · M0–M9 + Sprint TM complete · product paused (v1.3.7 in tree, GitHub Release latest v1.3.0)

**Labels:** `[AGENT]` scriptable · `[LR]` needs Lightroom · `[HUMAN]` human developer · `[AUTO]` CI/scripts · `[PARALLEL-OK]` safe to parallelize

**Agent rule:** Sequential lane first. After each `[AGENT]` step: `scripts/watch-agent-gates.ps1 -Once -Step <label>`. Major decisions → `DECISION_LOG.md`.

---

## Open

| ID | Task | Owner | Gate |
|----|------|-------|------|
| **Audit.6** | ⬜ Commit + push TM.H2 closure + Audit 2 doc/CI fixes | [HUMAN] | CI + CodeQL green |

---

## Constraints

Production paths are locked — see [docs/BOOTSTRAP_TEMPLATE_MAP.md](docs/BOOTSTRAP_TEMPLATE_MAP.md).

| Component | Path |
|-----------|------|
| Lightroom plugin | `NoClipAuto.lrdevplugin/` |
| Rust analyzer | `noclip-analyze/` |
| Tests & fixtures | `tests/` |

**Non-goals:** relocate plugin/analyzer into `examples/`; replace PowerShell gates with bash on Windows; resume alpha reliability work without explicit scope; change Apache-2.0 license; add inactive bootstrap stacks (web/python/android).

**Parallel guardrails:** one agent per path; never parallelize `Core/Pipeline/`, `noclip-analyze/src/`, or `scripts/run-milestone-gate.ps1`.

---

## Gates

| When | Command |
|------|---------|
| Doc/scaffold change | `validate-bootstrap.ps1 -Quick` |
| After AGENT step | `watch-agent-gates.ps1 -Once -Step scaffold` |
| Rust / pipeline work | `watch-agent-gates.ps1 -Once -Step tests` |
| Pre-release | `pre-release-gate.ps1` |
| M0–M9 regression | `run-milestone-gate.ps1 -Milestone N` |
| TM/bootstrap closure | `run-milestone-tm-gate.ps1` |

Full matrix: [docs/GATES.md](docs/GATES.md) · Agent ops: [docs/FOR_AGENTS.md](docs/FOR_AGENTS.md)

---

## Reference

| Topic | Doc |
|-------|-----|
| Agent entry | [docs/START_HERE.md](docs/START_HERE.md) |
| Algorithm | [docs/ALGORITHM.md](docs/ALGORITHM.md) |
| LR testing | [docs/LR_TESTING.md](docs/LR_TESTING.md) |
| Feature slices | [docs/FEATURE_MODULES.md](docs/FEATURE_MODULES.md) |
| Slash commands | [docs/help/BATCH_COMMANDS.md](docs/help/BATCH_COMMANDS.md) |

## Archived sprints

| Sprint | Archive |
|--------|---------|
| M0–M9 — Product milestones | [docs/BUILD_PLAN_COMPLETED.md](docs/BUILD_PLAN_COMPLETED.md) |
| TM — Template migration | [COMPLETED_TASKS.md](COMPLETED_TASKS.md) |
| Audit — Ship readiness + Audit 2 | [COMPLETED_TASKS.md](COMPLETED_TASKS.md) |
