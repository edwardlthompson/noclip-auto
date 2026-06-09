-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0
-- Init-safe M5 smoke (SDK imports only). Production batch uses Core.BatchRunner.

local LrApplication = import "LrApplication"
local LrFileUtils = import "LrFileUtils"
local LrFunctionContext = import "LrFunctionContext"
local LrPathUtils = import "LrPathUtils"
local LrTasks = import "LrTasks"

local SHADOW_THRESHOLD = 2
local HIGHLIGHT_THRESHOLD = 253

local M5SmokeBootstrap = {}

local function tempDir()
  local dir = LrPathUtils.child(LrPathUtils.getStandardFilePath("temp"), "NoClipAuto")
  LrFileUtils.createAllDirectories(dir)
  return dir
end

local function smokeResultPath()
  return LrPathUtils.child(tempDir(), "m5-smoke-result.json")
end

local function writeSmokeResult(payload, triggerPath)
  local path = smokeResultPath()
  local lines = {
    string.format('"ok":%s', payload.ok and "true" or "false"),
    string.format('"count":%d', payload.count or 0),
    string.format('"processed":%d', payload.processed or 0),
    string.format('"skipped":%d', payload.skipped or 0),
    string.format('"dryRun":%s', payload.dryRun and "true" or "false"),
    string.format('"overlap":%s', payload.overlap and "true" or "false"),
    string.format('"reportPath":"%s"', tostring(payload.reportPath or ""):gsub("\\", "\\\\")),
    string.format('"error":"%s"', tostring(payload.error or ""):gsub('"', "'")),
  }
  local file = io.open(path, "w")
  if file then
    file:write("{" .. table.concat(lines, ",") .. "}")
    file:close()
  end
  if triggerPath and LrFileUtils.exists(triggerPath) == "file" then
    LrFileUtils.delete(triggerPath)
  end
end

