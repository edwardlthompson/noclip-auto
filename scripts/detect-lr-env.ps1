$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$result = @{
    status = "UNKNOWN"
    version = $null
    installPath = $null
    logPath = $null
}

$lrPaths = @(
    "${env:ProgramFiles}\Adobe\Adobe Lightroom Classic",
    "${env:ProgramFiles(x86)}\Adobe\Adobe Lightroom Classic"
)

foreach ($p in $lrPaths) {
    if (Test-Path $p) {
        $result.status = "INSTALLED"
        $result.installPath = $p
        break
    }
}

if ($result.status -ne "INSTALLED") {
    $result.status = "NOT_INSTALLED"
}

$logPath = Join-Path $env:LOCALAPPDATA "Adobe\Lightroom\Logs\LrClassicLogs"
if (Test-Path $logPath) {
    $result.logPath = $logPath
}

$outPath = Join-Path $root "docs\lr-env.json"
$result | ConvertTo-Json | Set-Content $outPath
Write-Host ($result | ConvertTo-Json)
Write-Host "Wrote $outPath"
