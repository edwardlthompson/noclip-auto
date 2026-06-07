-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0
-- Keep VERSION in sync with Info.lua

local About = {}

About.VERSION = { major = 0, minor = 1, revision = 0, build = 0 }

About.GITHUB_URL = "https://github.com/edwardlthompson/noclip-auto"
About.CHANGELOG_URL = "https://github.com/edwardlthompson/noclip-auto/blob/main/docs/CHANGELOG.md"
About.VENMO_URL = "https://venmo.com/code?user_id=1857304970395648420"

About.RELEASE_NOTES = {
  "Initial pre-release: 3-phase tone pipeline for highlight/shadow recovery.",
  "Batch and Develop workflows with dry-run mode and develop snapshots.",
  "Bundled Rust analyzer; performance tiers; Plugin Manager preferences.",
}

function About.versionString()
  local v = About.VERSION
  return string.format("%d.%d.%d", v.major, v.minor, v.revision)
end

function About.releaseNotesText()
  return table.concat(About.RELEASE_NOTES, "\n")
end

return About
