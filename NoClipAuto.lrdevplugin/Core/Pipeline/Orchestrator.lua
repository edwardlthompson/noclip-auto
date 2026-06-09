-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrApplication = import "LrApplication"

local Config = require("Core.Pipeline.Config")
local SettingsIO = require("Core.SettingsIO")
local AutoTone = require("Core.Pipeline.AutoTone")
local PhaseRunner = require("Core.Pipeline.PhaseRunner")
local PhaseBalance = require("Core.Pipeline.PhaseBalance")

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
  local ctx = {
    catalog = catalog,
    photo = photo,
    dryRun = dryRun,
    initialSettings = initialSettings,
  }

  if not dryRun then
    catalog:withWriteAccessDo("NoClip Auto", function()
      photo:createDevelopSnapshot("NoClip Auto (before)")
    end, { timeout = 30 })
  end

  local settings = AutoTone.apply(catalog, photo)
  if not settings then
    return { ok = false, error = "auto_tone_failed" }
  end

  if not dryRun then
    catalog:withWriteAccessDo("NoClip Auto", function()
      photo:createDevelopSnapshot("NoClip Auto (auto tone)")
    end, { timeout = 30 })
  end

  local beforeClip, beforeErr = PhaseRunner.measure(photo, previewSize)
  if not beforeClip then
    return { ok = false, error = beforeErr }
  end

  local status
  local finished = not Config.isClipped(beforeClip)

  if not finished then
    settings, totalIter, status = PhaseRunner.runPhase1(photo, settings, previewSize, totalIter, maxIter, ctx)
    if status == "done" then
      finished = true
    elseif isErrorStatus(status) then
      if dryRun then
        SettingsIO.syncToPhoto(catalog, photo, initialSettings, "NoClip Auto (dry run restore)")
      end
      return { ok = false, error = status }
    end
  end

  if not finished then
    settings, totalIter, status = PhaseRunner.runPhase2(photo, settings, previewSize, totalIter, maxIter, ctx)
    if status == "done" then
      finished = true
    elseif isErrorStatus(status) then
      if dryRun then
        SettingsIO.syncToPhoto(catalog, photo, initialSettings, "NoClip Auto (dry run restore)")
      end
      return { ok = false, error = status }
    end
  end

  if not finished then
    settings, totalIter, status = PhaseRunner.runPhase3(photo, settings, previewSize, totalIter, maxIter, ctx)
    if status == "done" then
      finished = true
    elseif isErrorStatus(status) then
      if dryRun then
        SettingsIO.syncToPhoto(catalog, photo, initialSettings, "NoClip Auto (dry run restore)")
      end
      return { ok = false, error = status }
    end
  end

  if PhaseBalance.isEnabled() then
    local clipCheck, clipErr = PhaseRunner.measure(photo, previewSize)
    if not clipCheck then
      if dryRun then
        SettingsIO.syncToPhoto(catalog, photo, initialSettings, "NoClip Auto (dry run restore)")
      end
      return { ok = false, error = clipErr }
    end
    if not Config.isClipped(clipCheck) then
      settings, totalIter, status = PhaseBalance.runPhase(photo, settings, previewSize, totalIter, maxIter, ctx, PhaseRunner)
      if isErrorStatus(status) then
        if dryRun then
          SettingsIO.syncToPhoto(catalog, photo, initialSettings, "NoClip Auto (dry run restore)")
        end
        return { ok = false, error = status }
      end
    end
  end

  local afterClip, afterErr = PhaseRunner.measure(photo, previewSize)
  if not afterClip then
    if dryRun then
      SettingsIO.syncToPhoto(catalog, photo, initialSettings, "NoClip Auto (dry run restore)")
    end
    return { ok = false, error = afterErr }
  end

  if dryRun then
    SettingsIO.syncToPhoto(catalog, photo, initialSettings, "NoClip Auto (dry run restore)")
  end

  return {
    ok = true,
    skipped = finished and not Config.isClipped(beforeClip),
    reason = finished and "already_clean_after_auto_tone" or nil,
    autoTone = true,
    before = beforeClip,
    after = afterClip,
    settings = settings,
    iterations = totalIter.count,
    dryRun = dryRun,
  }
end

return Orchestrator
