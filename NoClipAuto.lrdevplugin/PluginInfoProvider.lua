-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrView = import "LrView"
local bind = LrView.bind

local function sectionsForTopOfDialog(f, propertyTable)
  return {
    {
      title = "NoClip Auto",
      synopsis = "Automatic highlight and shadow clipping recovery",
      f:column {
        spacing = f:control_spacing(),
        f:row {
          f:static_text { title = "Clip threshold (%):" },
          f:edit_field {
            value = bind("clipThresholdPct"),
            width_in_chars = 8,
            precision = 3,
          },
        },
        f:row {
          f:static_text { title = "Performance tier:" },
          f:popup_menu {
            value = bind("performanceTier"),
            items = {
              { title = "Auto", value = "Auto" },
              { title = "Low", value = "Low" },
              { title = "Balanced", value = "Balanced" },
              { title = "High", value = "High" },
            },
          },
        },
        f:row {
          f:static_text { title = "Dry run (log only, no apply):" },
          f:checkbox { value = bind("dryRun") },
        },
        f:row {
          f:static_text { title = "Max iterations per photo:" },
          f:edit_field {
            value = bind("maxTotalIterations"),
            width_in_chars = 6,
            integral = true,
          },
        },
      },
    },
  }
end

return {
  sectionsForTopOfDialog = sectionsForTopOfDialog,
}
