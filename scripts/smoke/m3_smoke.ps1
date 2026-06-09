$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "M3 smoke: preview JPEG export via Lightroom"

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
$triggerPath = Join-Path $pluginSmoke "m3-smoke.trigger"
@{ fixture = $fixture; previewSize = 512 } | ConvertTo-Json -Compress | Set-Content -Path $triggerPath -Encoding ASCII -NoNewline

& (Join-Path $root "scripts\install-plugin.ps1") -Force
& (Join-Path $root "scripts\enable-lr-plugin.ps1") -Force

$tempDir = Join-Path $env:TEMP "NoClipAuto"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
$resultPath = Join-Path $tempDir "m3-smoke-result.json"
$markerPaths = @(
    Join-Path $env:TEMP "NoClipAuto\noclip-plugin-loaded.txt"
    Join-Path $env:APPDATA "Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin\smoke\plugin-loaded.txt"
)
Remove-Item -Force -ErrorAction SilentlyContinue $resultPath
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

Write-Host "Waiting for plugin init and M3 smoke (Init auto-run)..."

$analyzer = Join-Path $root "NoClipAuto.lrdevplugin\bin\win-x64\noclip-analyze.exe"
$smokeStart = Get-Date
$deadline = (Get-Date).AddSeconds(600)
while ((Get-Date) -lt $deadline) {
    if (Test-Path $resultPath) {
        $raw = Get-Content $resultPath -Raw
        if ($raw -match '"ok"\s*:\s*true') {
            Write-Host $raw
            Write-Host "M3 smoke PASS"
            exit 0
        }
        Write-Host "Smoke result (waiting for success): $raw"
    }

    $preview = Get-ChildItem (Join-Path $env:TEMP "NoClipAuto") -Filter "preview_*.jpg" -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -ge $smokeStart } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($preview -and (Test-Path $analyzer)) {
        $outFile = Join-Path $env:TEMP "NoClipAuto\m3-ps-analyze-out.json"
        Remove-Item -Force -ErrorAction SilentlyContinue $outFile
        & $analyzer --input $preview.FullName --output $outFile --shadow-threshold 2 --highlight-threshold 253 2>$null
        $analysis = if (Test-Path $outFile) { Get-Content $outFile -Raw } else { $null }
        if ($analysis -match '"shadow_clip_px"') {
            Write-Host "Preview JPEG: $($preview.FullName)"
            Write-Host $analysis
            Write-Host "M3 smoke PASS (preview + analyzer)"
            exit 0
        }
    }

    $lr = Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue
    if (-not $lr) {
        throw "M3 smoke FAIL: Lightroom exited before producing preview"
    }

    Start-Sleep -Seconds 5
}

if (Test-Path $resultPath) {
    throw "M3 smoke FAIL: $(Get-Content $resultPath -Raw)"
}
throw "M3 smoke FAIL: timed out waiting for preview JPEG or $resultPath"
