-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrLogger = import "LrLogger"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"

local logger = LrLogger("NoClipAuto")
logger:enable("logfile")

NoClipAuto = {
  logger = logger,
}

local Prefs = dofile(LrPathUtils.child(_PLUGIN.path, "Core/Prefs.lua"))
Prefs.syncToGlobals()

logger:info("NoClip Auto plugin loaded")

local stamp = os.date("%Y-%m-%dT%H:%M:%S")
local smokeDir = LrPathUtils.child(_PLUGIN.path, "smoke")
LrFileUtils.createAllDirectories(smokeDir)

local function writeTextFile(path, text)
  local file = io.open(path, "w")
  if not file then
    return false, "could not open " .. tostring(path)
  end
  file:write(text)
  file:close()
  return true
end

local ok, err = writeTextFile(LrPathUtils.child(smokeDir, "plugin-loaded.txt"), stamp)
if not ok then
  logger:error("Init marker failed: " .. tostring(err))
end

local tempDir = LrPathUtils.child(LrPathUtils.getStandardFilePath("temp"), "NoClipAuto")
LrFileUtils.createAllDirectories(tempDir)
writeTextFile(LrPathUtils.child(tempDir, "noclip-plugin-loaded.txt"), stamp)

dofile(LrPathUtils.child(_PLUGIN.path, "InitSmokeWatch.lua")).start(_PLUGIN.path, smokeDir, tempDir)
