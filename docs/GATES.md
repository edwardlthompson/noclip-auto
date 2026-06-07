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

- [ ] BUILD_PLAN, AGENT_MEMORY, CHANGELOG, GATES, LR_TESTING, AGENTS.md exist
- [ ] Gate GF passes
- [ ] m0_smoke.ps1 exit 0
- [ ] archive-completed-tasks.ps1 runs without error

## G1 — Plugin load

- [ ] verify-lr-plugin.ps1 exit 0
- [ ] m1_smoke.ps1 exit 0

## G2 — Analyzer

- [ ] cargo test pass
- [ ] m2_smoke.ps1 exit 0
- [ ] noclip-analyze.exe on fixtures returns sane clip counts

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
