-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local LrFunctionContext = import "LrFunctionContext"
local LrProgressScope = import "LrProgressScope"
local LrPathUtils = import "LrPathUtils"

local PerformanceTier = require("Core.PerformanceTier")
local Orchestrator = require("Core.Pipeline.Orchestrator")
local PhaseRunner = require("Core.Pipeline.PhaseRunner")
local PreviewPrefetch = require("Core.PreviewPrefetch")
local BatchReport = require("Core.BatchReport")
local ClippingClient = require("Core.ClippingClient")

local BatchRunner = {}

local function isVideo(photo)
  local path = photo:getRawMetadata("path")
  if not path then return true end
  local ext = LrPathUtils.extension(path):lower()
  return ext == "mp4" or ext == "mov" or ext == "avi" or ext == "m4v"
end

function BatchRunner.runBatch(photos, opts)
  opts = opts or {}
  local tier = opts.tier or PerformanceTier.current()
  local dryRun = opts.dryRun == true
  local results = {}

  if not opts.skipAnalyzerCheck and not ClippingClient.analyzerExists() then
    return nil, "analyzer not found"
  end

  local prefetch = tier.overlap and PreviewPrefetch.new(tier.previewSize) or nil

  local function processPhotos(progress)
    if prefetch then
      PhaseRunner.setPrefetch(prefetch)
    end

    for i, photo in ipairs(photos) do
      if progress then
        progress:setPortionComplete(i - 1, #photos)
        if progress:isCanceled() then
          break
        end
      end

      if prefetch and i < #photos then
        local nextPhoto = photos[i + 1]
        if not isVideo(nextPhoto) then
          prefetch:enqueue(nextPhoto)
        end
      end

      if isVideo(photo) then
        table.insert(results, { id = photo.localIdentifier, ok = true, skipped = true, iterations = 0 })
      else
        local result = Orchestrator.processPhoto(photo, tier.previewSize, dryRun)
        table.insert(results, BatchReport.resultEntry(photo, result))
      end

      PerformanceTier.maybeYield(i, tier)
    end

    if prefetch then
      PhaseRunner.setPrefetch(nil)
    end

    if progress then
      progress:done()
    end
  end

  if opts.useProgress then
    LrFunctionContext.callWithContext("NoClip Auto Batch", function(context)
      local progress = LrProgressScope({
        title = dryRun and "NoClip Auto (dry run)" or "NoClip Auto",
        functionContext = context,
      })
      processPhotos(progress)
    end)
  else
    processPhotos(nil)
  end

  local reportPath = BatchReport.writeReport(results, { dryRun = dryRun, tier = tier.name })
  return results, reportPath
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

  local dryRun = NoClipAuto.prefs.dryRun == true
  local results = BatchRunner.runBatch(photos, { dryRun = dryRun, useProgress = true })
  if not results then
    LrDialogs.message("NoClip Auto", "Batch failed.")
    return
  end

  local processed, skipped = BatchReport.summarize(results)
  LrDialogs.message(
    "NoClip Auto",
    string.format("Finished. Processed: %d, Skipped: %d%s", processed, skipped, dryRun and " (dry run)" or "")
  )
end

return BatchRunner
