-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrFunctionContext = import "LrFunctionContext"
local LrDialogs = import "LrDialogs"
local LrPathUtils = import "LrPathUtils"
local LrTasks = import "LrTasks"

LrFunctionContext.postAsyncTaskWithContext("NoClip Auto Develop", function(context)
  LrDialogs.attachErrorDialogToFunctionContext(context)
  LrTasks.sleep(0.1)

  local Loader = dofile(LrPathUtils.child(_PLUGIN.path, "Core/Loader.lua"))
  Loader.setup(_PLUGIN.path)
  require("Core.SingleRunner").run(context)
end)
