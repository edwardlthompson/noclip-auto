param(
    [int]$TimeoutSec = 120
)

$ErrorActionPreference = "Stop"
$proc = Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue
if ($proc) {
    Write-Host "Lightroom already running (PID $($proc.Id))"
    exit 0
}

$lrExe = @(
    "${env:ProgramFiles}\Adobe\Adobe Lightroom Classic\Lightroom.exe",
    "${env:ProgramFiles(x86)}\Adobe\Adobe Lightroom Classic\Lightroom.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $lrExe) {
    Write-Host "NOT_INSTALLED"
    exit 2
}

Start-Process $lrExe
Write-Host "Started Lightroom, waiting for log heartbeat..."

$logDir = Join-Path $env:LOCALAPPDATA "Adobe\Lightroom\Logs\LrClassicLogs"
$deadline = (Get-Date).AddSeconds($TimeoutSec)

while ((Get-Date) -lt $deadline) {
    if (Test-Path $logDir) {
        $recent = Get-ChildItem $logDir -Filter "*.log" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($recent -and $recent.LastWriteTime -gt (Get-Date).AddMinutes(-2)) {
            Write-Host "Log heartbeat detected: $($recent.Name)"
            exit 0
        }
    }
    Start-Sleep -Seconds 3
}

Write-Host "Timeout waiting for LR log heartbeat"
exit 1
