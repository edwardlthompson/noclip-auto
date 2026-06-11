-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local SettingsIO = require("Core.SettingsIO")

local LensProfile = {}

local LENS_FLAGS = {
  EnableLensCorrections = true,
  LensProfileEnable = true,
  AutoLateralCA = true,
}

local function profileEnabled(settings)
  local v = settings and settings.LensProfileEnable
  return v == true or v == 1
end

local function hadMatchedProfile(settings)
  if not profileEnabled(settings) then
    return false
  end
  local name = settings.LensProfileName
  if name and name ~= "" then
    return true
  end
  local file = settings.LensProfileFilename
  if file and file ~= "" then
    return true
  end
  return false
end

function LensProfile.isEnabled()
  if NoClipAuto.prefs.enableLensProfileCorrection == nil then
    return true
  end
  return NoClipAuto.prefs.enableLensProfileCorrection == true
end

function LensProfile.apply(catalog, photo)
  if not LensProfile.isEnabled() then
    return { applied = false, hadProfile = false, skipped = true }
  end

  local before = photo:getDevelopSettings() or {}
  if profileEnabled(before) and hadMatchedProfile(before) then
    return { applied = false, hadProfile = true, skipped = true, reason = "already_enabled" }
  end

  local ok, err = pcall(function()
    catalog:withWriteAccessDo("NoClip Auto Lens Profile", function()
      photo:applyDevelopSettings(LENS_FLAGS, "NoClip Auto Lens Profile", true)
    end, { timeout = 60 })
  end)

  if not ok then
    NoClipAuto.logger:warn("Lens profile apply failed: " .. tostring(err))
    return { applied = false, hadProfile = false, error = tostring(err) }
  end

  local after = photo:getDevelopSettings() or {}
  local applied = profileEnabled(after)
  local hadProfile = hadMatchedProfile(after)

  NoClipAuto.logger:info(string.format(
    "Lens profile photo=%s applied=%s hadProfile=%s name=%s",
    tostring(photo.localIdentifier),
    tostring(applied),
    tostring(hadProfile),
    tostring(after.LensProfileName or "")
  ))

  return { applied = applied, hadProfile = hadProfile }
end

return LensProfile
