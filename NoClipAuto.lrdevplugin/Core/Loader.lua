-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0
-- Plugin module loader — LR native require cannot load Core/* from the toolkit.

local Loader = {}

local function pathPrefix(pluginPath)
  return pluginPath .. "/?.lua;"
    .. pluginPath .. "/Core/?.lua;"
    .. pluginPath .. "/Core/Pipeline/?.lua;"
end

local function moduleFile(pluginPath, name)
  return pluginPath .. "/" .. name:gsub("%.", "/") .. ".lua"
end

local function installRequire(pluginPath)
  require = function(name)
    if package.loaded[name] ~= nil then
      return package.loaded[name]
    end
    if package.preload[name] then
      package.loaded[name] = package.preload[name]()
      return package.loaded[name]
    end
    local path = moduleFile(pluginPath, name)
    local probe = io.open(path, "r")
    if not probe then
      error("module '" .. name .. "' not found: " .. path)
    end
    probe:close()
    local mod = dofile(path)
    package.loaded[name] = mod ~= nil and mod or true
    return mod
  end
end

function Loader.setup(pluginPath)
  local prefix = pathPrefix(pluginPath)
  if not package then
    package = { path = prefix, loaded = {}, preload = {} }
  else
    package.path = prefix .. package.path
  end
  installRequire(pluginPath)
  return true
end

return Loader
