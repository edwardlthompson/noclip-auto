# Security Triage — NoClip Auto

Weekly CVE triage for Dependabot alerts and release security gates.

## Setup (one-time, [HUMAN])

1. GitHub → **Settings** → **Code security and analysis**
2. Enable **Dependabot alerts** and **Dependabot security updates**
3. Enable **Private vulnerability reporting**
4. Confirm `.github/dependabot.yml` covers `github-actions` and `cargo`

**Automated setup (recommended):**

```powershell
.\scripts\setup-github-repo.ps1
# Linux/macOS/Git Bash:
./scripts/setup-github-repo.sh
```

Requires `gh` CLI authenticated with admin access. On API `422` (plan or permission limits), the script prints a manual UI checklist.

5. Branch protection on `main` requiring: **CI**, **Security Scan**, **CodeQL**, **Repo Hygiene**, **Feature Gate**

Override check names with `GITHUB_REQUIRED_CHECKS` if workflow job names differ.

## Weekly triage pass

Recommended cadence: **Monday** (after Dependabot weekend scans).

| Step | Owner | Action |
|------|-------|--------|
| 1 | HUMAN | Open **Security → Dependabot alerts**; sort Critical/High first |
| 2 | HUMAN | Review open Dependabot version-update PRs (`cargo`, `github-actions`) |
| 3 | AGENT | Apply bumps; run `feature-gate.ps1 -Stack lightroom-rust -Ci` locally |
| 4 | AUTO | CI (rust-test, Trivy, CodeQL) validates merges |
| 5 | HUMAN | Merge PR or defer with linked issue |
| 6 | AUTO | After push: `check-github-ci.ps1 -WaitSeconds 300` |

## Triage decisions

| Decision | When | Action |
|----------|------|--------|
| **Fix** | Patch available, low risk | Merge Dependabot PR or agent applies bump |
| **Defer** | No fix yet, acceptable window | Open issue with expiry; log in `DECISION_LOG.md` |
| **Dismiss** | False positive / not applicable | Document rationale in issue or ADR |

Confirm **Security Scan** and **CodeQL** workflows are green on `main` after triage.

## Release gate (before tag)

Before `publish-release.ps1`:

- Weekly triage within last **7 days**
- Zero open **Critical/High** Dependabot alerts (or documented exception with [HUMAN] approval)
- `pre-release-gate.ps1` exit 0
- CI green on `main` (`check-github-ci.ps1 -WaitSeconds 300`)

If a Critical/High alert has no upstream fix, release may proceed only when:

1. A linked issue documents advisory, impact, and mitigation
2. [HUMAN] approves in release notes or `DECISION_LOG.md`

## NoClip scope notes

- **In scope:** `noclip-analyze` (Rust/Cargo), GitHub Actions pins, bundled analyzer binary supply chain
- **Out of scope:** Adobe Lightroom Classic, user catalog data (local only — see [PRIVACY.md](PRIVACY.md))
- **No network in plugin/analyzer v1** — runtime attack surface is local file paths and LR SDK boundaries

## Related files

| File | Purpose |
|------|---------|
| `.github/dependabot.yml` | Weekly grouped version-update PRs |
| `.github/workflows/security.yml` | Trivy filesystem scan |
| `.github/workflows/codeql.yml` | CodeQL (Rust: `noclip-analyze/`) |
| `scripts/setup-github-repo.ps1` | Dependabot + reporting + branch protection |
| `scripts/check-github-ci.ps1` | Post-push workflow poll |
| `scripts/pre-release-gate.ps1` | Pre-tag local gate |
| `SECURITY.md` | Vulnerability reporting |
| `docs/THREAT_MODEL.md` | STRIDE summary |
