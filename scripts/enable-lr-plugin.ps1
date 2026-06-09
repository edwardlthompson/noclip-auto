param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$pluginPath = Join-Path $env:APPDATA "Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin"
$pluginId = "com.noclipauto.lightroom"

if (-not (Test-Path $pluginPath)) {
    throw "Plugin not installed at $pluginPath"
}

function Format-LrPrefPath([string]$Path) {
    return ($Path -replace '\\', '\\\\')
}

$pluginPathEsc = Format-LrPrefPath $pluginPath

$prefsDir = Join-Path $env:APPDATA "Adobe\Lightroom\Preferences"
$prefsFile = Get-ChildItem $prefsDir -Filter "*Preferences.agprefs" |
    Where-Object { $_.Name -notmatch "Startup" } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $prefsFile) {
    throw "Lightroom preferences file not found in $prefsDir"
}

$content = Get-Content $prefsFile.FullName -Raw
$changed = $false

$idPattern = '\[\\"' + [regex]::Escape($pluginId) + '\\"\] = true,\\\r\n'
if ($content -match $idPattern) {
    $content = $content -replace $idPattern, ""
    $changed = $true
    Write-Host "Removed $pluginId from disabledPluginIDs"
}

$pathPattern = '\[\\"' + [regex]::Escape($pluginPathEsc) + '\\"\] = true,\\\r\n'
if ($content -match $pathPattern) {
    $content = $content -replace $pathPattern, ""
    $changed = $true
    Write-Host "Removed plugin path from disabledPluginPaths"
}

$installedPattern = '\[\\"' + [regex]::Escape($pluginPathEsc) + '\\"\] = \\"' + [regex]::Escape($pluginPathEsc) + '\\",\\\r\n'
if ($content -notmatch $installedPattern) {
    $entry = "`t[\`"$pluginPathEsc\`"] = \`"$pluginPathEsc\`",\" + "`r`n"
    if ($content -match 'AgSdkPluginLoader_installedPluginPaths = "t = \{\\') {
        $content = $content -replace '(AgSdkPluginLoader_installedPluginPaths = "t = \{\\)', "`$1$entry"
        $changed = $true
        Write-Host "Registered plugin path in installedPluginPaths"
    } else {
        throw "Could not find AgSdkPluginLoader_installedPluginPaths in preferences"
    }
}

if (-not $changed) {
    Write-Host "Plugin already enabled in Lightroom preferences"
    Write-Host "Plugin path: $pluginPath"
    exit 0
}

if (-not $Force) {
    Write-Host "Would update $($prefsFile.Name)"
    exit 0
}

Set-Content -Path $prefsFile.FullName -Value $content -NoNewline
Write-Host "Updated Lightroom plugin preferences (enabled)"
Write-Host "Plugin path: $pluginPath"
