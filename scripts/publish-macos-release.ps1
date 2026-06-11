param(
    [string]$Version = "1.3.0",
    [switch]$Wait
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI not authenticated - run gh auth login"
}

Write-Host "Triggering release-macos workflow for v$Version..."
gh workflow run release-macos.yml -f "version=$Version"
if ($LASTEXITCODE -ne 0) { throw "gh workflow run failed" }

if (-not $Wait) {
    Write-Host "Workflow started. Track: gh run list --workflow=release-macos.yml"
    Write-Host "Release asset: NoClipAuto-v$Version-macos-arm64.lrdevplugin.zip (UNVALIDATED)"
    exit 0
}

Write-Host "Waiting for workflow run..."
Start-Sleep -Seconds 10
$runId = (gh run list --workflow=release-macos.yml --limit 1 --json databaseId -q ".[0].databaseId")
if (-not $runId) { throw "Could not find workflow run" }

gh run watch $runId --exit-status
if ($LASTEXITCODE -ne 0) { throw "release-macos workflow failed" }

$tag = "v$Version"
Write-Host "Published: https://github.com/edwardlthompson/noclip-auto/releases/tag/$tag"
exit 0
