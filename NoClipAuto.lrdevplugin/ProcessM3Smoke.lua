-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrFunctionContext = import "LrFunctionContext"
local LrDialogs = import "LrDialogs"
local LrPathUtils = import "LrPathUtils"
local LrTasks = import "LrTasks"

LrFunctionContext.postAsyncTaskWithContext("NoClip Auto M3 Smoke", function(context)
  LrDialogs.attachErrorDialogToFunctionContext(context)
  LrTasks.sleep(0.1)

  local trigger = LrPathUtils.child(LrPathUtils.child(_PLUGIN.path, "smoke"), "m3-smoke.trigger")
  local runner = dofile(LrPathUtils.child(_PLUGIN.path, "M3SmokeHeadless.lua"))
  runner.run(trigger, _PLUGIN.path, true)
end)
