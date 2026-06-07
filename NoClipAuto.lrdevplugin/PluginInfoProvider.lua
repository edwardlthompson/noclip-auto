-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrView = import "LrView"
local LrHttp = import "LrHttp"
local bind = LrView.bind

local About = require("Core.About")

local function openUrl(url)
  LrHttp.openUrlInBrowser(url)
end

local function sectionsForTopOfDialog(f, propertyTable)
  return {
    {
      title = "About",
      synopsis = "Version, release notes, and project links",
      f:column {
        spacing = f:control_spacing(),
        f:static_text {
          title = "Version " .. About.versionString(),
          font = "<system/bold>",
        },
        f:static_text {
          title = "Release notes:",
          font = "<system/small/bold>",
        },
        f:static_text {
          title = About.releaseNotesText(),
          width_in_chars = 60,
          height_in_lines = 4,
        },
        f:row {
          spacing = f:control_spacing(),
          f:push_button {
            title = "Changelog",
            action = function() openUrl(About.CHANGELOG_URL) end,
          },
          f:push_button {
            title = "GitHub Project",
            action = function() openUrl(About.GITHUB_URL) end,
          },
        },
        f:static_text {
          title = "NoClip Auto is free and open source (Apache-2.0). If it saves you time, consider a donation to support development.",
          width_in_chars = 60,
          height_in_lines = 3,
        },
        f:push_button {
          title = "Donate via Venmo",
          action = function() openUrl(About.VENMO_URL) end,
        },
      },
    },
    {
      title = "Settings",
      synopsis = "Clip threshold, performance, and run options",
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
