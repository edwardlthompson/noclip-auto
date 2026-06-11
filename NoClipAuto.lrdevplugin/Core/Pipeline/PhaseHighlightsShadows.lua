-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local Config = require("Core.Pipeline.Config")
local SettingsIO = require("Core.SettingsIO")

local PhaseHighlightsShadows = {}

function PhaseHighlightsShadows.adjust(settings, clipResult)
  local deltas = {}
  local changed = false

  if Config.shadowClipped(clipResult) then
    settings, deltas[Config.SLIDER_KEYS.shadows] = SettingsIO.applyDelta(
      settings,
      Config.SLIDER_KEYS.shadows,
      Config.shadowsStep(),
      -100,
      100
    )
    changed = true
  end

  if Config.highlightClipped(clipResult) then
    settings, deltas[Config.SLIDER_KEYS.highlights] = SettingsIO.applyDelta(
      settings,
      Config.SLIDER_KEYS.highlights,
      Config.highlightsStep(),
      -100,
      100
    )
    changed = true
  end

  local done = not Config.isClipped(clipResult) or not changed
  return settings, deltas, done
end

return PhaseHighlightsShadows
