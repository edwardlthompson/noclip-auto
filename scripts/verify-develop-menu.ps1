$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$infoPath = Join-Path $env:APPDATA "Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin\Info.lua"

if (-not (Test-Path $infoPath)) {
    Write-Host "FAIL: Plugin not installed at $infoPath"
    exit 1
}

$raw = Get-Content $infoPath -Raw
$checks = @(
    @{ name = "Library batch menu"; pattern = "NoClip Auto - Selected Photos" },
    @{ name = "Library Active Photo menu"; pattern = "NoClip Auto - Active Photo" },
    @{ name = "File Active Photo menu"; pattern = "LrExportMenuItems" },
    @{ name = "Export Active Photo entry"; pattern = "Active Photo (File)" },
    @{ name = "ProcessDevelop.lua"; pattern = "ProcessDevelop.lua" }
)

$fail = $false
foreach ($c in $checks) {
    if ($raw -match [regex]::Escape($c.pattern)) {
        Write-Host "OK: $($c.name)"
    } else {
        Write-Host "FAIL: $($c.name) missing"
        $fail = $true
    }
}

if ($raw -match 'VERSION\s*=\s*\{\s*major\s*=\s*(\d+),\s*minor\s*=\s*(\d+),\s*revision\s*=\s*(\d+)') {
    Write-Host "Version: $($Matches[1]).$($Matches[2]).$($Matches[3])"
} else {
    Write-Host "WARN: Could not parse VERSION from Info.lua"
}

if ($fail) { exit 1 }
Write-Host "verify-develop-menu PASS"
exit 0
