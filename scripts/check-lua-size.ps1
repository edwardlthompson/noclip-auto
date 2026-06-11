param(
    [int]$MaxLines = 200,
    [switch]$ShippedOnly
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$pluginDir = Join-Path $root "NoClipAuto.lrdevplugin"

$devExclude = @(
    "M3SmokeHeadless.lua",
    "M5SmokeBootstrap.lua",
    "M8SmokeBootstrap.lua",
    "M9SmokeBootstrap.lua",
    "InitSmokeWatch.lua",
    "ProcessM3Smoke.lua",
    "ProcessM5Smoke.lua",
    "ProcessM8Smoke.lua",
    "ProcessM9Smoke.lua"
)

$luaFiles = Get-ChildItem $pluginDir -Filter "*.lua" -Recurse
$failures = @()
$checked = 0

foreach ($f in $luaFiles) {
    if ($ShippedOnly -and ($devExclude -contains $f.Name)) {
        continue
    }
    $checked++
    $lines = (Get-Content $f.FullName).Count
    if ($lines -gt $MaxLines) {
        $failures += "$($f.FullName): $lines lines"
    }
}

if ($failures.Count -gt 0) {
    throw "Lua size gate FAIL:`n$($failures -join "`n")"
}

Write-Host "Lua size gate PASS ($checked files checked, max $MaxLines lines)"
exit 0
