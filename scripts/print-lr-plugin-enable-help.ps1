Write-Host @"
NoClip Auto is installed but not enabled in Lightroom yet.

One-time setup (manual):
  1. In Lightroom Classic, open File > Plug-in Manager
  2. Select "NoClip Auto" in the left list
     (If missing: click Add, choose:
      $env:APPDATA\Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin)
  3. Click Enable in the Status section
  4. Click Done, then re-run the smoke test

After enabling once, automated m3_smoke.ps1 should work on this machine.
"@

exit 2
