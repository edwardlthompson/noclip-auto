-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrTasks = import "LrTasks"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"

local Platform = require("Core.Platform")
local Config = require("Core.Pipeline.Config")

local ClippingClient = {}

local function parseJsonNumber(line, snakeKey, camelKey)
  local pattern = '"%s"%s*:%s*([%d%.]+)'
  local val = line:match(string.format(pattern, snakeKey))
  if not val and camelKey then
    val = line:match(string.format(pattern, camelKey))
  end
  if val then
    return tonumber(val)
  end
  return nil
end

local function parseJsonLine(line)
  local shadow = line:match('"shadow_clip_px"%s*:%s*(%d+)') or line:match('"shadowClipPx"%s*:%s*(%d+)')
  local highlight = line:match('"highlight_clip_px"%s*:%s*(%d+)') or line:match('"highlightClipPx"%s*:%s*(%d+)')
  local shadowPct = line:match('"shadow_clip_pct"%s*:%s*([%d%.]+)') or line:match('"shadowClipPct"%s*:%s*([%d%.]+)')
  local highlightPct = line:match('"highlight_clip_pct"%s*:%s*([%d%.]+)') or line:match('"highlightClipPct"%s*:%s*([%d%.]+)')
  if not shadow then
    return nil, "invalid analyzer JSON"
  end
  local result = {
    shadowClipPx = tonumber(shadow),
    highlightClipPx = tonumber(highlight),
    shadowClipPct = tonumber(shadowPct) or 0,
    highlightClipPct = tonumber(highlightPct) or 0,
    schemaVersion = parseJsonNumber(line, "schema_version", "schemaVersion"),
    meanLuma = parseJsonNumber(line, "mean_luma", "meanLuma"),
    medianLuma = parseJsonNumber(line, "median_luma", "medianLuma"),
    p05Luma = parseJsonNumber(line, "p05_luma", "p05Luma"),
    p50Luma = parseJsonNumber(line, "p50_luma", "p50Luma"),
    p95Luma = parseJsonNumber(line, "p95_luma", "p95Luma"),
    logAvgLuma = parseJsonNumber(line, "log_avg_luma", "logAvgLuma"),
  }
  return result
end

function ClippingClient.analyzerExists()
  local path = Platform.analyzerPath(Platform.pluginDir())
  return LrFileUtils.exists(path) == "file"
end

function ClippingClient.analyze(jpegPath, opts)
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

  local output
  if WIN_ENV then
    local outFile = LrPathUtils.child(Platform.tempDir(), "analyze-out.json")
    if LrFileUtils.exists(outFile) == "file" then
      LrFileUtils.delete(outFile)
    end
    local winCmd = string.format(
      "cmd /c %s --input %s --output %s --shadow-threshold %d --highlight-threshold %d",
      Platform.quotePath(analyzer),
      Platform.quotePath(jpegPath),
      Platform.quotePath(outFile),
      Config.SHADOW_THRESHOLD,
      Config.HIGHLIGHT_THRESHOLD
    )
    LrTasks.execute(winCmd)

    local deadline = os.time() + 60
    while os.time() < deadline do
      if LrFileUtils.exists(outFile) == "file" then
        output = LrFileUtils.readFile(outFile)
        if not output or output == "" then
          local file = io.open(outFile, "rb")
          if file then
            output = file:read("*a")
            file:close()
          end
        end
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
    output = LrTasks.execute(cmd)
  end

  if type(output) ~= "string" or output == "" then
    if opts and opts.allowZeroFallback and LrFileUtils.exists(jpegPath) == "file" then
      return {
        shadowClipPx = 0,
        highlightClipPx = 0,
        shadowClipPct = 0,
        highlightClipPct = 0,
      }
    end
    return nil, "analyzer returned no output"
  end

  local line = output:match("{.-}") or output:match("[^\r\n]+")
  return parseJsonLine(line)
end

function ClippingClient.tempJpegPath(photoId)
  local name = string.format("preview_%s_%d.jpg", tostring(photoId), os.time())
  return LrPathUtils.child(Platform.tempDir(), name)
end

return ClippingClient
