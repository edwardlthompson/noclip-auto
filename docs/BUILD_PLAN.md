# BUILD_PLAN — NoClip Auto

Active milestone tasks only. Completed items are archived to [BUILD_PLAN_COMPLETED.md](BUILD_PLAN_COMPLETED.md) via `scripts/archive-completed-tasks.ps1`.

**Current milestone:** M8 complete — next: archive M8 tasks.

**Labels:** `[AGENT]` scriptable · `[LR]` needs Lightroom via automation · `[HUMAN-ONLY]` H1–H3 only · `[PARALLEL-OK]` safe to parallelize

**About metadata policy:** GitHub repo About = **short** (~100 chars, sidebar preview). README `## About` and Plugin Manager About = **long** (version, release notes, changelog, GitHub, Venmo). See [GITHUB_ABOUT.md](GITHUB_ABOUT.md).

---

## M0 — Agent infrastructure, FOSS, GitHub ✅ COMPLETE

Gate G0 passed 2026-06-07. Archived tasks: [BUILD_PLAN_COMPLETED.md](BUILD_PLAN_COMPLETED.md).

---

## M1 — Plugin scaffold ✅ COMPLETE

Gate G1 passed 2026-06-07. Plugin installed to Modules folder; verify-lr-plugin and m1_smoke PASS.

---

## M2 — Clipping analyzer ✅ COMPLETE

Gate G2 passed 2026-06-07. `cargo test`, `test_analyzer.ps1`, `m2_smoke.ps1` PASS; exe 1.5 MB (GS).

---

## M3 — Preview render loop ✅ COMPLETE

Gate G3 passed 2026-06-08. Preview via `requestJpegThumbnail`; Init auto-run + `m3_smoke.ps1` PASS.

---

## M4 — Tone pipeline ✅ COMPLETE

Gate G4 passed 2026-06-08. `verify-tone-quality.ps1` + golden fixtures; phase 2 caps verified.

---

## M5 — Batch + Develop integration ✅ COMPLETE

Gate G5 passed 2026-06-08. BatchRunner overlap + dry-run log; `m5_smoke.ps1` PASS.

---

## M6 — Tune, release v1.0.0 ✅ COMPLETE

Gate G6 passed 2026-06-08. v1.0.0 win64 release published; GS + GP pass.

---

## M7 — Mac release (post v1.0, UNVALIDATED) ✅ COMPLETE

Gate GM passed 2026-06-08 (CI). v1.1.0 macOS arm64 UNVALIDATED release via `release-macos.yml`.

---

## M8 — Smart Tone & Balance ✅ COMPLETE

Gate G8 passed 2026-06-08. v1.2.0 win64 + macOS (UNVALIDATED) via `publish-release-all.ps1`.

- [x] Phase 0 Auto Tone (mandatory) + interim `SettingsIO.syncToPhoto`
- [x] Analyzer v2 (`schema_version: 2`)
- [x] Phase 4 Balance (opt-in pref)
- [x] `m8_smoke.ps1`, `m8_lr_smoke.ps1`, Gate G8 automated
- [x] Tag v1.2.0 release (win64 + macOS)

**Gate G8**

---

## Cross-cutting (perf + modularity) ✅ COMPLETE

Gate GS + GP passed 2026-06-08; CI runs `check-lua-size.ps1 -ShippedOnly` and `bench-analyzer.ps1`.

---

## Reference docs (not active tasks)

- Algorithm: [ALGORITHM.md](ALGORITHM.md)
- LR testing: [LR_TESTING.md](LR_TESTING.md)
- Mac: [MAC.md](MAC.md)
- GitHub metadata (short About): [GITHUB_ABOUT.md](GITHUB_ABOUT.md)
