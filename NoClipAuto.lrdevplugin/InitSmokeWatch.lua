-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0
-- Init-safe smoke trigger watcher (dofile from Init.lua).

local LrApplication = import "LrApplication"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"
local LrTasks = import "LrTasks"
local LrFunctionContext = import "LrFunctionContext"

local InitSmokeWatch = {}

local function writeTextFile(path, text)
  local file = io.open(path, "w")
  if not file then
    return false
  end
  file:write(text)
  file:close()
  return true
end

local function waitForCatalog(triggerPath, catalogReadyFn)
  for _ = 1, 120 do
    if LrFileUtils.exists(triggerPath) ~= "file" then
      return false
    end
    local catalog = LrApplication.activeCatalog()
    if catalog then
      local ready = pcall(catalogReadyFn, catalog)
      if ready then
        LrTasks.sleep(5)
        return LrFileUtils.exists(triggerPath) == "file"
      end
    end
    LrTasks.sleep(2)
  end
  return LrFileUtils.exists(triggerPath) == "file"
end

local function runBootstrap(triggerPath, pluginPath, bootstrapName, failPath, failJson)
  local ok, err = pcall(function()
    local runner = dofile(LrPathUtils.child(pluginPath, bootstrapName))
    runner.run(triggerPath, pluginPath)
  end)
  if not ok then
    NoClipAuto.logger:error(bootstrapName .. " failed: " .. tostring(err))
    writeTextFile(failPath, string.format(failJson, tostring(err):gsub('"', "'")))
    return
  end
end

function InitSmokeWatch.start(pluginPath, smokeDir, tempDir)
  local m3 = LrPathUtils.child(smokeDir, "m3-smoke.trigger")
  if LrFileUtils.exists(m3) == "file" then
    LrFunctionContext.postAsyncTaskWithContext("NoClip Auto M3 Smoke", function()
      NoClipAuto.logger:info("M3 smoke trigger found; waiting for catalog")
      if not waitForCatalog(m3, function(catalog) catalog:getTargetPhotos() end) then
        return
      end
      NoClipAuto.logger:info("Running M3 smoke headless")
      dofile(LrPathUtils.child(pluginPath, "M3SmokeHeadless.lua")).run(m3, pluginPath)
    end)
  end

  local bootstraps = {
    { trigger = "m5-smoke.trigger", label = "M5", bootstrap = "M5SmokeBootstrap.lua",
      fail = "m5-smoke-result.json", json = '{"ok":false,"error":"%s"}' },
    { trigger = "m8-smoke.trigger", label = "M8", bootstrap = "M8SmokeBootstrap.lua",
      fail = "m8-smoke-result.json", json = '{"ok":false,"autoTone":false,"schemaVersion2":false,"error":"%s"}' },
    { trigger = "m9-smoke.trigger", label = "M9", bootstrap = "M9SmokeBootstrap.lua",
      fail = "m9-smoke-result.json", json = '{"ok":false,"autoTone":false,"schemaVersion2":false,"lensProfile":false,"error":"%s"}' },
  }

  for _, cfg in ipairs(bootstraps) do
    local triggerPath = LrPathUtils.child(smokeDir, cfg.trigger)
    if LrFileUtils.exists(triggerPath) == "file" then
      LrFunctionContext.postAsyncTaskWithContext("NoClip Auto " .. cfg.label .. " Smoke", function()
        NoClipAuto.logger:info(cfg.label .. " smoke trigger found; waiting for catalog")
        if not waitForCatalog(triggerPath, function(catalog) catalog:getAllPhotos() end) then
          return
        end
        NoClipAuto.logger:info("Running " .. cfg.label .. " smoke bootstrap")
        runBootstrap(
          triggerPath,
          pluginPath,
          cfg.bootstrap,
          LrPathUtils.child(tempDir, cfg.fail),
          cfg.json
        )
      end)
    end
  end
end

return InitSmokeWatch
