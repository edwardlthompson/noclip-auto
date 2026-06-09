$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "M5 smoke: batch dry-run (10 photos, High-tier overlap)"

Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Stopping Lightroom (PID $($_.Id))..."
    Stop-Process -Id $_.Id -Force
}
Start-Sleep -Seconds 8

$catalog = Join-Path $env:APPDATA "Adobe\Lightroom\Preferences"
$prefsFile = Get-ChildItem $catalog -Filter "*Preferences.agprefs" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch "Startup" } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if ($prefsFile) {
    $raw = Get-Content $prefsFile.FullName -Raw
    if ($raw -match 'libraryToLoad20 = "([^"]+\.lrcat)"') {
        $lockPath = ($Matches[1] -replace '\\\\', '\') + ".lock"
        if ((Test-Path $lockPath) -and -not (Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue)) {
            Write-Host "Removing stale catalog lock: $lockPath"
            Remove-Item -Force $lockPath
        }
    }
}

& (Join-Path $root "scripts\build-analyzer.ps1") -Profile release-small

$fixture = Join-Path $root "tests\fixtures\gray.jpg"
if (-not (Test-Path $fixture)) {
    & (Join-Path $root "scripts\generate-fixtures.ps1")
}

$pluginSmoke = Join-Path $root "NoClipAuto.lrdevplugin\smoke"
New-Item -ItemType Directory -Force -Path $pluginSmoke | Out-Null
$triggerPath = Join-Path $pluginSmoke "m5-smoke.trigger"
@{ fixture = $fixture; count = 10; dryRun = $true } | ConvertTo-Json -Compress | Set-Content -Path $triggerPath -Encoding ASCII -NoNewline

& (Join-Path $root "scripts\install-plugin.ps1") -Force
& (Join-Path $root "scripts\enable-lr-plugin.ps1") -Force

$tempDir = Join-Path $env:TEMP "NoClipAuto"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
$resultPath = Join-Path $tempDir "m5-smoke-result.json"
$reportPath = Join-Path $tempDir "NoClipAuto-last-run.json"
$dryRunLog = Join-Path $tempDir "NoClipAuto-dry-run.log"
$markerPaths = @(
    Join-Path $env:TEMP "NoClipAuto\noclip-plugin-loaded.txt"
    Join-Path $env:APPDATA "Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin\smoke\plugin-loaded.txt"
)
Remove-Item -Force -ErrorAction SilentlyContinue $resultPath, $reportPath, $dryRunLog
foreach ($marker in $markerPaths) {
    Remove-Item -Force -ErrorAction SilentlyContinue $marker
}

& (Join-Path $root "scripts\wait-for-lr-ready.ps1") -TimeoutSec 360

Write-Host "Waiting for plugin load marker..."
$pluginDeadline = (Get-Date).AddSeconds(120)
$pluginLoaded = $false
while ((Get-Date) -lt $pluginDeadline) {
    foreach ($marker in $markerPaths) {
        if (Test-Path $marker) {
            $pluginLoaded = $true
            Write-Host "Plugin loaded: $marker"
            break
        }
    }
    if ($pluginLoaded) { break }
    Start-Sleep -Seconds 3
}
if (-not $pluginLoaded) {
    Write-Host "Plugin marker missing; attempting Plug-in Manager enable..."
    & (Join-Path $root "scripts\enable-lr-plugin-ui.ps1") -TimeoutSec 180
}

Write-Host "Waiting for M5 batch smoke (Init auto-run)..."

$smokeStart = Get-Date
$deadline = (Get-Date).AddSeconds(900)
while ((Get-Date) -lt $deadline) {
    if (Test-Path $resultPath) {
        $raw = Get-Content $resultPath -Raw
        if ($raw -match '"ok"\s*:\s*false') {
            throw "M5 smoke FAIL: $raw"
        }
        if ($raw -match '"ok"\s*:\s*true' -and $raw -match '"count"\s*:\s*10' -and $raw -match '"dryRun"\s*:\s*true') {
            if (-not (Test-Path $reportPath)) {
                Write-Host "Waiting for batch report..."
                Start-Sleep -Seconds 3
                continue
            }
            if (-not (Test-Path $dryRunLog)) {
                Write-Host "Waiting for dry-run log..."
                Start-Sleep -Seconds 3
                continue
            }
            $report = Get-Content $reportPath -Raw | ConvertFrom-Json
            if ($report.Count -lt 10) {
                Write-Host "Report has $($report.Count) entries; waiting..."
                Start-Sleep -Seconds 5
                continue
            }
            Write-Host $raw
            Write-Host "Batch report: $reportPath ($($report.Count) entries)"
            Write-Host "Dry-run log: $dryRunLog"
            Write-Host "M5 smoke PASS"
            exit 0
        }
        Write-Host "Smoke result (waiting for success): $raw"
    }

    $lr = Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue
    if (-not $lr) {
        throw "M5 smoke FAIL: Lightroom exited before batch completed"
    }

    Start-Sleep -Seconds 10
}

if (Test-Path $resultPath) {
    throw "M5 smoke FAIL: $(Get-Content $resultPath -Raw)"
}
throw "M5 smoke FAIL: timed out waiting for $resultPath"
