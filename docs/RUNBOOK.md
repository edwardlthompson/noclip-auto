# Runbook — NoClip Auto

> Operational guide for build, release, rollback, and incident response.

## Health checks (local)

| Check | Command | Expected |
|-------|---------|----------|
| Bootstrap artifacts | `.\scripts\validate-bootstrap.ps1 -Quick` | exit 0 |
| Analyzer contract | `.\scripts\smoke\m2_smoke.ps1` | exit 0 |
| Full stack | `.\scripts\feature-gate.ps1 -Stack lightroom-rust` | exit 0 |
| LR environment | `.\scripts\detect-lr-env.ps1` | LR INSTALLED in `AGENT_MEMORY.md` |

No HTTP `/health` endpoint — desktop plugin + CLI only.

## Logging

- Plugin: `LrLogger` via `Init.lua` — avoid logging full file paths in release builds
- Analyzer: stderr for errors; JSON on stdout
- **Never** log catalog contents, GPS, or faces

## Release procedure

1. [AUTO] `feature-gate.ps1 -Stack lightroom-rust` green locally
2. [AUTO] `pre-release-gate.ps1` green
3. [HUMAN] Merge to `main`; `check-github-ci.ps1 -WaitSeconds 300`
4. [HUMAN] `.\scripts\publish-release.ps1 -Version <x.y.z>`
5. [HUMAN] Optional macOS: `publish-macos-release.ps1`

See [SECURITY_TRIAGE.md](SECURITY_TRIAGE.md) for security preconditions.

## Rollback

1. Revert git tag / reinstall previous release zip from GitHub Releases
2. User: Plug-in Manager → remove plugin → reinstall prior `NoClipAuto.lrdevplugin`
3. Develop snapshots (`NoClip Auto (before)`) allow per-photo rollback
4. Log user-impacting incidents in `DECISION_LOG.md`

## Common failures

| Symptom | Check | Fix |
|---------|-------|-----|
| CI failing on rust | `cargo test` in `noclip-analyze/` | Fix clippy/test errors |
| Size gate fail | `check-bundle-size.ps1` | Rebuild `release-small` profile |
| Analyzer no output (Win) | `Core/ClippingClient.lua` async pattern | See KNOWLEDGE_BASE KB-002 |
| Plugin not in menu | Plug-in Manager Enable | `enable-lr-plugin.ps1` |
| Dependabot alert | [SECURITY_TRIAGE.md](SECURITY_TRIAGE.md) | Merge bump PR |

## Backup and restore

| Target | Procedure |
|--------|-----------|
| User catalog | Adobe Lightroom backup (user responsibility) |
| Repository | `git clone`; releases on GitHub |
| Plugin prefs | `LrPrefs` — reset via Plugin Manager |

## Escalation

1. Check `BUILD_PLAN.md` and `AGENT_MEMORY.md` blockers
2. Security: [SECURITY_TRIAGE.md](SECURITY_TRIAGE.md) + [THREAT_MODEL.md](THREAT_MODEL.md)
3. Maintainers: `.github/CODEOWNERS`

## Secret rotation

If credentials leak:

1. [HUMAN] Revoke tokens in provider console
2. [AGENT] Rotate GitHub secrets; never commit `.env`
3. [AUTO] Re-run CI; confirm green
4. [HUMAN] Log in `DECISION_LOG.md`
