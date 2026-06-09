-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"

local Platform = require("Core.Platform")

local M8SmokeReport = {}

function M8SmokeReport.resultPath()
  return LrPathUtils.child(Platform.tempDir(), "m8-smoke-result.json")
end

function M8SmokeReport.write(payload, triggerPath)
  local path = M8SmokeReport.resultPath()
  local lines = {
    string.format('"ok":%s', payload.ok and "true" or "false"),
    string.format('"count":%d', payload.count or 0),
    string.format('"processed":%d', payload.processed or 0),
    string.format('"skipped":%d', payload.skipped or 0),
    string.format('"dryRun":%s', payload.dryRun and "true" or "false"),
    string.format('"autoTone":%s', payload.autoTone and "true" or "false"),
    string.format('"schemaVersion2":%s', payload.schemaVersion2 and "true" or "false"),
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

function M8SmokeReport.validateResults(results, count)
  if #results ~= count then
    return false, string.format("expected %d results, got %d", count, #results)
  end
  for _, r in ipairs(results) do
    if not r.ok then
      return false, "photo failed: " .. tostring(r.id) .. " " .. tostring(r.error)
    end
    if not r.autoTone then
      return false, "autoTone not set for " .. tostring(r.id)
    end
    if r.schemaVersion ~= 2 then
      return false, "schemaVersion not 2 for " .. tostring(r.id)
    end
    if not r.medianBefore then
      return false, "medianLuma missing for " .. tostring(r.id)
    end
  end
  return true
end

return M8SmokeReport
