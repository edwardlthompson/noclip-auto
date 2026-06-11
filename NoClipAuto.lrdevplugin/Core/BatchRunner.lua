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
local RunSummary = require("Core.RunSummary")
local Prefs = require("Core.Prefs")

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
  local functionContext = opts.functionContext
  local photoCount = #photos

  if not opts.skipAnalyzerCheck and not ClippingClient.analyzerExists() then
    return nil, "analyzer not found"
  end

  local prefetch = tier.overlap and PreviewPrefetch.new(tier.previewSize) or nil

  local function processPhotos(progress)
    if prefetch then
      PhaseRunner.setPrefetch(prefetch)
    end

    for i, photo in ipairs(photos) do
      local basePortion = (i - 1) / photoCount

      if progress then
        progress:setPortionComplete(basePortion, 1)
        progress:setCaption(string.format("Photo %d of %d", i, photoCount))
      end

      if progress and progress:isCanceled() then
        break
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
        local orchResult = Orchestrator.processPhoto(photo, tier.previewSize, dryRun, {
          onProgress = function(caption, iterFraction)
            if progress then
              progress:setCaption(string.format("Photo %d/%d — %s", i, photoCount, caption))
              progress:setPortionComplete(basePortion + (iterFraction / photoCount), 1)
            end
          end,
        })
        table.insert(results, BatchReport.resultEntry(photo, orchResult))
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

  if opts.useProgress and functionContext then
    local progress = LrProgressScope({
      title = dryRun and "NoClip Auto (dry run)" or "NoClip Auto",
      functionContext = functionContext,
    })
    processPhotos(progress)
  elseif opts.useProgress then
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

function BatchRunner.run(functionContext)
  Prefs.syncToGlobals()

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
  if dryRun then
    local proceed = LrDialogs.confirm(
      "NoClip Auto",
      "Dry run is ON — settings are measured and logged but NOT saved to your photos.\n\nContinue anyway?",
      "Continue dry run",
      "Cancel"
    )
    if proceed ~= "ok" then
      return
    end
  end

  local results, reportPath = BatchRunner.runBatch(photos, {
    dryRun = dryRun,
    useProgress = true,
    functionContext = functionContext,
  })
  if not results then
    LrDialogs.message("NoClip Auto", "Batch failed.")
    return
  end

  local processed, skipped = BatchReport.summarize(results)
  local header = string.format("Finished. Processed: %d, Skipped: %d", processed, skipped)
  local detail = RunSummary.formatBatchResults(results, dryRun)
  LrDialogs.message("NoClip Auto", header .. "\n\n" .. detail .. "\nReport: " .. tostring(reportPath or ""))
end

return BatchRunner
