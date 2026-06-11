-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local RunSummary = {}

local function fmtSliderLine(label, entry)
  if not entry then
    return nil
  end
  return string.format("%s: %.2f → %.2f", label, entry.before, entry.after)
end

function RunSummary.formatPhotoResult(result)
  if not result.ok then
    return "Error: " .. tostring(result.error)
  end

  local lines = {}
  if result.dryRun then
    lines[#lines + 1] = "(Dry run — no edits were saved.)"
  end

  if result.skipped then
    lines[#lines + 1] = "Auto Tone applied; no clip adjustments needed."
  else
    lines[#lines + 1] = string.format("Iterations: %d", result.iterations or 0)
  end

  if result.before and result.after then
    lines[#lines + 1] = string.format(
      "Clip shadow %.2f%% → %.2f%% | highlight %.2f%% → %.2f%%",
      result.before.shadowClipPct or 0,
      result.after.shadowClipPct or 0,
      result.before.highlightClipPct or 0,
      result.after.highlightClipPct or 0
    )
  end

  local delta = result.sliderDelta
  if delta then
    local exp = fmtSliderLine("Exposure", delta.Exposure2012)
    if exp then
      lines[#lines + 1] = exp
    end
    if not delta.anyChange and not result.dryRun then
      lines[#lines + 1] = "Warning: no develop slider changes were saved."
    elseif not delta.anyChange and result.dryRun then
      lines[#lines + 1] = "No slider changes would be applied."
    end
  end

  return table.concat(lines, "\n")
end

function RunSummary.formatBatchResults(results, dryRun)
  local lines = {}
  if dryRun then
    lines[#lines + 1] = "Dry run — no edits were saved to photos."
    lines[#lines + 1] = ""
  end

  for i, r in ipairs(results) do
    lines[#lines + 1] = string.format("Photo %d:", i)
    lines[#lines + 1] = RunSummary.formatPhotoResult(r)
    lines[#lines + 1] = ""
  end

  return table.concat(lines, "\n")
end

return RunSummary
