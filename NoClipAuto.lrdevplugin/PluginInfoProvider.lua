-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrView = import "LrView"
local LrHttp = import "LrHttp"
local LrPathUtils = import "LrPathUtils"
local bind = LrView.bind

local About = dofile(LrPathUtils.child(_PLUGIN.path, "Core/About.lua"))
local Prefs = dofile(LrPathUtils.child(_PLUGIN.path, "Core/Prefs.lua"))
local SettingsUI = dofile(LrPathUtils.child(_PLUGIN.path, "Core/SettingsUI.lua"))

local function openUrl(url)
  LrHttp.openUrlInBrowser(url)
end

local function startDialog(propertyTable)
  Prefs.loadToPropertyTable(propertyTable)
end

local function endDialog(propertyTable, why)
  if why == "ok" then
    Prefs.saveFromPropertyTable(propertyTable)
  end
end

local function sectionsForTopOfDialog(f, propertyTable)
  Prefs.loadToPropertyTable(propertyTable)
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
          title = About.releaseNotesText(),
          width_in_chars = 60,
          height_in_lines = 4,
          font = "<system/small>",
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
        f:push_button {
          title = "Donate via Venmo",
          action = function() openUrl(About.VENMO_URL) end,
        },
      },
    },
    {
      title = "Settings",
      synopsis = "Clip threshold, performance, and run options",
      SettingsUI.buildSettingsSection(f, propertyTable, function()
        Prefs.applyDefaultsToPropertyTable(propertyTable)
        Prefs.saveFromPropertyTable(propertyTable)
      end),
    },
  }
end

return {
  startDialog = startDialog,
  endDialog = endDialog,
  sectionsForTopOfDialog = sectionsForTopOfDialog,
}
