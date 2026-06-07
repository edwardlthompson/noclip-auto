-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local Config = require("Core.Pipeline.Config")
local PreviewRender = require("Core.PreviewRender")
local ClippingClient = require("Core.ClippingClient")
local PhaseExposure = require("Core.Pipeline.PhaseExposure")
local PhaseWhitesBlacks = require("Core.Pipeline.PhaseWhitesBlacks")
local PhaseHighlightsShadows = require("Core.Pipeline.PhaseHighlightsShadows")

local PhaseRunner = {}

function PhaseRunner.measure(photo, previewSize)
  local jpegPath, err = PreviewRender.exportPhoto(photo, previewSize)
  if not jpegPath then
    return nil, err
  end
  local clipResult, analyzeErr = ClippingClient.analyze(jpegPath)
  PreviewRender.cleanup(jpegPath)
  if not clipResult then
    return nil, analyzeErr
  end
  return clipResult
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

function PhaseRunner.runPhase1(photo, settings, previewSize, totalIter, maxIter)
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
    totalIter.count = totalIter.count + 1

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

function PhaseRunner.runPhase2(photo, settings, previewSize, totalIter, maxIter)
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

    if phaseDone then
      return settings, totalIter, "phase_done"
    end

    totalIter.count = totalIter.count + 1
  end

  return settings, totalIter, "phase_max"
end

function PhaseRunner.runPhase3(photo, settings, previewSize, totalIter, maxIter)
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

    if phaseDone then
      return settings, totalIter, "phase_done"
    end

    totalIter.count = totalIter.count + 1
  end

  return settings, totalIter, "phase_max"
end

return PhaseRunner
