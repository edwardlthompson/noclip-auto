$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

$required = @(
    "LICENSE",
    "README.md",
    "BUILD_PLAN.md",
    "AGENT_MEMORY.md",
    "CHANGELOG.md",
    "AGENTS.md",
    "docs\GATES.md",
    "docs\LR_TESTING.md",
    "docs\ALGORITHM.md",
    ".github\workflows\ci.yml",
    "NoClipAuto.lrdevplugin\Info.lua",
    "NoClipAuto.lrdevplugin\Init.lua",
    "noclip-analyze\Cargo.toml",
    "scripts\build-analyzer.ps1",
    "scripts\foss-audit.ps1"
)

$missing = @()
foreach ($f in $required) {
    if (-not (Test-Path (Join-Path $root $f))) {
        $missing += $f
    }
}

if ($missing.Count -gt 0) {
    Write-Error "M0 smoke FAIL - missing:`n$($missing -join "`n")"
    exit 1
}

& (Join-Path $root "scripts\foss-audit.ps1")
Write-Host "M0 smoke PASS"
exit 0
