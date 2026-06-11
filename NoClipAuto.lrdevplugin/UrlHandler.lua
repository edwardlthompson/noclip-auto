-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrFunctionContext = import "LrFunctionContext"
local LrDialogs = import "LrDialogs"
local LrTasks = import "LrTasks"
local LrPathUtils = import "LrPathUtils"

return {
  URLHandler = function(url)
    url = url:gsub('^"(.*)"$', "%1")

    local isM3 = url:match("/m3%-smoke") or url:match("m3%-smoke")
    local isM5 = url:match("/m5%-smoke") or url:match("m5%-smoke")
    local isM8 = url:match("/m8%-smoke") or url:match("m8%-smoke")
    local isM9 = url:match("/m9%-smoke") or url:match("m9%-smoke")

    if isM3 then
      LrTasks.startAsyncTask(function()
        local trigger = LrPathUtils.child(LrPathUtils.child(_PLUGIN.path, "smoke"), "m3-smoke.trigger")
        local runner = dofile(LrPathUtils.child(_PLUGIN.path, "M3SmokeHeadless.lua"))
        runner.run(trigger, _PLUGIN.path)
      end)
      return
    end

    if isM5 then
      LrTasks.startAsyncTask(function()
        local Loader = dofile(LrPathUtils.child(_PLUGIN.path, "Core/Loader.lua"))
        Loader.setup(_PLUGIN.path)
        local trigger = LrPathUtils.child(LrPathUtils.child(_PLUGIN.path, "smoke"), "m5-smoke.trigger")
        require("Core.BatchSmoke").runFromTrigger(trigger)
      end)
      return
    end

    if isM8 then
      LrTasks.startAsyncTask(function()
        local Loader = dofile(LrPathUtils.child(_PLUGIN.path, "Core/Loader.lua"))
        Loader.setup(_PLUGIN.path)
        local trigger = LrPathUtils.child(LrPathUtils.child(_PLUGIN.path, "smoke"), "m8-smoke.trigger")
        require("Core.M8Smoke").runFromTrigger(trigger)
      end)
      return
    end

    if isM9 then
      LrFunctionContext.postAsyncTaskWithContext("NoClip Auto M9 Smoke URL", function(context)
        LrDialogs.attachErrorDialogToFunctionContext(context)
        local Loader = dofile(LrPathUtils.child(_PLUGIN.path, "Core/Loader.lua"))
        Loader.setup(_PLUGIN.path)
        local trigger = LrPathUtils.child(LrPathUtils.child(_PLUGIN.path, "smoke"), "m9-smoke.trigger")
        require("Core.M9Smoke").runFromTrigger(trigger)
      end)
    end
  end,
}
