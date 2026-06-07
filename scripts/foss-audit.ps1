$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$required = @(
    "LICENSE",
    "README.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "docs\FOSS.md",
    "docs\BUILD_PLAN.md",
    "NoClipAuto.lrdevplugin\Info.lua"
)

foreach ($f in $required) {
    $path = Join-Path $root $f
    if (-not (Test-Path $path)) {
        throw "FOSS audit fail: missing $f"
    }
}

$licenseContent = Get-Content (Join-Path $root "LICENSE") -Raw
if ($licenseContent -notmatch "Apache License") {
    throw "FOSS audit fail: LICENSE is not Apache-2.0"
}

Write-Host "FOSS audit passed."
