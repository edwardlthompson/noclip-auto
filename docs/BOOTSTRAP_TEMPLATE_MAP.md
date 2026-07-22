# Bootstrap Template Map — NoClip Auto

Maps [agent-project-bootstrap](https://github.com/edwardlthompson/agent-project-bootstrap) expectations to this child repo's **lightroom+rust** layout.

**Template version target:** 0.15.0 (aligned from 0.11.0 in Sprint BA)  
**Active stack:** `lightroom` + `rust` (production paths — not `examples/` stubs)  
**Gap analysis:** [BOOTSTRAP_ALIGNMENT.md](BOOTSTRAP_ALIGNMENT.md)

## Root documentation

| Template path | NoClip path | Notes |
|---------------|-------------|-------|
| `BUILD_PLAN.md` | `BUILD_PLAN.md` | Active sprint board |
| `AGENTS.md` | `AGENTS.md` | Agent router |
| `AGENT_MEMORY.md` | `AGENT_MEMORY.md` | Living memory |
| `COMPLETED_TASKS.md` | `COMPLETED_TASKS.md` + `docs/BUILD_PLAN_COMPLETED.md` | Dual archive |
| `DECISION_LOG.md` | `DECISION_LOG.md` | Major trade-offs |
| `CHANGELOG.md` | `CHANGELOG.md` | Keep a Changelog |
| `docs/BUILD_PLAN.md` | Stub pointer | Back-compat |
| `KNOWLEDGE_BASE.md` | `KNOWLEDGE_BASE.md` | Debug KB entries |
| `PROMPT_LIBRARY.md` | `PROMPT_LIBRARY.md` | Agent prompts |
| `docs/START_HERE.md` | `docs/START_HERE.md` | Agent entry |
| `docs/FOR_AGENTS.md` | `docs/FOR_AGENTS.md` | Agent ops guide |
| `docs/FEATURE_MODULES.md` | `docs/FEATURE_MODULES.md` | Vertical slices |
| `docs/adr/0001` | `docs/adr/0001-core-architecture.md` | Hexagonal ADR |

## Production code (Golden Path)

| Template concept | NoClip production path | `examples/` stub |
|------------------|------------------------|------------------|
| Lightroom plugin | `NoClipAuto.lrdevplugin/` | `examples/golden-path/` (docs only) |
| Rust analyzer | `noclip-analyze/` | Documented in `modules/rust/MODULE.md` |
| Tests / fixtures | `tests/` | Golden JSON + bench JPEG |

**Do not** copy production Lua/Rust into `examples/` — install and release paths depend on current layout.

## Modules

| Template module | NoClip `MODULE.md` | Production |
|-----------------|-------------------|------------|
| `modules/lightroom/` | `modules/lightroom/MODULE.md` | `NoClipAuto.lrdevplugin/` |
| `modules/rust/` | `modules/rust/MODULE.md` | `noclip-analyze/` |

## Gates

| Template script | NoClip equivalent | Status |
|---------------|-------------------|--------|
| `validate-bootstrap.sh` | `scripts/validate-bootstrap.ps1` / `.sh` | TM.0 |
| `watch-agent-gates.sh` | `scripts/watch-agent-gates.ps1` / `.sh` | TM.0 |
| `feature-gate.sh` | `scripts/feature-gate.ps1` (TM.4) | Done |
| `pre-release-gate.sh` | `scripts/pre-release-gate.ps1` / `.sh` | TM.7 ✅ |
| `run-milestone-gate.ps1` | Existing M0–M9 gates | Done |
| `run-milestone-tm-gate.ps1` | TM sprint closure gate | TM.9 ✅ |

## CI workflows

| Template workflow | NoClip | Status |
|-------------------|--------|--------|
| `ci.yml` (Feature Gate, Repo Hygiene) | Extended `ci.yml` | TM.4 ✅ |
| `security.yml` | Added | TM.4 ✅ |
| `codeql.yml` | Added (Rust: `noclip-analyze/`) | TM.4 ✅ |
| `dependency-review.yml` | Added | BA.5 ✅ |
| `scorecard.yml` | Added (non-required) | BA.5 ✅ |
| `stale.yml` | Added | BA.5 ✅ |
| `weekly-health-check.yml` | LR+Rust adapted | BA.5 ✅ |
| `release-macos.yml` | Keep project-specific | Done |
| `release-please.yml` | **Skipped** (custom publish) | BA.H1 |

## Cursor rules

| Template rule | NoClip | Status |
|---------------|--------|--------|
| `settings-ui-hints.mdc` | Project-specific | Done |
| `ci-gates.mdc`, `foss-compliance.mdc`, etc. | Bootstrap rules in `.cursor/rules/` | TM.3 + BA.2 ✅ |
| `local-compute.mdc`, `security-triage.mdc`, `feature-modules.mdc` | Added | BA.2 ✅ |

## Repo hygiene (TM.6)

| Template path | NoClip path | Notes |
|---------------|-------------|-------|
| `.editorconfig` | `.editorconfig` | UTF-8, LF; `*.rs` indent 4 |
| `.gitattributes` | `.gitattributes` | `text=auto eol=lf`; binary assets |
| `.cursorignore` | `.cursorignore` | `target/`, plugin binaries |
| `.pre-commit-config.yaml` | `.pre-commit-config.yaml` | pwsh local hooks + gitleaks |
| `.template-update.json` | `.template-update.json` | Upstream sync config |
| `.template-version` | `.template-version` | `0.15.0` |
| `TEMPLATE_INDEX.json` | `TEMPLATE_INDEX.json` | Child-repo slim index (BA) |
| `HUMAN_BACKLOG.md` | `HUMAN_BACKLOG.md` | Deferred human tasks |
| `.cursor/hooks.json` | `.cursor/hooks.json` | FOSS hooks (BA.H1) |
| `.cursor/skills/` | `.cursor/skills/` | FOSS skills pack |
| `.cursor/agents/` | `.cursor/agents/` | explorer / gate-fixer / verifier |
| `.env.example` | `.env.example` | No secrets |
| `CODE_OF_CONDUCT.md` | `CODE_OF_CONDUCT.md` | Contributor Covenant |
| `THIRD_PARTY_LICENSES.md` | `THIRD_PARTY_LICENSES.md` | Rust deps + Adobe SDK note |

## Security and ops (TM.P1)

| Template path | NoClip path | Status |
|---------------|-------------|--------|
| `docs/SECURITY_TRIAGE.md` | `docs/SECURITY_TRIAGE.md` | TM.P1 ✅ |
| `docs/THREAT_MODEL.md` | `docs/THREAT_MODEL.md` | TM.P1 ✅ |
| `docs/PRIVACY.md` | `docs/PRIVACY.md` | TM.P1 ✅ |
| `docs/RUNBOOK.md` | `docs/RUNBOOK.md` | TM.P1 ✅ |
| `docs/help/BATCH_COMMANDS.md` | `docs/help/BATCH_COMMANDS.md` | TM.P2 ✅ |
| `docs/BATCH_COMMANDS.md` | `docs/BATCH_COMMANDS.md` | TM.P2 ✅ |
| `.cursor/commands/*.md` (26, +cleanup) | `.cursor/commands/*.md` | TM.P2 + BA.2 ✅ |
| `.cursor/rules/batch-commands.mdc` | `.cursor/rules/batch-commands.mdc` | TM.P2 ✅ |
| `scripts/check-github-ci.ps1` | `scripts/check-github-ci.ps1` | TM.P3 ✅ |
| `scripts/setup-github-repo.ps1` | `scripts/setup-github-repo.ps1` | TM.P3 ✅ |

## Intentionally omitted (wrong stack)

- `examples/web/`, `examples/python/`, `examples/android/`, `examples/node/`
- `design-tokens/`, GitHub Pages workflow
- F-Droid / Winget packaging stubs
