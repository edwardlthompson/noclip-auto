# Agent shortcuts (cheat sheet)

Shortcut commands for Cursor Agent — type **`/`** in Agent chat to pick a recipe.

## 30-second start

1. Open **Agent** chat in Cursor.
2. Type **`/`** to open the command menu.
3. Pick a command (e.g. `/verify`, `/gates`, `/ship`).
4. The agent runs the workflow step by step.

Bookmark this page when you come back after a break.

## Try these first (super commands)

| Command | When to use |
|---------|-------------|
| `/bootstrap` | Re-verify child-repo bootstrap alignment |
| `/verify` | After your changes, before opening a pull request |
| `/build` | Start a new feature (plans first, then implements) |
| `/ship` | Publish a release to GitHub (checks, push, regression) |
| `/maintain` | Weekly health pass — security, dependencies, full review |

**Worked example — pre-merge:** make changes → `/verify` → fix failures → open PR.

## When you need one step

Grouped by life moment (use `/` menu for the full list).

**Getting started:** `/init` · `/prune` · `/setup` · `/gates`

**Building:** `/plan` · `/feature` · `/fix` (gates failed after `/build`) · `/cleanup` (archive done rows) · `/scope` (parallel agents)

**Docs & checks:** `/docs` · `/ci` (CI poll only) · `/gates` (full local validation)

**Publishing:** `/prerelease` (checks before publish) · `/push` (commit + push + release) · `/regress` (after release)

**Maintenance:** `/triage` · `/dependabot` · `/audit` (full repo review)

**Debugging:** `/debug` (defect with repro evidence — not `/audit`)

**Long sessions:** `/compact` (save checkpoint before clearing chat) · `/restore` (load checkpoint)

## Before you publish

`/push` and `/ship` **push code to GitHub**. Only run them when you intend to publish. `/ship` is the full path (pre-release checks → push → post-release verification). Use `/prerelease` alone if you want checks without pushing yet.

## NoClip gate commands (PowerShell)

```powershell
.\scripts\validate-bootstrap.ps1 -Quick
.\scripts\feature-gate.ps1 -Stack lightroom-rust -Ci
.\scripts\feature-gate.ps1 -Stack lightroom-rust
.\scripts\pre-release-gate.ps1
.\scripts\publish-release.ps1 -Version 1.3.8
```

## Coming back after a break?

Type **`/`** in Agent chat. Supers like `/verify` or `/maintain` are a good refresher.

## Bare words (optional)

You can type a single word like `audit` instead of `/audit`. Slash commands are more reliable.

---

Advanced registry (maintainers): [docs/BATCH_COMMANDS.md](../BATCH_COMMANDS.md)
