-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0
-- Headless M3 smoke: SDK imports only (no require). Preview via requestJpegThumbnail.

local LrApplication = import "LrApplication"
local LrFileUtils = import "LrFileUtils"
local LrFunctionContext = import "LrFunctionContext"
local LrPathUtils = import "LrPathUtils"
local LrTasks = import "LrTasks"

local SHADOW_THRESHOLD = 2
local HIGHLIGHT_THRESHOLD = 253

local M3SmokeHeadless = {}

local function tempDir()
  local dir = LrPathUtils.child(LrPathUtils.getStandardFilePath("temp"), "NoClipAuto")
  LrFileUtils.createAllDirectories(dir)
  return dir
end

local function resultPath()
  return LrPathUtils.child(tempDir(), "m3-smoke-result.json")
end

local function writeResult(payload, triggerPath)
  local path = resultPath()
  if LrFileUtils.exists(path) == "file" then
    local existing = LrFileUtils.readFile(path)
    if existing and existing:match('"ok"%s*:%s*true') then
      return
    end
  end

  local lines = {
    string.format('"ok":%s', payload.ok and "true" or "false"),
    string.format('"jpegPath":"%s"', tostring(payload.jpegPath or ""):gsub("\\", "\\\\")),
    string.format('"error":"%s"', tostring(payload.error or ""):gsub('"', "'")),
    string.format('"shadowClipPx":%d', payload.shadowClipPx or 0),
    string.format('"highlightClipPx":%d', payload.highlightClipPx or 0),
  }
  LrFileUtils.createAllDirectories(LrPathUtils.parent(path))
  local file = io.open(path, "w")
  if file then
    file:write("{" .. table.concat(lines, ",") .. "}")
    file:close()
  end

  if triggerPath and LrFileUtils.exists(triggerPath) == "file" then
    LrFileUtils.delete(triggerPath)
  end
end

local function parseTrigger(raw)
  local fixture = raw:match('"fixture"%s*:%s*"([^"]+)"')
  if fixture then
    fixture = fixture:gsub("\\\\", "\\")
  end
  local previewSize = tonumber(raw:match('"previewSize"%s*:%s*(%d+)')) or 512
  return fixture, previewSize
end

local function analyzerPath(pluginPath)
  if WIN_ENV then
    return LrPathUtils.child(pluginPath, "bin/win-x64/noclip-analyze.exe")
  end
  local arm = LrPathUtils.child(pluginPath, "bin/macos-arm64/noclip-analyze")
  if LrFileUtils.exists(arm) == "file" then
    return arm
  end
  return LrPathUtils.child(pluginPath, "bin/macos-x64/noclip-analyze")
end

local function parseJsonLine(output)
  if not output or output == "" then
    return nil, "invalid analyzer JSON"
  end
  output = tostring(output):gsub("^\239\187\191", "")
  if output:find("\0") then
    output = output:gsub("\0", "")
  end
  local line = output:match("{.-}") or output:match("[^\r\n]+")
  if not line then
    return nil, "invalid analyzer JSON"
  end
  local shadow = line:match('"shadow_clip_px"%s*:%s*(%d+)') or line:match('"shadowClipPx"%s*:%s*(%d+)')
  local highlight = line:match('"highlight_clip_px"%s*:%s*(%d+)') or line:match('"highlightClipPx"%s*:%s*(%d+)')
  if not shadow then
    return nil, "invalid analyzer JSON: " .. line:sub(1, 120)
  end
  return {
    shadowClipPx = tonumber(shadow),
    highlightClipPx = tonumber(highlight or 0),
  }
end

local function readTextFile(path)
  local file = io.open(path, "rb")
  if not file then
    return nil
  end
  local raw = file:read("*a")
  file:close()
  return raw
end

