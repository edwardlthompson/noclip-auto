-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0
-- Init entry: sets package.path then runs Core.M8Smoke (full Orchestrator dry-run).

local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"

local M8SmokeBootstrap = {}

local function tempDir()
  local dir = LrPathUtils.child(LrPathUtils.getStandardFilePath("temp"), "NoClipAuto")
  LrFileUtils.createAllDirectories(dir)
  return dir
end

local function writeFail(err, triggerPath)
  local path = LrPathUtils.child(tempDir(), "m8-smoke-result.json")
  local file = io.open(path, "w")
  if file then
    file:write(string.format(
      '{"ok":false,"autoTone":false,"schemaVersion2":false,"error":"%s"}',
      tostring(err):gsub('"', "'")
    ))
    file:close()
  end
  if triggerPath and LrFileUtils.exists(triggerPath) == "file" then
    LrFileUtils.delete(triggerPath)
  end
end

local function setupPackagePath(pluginPath)
  package.path = pluginPath .. "/?.lua;"
    .. pluginPath .. "/Core/?.lua;"
    .. pluginPath .. "/Core/Pipeline/?.lua;"
    .. package.path
end

function M8SmokeBootstrap.run(triggerPath, pluginPath)
  if not triggerPath or LrFileUtils.exists(triggerPath) ~= "file" then
    writeFail("trigger not found", triggerPath)
    return
  end

  setupPackagePath(pluginPath)
  local ok, err = pcall(function()
    require("Core.M8Smoke").runFromTrigger(triggerPath, false)
  end)
  if not ok then
    writeFail(err, triggerPath)
  end
end

return M8SmokeBootstrap
