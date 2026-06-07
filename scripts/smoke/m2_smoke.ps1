$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

$exe = Join-Path $root "NoClipAuto.lrdevplugin\bin\win-x64\noclip-analyze.exe"
if (-not (Test-Path $exe)) {
    & (Join-Path $root "scripts\build-analyzer.ps1") -Profile release-small
}

$fixtures = Join-Path $root "tests\fixtures"
if (-not (Test-Path $fixtures)) {
    & (Join-Path $root "scripts\generate-fixtures.ps1")
}

$black = Join-Path $fixtures "black.jpg"
$output = & $exe --input $black --shadow-threshold 2 --highlight-threshold 253 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Analyzer failed on black fixture: $output"
}

if ($output -notmatch '"shadow_clip_px"\s*:\s*100') {
    throw "Expected 100 shadow clipped pixels on 10x10 black, got: $output"
}

$white = Join-Path $fixtures "white.jpg"
$outputWhite = & $exe --input $white --shadow-threshold 2 --highlight-threshold 253 2>&1
if ($outputWhite -notmatch '"highlight_clip_px"\s*:\s*100') {
    throw "Expected 100 highlight clipped pixels on 10x10 white, got: $outputWhite"
}

Write-Host "M2 smoke PASS"
exit 0
