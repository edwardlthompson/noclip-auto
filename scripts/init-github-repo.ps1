param(
    [string]$Owner,
    [string]$Name = "noclip-auto",
    [switch]$Private
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$ghStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "NEEDS_GH_AUTH"
    exit 3
}

if (-not $Owner) {
    $Owner = gh api user -q .login
}

$visibility = if ($Private) { "--private" } else { "--public" }
$remote = gh repo view "$Owner/$Name" 2>$null
if ($LASTEXITCODE -ne 0) {
    gh repo create "$Owner/$Name" $visibility --source=. --remote=origin --description "FOSS Lightroom Classic plugin — auto no-clip tone pipeline"
    Write-Host "Created repo: https://github.com/$Owner/$Name"
} else {
    Write-Host "Repo already exists: https://github.com/$Owner/$Name"
}

& (Join-Path $root "scripts\update-agent-memory.ps1") -RepoUrl "https://github.com/$Owner/$Name"
