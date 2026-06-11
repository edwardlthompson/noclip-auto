-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0
-- Init entry: sets package.path then runs Core.M9Smoke (Orchestrator dry-run with lens pre-pass).

local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"
local LrFunctionContext = import "LrFunctionContext"

local M9SmokeBootstrap = {}

local function tempDir()
  local dir = LrPathUtils.child(LrPathUtils.getStandardFilePath("temp"), "NoClipAuto")
  LrFileUtils.createAllDirectories(dir)
  return dir
end

local function writeFail(err, triggerPath)
  local path = LrPathUtils.child(tempDir(), "m9-smoke-result.json")
  local file = io.open(path, "w")
  if file then
    file:write(string.format(
      '{"ok":false,"autoTone":false,"schemaVersion2":false,"lensProfile":false,"error":"%s"}',
      tostring(err):gsub('"', "'")
    ))
    file:close()
  end
  if triggerPath and LrFileUtils.exists(triggerPath) == "file" then
    LrFileUtils.delete(triggerPath)
  end
end

function M9SmokeBootstrap.run(triggerPath, pluginPath)
  if not triggerPath or LrFileUtils.exists(triggerPath) ~= "file" then
    writeFail("trigger not found", triggerPath)
    return
  end

  LrFunctionContext.postAsyncTaskWithContext("NoClip Auto M9 batch", function()
    local Loader = dofile(LrPathUtils.child(pluginPath, "Core/Loader.lua"))
    Loader.setup(pluginPath)
    require("Core.M9Smoke").runFromTrigger(triggerPath, false)
  end)
end

return M9SmokeBootstrap
