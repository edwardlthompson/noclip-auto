param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    [int]$MaxZipMB = 5
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$src = Join-Path $root "NoClipAuto.lrdevplugin"
$dist = Join-Path $root "dist"
$stage = Join-Path $dist "NoClipAuto.lrdevplugin"
$zipName = "NoClipAuto-v$Version-win64.lrdevplugin.zip"
$zipPath = Join-Path $dist $zipName

$devExclude = @(
    "M3SmokeHeadless.lua",
    "M5SmokeBootstrap.lua",
    "M8SmokeBootstrap.lua",
    "ProcessM3Smoke.lua",
    "ProcessM5Smoke.lua",
    "ProcessM8Smoke.lua"
)

& (Join-Path $root "scripts\build-analyzer.ps1") -Profile release-small

if (Test-Path $stage) {
    Remove-Item -Recurse -Force $stage
}
New-Item -ItemType Directory -Force -Path $dist | Out-Null
Copy-Item -Recurse -Force $src $stage

foreach ($name in $devExclude) {
    $path = Join-Path $stage $name
    Remove-Item -Force -ErrorAction SilentlyContinue $path
}

$smokeDir = Join-Path $stage "smoke"
if (Test-Path $smokeDir) {
    Get-ChildItem $smokeDir -Filter "*.trigger" -ErrorAction SilentlyContinue | Remove-Item -Force
}

$infoPath = Join-Path $stage "Info.lua"
$info = Get-Content $infoPath -Raw
$info = $info -replace 'title = "NoClip Auto - M3 Smoke \(dev\)",\r?\n\s*', ''
$info = $info -replace 'title = "NoClip Auto - M5 Smoke \(dev\)",\r?\n\s*', ''
$info = $info -replace 'title = "NoClip Auto - M8 Smoke \(dev\)",\r?\n\s*', ''
$parts = $Version.Split(".")
if ($parts.Count -lt 3) { throw "Version must be major.minor.patch (e.g. 1.0.0)" }
$info = $info -replace 'VERSION = \{ major = \d+, minor = \d+, revision = \d+, build = \d+ \}',
    ("VERSION = {{ major = {0}, minor = {1}, revision = {2}, build = 0 }}" -f $parts[0], $parts[1], $parts[2])
Set-Content -Path $infoPath -Value $info -Encoding UTF8 -NoNewline

$aboutPath = Join-Path $stage "Core\About.lua"
$about = Get-Content $aboutPath -Raw
$about = $about -replace 'About\.VERSION = \{ major = \d+, minor = \d+, revision = \d+, build = \d+ \}',
    ("About.VERSION = {{ major = {0}, minor = {1}, revision = {2}, build = 0 }}" -f $parts[0], $parts[1], $parts[2])
Set-Content -Path $aboutPath -Value $about -Encoding UTF8 -NoNewline

Remove-Item -Force -ErrorAction SilentlyContinue $zipPath
Compress-Archive -Path $stage -DestinationPath $zipPath

$zipMB = (Get-Item $zipPath).Length / 1MB
if ($zipMB -gt $MaxZipMB) {
    throw "Release zip too large: $([math]::Round($zipMB, 2)) MB (max $MaxZipMB MB)"
}

& (Join-Path $root "scripts\check-bundle-size.ps1") -MaxZipMB $MaxZipMB
& (Join-Path $root "scripts\check-lua-size.ps1") -ShippedOnly

Write-Host "Packaged: $zipPath ($([math]::Round($zipMB, 2)) MB)"
exit 0
