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

local LENS_KEYS = {
  "EnableLensCorrections",
  "LensProfileEnable",
  "AutoLateralCA",
  "LensProfileName",
  "LensProfileFilename",
  "LensProfileSetup",
  "LensManualDistortionAmount",
  "LensManualVignettingAmount",
  "LensProfileDistortionScale",
  "LensProfileVignettingScale",
}

local SLIDER_SUMMARY_KEYS = {
  "Exposure2012",
  "Whites2012",
  "Blacks2012",
  "Highlights2012",
  "Shadows2012",
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

function SettingsIO.extractLensSettings(settings)
  local out = {}
  settings = settings or {}
  for _, key in ipairs(LENS_KEYS) do
    if settings[key] ~= nil then
      out[key] = settings[key]
    end
  end
  return out
end

function SettingsIO.readLensSettings(photo)
  return SettingsIO.extractLensSettings(photo:getDevelopSettings() or {})
end

function SettingsIO.sliderSummary(before, after)
  local summary = {}
  local anyChange = false
  for _, key in ipairs(SLIDER_SUMMARY_KEYS) do
    local b = SettingsIO.getSlider(before, key)
    local a = SettingsIO.getSlider(after, key)
    summary[key] = { before = b, after = a }
    if math.abs(a - b) > 0.001 then
      anyChange = true
    end
  end
  summary.anyChange = anyChange
  return summary
end

function SettingsIO.applyTone(catalog, photo, settings, historyName, quiet)
  local toneOnly = SettingsIO.extractToneSettings(settings)
  local label = quiet and nil or (historyName or "NoClip Auto")
  catalog:withWriteAccessDo("NoClip Auto", function()
    photo:applyDevelopSettings(toneOnly, label, true)
  end, { timeout = 60 })
end

function SettingsIO.syncLensToPhoto(catalog, photo, settings, historyName)
  local lensOnly = SettingsIO.extractLensSettings(settings)
  local label = historyName or "NoClip Auto"
  catalog:withWriteAccessDo(label, function()
    photo:applyDevelopSettings(lensOnly, label, true)
  end, { timeout = 60 })
end

function SettingsIO.restoreInitial(catalog, photo, toneSettings, lensSettings, historyName)
  local merged = SettingsIO.extractToneSettings(toneSettings)
  for key, value in pairs(SettingsIO.extractLensSettings(lensSettings)) do
    merged[key] = value
  end
  local label = historyName or "NoClip Auto"
  catalog:withWriteAccessDo(label, function()
    photo:applyDevelopSettings(merged, label, true)
  end, { timeout = 60 })
end

function SettingsIO.syncToPhoto(catalog, photo, settings, historyName, quiet)
  SettingsIO.applyTone(catalog, photo, settings, historyName, quiet)
end

return SettingsIO
