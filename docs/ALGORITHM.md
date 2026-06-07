# Algorithm — NoClip Auto

3-phase tone pipeline driven by clipped-pixel counts only (no histogram UI).

## Measurement loop

Every adjustment iteration:

1. Export preview JPEG (512–1024 px long edge per PerformanceTier)
2. Run `noclip-analyze` → `{ shadowClipPx, highlightClipPx, shadowClipPct, highlightClipPct }`
3. If both clip percentages below threshold (default 0.05%) → **done**
4. Apply current phase rules → apply develop settings → repeat

**Clipping definition:** luminance ≤ 2 (shadow), luminance ≥ 253 (highlight).

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

## Safety rails

- Clamp sliders to ±100 (Exposure ±5)
- Skip VIDEO and unavailable photos
- Develop snapshot before first apply
- Log every iteration: phase, clip counts, slider deltas

## Why bundled analyzer?

The Lightroom SDK does not expose histogram data, clipping counts, or pixel buffers to Lua. Exporting a preview JPEG and counting clipped pixels externally is the minimum accurate measurement for this iterative pipeline.

See README for install and architecture overview.
