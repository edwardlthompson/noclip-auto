# Decision Log

> Chronological register of major technical trade-offs, accepted architectures, and rejected alternatives.
> **Treat past entries as immutable history; append only.**

## Format

```markdown
### YYYY-MM-DD — [Title]
- **Status:** Accepted | Rejected | Superseded
- **Context:** ...
- **Decision:** ...
- **Alternatives considered:** ...
- **Consequences:** ...
```

## Entries

### 2026-06-07 — Bundled native analyzer (M2)

- **Status:** Accepted
- **Context:** Adobe Lightroom SDK exposes no pixel-level clipping API from Lua
- **Decision:** Ship `noclip-analyze` inside `NoClipAuto.lrdevplugin/bin/`; plugin exports preview JPEG and parses JSON clip counts
- **Alternatives considered:** Pure Lua histogram approximation (rejected: inaccurate); external install step (rejected: poor UX)
- **Consequences:** Rust build required for development; size gate GS applies to exe; Windows spawn constraints documented in KB-002

### 2026-06-07 — Init.lua cannot use require() (M3)

- **Status:** Accepted
- **Context:** `package` is nil in Lightroom `Init.lua` context
- **Decision:** Use `dofile` for Init bootstraps; `Core/Loader.lua` polyfills `package` + `require` inside async menu tasks
- **Alternatives considered:** Single Init require tree (rejected: runtime failure)
- **Consequences:** Smoke bootstraps (`M5SmokeBootstrap.lua`, etc.) separate from production menu entries

### 2026-06-08 — Three-phase PV2012 pipeline order (M4)

- **Status:** Accepted
- **Context:** Need deterministic clip recovery across batch and Develop
- **Decision:** Exposure → Whites/Blacks (±25 cap) → Highlights/Shadows; clip threshold default 0.05%
- **Alternatives considered:** Single-pass auto tone only (rejected: insufficient for heavy clipping)
- **Consequences:** Golden fixtures in `tests/golden/`; `verify-tone-quality.ps1` regression gate

### 2026-06-08 — Performance tier preview sizing (M5)

- **Status:** Accepted
- **Context:** Batch on large catalogs must not freeze Lightroom UI
- **Decision:** `Core/PerformanceTier.lua` scales preview long edge and batch yield; user override in Plugin Manager
- **Alternatives considered:** Fixed 1024px always (rejected: slow on low-tier machines)
- **Consequences:** Bench gate GP validates analyzer throughput separately from preview size

### 2026-06-08 — macOS CI build UNVALIDATED (M7)

- **Status:** Accepted
- **Context:** No maintainer Mac hardware for full LR validation
- **Decision:** CI builds `aarch64-apple-darwin` binary; releases labeled UNVALIDATED-macOS prerelease
- **Alternatives considered:** Block macOS releases until validated (rejected: community testers needed)
- **Consequences:** See [docs/MAC.md](docs/MAC.md); Mac validation remains `[HUMAN]` / community-driven

### 2026-06-08 — Analyzer schema v2 + Auto Tone pre-pass (M8)

- **Status:** Accepted
- **Context:** Clip-only loop misses global tone balance opportunities
- **Decision:** Analyzer v2 adds histogram stats; Phase 0 Auto Tone always runs; optional Phase 4 Balance
- **Alternatives considered:** Clip loop only forever (rejected: poor results on flat images)
- **Consequences:** `m8_smoke.ps1` / `m8_lr_smoke.ps1` gates; golden clip regression unchanged

### 2026-06-09 — Lens profile pre-pass (M9)

- **Status:** Accepted
- **Context:** Vignette/distortion can inflate edge clip counts before tone phases
- **Decision:** Phase −1 lens profile (default on) before Auto Tone; dry-run restores lens + tone settings
- **Alternatives considered:** User-only lens correction (rejected: inconsistent batch results)
- **Consequences:** `Core/Pipeline/LensProfile.lua`; SettingsIO lens restore on dry-run

### 2026-06-10 — Windows analyzer spawn inside async task (v1.3.7)

- **Status:** Accepted
- **Context:** Bare `LrTasks.execute` from menu async context returned no output on Windows
- **Decision:** Run `noclip-analyze` inside `LrTasks.startAsyncTask`; unique output paths per iteration; stdout-first then file fallback
- **Alternatives considered:** PowerShell-only analyze from Lua (rejected: M3 pattern already proven for smoke)
- **Consequences:** Documented in KB-002; menu title split for File vs Library Active Photo shortcuts

### 2026-06-18 — Production paths preserved during template migration (TM)

- **Status:** Accepted
- **Context:** Align with agent-project-bootstrap without breaking install, releases, or M0–M9 smoke paths
- **Decision:** Keep `NoClipAuto.lrdevplugin/` and `noclip-analyze/` at repo root; `examples/golden-path/` is documentation only; `modules/` documents production layout
- **Alternatives considered:** Move plugin into `examples/lightroom/` per template stub (rejected: breaks `%APPDATA%` install scripts and release zips)
- **Consequences:** Bootstrap `validate-bootstrap` uses lightroom+rust child profile; root doc relocation deferred to TM.5

### 2026-06-18 — Root doc relocation (TM.5)

- **Status:** Accepted
- **Context:** Bootstrap template expects `BUILD_PLAN.md`, `AGENTS.md`, `AGENT_MEMORY.md`, `CHANGELOG.md` at repo root
- **Decision:** Move canonical copies to root; leave stub pointers in `docs/` and `.cursor/AGENTS.md` for back-compat
- **Alternatives considered:** Symlinks (rejected: poor Windows git support); duplicate full copies (rejected: drift risk)
- **Consequences:** Scripts and validate-bootstrap check root paths; grep `docs/BUILD_PLAN` should resolve via stubs only

### 2026-06-18 — Hexagonal architecture for lightroom+rust stack (TM.2)

- **Status:** Accepted (HUMAN TM.H3 sign-off 2026-06-18)
- **Context:** Need documented layer boundaries for agents post-bootstrap
- **Decision:** Hexagonal (ports & adapters): Lua pipeline core ↔ `ClippingClient` port ↔ Rust analyzer adapter; thin menu entries as composition root
- **Alternatives considered:** Monolithic Lua scripts (rejected: already split); full Clean Architecture folders (rejected: overkill for LR plugin size)
- **Consequences:** See [docs/adr/0001-core-architecture.md](docs/adr/0001-core-architecture.md); new features must not bypass `ClippingClient` or `Platform.lua`

### 2026-06-18 — Sprint TM closure (TM.9)

- **Status:** Accepted
- **Context:** Sequential TM.0–TM.8 complete; need single closure gate and archive
- **Decision:** `scripts/run-milestone-tm-gate.ps1` runs validate-bootstrap + full feature-gate + M9 regression, then archives to `COMPLETED_TASKS.md` and `docs/BUILD_PLAN_COMPLETED.md`
- **Alternatives considered:** Reuse `archive-completed-tasks.ps1` only (rejected: TM tasks use table format, not `- [x]` checklist)
- **Consequences:** TM sprint marked complete in BUILD_PLAN; optional TM.P1–P3 / TM.H1–H3 remain non-blocking backlog
