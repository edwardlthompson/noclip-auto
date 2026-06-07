# BUILD_PLAN — NoClip Auto

Active milestone tasks only. Completed items are archived to [BUILD_PLAN_COMPLETED.md](BUILD_PLAN_COMPLETED.md) via `scripts/archive-completed-tasks.ps1`.

**Current milestone:** M3 (Preview render loop) — M2 complete.

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

## M3 — Preview render loop


**Gate G3**
- [ ] Preview JPEG created for test photo `[AGENT] [LR]`
- [ ] m3_smoke.ps1 exit 0 `[AGENT] [LR]`

---

## M4 — Tone pipeline

<!-- PARALLEL -->
<!-- END PARALLEL -->

- [ ] [AGENT] verify-tone-quality.ps1 + tests/golden/ thresholds
- [ ] [AGENT] m4_smoke.ps1

**Gate G4**
- [ ] Golden fixtures pass verify-tone-quality.ps1
- [ ] Phase 2 caps enforced (Blacks +25, Whites −25)

---

## M5 — Batch + Develop integration

- [ ] [AGENT] High-tier export/analyze overlap in BatchRunner
- [ ] [AGENT] Batch summary JSON (NoClipAuto-last-run.json) — implemented; verify in LR
- [ ] [AGENT] Develop snapshot before apply — implemented; verify in LR
- [ ] [AGENT] m5_smoke.ps1

**Gate G5**
- [ ] Batch 10 photos completes without Lua errors `[AGENT] [LR]`
- [ ] Dry-run produces log without apply `[AGENT] [LR]`

---

## M6 — Tune, release v1.0.0

- [ ] [AGENT] Tune phase steps and iteration caps on real photos `[AGENT] [LR]`
- [ ] [AGENT] Gate GS + GP pass (check-bundle-size, bench-analyzer)
- [ ] [AGENT] package-release.ps1 + publish-release.ps1
- [ ] [AGENT] Tag v1.0.0 win64 GitHub release
- [ ] [AGENT] Confirm GitHub About still preview-safe after release (re-run `gh repo edit` if description drifted)

**Gate G6**
- [ ] Release zip ≤ 5 MB
- [ ] CHANGELOG v1.0.0 section complete

---

## M7 — Mac release (post v1.0, UNVALIDATED)

<!-- PARALLEL -->
- [ ] [AGENT] [PARALLEL-OK] install-plugin.sh + ensure-lr-running.sh
- [ ] [AGENT] [PARALLEL-OK] CI build-analyzer-macos-arm64
- [ ] [AGENT] [PARALLEL-OK] docs/MAC.md + Gate GM in GATES.md
<!-- END PARALLEL -->

- [ ] [AGENT] Tag v1.1.0 UNVALIDATED-macOS release

---

## Cross-cutting (perf + modularity)

<!-- PARALLEL -->
- [ ] [AGENT] [PARALLEL-OK] check-bundle-size.ps1 + check-lua-size.ps1 in CI
- [ ] [AGENT] [PARALLEL-OK] bench-analyzer.ps1 + GP gate thresholds
<!-- END PARALLEL -->

---

## Reference docs (not active tasks)

- Algorithm: [ALGORITHM.md](ALGORITHM.md)
- LR testing: [LR_TESTING.md](LR_TESTING.md)
- Mac: [MAC.md](MAC.md)
- GitHub metadata (short About): [GITHUB_ABOUT.md](GITHUB_ABOUT.md)
- Full original plan: archived in repo history / Cursor plan file
