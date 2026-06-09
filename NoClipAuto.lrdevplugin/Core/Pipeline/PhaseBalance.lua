-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local Config = require("Core.Pipeline.Config")
local SettingsIO = require("Core.SettingsIO")

local PhaseBalance = {}

local PARAMETRIC = {
  shadows = "ParametricShadows",
  darks = "ParametricDarks",
  lights = "ParametricLights",
  highlights = "ParametricHighlights",
}

function PhaseBalance.isEnabled()
  return NoClipAuto.prefs.enableBalancePhase == true
end

function PhaseBalance.targetMedian()
  if NoClipAuto.prefs.balanceEttrMode == true then
    return 0.55
  end
  return NoClipAuto.prefs.balanceTargetMedian or 0.45
end

function PhaseBalance.adjust(settings, clipResult)
  local median = clipResult.medianLuma
  if not median then
    return settings, {}, true
  end

  local target = PhaseBalance.targetMedian()
  local deltas = {}
  local done = true

  if math.abs(median - target) >= 0.02 then
    local ratio = target / math.max(median, 0.01)
    local evDelta = math.log(ratio) / math.log(2) * 0.35
    evDelta = math.max(-1.0, math.min(1.0, evDelta))
    if math.abs(evDelta) >= 0.02 then
      settings, deltas[Config.SLIDER_KEYS.exposure] = SettingsIO.applyDelta(
        settings,
        Config.SLIDER_KEYS.exposure,
        evDelta,
        -5,
        5
      )
      done = false
    end
  end

  local p05 = clipResult.p05Luma
  local p95 = clipResult.p95Luma
  if p05 and p95 then
    local span = p95 - p05
    if span < 0.55 and span > 0.01 then
      local stretch = (0.65 - span) * 40
      stretch = math.max(0, math.min(25, stretch))
      if stretch >= 1 then
        settings, deltas[PARAMETRIC.darks] = SettingsIO.applyDelta(
          settings,
          PARAMETRIC.darks,
          -stretch,
          -100,
          100
        )
        settings, deltas[PARAMETRIC.lights] = SettingsIO.applyDelta(
          settings,
          PARAMETRIC.lights,
          stretch,
          -100,
          100
        )
        done = false
      end
    end
  end

  return settings, deltas, done
end

function PhaseBalance.runPhase(photo, settings, previewSize, totalIter, maxIter, ctx, runner)
  for i = 1, Config.MAX_PHASE3_ITER do
    if totalIter.count >= maxIter then
      return settings, totalIter, "max_total"
    end

    local clipResult, err = runner.measure(photo, previewSize)
    if not clipResult then
      return settings, totalIter, err
    end

    if Config.isClipped(clipResult) then
      return settings, totalIter, "phase_done"
    end

    local prevSettings = settings
    local newSettings, deltas, phaseDone = PhaseBalance.adjust(settings, clipResult)
    runner.logIteration(photo.localIdentifier, "balance", i, clipResult, deltas)
    settings = newSettings

    if phaseDone then
      return settings, totalIter, "phase_done"
    end

    runner.syncSettings(settings, ctx)
    totalIter.count = totalIter.count + 1

    local verifyClip, verifyErr = runner.measure(photo, previewSize)
    if not verifyClip then
      return settings, totalIter, verifyErr
    end
    if Config.isClipped(verifyClip) then
      settings = prevSettings
      SettingsIO.syncToPhoto(ctx.catalog, ctx.photo, prevSettings, "NoClip Auto (balance rollback)")
      return settings, totalIter, "phase_done"
    end
  end

  return settings, totalIter, "phase_max"
end

return PhaseBalance
