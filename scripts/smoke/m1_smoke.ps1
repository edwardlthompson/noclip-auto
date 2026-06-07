$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "M1 smoke: requires Lightroom Classic"

# Fresh load — plugin is scanned only at LR startup
Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Stopping Lightroom (PID $($_.Id)) for clean plugin load..."
    Stop-Process -Id $_.Id -Force
}
Start-Sleep -Seconds 3

& (Join-Path $root "scripts\build-analyzer.ps1") -Profile release-small
& (Join-Path $root "scripts\install-plugin.ps1") -Force
& (Join-Path $root "scripts\ensure-lr-running.ps1") -TimeoutSec 180
& (Join-Path $root "scripts\wait-for-lr-plugin.ps1") -WaitSec 240

Write-Host "M1 smoke PASS"
exit 0
