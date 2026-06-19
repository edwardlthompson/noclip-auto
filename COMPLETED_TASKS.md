# Completed Tasks

> Archive of finished BUILD_PLAN items. Full M0–M9 milestone history lives in [docs/BUILD_PLAN_COMPLETED.md](docs/BUILD_PLAN_COMPLETED.md).

Template migration (Sprint TM) archived 2026-06-18 via `scripts/run-milestone-tm-gate.ps1`.

## Sprint TM — Complete (2026-06-18)

- ✅ [AGENT] **TM.0** — `COMPLETED_TASKS.md`, `docs/BOOTSTRAP_TEMPLATE_MAP.md`, `validate-bootstrap.ps1/.sh`, `watch-agent-gates.ps1/.sh`; gate PASS
- ✅ [AGENT] **TM.1** — `modules/lightroom/MODULE.md`, `modules/rust/MODULE.md`, `examples/golden-path/README.md`; gate PASS
- ✅ [AGENT] **TM.2** — `DECISION_LOG.md`, `docs/adr/0001-core-architecture.md`, `KNOWLEDGE_BASE.md`, `PROMPT_LIBRARY.md`, `docs/START_HERE.md`, `docs/FOR_AGENTS.md`, `docs/FEATURE_MODULES.md`; gate PASS
- ✅ [AGENT] **TM.3** — 9 bootstrap `.cursor/rules/*.mdc` + `docs/CURSOR_MODES.md`; kept `settings-ui-hints.mdc`; gate PASS
- ✅ [AGENT] **TM.4** — dependabot, CODEOWNERS, security.yml, codeql.yml, CI jobs, feature-gate.ps1, check-repo-hygiene.ps1; gate PASS
- ✅ [AGENT] **TM.5** — root `BUILD_PLAN.md`, `AGENT_MEMORY.md`, `AGENTS.md`, `CHANGELOG.md`; stub pointers in `docs/`; gate PASS
- ✅ [AGENT] **TM.6** — `.editorconfig`, `.gitattributes`, `.cursorignore`, `.pre-commit-config.yaml`, `.template-update.json`, `.template-version`, `.env.example`, `CODE_OF_CONDUCT.md`, `THIRD_PARTY_LICENSES.md`; gate PASS
- ✅ [AGENT] **TM.7** — `pre-release-gate.ps1/.sh`; `feature-gate.ps1` full profile (cargo test/clippy, m2, size); gate PASS
- ✅ [AGENT] **TM.8** — README badges/gates/milestones; `KNOWLEDGE_BASE.md` module index; gate PASS
- ✅ [AGENT] **TM.9** — run-milestone-tm-gate.ps1; TM sprint archived; gate PASS 2026-06-18

## Sprint TM backlog (2026-06-18)

- ✅ [AGENT] **TM.P1** — SECURITY_TRIAGE, THREAT_MODEL, PRIVACY, RUNBOOK
- ✅ [AGENT] **TM.P2** — docs/help/BATCH_COMMANDS.md + all 25 .cursor/commands + batch-commands.mdc + docs/BATCH_COMMANDS.md
- ✅ [AGENT] **TM.P3** — check-github-ci.ps1/.sh, setup-github-repo.ps1/.sh
- ✅ [HUMAN] **TM.H3** — ADR-0001 approved
- ✅ [HUMAN] **TM.H1** — setup-github-repo.ps1 (Dependabot + branch protection)
- ✅ [HUMAN] **TM.H2** — Visual README review on GitHub confirmed

## Sprint Audit — Ship readiness (2026-06-18)

- ✅ [HUMAN] **Audit.1** — TM bootstrap pushed to `main`; CI + Security green
- ✅ [AGENT] **Audit.2** — Stale assessment docs refreshed (BUILD_PLAN, START_HERE)
- ✅ [HUMAN] **Audit.3** — README visual review confirmed (TM.H2)

## Sprint Audit 2 — Post-ship hygiene (2026-06-18)

- ✅ [AGENT] **Audit.4** — README + BUILD_PLAN + FEATURE_MODULES status copy refreshed
- ✅ [AGENT] **Audit.5** — CodeQL `CARGO_NET_RETRY` for registry flake mitigation
- ✅ [HUMAN] **Audit.6** — Shipped v1.3.7 (`d76e2b5`); CI + CodeQL green; GitHub Release published
