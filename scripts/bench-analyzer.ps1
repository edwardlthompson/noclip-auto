param(
    [double]$MinMpPerSec = 50,
    [int]$Runs = 5,
    [string]$Profile = "release-bench"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$cargoDir = Join-Path $root "noclip-analyze"
$fixtures = Join-Path $root "tests\fixtures"
$benchJpeg = Join-Path $fixtures "bench-1080p.jpg"

if (-not (Test-Path $benchJpeg)) {
    & (Join-Path $root "scripts\generate-fixtures.ps1")
    Add-Type -AssemblyName System.Drawing
    $bmp = New-Object System.Drawing.Bitmap 1920, 1080
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.Clear([System.Drawing.Color]::FromArgb(128, 128, 128))
    $graphics.Dispose()
    $bmp.Save($benchJpeg, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $bmp.Dispose()
    Write-Host "Generated bench fixture: $benchJpeg"
}

Push-Location $cargoDir
try {
    cargo build --profile $Profile
    if ($LASTEXITCODE -ne 0) { throw "cargo build --profile $Profile failed" }
} finally {
    Pop-Location
}

$exe = Join-Path $cargoDir "target\$Profile\noclip-analyze.exe"
if (-not (Test-Path $exe)) {
    throw "Bench analyzer not found: $exe"
}

$megapixels = (1920 * 1080) / 1e6
$times = @()

for ($i = 1; $i -le $Runs; $i++) {
    $outFile = Join-Path $env:TEMP "noclip-bench-out-$i.json"
    Remove-Item -Force -ErrorAction SilentlyContinue $outFile
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    & $exe --input $benchJpeg --output $outFile --shadow-threshold 2 --highlight-threshold 253 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "bench run $i failed" }
    if (-not (Test-Path $outFile)) { throw "bench run $i produced no output" }
    $sw.Stop()
    $times += $sw.Elapsed.TotalSeconds
}

$median = ($times | Sort-Object)[[math]::Floor($Runs / 2)]
$mpPerSec = $megapixels / $median

Write-Host ("Bench: {0:N2} MP, median {1:N3}s, {2:N1} MP/s (min {3} MP/s)" -f $megapixels, $median, $mpPerSec, $MinMpPerSec)

if ($mpPerSec -lt $MinMpPerSec) {
    throw "Performance gate FAIL: $([math]::Round($mpPerSec, 1)) MP/s < $MinMpPerSec MP/s"
}

Write-Host "Performance gate PASS"
exit 0
