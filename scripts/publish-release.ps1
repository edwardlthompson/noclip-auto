param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    [switch]$SkipPackage,
    [switch]$Draft
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$dist = Join-Path $root "dist"
$zipName = "NoClipAuto-v$Version-win64.lrdevplugin.zip"
$zipPath = Join-Path $dist $zipName
$tag = "v$Version"
$notesPath = Join-Path $env:TEMP "noclip-release-notes-$Version.md"

gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI not authenticated - run gh auth login"
}

if (-not $SkipPackage) {
    & (Join-Path $root "scripts\package-release.ps1") -Version $Version
    if ($LASTEXITCODE -ne 0) { throw "package-release failed" }
}

if (-not (Test-Path $zipPath)) {
    throw "Release zip not found: $zipPath"
}

$about = "Auto-fix highlight and shadow clipping in Lightroom Classic. FOSS, local-only. Windows + macOS (UNVALIDATED). Apache-2.0."
gh repo edit edwardlthompson/noclip-auto --description $about

$changelog = Get-Content (Join-Path $root "docs\CHANGELOG.md") -Raw
if ($changelog -match "(?ms)## \[$([regex]::Escape($Version))\][^\#]*") {
    $section = $Matches[0].Trim()
} else {
    $section = "## v$Version`n`nSee docs/CHANGELOG.md"
}
Set-Content -Path $notesPath -Value $section -Encoding UTF8

cmd /c "gh release view $tag >nul 2>nul"
$existingOk = ($LASTEXITCODE -eq 0)

if ($existingOk) {
    Write-Host "Release $tag already exists; uploading asset..."
    gh release upload $tag $zipPath --clobber
} else {
    if ($Draft) {
        gh release create $tag --title "NoClip Auto v$Version" --notes-file $notesPath --draft
    } else {
        gh release create $tag --title "NoClip Auto v$Version" --notes-file $notesPath
    }
    if ($LASTEXITCODE -ne 0) { throw "gh release create failed" }
    gh release upload $tag $zipPath --clobber
}

Write-Host "Published: https://github.com/edwardlthompson/noclip-auto/releases/tag/$tag"
exit 0
