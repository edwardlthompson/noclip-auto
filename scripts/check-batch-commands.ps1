param()

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$errors = 0
$AtomicCmds = @(
    'audit'
    'debug'
    'gates'
    'triage'
    'dependabot'
    'push'
    'prerelease'
    'regress'
    'feature'
    'fix'
    'init'
    'prune'
    'ci'
    'docs'
    'upgrade'
    'setup'
    'plan'
    'restore'
    'compact'
    'scope'
)
$SuperCmds = @(
    'bootstrap'
    'verify'
    'build'
    'ship'
    'maintain'
)
$SuperChains = @{
    bootstrap = @('init', 'prune', 'setup', 'gates')
    verify    = @('docs', 'gates', 'ci')
    build     = @('plan', 'feature', 'gates')
    ship      = @('prerelease', 'push', 'regress')
    maintain  = @('triage', 'dependabot', 'audit')
}

function Fail($msg) {
    Write-Host $msg
    $script:errors++
}

foreach ($cmd in ($AtomicCmds + $SuperCmds)) {
    $path = Join-Path $root ".cursor\commands\$cmd.md"
    if (-not (Test-Path $path)) { Fail "MISSING: .cursor/commands/$cmd.md" }
}

Get-ChildItem (Join-Path $root ".cursor\commands\*.md") | ForEach-Object {
    $base = $_.BaseName
    if ($base -notin ($AtomicCmds + $SuperCmds)) { Fail "ORPHAN: $($_.FullName)" }
}

foreach ($super in $SuperCmds) {
    foreach ($child in $SuperChains[$super]) {
        $childPath = Join-Path $root ".cursor\commands\$child.md"
        if (-not (Test-Path $childPath)) {
            Fail "SUPER_CHAIN: $super references missing child $child"
        }
    }
}

$required = @(
    ".cursor/rules/batch-commands.mdc",
    "docs/BATCH_COMMANDS.md",
    "docs/help/BATCH_COMMANDS.md",
    "CODE_REVIEW.md.example",
    "RELEASE_NOTES.md.example"
)
foreach ($f in $required) {
    if (-not (Test-Path (Join-Path $root $f))) { Fail "MISSING: $f" }
}

$expected = $AtomicCmds.Count + $SuperCmds.Count
$actual = (Get-ChildItem (Join-Path $root ".cursor\commands\*.md")).Count
if ($actual -ne $expected) { Fail "COUNT: expected $expected command files, found $actual" }

if ($errors -gt 0) {
    Write-Host "$errors batch command check(s) failed"
    exit 1
}

Write-Host "Batch commands OK ($expected files: $($AtomicCmds.Count) atomic + $($SuperCmds.Count) super)"
exit 0
