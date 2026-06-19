$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$errors = 0

function Fail($msg) {
    Write-Host "FAIL: $msg"
    $script:errors++
}

$requiredConfig = @(".editorconfig", ".gitattributes", ".cursorignore")
foreach ($f in $requiredConfig) {
    if (-not (Test-Path (Join-Path $root $f))) {
        Fail "missing $f"
    }
}

$requiredIgnore = @(
    "**/target/",
    "dist/",
    ".env",
    "NoClipAuto.lrdevplugin/bin/**/noclip-analyze*"
)

$gitignore = Join-Path $root ".gitignore"
if (-not (Test-Path $gitignore)) {
    Fail "missing .gitignore"
}
else {
    $gi = Get-Content $gitignore -Raw
    foreach ($entry in $requiredIgnore) {
        if ($gi -notmatch [regex]::Escape($entry)) {
            Fail ".gitignore missing entry: $entry"
        }
    }
}

$tracked = git ls-files 2>$null
if ($LASTEXITCODE -eq 0) {
    foreach ($line in $tracked) {
        if ($line -match 'noclip-analyze(\.exe)?$' -and $line -notmatch '\.gitkeep$') {
            Fail "tracked analyzer binary: $line"
        }
        if ($line -eq ".env") {
            Fail "tracked secret file: .env"
        }
    }
}

if ($errors -gt 0) {
    Write-Host "$errors repo hygiene check(s) failed"
    exit 1
}

Write-Host "Repo hygiene checks passed"
exit 0
