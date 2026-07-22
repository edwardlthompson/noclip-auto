# BUILD_PLAN — NoClip Auto

Active tasks only. Completed work archives to [COMPLETED_TASKS.md](COMPLETED_TASKS.md) (TM, audits, BA) and [docs/BUILD_PLAN_COMPLETED.md](docs/BUILD_PLAN_COMPLETED.md) (M0–M9).

**Status:** **v1.3.8** released (2026-07-21) · Sprint BA archived · optional BA.H2/BA.L1 open · M0–M9 + TM complete · product paused (alpha)

> **BA** archived in COMPLETED_TASKS.md @ `0f2dcdf`.

**Labels:** `[AGENT]` scriptable · `[LR]` needs Lightroom · `[HUMAN]` human developer · `[AUTO]` CI/scripts · `[PARALLEL-OK]` safe to parallelize

**Agent rule:** Sequential lane first. After each `[AGENT]` step: `scripts/watch-agent-gates.ps1 -Once -Step <label>`. Major decisions → `DECISION_LOG.md`.

**BA.H1 decisions (2026-07-21):** hooks **on** (FOSS) · Scorecard + stale + weekly-health **on** (non-required) · Dependabot automerge **off** · Release Please **off**

---

## Constraints

Production paths are locked — see [docs/BOOTSTRAP_TEMPLATE_MAP.md](docs/BOOTSTRAP_TEMPLATE_MAP.md). Gap analysis: [docs/BOOTSTRAP_ALIGNMENT.md](docs/BOOTSTRAP_ALIGNMENT.md).

| Component | Path |
|-----------|------|
| Lightroom plugin | `NoClipAuto.lrdevplugin/` |
| Rust analyzer | `noclip-analyze/` |
| Tests & fixtures | `tests/` |

**Non-goals:** relocate plugin/analyzer; Release Please; Dependabot automerge; inactive stacks (web/python/android); change Apache-2.0; resume alpha without explicit scope.

**Parallel guardrails:** one agent per path; never parallelize `Core/Pipeline/`, `noclip-analyze/src/`, or `scripts/run-milestone-gate.ps1`.

---

## Gates

| When | Command |
|------|---------|
| Doc/scaffold change | `validate-bootstrap.ps1 -Quick` |
| After AGENT step | `watch-agent-gates.ps1 -Once -Step scaffold` |
| Encoding | `python scripts/check-file-encoding.py .` |
| Rust / pipeline work | `watch-agent-gates.ps1 -Once -Step tests` |
| Pre-release | `pre-release-gate.ps1` |
| M0–M9 regression | `run-milestone-gate.ps1 -Milestone N` |
| TM/bootstrap closure | `run-milestone-tm-gate.ps1` |

Full matrix: [docs/GATES.md](docs/GATES.md) · Agent ops: [docs/FOR_AGENTS.md](docs/FOR_AGENTS.md)

---

## Open

> No open automation rows. Optional BA.H2 / BA.L1 completed 2026-07-21.

---

## Reference

| Topic | Doc |
|-------|-----|
| Agent entry | [docs/START_HERE.md](docs/START_HERE.md) |
| Alignment | [docs/BOOTSTRAP_ALIGNMENT.md](docs/BOOTSTRAP_ALIGNMENT.md) |
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
| BA — Bootstrap Align 0.15.0 | [COMPLETED_TASKS.md](COMPLETED_TASKS.md) |
