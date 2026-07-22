# Bootstrap Alignment — Gap Analysis

> **Phase 0 deliverable** (2026-07-21). Migration / alignment of NoClip Auto to [agent-project-bootstrap](https://github.com/edwardlthompson/agent-project-bootstrap) **v0.15.0**. Not a fresh bootstrap.
>
> **Status:** Phase 1–2 executing under Sprint BA. **BA.H1:** hooks on · Scorecard/stale/weekly-health on · automerge off · Release Please off.

| Field | Value |
|-------|-------|
| Local template version | `0.11.0` (`.template-version`) |
| Upstream latest | `0.15.0` (2026-07-22) |
| Prior alignment | Sprint TM complete 2026-06-18 → `COMPLETED_TASKS.md` |
| Active stack | **lightroom + rust** (production paths locked) |
| License | **Apache-2.0** (upstream template is MIT — keep Apache) |
| Product state | M0–M9 done (v1.3.7); alpha paused |

## Stack selection (recommended)

| Decision | Rationale |
|----------|-----------|
| Keep `lightroom` + `rust` only | Matches shipped product; `docs/BOOTSTRAP_TEMPLATE_MAP.md` production lock |
| Do **not** add web / python / android / design-tokens / Pages | Wrong stack; intentionally omitted in TM |
| Device label stays `[LR]` (not `[ADB]`) | Lightroom Classic is the device surface; map `[ADB]` docs → `[LR]` mentally |
| Keep custom release scripts | `publish-release.ps1` / `release-macos.yml` — do not replace with Release Please without explicit approval |

---

## What already matches (v0.11.0 baseline)

Core agent surface from Sprint TM is in place and working:

| Area | Present |
|------|---------|
| Router / entry | `AGENTS.md`, `docs/START_HERE.md`, `docs/CURSOR_MODES.md`, `docs/FOR_AGENTS.md` |
| Memory | `AGENT_MEMORY.md`, `DECISION_LOG.md`, `KNOWLEDGE_BASE.md`, `PROMPT_LIBRARY.md` |
| Task board | `BUILD_PLAN.md` (emoji status, Sequential-first rule, archives) |
| Archives | `COMPLETED_TASKS.md`, `docs/BUILD_PLAN_COMPLETED.md` |
| Cursor | 11 `.cursor/rules/*.mdc`, 25 `.cursor/commands/*.md`, batch registry + help |
| Gates | `validate-bootstrap`, `watch-agent-gates`, `feature-gate`, `pre-release-gate`, TM/M0–M9 gates |
| Hygiene | `.editorconfig`, `.gitattributes`, `.cursorignore`, `.pre-commit-config.yaml`, `.env.example` |
| Provenance | `.template-version`, `.template-update.json` |
| Security docs | `SECURITY.md`, `docs/SECURITY_TRIAGE.md`, `THREAT_MODEL.md`, `PRIVACY.md`, `RUNBOOK.md` |
| CI (partial) | `ci.yml`, `security.yml`, `codeql.yml`, `dependabot.yml`, `CODEOWNERS` |
| Modules | `modules/lightroom/`, `modules/rust/` + golden-path docs |
| No `.cursorrules` | Already deprecated / absent |

`BUILD_PLAN.md` currently has **no open automation rows** (product paused). Alignment work should open a new sprint (proposed: **BA** — Bootstrap Align 0.15).

---

## What is missing (0.11.0 → 0.15.0)

Grouped by risk / value for this child repo.

### A — High value, low product risk (adopt)

| Item | Upstream since | Notes |
|------|----------------|-------|
| `docs/UPGRADING_FROM_TEMPLATE.md` | earlier | Cherry-pick guide for child repos |
| `docs/INITIALIZATION_PROMPT.md` | earlier | Adapt to lightroom-rust; do not blind overwrite |
| `HUMAN_BACKLOG.md` | 0.12+ | Parking for failed/blocked human automation |
| `TEMPLATE_INDEX.json` | earlier | Slim / stack-filtered copy; drive validate-bootstrap |
| `scripts/check-template-updates.ps1/.sh` | earlier | Config already in `.template-update.json` |
| `scripts/check-file-encoding.py` (+ sh) | earlier | Windows encoding gate (rules already reference TM.6) |
| `scripts/check-changelog-unreleased.sh` | earlier | Keep a Changelog discipline |
| `scripts/check-license-compliance.sh` | earlier | Adapt for Apache-2.0 allowlist |
| `scripts/check-repo-hygiene.sh` | earlier | Pair with existing `.ps1` |
| `scripts/check-security-triage.ps1/.sh` | later | Wire to SECURITY_TRIAGE |
| `.cursor/rules/local-compute.mdc` | 0.15 | Prefer This Computer / worktrees over Cloud |
| `.cursor/rules/security-triage.mdc` | later | Matches existing triage docs |
| `.cursor/rules/feature-modules.mdc` | later | Align with `docs/FEATURE_MODULES.md` |
| `.cursor/commands/cleanup.md` | 0.12 | Archive BUILD_PLAN rows after `/build` |
| `docs/FILE_SIZE_GUIDE.md` | 0.12 | Taxonomy; reconcile with Lua ≤200 / menu ≤50 |
| `docs/REPO_HYGIENE.md` | earlier | Pair with existing rule |
| PR template + YAML issue templates | earlier | Upgrade from `.md` issue templates |
| `.github/workflows/dependency-review.yml` | earlier | PR-only; low blast radius |
| Session / parallel docs refresh | 0.12 | `PARALLEL_AGENT_SCOPES`, `/scope`, cleanup |

### B — Medium value; adapt carefully

| Item | Risk | Adaptation |
|------|------|------------|
| `.cursor/hooks.json` + `hooks/*.py` | Medium — can deny shell commands | FOSS profile only; tune denylist for PowerShell + LR scripts |
| `.cursor/skills/*` (validate-bootstrap, hygiene, gates, parallel-scope, …) | Low–med | Copy FOSS-relevant skills; skip Android/web-only |
| `.cursor/agents/*` (explorer, gate-fixer, verifier) | Low | Useful; stack-agnostic |
| `.cursor/permissions.json`, `cursor-features.json`, `stack-selection.json` | Low | Set stack=`lightroom-rust` |
| `docs/CURSOR_FEATURE_RADAR.md` + registry JSON | Low | Optional maintainer radar |
| `docs/CURSOR_CLI.md` | Low | Optional |
| Parallel dispatch scripts (`plan-parallel-dispatch`, `check-build-plan-parallel`, `scripts/lib/parallel_scope*.py`) | Med | Keep NoClip parallel guardrails (Pipeline, analyzer, milestone gate) |
| `scripts/lib/run_checks_parallel.py` | Low | Speed up validate-bootstrap |
| `scripts/agent-run.py`, quiet shell hooks | Med | Windows PowerShell path testing required |
| `scorecard.yml` | Med | Needs GitHub token / branch protection awareness |
| `stale.yml`, `weekly-health-check.yml` | Low–med | Noise vs hygiene trade-off |
| Expand `validate-bootstrap.ps1` for new required files | Med | Must stay lightroom-rust profile; not full template index |

### C — High risk or wrong stack (confirm or skip)

| Item | Recommendation | Why |
|------|----------------|-----|
| `release-please.yml` + automerge | **Skip by default** | Conflicts with existing `publish-release.ps1` / versioning / macOS UNVALIDATED flow |
| `dependabot-automerge.yml` + `setup-automerge-token` | **Confirm** | Needs PAT/app token; can merge without review |
| `pages.yml`, `design-tokens/`, web/python/android examples | **Skip** | Wrong stack |
| `.cursor/rules/design-system.mdc` | **Skip** | No web UI design system |
| `.cursor/rules/commercial-compliance.mdc` + commercial hooks/MCP examples | **Skip** | FOSS Apache project |
| Replace `[LR]` with `[ADB]` | **Skip** | Keep `[LR]`; document equivalence in START_HERE |
| Blind overwrite of `docs/INITIALIZATION_PROMPT` / product ADRs | **Forbidden** | Preserve project decisions |
| Change Apache-2.0 → MIT | **Forbidden** | License conflict; note only |
| Mass rewrite of `ci.yml` required checks | **Confirm** | Must not break green main without migration plan |

---

## Conflicts (migrate carefully)

1. **Version drift** — Claimed “bootstrap aligned” at 0.11.0; upstream moved through 0.12 (hooks/skills/parallel `/build`/`/cleanup`), 0.13 (Release Please), 0.14 (quiet agent shell), 0.15 (local-compute / Cursor 3.9–3.11).
2. **License** — Template MIT vs repo Apache-2.0. License compliance script must allow Apache-2.0 + existing third-party Rust deps.
3. **Device label** — Template `[ADB]` vs NoClip `[LR]` + `[PARALLEL-OK]`.
4. **BUILD_PLAN shape** — Template now emphasizes Parallel-first planning + Human & device grouping + `HUMAN_BACKLOG.md`. NoClip board is archive-only with Sequential-first product rule. Align *process* without inventing fake product work.
5. **Release machinery** — Custom LR plugin zips vs Release Please npm-style releases.
6. **CI surface** — NoClip CI is Windows-primary Rust/LR smokes; template CI is multi-stack. Cherry-pick workflows; do not import Android/Python jobs.
7. **Production path lock** — Never move `NoClipAuto.lrdevplugin/` or `noclip-analyze/`.

---

## Risk areas

| Risk | Mitigation |
|------|------------|
| Hook denylist breaks LR smoke / cargo / gh | Start with permissive FOSS hooks; test `watch-agent-gates` + smokes |
| New required CI checks fail main | Add workflows as `continue-on-error` or non-required first; `[HUMAN]` to promote |
| Dependabot automerge | Opt-in only after token setup |
| Encoding checker false positives | Run dry-run; exclude binaries / `bin/` |
| Agent scope creep into product Lua/Rust | Alignment sprint scopes docs/scripts/CI/cursor only |
| Secrets | Never copy `.env`; merge `.env.example` only |

---

## Prioritized alignment plan (Sprint BA)

Proposed sprint id: **BA** (Bootstrap Align → 0.15.0). Labels: `[AGENT]` / `[HUMAN]` / `[LR]` / `[AUTO]` / `[PARALLEL-OK]`. Status markers: 🔲 · ✅ · ❌.

### Sequential

1. 🔲 [AGENT] **BA.0** — Land this gap analysis; open Sprint BA in `BUILD_PLAN.md`; bump planning notes in `docs/BOOTSTRAP_TEMPLATE_MAP.md` (target 0.15.0)
2. 🔲 [AGENT] **BA.1** — Core docs: `UPGRADING_FROM_TEMPLATE.md`, adapted `INITIALIZATION_PROMPT.md`, `HUMAN_BACKLOG.md`, `REPO_HYGIENE.md`, `FILE_SIZE_GUIDE.md` (reconcile with Lua limits); refresh START_HERE / FOR_AGENTS session protocol if drifted
3. 🔲 [AGENT] **BA.2** — Cursor rules: add `local-compute`, `security-triage`, `feature-modules`; refresh `batch-commands` for `/cleanup`; keep `settings-ui-hints`
4. 🔲 [AGENT] **BA.3** — Cursor FOSS pack (skills, agents, hooks, permissions, stack-selection, feature registry) — **hooks behind confirmation**
5. 🔲 [AGENT] **BA.4** — Scripts: template-update checker, file-encoding, changelog-unreleased, license-compliance (Apache), security-triage check, parallel helpers as needed; expand `validate-bootstrap.ps1` lightly
6. 🔲 [AGENT] **BA.5** — `TEMPLATE_INDEX.json` (stack-filtered) + map update; `.template-version` → `0.15.0` only after gates pass
7. 🔲 [AUTO] **BA.6** — `validate-bootstrap.ps1` + `check-batch-commands.ps1` + encoding check green

### Parallel (after BA.2 schema/docs lock) — `[PARALLEL-OK]`

| Agent | Scope |
|-------|-------|
| P1 | `.github/workflows/dependency-review.yml` + PR/issue template refresh |
| P2 | Optional: `scorecard.yml`, `stale.yml`, `weekly-health-check.yml` (non-required) |
| P3 | README “How agents work” short section + migration notes pointer |

### Human & device (after automation)

1. 🔲 [HUMAN] **BA.H1** — Approve high-risk opts (hooks on/off; automerge; scorecard; Release Please skip)
2. 🔲 [HUMAN] **BA.H2** — Branch protection / required checks if new workflows added
3. 🔲 [LR] **BA.L1** — Optional: smoke `m0`/`m2` after hook adoption (only if hooks land)

### Explicit non-goals (this sprint)

- Product reliability / alpha resume
- Relocating plugin or analyzer
- Importing web/python/android examples or design-tokens
- Switching license to MIT
- Replacing custom release with Release Please (unless BA.H1 says yes)

---

## Migration notes (for human)

**Already done (TM @ 0.11.0):** agent router, BUILD_PLAN labels, gates, security docs, batch commands, modules, CI security/CodeQL, hygiene files.

**This pass upgrades process/tooling to ~0.15.0** without touching clipping algorithm or plugin business logic.

**You must decide before Agent executes BA.3–BA.5 CI expansions:**

1. Enable Cursor **hooks** (shell guard / encoding / session context)? Default proposal: **yes, FOSS-tuned**.
2. Add **OpenSSF Scorecard** + **stale** + **weekly-health**? Default proposal: **scorecard yes (non-required), stale/weekly optional**.
3. Enable **Dependabot automerge**? Default proposal: **no** (manual `/dependabot`).
4. Adopt **Release Please**? Default proposal: **no**.

---

## Critique

- **Scope:** Alignment is large if “copy everything.” Narrowing to FOSS lightroom-rust profile keeps risk bounded; full TEMPLATE_INDEX parity is unnecessary.
- **Hooks:** Highest local DX risk — must validate against PowerShell gate scripts before requiring them in CI.
- **Version bump:** Do not set `.template-version` to 0.15.0 until BA.6 gates pass; otherwise update checker lies.
- **BUILD_PLAN:** Empty active board is honest for paused product; Sprint BA should be the only new open work unless human reopens alpha.
- **Parallel:** Template’s parallel-first `/build` is useful; NoClip must retain path mutexes (`Core/Pipeline/`, `noclip-analyze/src/`, milestone gate).

---

## Execution result (2026-07-21)

BA.H1 confirmed: **(1) hooks on**, **(2) Scorecard + stale + weekly-health on**. Automations BA.0–BA.6 complete; `.template-version` = **0.15.0**.

### Still needs human attention

| Item | Action |
|------|--------|
| BA.H2 | ✅ Required: Scorecard analysis + Dependency Review (Weekly Health schedule-only, verified after cargo-audit fix) |
| BA.L1 | ✅ `m0_smoke` + `m2_smoke` PASS |
| Push | ✅ v1.3.8 shipped; follow-up chore for BA.H2/BA.L1 |

### Intentionally not adopted

Release Please · Dependabot automerge · web/python/android examples · design-tokens · commercial Cursor pack · MIT license swap
