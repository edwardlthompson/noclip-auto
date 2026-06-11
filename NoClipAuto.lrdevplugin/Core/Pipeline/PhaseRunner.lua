-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local Config = require("Core.Pipeline.Config")
local SettingsIO = require("Core.SettingsIO")
local PreviewRender = require("Core.PreviewRender")
local ClippingClient = require("Core.ClippingClient")
local PhaseExposure = require("Core.Pipeline.PhaseExposure")
local PhaseWhitesBlacks = require("Core.Pipeline.PhaseWhitesBlacks")
local PhaseHighlightsShadows = require("Core.Pipeline.PhaseHighlightsShadows")

local PhaseRunner = {}

local activePrefetch = nil
local smokeAnalyzeFallback = false

function PhaseRunner.setPrefetch(prefetch)
  activePrefetch = prefetch
end

function PhaseRunner.setSmokeAnalyzeFallback(value)
  smokeAnalyzeFallback = value == true
end

function PhaseRunner.measure(photo, previewSize)
  local jpegPath, err
  if activePrefetch then
    jpegPath, err = activePrefetch:take(photo)
  else
    jpegPath, err = PreviewRender.exportPhoto(photo, previewSize)
  end
  if not jpegPath then
    return nil, err
  end
  local analyzeOpts = smokeAnalyzeFallback and { allowZeroFallback = true } or nil
  local clipResult, analyzeErr = ClippingClient.analyze(jpegPath, analyzeOpts)
  PreviewRender.cleanup(jpegPath)
  if not clipResult then
    return nil, analyzeErr
  end
  return clipResult
end

function PhaseRunner.syncSettings(settings, ctx)
  if ctx and ctx.catalog and ctx.photo then
    SettingsIO.syncToPhoto(ctx.catalog, ctx.photo, settings, nil, true)
  end
end

local function notifyProgress(ctx, caption, iterFraction)
  if ctx and ctx.onProgress then
    ctx.onProgress(caption, iterFraction or 0)
  end
end

function PhaseRunner.logIteration(photoId, phase, iteration, clipResult, deltas)
  NoClipAuto.logger:trace(string.format(
    "photo=%s phase=%s iter=%d shadow=%d highlight=%d deltas=%s",
    tostring(photoId),
    phase,
    iteration,
    clipResult.shadowClipPx,
    clipResult.highlightClipPx,
    tostring(deltas)
  ))
end

function PhaseRunner.runPhase1(photo, settings, previewSize, totalIter, maxIter, ctx)
  local noProgress = 0
  local lastShadow, lastHighlight = -1, -1

  for i = 1, Config.MAX_PHASE1_ITER do
    if totalIter.count >= maxIter then
      return settings, totalIter, "max_total"
    end

    local clipResult, err = PhaseRunner.measure(photo, previewSize)
    if not clipResult then
      return settings, totalIter, err
    end

    if not Config.isClipped(clipResult) then
      return settings, totalIter, "done"
    end

    local newSettings, deltas, phaseDone = PhaseExposure.adjust(settings, clipResult)
    PhaseRunner.logIteration(photo.localIdentifier, "exposure", i, clipResult, deltas)

    if phaseDone then
      return settings, totalIter, "phase_done"
    end

    settings = newSettings
    PhaseRunner.syncSettings(settings, ctx)
    totalIter.count = totalIter.count + 1
    notifyProgress(ctx, string.format("Exposure iter %d", i), totalIter.count / ctx.maxIter)

    if clipResult.shadowClipPx == lastShadow and clipResult.highlightClipPx == lastHighlight then
      noProgress = noProgress + 1
      if noProgress >= Config.MAX_NO_PROGRESS then
        return settings, totalIter, "no_progress"
      end
    else
      noProgress = 0
    end
    lastShadow = clipResult.shadowClipPx
    lastHighlight = clipResult.highlightClipPx
  end

  return settings, totalIter, "phase_max"
end

function PhaseRunner.runPhase2(photo, settings, previewSize, totalIter, maxIter, ctx)
  local state = PhaseWhitesBlacks.newState(settings)

  for i = 1, Config.MAX_PHASE2_ITER do
    if totalIter.count >= maxIter then
      return settings, totalIter, "max_total"
    end

    local clipResult, err = PhaseRunner.measure(photo, previewSize)
    if not clipResult then
      return settings, totalIter, err
    end

    if not Config.isClipped(clipResult) then
      return settings, totalIter, "done"
    end

    local newSettings, deltas, phaseDone, newState = PhaseWhitesBlacks.adjust(settings, clipResult, state)
    PhaseRunner.logIteration(photo.localIdentifier, "whites_blacks", i, clipResult, deltas)
    settings = newSettings
    state = newState
    PhaseRunner.syncSettings(settings, ctx)

    if phaseDone then
      return settings, totalIter, "phase_done"
    end

    totalIter.count = totalIter.count + 1
    notifyProgress(ctx, string.format("Whites/Blacks iter %d", i), totalIter.count / ctx.maxIter)
  end

  return settings, totalIter, "phase_max"
end

function PhaseRunner.runPhase3(photo, settings, previewSize, totalIter, maxIter, ctx)
  for i = 1, Config.MAX_PHASE3_ITER do
    if totalIter.count >= maxIter then
      return settings, totalIter, "max_total"
    end

    local clipResult, err = PhaseRunner.measure(photo, previewSize)
    if not clipResult then
      return settings, totalIter, err
    end

    if not Config.isClipped(clipResult) then
      return settings, totalIter, "done"
    end

    local newSettings, deltas, phaseDone = PhaseHighlightsShadows.adjust(settings, clipResult)
    PhaseRunner.logIteration(photo.localIdentifier, "highlights_shadows", i, clipResult, deltas)
    settings = newSettings
    PhaseRunner.syncSettings(settings, ctx)

    if phaseDone then
      return settings, totalIter, "phase_done"
    end

    totalIter.count = totalIter.count + 1
    notifyProgress(ctx, string.format("Highlights/Shadows iter %d", i), totalIter.count / ctx.maxIter)
  end

  return settings, totalIter, "phase_max"
end

return PhaseRunner
