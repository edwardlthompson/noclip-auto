param(
    [ValidateSet("m3-smoke", "m5-smoke", "m8-smoke")]
    [string]$Command = "m3-smoke"
)

$ErrorActionPreference = "Stop"

$lr = Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $lr) {
    throw "Lightroom is not running"
}

$url = "lightroom://com.noclipauto.lightroom/$Command"
Write-Host "Invoking $url"
Start-Process "rundll32.exe" -ArgumentList @("url.dll,FileProtocolHandler", $url)