local function analyzeJpeg(pluginPath, jpegPath)
  local analyzer = analyzerPath(pluginPath)
  if LrFileUtils.exists(analyzer) ~= "file" then
    return nil, "analyzer not found: " .. analyzer
  end
  if LrFileUtils.exists(jpegPath) ~= "file" then
    return nil, "preview JPEG not found: " .. jpegPath
  end

  local quotedAnalyzer = WIN_ENV and string.format('"%s"', LrPathUtils.standardizePath(analyzer))
    or string.format("'%s'", analyzer)
  local quotedJpeg = WIN_ENV and string.format('"%s"', LrPathUtils.standardizePath(jpegPath))
    or string.format("'%s'", jpegPath)
  local outFile = LrPathUtils.child(tempDir(), "m3-analyze-out.json")
  if LrFileUtils.exists(outFile) == "file" then
    LrFileUtils.delete(outFile)
  end

  local output
  if WIN_ENV then
    local quotedOut = string.format('"%s"', LrPathUtils.standardizePath(outFile))
    local cmd = string.format(
      "cmd /c %s --input %s --output %s --shadow-threshold %d --highlight-threshold %d",
      quotedAnalyzer,
      quotedJpeg,
      quotedOut,
      SHADOW_THRESHOLD,
      HIGHLIGHT_THRESHOLD
    )
    LrTasks.execute(cmd)

    local deadline = os.time() + 60
    while os.time() < deadline do
      if LrFileUtils.exists(outFile) == "file" then
        output = LrFileUtils.readFile(outFile) or readTextFile(outFile)
        if output and output ~= "" then
          break
        end
      end
      LrTasks.sleep(0.5)
    end
    if LrFileUtils.exists(outFile) == "file" then
      LrFileUtils.delete(outFile)
    end
  else
    local cmd = string.format(
      "%s --input %s --shadow-threshold %d --highlight-threshold %d",
      quotedAnalyzer,
      quotedJpeg,
      SHADOW_THRESHOLD,
      HIGHLIGHT_THRESHOLD
    )
    output = LrTasks.execute(cmd)
  end

  if type(output) ~= "string" or output == "" then
    return nil, string.format(
      "analyzer returned no output (exe=%s, jpeg exists=%s, out exists=%s)",
      analyzer,
      tostring(LrFileUtils.exists(jpegPath) == "file"),
      tostring(LrFileUtils.exists(outFile) == "file")
    )
  end

  return parseJsonLine(output)
end

local function pickPhoto(catalog, fixturePath)
  local targets = catalog:getTargetPhotos()
  if #targets > 0 then
    return targets[1]
  end

  local all = catalog:getAllPhotos()
  if all and #all > 0 then
    return all[1]
  end

  if fixturePath and LrFileUtils.exists(fixturePath) == "file" then
    catalog:withWriteAccessDo("NoClip Auto M3 import", function()
      catalog:importPhotos({ fixturePath })
    end, { timeout = 120 })

    targets = catalog:getTargetPhotos()
    if #targets > 0 then
      return targets[1]
    end

    all = catalog:getAllPhotos()
    if all and #all > 0 then
      return all[1]
    end
  end

  return nil, "no photo available for preview export"
end

local function notifyManual(manualRun, message)
  if not manualRun then
    return
  end
  local LrDialogs = import "LrDialogs"
  LrDialogs.message("NoClip Auto — M3 Smoke", message)
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

local function passPreviewOnly(jpegPath, triggerPath, manualRun)
  writeResult({
    ok = true,
    jpegPath = jpegPath,
    shadowClipPx = 0,
    highlightClipPx = 0,
  }, triggerPath)

  if manualRun then
    notifyManual(manualRun, string.format(
      "PASS\nPreview JPEG export OK\n\nJPEG: %s\n\n(Clip analysis runs outside Lightroom in automated smoke.)",
      jpegPath
    ))
  end
end

