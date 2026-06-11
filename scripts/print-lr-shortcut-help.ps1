$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ahk = Join-Path $root "scripts\NoClipAuto-shortcuts.ahk"

Write-Host ""
Write-Host "NoClip Auto — keyboard shortcuts"
Write-Host ""
Write-Host "Lightroom Classic has NO plugin shortcut API."
Write-Host ""
Write-Host "=== macOS (built-in App Shortcuts) ==="
Write-Host "  System Settings -> Keyboard -> Keyboard Shortcuts -> App Shortcuts"
Write-Host "  Application: Adobe Lightroom Classic"
Write-Host "  Add one shortcut per menu item. Menu Title must include THREE leading spaces:"
Write-Host ""
Write-Host '    [space][space][space]NoClip Auto - Active Photo (File)'
Write-Host '    [space][space][space]NoClip Auto - Active Photo'
Write-Host '    [space][space][space]NoClip Auto - Selected Photos'
Write-Host ""
Write-Host "  File vs Library Active Photo use DIFFERENT titles (required for shortcuts to work)."
Write-Host ""
Write-Host "=== Windows (AutoHotkey — OS App Shortcuts do NOT work for LR plugins) ==="
Write-Host "  1. Install AutoHotkey v2: https://www.autohotkey.com/"
Write-Host "  2. Double-click: $ahk"
Write-Host "  3. Default hotkeys (Lightroom must be focused):"
Write-Host "       Ctrl+Alt+A         File > Plug-in Extras > Active Photo (File)  [Develop]"
Write-Host "       Ctrl+Alt+Shift+A   Library > Plug-in Extras > Active Photo"
Write-Host "       Ctrl+Alt+B         Library > Plug-in Extras > Selected Photos  [batch]"
Write-Host ""
Write-Host "  Edit the .ahk file to change hotkeys or if Plug-in Extras menu order differs."
Write-Host ""
Write-Host "If a shortcut does nothing:"
Write-Host "  - Restart Lightroom after plugin install"
Write-Host "  - Plug-in Manager -> NoClip Auto should show version 1.3.7+"
Write-Host "  - Turn OFF Dry run (Reset to defaults)"
Write-Host "  - Select photo(s) before running Library commands"
Write-Host "  - In Develop, use the (File) menu item or Ctrl+Alt+A"
Write-Host ""

if (Test-Path $ahk) {
    Write-Host "Shortcut script: $ahk"
}
