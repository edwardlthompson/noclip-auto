# Batch Commands — Agent Registry

> Technical catalog for agents and maintainers. **Humans:** start with [docs/help/BATCH_COMMANDS.md](help/BATCH_COMMANDS.md).

26 slash commands: **21 atomic** workflows + **5 super** orchestrators. Bare-word triggers: `.cursor/rules/batch-commands.mdc`.

**Stack:** `lightroom-rust` only.

## Super commands

| Command | Chain | Cursor mode | Push? |
|---------|-------|-------------|-------|
| `/bootstrap` | init → prune → setup → gates | Agent | No |
| `/verify` | docs → gates → ci | Agent | No |
| `/build` | plan → approval → feature → gates → cleanup | Plan then Agent | No |
| `/ship` | prerelease → push → regress | Agent | **Yes** |
| `/maintain` | triage → dependabot → audit | Agent | No |

## Atomic commands

| Command | Workflow | Super parent |
|---------|----------|--------------|
| `/audit` | Full repo review → BUILD_PLAN → execute → cleanup | maintain |
| `/debug` | Defect investigation (LR smokes, KB) | — |
| `/gates` | Local validation suite | bootstrap, verify, build |
| `/triage` | Weekly security pass | maintain |
| `/dependabot` | Triage/merge Dependabot (cargo, actions) | maintain |
| `/push` | Release commit → push → publish | ship |
| `/prerelease` | `pre-release-gate.ps1` | ship |
| `/regress` | Post-release M9 + CI check | ship |
| `/feature` | Vertical slice + gate loop | build |
| `/fix` | `watch-agent-gates -Autofix` in feature scope | build |
| `/cleanup` | Archive finished BUILD_PLAN rows → COMPLETED_TASKS | build |
| `/init` | Child repo bootstrap verify | bootstrap |
| `/prune` | lightroom+rust stack verification | bootstrap |
| `/ci` | Post-push CI poll only | verify |
| `/docs` | Doc + registry checks | verify |
| `/upgrade` | Template upgrade drift check | maintain |
| `/setup` | GitHub repo settings | bootstrap |
| `/plan` | Feature/ADR plan + Critique | build |
| `/restore` | Restore from `.cursor-session-state.json` | — |
| `/compact` | Save session state before clearing chat | — |
| `/scope` | Parallel scope map before dispatch | — |

## Decision tree

```
New clone / re-align?  → /bootstrap
Changed code?          → /verify (or /docs if docs-only)
New feature?           → /build  (or /fix if gates fail)
Ready to publish?      → /ship   (or /prerelease then /push)
Weekly maintenance?    → /maintain (heavy) or /triage + /verify (light)
Bug with evidence?     → /debug  (not /audit)
Long chat session?     → /compact before clear · /restore after
Parallel agents?       → /scope first
```

## `/verify` vs `/gates` vs `/push` vs `/ship`

| Command | Scope |
|---------|-------|
| `/gates` | Local scripts only — no CI poll |
| `/verify` | docs + gates + CI (pre-merge) |
| `/push` | Full release workflow with explicit push approval |
| `/ship` | prerelease + push + regress (preferred publish path) |

## File layout

| Path | Role |
|------|------|
| `.cursor/commands/*.md` | Slash command bodies (loaded on `/name`) |
| `.cursor/rules/batch-commands.mdc` | Bare-word → same files |
| `docs/help/BATCH_COMMANDS.md` | Human cheat sheet |
| `CODE_REVIEW.md.example` | Audit output template |
| `RELEASE_NOTES.md.example` | Release draft template |
| `scripts/check-batch-commands.ps1` | Registry ↔ filesystem sync |

Validation: `.\scripts\check-batch-commands.ps1` (also via `validate-bootstrap.ps1 -Quick`).
