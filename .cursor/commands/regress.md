# Post-release regression

After tagging or publishing vX.Y.Z:

1. Run `.\scripts\pre-release-gate.ps1` and confirm CI + Security Scan + CodeQL green.
2. Run `.\scripts\run-milestone-gate.ps1 -Milestone 9` for M8/M9 regression.
3. Verify GitHub Release zip exists and matches `THIRD_PARTY_LICENSES.md`.
4. Confirm `Info.lua` VERSION matches CHANGELOG release section.
5. Append regressions to @KNOWLEDGE_BASE.md and BUILD_PLAN [AUTO] items.

Begin now.
