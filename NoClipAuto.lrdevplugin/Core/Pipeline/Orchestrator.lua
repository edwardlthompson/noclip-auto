-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrApplication = import "LrApplication"

local Config = require("Core.Pipeline.Config")
local SettingsIO = require("Core.SettingsIO")
local PhaseRunner = require("Core.Pipeline.PhaseRunner")

local Orchestrator = {}

local function isErrorStatus(status)
  return type(status) == "string"
    and status ~= "done"
    and status ~= "phase_done"
    and status ~= "no_progress"
    and status ~= "phase_max"
    and status ~= "max_total"
end

function Orchestrator.processPhoto(photo, previewSize, dryRun)
  local catalog = LrApplication.activeCatalog()
  local initialSettings = SettingsIO.readToneSettings(photo)
  local totalIter = { count = 0 }
  local maxIter = Config.maxTotalIterations()

  local beforeClip, beforeErr = PhaseRunner.measure(photo, previewSize)
  if not beforeClip then
    return { ok = false, error = beforeErr }
  end

  if not Config.isClipped(beforeClip) then
    return {
      ok = true,
      skipped = true,
      reason = "already_clean",
      before = beforeClip,
      after = beforeClip,
      settings = initialSettings,
      iterations = 0,
    }
  end

  local settings = initialSettings
  local status
  local finished = false

  settings, totalIter, status = PhaseRunner.runPhase1(photo, settings, previewSize, totalIter, maxIter)
  if status == "done" then
    finished = true
  elseif isErrorStatus(status) then
    return { ok = false, error = status }
  end

  if not finished then
    settings, totalIter, status = PhaseRunner.runPhase2(photo, settings, previewSize, totalIter, maxIter)
    if status == "done" then
      finished = true
    elseif isErrorStatus(status) then
      return { ok = false, error = status }
    end
  end

  if not finished then
    settings, totalIter, status = PhaseRunner.runPhase3(photo, settings, previewSize, totalIter, maxIter)
    if isErrorStatus(status) then
      return { ok = false, error = status }
    end
  end

  local afterClip, afterErr = PhaseRunner.measure(photo, previewSize)
  if not afterClip then
    return { ok = false, error = afterErr }
  end

  if not dryRun then
    catalog:withWriteAccessDo("NoClip Auto", function()
      photo:createDevelopSnapshot("NoClip Auto (before)")
      photo:applyDevelopSettings(settings)
    end, { timeout = 30 })
  end

  return {
    ok = true,
    skipped = false,
    before = beforeClip,
    after = afterClip,
    settings = settings,
    iterations = totalIter.count,
    dryRun = dryRun,
  }
end

return Orchestrator
