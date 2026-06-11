-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local Config = require("Core.Pipeline.Config")
local SettingsIO = require("Core.SettingsIO")

local PhaseWhitesBlacks = {}

function PhaseWhitesBlacks.newState(settings)
  return {
    blacksAccum = 0,
    whitesAccum = 0,
    startBlacks = SettingsIO.getSlider(settings, Config.SLIDER_KEYS.blacks),
    startWhites = SettingsIO.getSlider(settings, Config.SLIDER_KEYS.whites),
  }
end

function PhaseWhitesBlacks.adjust(settings, clipResult, state)
  local deltas = {}
  local changed = false

  if Config.shadowClipped(clipResult) then
    local nextAccum = state.blacksAccum + Config.blacksStep()
    if nextAccum <= Config.BLACKS_CAP then
      settings, deltas[Config.SLIDER_KEYS.blacks] = SettingsIO.applyDelta(
        settings,
        Config.SLIDER_KEYS.blacks,
        Config.blacksStep(),
        -100,
        100
      )
      state.blacksAccum = nextAccum
      changed = true
    end
  end

  if Config.highlightClipped(clipResult) then
    local nextAccum = state.whitesAccum + math.abs(Config.whitesStep())
    if nextAccum <= math.abs(Config.WHITES_CAP) then
      settings, deltas[Config.SLIDER_KEYS.whites] = SettingsIO.applyDelta(
        settings,
        Config.SLIDER_KEYS.whites,
        Config.whitesStep(),
        -100,
        100
      )
      state.whitesAccum = nextAccum
      changed = true
    end
  end

  local done = not Config.isClipped(clipResult) or not changed
  return settings, deltas, done, state
end

return PhaseWhitesBlacks
