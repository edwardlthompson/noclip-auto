$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$exe = Join-Path $root "NoClipAuto.lrdevplugin\bin\win-x64\noclip-analyze.exe"
$fixtures = Join-Path $root "tests\fixtures"

if (-not (Test-Path $exe)) {
    & (Join-Path $root "scripts\build-analyzer.ps1") -Profile release-small
}

if (-not (Test-Path $fixtures)) {
    & (Join-Path $root "scripts\generate-fixtures.ps1")
}

function Test-AnalyzerJson($path, $expect) {
    $output = & $exe --input $path --shadow-threshold 2 --highlight-threshold 253 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Analyzer exit $($LASTEXITCODE) on $path : $output"
    }

    $line = ($output | Out-String).Trim().Split("`n")[0]
    foreach ($key in @("schema_version", "shadow_clip_px", "highlight_clip_px", "shadow_clip_pct", "highlight_clip_pct", "total_px", "mean_luma", "median_luma", "p05_luma", "p50_luma", "p95_luma", "log_avg_luma")) {
        if ($line -notmatch "`"$key`"\s*:") {
            throw "Missing JSON key '$key' in output: $line"
        }
    }

    if ($line -notmatch '"schema_version"\s*:\s*2\b') {
        throw "Expected schema_version 2 in output: $line"
    }

    if ($null -ne $expect.shadow_clip_px -and $line -notmatch "`"shadow_clip_px`"\s*:\s*$($expect.shadow_clip_px)\b") {
        throw "shadow_clip_px mismatch on $path : $line"
    }
    if ($null -ne $expect.highlight_clip_px -and $line -notmatch "`"highlight_clip_px`"\s*:\s*$($expect.highlight_clip_px)\b") {
        throw "highlight_clip_px mismatch on $path : $line"
    }

    Write-Host "OK $([System.IO.Path]::GetFileName($path)) -> $line"
}

Test-AnalyzerJson (Join-Path $fixtures "black.jpg") @{ shadow_clip_px = 100; highlight_clip_px = 0 }
Test-AnalyzerJson (Join-Path $fixtures "white.jpg") @{ shadow_clip_px = 0; highlight_clip_px = 100 }
Test-AnalyzerJson (Join-Path $fixtures "gray.jpg") @{ shadow_clip_px = 0; highlight_clip_px = 0 }

Write-Host "test_analyzer.ps1 PASS"
exit 0
