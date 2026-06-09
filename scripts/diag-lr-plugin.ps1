$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

& (Join-Path $root "scripts\install-plugin.ps1") -Force
& (Join-Path $root "scripts\enable-lr-plugin.ps1") -Force
& (Join-Path $root "scripts\ensure-lr-running.ps1") -TimeoutSec 240
Start-Sleep -Seconds 45

& (Join-Path $root "scripts\verify-lr-plugin.ps1")
Write-Host "verify exit=$LASTEXITCODE"

$logDir = Join-Path $env:LOCALAPPDATA "Adobe\Lightroom\Logs\LrClassicLogs"
Write-Host "Log dir exists: $(Test-Path $logDir)"
Get-ChildItem $logDir -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "$($_.Name) $($_.Length) $($_.LastWriteTime)"
}

Get-ChildItem (Join-Path $env:LOCALAPPDATA "Adobe\Lightroom\Logs") -Recurse -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 10 |
    ForEach-Object { Write-Host "LOG: $($_.FullName) $($_.Length)" }

$lr = Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($lr) { Write-Host "LR window: $($lr.MainWindowTitle)" }
