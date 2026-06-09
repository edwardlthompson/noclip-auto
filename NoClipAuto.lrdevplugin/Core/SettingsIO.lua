-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local SettingsIO = {}

local PV2012_KEYS = {
  "Exposure2012",
  "Whites2012",
  "Blacks2012",
  "Highlights2012",
  "Shadows2012",
  "ProcessVersion",
}

local PARAMETRIC_KEYS = {
  "ParametricShadows",
  "ParametricDarks",
  "ParametricLights",
  "ParametricHighlights",
}

function SettingsIO.ensurePV2012(settings)
  settings = settings or {}
  settings.ProcessVersion = "15.4"
  return settings
end

function SettingsIO.readToneSettings(photo)
  local settings = photo:getDevelopSettings() or {}
  return SettingsIO.ensurePV2012(settings)
end

function SettingsIO.getSlider(settings, key)
  return settings[key] or 0
end

function SettingsIO.setSlider(settings, key, value)
  settings[key] = value
  return settings
end

function SettingsIO.applyDelta(settings, key, delta, minVal, maxVal)
  local current = SettingsIO.getSlider(settings, key)
  local nextVal = current + delta
  if minVal then nextVal = math.max(minVal, nextVal) end
  if maxVal then nextVal = math.min(maxVal, nextVal) end
  settings[key] = nextVal
  return settings, nextVal - current
end

function SettingsIO.toneKeys()
  return PV2012_KEYS
end

function SettingsIO.parametricKeys()
  return PARAMETRIC_KEYS
end

function SettingsIO.extractToneSettings(settings)
  local out = SettingsIO.ensurePV2012({})
  for _, key in ipairs(PV2012_KEYS) do
    if settings[key] ~= nil then
      out[key] = settings[key]
    end
  end
  for _, key in ipairs(PARAMETRIC_KEYS) do
    if settings[key] ~= nil then
      out[key] = settings[key]
    end
  end
  return out
end

function SettingsIO.syncToPhoto(catalog, photo, settings, historyName)
  local toneOnly = SettingsIO.extractToneSettings(settings)
  catalog:withWriteAccessDo(historyName or "NoClip Auto", function()
    photo:applyDevelopSettings(toneOnly, historyName)
  end, { timeout = 30 })
end

return SettingsIO
