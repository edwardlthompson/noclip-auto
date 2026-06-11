$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "M9 smoke: lens profile module + M8 regression + package 1.3.0"

$lensModule = Join-Path $root "NoClipAuto.lrdevplugin\Core\Pipeline\LensProfile.lua"
if (-not (Test-Path $lensModule)) {
    throw "LensProfile.lua missing"
}

& (Join-Path $root "scripts\smoke\m8_smoke.ps1")
if ($LASTEXITCODE -ne 0) { throw "m8_smoke.ps1 failed" }

& (Join-Path $root "scripts\package-release.ps1") -Version "1.3.0"
if ($LASTEXITCODE -ne 0) { throw "package-release.ps1 failed" }

Write-Host "M9 smoke PASS"
exit 0
