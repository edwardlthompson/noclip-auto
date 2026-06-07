-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrTasks = import "LrTasks"

LrTasks.startAsyncTask(function()
  require("Core.SingleRunner").run()
end)
