-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrApplication = import "LrApplication"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"
local LrTasks = import "LrTasks"

local Platform = require("Core.Platform")
local PreviewRender = require("Core.PreviewRender")
local ClippingClient = require("Core.ClippingClient")

local PreviewSmoke = {}

local function resultPath()
  return LrPathUtils.child(Platform.tempDir(), "m3-smoke-result.json")
end

local function writeResult(payload)
  local lines = {
    string.format('"ok":%s', payload.ok and "true" or "false"),
    string.format('"jpegPath":"%s"', tostring(payload.jpegPath or ""):gsub("\\", "\\\\")),
    string.format('"error":"%s"', tostring(payload.error or ""):gsub('"', "'")),
    string.format('"shadowClipPx":%d', payload.shadowClipPx or 0),
    string.format('"highlightClipPx":%d', payload.highlightClipPx or 0),
  }
  local path = resultPath()
  LrFileUtils.createAllDirectories(LrPathUtils.parent(path))
  local file = io.open(path, "w")
  if file then
    file:write("{" .. table.concat(lines, ",") .. "}")
    file:close()
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

    LrTasks.yield()
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

local function runSmoke(triggerPath)
  if LrFileUtils.exists(triggerPath) ~= "file" then
    return
  end

  local raw = LrFileUtils.readFile(triggerPath)
  LrFileUtils.delete(triggerPath)
  local fixturePath, previewSize = parseTrigger(raw)

  local catalog = LrApplication.activeCatalog()
  local photo, pickErr = pickPhoto(catalog, fixturePath)
  if not photo then
    writeResult({ ok = false, error = pickErr or "no photo" })
    return
  end

  local jpegPath, exportErr = PreviewRender.exportPhoto(photo, previewSize)
  if not jpegPath then
    writeResult({ ok = false, error = exportErr or "export failed" })
    return
  end

  local clipResult, analyzeErr = ClippingClient.analyze(jpegPath)
  PreviewRender.cleanup(jpegPath)

  if not clipResult then
    writeResult({ ok = false, error = analyzeErr or "analyze failed" })
    return
  end

  writeResult({
    ok = true,
    jpegPath = jpegPath,
    shadowClipPx = clipResult.shadowClipPx,
    highlightClipPx = clipResult.highlightClipPx,
  })
end

local function triggerPath()
  return LrPathUtils.child(LrPathUtils.child(_PLUGIN.path, "smoke"), "m3-smoke.trigger")
end

function PreviewSmoke.runFromTriggerFile()
  for _ = 1, 60 do
    LrTasks.yield()
  end

  local path = triggerPath()
  if LrFileUtils.exists(path) == "file" then
    runSmoke(path)
    return
  end

  writeResult({ ok = false, error = "m3-smoke.trigger not found at " .. tostring(path) })
end

function PreviewSmoke.runFromTrigger(triggerPathArg)
  LrTasks.yield()
  LrTasks.yield()
  local ok, err = pcall(function() runSmoke(triggerPathArg) end)
  if not ok then
    writeResult({ ok = false, error = tostring(err) })
  end
end

return PreviewSmoke
