-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrTasks = import "LrTasks"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"

local Platform = require("Core.Platform")
local Config = require("Core.Pipeline.Config")

local ClippingClient = {}
local analyzeSeq = 0

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
  return {
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
end

local function readTextFile(path)
  local output = LrFileUtils.readFile(path)
  if output and output ~= "" then
    return output
  end
  local file = io.open(path, "rb")
  if not file then
    return nil
  end
  output = file:read("*a")
  file:close()
  return output
end

local function isJpegFile(path)
  if LrFileUtils.exists(path) ~= "file" then
    return false
  end
  local raw = readTextFile(path)
  if not raw or #raw < 3 then
    return false
  end
  local b1, b2, b3 = raw:byte(1, 3)
  return b1 == 255 and b2 == 216 and b3 == 255
end

local function uniqueOutPath()
  analyzeSeq = analyzeSeq + 1
  return LrPathUtils.child(
    Platform.tempDir(),
    string.format("analyze-out-%d-%d.json", os.time(), analyzeSeq)
  )
end

local function runWindowsTask(fn)
  local state = { done = false, result = nil }
  LrTasks.startAsyncTask(function()
    state.result = fn()
    state.done = true
  end)
  local deadline = os.time() + 65
  while not state.done and os.time() < deadline do
    LrTasks.yield()
  end
  return state.result
end

local function analyzeWindows(analyzer, jpegPath)
  local stdoutCmd = string.format(
    'cmd /c "%s" --input "%s" --shadow-threshold %d --highlight-threshold %d',
    LrPathUtils.standardizePath(analyzer),
    LrPathUtils.standardizePath(jpegPath),
    Config.SHADOW_THRESHOLD,
    Config.HIGHLIGHT_THRESHOLD
  )
  local stdout = runWindowsTask(function()
    return LrTasks.execute(stdoutCmd)
  end)
  if type(stdout) == "string" and stdout:match('"shadow_clip_px"') then
    return stdout
  end

  local outFile = uniqueOutPath()
  local fileCmd = string.format(
    'cmd /c "%s" --input "%s" --output "%s" --shadow-threshold %d --highlight-threshold %d',
    LrPathUtils.standardizePath(analyzer),
    LrPathUtils.standardizePath(jpegPath),
    LrPathUtils.standardizePath(outFile),
    Config.SHADOW_THRESHOLD,
    Config.HIGHLIGHT_THRESHOLD
  )
  return runWindowsTask(function()
    LrTasks.execute(fileCmd)
    local deadline = os.time() + 60
    while os.time() < deadline do
      if LrFileUtils.exists(outFile) == "file" then
        local text = readTextFile(outFile)
        if text and text ~= "" then
          if LrFileUtils.exists(outFile) == "file" then
            LrFileUtils.delete(outFile)
          end
          return text
        end
      end
      LrTasks.sleep(0.1)
    end
    if LrFileUtils.exists(outFile) == "file" then
      LrFileUtils.delete(outFile)
    end
    return nil
  end)
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
  if LrFileUtils.exists(jpegPath) ~= "file" then
    return nil, "preview JPEG not found: " .. tostring(jpegPath)
  end
  if not isJpegFile(jpegPath) then
    return nil, "preview is not a valid JPEG: " .. tostring(jpegPath)
  end

  local output
  if WIN_ENV then
    output = analyzeWindows(analyzer, jpegPath)
  else
    local cmd = string.format(
      "%s --input %s --shadow-threshold %d --highlight-threshold %d",
      Platform.quotePath(analyzer),
      Platform.quotePath(jpegPath),
      Config.SHADOW_THRESHOLD,
      Config.HIGHLIGHT_THRESHOLD
    )
    output = LrTasks.execute(cmd)
  end

  if type(output) ~= "string" or output == "" then
    if opts and opts.allowZeroFallback then
      return {
        shadowClipPx = 0,
        highlightClipPx = 0,
        shadowClipPct = 0,
        highlightClipPct = 0,
        schemaVersion = 2,
        medianLuma = 0.5,
      }
    end
    return nil, "analyzer returned no output"
  end

  local line = output:match("{.-}") or output:match("[^\r\n]+")
  return parseJsonLine(line)
end

function ClippingClient.tempJpegPath(photoId)
  analyzeSeq = analyzeSeq + 1
  local name = string.format("preview_%s_%d_%d.jpg", tostring(photoId), os.time(), analyzeSeq)
  return LrPathUtils.child(Platform.tempDir(), name)
end

return ClippingClient
