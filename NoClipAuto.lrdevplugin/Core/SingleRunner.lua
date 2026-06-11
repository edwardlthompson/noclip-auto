-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local LrDevelopController = import "LrDevelopController"
local LrProgressScope = import "LrProgressScope"

local PerformanceTier = require("Core.PerformanceTier")
local Orchestrator = require("Core.Pipeline.Orchestrator")
local ClippingClient = require("Core.ClippingClient")
local Prefs = require("Core.Prefs")
local RunSummary = require("Core.RunSummary")

local SingleRunner = {}

local function resolveActivePhoto()
  local ok, developPhoto = pcall(function()
    return LrDevelopController.getTargetPhoto()
  end)
  if ok and developPhoto then
    return developPhoto
  end

  local photos = LrApplication.activeCatalog():getTargetPhotos()
  if #photos == 1 then
    return photos[1]
  end
  if #photos > 1 then
    return nil, "multiple"
  end
  return nil, "none"
end

function SingleRunner.run(functionContext)
  Prefs.syncToGlobals()

  if not ClippingClient.analyzerExists() then
    LrDialogs.message("NoClip Auto", "Analyzer binary not found. Reinstall the plugin package.")
    return
  end

  local photo, pickErr = resolveActivePhoto()
  if not photo then
    local msg = "Select one photo in Library (filmstrip or grid), or open Develop."
    if pickErr == "multiple" then
      msg = "Multiple photos selected. Select one photo, or use NoClip Auto - Selected Photos for batch."
    end
    LrDialogs.message("NoClip Auto", msg)
    return
  end

  local dryRun = NoClipAuto.prefs.dryRun == true
  if dryRun then
    local proceed = LrDialogs.confirm(
      "NoClip Auto",
      "Dry run is ON — settings are measured and logged but NOT saved to your photo.\n\nContinue anyway?",
      "Continue dry run",
      "Cancel"
    )
    if proceed ~= "ok" then
      return
    end
  end

  local tier = PerformanceTier.current()
  local result

  local function process(onProgress)
    return Orchestrator.processPhoto(photo, tier.previewSize, dryRun, {
      onProgress = onProgress,
    })
  end

  if functionContext then
    local progress = LrProgressScope({
      title = dryRun and "NoClip Auto (dry run)" or "NoClip Auto",
      functionContext = functionContext,
    })
    result = process(function(caption, iterFraction)
      progress:setCaption(caption)
      progress:setPortionComplete(iterFraction or 0, 1)
    end)
    progress:done()
  else
    result = process(nil)
  end

  if not result.ok then
    LrDialogs.message("NoClip Auto", "Error: " .. tostring(result.error))
    return
  end

  LrDialogs.message("NoClip Auto", RunSummary.formatPhotoResult(result))
end

return SingleRunner
