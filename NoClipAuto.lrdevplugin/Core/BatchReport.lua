-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrPathUtils = import "LrPathUtils"

local Platform = require("Core.Platform")

local BatchReport = {}

function BatchReport.resultEntry(photo, result)
  return {
    id = photo.localIdentifier,
    ok = result.ok,
    skipped = result.skipped,
    iterations = result.iterations or 0,
    shadowBefore = result.before and result.before.shadowClipPct or 0,
    highlightBefore = result.before and result.before.highlightClipPct or 0,
    shadowAfter = result.after and result.after.shadowClipPct or 0,
    highlightAfter = result.after and result.after.highlightClipPct or 0,
    autoTone = result.autoTone == true,
    schemaVersion = result.before and result.before.schemaVersion,
    medianBefore = result.before and result.before.medianLuma,
    medianAfter = result.after and result.after.medianLuma,
    error = result.error,
  }
end

function BatchReport.summarize(results)
  local processed, skipped = 0, 0
  for _, r in ipairs(results) do
    if r.skipped then
      skipped = skipped + 1
    else
      processed = processed + 1
    end
  end
  return processed, skipped
end

function BatchReport.writeReport(results, meta)
  local reportPath = LrPathUtils.child(Platform.tempDir(), "NoClipAuto-last-run.json")
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

  if meta and meta.dryRun then
    local logPath = LrPathUtils.child(Platform.tempDir(), "NoClipAuto-dry-run.log")
    local logLines = {
      string.format("dryRun=true tier=%s count=%d", tostring(meta.tier or ""), #results),
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
  end

  return reportPath
end

function BatchReport.smokeResultPath()
  return LrPathUtils.child(Platform.tempDir(), "m5-smoke-result.json")
end

function BatchReport.writeSmokeResult(payload, triggerPath)
  local LrFileUtils = import "LrFileUtils"
  local path = BatchReport.smokeResultPath()
  if LrFileUtils.exists(path) == "file" then
    local existing = LrFileUtils.readFile(path)
    if existing and existing:match('"ok"%s*:%s*true') then
      return
    end
  end

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

return BatchReport
