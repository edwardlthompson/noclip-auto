-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"

local Platform = {}

function Platform.isWindows()
  return WIN_ENV == true
end

function Platform.isMac()
  return MAC_ENV == true
end

function Platform.analyzerPath(pluginDir)
  if WIN_ENV then
    return LrPathUtils.child(pluginDir, "bin/win-x64/noclip-analyze.exe")
  end
  local arm = LrPathUtils.child(pluginDir, "bin/macos-arm64/noclip-analyze")
  local x64 = LrPathUtils.child(pluginDir, "bin/macos-x64/noclip-analyze")
  if LrFileUtils.exists(arm) == "file" then
    return arm
  end
  return x64
end

function Platform.tempDir()
  local base = LrPathUtils.getStandardFilePath("temp")
  local dir = LrPathUtils.child(base, "NoClipAuto")
  LrFileUtils.createAllDirectories(dir)
  return dir
end

function Platform.logDir()
  local dir = LrPathUtils.child(Platform.tempDir(), "logs")
  LrFileUtils.createAllDirectories(dir)
  return dir
end

function Platform.quotePath(path)
  path = LrPathUtils.standardizePath(path)
  if WIN_ENV then
    return string.format('"%s"', path)
  end
  return string.format("'%s'", path)
end

function Platform.modulesInstallHint()
  if WIN_ENV then
    return "%APPDATA%\\Adobe\\Lightroom\\Modules\\"
  end
  return "~/Library/Application Support/Adobe/Lightroom/Modules/"
end

function Platform.pluginDir()
  return _PLUGIN.path
end

return Platform
