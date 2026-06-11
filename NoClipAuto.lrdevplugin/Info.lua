-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

return {
  LrSdkVersion = 6.0,
  LrSdkMinimumVersion = 6.0,
  LrToolkitIdentifier = "com.noclipauto.lightroom",
  LrPluginName = "NoClip Auto",
  LrPluginInfoUrl = "https://github.com/edwardlthompson/noclip-auto",
  LrInitPlugin = "Init.lua",
  LrForceInitPlugin = true,

  LrLibraryMenuItems = {
    { title = "NoClip Auto - Selected Photos", file = "ProcessLibrary.lua" },
    { title = "NoClip Auto - Active Photo", file = "ProcessDevelop.lua" },
  },

  LrExportMenuItems = {
    { title = "NoClip Auto - Selected Photos", file = "ProcessLibrary.lua" },
    { title = "NoClip Auto - Active Photo (File)", file = "ProcessDevelop.lua" },
  },

  LrPluginInfoProvider = "PluginInfoProvider.lua",
  URLHandler = "UrlHandler.lua",
  VERSION = { major = 1, minor = 3, revision = 7, build = 0 },
}
