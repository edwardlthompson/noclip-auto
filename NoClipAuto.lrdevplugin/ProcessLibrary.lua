-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrTasks = import "LrTasks"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"

LrTasks.startAsyncTask(function()
  local trigger = LrPathUtils.child(LrPathUtils.child(_PLUGIN.path, "smoke"), "m3-smoke.trigger")
  if LrFileUtils.exists(trigger) == "file" then
    require("Core.PreviewSmoke").runFromTrigger(trigger)
    return
  end
  require("Core.BatchRunner").run()
end)
