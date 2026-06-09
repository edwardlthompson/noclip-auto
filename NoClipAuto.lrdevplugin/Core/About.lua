-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0
-- Keep VERSION in sync with Info.lua

local About = {}

About.VERSION = { major = 1, minor = 2, revision = 0, build = 0 }

About.GITHUB_URL = "https://github.com/edwardlthompson/noclip-auto"
About.CHANGELOG_URL = "https://github.com/edwardlthompson/noclip-auto/blob/main/docs/CHANGELOG.md"
About.VENMO_URL = "https://venmo.com/code?user_id=1857304970395648420"

About.RELEASE_NOTES = {
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
