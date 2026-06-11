-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrDevelopController = import "LrDevelopController"

local SettingsIO = require("Core.SettingsIO")

local AutoTone = {}

local AUTO_FLAGS = {
  AutoExposure = true,
  AutoContrast = true,
  AutoShadows = true,
  AutoHighlight = true,
  AutoWhites = true,
  AutoBlacks = true,
}

local function toneChanged(before, after)
  for _, key in ipairs(SettingsIO.toneKeys()) do
    if key ~= "ProcessVersion" then
      local b = SettingsIO.getSlider(before, key)
      local a = SettingsIO.getSlider(after, key)
      if math.abs(a - b) > 0.001 then
        return true
      end
    end
  end
  return false
end

function AutoTone.isTargetPhoto(photo)
  local ok, target = pcall(function()
    return LrDevelopController.getTargetPhoto()
  end)
  if not ok or not target then
    return false
  end
  return target.localIdentifier == photo.localIdentifier
end

function AutoTone.apply(catalog, photo)
  local before = SettingsIO.readToneSettings(photo)

  if AutoTone.isTargetPhoto(photo) then
    catalog:withWriteAccessDo("NoClip Auto Auto Tone", function()
      LrDevelopController.setAutoTone()
    end, { timeout = 60 })
  else
    catalog:withWriteAccessDo("NoClip Auto Auto Tone", function()
      photo:applyDevelopSettings(AUTO_FLAGS, "NoClip Auto Auto Tone", true)
    end, { timeout = 60 })
  end

  local after = SettingsIO.readToneSettings(photo)

  if not toneChanged(before, after) and not AutoTone.isTargetPhoto(photo) then
    catalog:withWriteAccessDo("NoClip Auto Auto Tone", function()
      catalog:setSelectedPhotos({ photo })
      LrDevelopController.revealPhoto(photo)
      LrDevelopController.setAutoTone()
    end, { timeout = 90 })
    after = SettingsIO.readToneSettings(photo)
  elseif not toneChanged(before, after) then
    NoClipAuto.logger:warn(string.format(
      "Auto Tone made no change on target photo=%s; continuing with current settings",
      tostring(photo.localIdentifier)
    ))
  end

  NoClipAuto.logger:info(string.format(
    "Auto Tone applied photo=%s exposure %.2f -> %.2f",
    tostring(photo.localIdentifier),
    SettingsIO.getSlider(before, "Exposure2012"),
    SettingsIO.getSlider(after, "Exposure2012")
  ))
  return after
end

return AutoTone
