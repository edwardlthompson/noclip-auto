# BUILD_PLAN — NoClip Auto

Active tasks only. Completed work archives to [COMPLETED_TASKS.md](COMPLETED_TASKS.md) (TM, audits, BA) and [docs/BUILD_PLAN_COMPLETED.md](docs/BUILD_PLAN_COMPLETED.md) (M0–M9).

**Status:** Sprint **BA** ✅ shipped in **v1.3.8** (template 0.15.0) · optional BA.H2/BA.L1 open · M0–M9 + TM complete · product paused (alpha)

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

## Sprint BA — Bootstrap Align 0.15.0

### Sequential

1. ✅ [AGENT] **BA.0** — Gap analysis in `docs/BOOTSTRAP_ALIGNMENT.md`; open Sprint BA; map target 0.15.0
2. ✅ [AGENT] **BA.1** — Core docs: UPGRADING, INITIALIZATION_PROMPT, HUMAN_BACKLOG, REPO_HYGIENE, FILE_SIZE_GUIDE, Cursor feature docs
3. ✅ [AGENT] **BA.2** — Rules: `local-compute`, `security-triage`, `feature-modules`; `/cleanup` in batch registry
4. ✅ [AGENT] **BA.3** — Cursor FOSS pack: hooks, skills, agents, permissions, stack-selection (`lightroom-rust`), worktrees
5. ✅ [AGENT] **BA.4** — Scripts: template-update, file-encoding, parallel helpers, maintainer gates; expand `validate-bootstrap.ps1`
6. ✅ [AGENT] **BA.5** — `TEMPLATE_INDEX.json`; CI: dependency-review, scorecard, stale, weekly-health (LR+Rust); `.template-version` → 0.15.0
7. ✅ [AUTO] **BA.6** — `validate-bootstrap.ps1 -Quick` + encoding + batch-commands green (2026-07-21)

### Parallel (after BA.2) — `[PARALLEL-OK]`

| ID | Task | Status |
|----|------|--------|
| BA.P1 | PR + YAML issue templates from upstream | ✅ |
| BA.P2 | README “How agents work” + migration notes pointer | ✅ |
| BA.P3 | Soften `validate-template-index` for child_repo profile | ✅ |

### Human & device (after automation)

1. ✅ [HUMAN] **BA.H1** — Approved hooks + Scorecard/stale/weekly-health; skipped automerge + Release Please
2. 🔲 [HUMAN] **BA.H2** — Optional: promote new workflows to required status checks after green runs on `main`
3. 🔲 [LR] **BA.L1** — Optional smoke `m0`/`m2` after hooks land (not required for BA closure)

> **BA** automation complete — archive via `/cleanup` when ready. Remaining rows are optional human/LR.

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
