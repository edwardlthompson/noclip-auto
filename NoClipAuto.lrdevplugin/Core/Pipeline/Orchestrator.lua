-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local Orchestrator = {}

local LrApplication = import "LrApplication"

local Config = require("Core.Pipeline.Config")
local SettingsIO = require("Core.SettingsIO")
local LensProfile = require("Core.Pipeline.LensProfile")
local AutoTone = require("Core.Pipeline.AutoTone")
local PhaseRunner = require("Core.Pipeline.PhaseRunner")
local PhaseBalance = require("Core.Pipeline.PhaseBalance")

local function isErrorStatus(status)
  return type(status) == "string"
    and status ~= "done"
    and status ~= "phase_done"
    and status ~= "no_progress"
    and status ~= "phase_max"
    and status ~= "max_total"
end

local function restoreDryRun(catalog, photo, ctx)
  SettingsIO.restoreInitial(
    catalog,
    photo,
    ctx.initialSettings,
    ctx.initialLensSettings,
    "NoClip Auto (dry run restore)"
  )
end

local function notifyProgress(ctx, caption, iterFraction)
  if ctx.onProgress then
    ctx.onProgress(caption, iterFraction or 0)
  end
end

local function failWith(catalog, photo, ctx, status, lensResult)
  if ctx.dryRun then
    restoreDryRun(catalog, photo, ctx)
  end
  return { ok = false, error = status, lensProfile = lensResult }
end

local function snapshotsEnabled()
  return NoClipAuto.prefs and NoClipAuto.prefs.enableDevelopSnapshots == true
end

function Orchestrator.processPhoto(photo, previewSize, dryRun, opts)
  opts = opts or {}
  local catalog = LrApplication.activeCatalog()
  local initialSettings = SettingsIO.readToneSettings(photo)
  local initialLensSettings = SettingsIO.readLensSettings(photo)
  local totalIter = { count = 0 }
  local maxIter = Config.maxTotalIterations()
  local ctx = {
    catalog = catalog,
    photo = photo,
    dryRun = dryRun,
    initialSettings = initialSettings,
    initialLensSettings = initialLensSettings,
    maxIter = maxIter,
    onProgress = opts.onProgress,
  }

  notifyProgress(ctx, "Lens profile", 0)

  if not dryRun and snapshotsEnabled() then
    catalog:withWriteAccessDo("NoClip Auto", function()
      photo:createDevelopSnapshot("NoClip Auto (before)")
    end, { timeout = 30 })
  end

  local lensResult = { applied = false, hadProfile = false }
  if LensProfile.isEnabled() then
    lensResult = LensProfile.apply(catalog, photo)
  end

  notifyProgress(ctx, "Auto Tone", 0.05)

  local settings = AutoTone.apply(catalog, photo)
  if not settings then
    return failWith(catalog, photo, ctx, "auto_tone_failed", lensResult)
  end

  notifyProgress(ctx, "Measuring clip", 0.1)

  local beforeClip, beforeErr = PhaseRunner.measure(photo, previewSize)
  if not beforeClip then
    return failWith(catalog, photo, ctx, beforeErr, lensResult)
  end

  local status
  local finished = not Config.isClipped(beforeClip)

  if not finished then
    notifyProgress(ctx, "Phase 1 — Exposure", 0.15)
    settings, totalIter, status = PhaseRunner.runPhase1(photo, settings, previewSize, totalIter, maxIter, ctx)
    if status == "done" then
      finished = true
    elseif isErrorStatus(status) then
      return failWith(catalog, photo, ctx, status, lensResult)
    end
  end

  if not finished then
    notifyProgress(ctx, "Phase 2 — Whites/Blacks", 0.45)
    settings, totalIter, status = PhaseRunner.runPhase2(photo, settings, previewSize, totalIter, maxIter, ctx)
    if status == "done" then
      finished = true
    elseif isErrorStatus(status) then
      return failWith(catalog, photo, ctx, status, lensResult)
    end
  end

  if not finished then
    notifyProgress(ctx, "Phase 3 — Highlights/Shadows", 0.7)
    settings, totalIter, status = PhaseRunner.runPhase3(photo, settings, previewSize, totalIter, maxIter, ctx)
    if status == "done" then
      finished = true
    elseif isErrorStatus(status) then
      return failWith(catalog, photo, ctx, status, lensResult)
    end
  end

  if PhaseBalance.isEnabled() then
    notifyProgress(ctx, "Balance", 0.85)
    local clipCheck, clipErr = PhaseRunner.measure(photo, previewSize)
    if not clipCheck then
      return failWith(catalog, photo, ctx, clipErr, lensResult)
    end
    if not Config.isClipped(clipCheck) then
      settings, totalIter, status = PhaseBalance.runPhase(photo, settings, previewSize, totalIter, maxIter, ctx, PhaseRunner)
      if isErrorStatus(status) then
        return failWith(catalog, photo, ctx, status, lensResult)
      end
    end
  end

  notifyProgress(ctx, "Final measure", 0.95)

  local afterClip, afterErr = PhaseRunner.measure(photo, previewSize)
  if not afterClip then
    return failWith(catalog, photo, ctx, afterErr, lensResult)
  end

  local sliderDelta = SettingsIO.sliderSummary(initialSettings, settings)

  if dryRun then
    restoreDryRun(catalog, photo, ctx)
  else
    SettingsIO.syncToPhoto(catalog, photo, settings, "NoClip Auto (final)")
    local readBack = SettingsIO.readToneSettings(photo)
    sliderDelta = SettingsIO.sliderSummary(initialSettings, readBack)
    NoClipAuto.logger:info(string.format(
      "Final photo=%s exposure %.2f -> %.2f iterations=%d",
      tostring(photo.localIdentifier),
      sliderDelta.Exposure2012.before,
      sliderDelta.Exposure2012.after,
      totalIter.count
    ))
  end

  notifyProgress(ctx, "Done", 1)

  return {
    ok = true,
    skipped = finished and not Config.isClipped(beforeClip),
    reason = finished and "already_clean_after_auto_tone" or nil,
    autoTone = true,
    lensProfile = lensResult,
    before = beforeClip,
    after = afterClip,
    settings = settings,
    iterations = totalIter.count,
    dryRun = dryRun,
    sliderDelta = sliderDelta,
  }
end

return Orchestrator
