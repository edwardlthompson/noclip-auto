-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local Config = require("Core.Pipeline.Config")
local SettingsIO = require("Core.SettingsIO")

local PhaseExposure = {}

function PhaseExposure.adjust(settings, clipResult)
  local shadow = Config.shadowClipped(clipResult)
  local highlight = Config.highlightClipped(clipResult)
  local deltas = {}

  if not shadow and not highlight then
    return settings, deltas, true
  end

  local delta = 0
  if shadow and not highlight then
    delta = Config.exposureStep()
  elseif highlight and not shadow then
    delta = -Config.exposureStep()
  else
    if clipResult.shadowClipPx >= clipResult.highlightClipPx then
      delta = Config.exposureStep()
    else
      delta = -Config.exposureStep()
    end
  end

  settings, deltas[Config.SLIDER_KEYS.exposure] = SettingsIO.applyDelta(
    settings,
    Config.SLIDER_KEYS.exposure,
    delta,
    -5,
    5
  )

  return settings, deltas, false
end

return PhaseExposure
