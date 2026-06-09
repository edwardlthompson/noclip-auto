$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "M8 smoke: analyzer v2 + tone golden regression"

& (Join-Path $root "scripts\build-analyzer.ps1") -Profile release-small
if ($LASTEXITCODE -ne 0) { throw "build-analyzer failed" }

Push-Location (Join-Path $root "noclip-analyze")
cargo test
if ($LASTEXITCODE -ne 0) { throw "cargo test failed" }
Pop-Location

& (Join-Path $root "scripts\test_analyzer.ps1")
if ($LASTEXITCODE -ne 0) { throw "test_analyzer.ps1 failed" }

& (Join-Path $root "scripts\verify-tone-quality.ps1")
if ($LASTEXITCODE -ne 0) { throw "verify-tone-quality.ps1 failed" }

& (Join-Path $root "scripts\bench-analyzer.ps1")
if ($LASTEXITCODE -ne 0) { throw "bench-analyzer.ps1 failed" }

& (Join-Path $root "scripts\package-release.ps1") -Version "1.2.0"
if ($LASTEXITCODE -ne 0) { throw "package-release.ps1 failed" }

Write-Host "M8 smoke PASS"
exit 0
