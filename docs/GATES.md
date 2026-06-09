# Gates — NoClip Auto

Must-pass checklists before advancing milestones.

## Gate index

| Gate | Milestone | Description |
|------|-----------|-------------|
| G0 | M0 | Repo + FOSS + CI scaffold |
| G1 | M1 | Plugin loads in LR |
| G2 | M2 | Analyzer returns valid JSON |
| G3 | M3 | Preview render loop works |
| G4 | M4 | Tone pipeline golden tests pass |
| G5 | M5 | Batch + Develop integration |
| G6 | M6 | Release v1.0.0 |
| GF | All | FOSS compliance |
| GS | M6 | Size limits (exe ≤ 2 MB, zip ≤ 5 MB, Lua ≤ 200 lines) |
| GP | M6 | Analyzer throughput ≥ 50 MP/s (bench profile) |
| GM | M7 | Mac CI build + UNVALIDATED release |
| G8 | M8 | Smart Tone & Balance (Auto Tone + analyzer v2) |

## G0 — Infrastructure

- [x] BUILD_PLAN, AGENT_MEMORY, CHANGELOG, GATES, LR_TESTING, AGENTS.md exist
- [x] Gate GF passes
- [x] m0_smoke.ps1 exit 0
- [x] run-milestone-gate.ps1 -Milestone 0 exit 0
- [x] GitHub About ≤ 120 chars (97 chars, preview-safe)
- [x] GitHub Actions green on main

**Passed:** 2026-06-07

## G1 — Plugin load

- [x] verify-lr-plugin.ps1 exit 0
- [x] m1_smoke.ps1 exit 0
- [x] Plugin installed to `%APPDATA%\Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin\`

**Passed:** 2026-06-07

## G2 — Analyzer

- [x] cargo test pass
- [x] m2_smoke.ps1 exit 0
- [x] test_analyzer.ps1 exit 0 on black/white/gray fixtures
- [x] noclip-analyze.exe clip metrics sane (100% black/white, 0% gray)
- [x] Gate GS (exe): 1.5 MB ≤ 2 MB

**Passed:** 2026-06-07

## G3 — Preview

- [x] Preview JPEG export works in LR
- [x] m3_smoke.ps1 exit 0

**Passed:** 2026-06-08

## G4 — Pipeline

- [x] verify-tone-quality.ps1 pass on golden fixtures
- [x] Phase 2 caps enforced (Blacks +25, Whites −25)

**Passed:** 2026-06-08

## G5 — Integration

- [x] Batch 10 photos without Lua errors
- [x] Dry-run mode verified (`NoClipAuto-dry-run.log`, no apply)

**Passed:** 2026-06-08

## G6 — Release

- [x] Gate GS + GP pass
- [x] v1.0.0 tag and release zip published (`NoClipAuto-v1.0.0-win64.lrdevplugin.zip`, 0.68 MB)

**Passed:** 2026-06-08

## GF — FOSS

- [ ] LICENSE Apache-2.0 present
- [ ] foss-audit.ps1 pass
- [ ] No Adobe SDK files in repo
- [ ] README states Apache-2.0 and local-only (no network)

## GS — Size

- [x] Shipped exe ≤ 2 MB (1.5 MB)
- [x] Release zip ≤ 5 MB (0.68 MB)
- [x] Largest shipped Lua file ≤ 200 lines (`check-lua-size.ps1 -ShippedOnly`)

## GP — Performance

- [x] Analyzer ≥ 50 MP/s on 1080p JPEG (115.8 MP/s, release-bench)

## GM — Mac build

- [x] CI produces macos-arm64 binary (`build-analyzer-macos-arm64` + artifact)
- [x] Executable bit set in release zip (`package-release-macos.sh` + `chmod +x`)
- [x] Release labeled UNVALIDATED-macOS (prerelease via `release-macos.yml`)

**Passed (CI):** 2026-06-08 — maintainer has not validated on physical Mac hardware.

## G8 — Smart Tone & Balance

- [x] Analyzer v2 JSON (`schema_version: 2`, histogram stats)
- [x] `m8_smoke.ps1` + `run-milestone-gate.ps1 -Milestone 8` pass
- [x] Golden clip regression (verify-tone-quality.ps1)
- [x] Gate GP pass (bench ≥ 50 MP/s)
- [x] Auto Tone + Balance covered by `m8_lr_smoke.ps1` harness `[LR]`
- [x] Tag v1.2.0 release (win64 + macOS arm64 UNVALIDATED)

**Passed:** 2026-06-08

**Last updated:** 2026-06-08
