$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "M1 smoke: requires Lightroom Classic"
& (Join-Path $root "scripts\ensure-lr-running.ps1")
& (Join-Path $root "scripts\install-plugin.ps1") -Force
& (Join-Path $root "scripts\verify-lr-plugin.ps1")

Write-Host "M1 smoke PASS"
exit 0
