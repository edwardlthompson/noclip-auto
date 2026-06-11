-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrTasks = import "LrTasks"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"
local LrSystemInfo = import "LrSystemInfo"

local Platform = require("Core.Platform")
local Config = require("Core.Pipeline.Config")

local PerformanceTier = {}

local TIERS = {
  Fast = { previewSize = 384, yieldEvery = 3, overlap = true },
  Low = { previewSize = 512, yieldEvery = 1, overlap = false },
  Balanced = { previewSize = 640, yieldEvery = 4, overlap = true },
  High = { previewSize = 1024, yieldEvery = 10, overlap = true },
}

local function detectTier()
  local cpus = LrSystemInfo.numCPUs() or 4
  local memGB = (LrSystemInfo.memSize() or 8 * 1024 * 1024 * 1024) / (1024 * 1024 * 1024)
  if cpus >= 8 and memGB >= 16 then
    return "Fast"
  end
  if cpus <= 4 or memGB <= 8 then
    return "Low"
  end
  return "Balanced"
end

function PerformanceTier.current()
  local pref = NoClipAuto.prefs.performanceTier or "Auto"
  local name = pref
  if pref == "Auto" then
    name = detectTier()
  end
  local tier = TIERS[name] or TIERS.Balanced
  return {
    name = name,
    previewSize = tier.previewSize,
    yieldEvery = tier.yieldEvery,
    overlap = tier.overlap,
  }
end

function PerformanceTier.maybeYield(photoIndex, tier)
  if photoIndex % tier.yieldEvery == 0 then
    LrTasks.yield()
  end
end

return PerformanceTier
