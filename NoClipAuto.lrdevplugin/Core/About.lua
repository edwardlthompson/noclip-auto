-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0
-- Keep VERSION in sync with Info.lua

local About = {}

About.VERSION = { major = 1, minor = 3, revision = 7, build = 0 }

About.GITHUB_URL = "https://github.com/edwardlthompson/noclip-auto"
About.CHANGELOG_URL = "https://github.com/edwardlthompson/noclip-auto/blob/main/CHANGELOG.md"
About.VENMO_URL = "https://venmo.com/code?user_id=1857304970395648420"

About.RELEASE_NOTES = {
  "v1.3.7: Fix Windows analyzer spawn; unique File menu title; AutoHotkey shortcuts.",
  "v1.3.6: Fix analyzer race on Windows (unique output paths per measure).",
  "v1.3.5: Fast tier, progress on Active Photo, quieter loop sync, snapshots optional.",
  "v1.3.4: Active Photo on File > Plug-in Extras (Develop); fix Library Active Photo target.",
  "v1.3.3: Settings sliders + hints; Library Active Photo menu; faster preview; apply fixes.",
  "v1.3.2: Reset defaults button; production Library menu only; prefs reload; dry-run warning.",
  "v1.3.1: Fix Library/Develop menus (Loader + yield-safe async); install includes analyzer.",
  "v1.3.0: Optional lens profile correction before Auto Tone (default on).",
  "v1.2.2: Fix Init crash (package nil); Develop Photo menu loads; Loader for menu scripts.",
  "v1.2.1: Fix menu require(); persist Plugin Manager settings via LrPrefs.",
  "v1.2.0: Auto Tone always runs first; optional Balance phase; analyzer v2 stats.",
  "Interim develop sync during measure loop; dry-run restores initial settings.",
  "v1.0.0: 3-phase tone pipeline until clipping is eliminated.",
  "Library batch, Develop single-photo, dry-run mode, develop snapshots.",
}

function About.versionString()
  local v = About.VERSION
  return string.format("%d.%d.%d", v.major, v.minor, v.revision)
end

function About.releaseNotesText()
  return table.concat(About.RELEASE_NOTES, "\n")
end

return About
