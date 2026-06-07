param(
    [int]$MaxLines = 200
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$pluginDir = Join-Path $root "NoClipAuto.lrdevplugin"

$luaFiles = Get-ChildItem $pluginDir -Filter "*.lua" -Recurse
$failures = @()

foreach ($f in $luaFiles) {
    $lines = (Get-Content $f.FullName).Count
    if ($lines -gt $MaxLines) {
        $failures += "$($f.FullName): $lines lines"
    }
}

if ($failures.Count -gt 0) {
    throw "Lua size gate FAIL:`n$($failures -join "`n")"
}

Write-Host "Lua size gate PASS ($($luaFiles.Count) files checked, max $MaxLines lines)"
