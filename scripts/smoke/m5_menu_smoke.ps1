$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "M5 menu smoke: production ProcessLibrary via Library Plug-in Extras"
Write-Host "Requires Lightroom running with photos in catalog (run after m9_lr_smoke.ps1)"

$lr = Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue
if (-not $lr) {
    throw "Lightroom is not running — start LR and import photos first (e.g. run m9_lr_smoke.ps1)"
}

$pluginSmoke = Join-Path $root "NoClipAuto.lrdevplugin\smoke"
Remove-Item -Force -ErrorAction SilentlyContinue @(
    (Join-Path $pluginSmoke "m3-smoke.trigger")
    (Join-Path $pluginSmoke "m5-smoke.trigger")
    (Join-Path $pluginSmoke "m8-smoke.trigger")
    (Join-Path $pluginSmoke "m9-smoke.trigger")
)

$tempDir = Join-Path $env:TEMP "NoClipAuto"
$reportPath = Join-Path $tempDir "NoClipAuto-last-run.json"
$reportBefore = $null
if (Test-Path $reportPath) {
    $reportBefore = (Get-Item $reportPath).LastWriteTimeUtc
}

Write-Host "Invoking Library -> Plug-in Extras -> NoClip Auto - Selected Photos..."
& (Join-Path $root "scripts\invoke-lr-plugin-menu.ps1") `
    -MenuTitle "   NoClip Auto - Selected Photos" `
    -ParentMenu "Library" `
    -WaitForMenuSec 120

Write-Host "Waiting for batch report from menu path..."
$deadline = (Get-Date).AddSeconds(600)
while ((Get-Date) -lt $deadline) {
    if (Test-Path $reportPath) {
        $mtime = (Get-Item $reportPath).LastWriteTimeUtc
        if (-not $reportBefore -or $mtime -gt $reportBefore) {
            $report = Get-Content $reportPath -Raw | ConvertFrom-Json
            if ($report.Count -ge 1) {
                Write-Host "Batch report: $reportPath ($($report.Count) entries)"
                Write-Host "M5 menu smoke PASS"
                exit 0
            }
        }
    }
    if (-not (Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue)) {
        throw "M5 menu smoke FAIL: Lightroom exited before batch completed"
    }
    Start-Sleep -Seconds 5
}

throw "M5 menu smoke FAIL: timed out waiting for updated $reportPath"
