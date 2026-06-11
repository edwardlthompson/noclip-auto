$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "M9 LR smoke: lens profile + Auto Tone dry-run (3 photos, High-tier overlap)"

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

& (Join-Path $root "scripts\install-plugin.ps1") -Force
& (Join-Path $root "scripts\enable-lr-plugin.ps1") -Force

$triggerPath = Join-Path $pluginSmoke "m9-smoke.trigger"
@{ fixture = $fixture; count = 3; dryRun = $true } | ConvertTo-Json -Compress | Set-Content -Path $triggerPath -Encoding ASCII -NoNewline
$installedTrigger = Join-Path $env:APPDATA "Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin\smoke\m9-smoke.trigger"
Copy-Item -Force $triggerPath $installedTrigger

$tempDir = Join-Path $env:TEMP "NoClipAuto"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
$resultPath = Join-Path $tempDir "m9-smoke-result.json"
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

Write-Host "Waiting for M9 batch smoke (Init auto-run)..."

$invokeDeadline = (Get-Date).AddSeconds(360)
while ((Get-Date) -lt $invokeDeadline) {
    if (Test-Path $resultPath) { break }
    Start-Sleep -Seconds 10
}
if (-not (Test-Path $resultPath) -and (Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue)) {
    Write-Host "Init did not finish M9 smoke within 6 min; invoking URL handler..."
    & (Join-Path $root "scripts\invoke-lr-url.ps1") -Command m9-smoke
}

$deadline = (Get-Date).AddSeconds(1200)
while ((Get-Date) -lt $deadline) {
    if (Test-Path $resultPath) {
        $raw = Get-Content $resultPath -Raw
        if ($raw -match '"ok"\s*:\s*false') {
            throw "M9 LR smoke FAIL: $raw"
        }
        $batchOk = ($raw -match '"ok"\s*:\s*true') -and ($raw -match '"count"\s*:\s*3') -and ($raw -match '"dryRun"\s*:\s*true') -and ($raw -match '"autoTone"\s*:\s*true') -and ($raw -match '"schemaVersion2"\s*:\s*true') -and ($raw -match '"lensProfile"\s*:\s*true')
        if ($batchOk) {
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
            if ($report.Count -lt 3) {
                Write-Host "Report has $($report.Count) entries; waiting..."
                Start-Sleep -Seconds 5
                continue
            }
            Write-Host $raw
            Write-Host "Batch report: $reportPath ($($report.Count) entries)"
            Write-Host "Dry-run log: $dryRunLog"
            Write-Host "M9 LR smoke PASS"
            exit 0
        }
        Write-Host "Smoke result (waiting for success): $raw"
    }

    $lr = Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue
    if (-not $lr) {
        throw "M9 LR smoke FAIL: Lightroom exited before batch completed"
    }

    Start-Sleep -Seconds 10
}

if (Test-Path $resultPath) {
    throw "M9 LR smoke FAIL: $(Get-Content $resultPath -Raw)"
}
throw "M9 LR smoke FAIL: timed out waiting for $resultPath"
