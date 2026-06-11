# Plugin Manager settings UI

## Rule (do not remove)

Plugin Manager settings **must** include per-field hint text: valid range, default value, and when to change it.

Do **not** remove hints to stay under the 200-line Lua gate — extract layout to [`Core/SettingsUI.lua`](../NoClipAuto.lrdevplugin/Core/SettingsUI.lua) instead.

## Layout pattern

Numeric prefs use an LR-style row:

- Label
- `f:slider` (min/max from this doc)
- `f:edit_field` (same bound key — numeric callout)
- Hint `static_text` below (`<system/small>`, 2–3 lines)

Checkboxes use label + checkbox + hint.

## Setting reference

| Key | Control | Range | Default |
|-----|---------|-------|---------|
| `dryRun` | checkbox | — | false |
| `clipThresholdPct` | slider + field | 0.01–0.50 | 0.05 |
| `performanceTier` | popup | Auto/Low/Balanced/High | Balanced |
| `maxTotalIterations` | slider + field | 10–120 | 60 |
| `enableLensProfileCorrection` | checkbox | — | true |
| `useFullSizePreview` | checkbox | — | false |
| `enableBalancePhase` | checkbox | — | false |
| `balanceTargetMedian` | slider + field | 0.30–0.60 | 0.45 |
| `balanceEttrMode` | checkbox | — | false |

Update this table when adding or changing prefs.
