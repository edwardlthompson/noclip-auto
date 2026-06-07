-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local LrDevelopController = import "LrDevelopController"

local PerformanceTier = require("Core.PerformanceTier")
local Orchestrator = require("Core.Pipeline.Orchestrator")
local ClippingClient = require("Core.ClippingClient")

local SingleRunner = {}

function SingleRunner.run()
  if not ClippingClient.analyzerExists() then
    LrDialogs.message("NoClip Auto", "Analyzer binary not found. Reinstall the plugin package.")
    return
  end

  local photo = LrDevelopController.getTargetPhoto()
  if not photo then
    LrDialogs.message("NoClip Auto", "No active photo in Develop.")
    return
  end

  local tier = PerformanceTier.current()
  local dryRun = NoClipAuto.prefs.dryRun == true
  local result = Orchestrator.processPhoto(photo, tier.previewSize, dryRun)

  if not result.ok then
    LrDialogs.message("NoClip Auto", "Error: " .. tostring(result.error))
    return
  end

  if result.skipped then
    LrDialogs.message("NoClip Auto", "Photo already has no significant clipping.")
    return
  end

  LrDialogs.message(
    "NoClip Auto",
    string.format(
      "Done%s. Iterations: %d. Shadow clip: %.2f%% → %.2f%%. Highlight clip: %.2f%% → %.2f%%.",
      dryRun and " (dry run)" or "",
      result.iterations or 0,
      result.before.shadowClipPct,
      result.after.shadowClipPct,
      result.before.highlightClipPct,
      result.after.highlightClipPct
    )
  )
end

return SingleRunner
