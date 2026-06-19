param(
    [switch]$SkipArchive,
    [switch]$SkipM9
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

function Invoke-Step {
    param([string]$Label, [scriptblock]$Action)
    Write-Host "run-milestone-tm-gate: $Label"
    & $Action
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
        throw "run-milestone-tm-gate failed at $Label (exit $LASTEXITCODE)"
    }
}

function Archive-TmSprint {
    $completed = Join-Path $root "COMPLETED_TASKS.md"
    $bpCompleted = Join-Path $root "docs\BUILD_PLAN_COMPLETED.md"
    $timestamp = Get-Date -Format "yyyy-MM-dd"

    $tm9Line = "- ✅ [AGENT] **TM.9** — run-milestone-tm-gate.ps1; TM sprint archived; gate PASS $timestamp"
    $completedText = Get-Content $completed -Raw
    if ($completedText -notmatch '\*\*TM\.9\*\*') {
        if ($completedText -match 'Sprint TM partial') {
            $completedText = $completedText -replace 'Sprint TM partial', "Sprint TM — Complete ($timestamp)"
        }
        $completedText = $completedText.TrimEnd() + "`n$tm9Line`n"
        Set-Content -Path $completed -Value $completedText -NoNewline
    }

    $archiveBlock = @"

## Sprint TM — Template Migration ✅ ($timestamp)

Bootstrap alignment to [agent-project-bootstrap](https://github.com/edwardlthompson/agent-project-bootstrap) v0.11.0 for **lightroom+rust** child repo.

| Phase | Deliverables |
|-------|--------------|
| TM.0 | validate-bootstrap, watch-agent-gates, BOOTSTRAP_TEMPLATE_MAP |
| TM.1 | modules/lightroom + rust, examples/golden-path |
| TM.2 | DECISION_LOG, ADR-0001, KNOWLEDGE_BASE, agent docs |
| TM.3 | 9 bootstrap .cursor/rules + CURSOR_MODES |
| TM.4 | dependabot, security/codeql, CI jobs, feature-gate, repo-hygiene |
| TM.5 | Root BUILD_PLAN, AGENTS, AGENT_MEMORY, CHANGELOG |
| TM.6 | editorconfig, gitattributes, pre-commit, template provenance |
| TM.7 | pre-release-gate, full feature-gate profile |
| TM.8 | README badges/gates, KNOWLEDGE_BASE module index |
| TM.9 | run-milestone-tm-gate closure |

**Gate:** ``scripts/run-milestone-tm-gate.ps1`` exit 0 on $timestamp.

Full task list: [COMPLETED_TASKS.md](../COMPLETED_TASKS.md).

"@
    $bpText = Get-Content $bpCompleted -Raw
    if ($bpText -notmatch 'Sprint TM — Template Migration') {
        Add-Content -Path $bpCompleted -Value $archiveBlock
    }

    Write-Host "Archived Sprint TM to COMPLETED_TASKS.md and docs/BUILD_PLAN_COMPLETED.md"
}

Write-Host "=== TM milestone gate ==="

Invoke-Step "validate-bootstrap" {
    & (Join-Path $root "scripts\validate-bootstrap.ps1")
}

Invoke-Step "feature-gate" {
    & (Join-Path $root "scripts\feature-gate.ps1") -Stack lightroom-rust
}

if (-not $SkipM9) {
    Invoke-Step "m9-regression" {
        & (Join-Path $root "scripts\run-milestone-gate.ps1") -Milestone 9
    }
}

if (-not $SkipArchive) {
    Archive-TmSprint
}

Write-Host "TM milestone gate passed"
exit 0
