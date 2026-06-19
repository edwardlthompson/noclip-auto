param(
    [switch]$Quick
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$errors = 0

function Test-RequiredFile($relativePath) {
    $full = Join-Path $root $relativePath
    if (-not (Test-Path $full)) {
        Write-Host "MISSING: $relativePath"
        script:errors++
    }
}

# Core bootstrap artifacts (lightroom+rust child repo profile)
$required = @(
    "README.md",
    "LICENSE",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "COMPLETED_TASKS.md",
    "BUILD_PLAN.md",
    "AGENT_MEMORY.md",
    "CHANGELOG.md",
    "AGENTS.md",
    "docs/BUILD_PLAN.md",
    "docs/AGENT_MEMORY.md",
    "docs/CHANGELOG.md",
    "docs/GATES.md",
    "docs/BOOTSTRAP_TEMPLATE_MAP.md",
    ".cursor/AGENTS.md",
    "NoClipAuto.lrdevplugin/Info.lua",
    "noclip-analyze/Cargo.toml",
    "scripts/foss-audit.ps1",
    "scripts/run-milestone-gate.ps1",
    "scripts/run-milestone-tm-gate.ps1",
    "scripts/watch-agent-gates.ps1",
    "scripts/feature-gate.ps1",
    "scripts/pre-release-gate.ps1",
    "scripts/check-github-ci.ps1",
    "scripts/setup-github-repo.ps1",
    "scripts/check-batch-commands.ps1",
    "scripts/check-parallel-scope.ps1",
    "scripts/check-repo-hygiene.ps1",
    "scripts/smoke/m0_smoke.ps1",
    "scripts/smoke/m2_smoke.ps1",
    ".github/workflows/ci.yml",
    ".github/workflows/security.yml",
    ".github/workflows/codeql.yml",
    ".github/dependabot.yml",
    ".github/CODEOWNERS",
    "modules/lightroom/MODULE.md",
    "modules/rust/MODULE.md",
    "examples/golden-path/README.md",
    "DECISION_LOG.md",
    "docs/adr/0001-core-architecture.md",
    "KNOWLEDGE_BASE.md",
    "PROMPT_LIBRARY.md",
    "docs/START_HERE.md",
    "docs/FOR_AGENTS.md",
    "docs/FEATURE_MODULES.md",
    "docs/CURSOR_MODES.md",
    "docs/SECURITY_TRIAGE.md",
    "docs/THREAT_MODEL.md",
    "docs/PRIVACY.md",
    "docs/RUNBOOK.md",
    "docs/help/BATCH_COMMANDS.md",
    "docs/BATCH_COMMANDS.md",
    "docs/PARALLEL_AGENT_SCOPES.md",
    ".cursor/rules/settings-ui-hints.mdc",
    ".cursor/rules/ci-gates.mdc",
    ".cursor/rules/core-directives.mdc",
    ".cursor/rules/foss-compliance.mdc",
    ".cursor/rules/read-before-write.mdc",
    ".cursor/rules/testing.mdc",
    ".cursor/rules/repo-hygiene.mdc",
    ".cursor/rules/destructive-ops.mdc",
    ".cursor/rules/windows-encoding.mdc",
    ".cursor/rules/cursor-modes.mdc",
    ".cursor/rules/batch-commands.mdc",
    ".editorconfig",
    ".gitattributes",
    ".cursorignore",
    ".pre-commit-config.yaml",
    ".template-update.json",
    ".template-version",
    ".env.example",
    "CODE_OF_CONDUCT.md",
    "THIRD_PARTY_LICENSES.md",
    "CODE_REVIEW.md.example",
    "RELEASE_NOTES.md.example",
    ".cursor-session-state.example.json"
)

# TM.5 complete — root docs required (see $required above)

foreach ($f in $required) { Test-RequiredFile $f }

$buildPlan = Join-Path $root "BUILD_PLAN.md"
if (Test-Path $buildPlan) {
    $bp = Get-Content $buildPlan -Raw
    if ($bp -notmatch '\[AGENT\]' -and $bp -notmatch '\[HUMAN\]') {
        Write-Host "MISSING: BUILD_PLAN.md owner labels ([AGENT]/[HUMAN])"
        $errors++
    }
    if ($bp -notmatch 'Sprint TM') {
        Write-Host "MISSING: Template Migration Sprint in BUILD_PLAN.md"
        $errors++
    }
}

function Invoke-Check($label, $scriptBlock) {
    try {
        & $scriptBlock
        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
            Write-Host "FAIL: $label (exit $LASTEXITCODE)"
            $script:errors++
        }
    }
    catch {
        Write-Host "FAIL: $label — $($_.Exception.Message)"
        $script:errors++
    }
}

Invoke-Check "foss-audit" { & (Join-Path $root "scripts\foss-audit.ps1") }
Invoke-Check "batch-commands" { & (Join-Path $root "scripts\check-batch-commands.ps1") }

if (-not $Quick) {
    Invoke-Check "m0_smoke" { & (Join-Path $root "scripts\smoke\m0_smoke.ps1") }
}

if ($errors -gt 0) {
    Write-Host "$errors bootstrap check(s) failed"
    exit 1
}

if ($Quick) {
    Write-Host "Bootstrap validation passed (--Quick: skipped m0 smoke)"
}
else {
    Write-Host "Bootstrap validation passed"
}
exit 0
