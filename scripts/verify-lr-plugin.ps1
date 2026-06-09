$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$pluginPath = Join-Path $env:APPDATA "Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin"

if (-not (Test-Path $pluginPath)) {
    Write-Host "Plugin not installed at $pluginPath"
    exit 1
}

if (-not (Test-Path (Join-Path $pluginPath "Info.lua"))) {
    Write-Host "Info.lua missing in installed plugin"
    exit 1
}

$markerPaths = @(
    Join-Path $env:TEMP "NoClipAuto\noclip-plugin-loaded.txt"
    Join-Path $pluginPath "smoke\plugin-loaded.txt"
)

$found = $false
foreach ($marker in $markerPaths) {
    if (Test-Path $marker) {
        $age = (Get-Date) - (Get-Item $marker).LastWriteTime
        if ($age.TotalMinutes -le 60) {
            $found = $true
            Write-Host "Plugin load marker: $marker ($([math]::Round($age.TotalSeconds))s ago)"
            break
        }
    }
}

if (-not $found) {
    $logDir = Join-Path $env:LOCALAPPDATA "Adobe\Lightroom\Logs\LrClassicLogs"
    if (Test-Path $logDir) {
        $logs = Get-ChildItem $logDir -Filter "*.log" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 5
        foreach ($log in $logs) {
            $hits = @(Get-Content $log.FullName -Tail 800 -ErrorAction SilentlyContinue |
                Select-String -Pattern "NoClipAuto|com\.noclipauto|NoClip Auto plugin loaded")
            if ($hits.Count -gt 0) {
                $found = $true
                Write-Host "Plugin found in log: $($log.Name)"
                break
            }
        }
    }
}

if (-not $found) {
    Write-Host "Plugin not loaded — install, restart LR, and run a plugin menu once if needed"
    exit 1
}

Write-Host "verify-lr-plugin PASS"
exit 0
