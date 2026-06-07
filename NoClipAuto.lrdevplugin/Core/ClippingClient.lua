-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrTasks = import "LrTasks"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"

local Platform = require("Core.Platform")
local Config = require("Core.Pipeline.Config")

local ClippingClient = {}

local function parseJsonLine(line)
  local shadow = line:match('"shadow_clip_px"%s*:%s*(%d+)') or line:match('"shadowClipPx"%s*:%s*(%d+)')
  local highlight = line:match('"highlight_clip_px"%s*:%s*(%d+)') or line:match('"highlightClipPx"%s*:%s*(%d+)')
  local shadowPct = line:match('"shadow_clip_pct"%s*:%s*([%d%.]+)') or line:match('"shadowClipPct"%s*:%s*([%d%.]+)')
  local highlightPct = line:match('"highlight_clip_pct"%s*:%s*([%d%.]+)') or line:match('"highlightClipPct"%s*:%s*([%d%.]+)')
  if not shadow then
    return nil, "invalid analyzer JSON"
  end
  return {
    shadowClipPx = tonumber(shadow),
    highlightClipPx = tonumber(highlight),
    shadowClipPct = tonumber(shadowPct) or 0,
    highlightClipPct = tonumber(highlightPct) or 0,
  }
end

function ClippingClient.analyzerExists()
  local path = Platform.analyzerPath(Platform.pluginDir())
  return LrFileUtils.exists(path) == "file"
end

function ClippingClient.analyze(jpegPath)
  local analyzer = Platform.analyzerPath(Platform.pluginDir())
  if LrFileUtils.exists(analyzer) ~= "file" then
    return nil, "analyzer not found: " .. analyzer
  end

  local cmd = string.format(
    "%s --input %s --shadow-threshold %d --highlight-threshold %d",
    Platform.quotePath(analyzer),
    Platform.quotePath(jpegPath),
    Config.SHADOW_THRESHOLD,
    Config.HIGHLIGHT_THRESHOLD
  )

  local output = LrTasks.execute(cmd)
  if not output or output == "" then
    return nil, "analyzer returned no output"
  end

  local line = output:match("[^\r\n]+")
  return parseJsonLine(line)
end

function ClippingClient.tempJpegPath(photoId)
  local name = string.format("preview_%s_%d.jpg", tostring(photoId), os.time())
  return LrPathUtils.child(Platform.tempDir(), name)
end

return ClippingClient
