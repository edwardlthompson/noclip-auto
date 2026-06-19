# Threat Model — NoClip Auto

> Lightoom Classic plugin + local Rust analyzer. Review at milestone boundaries or when data flows change.

## Scope

| Item | Value |
|------|-------|
| Project | NoClip Auto |
| Stack | Adobe Lightroom Classic (Lua SDK) + Rust CLI (`noclip-analyze`) |
| Methodology | STRIDE adapted for local-only desktop plugin |

## Trust boundaries

```text
[User / LR Catalog]
        |
        v
[Lightroom Classic + NoClip Lua plugin]
        |  preview JPEG export (temp file)
        v
[noclip-analyze.exe] -- reads JPEG path, writes JSON to stdout/file
        |
        v
[Develop settings write-back via SDK] (or dry-run log only)
```

**External trust:** Adobe Lightroom Classic process, OS file system, user-supplied catalog paths.

**No trust:** Network endpoints (none in v1), cloud APIs, third-party analytics.

## STRIDE summary

| Threat | Example | Mitigation | Owner |
|--------|---------|------------|-------|
| Spoofing | Malicious binary swapped into `bin/` | Build in CI; size gate; gitignore shipped binaries | AGENT |
| Tampering | Modified preview JPEG misread | JPEG magic-byte validation; unique temp paths | AGENT |
| Repudiation | User denies batch run | `NoClipAuto-last-run.json` batch report (local) | AGENT |
| Information disclosure | Catalog paths in logs | `LrLogger` levels; no PII telemetry | AGENT |
| Denial of service | Huge preview / batch overload | Performance tiers; max iteration caps | AGENT |
| Elevation of privilege | Arbitrary command via analyzer args | Fixed CLI contract; path from plugin only | AGENT |

## Top abuse cases

1. **Path injection** — plugin passes untrusted path to analyzer → validate paths under LR temp/export dirs
2. **Supply-chain compromise** — malicious Rust dependency → Dependabot + CodeQL + `foss-audit.ps1`
3. **Secret leakage** — `.env` or tokens committed → pre-commit gitleaks; `check-repo-hygiene.ps1`
4. **Binary substitution** — replaced `noclip-analyze.exe` in Modules folder → document install-from-Releases only
5. **Develop settings corruption** — aggressive slider loop → phase caps, dry-run mode, develop snapshots

## Security tasks

Link mitigations to `BUILD_PLAN.md` and [SECURITY_TRIAGE.md](SECURITY_TRIAGE.md).

## Review cadence

- [HUMAN] Review at release boundaries
- [AGENT] Update when architecture or analyzer contract changes (append ADR reference)
