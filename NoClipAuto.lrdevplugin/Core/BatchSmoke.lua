-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"
local LrTasks = import "LrTasks"

local BatchRunner = require("Core.BatchRunner")
local BatchReport = require("Core.BatchReport")
local PhaseRunner = require("Core.Pipeline.PhaseRunner")
local PreviewRender = require("Core.PreviewRender")
local Platform = require("Core.Platform")

local BatchSmoke = {}

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

local function writeSmokeResult(payload, triggerPath)
  BatchReport.writeSmokeResult(payload, triggerPath)
end

local function parseSmokeTrigger(raw)
  local fixture = raw:match('"fixture"%s*:%s*"([^"]+)"')
  if fixture then
    fixture = fixture:gsub("\\\\", "\\")
  end
  local count = tonumber(raw:match('"count"%s*:%s*(%d+)')) or 10
  local dryRun = raw:match('"dryRun"%s*:%s*true') ~= nil
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
      catalog:withWriteAccessDo("NoClip Auto M5 import", function()
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

function BatchSmoke.runFromTrigger(triggerPath, manualRun)
  local function finishSmoke()
    local fixturePath
    local count = 10
    local dryRun = true

    if triggerPath and LrFileUtils.exists(triggerPath) == "file" then
      local raw = LrFileUtils.readFile(triggerPath)
      fixturePath, count, dryRun = parseSmokeTrigger(raw)
    elseif not manualRun then
      writeSmokeResult({ ok = false, error = "trigger not found: " .. tostring(triggerPath) }, triggerPath)
      return
    end

    local catalog = LrApplication.activeCatalog()
    local photos, pickErr = ensureSmokePhotos(catalog, count, fixturePath)
    if not photos then
      writeSmokeResult({ ok = false, error = pickErr or "no photos" }, triggerPath)
      if manualRun then
        LrDialogs.message("NoClip Auto — M5 Smoke", "FAIL: " .. tostring(pickErr or "no photos"))
      end
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
      writeSmokeResult({ ok = false, error = reportPath or "batch failed" }, triggerPath)
      if manualRun then
        LrDialogs.message("NoClip Auto — M5 Smoke", "FAIL: " .. tostring(reportPath or "batch failed"))
      end
      return
    end

    local processed, skipped = BatchReport.summarize(results)
    local allOk = true
    for _, r in ipairs(results) do
      if not r.ok then
        allOk = false
      end
    end

    local dryRunLog = LrPathUtils.child(Platform.tempDir(), "NoClipAuto-dry-run.log")
    if dryRun and LrFileUtils.exists(dryRunLog) ~= "file" then
      writeSmokeResult({ ok = false, error = "dry-run log missing: " .. dryRunLog }, triggerPath)
      if manualRun then
        LrDialogs.message("NoClip Auto — M5 Smoke", "FAIL: dry-run log missing")
      end
      return
    end

    writeSmokeResult({
      ok = allOk and #results == count,
      count = #results,
      processed = processed,
      skipped = skipped,
      dryRun = dryRun,
      overlap = true,
      reportPath = reportPath,
    }, triggerPath)

    if manualRun then
      local status = allOk and "PASS" or "FAIL"
      LrDialogs.message("NoClip Auto — M5 Smoke", string.format(
        "%s\nBatch dry-run: %d photos (%d processed, %d skipped)\nOverlap tier: High\nReport: %s\nResult: %s",
        status,
        #results,
        processed,
        skipped,
        reportPath or "",
        BatchReport.smokeResultPath()
      ))
    end
  end

  local ok, err = pcall(finishSmoke)
  if not ok then
    writeSmokeResult({ ok = false, error = tostring(err) }, triggerPath)
    if manualRun then
      LrDialogs.message("NoClip Auto — M5 Smoke", "FAIL: " .. tostring(err))
    end
  end
end

return BatchSmoke
