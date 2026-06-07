-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local Config = {}

Config.SHADOW_THRESHOLD = 2
Config.HIGHLIGHT_THRESHOLD = 253

Config.EXPOSURE_STEP = 0.05
Config.WHITES_STEP = -1
Config.BLACKS_STEP = 1
Config.HIGHLIGHTS_STEP = -2
Config.SHADOWS_STEP = 2

Config.WHITES_CAP = -25
Config.BLACKS_CAP = 25

Config.MAX_PHASE1_ITER = 15
Config.MAX_PHASE2_ITER = 25
Config.MAX_PHASE3_ITER = 20
Config.MAX_NO_PROGRESS = 2

Config.SLIDER_KEYS = {
  exposure = "Exposure2012",
  whites = "Whites2012",
  blacks = "Blacks2012",
  highlights = "Highlights2012",
  shadows = "Shadows2012",
}

function Config.clipThresholdPct()
  return NoClipAuto.prefs.clipThresholdPct or 0.05
end

function Config.maxTotalIterations()
  return NoClipAuto.prefs.maxTotalIterations or 60
end

function Config.isClipped(clipResult)
  local threshold = Config.clipThresholdPct()
  return clipResult.shadowClipPct > threshold or clipResult.highlightClipPct > threshold
end

function Config.shadowClipped(clipResult)
  return clipResult.shadowClipPct > Config.clipThresholdPct()
end

function Config.highlightClipped(clipResult)
  return clipResult.highlightClipPct > Config.clipThresholdPct()
end

return Config
