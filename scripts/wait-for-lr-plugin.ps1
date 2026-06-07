param(
    [int]$WaitSec = 180,
    [int]$PollSec = 5
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$logDir = Join-Path $env:LOCALAPPDATA "Adobe\Lightroom\Logs\LrClassicLogs"

if (-not (Test-Path $logDir)) {
    Write-Host "LR log dir not found"
    exit 2
}

$deadline = (Get-Date).AddSeconds($WaitSec)
while ((Get-Date) -lt $deadline) {
    & (Join-Path $root "scripts\verify-lr-plugin.ps1")
    if ($LASTEXITCODE -eq 0) {
        exit 0
    }
    Start-Sleep -Seconds $PollSec
}

Write-Host "Plugin not found in LR logs after ${WaitSec}s"
exit 1