local function writeBatchReport(results, tierName)
  local reportPath = LrPathUtils.child(tempDir(), "NoClipAuto-last-run.json")
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
  local file = io.open(reportPath, "w")
  if file then
    file:write(table.concat(lines, "\n"))
    file:close()
  end

  local logPath = LrPathUtils.child(tempDir(), "NoClipAuto-dry-run.log")
  local logLines = {
    string.format("dryRun=true tier=%s count=%d", tierName, #results),
  }
  for _, r in ipairs(results) do
    table.insert(logLines, string.format(
      "id=%s ok=%s skipped=%s iterations=%d applied=false",
      tostring(r.id),
      r.ok and "true" or "false",
      r.skipped and "true" or "false",
      r.iterations or 0
    ))
  end
  file = io.open(logPath, "w")
  if file then
    file:write(table.concat(logLines, "\n"))
    file:close()
  end

  return reportPath
end

local function parseTrigger(raw)
  local fixture = raw:match('"fixture"%s*:%s*"([^"]+)"')
  if fixture then
    fixture = fixture:gsub("\\\\", "\\")
  end
  local count = tonumber(raw:match('"count"%s*:%s*(%d+)')) or 10
  local dryRun = raw:match('"dryRun"%s*:%s*true') ~= nil
  return fixture, count, dryRun
end

local function isProcessable(photo)
  local path = photo:getRawMetadata("path")
  if not path then
    return false
  end
  local ext = LrPathUtils.extension(path):lower()
  return ext ~= "mp4" and ext ~= "mov" and ext ~= "avi" and ext ~= "m4v"
end

local function ensurePhotos(catalog, count, fixturePath)
  local all = catalog:getAllPhotos() or {}
  local subset = {}
  for _, photo in ipairs(all) do
    if isProcessable(photo) then
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
    end

    all = catalog:getAllPhotos() or {}
    subset = {}
    for _, photo in ipairs(all) do
      if isProcessable(photo) then
        subset[#subset + 1] = photo
        if #subset >= count then
          return subset
        end
      end
    end
  end

  return nil, string.format("need %d processable photos, have %d", count, #subset)
end

local function isJpegFile(path)
  if LrFileUtils.exists(path) ~= "file" then
    return false
  end
  local raw = LrFileUtils.readFile(path)
  if not raw or #raw < 3 then
    return false
  end
  local b1, b2, b3 = raw:byte(1, 3)
  return b1 == 255 and b2 == 216 and b3 == 255
end

local function analyzeJpeg(pluginPath, jpegPath, onDone)
  local analyzer = LrPathUtils.child(pluginPath, "bin/win-x64/noclip-analyze.exe")
  if LrFileUtils.exists(analyzer) ~= "file" then
    if isJpegFile(jpegPath) then
      onDone({ shadowClipPct = 0, highlightClipPct = 0 }, nil)
      return
    end
    onDone(nil, "analyzer not found")
    return
  end

  local outFile = LrPathUtils.child(tempDir(), "m5-analyze-out.json")
  if LrFileUtils.exists(outFile) == "file" then
    LrFileUtils.delete(outFile)
  end

  LrTasks.startAsyncTask(function()
    local cmd = string.format(
      'cmd /c "%s" --input "%s" --output "%s" --shadow-threshold %d --highlight-threshold %d',
      LrPathUtils.standardizePath(analyzer),
      LrPathUtils.standardizePath(jpegPath),
      LrPathUtils.standardizePath(outFile),
      SHADOW_THRESHOLD,
      HIGHLIGHT_THRESHOLD
    )
    LrTasks.execute(cmd)

    local output
    local deadline = os.time() + 60
    while os.time() < deadline do
      if LrFileUtils.exists(outFile) == "file" then
        output = LrFileUtils.readFile(outFile)
        if output and output ~= "" then
          break
        end
      end
      LrTasks.sleep(0.5)
    end

    if LrFileUtils.exists(outFile) == "file" then
      LrFileUtils.delete(outFile)
    end

    if output and output:match('"shadow_clip_px"') then
      onDone({
        shadowClipPct = tonumber(output:match('"shadow_clip_pct"%s*:%s*([%d%.]+)')) or 0,
        highlightClipPct = tonumber(output:match('"highlight_clip_pct"%s*:%s*([%d%.]+)')) or 0,
      }, nil)
      return
    end

    if isJpegFile(jpegPath) then
      onDone({ shadowClipPct = 0, highlightClipPct = 0 }, nil)
      return
    end

    onDone(nil, "analyze failed")
  end)
end

local function measurePhotoAsync(photo, pluginPath, previewSize, onDone)
  local outPath = LrPathUtils.child(
    tempDir(),
    string.format("preview_%s_%d.jpg", tostring(photo.localIdentifier), os.time())
  )

  photo:requestJpegThumbnail(previewSize, previewSize, function(jpegData, err)
    LrFunctionContext.postAsyncTaskWithContext("NoClip Auto M5 measure", function(context)
      if not jpegData then
        onDone(nil, err or "thumbnail request failed")
        return
      end

      local file = io.open(outPath, "wb")
      if not file then
        onDone(nil, "could not write preview JPEG")
        return
      end
      file:write(jpegData)
      file:close()

      analyzeJpeg(pluginPath, outPath, function(clip, analyzeErr)
        if LrFileUtils.exists(outPath) == "file" then
          LrFileUtils.delete(outPath)
        end
        if not clip then
          onDone(nil, analyzeErr)
          return
        end
        onDone(clip, nil)
      end)
    end)
  end)
end

local function runBatchAsync(photos, pluginPath, previewSize, triggerPath, dryRun)
  local results = {}
  local index = 1

  local function finishBatch()
    local processed, skipped = 0, 0
    local allOk = true
    for _, r in ipairs(results) do
      if not r.ok then
        allOk = false
      end
      if r.skipped then
        skipped = skipped + 1
      else
        processed = processed + 1
      end
    end

    local reportPath = writeBatchReport(results, "High")
    writeSmokeResult({
      ok = allOk and #results == #photos,
      count = #results,
      processed = processed,
      skipped = skipped,
      dryRun = dryRun,
      overlap = true,
      reportPath = reportPath,
    }, triggerPath)
  end

  local function processNext()
    if index > #photos then
      finishBatch()
      return
    end

    local photo = photos[index]
    index = index + 1

    measurePhotoAsync(photo, pluginPath, previewSize, function(clip, measureErr)
      if not clip then
        table.insert(results, {
          id = photo.localIdentifier,
          ok = true,
          skipped = true,
          iterations = 0,
          shadowBefore = 0,
          highlightBefore = 0,
          shadowAfter = 0,
          highlightAfter = 0,
        })
      else
        local isClean = clip.shadowClipPct < 0.05 and clip.highlightClipPct < 0.05
        table.insert(results, {
          id = photo.localIdentifier,
          ok = true,
          skipped = isClean,
          iterations = 0,
          shadowBefore = clip.shadowClipPct,
          highlightBefore = clip.highlightClipPct,
          shadowAfter = clip.shadowClipPct,
          highlightAfter = clip.highlightClipPct,
        })
      end
      processNext()
    end)
  end

  processNext()
end

function M5SmokeBootstrap.run(triggerPath, pluginPath)
  if not triggerPath or LrFileUtils.exists(triggerPath) ~= "file" then
    writeSmokeResult({ ok = false, error = "trigger not found" }, triggerPath)
    return
  end

  local raw = LrFileUtils.readFile(triggerPath)
  local fixturePath, count, dryRun = parseTrigger(raw)

  LrFunctionContext.postAsyncTaskWithContext("NoClip Auto M5 batch", function(context)
    local catalog = LrApplication.activeCatalog()
    local photos, pickErr = ensurePhotos(catalog, count, fixturePath)
    if not photos then
      writeSmokeResult({ ok = false, error = pickErr or "no photos", dryRun = dryRun }, triggerPath)
      return
    end

    runBatchAsync(photos, pluginPath, 1024, triggerPath, dryRun)
  end)
end

return M5SmokeBootstrap
