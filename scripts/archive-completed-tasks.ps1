param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$buildPlan = Join-Path $root "docs\BUILD_PLAN.md"
$completed = Join-Path $root "docs\BUILD_PLAN_COMPLETED.md"

if (-not (Test-Path $buildPlan)) {
    throw "BUILD_PLAN.md not found"
}

$content = Get-Content $buildPlan -Raw
$completedItems = [regex]::Matches($content, '(?m)^- \[x\].*$') | ForEach-Object { $_.Value }

if ($completedItems.Count -eq 0) {
    Write-Host "No completed items to archive."
    exit 0
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$archiveBlock = "`n## Archived $timestamp`n`n" + ($completedItems -join "`n") + "`n"

if (-not $DryRun) {
    Add-Content -Path $completed -Value $archiveBlock
    $newContent = [regex]::Replace($content, '(?m)^- \[x\].*\r?\n', '')
    Set-Content -Path $buildPlan -Value $newContent -NoNewline
}

Write-Host "Archived $($completedItems.Count) completed items."
