param(
    [int]$WaitSec = 30
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$lr = Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $lr) {
    throw "Lightroom is not running — start LR and open a catalog first"
}

$fixture = Join-Path $root "tests\fixtures\gray.jpg"
if (-not (Test-Path $fixture)) {
    & (Join-Path $root "scripts\generate-fixtures.ps1")
}

$pluginSmoke = Join-Path $root "NoClipAuto.lrdevplugin\smoke"
New-Item -ItemType Directory -Force -Path $pluginSmoke | Out-Null
$triggerPath = Join-Path $pluginSmoke "m8-smoke.trigger"
@{ fixture = $fixture; count = 3; dryRun = $true } | ConvertTo-Json -Compress | Set-Content -Path $triggerPath -Encoding ASCII -NoNewline

$tempDir = Join-Path $env:TEMP "NoClipAuto"
$resultPath = Join-Path $tempDir "m8-smoke-result.json"
Remove-Item -Force -ErrorAction SilentlyContinue $resultPath

Write-Host "M8 LR smoke trigger written: $triggerPath"
Write-Host "If LR was already running before plugin install, restart LR or use Library -> Plug-in Extras -> M8 Smoke (dev)"
Write-Host "Invoking lightroom:// URL handler..."
& (Join-Path $root "scripts\invoke-lr-url.ps1") -Command m8-smoke

Write-Host "Waiting up to ${WaitSec}s for result..."
$deadline = (Get-Date).AddSeconds($WaitSec)
while ((Get-Date) -lt $deadline) {
    if (Test-Path $resultPath) {
        Write-Host (Get-Content $resultPath -Raw)
        exit 0
    }
    Start-Sleep -Seconds 2
}

Write-Host "No result yet at $resultPath — run scripts\smoke\m8_lr_smoke.ps1 for full automated pass"
