param(
    [string]$Stack = "lightroom-rust",
    [switch]$Quick,
    [switch]$Ci
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

if ($Stack -ne "lightroom-rust") {
    Write-Host "WARN: only lightroom-rust stack supported; got $Stack"
}

function Invoke-Step($label, $scriptBlock) {
    Write-Host "feature-gate: $label"
    & $scriptBlock
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
        throw "feature-gate failed at $label (exit $LASTEXITCODE)"
    }
}

$bootstrapQuick = $Quick -or $Ci

Invoke-Step "validate-bootstrap" {
    if ($bootstrapQuick) {
        & (Join-Path $root "scripts\validate-bootstrap.ps1") -Quick
    }
    else {
        & (Join-Path $root "scripts\validate-bootstrap.ps1")
    }
}

Invoke-Step "foss-audit" {
    & (Join-Path $root "scripts\foss-audit.ps1")
}

Invoke-Step "repo-hygiene" {
    & (Join-Path $root "scripts\check-repo-hygiene.ps1")
}

if (-not $Ci) {
    Invoke-Step "m0_smoke" {
        & (Join-Path $root "scripts\smoke\m0_smoke.ps1")
    }
}

if (-not $Quick -and -not $Ci) {
    Invoke-Step "cargo-test" {
        Push-Location (Join-Path $root "noclip-analyze")
        cargo test
        if ($LASTEXITCODE -ne 0) { throw "cargo test failed" }
        Pop-Location
    }
    Invoke-Step "cargo-clippy" {
        Push-Location (Join-Path $root "noclip-analyze")
        cargo clippy -- -D warnings
        if ($LASTEXITCODE -ne 0) { throw "cargo clippy failed" }
        Pop-Location
    }
    Invoke-Step "build-analyzer" {
        & (Join-Path $root "scripts\build-analyzer.ps1") -Profile release-small
    }
    Invoke-Step "m2_smoke" {
        & (Join-Path $root "scripts\smoke\m2_smoke.ps1")
    }
    Invoke-Step "size-gate" {
        & (Join-Path $root "scripts\check-bundle-size.ps1")
        & (Join-Path $root "scripts\check-lua-size.ps1") -ShippedOnly
    }
}

Write-Host "Feature gate passed (stack=$Stack quick=$bootstrapQuick ci=$Ci)"
exit 0
