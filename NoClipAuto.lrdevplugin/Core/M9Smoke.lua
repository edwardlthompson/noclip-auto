-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"
local LrTasks = import "LrTasks"

local BatchRunner = require("Core.BatchRunner")
local BatchReport = require("Core.BatchReport")
local M9SmokeReport = require("Core.M9SmokeReport")
local PhaseRunner = require("Core.Pipeline.PhaseRunner")
local PreviewRender = require("Core.PreviewRender")
local Platform = require("Core.Platform")

local M9Smoke = {}

local SMOKE_HIGH_TIER = {
  name = "High",
  previewSize = 1024,
  yieldEvery = 10,
  overlap = true,
}

local function isVideo(photo)
  local path = photo:getRawMetadata("path")
  if not path then return true end
  local ext = LrPathUtils.extension(path):lower()
  return ext == "mp4" or ext == "mov" or ext == "avi" or ext == "m4v"
end

local function parseSmokeTrigger(raw)
  local fixture = raw:match('"fixture"%s*:%s*"([^"]+)"')
  if fixture then
    fixture = fixture:gsub("\\\\", "\\")
  end
  local count = tonumber(raw:match('"count"%s*:%s*(%d+)')) or 3
  local dryRun = raw:match('"dryRun"%s*:%s*false') == nil
  return fixture, count, dryRun
end

local function ensureSmokePhotos(catalog, count, fixturePath)
  local all = catalog:getAllPhotos() or {}
  local subset = {}
  for _, photo in ipairs(all) do
    if not isVideo(photo) then
      subset[#subset + 1] = photo
      if #subset >= count then
        return subset
      end
    end
  end

  if fixturePath and LrFileUtils.exists(fixturePath) == "file" then
    local need = count - #all
    local paths = {}
    for i = 1, need do
      paths[i] = fixturePath
    end
    if #paths > 0 then
      catalog:withWriteAccessDo("NoClip Auto M9 import", function()
        catalog:importPhotos(paths)
      end, { timeout = 300 })
      LrTasks.sleep(2)
    end

    all = catalog:getAllPhotos() or {}
    subset = {}
    for _, photo in ipairs(all) do
      if not isVideo(photo) then
        subset[#subset + 1] = photo
        if #subset >= count then
          return subset
        end
      end
    end
  end

  return nil, string.format("need %d processable photos, have %d", count, #subset)
end

local function fail(msg, triggerPath, dryRun, manualRun, count)
  M9SmokeReport.write({ ok = false, error = msg, dryRun = dryRun, count = count or 0 }, triggerPath)
  if manualRun then
    LrDialogs.message("NoClip Auto — M9 Smoke", "FAIL: " .. tostring(msg))
  end
end

function M9Smoke.runFromTrigger(triggerPath, manualRun)
  local fixturePath
  local count = 3
  local dryRun = true

  if triggerPath and LrFileUtils.exists(triggerPath) == "file" then
    local raw = LrFileUtils.readFile(triggerPath)
    fixturePath, count, dryRun = parseSmokeTrigger(raw)
  elseif not manualRun then
    fail("trigger not found: " .. tostring(triggerPath), triggerPath, true, false)
    return
  end

  local catalog = LrApplication.activeCatalog()
  local photos, pickErr = ensureSmokePhotos(catalog, count, fixturePath)
  if not photos then
    fail(pickErr or "no photos", triggerPath, dryRun, manualRun)
    return
  end

  PreviewRender.setPreferThumbnail(true)
  PhaseRunner.setSmokeAnalyzeFallback(true)
  local results, reportPath = BatchRunner.runBatch(photos, {
    dryRun = dryRun,
    tier = SMOKE_HIGH_TIER,
    skipAnalyzerCheck = false,
  })
  PhaseRunner.setSmokeAnalyzeFallback(false)
  PreviewRender.setPreferThumbnail(false)

  if not results then
    fail(reportPath or "batch failed", triggerPath, dryRun, manualRun)
    return
  end

  local valid, validErr = M9SmokeReport.validateResults(results, count)
  if not valid then
    fail(validErr, triggerPath, dryRun, manualRun, #results)
    return
  end

  local dryRunLog = LrPathUtils.child(Platform.tempDir(), "NoClipAuto-dry-run.log")
  if dryRun and LrFileUtils.exists(dryRunLog) ~= "file" then
    fail("dry-run log missing: " .. dryRunLog, triggerPath, dryRun, manualRun)
    return
  end

  local processed, skipped = BatchReport.summarize(results)
  M9SmokeReport.write({
    ok = true,
    count = #results,
    processed = processed,
    skipped = skipped,
    dryRun = dryRun,
    autoTone = true,
    schemaVersion2 = true,
    lensProfile = true,
    overlap = true,
    reportPath = reportPath,
  }, triggerPath)

  if manualRun then
    LrDialogs.message("NoClip Auto — M9 Smoke", string.format(
      "PASS\nLens profile + Auto Tone dry-run: %d photos\nReport: %s\nResult: %s",
      #results,
      reportPath or "",
      M9SmokeReport.resultPath()
    ))
  end
end

return M9Smoke
