$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "M4 smoke: tone pipeline golden + phase 2 caps"

& (Join-Path $root "scripts\verify-tone-quality.ps1")
if ($LASTEXITCODE -ne 0) {
    throw "verify-tone-quality.ps1 failed"
}

Write-Host "M4 smoke PASS"
exit 0
