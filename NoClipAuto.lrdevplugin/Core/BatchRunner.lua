-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local LrFunctionContext = import "LrFunctionContext"
local LrProgressScope = import "LrProgressScope"
local LrPathUtils = import "LrPathUtils"
local LrFileUtils = import "LrFileUtils"

local PerformanceTier = require("Core.PerformanceTier")
local Orchestrator = require("Core.Pipeline.Orchestrator")
local Platform = require("Core.Platform")
local ClippingClient = require("Core.ClippingClient")

local BatchRunner = {}

local function isVideo(photo)
  local path = photo:getRawMetadata("path")
  if not path then return true end
  local ext = LrPathUtils.extension(path):lower()
  return ext == "mp4" or ext == "mov" or ext == "avi" or ext == "m4v"
end

local function writeReport(results)
  local reportPath = LrPathUtils.child(Platform.tempDir(), "NoClipAuto-last-run.json")
  local lines = { "[" }
  for i, r in ipairs(results) do
    local entry = string.format(
      '{"id":"%s","ok":%s,"skipped":%s,"iterations":%d,"shadowBefore":%.3f,"highlightBefore":%.3f,"shadowAfter":%.3f,"highlightAfter":%.3f}',
      tostring(r.id),
      r.ok and "true" or "false",
      r.skipped and "true" or "false",
      r.iterations or 0,
      r.shadowBefore or 0,
      r.highlightBefore or 0,
      r.shadowAfter or 0,
      r.highlightAfter or 0
    )
    if i < #results then
      entry = entry .. ","
    end
    table.insert(lines, entry)
  end
  table.insert(lines, "]")
  LrFileUtils.writeToFile(reportPath, table.concat(lines, "\n"))
end

function BatchRunner.run()
  if not ClippingClient.analyzerExists() then
    LrDialogs.message("NoClip Auto", "Analyzer binary not found. Reinstall the plugin package.")
    return
  end

  local catalog = LrApplication.activeCatalog()
  local photos = catalog:getTargetPhotos()
  if #photos == 0 then
    LrDialogs.message("NoClip Auto", "No photos selected.")
    return
  end

  local tier = PerformanceTier.current()
  local dryRun = NoClipAuto.prefs.dryRun == true
  local results = {}

  LrFunctionContext.callWithContext("NoClip Auto Batch", function(context)
    local progress = LrProgressScope({
      title = dryRun and "NoClip Auto (dry run)" or "NoClip Auto",
      functionContext = context,
    })

    for i, photo in ipairs(photos) do
      progress:setPortionComplete(i - 1, #photos)
      if progress:isCanceled() then
        break
      end

      if isVideo(photo) then
        table.insert(results, { id = photo.localIdentifier, ok = true, skipped = true, iterations = 0 })
      else
        local result = Orchestrator.processPhoto(photo, tier.previewSize, dryRun)
        table.insert(results, {
          id = photo.localIdentifier,
          ok = result.ok,
          skipped = result.skipped,
          iterations = result.iterations or 0,
          shadowBefore = result.before and result.before.shadowClipPct or 0,
          highlightBefore = result.before and result.before.highlightClipPct or 0,
          shadowAfter = result.after and result.after.shadowClipPct or 0,
          highlightAfter = result.after and result.after.highlightClipPct or 0,
          error = result.error,
        })
      end

      PerformanceTier.maybeYield(i, tier)
    end

    progress:done()
  end)

  writeReport(results)
  local processed = 0
  local skipped = 0
  for _, r in ipairs(results) do
    if r.skipped then skipped = skipped + 1 else processed = processed + 1 end
  end
  LrDialogs.message(
    "NoClip Auto",
    string.format("Finished. Processed: %d, Skipped: %d%s", processed, skipped, dryRun and " (dry run)" or "")
  )
end

return BatchRunner
