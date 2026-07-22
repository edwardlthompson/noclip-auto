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

# Core bootstrap artifacts (lightroom+rust child repo profile @ template 0.15.0)
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
    "HUMAN_BACKLOG.md",
    "TEMPLATE_INDEX.json",
    "docs/BUILD_PLAN.md",
    "docs/AGENT_MEMORY.md",
    "docs/CHANGELOG.md",
    "docs/GATES.md",
    "docs/BOOTSTRAP_TEMPLATE_MAP.md",
    "docs/BOOTSTRAP_ALIGNMENT.md",
    "docs/UPGRADING_FROM_TEMPLATE.md",
    "docs/INITIALIZATION_PROMPT.md",
    "docs/REPO_HYGIENE.md",
    "docs/FILE_SIZE_GUIDE.md",
    ".cursor/AGENTS.md",
    ".cursor/hooks.json",
    ".cursor/stack-selection.json",
    ".cursor/permissions.json",
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
    "scripts/check-template-updates.ps1",
    "scripts/check-file-encoding.py",
    "scripts/smoke/m0_smoke.ps1",
    "scripts/smoke/m2_smoke.ps1",
    ".github/workflows/ci.yml",
    ".github/workflows/security.yml",
    ".github/workflows/codeql.yml",
    ".github/workflows/dependency-review.yml",
    ".github/workflows/scorecard.yml",
    ".github/workflows/stale.yml",
    ".github/workflows/weekly-health-check.yml",
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
    ".cursor/rules/local-compute.mdc",
    ".cursor/rules/security-triage.mdc",
    ".cursor/rules/feature-modules.mdc",
    ".cursor/commands/cleanup.md",
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

foreach ($f in $required) { Test-RequiredFile $f }

$buildPlan = Join-Path $root "BUILD_PLAN.md"
if (Test-Path $buildPlan) {
    $bp = Get-Content $buildPlan -Raw
    if ($bp -notmatch '\[AGENT\]' -and $bp -notmatch '\[HUMAN\]') {
        Write-Host "MISSING: BUILD_PLAN.md owner labels ([AGENT]/[HUMAN])"
        $errors++
    }
    if ($bp -notmatch 'Sprint TM' -and $bp -notmatch 'Sprint BA') {
        Write-Host "MISSING: Template Migration or Bootstrap Align sprint marker in BUILD_PLAN.md"
        $errors++
    }
}

$tv = (Get-Content (Join-Path $root ".template-version") -Raw).Trim()
if ($tv -ne "0.15.0") {
    Write-Host "UNEXPECTED: .template-version is '$tv' (expected 0.15.0 during Sprint BA)"
    $errors++
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
Invoke-Check "file-encoding" { python (Join-Path $root "scripts\check-file-encoding.py") $root }
Invoke-Check "template-index" {
    # Prefer Python on Windows (Git Bash path/space quirks); bash script remains for Unix CI.
    python -c @"
import json, os, sys
root = r'$root'
data = json.load(open(os.path.join(root, 'TEMPLATE_INDEX.json'), encoding='utf-8'))
errs = []
for ep in data.get('entry_points', []):
    if not os.path.exists(os.path.join(root, ep)):
        errs.append(ep)
for item in data.get('files', []):
    if not os.path.exists(os.path.join(root, item['path'])):
        errs.append(item['path'])
for mod in data.get('modules', {}).values():
    for key in ('guide', 'production', 'example'):
        p = mod.get(key)
        if p and not os.path.exists(os.path.join(root, p)):
            errs.append(p)
if errs:
    print('Missing:', *errs, sep='\n  ')
    sys.exit(1)
print('TEMPLATE_INDEX.json validation passed (python)')
"@
}

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

