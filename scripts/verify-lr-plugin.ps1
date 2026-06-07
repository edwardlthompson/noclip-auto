$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$logDir = Join-Path $env:LOCALAPPDATA "Adobe\Lightroom\Logs\LrClassicLogs"
if (-not (Test-Path $logDir)) {
    Write-Host "LR log dir not found — LR may not be installed or never run"
    exit 2
}

$logs = Get-ChildItem $logDir -Filter "*.log" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 3

$found = $false
$errors = @()

foreach ($log in $logs) {
    $content = Get-Content $log.FullName -Tail 500 -ErrorAction SilentlyContinue
    if ($content -match "NoClipAuto|com\.noclipauto") {
        $found = $true
    }
    $luaErrors = $content | Select-String -Pattern "NoClipAuto.*error|NoClip Auto.*error" -SimpleMatch:$false
    if ($luaErrors) {
        $errors += $luaErrors
    }
}

if (-not $found) {
    Write-Host "Plugin ID not found in recent logs — install plugin and restart LR"
    exit 1
}

if ($errors.Count -gt 0) {
    Write-Host "Lua errors found:"
    $errors | ForEach-Object { Write-Host $_ }
    exit 1
}

Write-Host "verify-lr-plugin PASS"
exit 0
