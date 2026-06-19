param(
    [string]$RepoUrl,
    [string]$LrStatus
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$memoryPath = Join-Path $root "AGENT_MEMORY.md"

if ($LrStatus) {
    $content = Get-Content $memoryPath -Raw
    $content = $content -replace '\| LR status \| .* \|', "| LR status | $LrStatus |"
    Set-Content -Path $memoryPath -Value $content -NoNewline
}

if ($RepoUrl) {
    $content = Get-Content $memoryPath -Raw
    $content = $content -replace '\| GitHub repo \| .* \|', "| GitHub repo | $RepoUrl |"
    Set-Content -Path $memoryPath -Value $content -NoNewline
    Write-Host "Updated AGENT_MEMORY with repo URL"
}

if (Test-Path (Join-Path $root "docs\lr-env.json")) {
    $env = Get-Content (Join-Path $root "docs\lr-env.json") | ConvertFrom-Json
    & $MyInvocation.MyCommand.Path -LrStatus $env.status
}
