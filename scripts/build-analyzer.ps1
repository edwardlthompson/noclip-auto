param(
    [string]$Profile = "release-small"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$cargoDir = Join-Path $root "noclip-analyze"
$binDir = Join-Path $root "NoClipAuto.lrdevplugin\bin\win-x64"

New-Item -ItemType Directory -Force -Path $binDir | Out-Null

Push-Location $cargoDir
try {
    if ($Profile -eq "release") {
        cargo build --release
        $exe = Join-Path $cargoDir "target\release\noclip-analyze.exe"
    } else {
        cargo build --profile $Profile
        $exe = Join-Path $cargoDir "target\$Profile\noclip-analyze.exe"
    }
    if (-not (Test-Path $exe)) {
        throw "Build failed: $exe not found"
    }
    Copy-Item -Force $exe (Join-Path $binDir "noclip-analyze.exe")
    Write-Host "Built and copied: $binDir\noclip-analyze.exe"
} finally {
    Pop-Location
}
