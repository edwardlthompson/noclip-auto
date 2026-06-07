-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

return {
  LrSdkVersion = 6.0,
  LrSdkMinimumVersion = 6.0,
  LrToolkitIdentifier = "com.noclipauto.lightroom",
  LrPluginName = "NoClip Auto",
  LrPluginInfoUrl = "https://github.com/edwardlthompson/noclip-auto",

  LrLibraryMenuItems = {
    { title = "NoClip Auto — Selected Photos", file = "ProcessLibrary.lua" },
  },

  LrExportMenuItems = {
    { title = "NoClip Auto — Selected Photos", file = "ProcessLibrary.lua" },
  },

  LrDevelopMenuItems = {
    { title = "NoClip Auto — Active Photo", file = "ProcessDevelop.lua" },
  },

  LrPluginInfoProvider = "PluginInfoProvider.lua",
  VERSION = { major = 0, minor = 1, revision = 0, build = 0 },
}
