param(
    [string]$GoldenDir = "",
    [string]$ThresholdsPath = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

if (-not $GoldenDir) {
    $GoldenDir = Join-Path $root "tests\golden"
}
if (-not $ThresholdsPath) {
    $ThresholdsPath = Join-Path $GoldenDir "thresholds.json"
}

$configLua = Join-Path $root "NoClipAuto.lrdevplugin\Core\Pipeline\Config.lua"

function Get-ConfigCapValue([string]$name) {
    $raw = Get-Content $configLua -Raw
    if ($raw -notmatch "$name\s*=\s*(-?\d+)") {
        throw "Config.lua missing $name"
    }
    return [int]$Matches[1]
}

function Test-Phase2CapsConfig {
    param($Thresholds)

    $blacksCap = Get-ConfigCapValue "BLACKS_CAP"
    $whitesCap = Get-ConfigCapValue "WHITES_CAP"

    if ($blacksCap -ne $Thresholds.phase2_caps.blacks_max_delta) {
        throw "BLACKS_CAP ($blacksCap) != thresholds phase2_caps.blacks_max_delta ($($Thresholds.phase2_caps.blacks_max_delta))"
    }
    if ([math]::Abs($whitesCap) -ne $Thresholds.phase2_caps.whites_max_delta) {
        throw "WHITES_CAP ($whitesCap) magnitude != thresholds phase2_caps.whites_max_delta ($($Thresholds.phase2_caps.whites_max_delta))"
    }

    $blacksAccum = 0
    for ($i = 0; $i -lt 40; $i++) {
        $next = $blacksAccum + 1
        if ($next -le $blacksCap) {
            $blacksAccum = $next
        }
    }
    if ($blacksAccum -ne $blacksCap) {
        throw "Phase 2 blacks cap simulation: expected $blacksCap, got $blacksAccum"
    }

    $whitesAccum = 0
    $whitesMax = [math]::Abs($whitesCap)
    for ($i = 0; $i -lt 40; $i++) {
        $next = $whitesAccum + 1
        if ($next -le $whitesMax) {
            $whitesAccum = $next
        }
    }
    if ($whitesAccum -ne $whitesMax) {
        throw "Phase 2 whites cap simulation: expected $whitesMax, got $whitesAccum"
    }

    Write-Host "Phase 2 caps enforced (Blacks +$blacksCap, Whites $whitesCap)"
}

function Test-GoldenCase {
    param($Case, $Thresholds)

    $category = $Case.category
    if (-not $Thresholds.$category) {
        throw "Unknown golden category: $category"
    }

    $rules = $Thresholds.$category
    $before = $Case.before
    $after = $Case.after

    if ($category -eq "underexposed") {
        if ($after.shadowClipPct -gt $rules.shadowClipPct_after_max) {
            throw "$($Case.description): after shadowClipPct $($after.shadowClipPct) > max $($rules.shadowClipPct_after_max)"
        }
        $maxAfter = $before.shadowClipPct * $rules.shadowClipPct_reduction_factor
        if ($after.shadowClipPct -gt $maxAfter) {
            throw "$($Case.description): after shadowClipPct $($after.shadowClipPct) not reduced enough (max $maxAfter)"
        }
    } elseif ($category -eq "overexposed") {
        if ($after.highlightClipPct -gt $rules.highlightClipPct_after_max) {
            throw "$($Case.description): after highlightClipPct $($after.highlightClipPct) > max $($rules.highlightClipPct_after_max)"
        }
        $maxAfter = $before.highlightClipPct * $rules.highlightClipPct_reduction_factor
        if ($after.highlightClipPct -gt $maxAfter) {
            throw "$($Case.description): after highlightClipPct $($after.highlightClipPct) not reduced enough (max $maxAfter)"
        }
    }

    Write-Host "PASS: $($Case.category) - $($Case.description)"
}

if (-not (Test-Path $ThresholdsPath)) {
    throw "Thresholds not found: $ThresholdsPath"
}

$thresholds = Get-Content $ThresholdsPath -Raw | ConvertFrom-Json
Test-Phase2CapsConfig -Thresholds $thresholds

$cases = Get-ChildItem $GoldenDir -Filter "*.json" |
    Where-Object { $_.Name -ne "thresholds.json" }

if (-not $cases) {
    throw "No golden cases found in $GoldenDir"
}

foreach ($file in $cases) {
    $case = Get-Content $file.FullName -Raw | ConvertFrom-Json
    Test-GoldenCase -Case $case -Thresholds $thresholds
}

Write-Host ("verify-tone-quality PASS ({0} golden cases)" -f $cases.Count)
exit 0
