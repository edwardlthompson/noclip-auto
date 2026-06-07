-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrLogger = import "LrLogger"

local logger = LrLogger("NoClipAuto")
logger:enable("logfile")

NoClipAuto = {
  logger = logger,
  prefs = import "LrPrefs".prefsForPlugin(),
}

NoClipAuto.prefs.clipThresholdPct = NoClipAuto.prefs.clipThresholdPct or 0.05
NoClipAuto.prefs.performanceTier = NoClipAuto.prefs.performanceTier or "Auto"
NoClipAuto.prefs.dryRun = NoClipAuto.prefs.dryRun or false
NoClipAuto.prefs.maxTotalIterations = NoClipAuto.prefs.maxTotalIterations or 60
