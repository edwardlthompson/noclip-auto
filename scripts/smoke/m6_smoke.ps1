$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "M6 smoke: release gates (GS + GP + package)"

& (Join-Path $root "scripts\check-bundle-size.ps1")
if ($LASTEXITCODE -ne 0) { throw "check-bundle-size failed" }

& (Join-Path $root "scripts\check-lua-size.ps1") -ShippedOnly
if ($LASTEXITCODE -ne 0) { throw "check-lua-size failed" }

& (Join-Path $root "scripts\bench-analyzer.ps1")
if ($LASTEXITCODE -ne 0) { throw "bench-analyzer failed" }

& (Join-Path $root "scripts\verify-tone-quality.ps1")
if ($LASTEXITCODE -ne 0) { throw "verify-tone-quality failed" }

& (Join-Path $root "scripts\package-release.ps1") -Version "1.0.0"
if ($LASTEXITCODE -ne 0) { throw "package-release failed" }

Write-Host "M6 smoke PASS"
exit 0
