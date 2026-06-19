param(
    [string]$Stack = "lightroom-rust",
    [switch]$SkipFeatureGate
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$errors = 0

function Fail($msg) {
    Write-Host "FAIL: $msg"
    $script:errors++
}

function Ok($msg) {
    Write-Host "OK   $msg"
}

Write-Host "=== Pre-release gate ==="

if (-not $SkipFeatureGate) {
    & (Join-Path $root "scripts\feature-gate.ps1") -Stack $Stack
    if ($LASTEXITCODE -ne 0) {
        Fail "feature-gate.ps1"
    }
    else {
        Ok "feature-gate.ps1 passed"
    }
}

$templatePath = Join-Path $root ".template-version"
if (-not (Test-Path $templatePath)) {
    Fail "missing .template-version"
}
else {
    $templateVer = (Get-Content $templatePath -Raw).Trim()
    Ok ".template-version = $templateVer"
}

$licensesPath = Join-Path $root "THIRD_PARTY_LICENSES.md"
if (-not (Test-Path $licensesPath)) {
    Fail "missing THIRD_PARTY_LICENSES.md"
}
else {
    Ok "THIRD_PARTY_LICENSES.md present"
}

$infoPath = Join-Path $root "NoClipAuto.lrdevplugin\Info.lua"
$info = Get-Content $infoPath -Raw
$pluginVer = $null
if ($info -match 'VERSION\s*=\s*\{\s*major\s*=\s*(\d+)\s*,\s*minor\s*=\s*(\d+)\s*,\s*revision\s*=\s*(\d+)') {
    $pluginVer = "$($Matches[1]).$($Matches[2]).$($Matches[3])"
}
else {
    Fail "could not parse Info.lua VERSION"
}

$changelogPath = Join-Path $root "CHANGELOG.md"
$changelog = Get-Content $changelogPath -Raw
$changelogVer = $null
if ($changelog -match '## \[(\d+\.\d+\.\d+)\]') {
    $changelogVer = $Matches[1]
}
else {
    Fail "no released version section in CHANGELOG.md"
}

if ($pluginVer -and $changelogVer) {
    if ($pluginVer -ne $changelogVer) {
        Fail "Info.lua ($pluginVer) != CHANGELOG latest release ($changelogVer)"
    }
    else {
        Ok "plugin version $pluginVer matches CHANGELOG"
    }
}

try {
    & (Join-Path $root "scripts\foss-audit.ps1")
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
        Fail "foss-audit.ps1"
    }
    else {
        Ok "foss-audit.ps1 passed"
    }
}
catch {
    Fail "foss-audit.ps1 — $($_.Exception.Message)"
}

if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh auth status 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Ok "gh CLI authenticated"
    }
    else {
        Write-Host "WARN: gh not authenticated — run gh auth login before publish-release.ps1"
    }
}
else {
    Write-Host "WARN: gh CLI not installed"
}

Write-Host ""
Write-Host "REMINDER: Confirm CI is green on https://github.com/edwardlthompson/noclip-auto/actions"
if ($pluginVer) {
    Write-Host "REMINDER: Tag release with scripts/publish-release.ps1 -Version $pluginVer"
    Write-Host "          Verify CHANGELOG.md [$pluginVer] section is complete"
}

if ($errors -gt 0) {
    Write-Host "$errors pre-release gate check(s) failed"
    exit 1
}

Write-Host "Pre-release gate passed"
exit 0
