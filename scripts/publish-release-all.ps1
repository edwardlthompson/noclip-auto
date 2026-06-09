param(
    [string]$Version = "1.2.0",
    [switch]$SkipMac,
    [switch]$Draft
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host "Publishing NoClip Auto v$Version (Windows + macOS)..."

& (Join-Path $root "scripts\publish-release.ps1") -Version $Version
if ($LASTEXITCODE -ne 0) { throw "publish-release failed" }

if (-not $SkipMac) {
    & (Join-Path $root "scripts\publish-macos-release.ps1") -Version $Version -Wait
    if ($LASTEXITCODE -ne 0) { throw "publish-macos-release failed" }
}

Write-Host "Release v$Version complete."
exit 0
