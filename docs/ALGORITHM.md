# Algorithm — NoClip Auto

Tone pipeline driven by clipped-pixel counts and (optionally) histogram balance stats.

## Pipeline order

1. Snapshot **NoClip Auto (before)**
2. **Phase −1 — Lens profile** (opt-in pref, default on): `LensProfileEnable` + `AutoLateralCA` via EXIF match
3. Snapshot **NoClip Auto (lens profile)** (when applied)
4. **Phase 0 — Auto Tone** (always): batch uses Auto* flags + `flattenAutoNow`; Develop uses `LrDevelopController.setAutoTone()`
5. Snapshot **NoClip Auto (auto tone)**
6. Measure → **Phases 1–3** clip prevention (apply settings after each adjustment)
7. **Phase 4 — Balance** (opt-in): median target + parametric stretch when not clipped
8. Dry-run: restore initial tone **and lens** develop settings at end

## Measurement loop

Every adjustment iteration:

1. Export preview JPEG (512–1024 px long edge per PerformanceTier)
2. Run `noclip-analyze` → clip counts + v2 stats (`median_luma`, `p05_luma`, `p95_luma`, …)
3. If both clip percentages below threshold (default 0.05%) → **done** (clip phases)
4. Apply current phase rules → sync develop settings to catalog → repeat

**Clipping definition:** luminance ≤ 2 (shadow), luminance ≥ 253 (highlight).

## Phase −1 — Lens profile (optional)

Enabled via Plugin Manager pref `enableLensProfileCorrection` (default on). Runs before Auto Tone so vignette/distortion do not skew edge clip counts.

Uses Lightroom's built-in EXIF lens profile match (`EnableLensCorrections`, `LensProfileEnable`, `AutoLateralCA`). No matching profile = no effective change; pipeline continues.

## Phase 0 — Auto Tone

Always runs before measurement (after optional lens profile). Not user-disableable.

## Sliders (Process Version 2012)

| Key | Phase |
|-----|-------|
| Exposure2012 | 1 |
| Whites2012, Blacks2012 | 2 |
| Highlights2012, Shadows2012 | 3 |

## Phase 1 — Exposure

| Condition | Action |
|-----------|--------|
| Shadow clipped only | Exposure **+** 0.05 |
| Highlight clipped only | Exposure **−** 0.05 |
| Both clipped | Adjust dominant side (higher pixel count); tie → **+** Exposure |
| Neither clipped | Exit phase |

Stop: both counts zero, no improvement for 2 iterations, or max 15 phase iterations.

## Phase 2 — Whites and Blacks

| Condition | Action | Cap |
|-----------|--------|-----|
| Shadow clipped | Blacks **+** 1 | +25 total |
| Highlight clipped | Whites **−** 1 | −25 total |

Apply both per iteration if needed. Max 25 phase iterations.

## Phase 3 — Highlights and Shadows

| Condition | Action |
|-----------|--------|
| Shadow clipped | Shadows **+** 2 |
| Highlight clipped | Highlights **−** 2 |

Max 20 phase iterations. Global max 60 total iterations per photo.

## Phase 4 — Balance (optional)

Enabled via Plugin Manager pref `enableBalancePhase` (default off). Runs only when clip phases leave the image unclipped.

| Step | Action |
|------|--------|
| Median target | Adjust Exposure toward target median (default 0.45; ETTR mode → 0.55) |
| S-curve stretch | If p95 − p05 < 0.55, widen via ParametricDarks (−) and ParametricLights (+) |
| Verify | Re-measure; rollback iteration if clipping reappears |

## Safety rails

- Clamp sliders to ±100 (Exposure ±5)
- Skip VIDEO and unavailable photos
- Develop snapshot before first apply
- Log every iteration: phase, clip counts, slider deltas

## Why bundled analyzer?

The Lightroom SDK does not expose histogram data, clipping counts, or pixel buffers to Lua. Exporting a preview JPEG and counting clipped pixels externally is the minimum accurate measurement for this iterative pipeline.

See README for install and architecture overview.
