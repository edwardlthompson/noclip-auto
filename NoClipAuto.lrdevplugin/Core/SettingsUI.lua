-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0
-- Plugin Manager settings layout (hints + LR-style slider rows).

local LrView = import "LrView"
local bind = LrView.bind

local SettingsUI = {}

local TIER_ITEMS = {
  { title = "Auto", value = "Auto" },
  { title = "Fast", value = "Fast" },
  { title = "Low", value = "Low" },
  { title = "Balanced", value = "Balanced" },
  { title = "High", value = "High" },
}

local function hint(f, text, lines)
  return f:static_text {
    title = text,
    width_in_chars = 60,
    height_in_lines = lines or 2,
    font = "<system/small>",
  }
end

function SettingsUI.sliderRow(f, bind, label, key, spec)
  return f:column {
    spacing = f:label_spacing(),
    f:row {
      f:static_text { title = label, width = 180 },
      f:slider {
        value = bind(key),
        min = spec.min,
        max = spec.max,
        integral = spec.integral or false,
        width = 200,
      },
      f:edit_field {
        value = bind(key),
        width_in_chars = spec.width or 8,
        precision = spec.precision,
        integral = spec.integral,
      },
    },
    hint(f, spec.hint, spec.hintLines or 2),
  }
end

function SettingsUI.checkboxRow(f, bind, label, key, hintText)
  return f:column {
    spacing = f:label_spacing(),
    f:row {
      f:static_text { title = label, width = 180 },
      f:checkbox { value = bind(key) },
    },
    hint(f, hintText, 2),
  }
end

function SettingsUI.buildSettingsSection(f, propertyTable, onReset)
  return f:column {
    bind_to_object = propertyTable,
    spacing = f:control_spacing(),
    hint(f, "Library → Plug-in Extras → Selected Photos (batch) or Active Photo (single). "
      .. "Develop: File → Plug-in Extras → Active Photo (File).", 3),
    f:row {
      spacing = f:control_spacing(),
      f:push_button { title = "Reset to defaults", action = onReset },
    },
    hint(f, "Safe defaults: Fast tier, dry run OFF, snapshots OFF, lens profile ON, thumbnail preview.", 2),
    SettingsUI.checkboxRow(f, bind, "Dry run (log only, no apply):", "dryRun",
      "When ON, no develop edits are saved to photos. Default OFF. Turn OFF for normal use."),
    SettingsUI.sliderRow(f, bind, "Clip threshold (%):", "clipThresholdPct", {
      min = 0.01, max = 0.50, precision = 3, width = 8,
      hint = "Range 0.01–0.50. Default 0.05. Stop when shadow and highlight clip are both below this % of preview pixels. "
        .. "Use 0.01 for stricter (near-zero) clipping; higher values finish sooner.",
      hintLines = 3,
    }),
    f:column {
      spacing = f:label_spacing(),
      f:row {
        f:static_text { title = "Performance tier:", width = 180 },
        f:popup_menu { value = bind("performanceTier"), items = TIER_ITEMS, width = 120 },
      },
      hint(f, "Auto picks from CPU/RAM. Fast = 384px preview, 2× steps, overlap (best for large batches). "
        .. "High = largest preview. Default Fast.", 3),
    },
    SettingsUI.sliderRow(f, bind, "Max iterations per photo:", "maxTotalIterations", {
      min = 10, max = 120, integral = true, width = 6,
      hint = "Range 10–120. Default 40. Cap on measure/adjust loops per photo. Lower = faster batches; raise for stubborn clip.",
    }),
    SettingsUI.checkboxRow(f, bind, "Create before snapshot:", "enableDevelopSnapshots",
      "When ON, saves one Develop snapshot before processing (slower). Default OFF for speed."),
    SettingsUI.checkboxRow(f, bind, "Enable lens profile correction:", "enableLensProfileCorrection",
      "Apply Lightroom lens profile from EXIF before Auto Tone. Default ON. No matching profile = no change."),
    SettingsUI.checkboxRow(f, bind, "Use full-size preview export:", "useFullSizePreview",
      "When ON, measure loop uses slow export JPEG (more accurate). Default OFF — uses fast thumbnail preview."),
    f:static_text { title = "Balance phase (optional, after clip prevention):", font = "<system/small/bold>" },
    SettingsUI.checkboxRow(f, bind, "Enable balance phase:", "enableBalancePhase",
      "Optional tone polish after clip prevention. Default OFF — enable only for median/exposure balance on clean photos."),
    SettingsUI.sliderRow(f, bind, "Target median luma (0–1):", "balanceTargetMedian", {
      min = 0.30, max = 0.60, precision = 2, width = 8,
      hint = "Range 0.30–0.60. Default 0.45. Balance target brightness (0=black, 1=white). Ignored when ETTR mode is ON (uses 0.55).",
      hintLines = 3,
    }),
    SettingsUI.checkboxRow(f, bind, "ETTR mode (brighter target):", "balanceEttrMode",
      "Expose-to-the-right: Balance aims for median luma 0.55. Default OFF. Brighter overall; watch highlight clip."),
  }
end

return SettingsUI
