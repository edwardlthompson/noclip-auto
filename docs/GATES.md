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
| GM | M7 | Mac CI build (no owner validation) |

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

- [ ] Preview JPEG export works in LR
- [ ] m3_smoke.ps1 exit 0

## G4 — Pipeline

- [ ] verify-tone-quality.ps1 pass on golden fixtures
- [ ] Phase 2 caps enforced

## G5 — Integration

- [ ] Batch 10 photos without Lua errors
- [ ] Dry-run mode verified

## G6 — Release

- [ ] Gate GS + GP pass
- [ ] v1.0.0 tag and release zip published

## GF — FOSS

- [ ] LICENSE Apache-2.0 present
- [ ] foss-audit.ps1 pass
- [ ] No Adobe SDK files in repo
- [ ] README states Apache-2.0 and local-only (no network)

## GS — Size

- [ ] Shipped exe ≤ 2 MB (`check-bundle-size.ps1`)
- [ ] Release zip ≤ 5 MB
- [ ] Largest Lua file ≤ 200 lines (`check-lua-size.ps1`)

## GP — Performance

- [ ] Analyzer ≥ 50 MP/s on 1080p JPEG (release-bench)

## GM — Mac build

- [ ] CI produces macos-arm64 binary
- [ ] Executable bit set in release zip
- [ ] Release labeled UNVALIDATED-macOS

**Last updated:** 2026-06-07
