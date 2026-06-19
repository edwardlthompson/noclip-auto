$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$scopeDoc = Join-Path $root "docs\PARALLEL_AGENT_SCOPES.md"
if (-not (Test-Path $scopeDoc)) {
    Write-Host "FAIL: missing docs/PARALLEL_AGENT_SCOPES.md"
    exit 1
}
Write-Host "Parallel scope doc present — assign isolated paths per docs/PARALLEL_AGENT_SCOPES.md before dispatch"
Write-Host "Parallel scope check OK"
exit 0
