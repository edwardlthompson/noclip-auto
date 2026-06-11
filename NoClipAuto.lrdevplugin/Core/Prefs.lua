-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrPrefs = import "LrPrefs"

local Prefs = {}

-- Safe everyday defaults: Auto Tone + lens profile + clip loop; no dry run, no balance phase.
Prefs.DEFAULTS = {
  clipThresholdPct = 0.05,
  performanceTier = "Fast",
  dryRun = false,
  maxTotalIterations = 40,
  enableLensProfileCorrection = true,
  enableBalancePhase = false,
  balanceTargetMedian = 0.45,
  balanceEttrMode = false,
  useFullSizePreview = false,
  enableDevelopSnapshots = false,
}

function Prefs.store()
  return LrPrefs.prefsForPlugin()
end

function Prefs.ensureDefaults(prefs)
  prefs = prefs or Prefs.store()
  for key, default in pairs(Prefs.DEFAULTS) do
    if prefs[key] == nil then
      prefs[key] = default
    end
  end
  return prefs
end

local function normalize(key, value)
  if value == nil then
    return Prefs.DEFAULTS[key]
  end
  if key == "clipThresholdPct" or key == "balanceTargetMedian" then
    return tonumber(value) or Prefs.DEFAULTS[key]
  end
  if key == "maxTotalIterations" then
    local n = tonumber(value)
    if not n or n < 1 then
      return Prefs.DEFAULTS[key]
    end
    return math.floor(n)
  end
  if key == "dryRun" or key == "enableBalancePhase" or key == "balanceEttrMode"
    or key == "enableLensProfileCorrection" or key == "useFullSizePreview"
    or key == "enableDevelopSnapshots" then
    return value == true
  end
  return value
end

function Prefs.loadToPropertyTable(propertyTable)
  local prefs = Prefs.ensureDefaults()
  for key in pairs(Prefs.DEFAULTS) do
    propertyTable[key] = normalize(key, prefs[key])
  end
end

function Prefs.saveFromPropertyTable(propertyTable)
  local prefs = Prefs.store()
  for key in pairs(Prefs.DEFAULTS) do
    prefs[key] = normalize(key, propertyTable[key])
  end
  Prefs.syncToGlobals()
end

function Prefs.applyDefaultsToPropertyTable(propertyTable)
  for key, default in pairs(Prefs.DEFAULTS) do
    propertyTable[key] = default
  end
end

function Prefs.resetToDefaults()
  local prefs = Prefs.store()
  for key, default in pairs(Prefs.DEFAULTS) do
    prefs[key] = default
  end
  return Prefs.syncToGlobals()
end

function Prefs.syncToGlobals()
  local prefs = Prefs.ensureDefaults()
  if NoClipAuto then
    NoClipAuto.prefs = NoClipAuto.prefs or {}
    for key in pairs(Prefs.DEFAULTS) do
      NoClipAuto.prefs[key] = normalize(key, prefs[key])
    end
  end
  return prefs
end

return Prefs
