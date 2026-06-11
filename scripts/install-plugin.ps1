param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$src = Join-Path $root "NoClipAuto.lrdevplugin"
$dest = Join-Path $env:APPDATA "Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin"

if (-not (Test-Path $src)) {
    throw "Plugin source not found: $src"
}

& (Join-Path $root "scripts\build-analyzer.ps1") -Profile release-small

if ((Test-Path $dest) -and -not $Force) {
    Write-Host "Removing existing install: $dest"
}
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $dest
New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
Copy-Item -Recurse -Force $src $dest

Get-ChildItem (Join-Path $dest "smoke") -Filter "*.trigger" -ErrorAction SilentlyContinue |
    Remove-Item -Force

Write-Host "Installed plugin to: $dest"
