-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local function writeTextFile(path, text)
  local file = io.open(path, "w")
  if not file then
    return false, "could not open " .. tostring(path)
  end
  file:write(text)
  file:close()
  return true
end

local LrLogger = import "LrLogger"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"
local LrTasks = import "LrTasks"
local LrFunctionContext = import "LrFunctionContext"

local logger = LrLogger("NoClipAuto")
logger:enable("logfile")

NoClipAuto = {
  logger = logger,
  prefs = import "LrPrefs".prefsForPlugin(),
}

NoClipAuto.prefs.clipThresholdPct = NoClipAuto.prefs.clipThresholdPct or 0.05
NoClipAuto.prefs.performanceTier = NoClipAuto.prefs.performanceTier or "Auto"
NoClipAuto.prefs.dryRun = NoClipAuto.prefs.dryRun or false
NoClipAuto.prefs.maxTotalIterations = NoClipAuto.prefs.maxTotalIterations or 60
NoClipAuto.prefs.enableBalancePhase = NoClipAuto.prefs.enableBalancePhase or false
NoClipAuto.prefs.balanceTargetMedian = NoClipAuto.prefs.balanceTargetMedian or 0.45
NoClipAuto.prefs.balanceEttrMode = NoClipAuto.prefs.balanceEttrMode or false

logger:info("NoClip Auto plugin loaded")

local stamp = os.date("%Y-%m-%dT%H:%M:%S")
local smokeDir = LrPathUtils.child(_PLUGIN.path, "smoke")
LrFileUtils.createAllDirectories(smokeDir)

local ok, err = writeTextFile(LrPathUtils.child(smokeDir, "plugin-loaded.txt"), stamp)
if not ok then
  logger:error("Init marker failed: " .. tostring(err))
end

local tempDir = LrPathUtils.child(LrPathUtils.getStandardFilePath("temp"), "NoClipAuto")
LrFileUtils.createAllDirectories(tempDir)
writeTextFile(LrPathUtils.child(tempDir, "noclip-plugin-loaded.txt"), stamp)

local smokeTrigger = LrPathUtils.child(smokeDir, "m3-smoke.trigger")
if LrFileUtils.exists(smokeTrigger) == "file" then
  LrFunctionContext.postAsyncTaskWithContext("NoClip Auto M3 Smoke", function(context)
    local LrApplication = import "LrApplication"
    logger:info("M3 smoke trigger found; waiting for catalog")

    for _ = 1, 120 do
      if LrFileUtils.exists(smokeTrigger) ~= "file" then
        return
      end
      local catalog = LrApplication.activeCatalog()
      if catalog then
        local ready = pcall(function()
          catalog:getTargetPhotos()
        end)
        if ready then
          LrTasks.sleep(5)
          break
        end
      end
      LrTasks.sleep(2)
    end

    if LrFileUtils.exists(smokeTrigger) ~= "file" then
      return
    end

    logger:info("Running M3 smoke headless")
    local runner = dofile(LrPathUtils.child(_PLUGIN.path, "M3SmokeHeadless.lua"))
    runner.run(smokeTrigger, _PLUGIN.path)
  end)
end

local m5SmokeTrigger = LrPathUtils.child(smokeDir, "m5-smoke.trigger")
if LrFileUtils.exists(m5SmokeTrigger) == "file" then
  LrFunctionContext.postAsyncTaskWithContext("NoClip Auto M5 Smoke", function(context)
    local LrApplication = import "LrApplication"
    logger:info("M5 smoke trigger found; waiting for catalog")

    for _ = 1, 120 do
      if LrFileUtils.exists(m5SmokeTrigger) ~= "file" then
        return
      end
      local catalog = LrApplication.activeCatalog()
      if catalog then
        local ready = pcall(function()
          catalog:getAllPhotos()
        end)
        if ready then
          LrTasks.sleep(5)
          break
        end
      end
      LrTasks.sleep(2)
    end

    if LrFileUtils.exists(m5SmokeTrigger) ~= "file" then
      return
    end

    logger:info("Running M5 smoke bootstrap")
    local ok, err = pcall(function()
      local runner = dofile(LrPathUtils.child(_PLUGIN.path, "M5SmokeBootstrap.lua"))
      runner.run(m5SmokeTrigger, _PLUGIN.path)
    end)
    if not ok then
      logger:error("M5 smoke failed: " .. tostring(err))
      writeTextFile(
        LrPathUtils.child(tempDir, "m5-smoke-result.json"),
        string.format('{"ok":false,"error":"%s"}', tostring(err):gsub('"', "'"))
      )
    end
  end)
end

local m8SmokeTrigger = LrPathUtils.child(smokeDir, "m8-smoke.trigger")
if LrFileUtils.exists(m8SmokeTrigger) == "file" then
  LrFunctionContext.postAsyncTaskWithContext("NoClip Auto M8 Smoke", function(context)
    local LrApplication = import "LrApplication"
    logger:info("M8 smoke trigger found; waiting for catalog")

    for _ = 1, 120 do
      if LrFileUtils.exists(m8SmokeTrigger) ~= "file" then
        return
      end
      local catalog = LrApplication.activeCatalog()
      if catalog then
        local ready = pcall(function()
          catalog:getAllPhotos()
        end)
        if ready then
          LrTasks.sleep(5)
          break
        end
      end
      LrTasks.sleep(2)
    end

    if LrFileUtils.exists(m8SmokeTrigger) ~= "file" then
      return
    end

    logger:info("Running M8 smoke bootstrap")
    local ok, err = pcall(function()
      local runner = dofile(LrPathUtils.child(_PLUGIN.path, "M8SmokeBootstrap.lua"))
      runner.run(m8SmokeTrigger, _PLUGIN.path)
    end)
    if not ok then
      logger:error("M8 smoke failed: " .. tostring(err))
      writeTextFile(
        LrPathUtils.child(tempDir, "m8-smoke-result.json"),
        string.format('{"ok":false,"autoTone":false,"schemaVersion2":false,"error":"%s"}', tostring(err):gsub('"', "'"))
      )
    end
  end)
end
