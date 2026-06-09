param(
    [int]$MaxExeMB = 2,
    [int]$MaxZipMB = 5
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$exe = Join-Path $root "NoClipAuto.lrdevplugin\bin\win-x64\noclip-analyze.exe"

if (-not (Test-Path $exe)) {
    throw "Analyzer exe not found - run build-analyzer.ps1 first"
}

$sizeMB = (Get-Item $exe).Length / 1MB
if ($sizeMB -gt $MaxExeMB) {
    throw "Bundle size gate FAIL: exe is $([math]::Round($sizeMB, 2)) MB (max $MaxExeMB MB)"
}

Write-Host "Bundle size gate PASS: exe $([math]::Round($sizeMB, 2)) MB"
exit 0
