-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrFunctionContext = import "LrFunctionContext"
local LrDialogs = import "LrDialogs"
local LrPathUtils = import "LrPathUtils"
local LrTasks = import "LrTasks"

LrFunctionContext.postAsyncTaskWithContext("NoClip Auto M5 Smoke", function(context)
  LrDialogs.attachErrorDialogToFunctionContext(context)
  LrTasks.sleep(0.1)

  local LrApplication = import "LrApplication"
  local trigger = LrPathUtils.child(LrPathUtils.child(_PLUGIN.path, "smoke"), "m5-smoke.trigger")

  for _ = 1, 60 do
    local catalog = LrApplication.activeCatalog()
    if catalog then
      local ready = pcall(function()
        catalog:getAllPhotos()
      end)
      if ready then
        LrTasks.sleep(2)
        break
      end
    end
    LrTasks.sleep(2)
  end

  local Loader = dofile(LrPathUtils.child(_PLUGIN.path, "Core/Loader.lua"))
  Loader.setup(_PLUGIN.path)
  require("Core.BatchSmoke").runFromTrigger(trigger, true)
end)
