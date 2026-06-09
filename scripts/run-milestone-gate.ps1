param(
    [int]$Milestone = 0,
    [switch]$RequiresLR
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$smokeDir = Join-Path $root "scripts\smoke"

function Invoke-Smoke($name) {
    $path = Join-Path $smokeDir "${name}_smoke.ps1"
    if (Test-Path $path) {
        Write-Host "Running $name..."
        & $path
        if ($LASTEXITCODE -ne 0) { throw "$name failed with exit $LASTEXITCODE" }
    }
}

if ($RequiresLR) {
    & (Join-Path $root "scripts\ensure-lr-running.ps1")
}

switch ($Milestone) {
    0 {
        Invoke-Smoke "m0"
        & (Join-Path $root "scripts\foss-audit.ps1")
    }
    1 {
        Invoke-Smoke "m0"
        Invoke-Smoke "m1"
        & (Join-Path $root "scripts\verify-lr-plugin.ps1")
    }
    2 {
        Invoke-Smoke "m0"
        Invoke-Smoke "m2"
        Push-Location (Join-Path $root "noclip-analyze")
        cargo test
        if ($LASTEXITCODE -ne 0) { throw "cargo test failed" }
        Pop-Location
    }
    3 {
        Invoke-Smoke "m0"
        Invoke-Smoke "m2"
        Invoke-Smoke "m3"
    }
    4 {
        Invoke-Smoke "m0"
        Invoke-Smoke "m2"
        Invoke-Smoke "m4"
    }
    5 {
        Invoke-Smoke "m0"
        Invoke-Smoke "m2"
        Invoke-Smoke "m4"
        Invoke-Smoke "m5"
    }
    6 {
        Invoke-Smoke "m0"
        Invoke-Smoke "m2"
        Invoke-Smoke "m4"
        Invoke-Smoke "m6"
    }
    7 {
        Invoke-Smoke "m0"
        Invoke-Smoke "m7"
    }
    8 {
        Invoke-Smoke "m0"
        Invoke-Smoke "m2"
        Invoke-Smoke "m4"
        Invoke-Smoke "m8"
    }
    default {
        Invoke-Smoke "m0"
        if ($Milestone -ge 2) { Invoke-Smoke "m2" }
    }
}

Write-Host "Gate M$Milestone passed."
