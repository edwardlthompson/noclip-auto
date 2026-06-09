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
  NoClipAuto.logger:info(string.format(
    "Auto Tone applied photo=%s exposure %.2f -> %.2f",
    tostring(photo.localIdentifier),
    SettingsIO.getSlider(before, "Exposure2012"),
    SettingsIO.getSlider(after, "Exposure2012")
  ))
  return after
end

return AutoTone