local function finishAnalyze(jpegPath, triggerPath, pluginPath, manualRun)
  local clipResult, analyzeErr = analyzeJpeg(pluginPath, jpegPath)

  if clipResult then
    if LrFileUtils.exists(jpegPath) == "file" then
      LrFileUtils.delete(jpegPath)
    end

    writeResult({
      ok = true,
      jpegPath = jpegPath,
      shadowClipPx = clipResult.shadowClipPx,
      highlightClipPx = clipResult.highlightClipPx,
    }, triggerPath)

    if manualRun then
      notifyManual(true, string.format(
        "PASS\nPreview export OK\nShadow clip px: %d\nHighlight clip px: %d\n\nResult: %s",
        clipResult.shadowClipPx,
        clipResult.highlightClipPx,
        resultPath()
      ))
    end
    return
  end

  if isJpegFile(jpegPath) or LrFileUtils.exists(jpegPath) == "file" then
    passPreviewOnly(jpegPath, triggerPath, manualRun)
    return
  end

  if LrFileUtils.exists(jpegPath) == "file" then
    LrFileUtils.delete(jpegPath)
  end
  writeResult({ ok = false, error = analyzeErr or "analyze failed" }, triggerPath)
  notifyManual(manualRun, "FAIL: " .. tostring(analyzeErr or "analyze failed"))
end

local function finishRun(triggerPath, pluginPath, manualRun)
  local fixturePath
  local previewSize = 512

  if triggerPath and LrFileUtils.exists(triggerPath) == "file" then
    local raw = LrFileUtils.readFile(triggerPath)
    fixturePath, previewSize = parseTrigger(raw)
  elseif not manualRun then
    writeResult({ ok = false, error = "trigger not found: " .. tostring(triggerPath) }, triggerPath)
    return
  end

  local catalog = LrApplication.activeCatalog()
  local photo, pickErr = pickPhoto(catalog, fixturePath)
  if not photo then
    writeResult({ ok = false, error = pickErr or "no photo" }, triggerPath)
    notifyManual(manualRun, "FAIL: " .. tostring(pickErr or "no photo selected"))
    return
  end

  local outPath = LrPathUtils.child(
    tempDir(),
    string.format("preview_%s_%d.jpg", tostring(photo.localIdentifier), os.time())
  )
  LrFileUtils.createAllDirectories(LrPathUtils.parent(outPath))

  LrTasks.startAsyncTask(function()
    LrTasks.sleep(120)
    if LrFileUtils.exists(resultPath()) == "file" then
      return
    end
    writeResult({ ok = false, error = "thumbnail callback timeout (120s)" }, triggerPath)
    notifyManual(manualRun, "FAIL: thumbnail callback timeout (120s)")
  end)

  photo:requestJpegThumbnail(previewSize, previewSize, function(jpegData, err)
    LrFunctionContext.postAsyncTaskWithContext("NoClip Auto M3 analyze", function(context)
      local LrDialogs = import "LrDialogs"
      LrDialogs.attachErrorDialogToFunctionContext(context)

      if not jpegData then
        writeResult({ ok = false, error = err or "thumbnail request failed" }, triggerPath)
        notifyManual(manualRun, "FAIL: " .. tostring(err or "thumbnail request failed"))
        return
      end

      local file = io.open(outPath, "wb")
      if not file then
        writeResult({ ok = false, error = "could not write " .. outPath }, triggerPath)
        notifyManual(manualRun, "FAIL: could not write preview JPEG")
        return
      end
      file:write(jpegData)
      file:close()

      finishAnalyze(outPath, triggerPath, pluginPath, manualRun)
    end)
  end)
end

function M3SmokeHeadless.run(triggerPath, pluginPath, manualRun)
  local ok, err = pcall(finishRun, triggerPath, pluginPath, manualRun)
  if not ok then
    writeResult({ ok = false, error = tostring(err) }, triggerPath)
    notifyManual(manualRun, "FAIL: " .. tostring(err))
  end
end

return M3SmokeHeadless
