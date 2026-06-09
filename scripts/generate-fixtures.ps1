$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$fixtures = Join-Path $root "tests\fixtures"
New-Item -ItemType Directory -Force -Path $fixtures | Out-Null

Add-Type -AssemblyName System.Drawing

function New-SolidJpeg($path, $color, $size = 10) {
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $brush = New-Object System.Drawing.SolidBrush $color
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.FillRectangle($brush, 0, 0, $size, $size)
    $graphics.Dispose()
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $bmp.Dispose()
}

New-SolidJpeg (Join-Path $fixtures "black.jpg") ([System.Drawing.Color]::FromArgb(0, 0, 0))
New-SolidJpeg (Join-Path $fixtures "white.jpg") ([System.Drawing.Color]::FromArgb(255, 255, 255))
New-SolidJpeg (Join-Path $fixtures "gray.jpg") ([System.Drawing.Color]::FromArgb(128, 128, 128))

$bench = New-Object System.Drawing.Bitmap 1920, 1080
$g = [System.Drawing.Graphics]::FromImage($bench)
$g.Clear([System.Drawing.Color]::FromArgb(128, 128, 128))
$g.Dispose()
$bench.Save((Join-Path $fixtures "bench-1080p.jpg"), [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bench.Dispose()

Write-Host "Generated fixtures in $fixtures"
