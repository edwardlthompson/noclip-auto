# Idempotent GitHub repo security setup via gh api.
# Usage: scripts/setup-github-repo.ps1 [-Repo owner/name]
param(
    [string]$Repo = "edwardlthompson/noclip-auto",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

function Write-ManualChecklist {
    @"
MANUAL SETUP CHECKLIST (GitHub UI - API returned 422 or insufficient permissions):
  1. Settings -> Code security and analysis -> Dependabot alerts: ON
  2. Settings -> Code security and analysis -> Dependabot security updates: ON
  3. Settings -> Code security and analysis -> Private vulnerability reporting: ON
  4. Settings -> Branches -> Branch protection rules -> main:
     - Require status checks: CI, Security Scan, CodeQL, Repo Hygiene, Feature Gate, Scorecard analysis, Dependency Review
  5. Re-run: .\scripts\setup-github-repo.ps1
"@
}

function Invoke-GhApi {
    param(
        [string]$Method,
        [string]$Endpoint,
        [string]$Body = ""
    )
    $attempt = 0
    while ($attempt -lt 3) {
        $attempt++
        try {
            if ($Body) {
                $Body | gh api --method $Method $Endpoint --input - -i 2>&1
            }
            else {
                gh api --method $Method $Endpoint -i 2>&1
            }
            if ($LASTEXITCODE -eq 0) { return $true }
            return $false
        }
        catch {
            if ($attempt -ge 3) { throw }
            Start-Sleep -Seconds ($attempt * 2)
        }
    }
    return $false
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: gh CLI required (https://cli.github.com/)"
    exit 1
}

gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: gh not authenticated — run gh auth login"
    exit 1
}

if (-not $Repo) {
    $Repo = (gh repo view --json nameWithOwner | ConvertFrom-Json).nameWithOwner
}

$checks = if ($env:GITHUB_REQUIRED_CHECKS) {
    $env:GITHUB_REQUIRED_CHECKS -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}
else {
    @(
        "CI",
        "Security Scan",
        "CodeQL",
        "Repo Hygiene",
        "Feature Gate",
        "Scorecard analysis",
        "Dependency Review"
    )
}

Write-Host "Setting up GitHub repo security for $Repo (branch: $Branch)"

$failed = 0
$skipped = 0

foreach ($step in @(
        @{ Label = "Dependabot vulnerability alerts"; Method = "PUT"; Endpoint = "repos/$Repo/vulnerability-alerts" },
        @{ Label = "Private vulnerability reporting"; Method = "PUT"; Endpoint = "repos/$Repo/private-vulnerability-reporting" }
    )) {
    gh api --method $step.Method $step.Endpoint 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK   $($step.Label)"
    }
    elseif ($LASTEXITCODE -eq 1) {
        Write-Host "SKIP $($step.Label) (422 or plan limit)"
        Write-ManualChecklist
        $skipped++
    }
    else {
        Write-Host "FAIL $($step.Label)"
        $failed++
    }
}

$protection = @{
    required_status_checks = @{
        strict   = $true
        contexts = @($checks)
    }
    enforce_admins                = $false
    required_pull_request_reviews = @{
        dismiss_stale_reviews          = $true
        require_code_owner_reviews     = $false
        required_approving_review_count = 0
    }
    restrictions           = $null
    required_linear_history = $false
    allow_force_pushes     = $false
    allow_deletions        = $false
    block_creations        = $false
} | ConvertTo-Json -Depth 5 -Compress

$protection | gh api --method PUT "repos/$Repo/branches/$Branch/protection" --input - 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK   Branch protection on $Branch (checks: $($checks -join ', '))"
}
elseif ($LASTEXITCODE -eq 1) {
    Write-Host "SKIP Branch protection (422 or rulesets — verify in GitHub UI)"
    Write-ManualChecklist
    $skipped++
}
else {
    Write-Host "FAIL Branch protection"
    $failed++
}

if ($failed -gt 0) {
    Write-Host "$failed setup step(s) failed"
    exit 1
}

if ($skipped -gt 0) {
    Write-Host "Setup partially complete ($skipped skipped) — complete manual checklist if needed"
    exit 0
}

Write-Host "GitHub repo security setup complete for $Repo"
exit 0
