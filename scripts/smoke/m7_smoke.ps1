$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "M7 smoke: Mac release scripts + CI gate (Windows agent)"

$required = @(
    "scripts\install-plugin.sh"
    "scripts\ensure-lr-running.sh"
    "scripts\build-analyzer-macos.sh"
    "scripts\package-release-macos.sh"
    "scripts\smoke\m7_smoke.sh"
    "docs\MAC.md"
    "NoClipAuto.lrdevplugin\bin\macos-arm64\.gitkeep"
)

foreach ($path in $required) {
    $full = Join-Path $root $path
    if (-not (Test-Path $full)) {
        throw "Missing M7 artifact: $path"
    }
}

$ci = Get-Content (Join-Path $root ".github\workflows\ci.yml") -Raw
if ($ci -notmatch "build-analyzer-macos-arm64") {
    throw "CI missing build-analyzer-macos-arm64 job"
}

$release = Get-Content (Join-Path $root ".github\workflows\release-macos.yml") -Raw -ErrorAction SilentlyContinue
if (-not $release -or $release -notmatch "macos-arm64") {
    throw "Missing or incomplete .github/workflows/release-macos.yml"
}

$gates = Get-Content (Join-Path $root "docs\GATES.md") -Raw
if ($gates -notmatch "GM") {
    throw "GATES.md missing Gate GM"
}

Write-Host "M7 smoke PASS (Mac build/release validated in CI on macos-latest)"
exit 0
