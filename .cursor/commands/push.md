# Release: commit, push, and publish

Framework: AGENT/HUMAN/LR/AUTO; semver aligned with `Info.lua` VERSION and `CHANGELOG.md`.
**User invoked `/push` — explicit approval for `git push origin main`.**

## Step 1 — Pre-release validation

```powershell
.\scripts\validate-bootstrap.ps1 -Quick
.\scripts\feature-gate.ps1 -Stack lightroom-rust
.\scripts\pre-release-gate.ps1
```

Update @CHANGELOG.md `[Unreleased]` section.

## Step 2 — Release notes

Create/update `RELEASE_NOTES.md` from CHANGELOG and BUILD_PLAN rows (use @RELEASE_NOTES.md.example). Do not commit `RELEASE_NOTES.md`.

## Step 3 — Commit and push

- Stage **explicit paths only** (never `git add .`)
- Commit: `chore(release): prepare vX.Y.Z release` with key changes in body
- `git push origin main`
- `.\scripts\check-github-ci.ps1 -WaitSeconds 600`
- Zero open Critical/High Dependabot alerts (or documented exception)

## Step 4 — Release

```powershell
.\scripts\publish-release.ps1 -Version X.Y.Z
```

Update @AGENT_MEMORY.md and @DECISION_LOG.md at milestone boundary.

## Step 5 — Cleanup

Mark BUILD_PLAN ✅; archive sprint to @COMPLETED_TASKS.md if applicable.

Do not force-push, amend published tags, or disable hooks. Halt and escalate [HUMAN] on failure.

Start executing now.
