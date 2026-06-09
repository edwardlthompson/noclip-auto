param(
    [int]$TimeoutSec = 300,
    [int]$PollSec = 3,
    [int]$MinStartupSec = 30
)

$ErrorActionPreference = "Stop"

function Get-LrProcess {
    return Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 } |
        Sort-Object StartTime -Descending |
        Select-Object -First 1
}

function Get-DefaultCatalog {
    $prefsDir = Join-Path $env:APPDATA "Adobe\Lightroom\Preferences"
    $prefsFile = Get-ChildItem $prefsDir -Filter "*Preferences.agprefs" |
        Where-Object { $_.Name -notmatch "Startup" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $prefsFile) { return $null }

    $raw = Get-Content $prefsFile.FullName -Raw
    if ($raw -match 'libraryToLoad20 = "([^"]+\.lrcat)"') {
        return ($Matches[1] -replace '\\\\', '\')
    }
    return $null
}

function Start-LrWithCatalog {
    $catalog = Get-DefaultCatalog
    $lrExe = @(
        "${env:ProgramFiles}\Adobe\Adobe Lightroom Classic\Lightroom.exe",
        "${env:ProgramFiles(x86)}\Adobe\Adobe Lightroom Classic\Lightroom.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $lrExe) {
        throw "Lightroom Classic not installed"
    }

    if ($catalog -and (Test-Path $catalog)) {
        $lockPath = "$catalog.lock"
        if ((Test-Path $lockPath) -and -not (Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue)) {
            Write-Host "Removing stale catalog lock: $lockPath"
            Remove-Item -Force $lockPath
        }
        Write-Host "Opening catalog: $catalog"
        Start-Process -FilePath $catalog
        return
    }

    Write-Host "Starting Lightroom (no catalog path found)"
    Start-Process $lrExe
}

function Test-LrCatalogReady {
    $lr = Get-LrProcess
    if (-not $lr) { return $false }

    $title = $lr.MainWindowTitle
    if ($title -and $title -ne "Lightroom Classic" -and $title -match "Lightroom") {
        return $true
    }

    $markerPaths = @(
        Join-Path $env:TEMP "NoClipAuto\noclip-plugin-loaded.txt"
        Join-Path $env:APPDATA "Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin\smoke\plugin-loaded.txt"
    )
    foreach ($marker in $markerPaths) {
        if (Test-Path $marker) {
            return $true
        }
    }

    return $false
}

if (-not (Get-LrProcess)) {
    Start-LrWithCatalog
}

$windowSeenAt = $null
$deadline = (Get-Date).AddSeconds($TimeoutSec)
while ((Get-Date) -lt $deadline) {
    $lr = Get-LrProcess
    if ($lr) {
        if (-not $windowSeenAt) {
            $windowSeenAt = Get-Date
            Write-Host "Lightroom window detected: $($lr.MainWindowTitle)"
        }

        if ((Get-Date) -ge $windowSeenAt.AddSeconds($MinStartupSec) -and (Test-LrCatalogReady)) {
            Write-Host "Lightroom catalog ready: $($lr.MainWindowTitle)"
            exit 0
        }
    }

    Start-Sleep -Seconds $PollSec
}

throw "Timed out waiting for Lightroom catalog after ${TimeoutSec}s"
